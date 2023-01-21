module REG(input clk, rst, input [31:0] dataIn, output reg [31:0] DataOut);
	always@(posedge clk, posedge rst) begin
		if(rst)
			DataOut <= 32'b0;
		else if(clk)
			DataOut <= dataIn;
	end
endmodule