module Sign_extend_12 (input [11:0] In , output [31:0] Out);
	assign Out = {{20{In[11]}}, In};
endmodule

module Sign_extend_26 (input [25:0] In , output [31:0] Out);
	assign Out = {{7{In[25]}}, In};
endmodule