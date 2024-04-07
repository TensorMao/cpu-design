`ifndef __ALU_SV
`define __ALU_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif


module alu(
  input  [63:0] A,
  input  [63:0] B,
  input  [`ALUOP_WIDTH-1:0] ALUop,
  output logic [63:0] data
  );

  always_comb begin
    case (ALUop)
      0: data = A + B;
      1: data = A - B;
      2: data = A & B;
      3: data = A | B;
      4: data = A ^ B;
      5: data = {63'b0,$signed(A) < $signed(B)};
      6: data = {63'b0,$unsigned(A) < $unsigned(B)};
      7: data = A << B[5:0];
      8: data = A >> B[5:0];
      9: data = $signed(A) >>> B[5:0];
      10:data = {{32{{A+B}[31]}},{A+B}[31:0]};
      11:data = {{32{{A-B}[31]}},{A-B}[31:0]};
      12:data = {{32{{A<<B[4:0]}[31]}},{A<<B[4:0]}[31:0]};
      13:data = {{32{{A[31:0]>>B[4:0]}[31]}},{A[31:0]>>B[4:0]}[31:0]};
      14:data = {{32{{$signed(A[31:0])>>>B[4:0]}[31]}},{$signed(A[31:0])>>>B[4:0]}[31:0]};
      20:data = B;
      21:data = B+4;
      default: data = 0;
    endcase    
  end

endmodule

`endif