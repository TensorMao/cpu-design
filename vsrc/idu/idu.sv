`ifndef __IDU_SV
`define __IDU_SV
`ifdef VERILATOR
`include "param.sv"
`include "idu/decoder.sv"
`include "idu/sext.sv"

`else

`endif
module idu(
    input clk,
    input rst,
    input [31:0] instr,
    input [2:0]ZF,
    input idu_valid,
    input dstall,
    output [1:0]PC_M,
    output [2:0]RD_M,
    output [1:0]ALUB_M, 
    output ALUA_M,
    output BRsel,
    output [`ALUOP_WIDTH-1:0]ALUop ,
    output RF_W,
    output logic DM_R,
    output logic DM_W,
    output skip,
    output [4:0]rdc,
    output [4:0]rs1c,
    output logic [4:0]rs2c,
    output sign,
    output [63:0] sext_num,
    output [5:0] shamt

    );

    logic [2:0] SEXT_M;
    logic RF_W_t,RF_W_reg,DM_R_t,DM_W_t;
    logic [2:0]RD_M_t,RD_M_reg;
    logic [4:0] rdc_t,rs2c_t;
    logic [4:0] rdc_reg,rs2c_reg;
    assign RF_W=dstall||RF_W_reg; 
    assign RD_M=dstall?4:RD_M_reg;
    assign rs2c=(DM_W)?rs2c_reg:rs2c_t;
    assign rdc=rdc_reg;
    always_ff@(posedge clk)begin
        if(rst)begin
            DM_R<=0;
            DM_W<=0;
            RD_M_reg<=0;
            RF_W_reg<=0;
        end
        if(idu_valid)begin
            RD_M_reg<=RD_M_t;
            RF_W_reg<=RF_W_t;
            rdc_reg<=instr[11:7];
            rs2c_reg<=rs2c_t;
            DM_R<=DM_R_t;
            DM_W<=DM_W_t;
        end
        
    end

   

    decoder idu_decoder(instr,ZF,PC_M,RD_M_t,ALUB_M,ALUA_M,BRsel,SEXT_M,ALUop,RF_W_t,DM_R_t,DM_W_t,skip,rdc_t,rs1c,rs2c_t,sign,shamt);
    sext idu_sext(instr,SEXT_M,DM_W_t,sext_num);

    

    




endmodule
`endif