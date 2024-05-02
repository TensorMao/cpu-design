`ifndef __REGFILE_SV
`define __REGFILE_SV
`ifdef VERILATOR

`else

`endif

module regfile(
   input clk,
   input rst,
   output logic [63:0] regarray [31:0] ,
   /*-----rd-----*/
   input RFwe,
   input [4:0] rdaddr,
   input [63:0] rd,
   /*-----rs1-----*/
   input RFre1,
   input [4:0] rs1addr,
   output logic[63:0] rs1,
    /*-----rs2-----*/
   input RFre2,
   input [4:0] rs2addr,
   output logic[63:0] rs2

   );
   integer i;
 
    always_ff @ (posedge clk)begin: write
        if(rst)begin
            i = 0 ;
            repeat (32) begin
                regarray [i] <= 0;      //没有延迟的赋值，即同时赋值为0
                i = i + 1 ;
            end
        end
        else if (RFwe &&rdaddr != 0) begin
            regarray[rdaddr] <= rd;
        end
   end

   always_comb begin: read_rs1
      if(rst) begin
            rs1= 0;
      end else if((rs1addr == rdaddr) && RFwe && RFre1) begin
            rs1 = rd;
        end else if(RFre1) begin
            rs1 = regarray[rs1addr];
        end else begin
            rs1 = 0;
        end

   end

   always_comb begin: read_rs2
      if(rst) begin
            rs2= 0;
      end else if((rs2addr == rdaddr) && RFwe && RFre2) begin
            rs2 = rd;
        end else if(RFre1) begin
            rs2 = regarray[rs2addr];
        end else begin
            rs2 = 0;
        end

   end



endmodule

`endif