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
   output logic [63:0] regarray [31:0],
   output wend  );
 integer i;
 reg [63:0] temp1;
 reg [63:0] temp2;
 logic isequal_rs1;
 logic isequal_rs2;
 always @ (posedge clk)begin
    isequal_rs1=0;
    isequal_rs2=0;
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
              temp1= regarray[rdc];
              isequal_rs1=1;
            end
            if(rdc==rs2c)begin
              temp2= regarray[rdc];
              isequal_rs2=1;
            end
            regarray[rdc] = rd;
            
       end
    end
    wend=1;
 end
 end

 assign  rs1=isequal_rs1?temp1:regarray[rs1c];
 assign  rs2=isequal_rs2?temp2:regarray[rs2c];

 assign ZF= (rs1==rs2);
endmodule

`endif