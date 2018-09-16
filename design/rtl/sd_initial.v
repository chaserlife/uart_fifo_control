//Author :Lim
//function:
//to initial SD Card
module sd_initial(
    input           rst_n,
    input           sd_ck,
    input           sd_miso,
    output          sd_mosi,
    output          sd_csn,
    input           sd_init,//start init
    output reg      init_ok
    //output reg[3:0] state,
    //output reg[47:0] rx
);

parameter idle        =4'b0000, //idle
          send_cmd0   =4'b0001, //send cmd0
          wait_01     =4'b0010, //wait cmd0 resp.
          waitb       =4'b0011, //wait a time
          send_cmd8   =4'b0100, //send cmd8
          waita       =4'b0101, //wait cmd8 resp.
          send_cmd55  =4'b0110, //send cmd55
          send_acmd41 =4'b0111, //send acmd41
          init_done   =4'b1000, //initial done
          init_fail   =4'b1001, //initial fail
          dummy       =4'b1010; //dummy

//receive sd data
reg      en;//enalbe signal to start receive data
reg[5:0] rx_cnt;//rx counter for reveive 48 data
reg      rx_valid;
reg[47:0]rx;

reg[5:0] state,next_state;
reg      next_init_ok;
reg      sd_mosi,next_sd_mosi;
reg      sd_csn,next_sd_csn;
reg[5:0] tx_cnt,next_tx_cnt;
reg[47:0]data,next_data;
reg[9:0] cnt,next_cnt;
wire     sd_miso;

always@(posedge sd_ck or negedge rst_n)begin
    if(!rst_n)begin
        rx <= 48'hff_ff_ff_ff_ff_ff;
    end
    else if(!sd_mosi)begin
        rx <= 48'hff_ff_ff_ff_ff_ff;
    end
    else begin
        rx <= {rx[46:0],sd_miso};
    end
end
always@(negedge sd_ck or negedge rst_n)begin
    if(!rst_n)begin
        state     <= idle;
        init_ok    <= 1'b0;
        sd_mosi <= 1'b1;
        sd_csn     <= 1'b1;
        tx_cnt    <= 0;
        data      <= 0;
        cnt       <= 0;
    end
    else begin
        state     <= next_state;
        init_ok    <= next_init_ok;
        sd_mosi <= next_sd_mosi;
        sd_csn     <= next_sd_csn;
        tx_cnt    <= next_tx_cnt;
        data      <= next_data;
        cnt       <= next_cnt;
    end
end
always@(*)begin
    next_state     = state;
    next_tx_cnt    = tx_cnt - |tx_cnt;
    next_init_ok   = init_ok;
    next_sd_mosi   = sd_mosi;
    next_sd_csn    = sd_csn;
    next_data      = data;
    next_cnt       = cnt  - |cnt;
    case(state)
        idle:begin
            next_cnt        = 1023;
            next_sd_csn     = 1'b1;
            next_sd_mosi    = 1'b1;
            next_init_ok    = init_ok;
            if(!init_ok&sd_init)begin
                next_state     = dummy;
            end
        end
        dummy:begin
            if(|cnt)begin
                next_state = dummy;
            end
            else begin
                next_sd_csn = 1'b1;
                next_state  = send_cmd0;
                next_data   = `CMD0;
                next_tx_cnt = 48;
            end
        end
        send_cmd0:begin//send cmd0
            if(|tx_cnt)begin
                next_sd_csn  = 1'b0;
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[7:0]==8'h01)begin
                next_state   = send_cmd8;
                next_sd_mosi = `CMD8>>47;
                next_data    = `CMD8;
                next_tx_cnt  = 47;
            end
        end
        send_cmd8:begin
//R7
//[39:0] R1
//[31:28] command version
//[27:12] reserved bits
//[11:8]  voltage accepted
//[7:0]   check pattern
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
                next_state   = send_cmd8;
            end
            else if(rx[7:0]==8'h01)begin
                next_init_ok = 1'b1;
            end
            else begin
                next_state   = waita;
                next_sd_mosi = 1'b1;
            end
        end
        //waita:begin//cmd8 resp. SD2.0,support 2.7-3.6V supply
        //    if(rx_valid)begin
        //        if(rx[19:16]==4'b0001)begin
        //            next_state  = send_cmd55;
        //            next_data   = `CMD55;
        //            next_tx_cnt = 48;
        //        end
        //        else begin
        //            next_state = init_fail;
        //        end
        //        next_sd_csn = 1'b1;
        //    end
        //    else begin
        //        next_sd_csn     = 1'b0;
        //        next_sd_mosi = 1'b1;
        //        next_state     = waita;
        //    end
        //end
        //send_cmd55:begin
        //    if(|tx_cnt)begin
        //        next_sd_csn = 1'b0;
        //        next_sd_mosi = data[tx_cnt-1];
        //        next_state     = send_cmd55;
        //        next_cnt       = tx_cnt==1 ? 127 : cnt;
        //    end
        //    else if(|cnt)begin
        //       next_sd_mosi  = 1'b1;
        //       if(rx_valid&rx[47:40]==8'h01)begin//CMD55 resp.
        //           next_state  = send_acmd41;
        //           next_data   = `ACMD41;
        //           next_tx_cnt = 48;
        //           next_cnt    = 0;
        //           next_sd_csn = 1'b1;
        //       end
        //       else begin
        //           next_state = send_cmd55;
        //           next_sd_csn = 1'b0;
        //       end
        //    end
        //    else begin
        //        next_sd_csn = 1'b1;
        //        next_state = init_fail;
        //    end
        //end
        //send_acmd41:begin
        //    if(|tx_cnt)begin
        //        next_sd_csn = 1'b0;
        //        next_sd_mosi = data[tx_cnt-1];
        //        next_state     = send_acmd41;
        //        next_cnt       = tx_cnt==1 ? 127 : cnt;
        //    end
        //    else if(|cnt)begin
        //        next_sd_csn = 1'b0;
        //        next_sd_mosi = 1'b1;
        //        if(rx_valid&rx[47:40]==8'h00)begin
        //            next_state = init_done;
        //        end
        //        else begin
        //            next_state = send_acmd41;
        //        end
        //    end
        //    else begin
        //        next_sd_csn = 1'b1;
        //        next_state = init_fail;
        //    end
        //end
        //init_done:begin
        //    next_init_ok    = 1'b1;
        //    next_sd_csn     = 1'b1;
        //    next_sd_mosi = 1'b1;
        //end
        //init_fail:begin
        //    next_init_ok    = 1'b0;
        //    next_sd_csn     = 1'b1;
        //    next_sd_mosi = 1'b1;
        //    next_state     = waitb;//resend cmd8,cmd55,cmd41
        //end
        //default:begin
        //    next_state     = idle;//sverilog 'x
        //    next_init_ok    = 1'b0;
        //    next_sd_csn     = 1'b1;
        //    next_sd_mosi = 1'b1;
        //end
    endcase
end
endmodule
