`ifndef __CPU_SV
`define __CPU_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "pc.sv"
`include "npc.sv"
`include "sext12.sv"
`include "sext13.sv"
`include "sext21.sv"
`include "sext32.sv"
`include "regfile.sv"
`include "mux.sv"
`include "alu.sv"
`include "decoder.sv"
`include "nxtpc.sv"
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
    output logic [31:0] order_sh,
    output logic RF_W_sh,
    output logic [4:0]rdc_sh,
    output logic [63:0] mux2_out_sh,
    output logic [63:0]regarray_out [31:0],
    output logic rvalid
);
    //small components
    logic[63:0] add_out;
    logic [63:0]dpc_out;
    logic skip;
    assign add_out=pc_out+mux3_out;
    assign pc_delay=dpc_out;
    wire[63:0] sft_out;
    assign sft_out={alu_out[63:1],1'b0};
    
    //mux output
    logic [63:0]mux1_out,mux2_out,mux3_out,mux4_out;
    wire[11:0] mux5_out;
    assign mux5_out=DM_W?{order[31:25],order[11:7]}:order[31:20];
    assign mux2_out_sh=mux2_out;

    //SEXT output
    logic [63:0]sext12_out,sext13_out,sext32_out,sext21_out;

    //decoder output
    logic RF_W,DM_R,DM_W,M4,RF_Win;
    logic [1:0]M3,M1;
    logic [2:0]ALU_C,M2,M2in;
    logic [4:0]rs1c,rs2c,rdc;
    assign rs1c=order[19:15];
    assign rs2c=order[24:20];
    assign rdc=(dreq.strobe==0&&dresp.data_ok)?rdc_reg:order[11:7];
    assign rdc_sh=rdc;
    assign RF_W_sh=RF_W;
    assign RF_Win=(dreq.strobe==0&&dresp.data_ok)?1:RF_W;
    assign M2in=(dreq.strobe==0&&dresp.data_ok)?4:M2;

  
    //pc output
    //npc output
    logic [63:0]npc_out;
    reg [63:0] npc_reg;
    
    //rf output
    logic [63:0]rs1_out,rs2_out;
    logic ZF;
    //alu output
    logic [63:0]alu_out;
    //dmem output
    logic [63:0] dmem_out;
    //order
    logic [31:0] order; 
    logic [31:0] order_reg;
    assign order_sh=order;
    logic iwaits;

    assign iwaits =ireq.valid && ~iresp.data_ok || dwaits;
    assign ireq.addr=pc_out;
    assign ireq.valid=1;
    assign order=iresp.data;

    logic dwaits;
    logic [63:0]dreqaddr_reg;
    logic [2:0]dreqsize_reg;
    logic [7:0] dreqstrobe_reg;
    logic [63:0] dreqdata_reg;
    logic dreqvalid_reg;
    logic is_read;
    logic [4:0]rdc_reg;

    assign dwaits=dreq.valid && ~dresp.data_ok;
    assign dmem_out=dresp.data;
    assign dreq.addr=dreqaddr_reg;
    assign dreq.size=dreqsize_reg;
    assign dreq.strobe=dreqstrobe_reg;
    assign dreq.data= dreqdata_reg;
    assign dreq.valid=dreqvalid_reg;

    always @(posedge clk)begin
        if(DM_R||DM_W) begin
            dreqvalid_reg=1;
            dreqaddr_reg=alu_out;
            dreqsize_reg=3'b011;
            if(DM_R)begin
                dreqstrobe_reg=0;
                is_read=1;
                rdc_reg=order[11:7];
            end
            else if(DM_W)dreqstrobe_reg=8'b11111111;
            dreqdata_reg= (rs2_out<< ((alu_out[1:0]) << 3));
        end
        else begin
            if(dwaits)begin
                dreqvalid_reg=dreqvalid_reg;
                dreqaddr_reg=dreqaddr_reg;
                dreqsize_reg=dreqsize_reg;
                dreqstrobe_reg=dreqstrobe_reg;
                dreqdata_reg= dreqdata_reg;
            end
            else begin
                is_read=0;
                dreqvalid_reg=0;
            end

        end
    end

always@(posedge clk)begin
    
    if(dreq.valid&&dreq.strobe==0&&dresp.data_ok)dvalid=1;
    else dvalid=0;


end
logic dvalid=0;
logic wend;
logic valid;
always@(posedge clk)begin
    rvalid=valid;
    valid = (iresp.data_ok &&~is_read || dvalid);

end
 //assign 
     


    

    wire [63:0]nxt_pc;
    pc cpu_pc(clk,rst,nxt_pc,pc_out,dpc_out,iwaits);
    nxtpc cpu_nxtpc(clk,rst,mux1_out,iwaits,nxt_pc);
    sext12 cpu_sext12(mux5_out,sext12_out);
    sext13 cpu_sext13({order[31],order[7],order[30:25],order[11:8],1'b0},sext13_out);
    sext32 cpu_sext32({order[31:12],12'b0},sext32_out);
    sext21 cpu_sext21({order[31],order[19:12],order[20],order[30:21],1'b0},sext21_out);
    regfile cpu_rf(clk,rst,RF_Win,rs1c,rs2c,rdc,mux2_out,rs1_out,rs2_out,ZF,regarray_out,wend);
    npc cpu_npc(pc_out,npc_out);

 
    alu cpu_alu(rs1_out,mux4_out,ALU_C,alu_out);
    mux mux1(npc_out,add_out,sft_out,64'b0,64'b0,64'b0,64'b0,64'b0,{1'b0,M1},mux1_out);
    mux mux2(alu_out,dpc_out+4,sext32_out,add_out,dmem_out,64'b0,64'b0,64'b0,M2in,mux2_out);
    mux mux3(sext21_out,sext32_out,sext13_out,64'b0,64'b0,64'b0,64'b0,64'b0,{1'b0,M3},mux3_out);
    mux mux4(rs2_out,sext12_out,64'b0,64'b0,64'b0,64'b0,64'b0,64'b0,{2'b0,M4},mux4_out);
    decoder cpu_decoder(order,ZF,M1,M2,M3,M4,ALU_C,RF_W,DM_R,DM_W,skip);

   
 
endmodule

`endif