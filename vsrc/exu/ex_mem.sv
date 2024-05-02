`ifndef __EX_MEM_SV
`define __EX_MEM_SV
`ifdef VERILATOR

`else

`endif
module ex_mem(

    input clk,
    input rst,

    /* ------- signals from the ctrl unit --------*/
    input [5:0] stall,
    input flush,

    /* ------- signals from the exu unit --------*/
    input [63:0]  inst_addr_i,
    input [31:0]  inst_i,

    input                   branch_tag_i,       //this instruction needs jump
    input [63:0]            branch_addr,
    input                   branch_slot_end_i, 

    input [`WBSEL_WIDTH]    WBsel_i,
    input                   RFwe_i,
    input [4:0]             rdaddr_i,
    input [63:0]            rd_wdata_i,

    input                   DMre_i,
    input                   DMwe_i,
    input [2:0]             dreq_info_i,
    input [63:0]            mem_addr_i,
    input [63:0]            mem_wdata_i,

    /* ------- signals to the wbu  --------*/
    output logic[63:0] inst_addr_o,
    output logic[31:0] inst_o,
    //wb
    output logic [`WBSEL_WIDTH] WBsel_o,
    output logic        RFwe_o,
    output logic[4:0]   rdaddr_o,
    output logic[63:0]  rd_wdata_o, 

    output logic          branch_tag,
    output logic[63:0]    branch_pc,
    //mem
    output logic DMre_o,
    output logic DMwe_o,
    output logic [2:0] dreq_info_o,
    output logic[63:0]  mem_addr_o,  
    output logic[63:0]  mem_wdata_o
);

    always @ (posedge clk) begin
        if(rst || flush || (stall[3] && ~stall[4])) begin
            WBsel_o <=0;
            rdaddr_o <= 0;
            RFwe_o <= 0;
            rd_wdata_o <= 0;
			
            DMre_o <= 0;
            DMwe_o <= 0;
            dreq_info_o<=0;
            mem_addr_o <= 0;
            mem_wdata_o <= 0;
            
            inst_addr_o <= 0;
            inst_o <= 0;

            branch_tag <= 0;
            branch_pc <= 0;
        // stall current stage
        end else if(~stall[3]) begin
            WBsel_o <= WBsel_i;
            rdaddr_o <= rdaddr_i;
            RFwe_o <= RFwe_i;
            rd_wdata_o <= rd_wdata_i;

            DMre_o <= DMre_i;
            DMwe_o <= DMwe_i;
            dreq_info_o <= dreq_info_i;
            mem_addr_o <= mem_addr_i;
            mem_wdata_o <= mem_wdata_i;

            inst_o <= inst_i;
            inst_addr_o<=inst_addr_i;
            if(branch_tag_i) begin
                branch_tag <= 1'b1;
                branch_pc <= branch_addr;
            end else if(branch_tag && branch_slot_end_i) begin // branch ended
                branch_tag <= 1'b0;
                branch_pc <= 0;
            end
           
            /*handle the branch instructions

            if( branch_tag_i ) begin   // branch started
                branch_tag <= 1'b1;
                branch_pc <= inst_addr_i;
            end else begin
                if(branch_tag && branch_slot_end_i) begin // branch ended
                    branch_tag <= 1'b0;
                end
            end

            if(branch_tag) begin
                inst_addr_o <= branch_pc;
            end else begin
                inst_addr_o <= inst_addr_i;
            end*/
            
        end   
    end   
endmodule


`endif