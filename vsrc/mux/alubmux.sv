`ifndef __ALUBMUX_SV
`define __ALUBMUX_SV
`ifdef VERILATOR

`else


`endif
module alubmux(
    input [1:0]ALUB_M,
    input [63:0] rs2_out,
    input [63:0]sext_num,
    input [63:0]shamt,
    output logic[63:0] alubmux_out

    );
    always_comb begin
        case(ALUB_M)
            0:alubmux_out=rs2_out;
            1:alubmux_out=sext_num;
            2:alubmux_out=shamt;
            default:alubmux_out=rs2_out;
        endcase
    end

endmodule

`endif