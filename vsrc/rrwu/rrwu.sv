`ifndef __RRWU_SV
`define __RRWU_SV
`ifdef VERILATOR
`include "rrwu/regfile.sv"
`else

`endif
module rrwu import common::*;(
    input clk,
    input rst,
    input sign,
    input RF_W,
    input [2:0]RD_M,
    
    input [4:0] rs1c,//rs1 addr 
    input [4:0] rs2c,//rs2 addr 
    input [4:0] rdc,//rd addr 
    input [63:0] rd,

    output logic[63:0] rs1,
    output logic[63:0] rs2,
    output logic[2:0]ZF, 
    output logic [63:0] regarray [31:0]
    );
    regfile rrwu_rf(clk,rst,sign,RF_W,rs1c,rs2c,rdc,rd,rs1,rs2,ZF,regarray);
endmodule




`endif