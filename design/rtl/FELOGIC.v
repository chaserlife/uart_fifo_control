module FELOGIC(
    input             clk,
    input             rst_n,
    input             rok,
    input             fifo_done,
    input[7:0]        mosi,
    output reg[7:0]   cmd,
    output reg[15:0]  rx_cnt,
    output            fe_done,
    input             fifo_busy,
    output reg[31:0]  sec,
    output reg        en_fc
);
    reg[6:0] rx_flag;
    reg      busy,busy_sync,busy_sync1;
    reg      cmd_05;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            busy       <= 1'b0;
            busy_sync  <= 1'b0;
            busy_sync1 <= 1'b0;
        end
        
        else begin
            busy       <= fifo_done;
            busy_sync  <= busy;
            busy_sync1 <= busy_sync;
        end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            en_fc <= 1'b0;
        end
        else if(rok&rx_flag[2])begin
            en_fc <= 1'b1;
        end
        else if(rok&rx_flag[3])begin
            en_fc <= 1'b0;
        end
    end
    assign fe_done = !busy_sync1&busy_sync;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rx_cnt <= 0;
        end
        else if(rok&(|rx_flag[1:0]))begin
            rx_cnt <= {rx_cnt[7:0],mosi};
        end
        else if(rok&rx_flag[2:0]==3'b000)begin
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
        else if(rok&rx_flag[2]&mosi==8'h03)begin
            rx_flag <= 1'b1;
        end
        else if(rok&cmd_05&rx_flag[6])begin
            rx_flag <= 1'b1;
        end
        else if(rok)begin
            //rx_flag <= {rx_flag[1:0],1'b0};
            rx_flag <= rx_flag << 1;
        end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cmd <= 0;
        end
        else if(rok&rx_flag[2])begin
            cmd <= mosi;
        end
        //else if(fifo_busy)begin
        //    cmd <= 0;
        //end
        //else if(rok&rx_flag[2:0]==3'b000)begin
        //    cmd <= 0;
        //end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cmd_05 <= 1'b0;
        end
        else if(rok&rx_flag[2]&mosi==8'h05)begin
            cmd_05 <= 1'b1;
        end
        else if(rok&rx_flag[0])begin
            cmd_05 <= 0;
        end
    end
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sec <= 0;
        end
        else if(cmd_05&rok)begin
            sec <= |rx_flag[6:3] ? {sec[23:0],mosi} : sec;
        end
    end
 //1:cnt[7:0]
 //2:cnt[15:8]
 //3:cmd[7:0]]
 //4:sec[7:0]
 //5:sec[15:8]
 //6:sec[23:16]
 //7:sec[31:24]
endmodule
