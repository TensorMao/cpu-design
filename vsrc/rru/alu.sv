`ifndef __ALU_SV
`define __ALU_SV
`ifdef VERILATOR

`else

`endif


module alu(
  input  [63:0] A,
  input  [63:0] B,
  input  [3:0] ALU_C,
  output logic [63:0] data_out
  );

  always_comb begin
    case (ALU_C)
      0: data_out = A + B;
      1: data_out = A - B;
      2: data_out = A & B;
      3: data_out = A | B;
      4: data_out = A ^ B;
      5: data_out = {63'b0,$signed(A) < $signed(B)};
      6: data_out = {63'b0,$unsigned(A) < $unsigned(B)};
      7: data_out = A << B[5:0];
      8: data_out = A >> B[5:0];
      9: data_out = $signed(A) >>> B[5:0];
      default: data_out = 64'd0;
    endcase
  end

endmodule

`endif