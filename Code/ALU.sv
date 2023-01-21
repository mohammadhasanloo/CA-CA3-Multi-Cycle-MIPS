module ALU_32bit( input [31:0] In1 ,In2 , input [3:0] ALU_Sel ,output [31:0] Out, output Z, C, N, V);
  
  reg [31:0] ALU_Result;
  reg temp_zero,Carry;

  always @(*)
  begin
      case(ALU_Sel)
        4'b0000: // add - addi - sw - ld
         {Carry,ALU_Result} = In1 + In2; 
         
        4'b0001: // sub
         {Carry,ALU_Result} = In1 + ~In2 + 1;


        4'b0010: // RSB
         {Carry,ALU_Result} = In1 + ~In2 + 1;
         
        4'b0011: // and
         temp_zero = In1 && In2 ;
         
        4'b0100: // not
         temp_zero =  ~In2;
        default: ALU_Result = 32'bx ; 
      endcase
  end

  assign Out = ALU_Result;
  //Flags
  assign Z = temp_zero;
  assign C = Carry;
  assign N = ALU_Result[31] ? 1 : 0;
  assign V = (In1[31]^In2[31]) ? 0: (ALU_Result[31]^In1[31]);

endmodule