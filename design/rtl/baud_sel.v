module baud_sel(
    input      clk,
    input      rst_n,
    output reg clk_bps,
    input      mosi,
    input[2:0] mode
);
reg[12:0] cnt;
reg[7:0]  rx;
wire[12:0] cmp;
parameter bps9600=5208/2;
assign cmp = mode==0 ? bps9600 : 0;
      
wire RSTn;
always@(posedge clk or negedge RSTn)begin
    if(!RSTn)begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt < cmp ? cnt + 1 : 0;
    end
end
always@(posedge clk or negedge RSTn)begin
    if(!RSTn)begin
        clk_bps = 1'b0;
    end
    else begin
        clk_bps = cnt==cmp ? ~clk_bps : clk_bps;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rx[7:0] <= 8'hff;     
    end
    else begin
        rx[7:0] <= {rx[6:0],mosi};
    end
end
assign RSTn = !rst_n                 ? 1'b0 :
              (|rx[7:4])&(~|rx[3:0]) ? 1'b0 : 1'b1;//reset clock,generate stable clk_bps
endmodule
