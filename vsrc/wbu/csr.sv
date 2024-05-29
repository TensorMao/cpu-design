`ifndef __CSR_SV
`define __CSR_SV
`ifdef VERILATOR
`include "param.sv"
`include "include/common.sv"
`else

module csr(
    input clk,
    input rst,
     /*------ wb module update the csr  --------*/
    input RFwe,
    input [11:0] waddr,         // the register to write
    input [63:0] wdata,         // the data to write

    input wire  instret_incr_i,   // 0 or 1 indicate increase the counter of instret
    output [63:0] mtvec
);
     /*-- mtvec --*/
    always @(posedge clk) begin
        if(rst) mtvec <= `MTVEC_RESET;
        else if(waddr == `CSR_MTVEC_ADDR) && (RFwe) begin
            mtvec <= wdata;
        end
    end

    /*--mstatus--*/
    // {SD(1), WPRI(8), TSR(1), TW(1), TVM(1), MXR(1), SUM(1), MPRV(1), XS(2),
    //  FS(2), MPP(2), WPRI(2), SPP(1), MPIE(1), WPRI(1), SPIE(1), UPIE(1),MIE(1), WPRI(1), SIE(1), UIE(1)}
    // Global interrupt-enable bits, MIE, SIE, and UIE, are provided for each privilege mode.
    // xPIE holds the value of the interrupt-enable bit active prior to the trap, and xPP holds the previous privilege mode.
    logic [63:0]       mstatus;
    logic              mstatus_pie; // prior interrupt enable
    logic              mstatus_ie;
    assign             mstatus_ie_o = mstatus_ie;
    assign mstatus = {19'b0, 2'b11, 3'b0, mstatus_pie, 3'b0 , mstatus_ie, 3'b0};

    always @(posedge clk) begin
        if(rst) begin
            mstatus_ie <= 1'b0;
            mstatus_pie <= 1'b1;
        end else if( (waddr == `CSR_MSTATUS_ADDR) && RFwe) begin
            mstatus_ie <= wdata[3];
            mstatus_pie <= wdata[7];
        end else if(mstatus_ie_clear_i == 1'b1) begin
            mstatus_pie <= mstatus_ie;
            mstatus_ie <= 1'b0;
        end else if(mstatus_ie_set_i == 1'b1) begin
            mstatus_ie <= mstatus_pie;
            mstatus_pie <= 1'b1;
        end
    end
    

endmodule

`endif