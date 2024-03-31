`ifndef __DIVIDE_SV
`define __DIVIDE_SV
`ifdef VERILATOR

`else

`endif
module divide(
    input clk,
    input rst,
    input sign,
    input div_valid,
    input [63:0] x,
    input [63:0] y, 
    output logic div_data_ok,
    output logic [63:0]div_data,
    output logic [63:0] rem_data
);
    typedef enum {
        EXECUTE=1'b0,
        IDLE=1'b1    
    } div_state;
    div_state state;
    logic  [127:0]remainder;
    logic [63:0]quotient,divisor,minus,plus,temp;
    assign quotient=remainder[63:0];
    assign minus=remainder[127:64]-divisor;
    assign plus=remainder[127:64]+divisor;
    assign temp={remainder[127]==divisor[63]}?minus:plus;
    logic Cn;
    logic sign_reg;

    always_ff@(posedge clk,posedge rst)begin
        if(rst)state<=IDLE;
        else begin
            case(state)
                IDLE:begin
                    if(div_valid)begin
                        remainder<=sign?{{{64{x[63]}},x}<<1}:{64'b0,x};
                        divisor<=y;
                        sign_reg<=sign;
                        Cn<=65;       
                    end
                end
                EXECUTE:begin
                    if(Cn==0)begin
                        div_data_ok<=1;
                        div_data<=(sign_reg&&quotient[31]==1)?(~quotient+1):quotient;
                        rem_data<=remainder[127:64]>>1;
                        state<=IDLE;
                    end
                    else begin
                        if (divisor==0)begin//divide 0
                            div_data_ok<=1;
                            div_data<=64'bffffffffffffffff;
                            rem_data<=x;   
                            state<=IDLE;
                        end
                        else begin
                            if(sign_reg)begin//signed
                                if(temp==0||temp[63]==remainder[63])remainder<={{{temp,remainder[63:0]}<<1},1'b1};
                                else  remainder<=remainder<<1;                               
                            end
                            else begin//unsigned
                                if(minus[63]==1)remainder<=remainder<<1;
                                else remainder<={{{minus,remainder[63:0]}<<1},1'b1};
                                Cn<=Cn-1;  
                            end

                            
                        end
                    end

                end
            endcase

        end
        
    end
    always_ff

endmodule


`endif