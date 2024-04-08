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
    output logic ifu_valid,
    output logic idu_valid,
    output logic exu_valid,
    //output memu_valid,
    output wb_valid,
    output logic [4:0]rs1addr,
    output logic [4:0]rs2addr,
    output logic [4:0]rdaddr,
    output logic [63:0] sext_num_out,
    output logic [`ALUOP_WIDTH-1:0]ALUop_out,
    output logic [`ALUASEL_WIDTH-1:0] ALUAsel_out,
    output logic [`ALUBSEL_WIDTH-1:0] ALUBsel_out,
    output logic [`BRSEL_WIDTH-1:0]BRsel_out,
    output logic [`WBSEL_WIDTH-1:0]WBsel_out,
    output logic RFwe_out
    
    );

    //state
     typedef enum { 
        s1, //ifetch
        s2, //decode
        s3, //execute
        s4, //memrw
        s5, //writeback
    } state_t;
    state_t state,nxt_state;

    assign ifu_valid=(state==s1);
    assign idu_valid=(state==s2);
    assign exu_valid=(state==s3);
   // assign memu_valid=(state==s4);
    assign wb_valid=(state==s5);
    always_ff @( posedge clk ) begin
        if(rst) state<=s1;
        else state <= nxt_state;  
    end

    always_comb begin : state_change
        case(state)
        s1:begin
            if(ifu_finish) nxt_state=s2;
            else nxt_state=s1;
        end
        s2:begin
            nxt_state=s3;
        end
        s3:begin
            if(exu_finish) nxt_state=s5;
        end
        s5:begin
            nxt_state=s1;
        end
        endcase
    end

    //instr
    logic [6:0] op,func7; logic [5:0]func6; logic [2:0]func3;     
    logic R_type,I_type;
    logic add,sub,andu,oru,xoru;
    logic xori,ori,andi,addi;
    logic jal,jalr;
    logic lui,auipc;
    always_comb begin : instr_decode
        op=instr[6:0]; 
        func3=instr[14:12]; 
        func7=instr[31:25]; 
        func6=instr[31:26];

        R_type= (op==7'b0110011); 
        I_type= (op==7'b0010011);

        if(R_type)begin
            add=(func3==3'b000) && (func7==7'b0 );
            sub=(func3==3'b000)&&(func7==7'b0100000);
            xoru=(func3==3'b100)&&(func7==7'b0 );
            oru= (func3==3'b110)&&(func7==7'b0 );
            andu=(func3==3'b111)&&(func7==7'b0 );
        end

        if(I_type)begin
            addi=(func3 ==3'b000);
            xori= (func3 ==3'b100);
            ori= (func3 ==3'b110);
            andi= (func3 ==3'b111);
        end
        jalr= (op==7'b1100111)&& (func3 ==3'b0);
        jal = (op==7'b1101111);
        lui= (op==7'b0110111 );
        auipc=(op==7'b0010111 );
    end

    //signal

    logic [`ALUOP_WIDTH-1:0] ALUop;
    logic [`SEXTSEL_WIDTH-1:0] SEXTsel;
    logic [63:0]sext_num;
    logic [`ALUASEL_WIDTH-1:0] ALUAsel;
    logic [`ALUBSEL_WIDTH-1:0] ALUBsel;
    logic [`BRSEL_WIDTH-1:0]BRsel;
    logic [`WBSEL_WIDTH-1:0]WBsel;
    logic RFwe;
    assign rs1addr=instr[19:15];
    assign rs2addr=instr[24:20];
    assign RFwe = (add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc) ;

    always_ff @( posedge clk ) begin : signal_blk
            ALUop_out<=ALUop && (nxt_state==s3);
            sext_num_out<=sext_num;
            ALUAsel_out<=ALUAsel;
            ALUBsel_out<=ALUBsel;
            BRsel_out<=BRsel;
            WBsel_out<=WBsel;
            RFwe_out<=RFwe && (nxt_state == s5);
            rdaddr <= instr[11:7];       
    end

    always_comb begin :ALUop_blk
        if(add|addi|auipc|jal|jalr)  ALUop=0;//+
        else if(sub)                 ALUop=1;//-
        else if(andu|andi)           ALUop=2;//&
        else if(oru|ori)             ALUop=3;//|
        else if(xoru|xori)           ALUop=4;//^
        else if(lui)                 ALUop=20;
        else                         ALUop=0;
    end

    always_comb begin : ALUAsel_blk
        if(auipc) ALUAsel=1;//pc
        else ALUAsel=0;//rs1
    end

    always_comb begin : ALUBsel_blk
       if(addi|andi|ori|xori|lui|auipc) ALUBsel=1;//imm
       //else if(slli|srli|srai|slliw|srliw|sraiw) ALUBsel=2;//shamt
       if(jal|jalr)ALUAsel=3;//4
       else ALUBsel=0;       //rs2
    end

    always_comb begin :SEXTsel_blk
        if(auipc|lui)                                               SEXTsel=1;//32
        else if(beq|bne|bge|blt|bltu|bgeu)                          SEXTsel=2;//13
        else if(jal)                                                SEXTsel=3;//21
        else if(addi|andi|ori|xori|jalr|sd|ld|slti|sltiu|addiw)     SEXTsel=4;//12
        else  SEXTsel=0;
    end

    always_comb begin :SEXT_blk
        case (SEXTsel)
            1: sext_num={{32{instr[31]}},instr[31:12],12'b0};//32
            2: sext_num={{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};//13
            3: sext_num={{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};//21
            //4: sext_num=DM_W?{{52{instr[31]}},instr[31:25],instr[11:7]}:{{52{instr[31]}},instr[31:20]};//12
            4: sext_num={{52{instr[31]}},instr[31:20]};
        endcase
    end

    always_comb begin : BRsel_blk
        if(jal) BRsel=1;
        else if(jalr)BRsel=2;
        else BRsel=0;
    end

    always_comb begin : WBsel_blk
        WBsel=0;
    end







    

    










    
endmodule


`endif