`ifndef __PCNXT_SV
`define __PCNXT_SV
`ifdef VERILATOR

`else

`endif
module pcnxt(
    input instr_valid,
    input [63:0]pc_in,
    input redirect_valid,
    input [63:0]redirect_target,
    output logic [63:0]pc_nxt
    );

    always_comb begin 
        if(instr_valid)pc_nxt=redirect_valid?redirect_target:(pc_in+4);
        else pc_nxt=pc_in+4;
        
    end

endmodule

`endif