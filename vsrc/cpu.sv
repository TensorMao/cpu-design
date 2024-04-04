`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "rrwu/rrwu.sv"
`include "exu/exu.sv"
`include "ifu/ifu.sv"
`include "idu/idu.sv"
`include "memu/mem.sv"

`include "mux/pcmux.sv"
`include "mux/rdmux.sv"
`include "mux/alubmux.sv"

`else

`endif

module cpu import common::*; (
    input clk,
    input rst,
    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    //show
    output logic [63:0] pc_delay,
    output logic [31:0] instr,
    output logic RF_W,
    output logic [4:0]rdc,
    output logic [63:0] rdmux_out,
    output logic [63:0]regarray_out [31:0],
    output logic valid,
    output logic skip
);
    logic DM_R,DM_W,sign;
    logic [1:0]PC_M,ALUB_M;
    logic [2:0]RD_M,ZF;
    logic [3:0]ALU_C;
    logic [4:0]rs1c,rs2c;
    logic [5:0] shamt;
    logic [63:0] sext_num,br_out,alu_out,dmem_out,alubmux_out,pcmux_out,rs1_out,rs2_out,pc_out;
    
    /*logic dwaits;assign dwaits=dreq.valid && ~dresp.data_ok;*/    
    logic valid_tem;
    //TODO
    always_ff@(posedge clk)begin
        valid<=valid_tem;
        valid_tem<=(iresp.data_ok&&~DM_R)||(dresp.data_ok&&dreq.strobe==0);
    end

    
    ifu cpu_ifu (clk,rst,ifu_valid,skip,iresp,pcmux_out,ireq,pc_out,pc_delay,instr,ifu_finish);
    idu cpu_idu(clk,rst,idu_valid,instr,ZF,PC_M,RD_M,ALUB_M,ALU_C,RF_W,DM_R,DM_W,skip,rdc,rs1c,rs2c,sign,sext_num,shamt,idu_finish);
    exu cpu_exu(clk,rst,exu_valid,ALU_C,pc_out,sext_num,rs1_out,alubmux_out,alu_out,br_out,exu_finish);
    rrwu cpu_rrwu(clk,rst,sign,RF_W,RD_M,rs1c,rs2c,rdc,rdmux_out,rs1_out,rs2_out,ZF,regarray_out);
    mem cpu_mem (clk,DM_R,DM_W,alu_out,rs2_out,dreq,dresp,dmem_out);
    //mux
    pcmux cpu_pcmux(br_out,{alu_out[63:1],1'b0},pc_out,PC_M,pcmux_out);
    rdmux cpu_rdmux(RD_M, alu_out,pc_out+4,sext_num,br_out,dmem_out,rdmux_out);
    alubmux cpu_alubmux(ALUB_M,rs2_out, sext_num,{58'b0,shamt},alubmux_out);

    //state control
    logic ifu_valid,idu_valid,exu_valid;
    logic ifu_finish,idu_finish,exu_finish;

    



endmodule

`endif