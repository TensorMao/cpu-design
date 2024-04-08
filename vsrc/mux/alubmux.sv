`ifndef __ALUBMUX_SV
`define __ALUBMUX_SV
`ifdef VERILATOR

`else


`endif
module alubmux(
    input [1:0]ALUBsel,
    input [63:0] rs2_out,
    input [63:0]sext_num,
    //input [63:0]shamt,
    output logic[63:0] alubmux_out

    );
    always_comb begin
        case(ALUBsel)
            0:alubmux_out=rs2_out;
            1:alubmux_out=sext_num;
          //  2:alubmux_out=shamt;
            3:alubmux_out=4;
            default:alubmux_out=rs2_out;
        endcase
    end

endmodule

`endif