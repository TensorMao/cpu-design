`ifndef __PARAM_SV
`define __PARAM_SV 
      
`ifdef VERILATOR
//signal
   `define ALUOP_WIDTH 4:0 
   `define SEXTSEL_WIDTH 2:0 
   `define ALUASEL_WIDTH 0:0 
   `define ALUBSEL_WIDTH 1:0 
   `define BRSEL_WIDTH 3:0
   `define WBSEL_WIDTH 2:0

`else
`endif

`endif