module BELOGIC(
    input cmd,

);
assign start_ufu = cmd==8'h01;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= 0;
    end
    else begin
        state <= nex_state;
    end
end

always@(*)begin
    next_state = state;
    case(state)
        idle:begin
            if(cmd==8'h01)begin
                next_state = send_from_fifo;
            end
        end
        send_from_fifo:begin
            if(ufu_done)begin
                next_state = idle;
            end
        end
    endcase
end
endmodule
