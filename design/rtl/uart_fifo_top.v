module uart_fifo_top(
    input       ren,
    input       wen,
    input       clk,
    input       rst_n,
    input[7:0]  mosi,
    output[7:0] miso,
    output      wok,
    output      rok,
    output      rdy //
    );
    uart_fifo(
         .clk  (wclk           )
        ,.rst_n(rst_n          )
        ,.start(1'b1           )//TODO
        ,.mosi (mosi           )
        ,.miso (mosi_uart_fifo )
        ,.ok   (wok            )
    );
    fifo_uart(
         .clk  (rclk           )
        ,.rst_n(rst_n          )
        ,.start(wok            )//TODO
        ,.mosi (miso_fifo_uart )
        ,.miso (miso           )
        ,.ok   (rok            )
    );
    fifo fifo(
         .wclk (wclk          )
        ,.rclk (rclk          )
        ,.rst_n(rst_n         )
        ,.miso (miso_fifo_uart)
        ,.mosi (mosi_uart_fifo)
        ,.rdy  (rdy           )
    );
endmodule
