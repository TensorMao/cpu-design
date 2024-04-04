`ifndef __IFU_SV
`define __IFU_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "ifu/pcnxt.sv"
`include "ifu/pc.sv"
`else

`endif
module ifu import common::*;(
    input clk,
    input rst,
    input ifu_valid,
    input redirect_valid,
    input  ibus_resp_t iresp,
    input [63:0]pc_target,
    output ibus_req_t  ireq,
    output logic [63:0] pc_out,
    output logic [63:0] pc_delay,
    output logic [31:0] instr,
    output logic 
    );
    logic stall;
    logic [63:0]pc_nxt;

    assign ireq.valid=ifu_valid;
    assign ireq.addr=pc_out;
    assign instr=iresp.data;
    assign stall = ~iresp.data_ok;
    assign ifu_finish=iresp.data_ok;

    pc ifu_pc(clk,rst,stall,pc_nxt,pc_out,pc_delay);
    pcnxt ifu_pcnxt(iresp.data_ok,pc_out,redirect_valid,pc_target,pc_nxt);


endmodule




`endif