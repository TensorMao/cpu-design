`ifndef __ALU_SV
`define __ALU_SV
`ifdef VERILATOR

`else

`endif


module alu(
  input  [63:0] A,
  input  [63:0] B,
  input  [2:0] ALU_C,
  output logic [63:0] data_out
  );

  always_comb begin
    case (ALU_C)
      3'b000: data_out = A + B;
      3'b001: data_out = A - B;
      3'b010: data_out = A & B;
      3'b011: data_out = A | B;
      3'b100: data_out = A ^ B;
      default: data_out = 64'd0;
    endcase
  end

endmodule

`endif