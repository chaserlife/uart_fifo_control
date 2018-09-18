module top(
    input  clk,
    input  rst_n,

    //uart
    input  mosi,
    output miso,

    //sd
    output sd_ck,
    output sd_mosi,
    output sd_csn,
    input  sd_miso
);
wire[7:0]  mosi_rx;
wire[7:0]  cmd;
wire[15:0] rx_cnt;
fifo_control fifo_control(
     .clk        (clk         )
    ,.rst_n      (rst_n       )
    ,.mosi       (mosi        )
    ,.miso       (miso        )
    ,.miso_rx    (mosi_rx     )
    ,.cmd        (cmd         )
    ,.fifo_done  (fifo_done   )
    ,.rok        (rok         )
    ,.clk_bps    (clk_bps     )
    ,.rx_cnt     (rx_cnt      )
    ,.sd_init    (sd_init     )
    ,.init_ok    (init_ok     )
    ,.fifo_busy  (fifo_busy   )
    ,.fe_done    (fe_done     )
    ,.sd_ren     (sd_ren      )
    ,.sd_read_ok (1'b0        )
);
FELOGIC FELOGIC(
     .rst_n    (rst_n    )
    ,.rok      (rok      )
    ,.fifo_done(fifo_done)
    ,.mosi     (mosi_rx  )
    ,.clk      (clk_bps  )
    ,.cmd      (cmd      )
    ,.rx_cnt   (rx_cnt   )
    ,.fe_done  (fe_done  )
    ,.fifo_done(fifo_done)
);
sd_initial sd_initial(
     .rst_n     (rst_n     )
    ,.clk       (clk       )
    ,.sd_ck     (sd_ck     )
    ,.sd_miso   (sd_miso   )
    ,.sd_mosi   (sd_mosi   )
    ,.sd_init   (sd_init   )
    ,.init_ok   (init_ok   )
    ,.sd_csn    (sd_csn    )
    ,.fifo_busy (fifo_busy )
    ,.sd_ren    (sd_ren    )
);
endmodule
