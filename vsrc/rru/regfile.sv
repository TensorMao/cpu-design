`ifndef __REGFILE_SV
`define __REGFILE_SV
`ifdef VERILATOR

`else

`endif

module regfile(
   input clk,
   input rst,
   input RF_W,
   input [4:0] rs1c,//rs1 addr 
   input [4:0] rs2c,//rs2 addr 
   input [4:0] rdc,//rd addr 
   input [63:0] rd,
   output [63:0] rs1,
   output [63:0] rs2,
   output ZF, // x[rs1]==x[rs2]
   output logic [63:0] regarray [31:0] );
 integer i;
 reg [63:0] temprs1;
 reg [63:0] temprs2;
 logic isequal_rdrs1;
 logic isequal_rdrs2;
 always @ (posedge clk)begin
    isequal_rdrs1=0;
    isequal_rdrs2=0;
   if(rst)begin // if reset ,set all regs 0
      i=0;
      while(i<32)begin
      regarray[i]=64'b0;
      i=i+1;
      end
   end
   else begin
       if (RF_W) begin
         if(rdc != 0) begin
            if(rdc==rs1c)begin
              temprs1= regarray[rdc];
              isequal_rdrs1=1;
            end
            if(rdc==rs2c)begin
              temprs2= regarray[rdc];
              isequal_rdrs2=1;
            end
            regarray[rdc] = rd;
            
       end
    end
 end
 end

 assign  rs1=isequal_rdrs1?temprs1:regarray[rs1c];
 assign  rs2=isequal_rdrs2?temprs2:regarray[rs2c];

 assign ZF= (rs1==rs2);
endmodule

`endif