`ifndef __MULTIPLY_SV
`define __MULTIPLY_SV
`ifdef VERILATOR

`else

`endif
module multiply(
    input clk,
    input rst,
    input muldivword,
    input mult_valid,
    input [63:0] x,
    input [63:0] y,
    output logic mult_data_ok,
    output logic [63:0]mult_data

);
     typedef enum {
        EXECUTE,
        IDLE    
    } mul_state;
    mul_state state;
    logic  [128:0] mult_reg;
    logic [63:0] mier,micand,P_reg;//乘数,被乘数,乘积寄存器
    assign mier=mult_reg[63:0];
    assign P_reg=mult_reg[127:64];

    logic [64:0]plus;
    assign plus=P_reg+micand[63:0];
    logic [7:0] Cn;
    logic isword;
   /* logic valid_reg;

    assign mult_data_ok = (Cn == 0); 
    assign mult_data = mult_data_ok?P_reg:0;*/

    
    
    always_ff@(posedge clk,posedge rst)begin
        if(rst)state<=IDLE;
        else begin
            case(state)
                IDLE:begin
                    mult_data_ok<=0;
                    mult_data<=0;
                    isword<=0;
                    if(mult_valid)begin
                        mult_reg<={65'b0,x};
                        micand<=y;
                        Cn<=64;
                        isword<=muldivword;
                        state<=EXECUTE;
                    end
                end
                EXECUTE:begin
                    if(Cn==0)begin
                        mult_data_ok<=1;
                        mult_data<=isword?{{32{mult_reg[31]}},mult_reg[31:0]}:mult_reg[63:0];
                        state<=IDLE;
                    end
                    else begin           
                        mult_reg<=mult_reg[0]?({1'b0,plus[64:0],mier[63:1]}):({1'b0,mult_reg[128:1]});
                        Cn<=Cn-1;
                    end
                end
            endcase
        end
        

    end
    
endmodule


`endif