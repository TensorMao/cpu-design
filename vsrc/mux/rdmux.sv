`ifndef __RDMUX_SV
`define __RDMUX_SV
`ifdef VERILATOR
`include "param.sv"

`else


`endif
module rdmux(
    input [`WBSEL_WIDTH-1:0]WBsel,
    input [63:0] alu_out,
    input [63:0] dmem_out,
    input [63:0] div_out,
    input [63:0] rem_out,
    input [63:0] mul_out,
    output logic [63:0] rd

    );
    always_comb begin
        case(WBsel)
            0:rd=alu_out;
            4:rd=dmem_out;
            5:rd=div_out;
            6:rd=rem_out;
            7:rd=mul_out;
            default:rd=alu_out;
        endcase
    end

endmodule


`endif