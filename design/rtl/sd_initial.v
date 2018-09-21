//Author :Lim
//function:
//to initial SD Card
module sd_initial(
    input           rst_n,
    input           clk,
    output reg      sd_ck,
    input           sd_miso,
    output reg      sd_mosi,
    output reg      sd_csn,
    input           sd_init,//start init
    output reg      init_ok,
    input           sd_ren,
    input           fifo_busy,
    output reg      wclk,
    output reg[7:0] miso_data,
    output reg      rd_ok
    //output reg[3:0] state,
    //output reg[47:0] rx
);
reg[3:0] cnt_clk;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_clk <= 0;
    end
    else begin
        cnt_clk <= cnt_clk==5 ? 0 :cnt_clk + 1;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sd_ck <= 1'b0;
    end
    else begin
        sd_ck <= cnt_clk==5 ? ~sd_ck : sd_ck;
    end
end
parameter idle        = 4'b0000, //idle
          dummy       = 4'h8,
          send_cmd0   = 4'h1, //send cmd0
          send_cmd8   = 4'h2, //send cmd8
          send_cmd55  = 4'h3, //send cmd55
          send_acmd41 = 4'h4, //send acmd41
          send_cmd17  = 4'h5, //initial done
          rd_data     = 4'h6, //initial fail
          init_done   = 4'h7, //dummy
          rd_done     = 4'h9;

//receive sd data
reg      en;//enalbe signal to start receive data
reg      rx_valid;
reg[47:0]rx;
reg[7:0] next_miso_data;
reg[5:0] state,next_state;
reg      next_init_ok;
reg      next_sd_mosi;
reg      next_sd_csn;
reg[5:0] tx_cnt,next_tx_cnt;
reg[47:0]data,next_data;
reg[10:0]cnt,next_cnt;
reg[2:0] req,next_req;
reg[7:0] rx_cnt,next_rx_cnt;
reg      next_wclk;
reg      next_rd_ok;
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
        init_ok   <= 1'b0;
        sd_mosi   <= 1'b1;
        sd_csn    <= 1'b1;
        tx_cnt    <= 0;
        rx_cnt    <= 0;
        data      <= 0;
        cnt       <= 0;
        req       <= 0;
        miso_data <= 0;
        wclk      <= 0;
        rd_ok     <= 0;
    end
    else begin
        state     <= next_state;
        init_ok   <= next_init_ok;
        sd_mosi   <= next_sd_mosi;
        sd_csn    <= next_sd_csn;
        tx_cnt    <= next_tx_cnt;
        rx_cnt    <= next_rx_cnt;
        data      <= next_data;
        cnt       <= next_cnt;
        req       <= next_req;
        miso_data <= next_miso_data;
        wclk      <= next_wclk;
        rd_ok     <= next_rd_ok;
    end
end
always@(*)begin
    next_state     = state;
    next_tx_cnt    = tx_cnt - |tx_cnt;
    next_rx_cnt    = rx_cnt - |rx_cnt;
    next_init_ok   = init_ok;
    next_sd_mosi   = sd_mosi;
    next_sd_csn    = sd_csn;
    next_data      = data;
    next_cnt       = cnt;//  - |cnt;
    next_req       = req;
    next_miso_data = miso_data;
    next_wclk      = wclk;
    next_rd_ok     = rd_ok;
    case(state)
        idle:begin
            next_sd_csn     = 1'b1;
            next_sd_mosi    = 1'b1;
            next_init_ok    = init_ok;
            if(!init_ok&sd_init)begin
                next_cnt       = 1023;
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
            next_cnt       = cnt  - |cnt;
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
            else if(rx[47:40]==8'h01)begin
                next_state   = send_cmd8;
                next_sd_mosi = `CMD8>>47;
                next_data    = `CMD8;
                next_tx_cnt  = 47;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        send_cmd8:begin
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[47:40]==8'h01)begin
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
            else if(rx[47:40]==8'h01)begin
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
            else if(rx[47:40]==8'h00)begin
                next_state   = init_done;
                next_init_ok = 1'b1;
                next_sd_csn  = 1'b1;
                next_sd_mosi = 1'b1;
            end
            else if(rx[47:40]==8'h01)begin
                next_state   = send_cmd55;
                next_sd_mosi = `CMD55>>47;
                next_data    = `CMD55;
                next_tx_cnt  = 47;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        send_cmd17:begin
            if(|tx_cnt)begin
                next_sd_mosi = data[tx_cnt-1];
            end
            else if(rx[47:40]==8'h0)begin
                 next_state = rd_data;
            end
            else begin
                next_sd_mosi = 1'b1;
            end
        end
        rd_data:begin
            if(req==1'b0&rx[7:0]==8'hfe)begin
                next_req = 1'b1;
                next_rx_cnt = 7;
                next_cnt    = 512+2;//512+2 byte crc
            end
            else if(req==1'b1)begin
                next_cnt       =|rx_cnt ? cnt : cnt - 1;
                next_rx_cnt    = (|cnt)&rx_cnt==0 ? 7 :rx_cnt - |rx_cnt;
                next_wclk      = rx_cnt == 0;
                next_miso_data = rx_cnt==0 ? rx[7:0] : miso_data;
                next_req       = cnt==0&rx_cnt==0 ? 2'b10 : req;
                if(cnt==0&rx_cnt==0)begin
                    next_req    = 2'b10;
                    next_sd_csn    = 1'b1;
                    next_cnt    = 7;
                end
            end
            else if(req==2'b10)begin
                next_wclk = 1'b0;
                next_state = rd_done;
                next_rd_ok = 1'b1;
                //next_cnt = cnt - |cnt;
                //next_wclk = 1'b0;
                //if(cnt==0)begin
                //    next_req = 0;
                //    next_state = rd_done;
                //end
            end
        end
        init_done:begin
            if(fifo_busy)begin
                next_state = idle;
            end
        end
        rd_done:begin
            if(fifo_busy)begin
                next_state = idle;
                next_rd_ok = 1'b0;
            end
        end
    endcase
end
endmodule
