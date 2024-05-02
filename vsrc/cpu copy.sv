`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "param.sv"
`include "include/common.sv"
`include "wbu/regfile.sv"
`include "exu/exu.sv"
`include "ifu/ifu.sv"
`include "memu/mem.sv"
`include "idu/rdmux.sv"
`include "idu/alubmux.sv"
`include "idu/aluamux.sv"
`include "idu/controlUnit.sv"
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
    output logic RFwe,
    output logic [4:0]rdaddr,
    output logic [63:0] rd,
    output logic [63:0]regarray_out [31:0],
    output logic valid,
    output logic skip
);  
    logic ifu_finish,exu_finish,memu_finish;
    logic ifu_valid,idu_valid,exu_valid,memu_valid,wb_valid,redirect_valid;
    logic [63:0] br_out,pc_out,alu_out,dmem_out,div_out,rem_out,mul_out,rs1,rs2,A,B,sext_num;
    logic [4:0]rs1addr,rs2addr;
    logic [11:0] csraddr;
    logic [2:0]dreq_info;
    logic [`ALUOP_WIDTH] ALUop;
    logic [`ALUASEL_WIDTH] ALUAsel;
    logic [`ALUBSEL_WIDTH] ALUBsel;
    logic [`BRSEL_WIDTH] BRsel;
    logic [`WBSEL_WIDTH] WBsel;
    logic DMre,DMwe;

    ifu cpu_ifu(clk,rst,ifu_valid,ireq,iresp,exu_finish,redirect_valid,br_out,pc_out,pc_delay,instr,ifu_finish);
    controlUnit cpu_control(clk,rst,instr,ifu_finish,exu_finish,memu_finish,ifu_valid,idu_valid,exu_valid,memu_valid,wb_valid,rs1addr,rs2addr,rdaddr,csraddr,sext_num,ALUop,ALUAsel,ALUBsel,BRsel,WBsel,RFwe,DMre,DMwe,dreq_info);

    exu cpu_exu(clk,rst,exu_valid,A,B,rs1,rs2,pc_out,sext_num,ALUop,BRsel,alu_out,br_out,redirect_valid,div_out,rem_out,mul_out,exu_finish);

    mem cpu_mem (clk,rst,DMre,DMwe,alu_out,rs2,dreq_info,dreq,dresp,dmem_out,memu_finish);

    regfile cpu_regfile(clk,rst,idu_valid,wb_valid,RFwe,rs1addr,rs2addr,rdaddr,rd,rs1,rs2,regarray_out);

    aluamux cpu_aluamux(ALUAsel,rs1,pc_out,A);
    alubmux cpu_alubmux(ALUBsel,rs2,sext_num,B);
    rdmux cpu_rdmux(WBsel,alu_out,dmem_out,div_out,rem_out,mul_out,rd);

    logic valid_tem1;
    always_ff@(posedge clk)begin
        valid<=valid_tem1;
        valid_tem1<=wb_valid;
    end


endmodule

`endif