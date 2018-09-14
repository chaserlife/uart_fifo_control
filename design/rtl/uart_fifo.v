module uart_fifo(
    input           clk,   //uart clock
    input           rst_n,
    input           start,
    input[7:0]      mosi,

    output reg[7:0] miso,
    output          busy
);
reg[3:0] state,next_state;
reg[15:0] cnt,next_cnt;
reg[7:0]  tmp,next_tmp;
parameter idle     = 0;
parameter rec_num  = 1;
parameter rec_data = 2;
reg       req,next_req;
reg[7:0]  next_miso;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state    <= idle;
        cnt      <= 0;
        tmp      <= 0;
        req      <= 1'b0;
        miso     <= 0;
    end
    else begin
        state    <= next_state;
        cnt      <= next_cnt;
        tmp      <= next_tmp;
        req      <= next_req;
        miso     <= next_miso;
    end
end
always@(*)begin
    next_cnt      = cnt -|cnt;
    next_state    = state;
    next_req      = req;
    next_tmp      = tmp;
    next_miso     = miso;
    case(state)
        idle:begin
            next_cnt  = 0;
            next_req  = 1'b0;
            next_miso = 0;
            if(start&mosi==8'haa)begin
                next_state <= rec_num;
            end
        end
        rec_num:begin
            next_req      = 1'b1;
            if(req)begin
                next_tmp      = mosi;
                next_state = rec_data;
                next_cnt   = {tmp,mosi};
            end
        end
        rec_data:begin
            if(|cnt)begin
                next_miso  = mosi;
            end
            else if(mosi==8'hbb)begin
                next_req   = 1'b0;
                next_state = idle;
            end            
        end
    endcase
end
assign busy = !(state==idle);
endmodule
