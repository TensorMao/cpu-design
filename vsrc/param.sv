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

   `define  MTVEC_RESET  64'h0
   `define CSR_MTVEC_ADDR 12'h305
   `define CSR_MSTATUS_ADDR 12'h305

    // machine states
   `define STATE_RESET         4'b0001;
   `define STATE_OPERATING     4'b0010;
   `define STATE_TRAP_TAKEN    4'b0100;
   `define STATE_TRAP_RETURN   4'b1000;

`else
`endif

`endif