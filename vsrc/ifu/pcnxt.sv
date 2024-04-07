`ifndef __PCNXT_SV
`define __PCNXT_SV
`ifdef VERILATOR

`else

`endif
module pcnxt(
    input [63:0]pc_in,
    input redirect_valid,
    input [63:0]redirect_target,
    output logic [63:0]pc_nxt
    );

    always_comb begin 
        pc_nxt=redirect_valid?redirect_target:(pc_in+4);
    end

endmodule

`endif