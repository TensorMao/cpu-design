`ifndef __DECODER_SV
`define __DECODER_SV
`ifdef VERILATOR
`include "param.sv"

`else

`endif

module decoder(
   
    input [31:0] instr,
    input [2:0]ZF,
    output logic[1:0]PC_M,
    output logic[2:0]RD_M,
    output logic[1:0]ALUB_M, 
    output logic ALUA_M, 
    output logic BRsel,
    output logic[2:0] SEXT_M,
    output logic[`ALUOP_WIDTH-1:0]ALUop ,
    output logic RF_W,
    output logic DM_R,
    output logic DM_W,
    output logic skip,
    output logic [4:0]rdc,
    output logic [4:0]rs1c,
    output logic [4:0]rs2c,
    output logic sign,
    output logic[5:0]shamt,
    output logic [2:0] dreq_size,
    output logic muldivword
    );

    logic [5:0]func;    assign  func=instr[5:0];
    logic [6:0] op;     assign  op= instr[6:0];
    logic [2:0]func3;   assign func3=instr[14:12];
    logic [6:0]func7;   assign func7=instr[31:25];
    logic [5:0]func6;   assign func6=instr[31:26];
    assign shamt=instr[25:20];
    
    assign sign = blt|bge;

    logic R_type,add,sub,andu,oru,xoru;
    assign R_type= (op==7'b0110011);
    assign add= R_type && (func3==3'b000) && (func7==7'b0 );
    assign sub= R_type && (func3==3'b000)&&(func7==7'b0100000  );
    assign andu=R_type && (func3==3'b111)&&(func7==7'b0 );
    assign oru= R_type && (func3==3'b110)&&(func7==7'b0 );
    assign xoru=R_type && (func3==3'b100)&&(func7==7'b0 );
   
    logic I_type,xori,ori,andi,addi;
    assign I_type= (op==7'b0010011);
    assign xori= I_type && (func3 ==3'b100);
    assign ori=  I_type && (func3 ==3'b110);
    assign andi= I_type && (func3 ==3'b111);
    assign addi= I_type && (func3 ==3'b000);
    
    logic jal,jalr;
    assign jalr= (op==7'b1100111)&& (func3 ==3'b0);
    assign jal = (op==7'b1101111);

    logic beq,bne,blt,bge,bltu,bgeu,slt,sltu,slti,sltiu,sll,slli,srl,srli,sra,srai;
    assign beq =  (op==7'b1100011) && (func3==3'b000);
    assign bne =  (op==7'b1100011) && (func3==3'b001);
    assign blt =  (op==7'b1100011) && (func3==3'b100);
    assign bltu = (op==7'b1100011) && (func3==3'b110);
    assign bge =  (op==7'b1100011) && (func3==3'b101);
    assign bgeu = (op==7'b1100011) && (func3==3'b111);
    
    assign slt=   (op==7'b0110011) && (func3==3'b010) && (func7==7'b0);
    assign sltu=  (op==7'b0110011) && (func3==3'b011) && (func7==7'b0);
    assign slti=  (op==7'b0010011) && (func3 ==3'b010);
    assign sltiu=   (op==7'b0010011) && (func3==3'b011);
    assign sll= (op==7'b0110011) && (func3==3'b001)&&(func7==7'b0 );
    assign slli= (op==7'b0010011) && (func3==3'b001)&&(func6==6'b0);
    assign srl= (op==7'b0110011) && (func3==3'b101)&&(func7==7'b0 );
    assign srli= (op==7'b0010011) && (func3==3'b101)&&(func6==6'b0);
    assign sra=(op==7'b0110011)&&(func3==3'b101)&&(func7==7'b0100000);
    assign srai=(op==7'b0010011)&&(func3==3'b101)&&(func6==6'b010000);


    logic lui,auipc,ld,lb,lh,lw,lbu,lhu,lwu,sd,sb,sh,sw;
    assign lui= (op==7'b0110111 );
    assign auipc=(op==7'b0010111 );
    assign ld=(op==7'b0000011)&&(func3==3'b011);
    assign lb=(op==7'b0000011)&&(func3==3'b000);
    assign lh=(op==7'b0000011)&&(func3==3'b001);
    assign lw=(op==7'b0000011)&&(func3==3'b010);
    assign lbu=(op==7'b0000011)&&(func3==3'b100);
    assign lhu=(op==7'b0000011)&&(func3==3'b101);
    assign lwu=(op==7'b0000011)&&(func3==3'b110);
    assign sd=(op==7'b0100011)&&(func3==3'b011);
    assign sb=(op==7'b0100011)&&(func3==3'b000);
    assign sh=(op==7'b0100011)&&(func3==3'b001);
    assign sw=(op==7'b0100011)&&(func3==3'b010);
    //word
    logic addiw,addw,slliw,sllw,srliw, srlw,sraiw, sraw, subw;
    assign addiw=(op==7'b0011011)&&(func3==3'b0);
    assign addw=(op==7'b0111011)&&(func3==3'b0)&&(func7==7'b0);
    assign slliw=(op==7'b0011011)&&(func3==3'b001)&&(func6==6'b0);
    assign sllw=(op==7'b0111011)&&(func3==3'b001)&&(func7==7'b0);
    assign srliw=(op==7'b0011011)&&(func3==3'b101)&&(func6==6'b0);
    assign srlw=(op==7'b0111011)&&(func3==3'b101)&&(func7==7'b0);
    assign sraiw=(op==7'b0011011)&&(func3==3'b101)&&(func6==6'b010000);
    assign sraw=(op==7'b0111011)&&(func3==3'b101)&&(func7==7'b0100000);
    assign subw=(op==7'b0111011)&&(func3==3'b0)&&(func7==7'b0100000);

    //mutiple divide
    logic mul,div,divu,rem,remu,mulw,divw,divuw,remw,remuw;
    assign mul=(op==7'b0110011)&&(func3==3'b0)&&(func7==7'b0000001);
    assign mulw=(op==7'b0111011)&&(func3==3'b0)&&(func7==7'b0000001);
    assign div=(op==7'b0110011)&&(func3==3'b100)&&(func7==7'b0000001);
    assign divu=(op==7'b0110011)&&(func3==3'b101)&&(func7==7'b0000001);
    assign rem=(op==7'b0110011)&&(func3==3'b110)&&(func7==7'b0000001);
    assign remu=(op==7'b0110011)&&(func3==3'b111)&&(func7==7'b0000001);
    assign divw=(op==7'b0111011)&&(func3==3'b100)&&(func7==7'b0000001);
    assign divuw=(op==7'b0111011)&&(func3==3'b101)&&(func7==7'b0000001);
    assign remw=(op==7'b0111011)&&(func3==3'b110)&&(func7==7'b0000001);
    assign remuw=(op==7'b0111011)&&(func3==3'b111)&&(func7==7'b0000001);

    always_comb begin
        if(mulw|divw|divuw|remw|remuw)muldivword=1;
        else muldivword=0;
    end
   
    //Control 
    assign RF_W=add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc|slt|sltu|slti|sltiu|sll|slli|srl|srli|sra|srai|addiw|addw|slliw|sllw|srliw|srlw|sraiw|sraw|subw|div|divu|rem|remu|mul|mulw|divw|divuw|remw|remuw;
    assign DM_R=ld|lb|lh|lw|lbu|lhu|lwu;
    assign DM_W=sd|sb|sh|sw;
    assign skip=PC_M[0]||jalr;

    //rdc,rs1c,rs2c
    assign rdc= instr[11:7];
    assign rs1c=instr[19:15];
    assign rs2c=instr[24:20];

    always_comb begin :dreq_size_blk
        if(ld|sd) dreq_size=3'b011;
        else if(lw|sw) dreq_size=3'b010;
        else if(lwu) dreq_size=3'b110;
        else if(lh|sh) dreq_size=3'b001;
        else if(lhu) dreq_size=3'b101;
        else if(lb|sb) dreq_size=3'b000;
        else if(lbu) dreq_size=3'b100;
        else dreq_size=3'b011;
    end

    always_comb begin :ALUop_blk
        if(add|addi|sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu|auipc)  ALUop=0;//+
        else if(sub)                 ALUop=1;//-
        else if(andu|andi)           ALUop=2;//&
        else if(oru|ori)             ALUop=3;//|
        else if(xoru|xori)           ALUop=4;//^
        else if(slt|slti)            ALUop=5;//signed <
        else if(sltu|sltiu)          ALUop=6;//unsigned <
        else if(sll|slli)            ALUop=7;// <<
        else if(srl|srli)            ALUop=8;// >>
        else if(sra|srai)            ALUop=9;//>>>
        //word
        else if(addiw|addw)          ALUop=10;
        else if(subw)                ALUop=11;
        else if(slliw|sllw)          ALUop=12;
        else if(srliw|srlw)          ALUop=13;
        else if(sraiw|sraw)          ALUop=14;
        else if(mul|mulw)            ALUop=15;
        else if(div|divw)                 ALUop=16;
        else if(divu|divuw)                ALUop=17;
        else if(rem|remw)                 ALUop=18;
        else if(remu|remuw)                ALUop=19;
        else if(lui)                 ALUop=20;
        else if(jal|jalr)            ALUop=21;//pc+4
        else                         ALUop=0;
    end

    always_comb begin :SEXT_M_blk
        if(auipc|lui)                                               SEXT_M=1;//32
        else if(beq|bne|bge|blt|bltu|bgeu)                          SEXT_M=2;//13
        else if(jal)                                                SEXT_M=3;//21
        else if(addi|andi|ori|xori|jalr|sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu|slti|sltiu|addiw)     SEXT_M=4;//12
        else  SEXT_M=0;
    end

    always_comb begin :PC_M_blk
        if(jal||(beq&&ZF==0)||(bne&&ZF!=0)||(bge&&(ZF==1||ZF==0))||(blt&&ZF==3)||(bltu&&ZF==4)||(bgeu&&(ZF==2||ZF==0))) PC_M=1;
        else if(jalr) PC_M=2;
        else PC_M=0;
    end

    always_comb begin : ALUA_M_blk
        if(auipc) ALUA_M=1;
        else ALUA_M=0;
    end

    always_comb begin : ALUB_M_blk
       if(addi|andi|ori|xori|lui|sd|sb|sh|sw|ld|lb|lh|lw|lbu|lhu|lwu|addiw|sltiu|auipc|slti) ALUB_M=1;//imm
       else if(slli|srli|srai|slliw|srliw|sraiw) ALUB_M=2;//shamt
       else if(jal|jalr) ALUB_M=3;//pc
       else ALUB_M=0;       //rs2
    end

    always_comb begin : RD_M_blk
        if (ld|lb|lh|lw|lbu|lhu|lwu) RD_M=4;
        else if (div|divu|divw|divuw) RD_M=5;
        else if (rem|remu|remw|remuw) RD_M=6;
        else if (mul|mulw) RD_M=7;
        else RD_M=0;
    end

    always_comb begin : BRsel_blk
        if(jal) BRsel=0;
        else if(jalr)BRsel=1;
        else BRsel=0;
    end





endmodule

`endif