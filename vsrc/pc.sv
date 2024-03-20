`ifndef __PC_SV
`define __PC_SV
`ifdef VERILATOR

`else

`endif

module pc(
   input clk,
   input rst,
   input [63:0] data_in,
   output logic [63:0] pc_out,
   output logic [63:0] pc_delay,
   input logic waits
   );

   always @(posedge clk,posedge rst) begin
       if (rst) begin
           pc_out = 64'h80000000;
       end
       else if(waits) begin
			 pc_out =  pc_out;
		end 
        else begin
        pc_delay=pc_out;
			 pc_out = data_in;
		end

        
   end
endmodule

`endif