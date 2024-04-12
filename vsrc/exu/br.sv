`ifndef __BR_SV
`define __BR_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif
module br(
    input clk,
    input exu_valid,
    input [`BRSEL_WIDTH-1:0] BRsel,
    input [63:0]rs1,
    input [63:0]rs2,
    input [63:0] pc,
    input [63:0] sext_num,
    output logic [63:0] br_out,
    output logic redirect_valid,
    output logic br_data_ok
);
    always_comb begin
        case(BRsel)
        1,3,4,5,6,7,8:br_out=pc + sext_num;
        2:br_out={{(rs1 + sext_num)}[63:1], 1'b0};
        default:br_out=pc+4;
        endcase
      //  br_data_ok=1;
    end

    always_comb begin:redirect_valid_blk
        case(BRsel)
        0:redirect_valid = 0;
        3:redirect_valid = rs1==rs2;//beq
        4:redirect_valid = rs1!=rs2;//bne
        5:redirect_valid = $signed(rs1)<$signed(rs2);//blt
        6:redirect_valid = $signed(rs1)>=$signed(rs2);//bge
        7:redirect_valid = $unsigned(rs1)<$unsigned(rs2);//bltu
        8:redirect_valid =  $unsigned(rs1)>=$unsigned(rs2);//bgeu
        default:redirect_valid = 1;
        endcase
    end

    always_ff @( posedge clk ) begin
        if(exu_valid)br_data_ok<=1;
        else br_data_ok<=0;
        
    end
      
endmodule
`endif