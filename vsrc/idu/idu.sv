`ifndef __IDU_SV
`define __IDU_SV
`ifdef VERILATOR
`include "idu/decoder.sv"
`include "idu/sext.sv"

`else

`endif
module idu(
    input clk,
    input [31:0] instr,
    input [2:0]ZF,
    input dstall,
    output [1:0]PC_M,
    output [2:0]RD_M,
    output [1:0]ALUB_M, 
    output [3:0]ALU_C ,
    output RF_W,
    output DM_R,
    output DM_W,
    output skip,
    output [4:0]rdc,
    output [4:0]rs1c,
    output [4:0]rs2c,
    output sign,
    output [63:0] sext_num,
    output [5:0] shamt

    );
    logic [2:0] SEXT_M;
    logic RF_W_t;
    logic [2:0]RD_M_t;
    logic [4:0] rdc_t;
    logic [4:0] rdc_reg;
    assign RF_W=dstall||RF_W_t; 
    assign RD_M=dstall?4:RD_M_t;
    assign rdc=dstall?rdc_reg:rdc_t;
    always_ff@(posedge clk)begin
        if(DM_R) rdc_reg<=instr[11:7];
    end

    decoder idu_decoder(instr,ZF,PC_M,RD_M_t,ALUB_M,SEXT_M,ALU_C,RF_W_t,DM_R,DM_W,skip,rdc_t,rs1c,rs2c,sign,shamt);
    sext idu_sext(instr,SEXT_M,DM_W,sext_num);

    

    




endmodule
`endif