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

    /* signal from ctrl */
    input flush,
    input ifu_valid,
    input PCin,
    
    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,

    output dbus_req_t  dreq,
    input  dbus_resp_t dresp,
    
    input redirect_valid,
    input [63:0]pc_target,
    output logic [63:0] pc_out,
    //output logic [63:0] pc_delay,
    output logic [31:0] instr,
    output logic ifu_finish,
    output logic [63:0]if_exception_o,
    input [63:0] csr_new_pc_i,
    input [1:0]mode,
    output logic [63:0] addr,
    input[63:0] satp,
    input mmu_valid,
    output logic mmu_finish
    );
    logic misaligned;
    logic [63:0]pc_nxt;
    pc ifu_pc(
        .clk(clk),
        .rst(rst),
        .PCin(PCin),
        .pc_in(pc_nxt),
        .pc_out(pc_out),
       //.pc_delay(pc_delay),
        .misaligned(misaligned)
        );
    
    pcnxt ifu_pcnxt(
        .pc_in(pc_out),
        .redirect_valid(redirect_valid),
        .redirect_target(pc_target),
        .pc_nxt(pc_nxt),
        .flush(flush),
        .csr_new_pc_i(csr_new_pc_i)
        );

    logic [63:0] physical_addr_o;
    mmu if_mmu(
        .clk(clk),
        .rst(rst),
        .mmu_valid(mmu_valid),
        .mmu_finish(mmu_finish),
        .satp_i(satp),
        .virtual_addr(pc_out),
        .physical_addr(physical_addr_o),
        .dreq(dreq),
        .dresp(dresp)
        );
    assign if_exception_o[0]= misaligned;

    assign addr=(satp[63:60]==8&&mode!=3)?physical_addr_o:pc_out;


    always_ff @( posedge clk ) begin 
        if(ifu_valid && !misaligned)begin
            ireq.valid<=1;
            ireq.addr<=addr;
        end
        else if(ifu_valid && misaligned)begin
            ifu_finish<=1;            
        end

        if(iresp.data_ok)begin
            instr<=iresp.data;
            ireq.valid<=0;
            ifu_finish<=1;
        end

        if(ifu_finish)ifu_finish<=0;

    end





    
   
 


endmodule




`endif