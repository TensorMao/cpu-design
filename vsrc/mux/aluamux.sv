`ifndef __ALUAMUX_SV
`define __ALUAMUX_SV
`ifdef VERILATOR

`else


`endif
module aluamux(
    input ALUA_M,
    input [63:0] rs1_out,
    input [63:0] pc,
    output logic[63:0] aluamux_out

    );
    always_comb begin
        case(ALUA_M)
            0:aluamux_out=rs1_out;
            1:aluamux_out=pc;
            default:aluamux_out=rs1_out;
        endcase
    end

endmodule

`endif