module uart_tx(
    input      rst_n,
    input      clk,
    input      start,
    input[7:0] data,
    output     miso,
    output     busy,
    output reg ok
);
reg[7:0] tx_cnt,next_tx_cnt;
reg[2:0] state,next_state;
reg      tx,next_tx;
reg      next_ok;
reg[7:0] data_tmp,next_data_tmp;
assign miso = tx;
parameter idle      = 0;
parameter send_data = 1;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state    <= idle; 
        tx_cnt   <= 0;
        tx       <= 1;
        data_tmp <= 0;
        ok       <= 1'b0;
    end
    else begin
        state    <= next_state;
        tx_cnt   <= next_tx_cnt;
        tx       <= next_tx;
        data_tmp <= next_data_tmp;
        ok       <= next_ok;
    end
end
always@(*)begin
    next_state    = state;
    next_tx_cnt   = tx_cnt - |tx_cnt;
    next_tx       = tx;
    next_data_tmp = data_tmp;
    next_ok       = ok;
    case(state)
        idle:begin
            next_ok = 1'b0;
            if(start)begin
                next_state    = send_data;
                next_tx_cnt   = 8;
                next_tx       = 1'b0;
            end
        end
        send_data:begin
            if(|tx_cnt)begin
                next_tx    = data[8-tx_cnt];
            end
            else begin
                next_state = idle;
                next_ok    = 1'b1;
                next_tx    = 1'b1;
            end
        end
    endcase
end
assign busy = !(state == idle);
endmodule
