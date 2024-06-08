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
    input [`ALUOP_WIDTH]ALUop,
    input [`BRSEL_WIDTH]BRsel,
    output logic[63:0] alu_out,
    output logic[63:0] br_out,
    output logic redirect_valid_out, 
    output logic [63:0] div_out,
    output logic [63:0] rem_out,
    output logic [63:0] mul_out,
    output logic exu_finish,
    //csr
    input [2:0] CSRsel,
    output logic [63:0] csr_wdata_o,
    output logic [63:0] csr_wdata_rd_o,
    input [63:0] csr_rdata_i,
    input  [63:0] exu_exception_i,
    output logic [63:0] exu_exception_o
    );
    logic alu_data_ok,br_data_ok,div_data_ok,mul_data_ok,redirect_valid,div_valid,mul_valid;
    logic [63:0]alu_res,br_res,div_res,rem_res,mul_res;
    logic data_ok,unsign,word,div,mul;
    
    always_comb begin : data_ok_blk
      if(div)           data_ok = div_data_ok;
      else if(mul)      data_ok = mul_data_ok;
      else if(BRsel!=0) data_ok = br_data_ok;
      else              data_ok = alu_data_ok;
    end

    assign div=(ALUop>16 && ALUop<25);
    assign mul=(ALUop==15 || ALUop==16);
    assign unsign=(ALUop>18 && ALUop<23);
    assign word=(ALUop>15 && ALUop<21); 
    assign div_valid=exu_valid && div;
    assign mul_valid=exu_valid && mul;

    alu exu_alu(clk,exu_valid,A,B,ALUop,alu_res,alu_data_ok);  
    br exu_br(clk,exu_valid,BRsel,rs1,rs2,pc,sext_num,br_res,redirect_valid,br_data_ok);
    divide exu_divide(clk,rst,~unsign,word,div_valid,rs1,rs2,div_data_ok,div_res, rem_res);
    multiply exu_multiply(clk,rst,word,mul_valid,rs1,rs2,mul_data_ok,mul_res);




    always@(posedge clk)begin
            if(data_ok)begin
                alu_out<=alu_res;
                br_out<=br_res;
                div_out<=div_res;
                rem_out<=rem_res;
                mul_out<=mul_res;
                redirect_valid_out<=redirect_valid;
                //csr
                csr_wdata_rd_o<=csr_rdata_i;
                exu_exception_o <= exu_exception_i;
                csr_wdata_o<=csr_data;
                exu_finish<=1;
            end
            else exu_finish<=0;
    end

    logic [63:0] csr_result;
    assign       csr_result = csr_rdata_i;

    logic [63:0]csr_data;
    // calculate the data to write to the csr
    always_comb begin
        if(rst) begin
            csr_data = 0;
        end else begin
            case (CSRsel)
                1: begin
                    csr_data = rs1;// csrrw
                end
                2: begin
                    csr_data = rs1 | csr_result;// csrrs
                end
                3: begin
                    csr_data = csr_result & (~rs1); // csrrc
                end
                4: begin
                    csr_data = sext_num;// csrrwi
                end
                5: begin
                    csr_data = sext_num | csr_result;// csrrsi
                end
                6: begin
                    csr_data = csr_result & (~sext_num);//csrrci
                end
                default: begin
                    csr_data = 0;
                end
            endcase
        end 
    end  

   

    
endmodule

`endif