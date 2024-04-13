`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "param.sv"
`include "include/common.sv"
`include "rrwu/regfile.sv"
`include "exu/exu.sv"
`include "ifu/ifu.sv"
`include "memu/mem.sv"
`include "mux/rdmux.sv"
`include "mux/alubmux.sv"
`include "mux/aluamux.sv"
`include "controlUnit.sv"
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
    logic [2:0]dreq_info;
    logic [`ALUOP_WIDTH]ALUop;
    logic [`ALUASEL_WIDTH] ALUAsel;
    logic [`ALUBSEL_WIDTH] ALUBsel;
    logic [`BRSEL_WIDTH]BRsel;
    logic [`WBSEL_WIDTH]WBsel;
    logic DMre,DMwe;

    ifu cpu_ifu(clk,rst,ifu_valid,ireq,iresp,exu_finish,redirect_valid,br_out,pc_out,pc_delay,instr,ifu_finish);
    controlUnit cpu_control(clk,rst,instr,ifu_finish,exu_finish,memu_finish,ifu_valid,idu_valid,exu_valid,memu_valid,wb_valid,rs1addr,rs2addr,rdaddr,sext_num,ALUop,ALUAsel,ALUBsel,BRsel,WBsel,RFwe,DMre,DMwe,dreq_info);

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

  /*  logic [31:0] instr;
    logic DM_R,DM_W,dstall,sign,ALUA_M;
    logic [1:0]PC_M,ALUB_M;
    logic [2:0]RD_M,ZF;
    logic [`ALUOP_WIDTH-1:0]ALUop;
    logic [4:0]rs1c,rs2c;
    logic [5:0] shamt;
    logic [63:0] sext_num,br_out,alu_out,dmem_out,alubmux_out,aluamux_out,pcmux_out,rs1_out,rs2_out,pc_out;
    assign dstall= dreq.strobe==0&&dresp.data_ok;
    logic dwaits;assign dwaits=dreq.valid && ~dresp.data_ok;   
    logic valid_tem1 ,valid_tem2;*/ 
    //TODO
    /*always_ff@(posedge clk)begin
        valid<=valid_tem2;
        valid_tem2<=(exu_data_ok&&~DM_R)||(dresp.data_ok&&dreq.strobe==0);
    end

    logic exu_data_ok,BRsel;
    logic [63:0]div_data,rem_data,mul_data;
    assign ifu_valid=~exu_valid;
    ifu cpu_ifu (clk,rst,ifu_valid,ireq,iresp,skip,br_out,pc_out,pc_delay,instr,ifu_finish);
    idu cpu_idu(clk,exu_data_ok,instr,ZF,iresp.data_ok,dstall,PC_M,RD_M,ALUB_M,ALUA_M,BRsel,ALUop,RF_W,DM_R,DM_W,skip,rdc,rs1c,rs2c,sign,sext_num,shamt);
    exu cpu_exu(clk,rst,ifu_finish,BRsel,ALUop,pc_out,sext_num,aluamux_out,alubmux_out,alu_out,br_out,exu_valid,exu_data_ok,div_data,rem_data,mul_data);
    rrwu cpu_rrwu(clk,rst,sign,RF_W,RD_M,rs1c,rs2c,rdc,rdmux_out,rs1_out,rs2_out,ZF,regarray_out);
    mem cpu_mem (clk,DM_R,DM_W,alu_out,rs2_out,dreq,dresp,dmem_out);


    logic ifu_finish,exu_finish,ifu_valid,idu_valid,exu_valid,wb_valid; 
    controlUnit cpu_control(clk,rst,ifu_finish,exu_finish,ifu_valid,idu_valid,exu_valid,wb_valid);
    
    //pcmux cpu_pcmux(br_out,pc_out,PC_M,pcmux_out);
    rdmux cpu_rdmux(RD_M, alu_out,dmem_out,div_data,rem_data,mul_data,rdmux_out);
    alubmux cpu_alubmux(ALUB_M,rs2_out, sext_num,{58'b0,shamt},pc_out,alubmux_out);
    aluamux cpu_aluamux(ALUA_M,rs1_out,pc_out,aluamux_out);*/

endmodule

`endif