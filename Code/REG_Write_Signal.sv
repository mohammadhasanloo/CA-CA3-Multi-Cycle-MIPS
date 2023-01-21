module Reg_Write_Signal(input clk, rst, input Write, input [31:0] dataIn, output reg [31:0] DataOut);
	always@(posedge clk, posedge rst) begin
		if(rst)
			DataOut <= 32'b0;
		else
			if(Write)
				DataOut <= dataIn;
			else
				DataOut <= DataOut;
	end
endmodule