//Author :Lim
//function:
//to initial SD Card
module sd_initial(
    input           rst_n,
    input           sd_ck,
    input           sd_miso,
    output reg      sd_mosi,
    output reg      sd_csn,
    input           sd_init,//start init
    output reg      init_ok,
    input           sd_ren,
    output req[7:0] sd_miso_data
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
reg      next_sd_mosi;
reg      next_sd_csn;
reg[5:0] tx_cnt,next_tx_cnt;
reg[47:0]data,next_data;
reg[9:0] cnt,next_cnt;
reg[2:0] req,next_req;
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
        req       <= 0;
    end
    else begin
        state     <= next_state;
        init_ok    <= next_init_ok;
        sd_mosi <= next_sd_mosi;
        sd_csn     <= next_sd_csn;
        tx_cnt    <= next_tx_cnt;
        data      <= next_data;
        cnt       <= next_cnt;
        req       <= next_req;
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
    next_req       = req;
    case(state)
        idle:begin
            next_cnt        = 1023;
            next_sd_csn     = 1'b1;
            next_sd_mosi    = 1'b1;
            next_init_ok    = init_ok;
            if(!init_ok&sd_init)begin
                next_state     = dummy;
            end
            else if(init_ok&sd_ren)begin
                next_state     = send_cmd17;
                next_sd_mosi   = `CMD17>>47;
                next_data      = `CMD17;
                next_tx_cnt    = 47;
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
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[7:0]==8'h01)begin
                next_state   = send_cmd55;
                next_sd_mosi = `CMD55>>47;
                next_data    = `CMD55;
                next_tx_cnt  = 47;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        send_cmd55:begin
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[7:0]==8'h00)begin
                next_state   = send_acmd41;
                next_sd_mosi = `ACMD41>>47;
                next_data    = `ACMD41;
                next_tx_cnt  = 47;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        send_acmd41:begin
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[7:0]==8'h01)begin
                next_state   = init_done;
                next_init_ok = 1'b1;
                next_sd_csn  = 1'b1;
                next_sd_mosi = 1'b1;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        send_cmd17:begin
            if(rx[47:40]==8'h0)begin
                 next_state = rd_data;
            end
        end
        rd_data:begin
            if(req==1'b0&rx[7:0]==8'hfe)begin
                req = 1'b1;
                next_rx_cnt = 7;
                next_cnt    = 512+2;//512+2 byte crc
            end
            else if(req==1'b1)begin
                next_rx_cnt = (|cnt)&rx_cnt==0 ? 7 :rx_cnt - |rx_cnt;
                next_wclk   = rx_cnt == 0;
                next_miso   = rx[7:0];
                next_req    = cnt==0&rx_cnt==0 ? 2'b10 : req;
                if(cnt==0&rx_cnt==0)begin
                    next_req    = 2'b10;
                    next_csn    = 1'b1;
                    next_cnt    = 7;
                end
            end
            else if(req==2'b10)begin
                next_cnt = cnt - |cnt;
                next_wclk = 1'b0;
                if(cnt==0)begin
                    next_req = 0;
                    next_state = rd_done;
                end
            end
        end
        init_done:begin
            if(fifo_done)begin
                next_state = idle;
            end
        end
        rd_done:begin
            if(fifo_done)begin
                next_state = idle;
            end
        end
    endcase
end
endmodule
