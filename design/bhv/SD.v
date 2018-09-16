module SD(
    input      rst_n,
    input      SD_CLK,
    input      SD_IN,
    output     SD_OUT
    );
    reg       SD_OUT,next_SD_OUT;
    reg[9:0]  tx_cnt,next_tx_cnt;
    reg[5:0]  state,next_state;
    reg[5:0]  cmp,next_cmp;
    reg[47+48:0] data,next_data;
    parameter idle        = 0;
    parameter send_cmd0_r = 1;
    parameter send_wait   = 2;

parameter send_cmd0   =4'b0001, 
          send_r1     =4'b0010;
          //waitb       =4'b0011, 
          //send_cmd8   =4'b0100, 
          //waita       =4'b0101, 
          //send_cmd55  =4'b0110, 
          //send_acmd41 =4'b0111, 
          //init_done   =4'b1000, 
          //init_fail   =4'b1001, 
          //dummy       =4'b1010, 
          //wait_st     =4'b1011; 
reg[2:0] seq,next_seq;
wire[5:0] cmd0_r = tb.top.sd_top.sd_initial.state==1&tb.top.sd_top.sd_initial.tx_cnt==0;
//tb.DUT.init_o&tb.DUT.sd_read.read_seq&!tb.DUT.sd_read.ok    ? tb.DUT.sd_read.state :
//                    tb.DUT.init_o&tb.DUT.sd_write.write_seq&!tb.DUT.sd_write.ok ? tb.DUT.sd_write.state :
//                    tb.DUT.sd_initial.state;
reg[7:0]  cnt,next_cnt;
    always@(negedge SD_CLK or negedge rst_n)begin
        if(!rst_n)begin
            SD_OUT <= 1'b1;
            tx_cnt <= 0;
            state  <= idle;
            cmp    <= 0;
            data   <= 0;
            cnt    <= 0;
            seq    <= 0;
        end
        else begin
            SD_OUT <= next_SD_OUT;
            tx_cnt <= next_tx_cnt;
            state  <= next_state;
            cmp    <= next_cmp;
            data   <= next_data;
            cnt    <= next_cnt;
            seq    <= next_seq;
        end
    end
    always@(*)begin
        next_SD_OUT = SD_OUT;
        next_tx_cnt = tx_cnt - |tx_cnt;
        next_cmp    = cmp;
        next_data   = data;
        next_cnt    = cnt - |cnt;
        next_seq    = seq;
        case(state)
            idle:begin
                //if(!tb.DUT.init_o&state_r==4'b0010)begin
                //    next_state  = wait_st;
                //    next_tx_cnt = 48;
                //    next_data   = `DATA_R1_CMD0;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;
                //    next_cnt    = 8;
                //    next_seq    = 1;
                //end
                //else if(!tb.DUT.init_o&state_r==waita)begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = `DATA_R7_CMD8;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;
                //    next_seq    = 1;
                //end
                //else if(!tb.DUT.init_o&state_r==send_cmd55&(|tb.DUT.sd_initial.cnt))begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = `DATA_R1_CMD55;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 1;
                //end
                //else if(!tb.DUT.init_o&state_r==send_acmd41&(|tb.DUT.sd_initial.cnt))begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = `DATA_R1_ACMD41;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 1;
                //end
                //else if(!tb.DUT.sd_read.ok&tb.DUT.init_o&tb.DUT.sd_read.read_seq&state_r==tb.DUT.sd_read.read_cmd_resp)begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = `DATA_R1_CMD17;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 2;
                //end
                //else if(!tb.DUT.sd_read.ok&tb.DUT.init_o&tb.DUT.sd_read.read_seq&state_r==tb.DUT.sd_read.dummy)begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = {8'hfe,8'h00};
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 2;
                //end
                //else if(tb.DUT.init_o&tb.DUT.sd_write.write_seq&state_r==tb.DUT.sd_write.write_cmd)begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48+48;
                //    next_data   = {{48{1'b1}},{40{1'b1}},8'h00};
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 3;
                //end
                //else if(tb.DUT.init_o&tb.DUT.sd_write.write_seq&state_r==tb.DUT.sd_write.write_dummy)begin
                //    next_state  = send_cmd0_r;
                //    next_tx_cnt = 48;
                //    next_data   = 8'h00;
                //    next_cmp    = state_r;
                //    next_SD_OUT = 1;                  
                //    next_seq    = 3;
                //end
                if(cmd0_r)begin
                     next_data   = `DATA_R1_CMD0;
                     next_state  = send_r1;
                     next_tx_cnt = 8;
                end
                else begin
                    next_state = idle;
                    next_seq    = 0;
                end
            end
            send_r1:begin
                if(tx_cnt==1)begin
                    next_state  = idle;
                    next_SD_OUT = data[tx_cnt-1];
                end
                else begin
                    next_SD_OUT = data[tx_cnt-1];
                end
            end
            //wait_st:begin
            //    if(|cnt)begin
            //        next_state = wait_st;
            //    end
            //    else begin
            //        next_tx_cnt = 48;
            //        next_state  = send_cmd0_r;
            //    end
            //end
            //send_cmd0_r:begin
            //    if(|tx_cnt)begin
            //        next_SD_OUT = data[tx_cnt-1];
            //    end
            //    else begin
            //        next_SD_OUT = 1'b1;
            //        next_state  = send_wait;
            //    end
            //end
            //send_wait:begin
            //    if(seq==1&cmp!==state_r)begin
            //        next_state = idle;
            //        next_seq   = 0;
            //    end
            //    else if(seq==2&cmp!==state_r)begin
            //        next_state = idle;
            //        next_seq   = 0;
            //    end
            //    else if(seq==3&cmp!==state_r)begin
            //        next_state = idle;
            //        next_seq   = 0;
            //    end
            //end
        endcase
    end
endmodule
