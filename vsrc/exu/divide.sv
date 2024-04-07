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
        EXECUTE,
        IDLE    
    } div_state;
    div_state state;
    logic  [127:0]remainder;
    logic [63:0]quotient,divisor,minus;
    assign quotient=remainder[63:0];
    assign minus= remainder[127:64]-divisor;
    logic [7:0] Cn;
    logic sign_reg, compare,compare_t,right_sign,x_sign;
    logic[63:0] x_t,y_t;

    always_comb begin 
        if(sign)begin
            x_t=(x[63]==1)?(~x+1):x;
            y_t=(y[63]==1)?(~y+1):y;
            compare_t=(x_t<y_t);
        end
        else begin
            x_t = x;
            y_t = y;
            compare_t=($unsigned(x_t)<$unsigned(y_t));
        end
    end

    always_ff@(posedge clk,posedge rst)begin
        if(rst)state<=IDLE;
        else begin
            case(state)
                IDLE:begin
                    remainder<=0;
                    div_data_ok<=0;
                    div_data<=0;
                    rem_data<=0;
                    compare<=0;
                    sign_reg<=0;
                    right_sign<=0;
                    if(div_valid)begin
                        remainder<={63'b0,x_t,1'b0};
                        divisor<=y_t;
                        sign_reg<=sign;
                        x_sign<=x[63]&&sign;
                        right_sign<= x[63]^y[63];
                        Cn<=64; 
                        compare <=compare_t;
                        state<=EXECUTE;      
                    end
                end
                EXECUTE:begin
                    if(Cn==0)begin
                        div_data_ok<=1;
                        if(sign_reg)begin
                           div_data<=right_sign?(~quotient+1):quotient;
                           rem_data<=x_sign?(~{remainder[127],remainder[127:65]}+1):{remainder[127],remainder[127:65]};
                        end
                        else begin
                            div_data<=quotient;
                           rem_data<={remainder[127],remainder[127:65]};
                        end
                        state<=IDLE;
                    end
                    else begin
                        if (divisor==0)begin//divide 0
                            div_data_ok<=1;
                            div_data<=64'hffffffffffffffff;
                           if(x_sign)rem_data<=~remainder[64:1]+1;
                            else rem_data<=remainder[64:1];
                            state<=IDLE;
                        end
                        else if(compare)begin
                            div_data_ok<=1;
                            div_data<=0;
                           if(x_sign)rem_data<=~remainder[64:1]+1;
                            else rem_data<=remainder[64:1];
                            state<=IDLE;
                        end
                        else begin
                                if($unsigned(remainder[127:64])<$unsigned(divisor))remainder <= remainder<<1;
                                else remainder<={{minus,remainder[63:0]}[126:0],1'b1};
                            Cn<=Cn-1;  
                            
                        end
                    end

                end
            endcase

        end
        
    end

endmodule


`endif