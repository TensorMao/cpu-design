`ifndef __RDMUX_SV
`define __RDMUX_SV
`ifdef VERILATOR
`include "param.sv"

`else


`endif
module rdmux(
    input [`WBSEL_WIDTH]WBsel,
    input [63:0] csr_data_i,
    input [63:0] alu_data_i,
    input [63:0] dmem_data_i,
    input [63:0] div_data_i,
    input [63:0] rem_data_i,
    input [63:0] mul_data_i,
    output logic [63:0] rd_data_o

    );
    always_comb begin
        case(WBsel)
            0:rd_data_o=alu_data_i;
            3:rd_data_o=csr_data_i;
            4:rd_data_o=dmem_data_i;
            5:rd_data_o=div_data_i;
            6:rd_data_o=rem_data_i;
            7:rd_data_o=mul_data_i;
            default:rd_data_o=alu_data_i;
        endcase
    end

endmodule


`endif