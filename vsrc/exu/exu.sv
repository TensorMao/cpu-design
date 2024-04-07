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
    input ifu_finish,
    input BRsel,
    input [`ALUOP_WIDTH-1:0]ALUop,
    input [63:0] pc,
    input [63:0]sext_num,
    input [63:0]A,
    input [63:0]B,
    output logic[63:0] alu_out,
    output logic[63:0] br_out,
    output logic exu_valid,
    output logic exu_data_ok,
    output logic [63:0] div_data,
    output logic [63:0] rem_data,
    output logic [63:0] mul_data
    );
    logic div_data_ok,data_ok,div,mul,mul_data_ok;
    logic [63:0]alu_out_t;
    assign div=(ALUop==16||ALUop==17||ALUop==18||ALUop==19);
    assign mul=(ALUop==15);

    assign exu_data_ok=data_ok||div_data_ok||mul_data_ok;


    alu exu_alu(A,B,ALUop,alu_out_t);  
    br exu_br(BRsel,A,pc,sext_num,br_out);
    divide exu_divide(clk,rst,(ALUop==16||ALUop==18),div,A,B,div_data_ok,div_data, rem_data);
    multiply exu_multiply(clk,rst,mul,A,B,mul_data_ok,mul_data);


    always@(posedge clk,posedge rst)begin
        if(rst)exu_valid<=0;
        else begin
            
             if(ifu_finish)begin
                exu_valid<=1;
                if(~div&&~mul)data_ok<=1;          
            end
             if(exu_data_ok)begin
                exu_valid<=0;
                data_ok<=0;
            end
        end
    end

    always@(posedge clk,posedge rst)begin
        alu_out<=alu_out_t;
    end

    

    
endmodule

`endif