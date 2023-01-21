`timescale 1ns/1ns
module Controller(
	//INPUTS
	clk,reset,Z, C, N, V,lt,gt,Z_out,IR_O,
	//OUTPUTS
	Mem_read , Mem_write, reg_write,PC_write,Jump,ldPCreg,IRwrite,
	IoD,PCreg,WAddr,DT_store,ALUsrcA,PCsrc,ALUoperation,ALUsrcB,writeMux);

	input clk,reset,Z, C, N, V,lt,gt,Z_out;
	input [31:0] IR_O;

	output logic Mem_read , Mem_write, reg_write,PC_write,Jump,ldPCreg,IRwrite,
	IoD,PCreg,WAddr,ALUsrcA,PCsrc;
	output logic DT_store;
	output logic [3:0] ALUoperation;
	output logic [1:0] ALUsrcB;
	output logic [1:0] writeMux;

	//ALU Control Unit
	logic [1:0] ALUop;
	wire [5:0] func;
	assign func = IR_O[22:20];
	ALU_control ALU_CU(func ,ALUop , ALUoperation);

	//States
	parameter [3:0] IF = 4'b0000;
	parameter [3:0] Getting_Started = 4'b0001;
	parameter [3:0] ID = 4'b010;

	parameter [3:0] Data_Processing = 4'b0011;
	parameter [3:0] Data_Processing_1 = 4'b0100;
	parameter [3:0] Data_Processing_2 = 4'b0101;
	parameter [3:0] Data_Processing_3 = 4'b0110;
	parameter [3:0] Data_Processing_4 = 4'b0111;
	parameter [3:0] Data_Processing_5 = 4'b1000;

	parameter [3:0] Branch = 4'b1001;
	parameter [3:0] Branch_1 = 4'b1010;

	parameter [3:0] DataTransfer = 4'b1011;
	parameter [3:0] DataTransfer_1 = 4'b1100;
	parameter [3:0] DataTransfer_2 = 4'b1101;

	wire [1:0] C;
	assign C = IR_O[31:30];
	wire [2:0] Type;
	assign Type = IR_O[29:27];
	wire L;
	assign L = IR_O[20];

	wire [2:0] opc;
	assign opc = IR_O[22:20];

	wire I;
	assign I = IR_O[23];


	//C
	parameter [1:0] EQ = 2'b00;
	parameter [1:0] GT = 2'b01;
	parameter [1:0] LT = 2'b10;
	parameter [1:0] AL = 2'b11;

	// Huffman Model
	reg [3:0] ps;
	reg [3:0] ns;
	always @(posedge clk, posedge reset) begin
		if (reset)
			ps <= IF;
		else
			ps <= ns;
	end

	always @(ps)
	begin
		case(ps)
			IF: ns = Getting_Started;
			Getting_Started: begin
				if((C == EQ && Z) || (C ==AL) || (C == GT && gt) || (C == LT && lt))
					ns = ID;
				else
					ns = IF;
			end
			ID: begin 
				if(Type == 3'b000)
					ns = Data_Processing;
				else if(Type == 3'b010)
					ns = DataTransfer;
				else if(Type == 3'b101)
					ns = Branch;
				else
					ns = IF;
			end
			/* Data Transfer States */
			DataTransfer: begin
				ns = L ? DataTransfer_1 : DataTransfer_2;
			end

			DataTransfer_1: begin
				ns = L ? DataTransfer_1 : DataTransfer_2;
			end

			DataTransfer_1: begin
				ns = IF;
			end

			DataTransfer_2: begin
				ns = IF;
			end

			/* Branch States */
			Branch: begin
				ns = L ? Branch_1 : IF;
			end

			Branch_1: begin
				ns = IF;
			end

			/* Data Processing States */
			Data_Processing: begin
				if(opc == 3'b000)
					ns = Data_Processing_1;
				else if(Type == 3'b111)
					ns = Data_Processing_2;
				else if(Type == 3'b101 || Type == 3'b110) 
					ns = Data_Processing_3;
				else
					ns = Data_Processing_4;
			end

			Data_Processing_1: begin
				ns = IF;
			end

			Data_Processing_2: begin
				ns = IF;
			end

			Data_Processing_3: begin
				ns = IF;
			end

			Data_Processing_4: begin
				ns = Data_Processing_5;
			end

			Data_Processing_5: begin
				ns = IF;
			end
		endcase
	end

	always @(ps)
	begin
		{Mem_read , Mem_write, reg_write,PC_write,Jump,ldPCreg,IRwrite,
		IoD,PCreg,WAddr,DT_store,ALUsrcA,PCsrc} = 13'b0;
		ALUoperation = 4'b0;
		ALUsrcB = 2'b0;
		writeMux = 2'b0;

		case (ps)
			IF: begin
				Mem_read = 1'b1;
				ALUsrcA = 1'b0;
				IoD = 1'b0;
				IRwrite = 1'b1;
				ALUsrcB = 2'b01;
				ALUop = 2'b01;
				PC_write = 1'b1;
				PCsrc = 1'b0;
				ldPCreg = 1'b1;
				PCreg = 1'b0;
			end

			ID: begin
				ALUsrcA = 1'b0;
				ALUsrcB = 1'b11;
				ALUop = 2'b00;
				DT_store = IR_O[28];
			end

			Branch: begin
				PCsrc = 1'b1;
				PCreg = 1'b0;
				Jump = 1'b1;
			end

			Branch_1: begin
				reg_write = 1'b1;
				writeMux = 1'b11;
				Jump = 1'b1;
				WAddr = 1'b1;
			end

			DataTransfer: begin
				ALUsrcA = 1'b1;
				ALUsrcB = 1'b11;
				ALUop = 2'b00;
			end

			DataTransfer_1: begin
				reg_write = 1'b1;
				WAddr = 1'b0;
			end

			DataTransfer_2: begin
				Mem_write = 1'b1;
				IoD = 1'b1;
			end

			Data_Processing: begin
				ALUop = 2'b00;
				ALUsrcA = 1'b1;
				ALUsrcB = I ? 10 : 00;
			end
			Data_Processing_1: begin
				reg_write = 1'b1;
				writeMux = 2'b01;
			end

			Data_Processing_2: begin
				WAddr = 1'b0;
				writeMux = 2'b10;
			end

			Data_Processing_3: begin
				ALUsrcA = 2'b1;
				ALUsrcB = I ? 10 : 00;
				ALUop = (opc == 3'b101) ? 11 : 10;
			end

			Data_Processing_4: begin
				ALUop = 2'b01;
				ALUsrcA = 1'b1;
				ALUsrcB = I ? 10 : 00;
			end

			Data_Processing_5: begin
				writeMux = 2'b01;
				WAddr = 2'b00;
			end
		endcase
	end
endmodule