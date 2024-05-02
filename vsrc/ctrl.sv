`ifndef __CTRL_SV
`define __CTRL_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif
module ctrl(
    /* ----- stall request from other modules --------*/
    input rst,
    input is_ifid_busy_i,
    input is_idex_busy_i,
    input is_exmem_busy_i,
    input is_memwb_busy_i,
    input   stall_from_if_i,
    input   stall_from_id_i,
    input   stall_from_ex_i,
    input   stall_from_mem_i,
    /* ---signals to other stages of the pipeline  ----*/
    output logic[5:0]  stall_o,
    output logic flush_o
    // stall request to PC,IF_ID, ID_EX, EX_MEM, MEM_WB， one bit for one stage respectively
);

    always_comb begin
        if(rst) begin
            stall_o = 6'b000000;
        end else if(stall_from_mem_i) begin
             // stall request from memu: need to stop the ifu(0), IF_ID(1), ID_EXE(2), EXE_MEM(3), MEM_WB(4)
            stall_o = 6'b011111;
        end else if(stall_from_ex_i) begin
            // stall request from exu: stop the PC,IF_ID, ID_EXE, EXE_MEM
            stall_o = 6'b001111;
        end else if(stall_from_id_i||(is_ifid_busy_i&&is_exmem_busy_i)) begin
            // stall request from id: stop PC,IF_ID, ID_EXE
            stall_o = 6'b000111;
        end else if(stall_from_if_i) begin
            // stall request from if: stop the PC,IF_ID
            stall_o=6'b000011;
        end else begin
            stall_o = 6'b000000;
        end 
    end











endmodule
`endif