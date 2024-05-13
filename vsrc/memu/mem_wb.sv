`ifndef __MEM_WB_SV
`define __MEM_WB_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif


module mem_wb(

    input clk,
    input rst,

    /*-- signals from contrl module -----*/
    input[5:0]  stall,
    input       flush,

    output logic [63:0] inst_addr_i,
    output logic [31:0] inst_i,

    /*-- signals from mem -----*/
	//GPR
    input [`WBSEL_WIDTH]WBsel_i,
    input   RFwe_i,
    input[4:0]   rdaddr_i,
    input[63:0]           rd_wdata_i,
    input skip_i,
    /*-- signals passed to wb stage -----*/
	//GPR
    output logic [`WBSEL_WIDTH] WBsel_o,
    output logic                    RFwe_o,
    output logic[4:0]            rdaddr_o,
    output logic[63:0]           rd_wdata_o,

    output logic [63:0] inst_addr_o,
    output logic [31:0] inst_o,
    output logic skip_o
);

    always_ff @ (posedge clk) begin
        if(rst||flush||(stall[4] && ~stall[5])) begin
		    // GPR
            WBsel_o<=0;
            RFwe_o <= 0;
            rdaddr_o <= 0;
            rd_wdata_o <= 0;
        end else if(~stall[4]) begin
		    // write the GPR
            WBsel_o<=WBsel_i;
            RFwe_o <= RFwe_i;
            rdaddr_o <= rdaddr_i;
            rd_wdata_o <= rd_wdata_i;
            inst_o<=inst_i;
            inst_addr_o<=inst_addr_i;
            skip_o<=skip_i;

        end  //if
    end  //always
endmodule

`endif