`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "rru/regfile.sv"
`include "mux.sv"
`include "rru/alu.sv"
`include "idu/decoder.sv"
`include "pcmux.sv"
`include "ifu/ifu.sv"
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
    output logic [63:0] pc_out,
    output logic [63:0] pc_delay,
    output logic [31:0] instr_sh,
    output logic RF_W_sh,
    output logic [4:0]rdc_sh,
    output logic [63:0] mux2_out_sh,
    output logic [63:0]regarray_out [31:0],
    output logic valid,
    output logic skip
);
    logic [31:0] instr;
    //small components
    logic [63:0]add_out;
    assign add_out = pc_out + sext_num;
   
    //mux output
    logic [63:0]pcmux_out,mux2_out,mux3_out,mux4_out;
    assign mux2_out_sh=mux2_out;
    //decoder output
    logic RF_W,DM_R,DM_W,M4,RF_Win;
    logic [1:0]M1;
    logic [2:0]ALU_C,M2,M2in;
    logic [4:0]rs1c,rs2c,rdc_t,rdc;
    logic [63:0] sext_num;
    assign rdc=(dreq.strobe==0&&dresp.data_ok)?rdc_reg:rdc_t;
    assign rdc_sh=rdc;
    assign RF_W_sh=RF_W;
    assign RF_Win=(dreq.strobe==0&&dresp.data_ok)||RF_W; 
    assign M2in=(dreq.strobe==0&&dresp.data_ok)?4:M2;
    //rf output
    logic [63:0]rs1_out,rs2_out;
    logic ZF;
    //alu output
    logic [63:0]alu_out;
    //dmem output
    logic [63:0] dmem_out;
    logic [4:0]rdc_reg;
    /*logic dwaits;
    assign dwaits=dreq.valid && ~dresp.data_ok;*/
    assign dmem_out=dresp.data;

    always @(posedge clk)begin
        if(DM_R)begin
            dreq.valid=1;
            dreq.addr=alu_out;
            dreq.size=3'b011;
            dreq.strobe=0;
            rdc_reg=instr[11:7];
        end
        else if(DM_W)begin
            dreq.valid=1;
            dreq.addr=alu_out;
            dreq.size=3'b011;
            dreq.strobe=8'b11111111;
            dreq.data= (rs2_out<< ((alu_out[1:0]) << 3));
        end       
        else if(dresp.data_ok)dreq.valid=0;
    end

    logic valid_tem;

    always_ff@(posedge clk)begin
        valid<=valid_tem;
        valid_tem<=(iresp.data_ok&&~DM_R)||(dresp.data_ok&&dreq.strobe==0);
    end
    wire ifu_valid;
    ifu _ifu_ (clk,rst,ireq,iresp,skip,pcmux_out,ifu_valid,pc_out,pc_delay,instr,instr_sh);
    pcmux _pcmux_(add_out,{alu_out[63:1],1'b0},pc_out,M1,pcmux_out);
    decoder _decoder_(instr,ZF,M1,M2,M4,ALU_C,RF_W,DM_R,DM_W,skip,sext_num,rdc_t,rs1c,rs2c);
    regfile cpu_rf(clk,rst,RF_Win,rs1c,rs2c,rdc,mux2_out,rs1_out,rs2_out,ZF,regarray_out);
    alu cpu_alu(rs1_out,mux4_out,ALU_C,alu_out);   
    mux mux2(alu_out,pc_out+4,sext_num,add_out,dmem_out,64'b0,64'b0,64'b0,M2in,mux2_out);
    mux mux4(rs2_out, sext_num,64'b0,64'b0,64'b0,64'b0,64'b0,64'b0,{2'b0,M4},mux4_out);
   
       
 
endmodule

`endif