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
    output [5:0] shamt,
    output muldiv

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

     typedef enum { 
        s1, //ifetch
        s2, //decode
        s3, //execute
        s4, //memrw
        s5, //writeback
    } state_t;
    state_t state,nxt_state;
    always_ff @( posedge clk ) begin
        if(rst) state<=s1;
        else state <= nxt_state;  
    end

    always_comb begin : state_change
        case(state)
        s1:begin
            if(ifu_finish) nxt_state=s2;
            else nxt_state=s1;
        end
        s2:begin
            nxt_state=s3;
        end
        s3:begin
            if(exu_finish) nxt_state=s5;
        end
        s5:begin
            nxt_state=s1;
        end
        endcase
    end

    decoder idu_decoder(instr,ZF,PC_M,RD_M_t,ALUB_M,ALUA_M,BRsel,SEXT_M,ALUop,RF_W_t,DM_R_t,DM_W_t,skip,rdc_t,rs1c,rs2c_t,sign,shamt,muldiv);
    sext idu_sext(instr,SEXT_M,DM_W_t,sext_num);

    

    




endmodule
`endif