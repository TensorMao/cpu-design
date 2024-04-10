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
    output logic [63:0] sext_num_out,
    output logic [`ALUOP_WIDTH-1:0]ALUop_out,
    output logic [`ALUASEL_WIDTH-1:0] ALUAsel_out,
    output logic [`ALUBSEL_WIDTH-1:0] ALUBsel_out,
    output logic [`BRSEL_WIDTH-1:0]BRsel_out,
    output logic [`WBSEL_WIDTH-1:0]WBsel_out,
    output logic RFwe_out,
    output logic DMre_out,
    output logic DMwe_out,
    output logic DMwe_valid
    );
    //temp to do
    assign DMwe_valid=DMwe;
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

    assign ifu_valid= (state==s1);
    assign idu_valid= (state==s2);
    assign exu_valid= (state==s3);
    assign memu_valid=(state==s4);
    assign wb_valid=  (state==s5);
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
                if(ld|sd)nxt_state=s4;
                else nxt_state=s5;
            end
            else nxt_state=s3;
        end
        s4:begin
            if(memu_finish)begin
                if(sd)nxt_state=s1;
                else nxt_state=s5;
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

    logic R_type,I_type,B_type;
    assign R_type= (op==7'b0110011);
    assign I_type= (op==7'b0010011);
    assign B_type= (op==7'b1100011);

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

    logic ld,sd;
    assign ld=  (op==7'b0000011) && (func3==3'b011);
    assign sd=  (op==7'b0100011) && (func3==3'b011);

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

    //signal

    logic [`ALUOP_WIDTH-1:0] ALUop;
    logic [`SEXTSEL_WIDTH-1:0] SEXTsel;
    logic [63:0]sext_num;
    logic [`ALUASEL_WIDTH-1:0] ALUAsel;
    logic [`ALUBSEL_WIDTH-1:0] ALUBsel;
    logic [`BRSEL_WIDTH-1:0]BRsel;
    logic [`WBSEL_WIDTH-1:0]WBsel;
    logic RFwe,DMwe,DMre;
    assign rs1addr=instr[19:15];
    assign rs2addr=instr[24:20];

    assign RFwe = (add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc|ld|slt|sltu|slti|sltiu|sll|slli|srl|srli|sra|srai) ;
    assign DMwe_out = sd && (nxt_state == s4) && (state == s3);
    assign DMre_out = ld && (nxt_state == s4) && (state == s3);

    always_ff @( posedge clk ) begin : signal_blk
            ALUop_out       <=  ALUop;
            sext_num_out    <=  sext_num;
            ALUAsel_out     <=  ALUAsel;
            ALUBsel_out     <=  ALUBsel;
            BRsel_out       <=  BRsel;
            WBsel_out       <=  WBsel;
            RFwe_out        <=  RFwe && (nxt_state == s5);
            rdaddr          <=  instr[11:7];   
    end

    always_comb begin :ALUop_blk
        if(add|addi|auipc|jal|jalr|sd|ld)  ALUop=0;//A+B
        else if(sub)                 ALUop=1;//A-B
        else if(andu|andi)           ALUop=2;//A&B
        else if(oru|ori)             ALUop=3;//A|B
        else if(xoru|xori)           ALUop=4;//A^B
        else if(lui)                 ALUop=20;//B
        else if(slt|slti)            ALUop=5;//signed <
        else if(sltu|sltiu)          ALUop=6;//unsigned <
        else if(sll|slli)            ALUop=7;// <<
        else if(srl|srli)            ALUop=8;// >>
        else if(sra|srai)            ALUop=9;//>>>
        else                         ALUop=0; 
    end

    always_comb begin : ALUAsel_blk
        if(auipc) ALUAsel=1;//pc
        else ALUAsel=0;//rs1
    end

    always_comb begin : ALUBsel_blk
       if(addi|andi|ori|xori|lui|auipc|sd|ld|slti|sltiu) ALUBsel=1;//imm
       else if(slli|srli|srai) ALUBsel=2;//shamt
       else if(jal|jalr)ALUBsel=3;//4
       else ALUBsel=0;       //rs2
    end

    always_comb begin :SEXTsel_blk
        if(auipc|lui)                                               SEXTsel=1;//32
        else if(beq|bne|bge|blt|bltu|bgeu)                          SEXTsel=2;//13
        else if(jal)                                                SEXTsel=3;//21
       // else if(addi|andi|ori|xori|jalr|sd|ld|slti|sltiu|addiw)     SEXTsel=4;12
        else if(addi|andi|ori|xori|jalr|ld|slti|sltiu)              SEXTsel=4;//12
        else if(sd)                                                 SEXTsel=5;//sd
        else  SEXTsel=0;
    end

    always_comb begin :SEXT_blk
        case (SEXTsel)
            1: sext_num={{32{instr[31]}},instr[31:12],12'b0};//32
            2: sext_num={{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};//13
            3: sext_num={{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};//21
            //4: sext_num=DM_W?{{52{instr[31]}},instr[31:25],instr[11:7]}:{{52{instr[31]}},instr[31:20]};//12
            4: sext_num={{52{instr[31]}},instr[31:20]};
            5: sext_num={{52{instr[31]}},instr[31:25],instr[11:7]};
        endcase
    end

    always_comb begin : BRsel_blk
        if(jal) BRsel=1;
        else if(jalr)BRsel=2;
        else BRsel=0;
    end

    always_comb begin : WBsel_blk
        if (ld) WBsel=4;
        else WBsel=0;
    end







    

    










    
endmodule


`endif