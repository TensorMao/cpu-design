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

   /*-------------------------- CSR reg addr -------------------------*/
`define  CSR_MVENDORID_ADDR       12'hF11
`define  CSR_MARCHID_ADDR         12'hF12
`define  CSR_MIMPID_ADDR          12'hF13
`define  CSR_MHARTID_ADDR         12'hF14

/* ------ Machine trap setup ---------*/
`define  CSR_MSTATUS_ADDR         12'h300
`define  CSR_MISA_ADDR            12'h301
`define  CSR_MIE_ADDR             12'h304
`define  CSR_MTVEC_ADDR           12'h305
`define  CSR_MCOUNTEREN_ADDR      12'h306
`define  CSR_MCOUNTINHIBIT_ADDR   12'h320

/* ------ Machine trap handling ------*/
`define  CSR_MSCRATCH_ADDR        12'h340
`define  CSR_MEPC_ADDR            12'h341
`define  CSR_MCAUSE_ADDR          12'h342
`define  CSR_MTVAL_ADDR           12'h343
`define  CSR_MIP_ADDR             12'h344
`define  CSR_MCYCLE_ADDR          12'hB00
`define  CSR_SATP_ADDR            12'h180

// machine states



`else
`endif

`endif