`ifndef __SEXT32_SV
`define __SEXT32_SV
`ifdef VERILATOR

`else

`endif


module sext32#(parameter N=32)(
   input [N-1:0] data_in,
   output logic [63:0] data_out

 );
 always_comb begin
   if(data_in[N-1]==1)data_out={{(64-N){1'b1}},data_in};
   else data_out={{(64-N){1'b0}},data_in};
 end
endmodule

`endif