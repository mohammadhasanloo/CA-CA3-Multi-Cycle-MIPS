module ALU_control(input [2:0] func , input [1:0] ALUop , output reg [3:0] ALUoperation);  
	always @ (*)
	begin 
	  case(ALUop)
	    2'b00: ALUoperation = 4'b0000; //add

	    2'b01: case(func)
			0: ALUoperation = 4'b0000; //add
			1: ALUoperation = 4'b0001; //sub
			2: ALUoperation = 4'b0010; //RSB
			3: ALUoperation = 4'b0011; //and
			4: ALUoperation = 4'b0100; //not
	    endcase
	    2'b10: ALUoperation = 4'b0001; //sub
	    2'b11: ALUoperation = 4'b0110; //AND
	    endcase
	end
endmodule