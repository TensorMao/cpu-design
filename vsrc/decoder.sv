`ifndef __DECODER_SV
`define __DECODER_SV
`ifdef VERILATOR

`else

`endif

module decoder(
   
   input [31:0] order,
   input ZF,
   output [1:0]M1,
   output [2:0]M2,
   output [1:0]M3,
   output M4, 
   output [2:0]ALU_C ,
   output RF_W,
   output DM_R,
   output DM_W,
   output skip
    );
    logic [5:0] func;
    logic [6:0] op;
    logic [2:0]func3;
    logic [6:0]func7;
 assign  func=order[5:0];
 assign  op= order[6:0];
 assign func3=order[14:12];
 assign func7=order[31:25];
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
 
 assign M1[0]=ZF?(jal|beq):(jal);
 assign M1[1]=jalr;
 assign M2[0]=jal|jalr|auipc;
 assign M2[1]=lui|auipc;
 assign M2[2]=ld;
 assign M3[0]=auipc;
 assign M3[1]=beq;
 assign M4=addi|andi|ori|xori|jalr|sd|ld;

 assign ALU_C[0]=sub|oru|ori;
 assign ALU_C[1]=andu|oru|andi|ori;
 assign ALU_C[2]=xoru|xori;
 assign RF_W=add|sub|andu|oru|xoru|addi|andi|ori|xori|jalr|jal|lui|auipc&&~ld;
 assign DM_R=ld;
 assign DM_W=sd;
assign skip=jal;
endmodule

`endif