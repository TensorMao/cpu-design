`ifndef __EXU_SV
`define __EXU_SV
`ifdef VERILATOR
`include "param.sv"
`include "exu/alu.sv"
`include "exu/br.sv"
`include "exu/divide.sv"
`include "exu/multiply.sv"
`else

`endif
module exu(  
    input clk,
    input rst,
     /* ----- signals from the decoder unit -----*/
    
    input [31:0] inst_i,
    input[63:0] instaddr_i,
    input branch_slot_end_i,
    //alu
    input [63:0] exu_A_i,
    input [63:0] exu_B_i,
    input [`ALUOP_WIDTH] ALUop,
    //br
    input [63:0] rs1data,
    input [63:0] rs2data,
    
    input [63:0]sext_num, 
    input [`BRSEL_WIDTH]BRsel,
    //signal need to be passed
    //wb
    input logic [`WBSEL_WIDTH] WBsel_i,
    input [4:0] rdaddr_i,
    input RFwe_i,
    //mem
    input DMwe_i,
    input DMre_i,
    input [2:0]dreq_info_i,
    /* ------- signals to the ctrl unit --------*/
    output logic stall_req_o,
    output logic branch_valid,
    output logic[63:0] branch_addr,
    /* ------- passed to next pipeline --------*/
    output logic[63:0] instaddr_o,
    output logic[31:0] inst_o,

    output logic branch_tag_o,
    output logic  branch_slot_end_o,
    //wb
    output logic [`WBSEL_WIDTH] WBsel_o,
    output logic        RFwe_o,
    output logic[4:0]   rdaddr_o,
    output logic[63:0]  rd_wdata_o, 
    //mem
    output logic DMre_o,
    output logic DMwe_o,
    output logic [2:0] dreq_info_o,
    output logic[63:0]  mem_addr_o,  
    output logic[63:0]  mem_wdata_o   
   // used in the wbu
   
    
     // the memory address to access
     // the data to write to the memory for the store instruction

);  
    assign instaddr_o=instaddr_i;
    assign inst_o=inst_i;

    assign branch_slot_end_o=branch_slot_end_i;
    assign branch_tag_o = branch_valid;

    assign WBsel_o=WBsel_i;
    assign RFwe_o=RFwe_i;
    assign rdaddr_o=rdaddr_i;

    assign DMre_o=DMre_i;
    assign DMwe_o=DMwe_i;
    assign dreq_info_o=dreq_info_i;
    assign mem_addr_o=alu_res;
    assign mem_wdata_o=rs2data;

    logic [63:0]alu_res,br_res,div_res,rem_res,mul_res;
    logic div,mul,unsign,word,div_valid,mul_valid,div_data_ok,mul_data_ok;

    assign div=(ALUop>16 && ALUop<25);
    assign mul=(ALUop==15 || ALUop==16);
    assign unsign=(ALUop>18 && ALUop<23);
    assign word=(ALUop>15 && ALUop<21); 
  
    assign div_valid=div && ~div_data_ok;
    assign mul_valid=mul && ~mul_data_ok;
    assign stall_req_o=div_valid||mul_valid;


    always_comb begin
      if(div)begin
        if(WBsel_i==6)rd_wdata_o=rem_res;
        else rd_wdata_o=div_res;
      end
      else if(mul) rd_wdata_o=mul_res;
      else rd_wdata_o=alu_res;
      
    end
    



    alu exu_alu(exu_A_i,exu_B_i,ALUop,alu_res);  
    br exu_br(BRsel,rs1data,rs2data,instaddr_i,sext_num,branch_addr,branch_valid);
    divide exu_divide(clk,rst,~unsign,word,div_valid,rs1data,rs2data,div_data_ok,div_res,rem_res);
    multiply exu_multiply(clk,rst,word,mul_valid,rs1data,rs2data,mul_data_ok,mul_res);


    

    
endmodule

`endif