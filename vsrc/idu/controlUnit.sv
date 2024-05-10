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
    input ifu_finish,
    input exu_finish,
    input memu_finish,
    output logic ifu_valid,
    output logic idu_valid,
    output logic exu_valid,
    output logic memu_valid,
    output logic wb_valid,
    output logic [4:0]rs1addr,
    output logic [4:0]rs2addr,
    output logic [4:0]rdaddr,
    output logic [11:0]csraddr,
    output logic [63:0] sext_num,
    output logic [`ALUOP_WIDTH]ALUop,
    output logic [`ALUASEL_WIDTH] ALUAsel,
    output logic [`ALUBSEL_WIDTH] ALUBsel,
    output logic [`BRSEL_WIDTH]BRsel,
    output logic [`WBSEL_WIDTH]WBsel,
    output logic RFwe,
    output logic DMre,
    output logic DMwe,
    output logic [2:0] dreq_info
    );
    //state
     typedef enum { 
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
    end

    //instr
    logic [6:0] op,func7; logic [5:0]func6; logic [2:0]func3;     
    assign op=instr[6:0]; 
    assign func3=instr[14:12]; 
    assign func7=instr[31:25]; 
    assign func6=instr[31:26];

    logic R_type,I_type,B_type,R_type64,I_type64,I_typeload,S_type,CSR_type;
    assign R_type=      (op==7'b0110011);
    assign I_type=      (op==7'b0010011);
    assign B_type=      (op==7'b1100011);
    assign R_type64=    (op==7'b0111011);
    assign I_type64=    (op==7'b0011011);
    assign I_typeload=  (op==7'b0000011);
    assign S_type=      (op==7'b0100011);
    assign CSR_type=    (op==7'b1110011);

    logic add,sub,andu,oru,xoru,xori,ori,andi,addi,jal,jalr,lui,auipc;
    assign add= R_type && (func3==3'b000) && (func7==7'b0 );
    assign sub= R_type && (func3==3'b000) && (func7==7'b0100000);
    assign andu=R_type && (func3==3'b111) && (func7==7'b0);
    assign oru= R_type && (func3==3'b110) && (func7==7'b0);
    assign xoru=R_type && (func3==3'b100) && (func7==7'b0);
   
    
    assign xori= I_type && (func3 ==3'b100);
    assign ori=  I_type && (func3 ==3'b110);
    assign andi= I_type && (func3 ==3'b111);
    assign addi= I_type && (func3 ==3'b000);

        
    assign jalr= (op==7'b1100111) && (func3 ==3'b0);
    assign jal=  (op==7'b1101111);
    assign lui=  (op==7'b0110111);
    assign auipc=(op==7'b0010111);

    logic ld,sd,lb,lh,lw,lbu,lhu,lwu,sb,sh,sw;;
    assign ld=  I_typeload && (func3==3'b011);
    assign lb=  I_typeload && (func3==3'b000);
    assign lh=  I_typeload && (func3==3'b001);
    assign lw=  I_typeload && (func3==3'b010);
    assign lbu= I_typeload && (func3==3'b100);
    assign lhu= I_typeload && (func3==3'b101);
    assign lwu= I_typeload && (func3==3'b110);
    assign sb=  S_type && (func3==3'b000);
    assign sh=  S_type && (func3==3'b001);
    assign sw=  S_type && (func3==3'b010);
    assign sd=  S_type && (func3==3'b011);

    logic beq,bne,blt,bge,bltu,bgeu,slt,sltu,slti,sltiu,sll,slli,srl,srli,sra,srai;
    assign beq =  B_type && (func3==3'b000);
    assign bne =  B_type && (func3==3'b001);
    assign blt =  B_type && (func3==3'b100);
    assign bltu = B_type && (func3==3'b110);
    assign bge =  B_type && (func3==3'b101);
    assign bgeu = B_type && (func3==3'b111);
    
    assign slt= R_type && (func3==3'b010) && (func7==7'b0);
    assign sltu=R_type && (func3==3'b011) && (func7==7'b0);
    assign sll= R_type && (func3==3'b001) && (func7==7'b0);
    assign srl= R_type && (func3==3'b101) && (func7==7'b0);
    assign sra= R_type && (func3==3'b101) && (func7==7'b0100000);

    assign slti=    I_type && (func3==3'b010);
    assign sltiu=   I_type && (func3==3'b011);
    assign slli=    I_type && (func3==3'b001) && (func6==6'b0);
    assign srli=    I_type && (func3==3'b101) && (func6==6'b0);
    assign srai=    I_type && (func3==3'b101) && (func6==6'b010000);

    logic addiw,addw,slliw,sllw,srliw,srlw,sraiw,sraw,subw;
    assign addw=    R_type64 && (func3==3'b000) && (func7==7'b0);
    assign sllw=    R_type64 && (func3==3'b001) && (func7==7'b0);
    assign srlw=    R_type64 && (func3==3'b101) && (func7==7'b0);
    assign sraw=    R_type64 && (func3==3'b101) && (func7==7'b0100000);
    assign subw=    R_type64 && (func3==3'b000) && (func7==7'b0100000);

    assign addiw=   I_type64 && (func3==3'b0);
    assign slliw=   I_type64 && (func3==3'b001) && (func6==6'b0);
    assign srliw=   I_type64 && (func3==3'b101) && (func6==6'b0);
    assign sraiw=   I_type64 && (func3==3'b101) && (func6==6'b010000);

    /*--multiply and divide--*/
    logic mul,div,divu,rem,remu,mulw,divw,divuw,remw,remuw;
    assign mul=     R_type && (func3==3'b000) && (func7==7'b0000001);
    assign div=     R_type && (func3==3'b100) && (func7==7'b0000001);
    assign divu=    R_type && (func3==3'b101) && (func7==7'b0000001);
    assign rem=     R_type && (func3==3'b110) && (func7==7'b0000001);
    assign remu=    R_type && (func3==3'b111) && (func7==7'b0000001);

    assign mulw=    R_type64 && (func3==3'b000) && (func7==7'b0000001);
    assign divw=    R_type64 && (func3==3'b100) && (func7==7'b0000001);
    assign divuw=   R_type64 && (func3==3'b101) && (func7==7'b0000001);
    assign remw=    R_type64 && (func3==3'b110) && (func7==7'b0000001);
    assign remuw=   R_type64 && (func3==3'b111) && (func7==7'b0000001);

    /*--csr--*/
    //assign csrrw=   CSR_type && (func3==3'b001);

    

    //signal

    logic [`SEXTSEL_WIDTH] SEXTsel;
    assign rs1addr=instr[19:15];
    assign rs2addr=instr[24:20];
    assign rdaddr=instr[11:7];
    //assign shamt=instr[25:20];

    assign RFwe = !(sd|sb|sh|sw|beq|bne|blt|bge|bltu|bgeu) && wb_valid;
    assign DMwe = (sd|sb|sh|sw) && memu_valid;
    assign DMre = (ld|lb|lh|lw|lbu|lhu|lwu) && memu_valid;


    always_comb begin :ALUop_blk
        if(add|addi|auipc|jal|jalr|sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu)  ALUop=0;//A+B
        else if(sub)                 ALUop=1;//A-B
        else if(andu|andi)           ALUop=2;//A&B
        else if(oru|ori)             ALUop=3;//A|B
        else if(xoru|xori)           ALUop=4;//A^B
        else if(lui)                 ALUop=31;//B
        else if(slt|slti)            ALUop=5;//signed <
        else if(sltu|sltiu)          ALUop=6;//unsigned <
        else if(sll|slli)            ALUop=7;// <<
        else if(srl|srli)            ALUop=8;// >>
        else if(sra|srai)            ALUop=9;//>>>
        else if(addiw|addw)          ALUop=10;
        else if(subw)                ALUop=11;
        else if(slliw|sllw)          ALUop=12;
        else if(srliw|srlw)          ALUop=13;
        else if(sraiw|sraw)          ALUop=14;
        else if(mul)                 ALUop=15;
        else if(mulw)                ALUop=16;
        else if(divw)                ALUop=17;
        else if(remw)                ALUop=18;
        else if(divuw)               ALUop=19;
        else if(remuw)               ALUop=20;
        else if(divu)                ALUop=21;
        else if(remu)                ALUop=22;
        else if(div)                 ALUop=23;
        else if(rem)                 ALUop=24;
        
        
        else                         ALUop=0; 
    end

    always_comb begin : ALUAsel_blk
        if(auipc|jal|jalr) ALUAsel=1;//pc
        else ALUAsel=0;//rs1
    end

    always_comb begin : ALUBsel_blk
       if(addi|andi|ori|xori|lui|auipc|sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu|slti|sltiu|addiw|slli|srli|srai|slliw|srliw|sraiw) ALUBsel=1;//imm
       else if(jal|jalr)ALUBsel=3;//4
       else ALUBsel=0;       //rs2
    end

    always_comb begin :SEXTsel_blk
        if(auipc|lui)                                               SEXTsel=1;//32
        else if(beq|bne|bge|blt|bltu|bgeu)                          SEXTsel=2;//13
        else if(jal)                                                SEXTsel=3;//21
        else if(addi|andi|ori|xori|jalr|ld|lb|lh|lw|lbu|lhu|lwu|slti|sltiu|addiw)                                                      SEXTsel=4;//12
        else if(sd|sb|sh|sw)                                        SEXTsel=5;//sd
        else if(slli|srli|srai|slliw|srliw|sraiw)                   SEXTsel=6;//shamt
        else  SEXTsel=0;
    end

    always_comb begin :SEXT_blk
        case (SEXTsel)
            1: sext_num={{32{instr[31]}},instr[31:12],12'b0};//32
            2: sext_num={{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};//13
            3: sext_num={{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};//21
            4: sext_num={{52{instr[31]}},instr[31:20]};//12
            5: sext_num={{52{instr[31]}},instr[31:25],instr[11:7]};//sd
            6: sext_num={58'b0,instr[25:20]};//shamt
        endcase
    end

    always_comb begin : BRsel_blk
        if(jal)         BRsel=1;
        else if(jalr)   BRsel=2;
        else if(beq)    BRsel=3;
        else if(bne)    BRsel=4;
        else if(blt)    BRsel=5;
        else if(bge)    BRsel=6;
        else if(bltu)   BRsel=7;
        else if(bgeu)   BRsel=8;
        else BRsel=0;
    end

    always_comb begin : WBsel_blk
        if (ld|lb|lh|lw|lbu|lhu|lwu) WBsel=4;
        else if(div|divu|divw|divuw) WBsel=5;
        else if(remw|remuw|rem|remu) WBsel=6;
        else if( mul|mulw)WBsel=7;
        else WBsel=0;
    end

      always_comb begin :dreq_info_blk
        if(ld|sd)       dreq_info=3'b011;
        else if(lw|sw)  dreq_info=3'b010;
        else if(lwu)    dreq_info=3'b110;
        else if(lh|sh)  dreq_info=3'b001;
        else if(lhu)    dreq_info=3'b101;
        else if(lb|sb)  dreq_info=3'b000;
        else if(lbu)    dreq_info=3'b100;
        else dreq_info=3'b011;
    end







    

    










    
endmodule


`endif