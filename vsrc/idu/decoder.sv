`ifndef __DECODER_SV
`define __DECODER_SV
`ifdef VERILATOR

`else

`endif

module decoder(
   
    input [31:0] instr,
    input ZF,
    output [1:0]PC_M,
    output [2:0]M2,
    output M4, 
    output [2:0]ALU_C ,
    output RF_W,
    output DM_R,
    output DM_W,
    output skip,
    output logic[63:0] sext_num,
    output [4:0]rdc,
    output [4:0]rs1c,
    output [4:0]rs2c
    );

    
    logic [5:0] func;   assign  func=instr[5:0];
    logic [6:0] op;     assign  op= instr[6:0];
    logic [2:0]func3;   assign func3=instr[14:12];
    logic [6:0]func7;   assign func7=instr[31:25];
    
    //R type
    logic R_type,add,sub,andu,oru,xoru;
    assign R_type= (op==7'b0110011);
    assign add= R_type && (func3==3'b000) && (func7==7'b0000000 );
    assign sub= R_type && (func3==3'b000)&&(func7==7'b0100000  );
    assign andu=R_type && (func3==3'b111)&&(func7==7'b0000000 );
    assign oru= R_type && (func3==3'b110)&&(func7==7'b0000000 );
    assign xoru=R_type && (func3==3'b100)&&(func7==7'b0000000 );
    //I type
    logic I_type,xori,ori,andi,addi,jalr;
    assign I_type= (op==7'b0010011);
    assign xori= I_type && (func3 ==3'b100);
    assign ori=  I_type && (func3 ==3'b110);
    assign andi= I_type && (func3 ==3'b111);
    assign addi= I_type && (func3 ==3'b000);
    assign jalr= (op==7'b1100111)&& (func3 ==3'b000);
    //J type
    logic jal;
    assign jal = (op==7'b1101111);
    //B type
    logic beq;
    assign beq = (op==7'b1100011) && (func3==3'b000);
    //U type
    logic lui,auipc,ld,sd;
    assign lui= (op==7'b0110111 );
    assign auipc=(op==7'b0010111 );
    assign ld=(op==7'b0000011)&&(func3==3'b011);
    assign sd=(op==7'b0100011)&&(func3==3'b011);
 
    assign PC_M[0]=ZF?(jal|beq):(jal);
    assign PC_M[1]=jalr;
    assign M2[0]=jal|jalr|auipc;
    assign M2[1]=lui|auipc;
    assign M2[2]=ld;

    logic [2:0] SEXT_M;
    assign SEXT_M[0]=auipc|lui|jal;
    assign SEXT_M[1]=beq|jal;
    assign SEXT_M[2]=addi|andi|ori|xori|jalr|sd|ld;
    
    assign M4=addi|andi|ori|xori|jalr|sd|ld;

    assign ALU_C[0]=sub|oru|ori;
    assign ALU_C[1]=andu|oru|andi|ori;
    assign ALU_C[2]=xoru|xori;
    assign RF_W=add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc;
    assign DM_R=ld;
    assign DM_W=sd;
    assign skip=jal|jalr|(beq&&ZF);
    
    //sext
    always_comb begin 
        case (SEXT_M)
            1: sext_num={{32{instr[31]}},instr[31:12],12'b0};//32
            2: sext_num={{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};//13
            3: sext_num={{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};//21
            4: sext_num=DM_W?{{52{instr[31]}},instr[31:25],instr[11:7]}:{{52{instr[31]}},instr[31:20]};//12
        endcase

    end

    //rdc,rs1c,rs2c
    assign rdc= instr[11:7];
    assign rs1c=instr[19:15];
    assign rs2c=instr[24:20];



endmodule

`endif