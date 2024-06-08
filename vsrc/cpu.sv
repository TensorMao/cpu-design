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
`include "ctrl.sv"
`include "idu/idu.sv"
`include "wbu/csr.sv"
`include "mmu.sv"
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
  //  output logic [63:0] pc_delay,
    output logic [63:0] pc_out,
    output logic [31:0] instr,
    output logic RFwe,
    output logic [4:0]rdaddr,
    output logic [63:0] rd,
    output logic [63:0]regarray_out [31:0],
    output logic valid,
    output logic skip,
    //csr
    input  trint, swint, exint,
    output logic [63:0] mstatus,
	output logic [63:0]	mepc    ,
	output logic [63:0]	mtval   ,
	output logic [63:0]	mtvec   ,
	output logic [63:0]	mcause  ,
	output logic [63:0]	satp    ,
	output logic [63:0]	mip     ,
	output logic [63:0]	mie     ,
	output logic [63:0]	mscratch,
    output logic [1:0] mode_o
);  
 
 
    logic ifu_finish,mmu_finish;
    logic [63:0]if_exception_o,addr;
    ifu cpu_ifu(
        .clk(clk),
        .rst(rst),
        .flush(ctrl_flush_o),
        .ifu_valid(ifu_valid),
        .PCin(memu_finish),
        .ireq(ireq),
        .iresp(iresp),
        .redirect_valid(redirect_valid),
        .pc_target(br_out),
        .pc_out(pc_out),
       // .pc_delay(pc_delay),
        .instr(instr),
        .ifu_finish(ifu_finish),
        .if_exception_o(if_exception_o),
        .csr_new_pc_i(new_pc_o),
        .mode(mode_o),
        .addr(addr),
        .satp(satp),
        .mmu_valid(mmu_valid),
        .mmu_finish(mmu_finish),
        .dreq(dreq),
        .dresp(dresp)
        );
    
    logic ifu_valid,idu_valid,exu_valid,memu_valid,wb_valid,redirect_valid,ie_type_o,set_cause_o,set_epc_o,set_mtval_o,mstatus_ie_clear_o,mstatus_ie_set_o,ctrl_flush_o,mmu_valid,dreqSel;
    logic[3:0]  trap_cause_o;
    logic[63:0] ctrl_epc_o,mtval_o,new_pc_o ;
    
    ctrl cpu_control(
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .ifu_finish(ifu_finish),
        .exu_finish(exu_finish),
        .memu_finish(memu_finish),
        .mmu_finish(mmu_finish),
        .ifu_valid(ifu_valid),
        .idu_valid(idu_valid),
        .exu_valid(exu_valid),
        .memu_valid(memu_valid),
        .wb_valid(wb_valid),
        .mmu_valid(mmu_valid),
        .exception_i(memu_exception_o),
        .mstatus_ie_i(mstatus_ie_o),  
        .mie_external_i(mie_external_o),
        .mie_timer_i(mie_timer_o),
        .mie_sw_i(mie_sw_o),
        .mip_external_i(mip_external_o),
        .mip_timer_i(mip_timer_o),
        .mip_sw_i(mip_sw_o),
        .mtvec_i(mtvec),
        .epc_i(epc_o),
        .ie_type_o(ie_type_o),
        .set_cause_o(set_cause_o),
        .trap_cause_o(trap_cause_o),
        .set_epc_o(set_epc_o),
        .epc_o(ctrl_epc_o),
        .set_mtval_o(set_mtval_o),
        .mtval_o(mtval_o),
        .mstatus_ie_clear_o(mstatus_ie_clear_o),
        .mstatus_ie_set_o(mstatus_ie_set_o),
        .new_pc_o(new_pc_o),
        .flush_o(ctrl_flush_o),
        .pc_i(pc_out),
        //.mstatus_mpp_i(mstatus_mpp_o),
        .mode_i(mode_o),
        .satp_mode_i(satp[63:60]),
        .dreqSel(dreqSel)
    );

    logic [63:0]id_exception_o,sext_num;
    logic [4:0]rs1addr,rs2addr;
    logic [2:0]dreq_info;
    logic [`ALUOP_WIDTH] ALUop;
    logic [`ALUASEL_WIDTH] ALUAsel;
    logic [`ALUBSEL_WIDTH] ALUBsel;
    logic [`BRSEL_WIDTH] BRsel;
    logic [`WBSEL_WIDTH] WBsel;
    logic DMre,DMwe;
    logic [2:0]CSRsel;

    idu cpu_idu(
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .ifu_valid(ifu_valid),
        .idu_valid(idu_valid),
        .exu_valid(exu_valid),
        .memu_valid(memu_valid),
        .wb_valid(wb_valid),
        .rs1addr(rs1addr),
        .rs2addr(rs2addr),
        .rdaddr(rdaddr),
        .sext_num(sext_num),
        .ALUop(ALUop),
        .ALUAsel(ALUAsel),
        .ALUBsel(ALUBsel),
        .BRsel(BRsel),
        .WBsel(WBsel),
        .RFwe(RFwe),
        .DMre(DMre),
        .DMwe(DMwe),
        .dreq_info(dreq_info),
        .csr_we_o(csr_we_o),
        .csr_addr_o(csr_addr_o),
        .CSRsel(CSRsel),
        .id_exception_i(if_exception_o),
        .id_exception_o(id_exception_o)
    );
    logic exu_finish,exu_csr_we_o;
    logic [63:0] br_out,alu_out,div_out,rem_out,mul_out,rs1,rs2,A,B ,exu_exception_o,csr_wdata_rd_o;
    logic [63:0]exu_csr_wdata_o;
    logic [11:0]exu_csr_waddr_o;

    exu cpu_exu(
        .clk(clk),
        .rst(rst),
        .exu_valid(exu_valid),
        .A(A),
        .B(B),
        .rs1(rs1),
        .rs2(rs2),
        .pc(pc_out),
        .sext_num(sext_num),
        .ALUop(ALUop),
        .BRsel(BRsel),
        .alu_out(alu_out),
        .br_out(br_out),
        .redirect_valid_out(redirect_valid),
        .div_out(div_out),
        .rem_out(rem_out),
        .mul_out(mul_out),
        .exu_finish(exu_finish),
        .CSRsel(CSRsel),
        .csr_wdata_o(exu_csr_wdata_o),
        .csr_wdata_rd_o(csr_wdata_rd_o),
        .csr_rdata_i(csr_rdata_o),
        .exu_exception_i(id_exception_o),
        .exu_exception_o(exu_exception_o)
        );

    logic [63:0] dmem_out,memu_exception_o,memu_csr_wdata_o;
    logic memu_finish,memu_csr_we_o;
    logic [11:0] memu_csr_waddr_o;
    mem cpu_mem (
        .clk(clk),
        .rst(rst),
        .DMre(DMre),
        .DMwe(DMwe),
        .vaddr(alu_out),
        .data(rs2),
        .dreq_info(dreq_info),
        .dreq(dreq),
        .dresp(dresp),
        .dmem_out(dmem_out),
        .memu_finish(memu_finish),
        .memu_valid(memu_valid),
        .memu_exception_i(exu_exception_o),
        .memu_exception_o(memu_exception_o),
        .satp_i(satp),
        .dreqSel_i(dreqSel)
        );

    logic wb_finish;

    regfile cpu_regfile(clk,rst,idu_valid,wb_valid,RFwe,rs1addr,rs2addr,rdaddr,rd,rs1,rs2,regarray_out,wb_finish);

    logic csr_we_o,csr_re_o;
    logic [11:0]csr_addr_o;
    logic [63:0] csr_wdata_o,csr_rdata_o;
    logic   mstatus_ie_o,mie_external_o,mie_timer_o,mie_sw_o,mip_external_o,mip_timer_o,mip_sw_o;
    logic[63:0]epc_o;
    
    csr cpu_csr(
        .clk(clk),
        .rst(rst),
        .csr_we_i(csr_we_o),
        .waddr_i(csr_addr_o),
        .wdata_i(exu_csr_wdata_o),      
        .irq_software_i(swint),
        .irq_timer_i(trint),
        .irq_external_i(exint),
        .raddr_i(csr_addr_o), 
        .rdata_o(csr_rdata_o),        
        .ie_type_i(ie_type_o),
        .set_cause_i(set_cause_o),
        .trap_cause_i(trap_cause_o),
        .set_epc_i(set_epc_o),
        .epc_i(pc_out),
        .set_mtval_i(set_mtval_o),
        .mtval_i(mtval_o),
        .mstatus_ie_clear_i(mstatus_ie_clear_o),
        .mstatus_ie_set_i(mstatus_ie_set_o),
        .mstatus_ie_o(mstatus_ie_o),
        .mie_external_o(mie_external_o),
        .mie_timer_o(mie_timer_o),
        .mie_sw_o(mie_sw_o),
        .mip_external_o(mip_external_o),
        .mip_timer_o(mip_timer_o),
        .mip_sw_o(mip_sw_o),
        .mtvec_o(mtvec),
        .epc_o(epc_o),
        .mstatus(mstatus),
        .mepc(mepc), 
	    .mtval(mtval), 
        .mtvec(mtvec),
        .mcause(mcause),
	    .satp(satp),
        .mip(mip),   
	    .mie(mie),
	    .mscratch(mscratch),
        .mode_o(mode_o)
    );

    aluamux cpu_aluamux(ALUAsel,rs1,pc_out,A);
    alubmux cpu_alubmux(ALUBsel,rs2,sext_num,B);
    rdmux cpu_rdmux(
        .WBsel(WBsel),
        .csr_data_i(csr_wdata_rd_o),
        .alu_data_i(alu_out),
        .dmem_data_i(dmem_out),
        .div_data_i(div_out),
        .rem_data_i(rem_out),
        .mul_data_i(mul_out),
        .rd_data_o(rd)
        );

    logic valid_tem1;
    always_ff@(posedge clk)begin
        valid<=valid_tem1;
        valid_tem1<=wb_valid;
    end

endmodule

`endif