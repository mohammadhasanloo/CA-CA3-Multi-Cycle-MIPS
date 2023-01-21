`timescale 1ns/1ns
module TB();
	reg clk = 0;
	reg rst = 0;


	MIPS mips(clk, rst);

	initial begin
		forever #20 clk = ~clk;
	end

	initial begin
		clk = 0;
		rst = 0;
		#220
		rst = 1;
		#110
		rst =0;
		#50000
		$stop;
	end

endmodule

