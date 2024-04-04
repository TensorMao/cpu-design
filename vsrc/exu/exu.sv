`ifndef __EXU_SV
`define __EXU_SV
`ifdef VERILATOR
`include "exu/alu.sv"
`include "exu/br.sv"
`else

`endif
module exu(  
    input clk,
    input rst,
    input exu_valid,
    input [3:0]ALU_C,
    input [63:0] pc,
    input [63:0]sext_num,
    input [63:0]A,
    input [63:0]B,
    output logic[63:0] alu_out,
    output logic[63:0] br_out,
    output logic exu_finish
   
    );
    logic [63:0] alu_out_tem,br_out_tem;

    alu exu_alu(A,B,ALU_C,alu_out_tem);  
    br exu_br(pc,sext_num,br_out_tem);

    always_ff@(posedge clk)begin
        if(exu_valid)begin
            alu_out<=alu_out_tem;
            br_out<=br_out_tem;
            exu_finish<=1;
        end
    end




    
endmodule

`endif