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
    input [31:0] state,
    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    input redirect_valid,
    input [63:0]pc_target,
    output logic [63:0] pc_out,
    output logic [63:0] pc_delay,
    output logic [31:0] instr,
    output logic [31:0] instr_sh

    );
    logic stall;
    logic [63:0]pc_nxt;
    logic [31:0]instr_reg;
    assign instr_sh=instr_reg;
    
    assign ireq.valid=1;
    assign ireq.addr=pc_out;
    assign instr=iresp.data;
    assign stall =ireq.valid && ~iresp.data_ok;

    pc ifu_pc(clk,rst,stall,pc_nxt,pc_out,pc_delay);
    pcnxt ifu_pcnxt(clk,rst,iresp.data_ok,pc_out,redirect_valid,pc_target,pc_nxt);

    always_ff@(posedge clk)begin
        if(iresp.data_ok)instr_reg<=instr;
        else instr_reg<=instr_reg;
    end





    
   
 


endmodule




`endif