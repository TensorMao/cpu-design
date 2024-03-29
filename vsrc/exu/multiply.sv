`ifndef __MULTIPLY_SV
`define __MULTIPLY_SV
`ifdef VERILATOR

`else

`endif
module multiply(
    input clk,
    input [63:0] x,
    input [63:0] y,
    input mult_valid,
    output logic mult_data_ok,
    output logic [63:0]mult_data

);
    logic mult_reg [127:0];
    logic [63:0] mier,micand,P_reg;//乘数,被乘数,乘积寄存器
    assign mier=mult_reg[63:0];
    assign P_reg=mult_reg[127:64];

    logic [64:0]add;
    assign add=P_reg+micand[63:0];
    logic [6:0] Cn;
    logic valid_reg;

    assign mult_data_ok = (Cn == 0); 
    assign mult_data = mult_data_ok?P_reg:0;

    
    
    always_ff@(posedge clk)begin :init
        if(!valid_reg&&mult_valid)begin
           mult_reg<={64'b0,x};
           micand<=y;
           Cn<=64;           
        end
         valid_reg<=mult_valid;
        

    end
    
    always_ff @(posedge clk) begin :mult
        if(mult_valid) begin
            mult_reg<={add[64:0],mier[63:1]};
            Cn<=Cn-1;
        end
    end
endmodule


`endif