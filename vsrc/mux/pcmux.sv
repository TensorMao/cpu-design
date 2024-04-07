`ifndef __PCMUX_SV
`define __PCMUX_SV
`ifdef VERILATOR

`else

`endif

module pcmux#(parameter N = 2)(

    input [63:0] input_1,
    input [63:0] input_2,
    input [63:0] pc,
    input [N-1:0] select,
    output logic [63:0] pcmux_out
    );

always_comb begin
    case (select)
        1: pcmux_out = input_1;
        2: pcmux_out = input_2;
        default: pcmux_out = pc; 
    endcase
end

endmodule

`endif