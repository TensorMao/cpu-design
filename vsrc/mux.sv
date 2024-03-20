`ifndef __MUX_SV
`define __MUX_SV
`ifdef VERILATOR

`else

`endif

module mux(
    input [63:0] input_0,
    input [63:0] input_1,
    input [63:0] input_2,
    input [63:0] input_3,
    input [63:0] input_4,
    input [63:0] input_5,
    input [63:0] input_6,
    input [63:0] input_7,
    input [2:0] select,
    output logic [63:0] mux_out
);

always_comb begin
    case (select)
        0: mux_out = input_0;
        1: mux_out = input_1;
        2: mux_out = input_2;
        3: mux_out = input_3;
        4: mux_out = input_4;
        5: mux_out = input_5;
        6: mux_out = input_6;
        7: mux_out = input_7;
        default: mux_out = 64'b0; 
    endcase
end

endmodule

`endif