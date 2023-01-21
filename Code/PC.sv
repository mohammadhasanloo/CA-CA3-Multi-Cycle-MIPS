`timescale 1ns/1ns
module PC(input clk , reset, write_PC ,input [31:0] PC_In , output reg [31:0] PC_out);
	always @(posedge clk) begin
		if (reset)
			PC_out <=32'b0;
		else
			PC_out <= write_PC ? PC_In : PC_out;
	end
endmodule