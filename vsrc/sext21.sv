`ifndef __SEXT21_SV
`define __SEXT21_SV
`ifdef VERILATOR

`else

`endif


module sext21#(parameter N=21)(
   input [N-1:0] data_in,
   output logic [63:0] data_out

 );
 always_comb begin
   if(data_in[N-1]==1)data_out={{(64-N){1'b1}},data_in};
   else data_out={{(64-N){1'b0}},data_in};
 end
endmodule

`endif