module SD(
    input      rst_n,
    input      SD_CLK,
    input      SD_IN,
    output reg SD_OUT
    );
    reg       next_SD_OUT;
    reg[9:0]  tx_cnt,next_tx_cnt;
    reg[5:0]  state,next_state;
    reg[5:0]  cmp,next_cmp;
    reg[47+48:0] data,next_data;

parameter idle        =4'h0,
          send_cmd0   =4'h1, 
          send_r1     =4'h2,
          send_r2     =4'h3;
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
assign cmd0_r = tb.top.sd_initial.state==1&tb.top.sd_initial.tx_cnt==1|//cmd0    resp. 0x01
                tb.top.sd_initial.state==2&tb.top.sd_initial.tx_cnt==1|//cmd8
                tb.top.sd_initial.state==3&tb.top.sd_initial.tx_cnt==1;//cmd55
assign cmd5_r = tb.top.sd_initial.state==4&tb.top.sd_initial.tx_cnt==1|//acmd41 resp.0x00
                tb.top.sd_initial.state==5&tb.top.sd_initial.tx_cnt==1;//cmd17
assign cmd17_r = tb.top.sd_initial.state==6&tb.top.sd_initial.req==0;//read_resp. start 8'hfe
//tb.DUT.init_o&tb.DUT.sd_read.read_seq&!tb.DUT.sd_read.ok    ? tb.DUT.sd_read.state :
//                    tb.DUT.init_o&tb.DUT.sd_write.write_seq&!tb.DUT.sd_write.ok ? tb.DUT.sd_write.state :
//                    tb.DUT.sd_initial.state;
reg[10:0]  cnt,next_cnt;
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
        next_cnt    = cnt;
        next_cmp    = cmp;
        next_data   = data;
        next_seq    = seq;
        case(state)
            idle:begin
                if(cmd0_r)begin
                     next_data   = `DATA_R1_CMD0;
                     next_state  = send_r1;
                     next_tx_cnt = 48;
                end
                else if(cmd5_r)begin
                     next_data   = `DATA_R1_CMD5;
                     next_state  = send_r1;
                     next_tx_cnt = 48;
                end
                else if(cmd17_r)begin
                     next_data   = 8'hfe;
                     next_state  = send_r2;
                     next_tx_cnt = 8;
                end
                else begin
                    next_state = idle;
                    next_seq    = 0;
                end
            end
            send_r1:begin
                if(|tx_cnt)begin
                    next_SD_OUT = data[tx_cnt-1];
                end
                else begin
                    next_SD_OUT = 1'b1;
                    next_state  = idle;
                end
            end
            send_r2:begin
                if(tb.top.sd_initial.req==0)begin
                    next_SD_OUT = data[tx_cnt-1];
                    if(tx_cnt==0)begin
                        next_data    = $random;
                        next_SD_OUT = next_data[7];
                        next_tx_cnt  = 7;
                        next_cnt = 514;
                    end
                end
                else if(tb.top.sd_initial.req==1)begin
                     next_cnt = |tx_cnt ? cnt : cnt - |cnt;
                    if(tx_cnt==0)begin
                        if(cnt==2|cnt==1)begin
                           next_data = 8'hff;
                        end
                        else begin
                            next_data    = $random;
                        end
                        next_SD_OUT = next_data[7];
                        next_tx_cnt  = 7;
                    end
                    else begin
                        next_SD_OUT = data[tx_cnt-1];
                    end
                end
                else if(tb.top.sd_initial.req==2)begin
                    next_SD_OUT = 1'b1;
                    next_state  = idle;
                end
                //else begin
                //    next_SD_OUT = 1'b1;
                //    next_state  = idle;
                //end
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
