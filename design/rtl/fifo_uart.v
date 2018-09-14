module fifo_uart(
    input            clk,  //uart clock
    input            rst_n,
    input            start,
    input[7:0]       mosi,

    output reg[7:0]  miso,
    output reg       ok
);
parameter idle      = 0;
parameter send_num  = 1;
parameter send_data = 2;
reg[2:0] state,next_state;
reg[7:0]  next_miso;
reg       next_ok;
reg[15:0] cnt,next_cnt;
reg[7:0]  tmp,next_tmp;
reg       req,next_req;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= idle;
        cnt   <= 0;
        ok    <= 1'b0;
        tmp   <= 0;
        miso  <= 0;
        req   <= 0;
    end
    else begin
        state <= next_state;
        cnt   <= next_cnt;
        ok    <= next_ok;
        tmp   <= next_tmp;
        miso  <= next_miso;
        req   <= next_req;
    end
end
always@(*)begin
    next_state = state;
    next_cnt   = cnt - |cnt;
    next_tmp   = tmp;
    next_ok    = ok;
    next_miso  = miso;
    next_req   = req;
    case(state)
        idle:begin
            next_ok    = 1'b0;
            next_tmp   = 0;
            next_miso  = 0;
            if(start)begin
                next_state = send_num;
            end
        end
        send_num:begin
            next_req = 1'b1;
            next_tmp = mosi;
            if(req)begin
                next_state = send_data;
                next_cnt   = {tmp,mosi};
            end
        end
        send_data:begin
            if(|cnt)begin
                next_miso = mosi;
            end
            else if(mosi==8'hbb)begin
                next_ok    = 1'b1;
                next_req   = 1'b0;
                next_state = idle;
            end
        end
    endcase
end
endmodule
