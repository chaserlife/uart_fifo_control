module uart_top(
    input   rst_n,
    input   clk,
    output  miso,
    input   mosi
);
    wire[7:0] data;
    uart_rx uart_rx(//slave rx
                     .mosi   (mosi   )
                    ,.rst_n  (rst_n  )
                    ,.clk    (clk_bps)
                    ,.ok     (rx_ok  )
                    ,.data   (data   )
                   );
    uart_tx uart_tx(//slave tx
                     .miso (miso   )
                    ,.rst_n(rst_n  )
                    ,.clk  (clk_bps)
                    ,.start(rx_ok  )
                    ,.data (data   )
                   );
    baud_sel baud_sel( .clk    (clk    )
                      ,.rst_n  (rst_n  )
                      ,.clk_bps(clk_bps)
                      ,.mosi   (mosi   )
                     );
endmodule
