`ifndef __IF_ID_SV
`define __IF_ID_SV
`ifdef VERILATOR

`else

`endif


module if_id(

    input  clk,
    input  rst,

    /* ------- signals from the ctrl unit --------*/
    input [5:0] stall,
    input flush,

    /* ------- signals from the ifu  -------------*/
    input [63:0]      pc_i,
	input   branch_slot_end_i,

    /* ------- signals from the inst_rom  --------*/
    input [31:0]          inst_i, //the instruction

    /* ---------signals from exu -----------------*/
    input  branch_valid,

	/* ------- signals to the decode -------------*/
    output logic[63:0]      pc_o,
    output logic[31:0]          inst_o,
	output logic  branch_slot_end_o
);

    always @ (posedge clk) begin
        if (rst) begin
            pc_o <= 0;
            inst_o <= 0;
            branch_slot_end_o <= 0;
        end else if (branch_valid) begin
            pc_o <= pc_i;
            inst_o <= 0;
            branch_slot_end_o <= branch_slot_end_i;
        end else if (flush)begin
            pc_o <= pc_i;
            inst_o <= 0;
            branch_slot_end_o <= 0;
        end else if (stall[1] && ~stall[2])begin
            pc_o <= pc_i;
            inst_o <= 0;
            branch_slot_end_o <= 0;
        end else if(~stall[1]) begin
            pc_o <= pc_i;
            inst_o <= inst_i;
            branch_slot_end_o <= branch_slot_end_i;
        end
    end
endmodule


`endif
