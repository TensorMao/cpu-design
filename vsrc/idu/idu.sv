`ifndef __IDU_SV
`define __IDU_SV
`ifdef VERILATOR


`else

`endif
module idu(

    );
     decoder _decoder_(instr,ZF,PC_M,M2,M4,ALU_C,RF_W,DM_R,DM_W,skip,sext_num,rdc_t,rs1c,rs2c);
endmodule
`endif