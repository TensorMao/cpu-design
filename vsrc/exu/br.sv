`ifndef __BR_SV
`define __BR_SV
`ifdef VERILATOR

`else

`endif
module br(
    input [63:0] pc,
    input [63:0] sext_num,
    output logic [63:0] br_out
);
 assign br_out=pc + sext_num;
  
endmodule
`endif