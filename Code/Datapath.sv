module Datapath(
	/*INPUTS*/
	clk,reset,Mem_read , Mem_write, reg_write,ALUoperation,PC_write,Jump,ldPCreg,IRwrite,
	IoD,PCreg,WAddr,DT_store,ALUsrcA,PCsrc,ALUsrcB,writeMux,
	/*OUTPUTS*/
	Z, C, N, V,lt,gt,Z_out,IR_O
);

	input clk,reset,PC_write,Jump;
	//Memory
	wire [31:0] Address, Write_data;
	input Mem_read , Mem_write;
	wire [31:0] Mem_read_value;
	Memory Mem(clk,Address,Write_data,Write_data,Mem_write,Mem_read_value);

	
	//ALU
	wire [31:0] In1 ,In2;
	input [3:0] ALUoperation;
	wire [31:0] ALU_Result;
	output Z, C, N, V;
	ALU_32bit ALU(In1 ,In2 ,ALUoperation ,ALU_Result, Z, C, N, V);

	//PC
	wire write_PC;
	assign write_PC = PC_write | Jump;
	logic [31:0] PC_In;
	logic [31:0] PC_out;
	PC pc(clk , reset, write_PC ,PC_In , PC_out);

	//IR
	input IRwrite;
	wire [31:0] IR_in;
	assign IR_in = Mem_read_value;
	wire [31:0] IR_out;
	Reg_Write_Signal IR(clk, rst, IRwrite, IR_in, IR_out);

	//Register File
	input reg_write;
	wire [4:0] Read_reg1 , Read_reg2 , write_reg;
	assign Read_reg1 = IR_out[19:16];
	wire [31:0] write_data;
	wire [31:0] Read_data1 ,Read_data2;
	Register_file RF(clk, reset , Read_reg1 , Read_reg2 , write_reg ,  write_data , reg_write , Read_data1 ,Read_data2);

	//Sign Extend 12 bit
	wire [11:0] sign_extend12_in;
	assign sign_extend12_in = IR_out[11:0];
	wire [31:0] sign_extend12_out;
	Sign_extend_12 SE12 (sign_extend12_in , sign_extend12_out);

	//Sign Extend 26 bit
	wire [25:0] sign_extend26_in;
	assign sign_extend26_in = IR_out[25:0];
	wire [31:0] sign_extend26_out;
	Sign_extend_26 SE26 (sign_extend26_in , sign_extend26_out);


	/*********** Registers ***********/
	//Pre-PCreg
	input ldPCreg;
	wire [31:0] Pre_PCreg_in;
	assign Pre_PCreg_in = PC_out;
	wire [31:0] Pre_PCreg_out;
	Reg_Write_Signal PrePCreg(clk, rst, ldPCreg, Pre_PCreg_in, PrePCreg_out);


	//MDR
	wire [31:0] MDR_in;
	assign MDR_in = Mem_read_value;
	wire [31:0] MDR_out;
	REG MDR(clk, rst, MDR_in, MDR_out);

	//OP2Reg
	wire [31:0] OP2REG_in;
	assign OP2REG_in = sign_extend12_out;
	wire [31:0] OP2REG_out;
	REG OP2Reg(clk, rst, OP2REG_in, OP2REG_out);

	//A reg
	wire [31:0] A_in;
	assign A_in = Read_data1;
	wire [31:0] A_out;
	REG A(clk, rst, A_in, A_out);

	//B reg
	wire [31:0] B_in;
	assign B_in = Read_data2;
	wire [31:0] B_out;
	REG B(clk, rst, B_in, B_out);

	//ALU Output
	wire [31:0] ALU_in;
	assign ALU_in = ALU_Result;
	wire [31:0] ALU_out;
	REG ALU_REG(clk, rst, ALU_in, ALU_out);

	/*********** Mux ***********/
	input IoD;
	Mux2to1_32bit Memory_MUX ( PC_out, ALU_out ,IoD , Address);

	input PCreg;
	wire [31:0] PCreg_out_mux;
	Mux2to1_32bit PC_reg_MUX ( PC_out, Pre_PCreg_out ,PCreg , PCreg_out_mux);

	input WAddr;
	Mux2to1_4bit WAddr_MUX (IR_out[15:12] , 5'b1111 ,WAddr , write_reg);

	input DT_store;
	Mux2to1_4bit DT_STORE_MUX (IR_out[15:12] , IR_out[15:12] ,DT_store , Read_reg2);

	input ALUsrcA;
	Mux2to1_4bit ALU_SRC_A_MUX (PCreg_out_mux , A_out ,ALUsrcA , In1);

	input PCsrc;
	Mux2to1_4bit PC_SRC_MUX (ALU_Result , ALU_out ,PCsrc , PC_In);


	input [1:0] ALUsrcB;
	Mux4to1_32bit ALU_SRC_B_MUX (B_out , {{31{1'b0}},1'b1}, OP2Reg, sign_extend26_out ,ALUsrcB , In2);


	input [1:0] writeMux;
	Mux3to1_32bit write_MUX (MDR_out ,ALU_out, PC_out ,writeMux , write_data);

	output lt;
	assign lt = (V  && ~C) | (~V  && C);
	output gt;
	assign gt = ((~V  && ~C) | (V  && N)) && ~Z;
	output Z_out;
	assign Z_out = Z;

	output IR_O;
	assign IR_O = IR_out;
	// //Output Signal from ALU
	// //V
	// wire [31:0] V_in;
	// wire [31:0] V_out;
	// REG V(clk, rst, V_in, V_out);
	// //C
	// wire [31:0] C_in;
	// wire [31:0] C_out;
	// REG C(clk, rst, C_in, C_out);
	// //Z
	// wire [31:0] Z_in;
	// wire [31:0] Z_out;
	// REG Z(clk, rst, Z_in, Z_out);
	// //N
	// wire [31:0] N_in;
	// wire [31:0] N_out;
	// REG N(clk, rst, N_in, N_out);


endmodule