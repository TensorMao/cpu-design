`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "param.sv"
`include "include/common.sv"
`include "ifu/ifu.sv"
`include "ifu/if_id.sv"
`include "idu/idu.sv"
`include "idu/id_ex.sv"
`include "exu/exu.sv"
`include "exu/ex_mem.sv"
`include "memu/memu.sv"
`include "memu/mem_wb.sv"
`include "wbu/regfile.sv"
`include "wbu/rdmux.sv"
`include "exu/alubmux.sv"
`include "exu/aluamux.sv"
`include "ctrl.sv"
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
    output logic [63:0]regarray_o [31:0],
    output logic valid,
    output logic skip

);  
    logic submit;
    assign submit=(memwb_inst_o!=0);
    logic valid_tem1;
    logic[31:0] instr_tem1;
    logic[63:0] inst_addr_tem1;
    always_ff@(posedge clk)begin
        valid<=valid_tem1;
        valid_tem1<=submit;
        instr<= instr_tem1;
        instr_tem1<=memwb_inst_o;
        pc_delay<= inst_addr_tem1;
        inst_addr_tem1<=memwb_inst_addr_o;
    end
    
    logic [31:0]ifu_inst_o;
    logic ifu_stall_req_o;
    logic [63:0] ifu_pc_o,ifu_dpc_o;
    logic ifu_branch_slot_end_o;
    ifu cpu_ifu(
        .clk(clk),     
        .rst(rst),                  
        .stall(ctrl_stall_o), 
        .flush(0),  
        .iresp(iresp),     
        .instr(ifu_inst_o),  
        .branch_valid(exmem_branch_tag_o),    
        .branch_addr(exmem_branch_pc_o),
        .pc_o(ifu_pc_o),      
        .pc_delay_o(ifu_dpc_o), 
        .ireq(ireq),   
        .stall_req(ifu_stall_req_o),
        .branch_slot_end_o(ifu_branch_slot_end_o)
    );

    logic[63:0] ifid_pc_o;
    logic[31:0] ifid_inst_o;
    logic ifid_branch_slot_end_o;
    
    
    if_id if_id_reg(
        .clk(clk),              
        .rst(rst),
        .stall(ctrl_stall_o),   
        .flush(0), 
        .pc_i(ifu_pc_o),
        .branch_slot_end_i(ifu_branch_slot_end_o),
        .inst_i(ifu_inst_o),
        .branch_valid(exmem_branch_tag_o),
        .pc_o(ifid_pc_o),
        .inst_o(ifid_inst_o),
        .branch_slot_end_o(ifid_branch_slot_end_o)
    );

    logic [4:0] idu_rs1addr_o,idu_rs2addr_o,idu_rdaddr_o;
    logic [31:0] idu_inst_o;
    logic [63:0]idu_instaddr_o,idu_sext_num_o;
    logic idu_branch_slot_end_o;
    logic [`ALUOP_WIDTH]idu_ALUop_o;
    logic [`ALUASEL_WIDTH] idu_ALUAsel_o;
    logic [`ALUBSEL_WIDTH]idu_ALUBsel_o;
    logic [`BRSEL_WIDTH]idu_BRsel_o;
    /* ----- signal to wbu -----*/
    logic [`WBSEL_WIDTH]idu_WBsel_o;
    logic idu_RFwe_o,idu_RFre1_o,idu_RFre2_o;
    /* ----- signal to memu -----*/
    logic idu_DMre_o;
    logic idu_DMwe_o;
    logic [2:0] idu_dreq_info_o;


    idu cpu_idu(
        .rst(rst),
        .stall(ctrl_stall_o),
        .instr(ifid_inst_o),
        .instaddr(ifid_pc_o),
        .branch_slot_end_i(ifid_branch_slot_end_o),
        .RFre1(idu_RFre1_o),
        .rs1addr(idu_rs1addr_o),
        .RFre2(idu_RFre2_o),
        .rs2addr(idu_rs2addr_o),   
        .inst_o(idu_inst_o),
        .inst_addr_o(idu_instaddr_o),
        .branch_slot_end_o(idu_branch_slot_end_o),
        .sext_num(idu_sext_num_o),
        .ALUop(idu_ALUop_o),
        .ALUAsel(idu_ALUAsel_o),
        .ALUBsel(idu_ALUBsel_o),
        .BRsel(idu_BRsel_o),
        .WBsel(idu_WBsel_o),
        .rdaddr(idu_rdaddr_o),
        .RFwe(idu_RFwe_o),
        .DMre(idu_DMre_o),
        .DMwe(idu_DMwe_o),
        .dreq_info(idu_dreq_info_o)
    );

    logic[63:0] reg_rs1_o,reg_rs2_o;
    regfile cpu_regfile(
        .clk(clk),
        .rst(rst),
        .regarray(regarray_o),
        .RFwe(memwb_RFwe_o),
        .rdaddr(memwb_rdaddr_o),
        .rd(rdmux_rd_wdata_o),
        .RFre1(idu_RFre1_o),
        .rs1addr(idu_rs1addr_o),
        .rs1(reg_rs1_o),
        .RFre2(idu_RFre2_o),
        .rs2addr(idu_rs2addr_o),
        .rs2(reg_rs2_o)
    );

    logic [63:0] idex_rs1_o,idex_rs2_o;
    logic [4:0] idex_rdaddr_o;
    logic [31:0] idex_inst_o;
    logic [63:0]idex_instaddr_o,idex_sext_num_o;
    logic idex_branch_slot_end_o;
    logic [`ALUOP_WIDTH]idex_ALUop_o;
    logic [`ALUASEL_WIDTH] idex_ALUAsel_o;
    logic [`ALUBSEL_WIDTH]idex_ALUBsel_o;
    logic [`BRSEL_WIDTH]idex_BRsel_o;
    /* ----- signal to wbu -----*/
    logic [`WBSEL_WIDTH]idex_WBsel_o;
    logic idex_RFwe_o;
    /* ----- signal to memu -----*/
    logic idex_DMre_o;
    logic idex_DMwe_o;
    logic [2:0] idex_dreq_info_o;
    id_ex id_ex_reg(
        .clk(clk),
        .rst(rst),
        .stall(ctrl_stall_o),
        .flush(0),
        .inst_i(idu_inst_o),
        .instaddr_i(idu_instaddr_o),
        .branch_slot_end_i(idu_branch_slot_end_o),
        .rs1data(reg_rs1_o),
        .rs2data(reg_rs2_o),
        .sext_num_i(idu_sext_num_o),
        .ALUop_i(idu_ALUop_o),
        .ALUAsel_i(idu_ALUAsel_o),
        .ALUBsel_i(idu_ALUBsel_o),
        .BRsel_i(idu_BRsel_o),
        .rdaddr_i(idu_rdaddr_o),
        .WBsel_i(idu_WBsel_o),
        .RFwe_i(idu_RFwe_o),
        .DMre_i(idu_DMre_o),
        .DMwe_i(idu_DMwe_o),
        .dreq_info_i(idu_dreq_info_o),
        .inst_o(idex_inst_o),
        .instaddr_o(idex_instaddr_o),
        .branch_slot_end_o(idex_branch_slot_end_o),
        .rs1data_o(idex_rs1_o),
        .rs2data_o(idex_rs2_o),
        .sext_num_o(idex_sext_num_o),
        .ALUop_o(idex_ALUop_o),
        .ALUAsel_o(idex_ALUAsel_o),
        .ALUBsel_o(idex_ALUBsel_o),
        .BRsel_o(idex_BRsel_o),
        .WBsel_o(idex_WBsel_o),
        .rdaddr_o(idex_rdaddr_o),
        .RFwe_o(idex_RFwe_o),
        .DMre_o(idex_DMre_o),
        .DMwe_o(idex_DMwe_o),
        .dreq_info_o(idex_dreq_info_o)
    );

    logic[63:0] aluamux_o;
    aluamux mux_a(
        .ALUAsel(idex_ALUAsel_o),
        .rs1_out(idex_rs1_o),
        .pc(idex_instaddr_o),
        .aluamux_out(aluamux_o)
    );
    logic[63:0] alubmux_o;
    alubmux mux_b(
        .ALUBsel(idex_ALUBsel_o),
        .rs2_out(idex_rs2_o),
        .sext_num(idex_sext_num_o),
        .alubmux_out(alubmux_o)
    );

    logic exu_stall_req_o;
    logic exu_branch_valid_o;
    logic[63:0] exu_branch_addr_o;
    /* ------- passed to next pipeline --------*/
    logic[63:0] exu_instaddr_o;
    logic[31:0] exu_inst_o;

    logic exu_branch_tag_o;
    logic  exu_branch_slot_end_o;
    //wb
    logic [`WBSEL_WIDTH] exu_WBsel_o;
    logic        exu_RFwe_o;
    logic[4:0]   exu_rdaddr_o;
    logic[63:0]  exu_rd_wdata_o;
    //mem
    logic exu_DMre_o;
    logic exu_DMwe_o;
    logic [2:0] exu_dreq_info_o;
    logic[63:0]  exu_mem_addr_o;
    logic[63:0]  exu_mem_wdata_o;
    exu cpu_exu(
        .clk(clk),
        .rst(rst),
        .inst_i(idex_inst_o),
        .instaddr_i(idex_instaddr_o),
        .branch_slot_end_i(idex_branch_slot_end_o),
        .exu_A_i(aluamux_o),
        .exu_B_i(alubmux_o),
        .ALUop(idex_ALUop_o),
        .rs1data(idex_rs1_o),
        .rs2data(idex_rs2_o),
        .sext_num(idex_sext_num_o),
        .BRsel(idex_BRsel_o),
        .WBsel_i(idex_WBsel_o),
        .rdaddr_i(idex_rdaddr_o),
        .RFwe_i(idex_RFwe_o),
        .DMwe_i(idex_DMwe_o),
        .DMre_i(idex_DMre_o),
        .dreq_info_i(idex_dreq_info_o),
        .stall_req_o(exu_stall_req_o),
        .branch_valid(exu_branch_valid_o),
        .branch_addr(exu_branch_addr_o),
        .instaddr_o(exu_instaddr_o),
        .inst_o(exu_inst_o),
        .branch_tag_o(exu_branch_tag_o),
        .branch_slot_end_o(exu_branch_slot_end_o),
        .WBsel_o(exu_WBsel_o),
        .RFwe_o(exu_RFwe_o),
        .rdaddr_o(exu_rdaddr_o),
        .rd_wdata_o(exu_rd_wdata_o),
        .DMre_o(exu_DMre_o),
        .DMwe_o(exu_DMwe_o),
        .dreq_info_o(exu_dreq_info_o),
        .mem_addr_o(exu_mem_addr_o),
        .mem_wdata_o(exu_mem_wdata_o)
    );

    logic[63:0] exmem_inst_addr_o;
    logic[31:0] exmem_inst_o;
    //wb
    logic [`WBSEL_WIDTH] exmem_WBsel_o;
    logic        exmem_RFwe_o;
    logic[4:0]   exmem_rdaddr_o;
    logic[63:0]  exmem_rd_wdata_o;
    //mem
    logic exmem_DMre_o;
    logic exmem_DMwe_o;
    logic [2:0] exmem_dreq_info_o;
    logic[63:0]  exmem_mem_addr_o;  
    logic[63:0]  exmem_mem_wdata_o;
    logic exmem_branch_tag_o;
    logic [63:0] exmem_branch_pc_o;

    ex_mem ex_mem_reg(
        .clk(clk),
        .rst(rst),
        .stall(ctrl_stall_o), 
        .flush(0),
        .inst_addr_i(exu_instaddr_o),
        .inst_i(exu_inst_o),
        .branch_tag_i(exu_branch_tag_o),
        .branch_addr(exu_branch_addr_o),
        .branch_slot_end_i(exu_branch_slot_end_o),
        .WBsel_i(exu_WBsel_o),
        .RFwe_i(exu_RFwe_o),
        .rdaddr_i(exu_rdaddr_o),
        .rd_wdata_i(exu_rd_wdata_o),
        .DMre_i(exu_DMre_o),
        .DMwe_i(exu_DMwe_o),
        .dreq_info_i(exu_dreq_info_o),
        .mem_addr_i(exu_mem_addr_o),
        .mem_wdata_i(exu_mem_wdata_o),
        .inst_addr_o(exmem_inst_addr_o),
        .inst_o(exmem_inst_o),
        .WBsel_o(exmem_WBsel_o),
        .RFwe_o(exmem_RFwe_o),
        .rdaddr_o(exmem_rdaddr_o),
        .rd_wdata_o(exmem_rd_wdata_o),
        .DMre_o(exmem_DMre_o),
        .DMwe_o(exmem_DMwe_o),
        .dreq_info_o(exmem_dreq_info_o),
        .mem_addr_o(exmem_mem_addr_o),
        .mem_wdata_o(exmem_mem_wdata_o),
        .branch_tag(exmem_branch_tag_o),
        .branch_pc(exmem_branch_pc_o)
    );

    logic [`WBSEL_WIDTH] memu_WBsel_o;
    logic memu_RFwe_o;
    logic[4:0]      memu_rdaddr_o;
    logic[63:0]      memu_rd_wdata_o;
     /*------- signals to control ----------*/
    logic        memu_stall_req_o;
    logic[63:0]  memu_inst_addr_o;
    logic[31:0]  memu_inst_o;

    memu cpu_memu(
        .clk(clk),
        .rst(rst),
        .instaddr_i(exmem_inst_addr_o),
        .inst_i(exmem_inst_o),
        .WBsel_i(exmem_WBsel_o),
        .RFwe_i(exmem_RFwe_o),
        .rdaddr_i(exmem_rdaddr_o),
        .rd_wdata_i(exmem_rd_wdata_o),
        .DMre_i(exmem_DMre_o),
        .DMwe_i(exmem_DMwe_o),
        .dreq_info_i(exmem_dreq_info_o),
        .mem_addr_i(exmem_mem_addr_o),
        .mem_wdata_i(exmem_mem_wdata_o),
        .dreq(dreq),
        .dresp(dresp),
        .WBsel_o(memu_WBsel_o),
        .RFwe_o(memu_RFwe_o),
        .rdaddr_o(memu_rdaddr_o),
        .rd_wdata_o(memu_rd_wdata_o),
        .stall_req_o(memu_stall_req_o),
        .instaddr_o(memu_inst_addr_o),
        .inst_o(memu_inst_o)

    );

    logic [`WBSEL_WIDTH] memwb_WBsel_o;
    logic                    memwb_RFwe_o;
    logic[4:0]            memwb_rdaddr_o;
    logic[63:0]           memwb_rd_wdata_o;
    logic[63:0]  memwb_inst_addr_o;
    logic[31:0]  memwb_inst_o;

    mem_wb mem_wb_reg(
        .clk(clk),
        .rst(rst),
        .stall(ctrl_stall_o),
        .flush(0),
        .inst_i(memu_inst_o),
        .inst_addr_i(memu_inst_addr_o),
        .WBsel_i(memu_WBsel_o),
        .RFwe_i(memu_RFwe_o),
        .rdaddr_i(memu_rdaddr_o),
        .rd_wdata_i(memu_rd_wdata_o),
        .WBsel_o(memwb_WBsel_o),
        .RFwe_o(memwb_RFwe_o),
        .rdaddr_o(memwb_rdaddr_o),
        .rd_wdata_o(memwb_rd_wdata_o),
        .inst_addr_o(memwb_inst_addr_o),
        .inst_o(memwb_inst_o)
    );

    logic [63:0] rdmux_rd_wdata_o;
    rdmux mux_rd(
        .WBsel(memwb_WBsel_o),
        .alu_out(memwb_rd_wdata_o),
        .dmem_out(memwb_rd_wdata_o),
        .div_out(memwb_rd_wdata_o),
        .rem_out(memwb_rd_wdata_o),
        .mul_out(memwb_rd_wdata_o),
        .rd(rdmux_rd_wdata_o)
    );
    logic[5:0]  ctrl_stall_o;
    logic ctrl_flush_o;
    ctrl cpu_ctrl(
        .rst(rst),
        .is_ifid_busy_i(ifid_inst_o!=0),
        .is_idex_busy_i(idex_inst_o!=0),
        .is_exmem_busy_i(exmem_inst_o!=0),
        .is_memwb_busy_i(memwb_inst_o!=0),
        .stall_from_if_i(ifu_stall_req_o),
        .stall_from_id_i(0),
        .stall_from_ex_i(exu_stall_req_o),
        .stall_from_mem_i(memu_stall_req_o),
        .stall_o(ctrl_stall_o),
        .flush_o(ctrl_flush_o)
    );



    



endmodule

`endif