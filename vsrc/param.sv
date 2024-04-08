`ifndef __PARAM_SV
`define __PARAM_SV 
      
`ifdef VERILATOR
//signal
 `define ALUOP_WIDTH 5 
 `define SEXTSEL_WIDTH 3 
  `define ALUASEL_WIDTH 1 
   `define ALUBSEL_WIDTH 2 
   `define BRSEL_WIDTH 1
   `define WBSEL_WIDTH 1

`else
`endif

`endif