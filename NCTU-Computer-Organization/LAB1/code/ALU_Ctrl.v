//Subject:     CO project 1 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:
//----------------------------------------------
//Date:
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );

//I/O ports
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;

//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter


//Select exact operation

always @(*) begin
  case (ALUOp_i)
    3'b000:
      case (funct_i)
        6'b100_001: ALUCtrl_o <= 4'b0010;  //addu
        6'b100_011: ALUCtrl_o <= 4'b0110;  //subu
        6'b100_100: ALUCtrl_o <= 4'b0000;  //add
        6'b100_101: ALUCtrl_o <= 4'b0001;  //or
        6'b101_010: ALUCtrl_o <= 4'b0111;  //slt
      endcase
    3'b001: ALUCtrl_o <= 4'b0010;  //addi
    3'b010: ALUCtrl_o <= 4'b0111;  //sltiu
    3'b011: ALUCtrl_o <= 4'b0110;  //beg
  endcase
end

endmodule
