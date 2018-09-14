module fifo(
    input           wclk,
    input           rclk,
    input           rst_n,
    input[7:0]      mosi,
    output reg[7:0] miso,
    output          rdy
);
//cmd01:write data to sd
//cmd02:read data form sd
//reg[7:0] ram[512:0];//depth
reg[512:0][7:0] ram;//depth
reg[9:0] wcnt;
always@(posedge wclk or negedge rst_n)begin
    if(!rst_n)begin
        wcnt <= 0;
    end
    else begin
        wcnt <= wcnt + 1;
    end
end
reg[9:0] rcnt;
always@(posedge rclk or negedge rst_n)begin
    if(!rst_n)begin
        rcnt <= 0;
    end
    else begin
        rcnt <= rcnt + 1;
    end
end
always@(posedge rclk)begin
    miso <= ram[rcnt];
end
always@(posedge wclk)begin
    ram[wcnt] <= mosi;
end
assign rdy = wcnt == rcnt;//full
endmodule
