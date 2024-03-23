`ifndef __SEXT_SV
`define __SEXT_SV
`ifdef VERILATOR

`else


`endif
module sext(
    input [31:0] instr,
    input [2:0] SEXT_M,
    input DM_W,
    output logic[63:0] sext_num
    );
        always_comb begin 
        case (SEXT_M)
            1: sext_num={{32{instr[31]}},instr[31:12],12'b0};//32
            2: sext_num={{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};//13
            3: sext_num={{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};//21
            4: sext_num=DM_W?{{52{instr[31]}},instr[31:25],instr[11:7]}:{{52{instr[31]}},instr[31:20]};//12
        endcase

        

    end

endmodule

`endif