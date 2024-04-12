`ifndef __REGFILE_SV
`define __REGFILE_SV
`ifdef VERILATOR

`else

`endif

module regfile(
   input clk,
   input rst,
   input idu_valid,
   input wb_valid,
   input RFwe,
   input [4:0] rs1addr,//rs1 addr 
   input [4:0] rs2addr,//rs2 addr 
   input [4:0] rdaddr,//rd addr 
   input [63:0] rd,
   output logic[63:0] rs1,
   output logic[63:0] rs2,
   output logic [63:0] regarray [31:0] );
   integer i;
   reg [63:0] temprs1;
   reg [63:0] temprs2;
   logic isequal_rdrs1;
   logic isequal_rdrs2;
 //write
   always_ff @( posedge rst ) begin : init
      i = 0 ;
        repeat (32) begin
         regarray [i] <= 0;      //没有延迟的赋值，即同时赋值为0
         i = i + 1 ;
        end
    end
   
 
   always_ff @ (posedge clk)begin: write
      if (RFwe) begin
         if(rdaddr != 0) begin
            regarray[rdaddr] = rd;
            
       end
    end
   end

   always_ff @(posedge clk)begin: read
      if(idu_valid)begin
         rs1<=regarray[rs1addr];
         rs2<=regarray[rs2addr];
      end
   end

endmodule

`endif