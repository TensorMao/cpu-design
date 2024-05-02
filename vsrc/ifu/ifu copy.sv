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
    input [5:0] stall,
    input flush,
    //input ifu_valid,
    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
   // input PCin,
    input redirect_valid,
    input [63:0]pc_target,
    output logic [63:0] pc_out,
    output logic [63:0] pc_delay,
    output logic [31:0] instr,
    //output logic ifu_finish
    output logic stall_req

    );
   // logic stall;
    logic [63:0]pc_nxt;
    
    //assign ireq.valid=ifu_valid;
   // assign instr=iresp.data;
   // assign stall = ~iresp.data_ok;
   // assign ifu_finish=iresp.data_ok;

    pc ifu_pc(clk,rst,stall[0],pc_nxt,pc_out,pc_delay);
    pcnxt ifu_pcnxt(pc_out,redirect_valid,pc_target,pc_nxt);

    always_ff @( posedge clk ,posedge rst ) begin 
            if(~stall[0])begin
                ireq.valid<=1;
                ireq.addr<=pc_out;
                stall_req<=1;
            end

            if(iresp.data_ok)begin
                instr<=iresp.data;
                ireq.valid<=0;
                //ifu_finish<=1;
                stall_req<=0;
            end
            //else ifu_finish<=0;

    end





    
   
 


endmodule




`endif