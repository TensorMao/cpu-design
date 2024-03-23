`ifndef __IDU_SV
`define __IDU_SV
`ifdef VERILATOR
`include "idu/decoder.sv"
`include "idu/sext.sv"

`else

`endif
module idu(
    input [31:0] instr,
    input [2:0]ZF,
    output [1:0]PC_M,
    output [2:0]M2,
    output [1:0]M4, 
    output [3:0]ALU_C ,
    output RF_W,
    output DM_R,
    output DM_W,
    output skip,
    output [4:0]rdc,
    output [4:0]rs1c,
    output [4:0]rs2c,
    output sign,
    output [63:0] sext_num,
    output [5:0] shamt

    );
    logic [2:0] SEXT_M;
    decoder idu_decoder(instr,ZF,PC_M,M2,M4,SEXT_M,ALU_C,RF_W,DM_R,DM_W,skip,rdc,rs1c,rs2c,sign,shamt);
    sext idu_sext(instr,SEXT_M,DM_W,sext_num);
endmodule
`endif