`define NUM 7


`define CMD01 8'h01//output tx
`define CMD0   {8'h40,8'h00,8'h00,8'h00,8'h00,8'h95}  //CMD0,CRC 95
`define CMD8   {8'h48,8'h00,8'h00,8'h01,8'haa,8'h87}  //CMD8,CRC 87
`define CMD55  {8'h77,8'h00,8'h00,8'h00,8'h00,8'hff}  //CMD55,no need CRC
`define ACMD41 {8'h69,8'h40,8'h00,8'h00,8'h00,8'hff}  //CMD41,no need CRC
//`define CMD17  {8'h51,sec[31:24],sec[23:16],sec[15:8],sec[7:0],8'hff}//block read
`define CMD17  {8'h51,8'h0,8'h0,8'h0,8'h0,8'hff}//block read
`define CMD24  {8'h58,8'h0,8'h0,8'h0,8'h0,8'hff}//block write

`define DATA_R1_CMD0 {8'h01,8'hff,8'hff,8'hff,8'hff,8'hff};
`define DATA_R1_CMD5 {8'h00,8'hff,8'hff,8'hff,8'hff,8'hff};
//   {8'h01,8'hff,8'hff,8'hff,8'hff,8'hff}//[47:40]=8'h01

`define FCMD1 8'h01 //test uart,receive and send
`define FCMD2 8'h02 //init_sd
`define FCMD3 8'h03 //read_sd
`define FCMD4 8'h04 //write_sd
`define FCMD5 8'h05 //set sec address


//SD_STATE
`define idle        0
`define dummy       1
`define send_cmd8   2
`define send_cmd55  3
`define send_acmd41 4
`define send_cmd17  5
`define send_cmd24  6
`define rd_data     7
`define send_cmd0   8
`define wr_data     9
`define init_done   8'ha
`define rd_done     8'hb
`define wr_done     8'hc
