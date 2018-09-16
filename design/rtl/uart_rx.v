module uart_rx(
    input           rst_n,
    input           mosi,
    input           start_rx,
    input           clk,
    output          ok,
    output reg[7:0] data
);
reg[4:0] cnt,next_cnt;
reg      rx_ok,next_rx_ok;
reg[7:0] next_data;
reg[3:0] state,next_state;
reg[7:0] rx,next_rx;
assign ok  = rx_ok;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= 0;
        cnt   <= 0;
        rx    <= 0;
        rx_ok <= 0;
        data  <= 0;
    end
    else begin
        state <= next_state;
        rx_ok <= next_rx_ok;
        cnt   <= next_cnt;
        rx    <= next_rx;
        data  <= next_data;
    end
end
parameter idle     = 0;
parameter rec_data = 1;
parameter done     = 2;
parameter wait_dmy = 3;
always@(*)begin
    next_state = state;
    next_rx_ok = rx_ok;
    next_rx    = rx;
    next_data  = data;
    next_cnt   = cnt - |cnt;
    case(state)
        idle:begin
            next_rx_ok = 1'b0;
            if(start_rx&!mosi)begin
                next_state = rec_data;
                next_cnt   = 8;
            end
        end
        rec_data:begin
            if(|cnt)begin
                next_rx = {mosi,rx[7:1]};
            end
            else if(mosi)begin
                next_rx_ok = 1'b1;
                next_data  = rx;
                next_state = idle;
            end
            else begin//overtime
                next_rx_ok = 1'b0;
                next_state = wait_dmy;
                next_cnt   = 8;
            end
        end
        wait_dmy:begin
            if(|cnt) next_state = idle;
        end        
    endcase
end
endmodule
