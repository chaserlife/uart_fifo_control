`define NUM 7


`define CMD01 8'h01//output tx
`define CMD0   {8'h40,8'h00,8'h00,8'h00,8'h00,8'h95}  //CMD0,CRC 95
`define CMD8   {8'h48,8'h00,8'h00,8'h01,8'haa,8'h87}  //CMD8,CRC 87

`define DATA_R1_CMD0 8'h01
//   {8'h01,8'hff,8'hff,8'hff,8'hff,8'hff}//[47:40]=8'h01
