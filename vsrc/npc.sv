`ifndef __NPC_SV
`define __NPC_SV
`ifdef VERILATOR

`else

`endif

module npc(
    input [63:0] npc_in,
    output reg [63:0] npc_out
);

//always @(negedge clk) begin
   assign npc_out = npc_in + 64'd4;
//end

endmodule


`endif