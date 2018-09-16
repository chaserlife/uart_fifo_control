module sd_top(
    input      rst_n,
    input      clk,
    input      sd_miso,

    output     sd_ck,
    output     sd_mosi,
    output     sd_csn,
    output     init_ok,
    input      sd_init
);
//25M clock,MAIN clock 50M
reg  sd_clk;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sd_clk <= 1'b0;
    end
    else begin
        sd_clk <= ~sd_clk;
    end
end
reg  sd_clk1;
always@(posedge sd_clk or negedge rst_n)begin
    if(!rst_n)begin
        sd_clk1 <= 1'b0;
    end
    else begin
        sd_clk1 <= ~sd_clk1;
    end
end
reg  sd_clk2;
always@(posedge sd_clk1 or negedge rst_n)begin
    if(!rst_n)begin
        sd_clk2 <= 1'b0;
    end
    else begin
        sd_clk2 <= ~sd_clk2;
    end
end
reg  sd_clk3;
always@(posedge sd_clk2 or negedge rst_n)begin
    if(!rst_n)begin
        sd_clk3 <= 1'b0;
    end
    else begin
        sd_clk3 <= ~sd_clk3;
    end
end
sd_initial sd_initial(
     .rst_n     (rst_n        )
    ,.sd_ck     (sd_ck        )
    ,.sd_init   (sd_init      )
    ,.sd_miso   (sd_miso      )

    ,.sd_csn    (sd_csn_init  )
    ,.sd_mosi   (sd_mosi_init )
    ,.init_ok   (init_ok      )
    //.state     (),
    //.rx        ()
);
//sd_read sd_read(
//     .rst_n      (rst_n         )
//    ,.sd_miso    (sd_miso       )
//    ,.sd_ck     (sd_ck          )
//    ,.sd_mosi    (sd_mosi_read  )
//    ,.sd_csn     (sd_csn_read   )
//    ,.init_o     (init_o        )
//    ,.read_seq   (1'b1          )//TODO read_seq
//    ,.ok         (read_ok     )
//);
//sd_write sd_write(
//     .rst_n      (rst_n         )
//    ,.sd_miso    (sd_miso       )
//    ,.sd_ck     (sd_ck          )
//    ,.sd_mosi    (sd_mosi_write )
//    ,.sd_csn     (sd_csn_write  )
//    ,.init_o     (init_o        )
//    ,.write_seq  (read_ok       )//TODO read_seq
//    ,.ok         (write_ok      )
//);
assign sd_mosi = sd_mosi_init;//&sd_mosi_read&sd_mosi_write;
assign sd_csn  = sd_csn_init ;//&sd_csn_read &sd_csn_write;
assign sd_ck   = sd_clk3;
endmodule
