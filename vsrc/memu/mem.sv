`ifndef __MEM_SV
`define __MEM_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module mem import common::*;(
    input clk,
    input rst,
    input DMre,
    input DMwe,
    input [63:0]addr,
    input [63:0]data,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    output logic [63:0]dmem_out,
    output logic memu_finish
    );

    always_ff @(posedge clk)begin
        if(DMre)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<=3'b011;
            dreq.strobe<=0;
        end
        else if(DMwe)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<=3'b011;
            dreq.strobe<=8'b11111111;
            dreq.data<= (data<< ((addr[1:0]) << 3));
        end     
         if(dresp.data_ok)begin
            dmem_out<=dresp.data;
            dreq.valid<=0;
            memu_finish<=1;
        end
        else memu_finish<=0;
    end




endmodule

`endif