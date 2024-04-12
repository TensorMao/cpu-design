`ifndef __DIVIDE_SV
`define __DIVIDE_SV
`ifdef VERILATOR

`else

`endif
module divide(
    input clk,
    input rst,
    input sign,
    input muldivword,
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
    logic [63:0]quotient,divisor,minus,remainder_num_sign,remainder_num_unsign;
    assign quotient=remainder[63:0];
    assign minus= remainder[127:64]-divisor;
    assign remainder_num_sign={remainder[127],remainder[127:65]};
    assign remainder_num_unsign={1'b0,remainder[127:65]};
    logic [7:0] Cn;
    logic sign_reg, compare,compare_t,right_sign,x_sign,isword;
    logic[63:0] x_t,y_t;


    always_comb begin 
        if(sign)begin
            if(muldivword)begin
                x_t=(x[31]==1)?(~{x[31:0],32'b0}+1):{x[31:0],32'b0};
                y_t=(y[31]==1)?(~{y[31:0],32'b0}+1):{y[31:0],32'b0};
            end
            else begin
            x_t=(x[63]==1)?(~x+1):x;
            y_t=(y[63]==1)?(~y+1):y;

            end
            compare_t=(x_t<y_t);
        end
        else begin
            if(muldivword)begin
                x_t ={x[31:0],32'b0};
                y_t={y[31:0],32'b0};
            end
            else begin
                x_t = x;
                y_t = y;
            end
           
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
                    isword<=0;
                    if(div_valid)begin
                        remainder<={63'b0,x_t,1'b0};
                        divisor<=y_t;
                        sign_reg<=sign;
                        x_sign<=muldivword?(x[31]&&sign):(x[63]&&sign);
                        right_sign<= muldivword?(x[31]^y[31]):(x[63]^y[63]);
                        isword<=muldivword;
                        Cn<=64; 
                        compare <=compare_t;
                        state<=EXECUTE;      
                    end
                end
                EXECUTE:begin
                    if(Cn==0)begin
                        div_data_ok<=1;
                        if(sign_reg)begin
                                if(isword)begin
                                    div_data<={{32{{right_sign?(~quotient+1):quotient}[31]}},{right_sign?(~quotient+1):quotient}[31:0]};
                                    rem_data<={{32{{x_sign?(~remainder_num_sign+1):remainder_num_sign}[63]}},{x_sign?(~remainder_num_sign+1):remainder_num_sign}[63:32]};
                                end
                                else begin
                                    div_data<=right_sign?(~quotient+1):quotient;
                                    rem_data<=x_sign?(~remainder_num_sign+1):remainder_num_sign;
                                end

                        end
                        else begin
                            if(isword)begin
                                div_data<={{32{quotient[31]}},quotient[31:0]};
                                rem_data<={{32'b0},remainder_num_unsign[63:32]};
                            end
                            else begin
                                div_data<=quotient;
                                rem_data<=remainder_num_unsign ;
                            end
                           
                        end
                        state<=IDLE;
                    end
                    else begin
                        if (divisor==0)begin//divide 0
                            div_data_ok<=1;
                            div_data<=64'hffffffffffffffff;
                            if(isword)begin
                                if(x_sign)rem_data<={{32{{~remainder+1}[64]}},{~remainder+1}[33+:32]};
                                else rem_data<={{32{remainder[64]}},remainder[33+:32]};
                            end
                            else begin
                                if(x_sign)rem_data<=~remainder[64:1]+1;
                                else rem_data<=remainder[64:1];
                            end
                            state<=IDLE;
                        end
                        else if(compare)begin
                            div_data_ok<=1;
                            div_data<=0;
                           if(isword)begin
                                if(x_sign)rem_data<={{32{{~remainder+1}[64]}},{~remainder+1}[33+:32]};
                                else rem_data<={{32{remainder[64]}},remainder[33+:32]};

                            end
                            else begin
                                if(x_sign)rem_data<=~remainder[64:1]+1;
                                else rem_data<=remainder[64:1];
                            end
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