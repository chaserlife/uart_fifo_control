module ufu(
    input   clk,
    input   rst_n,
    input   mosi,
    output  miso,
    output  busy,
    input   start
);
wire      rok;
wire      clk_bps;
wire      fu_ok;
wire[7:0] data_uf;
wire[7:0] data_fu;
wire[7:0] mosi_fifo;
wire[7:0] miso_fifo;
parameter idle    = 0;
parameter rx_data = 1;
parameter tx_data = 2;
parameter tx_num  = 3;
parameter rx_num  = 4;
reg[3:0]  state,next_state;
reg[15:0] cnt,next_cnt;
reg[15:0] hcnt,next_hcnt;
reg       wclk,next_wclk;
reg       rclk,next_rclk;
wire      wok;
reg       start_tx,next_start_tx;
reg[7:0]  hcnt,next_hcnt;
wire      rdy;
always@(posedge clk_bps or negedge rst_n)begin
    if(!rst_n)begin
        state    <= idle;
        cnt      <= 0;
        wclk     <= 1'b0;
        rclk     <= 1'b0;
        start_tx <= 1'b0;
        hcnt     <= 0;
    end
    else begin
        state    <= next_state;
        cnt      <= next_cnt;
        wclk     <= next_wclk;
        rclk     <= next_rclk;
        start_tx <= next_start_tx;
        hcnt     <= next_hcnt;
    end
end
always@(*)begin
    next_state    = state;
    next_cnt      = cnt;
    next_rclk     = rclk;
    next_wclk     = wclk;
    next_start_tx = start_tx;
    next_hcnt     = hcnt;
    case(state)
        idle:begin
            next_rclk = 1'b0;
            next_wclk = 1'b0;
            //if(!mosi)begin
            if(start)begin
                next_state = rx_num;
                next_cnt   = 9;
            end
        end
        rx_num:begin
            if(rok)begin
                next_cnt = cnt - |cnt;
                case(cnt)
                    9:next_wclk = 1'b1;
                    8:next_wclk = 1'b1;
                endcase
            end
            else begin
                case(cnt)
                    8:{next_wclk,next_hcnt} = {1'b0,hcnt[7:0],data_uf};
                    7:begin 
                        {next_wclk,next_hcnt} = {1'b0,hcnt[7:0],data_uf};
                        next_cnt = cnt - |cnt;
                    end
                    6:begin
                        next_state = rx_data;
                        next_cnt   = hcnt;
                    end
                endcase
            end
        end
        rx_data:begin
            next_wclk = rok;
            if(rok)begin
                next_cnt = cnt - |cnt;
            end
            else if(~|cnt)begin
                next_state = tx_num;
                next_cnt   = 9;
            end
        end
        tx_num:begin
           next_cnt = cnt - |cnt;
           case(cnt)
               9:{next_rclk,next_hcnt} = {1'b1,hcnt[15:8],hcnt[7:0]};
               8:{next_rclk,next_hcnt} = {1'b0,hcnt[7:0] ,data_fu  };
               7:{next_rclk,next_hcnt} = {1'b1,hcnt[15:8],hcnt[7:0]};
               6:{next_rclk,next_hcnt} = {1'b0,hcnt[7:0] ,data_fu  };
               5:{next_rclk} = {1'b1};
               4:{next_rclk} = {1'b0};
           endcase
           if(~|cnt)begin
               next_state    = tx_data;
               next_cnt      = hcnt;
               next_start_tx = 1'b1;
           end
        end
        tx_data:begin
            if(wok)begin
                next_rclk     = 1'b1;
                next_cnt      = cnt - |cnt;
            end
            else begin
                next_rclk    = 1'b0;
                next_start_tx = !rdy;
                next_state    = rdy ? done : tx_data;
            end
        end
        done:begin
            next_state = idle;
        end
    endcase
end
assign busy       = !(state==idle);
assign state_done = state==done;
//generate clk_bps
baud_sel baud_sel(
     .clk    (clk    )
    ,.rst_n  (rst_n  )
    ,.clk_bps(clk_bps)
    ,.mosi   (mosi   )
);
//receive uart data to data_uf[7:0]
uart_rx uart_rx(
     .clk  (clk_bps  )
    ,.rst_n(rst_n    )
    ,.mosi (mosi     )
    ,.ok   (rok      )
    ,.data (data_uf  )
);
fifo fifo(
     .wclk (wclk      )
    ,.rclk (rclk      )
    ,.rst_n(rst_n     )
    ,.mosi (data_uf   )
    ,.miso (data_fu )
    ,.rdy  (rdy       )
);
uart_tx uart_tx(
     .rst_n(rst_n          )
    ,.clk  (clk_bps        )
    ,.start(start_tx       )
    ,.data (data_fu        )
    ,.miso (miso           )
    ,.busy (busy_tx        )
    ,.ok   (wok            )
);
endmodule
