`ifndef __BR_SV
`define __BR_SV
`ifdef VERILATOR

`else

`endif
module br(
    input BRsel,
    input [63:0]A,
    input [63:0] pc,
    input [63:0] sext_num,
    output logic [63:0] br_out
);
  
      assign  br_out =BRsel? ({{(A + sext_num)}[63:1], 1'b0}):(pc + sext_num);
    

  
endmodule
`endif