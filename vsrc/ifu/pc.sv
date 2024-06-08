`ifndef __PC_SV
`define __PC_SV
`ifdef VERILATOR

`else

`endif
module pc(
    input clk,
    input rst,
    input PCin,
    input [63:0] pc_in,
    output logic [63:0] pc_out,
  //  output logic [63:0] pc_delay,
    output logic misaligned
  
   );
    
    assign misaligned=pc_in[1:0]!=2'b00;

    always_ff @(posedge clk,posedge rst) begin
        if (rst) begin
           pc_out <= 64'h80000000;
        end
        else if(PCin)begin
        //    pc_delay <= pc_out;
			pc_out  <= pc_in;
		end
    end

endmodule




`endif