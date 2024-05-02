`ifndef __CONTROLUNIT_SV
`define __CONTROLUNIT_SV
`ifdef VERILATOR
`include "param.sv"
`else

`endif

module controlUnit(
    input clk,
    input rst,
    input [31:0] instr,
   /* input ifu_finish,
    input exu_finish,
    input memu_finish,
    output logic ifu_valid,
    output logic idu_valid,
    output logic exu_valid,
    output logic memu_valid,
    output logic wb_valid,*/
    /* ----- stall request from other modules -----*/
    input  stallreq_from_ifu,
    input  stallreq_from_idu,
    input  stallreq_from_exu,
    input  stallreq_from_memu,
    output logic[5:0]   stall

    );
    //state
/* typedef enum { 
        s0,
        s1, //ifetch
        s2, //decode
        s3, //execute
        s4, //memrw
        s5  //writeback
    } state_t;
    state_t state,nxt_state;

    assign ifu_valid= (state!=s1 && nxt_state==s1);
    assign idu_valid= (state!=s2 && nxt_state==s2);
    assign exu_valid= (state!=s3 && nxt_state==s3);
    assign memu_valid=(state!=s4 && nxt_state==s4);
    assign wb_valid=  (state!=s5 && nxt_state==s5);
    always_ff @( posedge clk ) begin
        if(rst) state<=s1;
        else state <= nxt_state;  
    end

    always_comb begin : state_change
        case(state)
        s0: nxt_state=s1;
        s1:begin
            if(ifu_finish) nxt_state=s2;
            else nxt_state=s1;
        end
        s2:begin
            nxt_state=s3;
        end
        s3:begin 
            if(exu_finish) begin
                if(sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu)nxt_state=s4;
                else nxt_state=s5;
            end
            else nxt_state=s3;
        end
        s4:begin
            if(memu_finish)begin
                nxt_state=s5;
            end
            else nxt_state=s4;
        end
        s5:begin
            nxt_state=s1;
        end
        endcase
end*/
    always_comb begin
        if(rst) begin
            stall = 6'b000000;
        // stall request from wbu: 
        // need to stop the ifu(0), IF_ID(1), ID_EXE(2), EXE_MEM(3), MEM_WB(4)
        end else if(stallreq_from_memu) begin
            stall = 6'b011111;
        // stall request from exu: 
        // stop the PC,IF_ID, ID_EXE, EXE_MEM
        end else if(stallreq_from_exu) begin
            stall = 6'b001111;
		// stall request from id: 
        // stop PC,IF_ID, ID_EXE
        end else if(stallreq_from_idu) begin
            stall = 6'b000111;
		// stall request from if: 
        // stop the PC,IF_ID, ID_EXE
        end else if(stallreq_from_ifu) begin
            stall = 6'b000111;
        end else begin
            stall = 6'b000000;
        end 
    end 

    
endmodule


`endif