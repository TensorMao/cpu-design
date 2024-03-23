`ifndef __PC_SV
`define __PC_SV
`ifdef VERILATOR

`else

`endif
module pc(
    input clk,
    input rst,
    input stall,
    input [63:0] pc_in,
    output logic [63:0] pc_out,
    output logic [63:0] pc_delay
  
   );

    logic [63:0] pc_reg;
    assign pc_out=pc_reg;

    always_ff @(posedge clk,posedge rst) begin
        if (rst) begin
           pc_reg <= 64'h80000000;
        end
        else if(stall) begin
			pc_reg <=  pc_reg;
		end 
        else begin
            pc_delay <= pc_reg;
			pc_reg  <= pc_in;
		end
    end

endmodule




`endif