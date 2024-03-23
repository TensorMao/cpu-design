`ifndef __MEM_SV
`define __MEM_SV
`ifdef VERILATOR

`else

`endif
module mem(
    input DM_R,
    input DM_W,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp
    );
endmodule
`endif