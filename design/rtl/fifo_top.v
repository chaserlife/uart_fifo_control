//Autho:Lim
//date:20180915
//description
//
module fifo_top(
    input       clk,      //input clk,50M
    input       rst_n,    //power reset
    input       mosi,     //rx from pc
    output      miso,     //tx to pc
    input       en_fifo,  //    input[7:0]  mosi_data,//slave in data
    output      clk_bps,  //uart clock
    output      rok,      //rx 1 byte data
    output      wok,      //tx 1 byte data
    input[3:0]  mode,     //buad mode select
    input[7:0]  mosi_data,//slave fifo out
    input[7:0]  miso_data,//slave fifo out
    output[7:0] miso_rx,
    output      fifo_rdy,
    input       start_tx,
    input       start_rx,
    input       wclk,
    input       rclk
);
wire[7:0] miso_tx;
wire[7:0] miso_fifo;
wire[7:0] mosi_fifo;
assign mosi_fifo = en_fifo ? mosi_data : miso_rx;
assign miso_tx   = en_fifo ? miso_data : miso_fifo;
baud_sel baud_sel(
     .clk    (clk    )
    ,.rst_n  (rst_n  )
    ,.clk_bps(clk_bps)
    ,.mosi   (mosi   )
    ,.mode   (mode   )
);
//receive uart data to mosi_fifo[7:0]
uart_rx uart_rx(
     .clk      (clk_bps   )
    ,.rst_n    (rst_n     )
    ,.mosi     (mosi      )
    ,.ok       (rok       )
    ,.data     (miso_rx   )
    ,.start_rx (start_rx  )
);
fifo fifo(
     .wclk (wclk      )
    ,.rclk (rclk      )
    ,.rst_n(rst_n     )
    ,.mosi (mosi_fifo )
    ,.miso (miso_fifo )
    ,.rdy  (fifo_rdy  )
);
uart_tx uart_tx(
     .rst_n(rst_n          )
    ,.clk  (clk_bps        )
    ,.start(start_tx       )
    ,.data (miso_tx        )
    ,.miso (miso           )
    ,.ok   (wok            )
);

endmodule
