`ifndef __BR_SV
`define __BR_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif
module br(
    input clk,
    input trigger,
    input [`BRSEL_WIDTH-1:0] BRsel,
    input [63:0]A,
    input [63:0] pc,
    input [63:0] sext_num,
    output logic [63:0] br_out,
    output logic redirect_valid,
    output logic br_data_ok
);
    always_comb begin
        case(BRsel)
        1:br_out=pc + sext_num;
        2:br_out={{(A + sext_num)}[63:1], 1'b0};
        default:br_out=pc+4;
        endcase
      //  br_data_ok=1;
    end

    always_comb begin:redirect_valid_blk
        case(BRsel)
        0:redirect_valid=0;
        default:redirect_valid=1;
        endcase
    end

    always_ff @( posedge clk ) begin
        if(trigger)br_data_ok<=1;
        else br_data_ok<=0;
        
    end
      
endmodule
`endif