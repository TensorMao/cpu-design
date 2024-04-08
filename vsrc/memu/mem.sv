`ifndef __MEM_SV
`define __MEM_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module mem import common::*;(
    input clk,
    input DM_R,
    input DM_W,
    input [63:0]addr,
    input [63:0]data,
    input [2:0]dreq_size,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    output logic [63:0]dmem_out
    );
    logic [7:0]strobe;
    logic [63:0] data_t;
    assign data_t=data<<({3'b0,addr[2:0]}<<3);
    logic [5:0]ad;
    assign ad={3'b0,dreq.addr[2:0]}<<3;
    always_comb begin 
        case(dreq_size)
        0:dmem_out={{56{dresp.data[ad+7]}},dresp.data[ad+:8]};
        1:dmem_out={{48{dresp.data[ad+15]}},dresp.data[ad+:16]};
        2:dmem_out={{32{dresp.data[ad+31]}},dresp.data[ad+:32]};
        3:dmem_out=dresp.data;
        4:dmem_out={56'b0,dresp.data[ad+:8]};
        5:dmem_out={48'b0,dresp.data[ad+:16]};
        6:dmem_out={32'b0,dresp.data[ad+:32]};
        default:dmem_out=dresp.data;
        endcase   
    end
    always_comb begin 
        case(dreq_size)
        0:strobe=8'b00000001<<addr[2:0];
        1:strobe=8'b00000011<<addr[2:0];
        2:strobe=8'b00001111<<addr[2:0];
        3:strobe=8'b11111111;
        4:strobe=8'b00000001<<addr[2:0];
        5:strobe=8'b00000011<<addr[2:0];
        6:strobe=8'b00001111<<addr[2:0];
        endcase 
    end

    assign dmem_out=dresp.data;

    always_ff @(posedge clk)begin
        if(DM_R)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<={1'b0,dreq_size[1:0]};
            dreq.strobe<=0;
        end
        else if(DM_W)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<={1'b0,dreq_size[1:0]};
            dreq.strobe<=strobe;
            dreq.data<=data_t;
        end       
        else if(dresp.data_ok)dreq.valid<=0;
    end


endmodule

`endif