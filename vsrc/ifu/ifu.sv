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
    /* ----- signals from the ctrl unit -----*/
    input [5:0] stall,
    input flush,
   // input pc_nxt,
    //input ifu_valid,
    
   input  ibus_resp_t iresp,
   output [31:0] instr,
   // input PCin,
    input branch_valid,
    input [63:0]branch_addr,

    output logic [63:0] pc_o,
    output logic [63:0] pc_delay_o,
    output ibus_req_t  ireq,
    output logic  branch_slot_end_o,

    output logic stall_req

    );
   // logic stall;
    logic [63:0]pc_nxt;
    
    //assign ireq.valid=ifu_valid;
   // assign instr=iresp.data;
   // assign stall = ~iresp.data_ok;
   // assign ifu_finish=iresp.data_ok;

    pc ifu_pc(clk,rst,stall[0],flush,pc_nxt,pc_o,pc_delay_o);
    pcnxt ifu_pcnxt(pc_o,branch_valid,branch_addr,pc_nxt);

    assign stall_req=ireq.valid && ~iresp.data_ok;
    assign instr=iresp.data;
    assign ireq.valid=1;
    assign ireq.addr=pc_o;

    always_ff@(posedge clk)begin
      if(branch_valid && ~stall[0])branch_slot_end_o<=1;
      else branch_slot_end_o<=0;
    end

endmodule






`endif