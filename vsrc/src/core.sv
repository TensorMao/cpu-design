`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "cpu.sv"
`endif

module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */
	cpu cpu(clk,reset,ireq,iresp,dreq,dresp,pc_delay,order,RF_W,rdc,rd,regarray,valid,skip);
	logic [31:0] order;
    logic RF_W;
    logic [4:0]rdc;
    logic [63:0] rd;
	logic [63:0] regarray [31:0];
	logic valid;
	logic  [63:0]pc_delay;
	logic skip;
	

	logic RF_W_tem1;logic RF_W_tem2;
	always_ff @(posedge clk ) begin
		RF_W_tem2 <= RF_W_tem1;
		RF_W_tem1 <= RF_W;
	end

	logic[4:0] rdc_tem1;logic[4:0]  rdc_tem2;
	always_ff @(posedge clk ) begin
		rdc_tem2 <= rdc_tem1;
		rdc_tem1 <= rdc;
	end

	logic[63:0] rd_tem1;logic[63:0]  rd_tem2;
	always_ff @(posedge clk ) begin
		rd_tem2 <= rd_tem1;
		rd_tem1 <= rd;
	end



`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (valid),
		.pc                 (pc_delay),
		.instr              (order),
		.skip               (skip),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (RF_W_tem2),
		.wdest              ({3'b0,rdc_tem2}),
		.wdata              (rd_tem2)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regarray[0]),
		.gpr_1              (regarray[1]),
		.gpr_2              (regarray[2]),
		.gpr_3              (regarray[3]),
		.gpr_4              (regarray[4]),
		.gpr_5              (regarray[5]),
		.gpr_6              (regarray[6]),
		.gpr_7              (regarray[7]),
		.gpr_8              (regarray[8]),
		.gpr_9              (regarray[9]),
		.gpr_10             (regarray[10]),
		.gpr_11             (regarray[11]),
		.gpr_12             (regarray[12]),
		.gpr_13             (regarray[13]),
		.gpr_14             (regarray[14]),
		.gpr_15             (regarray[15]),
		.gpr_16             (regarray[16]),
		.gpr_17             (regarray[17]),
		.gpr_18             (regarray[18]),
		.gpr_19             (regarray[19]),
		.gpr_20             (regarray[20]),
		.gpr_21             (regarray[21]),
		.gpr_22             (regarray[22]),
		.gpr_23             (regarray[23]),
		.gpr_24             (regarray[24]),
		.gpr_25             (regarray[25]),
		.gpr_26             (regarray[26]),
		.gpr_27             (regarray[27]),
		.gpr_28             (regarray[28]),
		.gpr_29             (regarray[29]),
		.gpr_30             (regarray[30]),
		.gpr_31             (regarray[31])
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif