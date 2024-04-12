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
    input exu_valid,
    input [63:0]A,
    input [63:0]B,
    input [63:0] rs1,
    input [63:0] rs2,
    input [63:0] pc,
    input [63:0]sext_num,
    input [`ALUOP_WIDTH-1:0]ALUop,
    input [`BRSEL_WIDTH-1:0]BRsel,
    output logic[63:0] alu_out,
   /* output logic [63:0] div_out,
    output logic [63:0] rem_out,
    output logic [63:0] mul_out*/
    output logic[63:0] br_out,
    output logic redirect_valid_out,
    output logic exu_finish
    
    );
  //  logic div_data_ok,data_ok,,mul_data_ok;
    logic alu_data_ok,br_data_ok,redirect_valid;
    logic [63:0]alu_res,br_res;
    logic data_ok;
    always_comb begin : data_ok_blk
      if(BRsel!=0)data_ok=alu_data_ok;
      else data_ok=br_data_ok;
    end;

   /* logic div,mul;
    assign div=(ALUop==16||ALUop==17||ALUop==18||ALUop==19);
    assign mul=(ALUop==15);

    assign exu_data_ok=data_ok||div_data_ok||mul_data_ok;*/
    
    alu exu_alu(clk,exu_valid,A,B,ALUop,alu_res,alu_data_ok);  
    br exu_br(clk,exu_valid,BRsel,rs1,rs2,pc,sext_num,br_res,redirect_valid,br_data_ok);
    /*divide exu_divide(clk,rst,(ALUop==16||ALUop==18),div,A,B,div_data_ok,div_data, rem_data);
    multiply exu_multiply(clk,rst,mul,A,B,mul_data_ok,mul_data);*/



    always@(posedge clk)begin
            if(data_ok)begin
                alu_out<=alu_res;
                br_out<=br_res;
                redirect_valid_out<=redirect_valid;
                exu_finish<=1;
            end
            else exu_finish<=0;
    end

    

    
endmodule

`endif