`ifndef __CONTROLUNIT_SV
`define __CONTROLUNIT_SV
`ifdef VERILATOR

`else

`endif

module controlUnit(
    input clk,
    input rst,
    input ZF,
    output logic[1:0]PC _M,
    output logic[2:0]RD_M,
    output logic[1:0]ALUB_M, 
    output logic[2:0] SEXT_M,
    output logic[3:0]ALU_C,
    output logic RF_W,
    output logic DM_R,
    output logic DM_W,
    output logic skip,
    output logic sign,
    output logic[5:0]shamt
    );



    
endmodule


`endif