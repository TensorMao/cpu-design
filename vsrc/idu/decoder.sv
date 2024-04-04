`ifndef __DECODER_SV
`define __DECODER_SV
`ifdef VERILATOR

`else

`endif

module decoder(
   
    input [31:0] instr,
    input [2:0]ZF,
    output logic[1:0]PC_M,
    output logic[2:0]RD_M,
    output logic[1:0]ALUB_M, 
    output logic[2:0] SEXT_M,
    output logic[3:0]ALU_C,
    output logic RF_W,
    output logic DM_R,
    output logic DM_W,
    output logic skip,
    output logic [4:0]rdc,
    output logic [4:0]rs1c,
    output logic [4:0]rs2c,
    output logic sign,
    output logic[5:0]shamt
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
    assign sub= R_type && (func3==3'b000)&&(func7==7'b0100000);
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

    //U type
    logic lui,auipc,ld,sd;
    assign lui= (op==7'b0110111 );
    assign auipc=(op==7'b0010111 );
    assign ld=(op==7'b0000011)&&(func3==3'b011);
    assign sd=(op==7'b0100011)&&(func3==3'b011);
    
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
    logic mul,div,divu,rem,remu;
    assign mul=(op==7'b0110011)&&(func3==3'b0)&&(func7==7'b0000001);
    assign div=(op==7'b0110011)&&(func3==3'b100)&&(func7==7'b0000001);
    assign divu=(op==7'b0110011)&&(func3==3'b101)&&(func7==7'b0000001);
    assign rem=(op==7'b0110011)&&(func3==3'b110)&&(func7==7'b0000001);
    assign remu=(op==7'b0110011)&&(func3==3'b111)&&(func7==7'b0000001);

    //Control 
    assign RF_W=add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc|slt|sltu|slti|sltiu|sll|slli|srl|srli|sra|srai|addiw|addw|slliw|sllw|srliw|srlw|sraiw|sraw|subw|mul|div|divu|rem|remu;
    assign DM_R=ld;
    assign DM_W=sd;
    assign skip=PC_M[0]||jalr;

    //rdc,rs1c,rs2c
    assign rdc= instr[11:7];
    assign rs1c=instr[19:15];
    assign rs2c=instr[24:20];

    always_comb begin :ALU_C_blk
        if(add|addi|jalr|sd|ld)  ALU_C=0;//+
        else if(sub)                 ALU_C=1;//-
        else if(andu|andi)           ALU_C=2;//&
        else if(oru|ori)             ALU_C=3;//|
        else if(xoru|xori)           ALU_C=4;//^
        else if(slt|slti)            ALU_C=5;//signed <
        else if(sltu|sltiu)          ALU_C=6;//unsigned <
        else if(sll|slli)            ALU_C=7;// <<
        else if(srl|srli)            ALU_C=8;// >>
        else if(sra|srai)            ALU_C=9;//>>>
        //word
        else if(addiw|addw)          ALU_C=10;
        else if(subw)                ALU_C=11;
        else if(slliw|sllw)          ALU_C=12;
        else if(srliw|srlw)          ALU_C=13;
        else if(sraiw|sraw)          ALU_C=14;
        else if(mul)                 ALU_C=15;
        else                         ALU_C=0;
    end

    always_comb begin :SEXT_M_blk
        if(auipc|lui)                                               SEXT_M=1;//32
        else if(beq|bne|bge|blt|bltu|bgeu)                          SEXT_M=2;//13
        else if(jal)                                                SEXT_M=3;//21
        else if(addi|andi|ori|xori|jalr|sd|ld|slti|sltiu|addiw)     SEXT_M=4;//12
        else  SEXT_M=0;
    end

    always_comb begin :PC_M_blk
        if(jal||(beq&&ZF==0)||(bne&&ZF!=0)||(bge&&(ZF==1||ZF==0))||(blt&&ZF==3)||(bltu&&ZF==4)||(bgeu&&(ZF==2||ZF==0))) PC_M=1;
        else if(jalr) PC_M=2;
        else PC_M=0;
    end

    always_comb begin : ALUB_M_blk
       if(addi|andi|ori|xori|jalr|sd|ld|addiw|sltiu) ALUB_M=1;//imm
       else if(slli|srli|srai|slliw|srliw|sraiw) ALUB_M=2;//shamt
       else ALUB_M=0;       //rs2
    end

    always_comb begin : RD_M_blk
        if(jal|jalr) RD_M=1;
        else if(lui) RD_M=2;
        else if(auipc) RD_M=3;
        else if (ld) RD_M=4;
        else RD_M=0;
    end





endmodule

`endif