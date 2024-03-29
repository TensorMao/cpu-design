`ifndef __RDMUX_SV
`define __RDMUX_SV
`ifdef VERILATOR

`else


`endif
module rdmux(
    input [2:0]RD_M,
    input [63:0] alu_out,
    input [63:0] pcadd4,
    input [63:0] sext_num,
    input [63:0] br_out,
    input [63:0] dmem_out,
    output logic [63:0] rd

    );
    always_comb begin
        case(RD_M)
            0:rd=alu_out;
            1:rd=pcadd4;
            2:rd=sext_num;
            3:rd=br_out;
            4:rd=dmem_out;
            default:rd=alu_out;
        endcase
    end

endmodule


`endif