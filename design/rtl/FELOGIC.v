module FELOGIC(
    input           clk,
    input           rst_n,
    input           rok,
    input           fifo_done,
    input[7:0]      mosi,
    output reg[7:0] cmd,
    output reg[7:0] rx_cnt,
    output reg      busy
);
    reg[2:0] rx_flag;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            busy <= 1'b0;
        end
        else begin
            busy <= fifo_done;
        end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rx_cnt <= 0;
        end
        else if(rok&rx_flag==3'b001)begin
            rx_cnt <= {rx_cnt,mosi};
        end
        else if(rok&rx_flag==3'b010)begin
            rx_cnt <= {rx_cnt,mosi};
        end
        else if(rok&rx_flag==3'b000)begin
            rx_cnt <= 0;
        end
        //else if(rok)begin
        //    rx_cnt <= rx_cnt;
        //end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rx_flag <= 1;
        end
        else if(fifo_done)begin
            rx_flag <= 1;
        end
        else if(rok)begin
            rx_flag <= {rx_flag[1:0],1'b0};
        end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cmd <= 0;
        end
        else if(rok&rx_flag==3'b100)begin
            cmd <= mosi;
        end
        else if(rok&rx_flag==3'b000)begin
            cmd <= 0;
        end
    end
endmodule
