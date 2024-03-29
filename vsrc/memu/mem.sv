`ifndef __MEM_SV
`define __MEM_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module mem import common::*;(
    input clk,
    input DM_R,
    input DM_W,
    input [63:0]addr,
    input [63:0]data,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    output logic [63:0]dmem_out
    );

    assign dmem_out=dresp.data;

    always_ff @(posedge clk)begin
        if(DM_R)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<=3'b011;
            dreq.strobe<=0;
        end
        else if(DM_W)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<=3'b011;
            dreq.strobe<=8'b11111111;
            dreq.data<= (data<< ((addr[1:0]) << 3));
        end       
        else if(dresp.data_ok)dreq.valid<=0;
    end


endmodule

`endif