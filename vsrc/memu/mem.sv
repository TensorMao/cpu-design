`ifndef __MEM_SV
`define __MEM_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module mem import common::*;(
    input clk,
    input rst,
    input DMre,
    input DMwe,
    input [63:0]addr,
    input [63:0]data,
    input [2:0] dreq_info,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    output logic [63:0]dmem_out,
    output logic memu_finish
    );

    logic [5:0]ad;
    logic [7:0]strobe;
    logic [63:0]dresp_data;
    assign ad={3'b0,dreq.addr[2:0]}<<3;
    always_comb begin 
        case(dreq_info)
        0:dresp_data={{56{dresp.data[ad+7]}},dresp.data[ad+:8]};
        1:dresp_data={{48{dresp.data[ad+15]}},dresp.data[ad+:16]};
        2:dresp_data={{32{dresp.data[ad+31]}},dresp.data[ad+:32]};
        3:dresp_data=dresp.data;
        4:dresp_data={56'b0,dresp.data[ad+:8]};
        5:dresp_data={48'b0,dresp.data[ad+:16]};
        6:dresp_data={32'b0,dresp.data[ad+:32]};
        default:dresp_data=dresp.data;
        endcase   
    end
    always_comb begin 
        case(dreq_info)
        0:strobe=8'b00000001<<addr[2:0];
        1:strobe=8'b00000011<<addr[2:0];
        2:strobe=8'b00001111<<addr[2:0];
        3:strobe=8'b11111111;
        4:strobe=8'b00000001<<addr[2:0];
        5:strobe=8'b00000011<<addr[2:0];
        6:strobe=8'b00001111<<addr[2:0];
        endcase 
    end

    always_ff @(posedge clk)begin
        if(DMre)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<={1'b0,dreq_info[1:0]};
            dreq.strobe<=0;
        end
        if(DMwe)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<={1'b0,dreq_info[1:0]};
            dreq.strobe<=strobe;
            dreq.data<= data<<({3'b0,addr[2:0]}<<3);
        end     
         if(dresp.data_ok)begin
            dmem_out<=dresp_data;
            dreq.valid<=0;
            memu_finish<=1;
        end
        else memu_finish<=0;
    end


endmodule

`endif