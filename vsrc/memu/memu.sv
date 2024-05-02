`ifndef __MEMU_SV
`define __MEMU_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module memu import common::*;(
    input clk,
    input rst,
    /* ----- signals from exu ----- */
    input[63:0] instaddr_i,
    input[31:0] inst_i,

    input [`WBSEL_WIDTH] WBsel_i,
    input        RFwe_i,
    input[4:0]   rdaddr_i,
    input[63:0]  rd_wdata_i, 

    input DMre_i,
    input DMwe_i,
    input [2:0] dreq_info_i,
    input[63:0]  mem_addr_i,  
    input[63:0]  mem_wdata_i,
    /*----- signals to access the external memory -----
    output logic[63:0] mem_addr_o,
    output logic       DMwe_o,
    output logic[3:0]  dreq_info_o,         
    output logic[63:0]mem_wdata_o,
    output logic         DMre_o,*/
    output dbus_req_t dreq,
    //the read result from memory
    input dbus_resp_t dresp,
    /*-- pass down to mem_wb stage -----*/
    output logic [`WBSEL_WIDTH] WBsel_o,
    output logic RFwe_o,
    output logic[4:0]       rdaddr_o,
    output logic[63:0]       rd_wdata_o,
     /*------- signals to control ----------*/
    output logic        stall_req_o,
    output logic[63:0]  instaddr_o,
    output logic[31:0]  inst_o
  );

  assign WBsel_o=WBsel_i;
  assign RFwe_o=RFwe_i;
  assign rdaddr_o=rdaddr_i;
  assign rd_wdata_o=rd_wdata_i;
  assign instaddr_o=instaddr_i;
  assign inst_o=inst_i;
  
  
    logic [5:0]ad;
    logic [7:0]strobe;
    logic [63:0]dresp_data;
    assign rd_wdata_o=(DMre_i||DMwe_i)?dresp_data:rd_wdata_i;
    assign ad={3'b0,dreq.addr[2:0]}<<3;
    always_comb begin 
        case(dreq_info_i)
        0:dresp_data={{56{dresp.data[ad+7]}},dresp.data[ad+:8]};//lb sb
        1:dresp_data={{48{dresp.data[ad+15]}},dresp.data[ad+:16]};//lh sh
        2:dresp_data={{32{dresp.data[ad+31]}},dresp.data[ad+:32]};//lw sw
        3:dresp_data=dresp.data;//ld sd
        4:dresp_data={56'b0,dresp.data[ad+:8]};//lbu
        5:dresp_data={48'b0,dresp.data[ad+:16]};//lhu
        6:dresp_data={32'b0,dresp.data[ad+:32]};//lwu
        default:dresp_data=dresp.data;
        endcase   
    end
    always_comb begin 
        case(dreq_info_i)
        0:strobe=8'b00000001<<mem_addr_i[2:0];
        1:strobe=8'b00000011<<mem_addr_i[2:0];
        2:strobe=8'b00001111<<mem_addr_i[2:0];
        3:strobe=8'b11111111;
        4:strobe=8'b00000001<<mem_addr_i[2:0];
        5:strobe=8'b00000011<<mem_addr_i[2:0];
        6:strobe=8'b00001111<<mem_addr_i[2:0];
        endcase 
    end

    assign stall_req_o= (DMre_i||DMwe_i) && ~dresp.data_ok;
    /*assign dreq.valid=stall_req_o;
    assign dreq.addr=mem_addr_i;
    assign dreq.size={1'b0,dreq_info_i[1:0]};
    assign dreq.strobe=strobe;
    assign dreq.data= mem_wdata_i<<({3'b0,mem_addr_i[2:0]}<<3);*/
    
      always_ff @(posedge clk)begin
        if(DMre_i)begin
            dreq.valid<=1;
            dreq.addr<=mem_addr_i;
            dreq.size<={1'b0,dreq_info_i[1:0]};
            dreq.strobe<=0;
        end
        if(DMwe_i)begin
            dreq.valid<=1;
            dreq.addr<=mem_addr_i;
            dreq.size<={1'b0,dreq_info_i[1:0]};
            dreq.strobe<=strobe;
            dreq.data<= mem_wdata_i<<({3'b0,mem_addr_i[2:0]}<<3);
        end    
         if(dresp.data_ok)begin
            dreq.valid<=0;
            
        end
    end 



endmodule

`endif