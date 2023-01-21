`timescale 1ns/1ns
module MIPS(input clk,reset);
	wire Mem_read , Mem_write, reg_write,PC_write,Jump,ldPCreg,IRwrite,
	IoD,PCreg,WAddr,ALUsrcA,PCsrc,DT_store;
	wire [3:0] ALUoperation;
	wire [1:0] ALUsrcB;
	wire [1:0] writeMux;

	wire Z, C, N, V,lt,gt,Z_out;
	wire [31:0] IR_O;

	//Datapath module
	Datapath DP(
		/* INPUT */
		clk,reset,Mem_read , Mem_write, reg_write,ALUoperation,PC_write,Jump,ldPCreg,IRwrite,
		IoD,PCreg,WAddr,DT_store,ALUsrcA,PCsrc,ALUsrcB,writeMux,
		/*OUTPUTS*/
		Z, C, N, V,lt,gt,Z_out,IR_O
	);

	//Controller + ALU Controller
	Controller CU(
		//INPUTS
		clk,reset,Z, C, N, V,lt,gt,Z_out,IR_O,
		//OUTPUTS
		Mem_read , Mem_write, reg_write,PC_write,Jump,ldPCreg,IRwrite,
		IoD,PCreg,WAddr,DT_store,ALUsrcA,PCsrc,ALUoperation,ALUsrcB,writeMux
	);
endmodule
