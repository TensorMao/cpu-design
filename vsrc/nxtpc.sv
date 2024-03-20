`ifndef __NXTPC_SV
`define __NXTPC_SV
`ifdef VERILATOR

`else

`endif

module nxtpc(
    input clk,
    input rst,
    input [63:0]data_in,
    input waits,
    output logic [63:0]nxt_pc
);
  always@(posedge clk,posedge rst)begin
        if(rst)nxt_pc=data_in;

        if(waits) begin
			nxt_pc =nxt_pc;
		end 
        else begin
            nxt_pc=data_in;
		end


  end

endmodule

`endif