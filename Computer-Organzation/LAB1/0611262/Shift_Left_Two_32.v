//Subject:      CO project 1 - Shift_Left_Two_32
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0611262 曾長彥
//----------------------------------------------
//Date:        2018/07/14
//Description:
//--------------------------------------------------------------------------------

module Shift_Left_Two_32(
    data_i,
    data_o
    );

//I/O ports
input [32-1:0] data_i;
output [32-1:0] data_o;

//shift left 2
assign data_o = data_i << 2;
endmodule
