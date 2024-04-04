`ifndef __IDU_SV
`define __IDU_SV
`ifdef VERILATOR
`include "idu/decoder.sv"
`include "idu/sext.sv"

`else

`endif
module idu(
    input clk,
    input rst,
    input idu_valid,
    input [31:0] instr,
    input [2:0]ZF,
    output logic [1:0]PC_M,
    output logic[2:0]RD_M,
    output logic[1:0]ALUB_M, 
    output logic[3:0]ALU_C ,
    output logic RF_W,
    output logic DM_R,
    output logic DM_W,
    output logic skip,
    output logic [4:0]rdc,
    output logic [4:0]rs1c,
    output logic [4:0]rs2c,
    output logic sign,
    output logic[63:0] sext_num,
    output logic[5:0] shamt,
    output logic idu_finish
    );

    logic [2:0] SEXT_M;
    /*
    logic RF_W_t,read_data_ok;
    logic [2:0]RD_M_t;
    logic [4:0] rdc_t;
    logic [4:0] rdc_reg;
    assign read_data_ok= dreq.strobe==0&&dresp.data_ok;
    assign RF_W=read_data_ok||RF_W_t; 
    assign RD_M=read_data_ok?4:RD_M_t;
    assign rdc=read_data_ok?rdc_reg:rdc_t;
    always_ff@(posedge clk)begin
        if(DM_R) rdc_reg<=instr[11:7];
    end
    */
    logic [1:0]PC_M_tem;
    logic [2:0]RD_M_tem,SEXT_M_tem;
    logic [1:0]ALUB_M_tem;
    logic [3:0]ALU_C_tem;
    logic RF_W_tem,DM_R_tem,DM_W_tem,skip_tem;    
    logic [4:0]rdc_tem,rs1c_tem,rs2c_tem;
    logic[5:0] shamt_tem;
    logic[63:0] sext_num_tem;

    decoder idu_decoder(instr,ZF,PC_M_tem,RD_M_tem,ALUB_M_tem,SEXT_M_tem,ALU_C_tem,RF_W_tem,DM_R_tem,DM_W_tem,skip_tem,rdc_tem,rs1c_tem,rs2c_tem,sign,shamt_tem);
    sext idu_sext(instr,SEXT_M_tem,DM_W,sext_num_tem);

    always_ff@(posedge clk,posedge rst)begin
        if(idu_valid)begin
            PC_M<=PC_M_tem;
            RD_M<=RD_M_tem;
            ALUB_M<=ALUB_M_tem;
            ALU_C<=ALU_C_tem;
            RF_W<=RF_W_tem;
            DM_R<=DM_R_tem;
            DM_W<=DM_W_tem;
            skip<=skip_tem;
            rdc<=rdc_tem;
            rs1c<=rs1c_tem;
            rs2c<=rs2c_tem;
            shamt<=shamt_tem;      
            sext_num<=sext_num_tem;  
            idu_finish<=1;   
        end
    end

    

    




endmodule
`endif