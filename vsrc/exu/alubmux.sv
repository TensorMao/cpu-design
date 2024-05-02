`ifndef __ALUBMUX_SV
`define __ALUBMUX_SV
`ifdef VERILATOR
`include "param.sv"
`else


`endif
module alubmux(
    input [`ALUBSEL_WIDTH]ALUBsel,
    input [63:0] rs2_out,
    input [63:0]sext_num,
    output logic[63:0] alubmux_out

    );
    always_comb begin
        case(ALUBsel)
            0:alubmux_out=rs2_out;
            1:alubmux_out=sext_num;
            3:alubmux_out=4;
            default:alubmux_out=rs2_out;
        endcase
    end

endmodule

`endif