module fifo_control(
    input       clk,  //50M
    input       rst_n,
    input       mosi,
    output      miso,
    output[7:0] miso_rx,
    input[7:0]  cmd,
    output      fifo_done,
    output      rok,
    output      clk_bps,
    input[15:0] rx_cnt,
    input       busy,
    output reg  sd_init,
    input       init_ok
);
wire wok;
wire fifo_rdy;
reg[7:0] state,next_state;
parameter idle       = 0,
          send_rx    = 1,
          send_tx    = 2,
          done       = 3,
          initial_sd = 4;
reg        start_rx,next_start_rx;
reg        start_tx,next_start_tx;
reg        en_fifo,next_en_fifo;
reg[15:0]  cnt,next_cnt;
reg        rclk,next_rclk;
reg        wclk,next_wclk;
reg        req,next_req;
reg        next_sd_init;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state    <= idle;
        start_rx <= 1'b0;
        start_tx <= 1'b0;
        en_fifo  <= 1'b0;
        cnt      <= 0;
        req      <= 1'b0;
        wclk     <= 1'b0;
        rclk     <= 1'b0;
        sd_init  <= 1'b0;
    end
    else begin
        state    <= next_state;
        start_rx <= next_start_rx;
        start_tx <= next_start_tx;
        en_fifo  <= next_en_fifo;
        cnt      <= next_cnt;
        req      <= next_req;
        wclk     <= next_wclk;
        rclk     <= next_rclk;
        sd_init  <= next_sd_init;
    end
end
//wire en = !req&rok;
reg en;
always@(*)begin
    next_state    = state;
    next_start_rx = start_rx;
    next_start_tx = start_tx;
    next_en_fifo  = 1'b0;
    next_cnt      = cnt;
    next_req      = req;
    next_wclk     = wclk;
    next_rclk     = rclk;
    en            = 1'b0;
    next_sd_init  = sd_init;
    case(state)
        idle:begin
            next_start_rx = 1'b1;
            if(cmd==8'h01)begin
                next_state    = send_rx;
                next_cnt      = rx_cnt;
            end
            else if(cmd==8'h02)begin
                next_state    = initial_sd;
                next_sd_init  = 1'b1;
            end
        end
        send_rx:begin
            next_req = rok;
            en       = !req&rok;
            next_cnt = en ? cnt - |cnt : cnt;
            if(en&(|cnt))begin
                next_wclk = 1'b1;
            end
            else if(rok&(~|cnt))begin
                next_state    = send_tx;
                next_wclk     = 1'b0;
                next_rclk     = 1'b1;
                next_start_tx = 1'b1;
            end
            else begin
                next_wclk = 1'b0;
            end
        end
        send_tx:begin
            next_req = wok;
            en       = !req&wok;
            if(fifo_rdy&en)begin
                next_rclk  = 1'b0;
                next_state = done;
            end
            else if(en)begin
                next_rclk = 1'b1;
            end
            else begin
                next_rclk = 1'b0;
            end
        end
        initial_sd:begin
            if(init_ok)begin
                next_state = done;
            end
        end
        done:begin
            next_start_tx = 1'b0;
            if(busy)begin
                next_state   = idle;
            end
        end
    endcase
end
assign fifo_done =  state == done;
fifo_top fifo_top(
     .clk       (clk       )
    ,.rst_n     (rst_n     )
    ,.mosi      (mosi      )
    ,.miso      (miso      )
    ,.en_fifo   (en_fifo   )
    ,.mode      (0         )//TODO
    ,.mosi_data (0         )//TODO
    ,.miso_data (0         )//TODO
    ,.start_tx  (start_tx  )
    ,.start_rx  (start_rx  )
    ,.miso_rx   (miso_rx   )
    ,.fifo_rdy  (fifo_rdy  )
    ,.rok       (rok       )
    ,.wok       (wok       )
    ,.clk_bps   (clk_bps   )
    ,.wclk      (wclk      )
    ,.rclk      (rclk      )

);
endmodule
