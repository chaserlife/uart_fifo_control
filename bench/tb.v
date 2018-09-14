`timescale 1ns/100ps
module tb;
reg mosi=1;
reg clk;
reg rst_n;
top top(
     .rst_n(rst_n)
    ,.clk  (clk  )
    ,.mosi (mosi )
);
initial begin
    #40ms $display("ERROR:overtime");$finish;
end
initial begin
    clk = 1'b0;
    forever begin
        #10 clk = ~clk;
    end
end
initial begin
    `include "stimulus.v"
end
task tx_pc(input[7:0] data);
    mosi = 1'b0;
    #104us;
    for(int i=0;i<8;i++)begin
        mosi = data[i];
        #104us;
    end
    mosi = 1'b1;
    #104us;
endtask
endmodule
