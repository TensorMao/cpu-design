`ifndef __MMU_SV
`define __MMU_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module mmu import common::*;(
    input clk,
    input rst,
    input mmu_valid,
    output logic mmu_finish,
    input [63:0] satp_i,
    input [63:0]virtual_addr,
    output logic [63:0]physical_addr,
    output dbus_req_t dreq,
    input dbus_resp_t dresp
   );
    
    typedef enum { 
        STALL,
        LOAD
    } state_t;
    state_t state,nxt_state;

    always_ff @( posedge clk ) begin
        if(rst) state<= STALL;
        else state <= nxt_state;  
    end

    logic[1:0] count;
    always_comb begin : state_change
        case(state)
        STALL:begin
            if(mmu_valid )begin
                nxt_state=LOAD;
            end
            else nxt_state=STALL;
        end
        LOAD:begin
            if(mmu_finish)begin
                nxt_state=STALL;
            end
            else nxt_state=LOAD;
        end
        endcase
    end

    logic [11:0] offset;   
    logic [63:0]data;
    logic [43:0]data_ppn;
    logic [63:0]addr;
    logic [8:0] index;
    assign offset=virtual_addr[11:0];
    assign data_ppn = (count==0)?satp_i[43:0]:data[53:10];
    assign addr={8'b0,data_ppn,index,3'b0};
     

    always_comb begin
        case(count)
            0:index=virtual_addr[38:30];
            1:index=virtual_addr[29:21];
            2:index=virtual_addr[20:12];
        endcase
    end

    always_ff @(posedge clk)begin
        if(state==LOAD && count<3)begin
            dreq.valid<=1;
            dreq.addr<=addr;
            dreq.size<=3'b011;
            dreq.strobe<=0;
            if(dresp.data_ok)begin
                data<=dresp.data;
                count<=count+1;
                dreq.valid<=0;
            end
        end
        else if(count==3)begin
            mmu_finish<=1;
            physical_addr<={8'b0,data_ppn,offset};
        end
        if(mmu_finish)begin
            mmu_finish<=0;
            count<=0;
        end
    end

endmodule




`endif