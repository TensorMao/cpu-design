`ifndef __ID_EX_SV
`define __ID_EX_SV
`ifdef VERILATOR
`else


`endif
module id_ex(
    input clk,
    input rst,
    input[5:0] stall,
    input flush,
    input[31:0] inst_i,
    input [63:0]instaddr_i,
    input  branch_slot_end_i,

    input [63:0]rs1data,
    input [63:0]rs2data,
    
    input [63:0] sext_num_i,
    input [`ALUOP_WIDTH]ALUop_i,
    input [`ALUASEL_WIDTH] ALUAsel_i,
    input[`ALUBSEL_WIDTH] ALUBsel_i,
    input  [`BRSEL_WIDTH]BRsel_i,

    input [4:0]rdaddr_i,
    input [`WBSEL_WIDTH]WBsel_i,
    input RFwe_i,

    input logic DMre_i,
    input logic DMwe_i,
    input logic [2:0] dreq_info_i,
    /* ----- signal to exu -----*/
    output logic[31:0] inst_o,
    output logic[63:0] instaddr_o,
    output logic branch_slot_end_o,

    output logic [63:0]rs1data_o,
    output logic [63:0]rs2data_o,
   
    
    output logic [63:0] sext_num_o,
    output logic [`ALUOP_WIDTH]ALUop_o,
    output logic [`ALUASEL_WIDTH] ALUAsel_o,
    output logic [`ALUBSEL_WIDTH] ALUBsel_o,
    output logic [`BRSEL_WIDTH]BRsel_o,
    /* ----- signal to wbu -----*/
    output logic [`WBSEL_WIDTH]WBsel_o,
     output logic [4:0]rdaddr_o,
    output logic RFwe_o,
    /* ----- signal to memu -----*/
    output logic DMre_o,
    output logic DMwe_o,
    output logic [2:0] dreq_info_o
 



);
    always_ff@(posedge clk)begin
        if(rst||flush||(stall[2]&&~stall[3]))begin
            inst_o<=0;
            instaddr_o<=0;
            branch_slot_end_o<=0;
            rs1data_o<=0;
            rs2data_o<=0;
            rdaddr_o<=0;
            sext_num_o<=0;
            ALUop_o<=0;
            ALUAsel_o<=0;
            ALUBsel_o<=0;
            BRsel_o<=0;
            WBsel_o<=0;
            RFwe_o<=0;
            DMre_o<=0;
            DMwe_o<=0;
            dreq_info_o<=3;
        end
        else if(~stall[2])begin
            inst_o<=inst_i;
            instaddr_o<=instaddr_i;
            branch_slot_end_o<=branch_slot_end_i;
            rs1data_o<=rs1data;
            rs2data_o<=rs2data;
            rdaddr_o<=rdaddr_i;
            sext_num_o<=sext_num_i;
            ALUop_o<=ALUop_i;
            ALUAsel_o<=ALUAsel_i;
            ALUBsel_o<=ALUBsel_i;
            BRsel_o<=BRsel_i;
            WBsel_o<=WBsel_i;
            RFwe_o<=RFwe_i;
            DMre_o<=DMre_i;
            DMwe_o<=DMwe_i;
            dreq_info_o<=dreq_info_i;
        end
    end


endmodule

`endif