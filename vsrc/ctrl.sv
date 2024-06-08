`ifndef __CTRL_SV
`define __CTRL_SV
`ifdef VERILATOR
`include "param.sv"
`else
`include "param.sv"
`endif

module ctrl(
    input clk,
    input rst,
    input [31:0] instr,
    input ifu_finish,
    input exu_finish,
    input memu_finish,
    input mmu_finish,
    output logic ifu_valid,
    output logic idu_valid,
    output logic exu_valid,
    output logic memu_valid,
    output logic wb_valid,
    output logic mmu_valid,
    //csr
    input [63:0]          exception_i,
    input               mstatus_ie_i,    // global interrupt enabled or not
    input               mie_external_i,  // external interrupt enbled or not
    input               mie_timer_i,     // timer interrupt enabled or not
    input               mie_sw_i,        // sw interrupt enabled or not

    input               mip_external_i,   // external interrupt pending
    input               mip_timer_i,      // timer interrupt pending
    input               mip_sw_i,         // sw interrupt pending

    input [63:0]          mtvec_i,          // the trap vector
    input [63:0]          epc_i , // get the epc for the mret instruction

    output logic                    ie_type_o,
    output logic                    set_cause_o,
    output logic[3:0]               trap_cause_o,

    output logic                    set_epc_o,
    output logic[63:0]              epc_o,

    output logic                    set_mtval_o,
    output logic[63:0]              mtval_o,

    output logic                    mstatus_ie_clear_o,
    output logic                    mstatus_ie_set_o,

    output logic[63:0]              new_pc_o,   // notify the ifu to fetch the instruction from the new PC
    output logic                    flush_o,
    input [63:0]          pc_i,
    input [1:0] mode_i,
    input [3:0] satp_mode_i,
    output logic dreqSel
);
    //state
     typedef enum { 
        s0,
        s6, //mmu
        s1, //ifetch
        s2, //decode
        s3, //execute
        s4, //memrw
        s5  //writeback
    } state_t;
    state_t state,nxt_state;

    assign dreqSel =(state==s4);
    assign ifu_valid= (state!=s1 && nxt_state==s1);
    assign idu_valid= (state!=s2 && nxt_state==s2);
    assign exu_valid= (state!=s3 && nxt_state==s3);
    assign memu_valid=(state!=s4 && nxt_state==s4);
    assign wb_valid=  (state!=s5 && nxt_state==s5);
    assign mmu_valid=(state!=s6 && nxt_state==s6);
    always_ff @( posedge clk ) begin
        if(rst) state<=s0;
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
            if(exu_finish) nxt_state=s4;
            else nxt_state=s3;
        end
        s4:begin
            if(memu_finish)nxt_state=s5;
            else nxt_state=s4;
        end
        s5:begin
            if(satp_mode_i==8 && mode_i!=3)nxt_state=s6;
            else  nxt_state=s1;
            
        end
        s6:begin
            if(mmu_finish)nxt_state=s1;
            else nxt_state=s6;
        end
        endcase
    end

    /*  -- handle the the interrupt and exceptions --*/
     typedef enum {
        MSTATE_RESET,
        MSTATE_OPERATING,
        MSTATE_TRAP_TAKEN,
        MSTATE_TRAP_RETURN,
        USTATE_OPERATING
     } mstate_t;

    mstate_t curr_status,nxt_status;
    //check there is a interrupt on pending
    logic   eip;
    logic   tip;
    logic   sip;
    logic   ip;
    assign eip = mie_external_i & mip_external_i;
    assign tip = mie_timer_i &  mip_timer_i;
    assign sip = mie_sw_i & mip_sw_i;
    assign ip = eip | tip | sip;

    logic   mret;
    logic   ecall;
    logic   ebreak;
    logic   misaligned_inst;
    logic   illegal_inst;
    logic   misaligned_store;
    logic   misaligned_load;
    assign {misaligned_load, misaligned_store, ebreak, ecall, mret, illegal_inst, misaligned_inst} = exception_i[6:0];
    // an interrupt or an exception, need to be processed 
    logic   trap_happened;
    assign trap_happened = (mstatus_ie_i & ip) | ecall | misaligned_inst | illegal_inst | misaligned_store | misaligned_load;

    assign epc_o = epc_i;
    
    always_comb   begin
        case(curr_status)
            MSTATE_RESET: begin
                nxt_status = MSTATE_OPERATING;
            end
            MSTATE_OPERATING: begin
                /*if(trap_happened)
                    nxt_status = MSTATE_TRAP_TAKEN;*/
                if(mret)
                    nxt_status = MSTATE_TRAP_RETURN;
                else
                    nxt_status = MSTATE_OPERATING;
            end
            MSTATE_TRAP_TAKEN: begin
                nxt_status = MSTATE_OPERATING;
            end

            MSTATE_TRAP_RETURN: begin
                nxt_status = USTATE_OPERATING;
            end
            USTATE_OPERATING: begin
                if(trap_happened)
                    nxt_status = MSTATE_TRAP_TAKEN;
            end
            default: begin
                nxt_status = MSTATE_OPERATING;
            end
        endcase
    end

    always @(posedge clk) begin
        if(rst)
            curr_status <= MSTATE_RESET;
        else
            curr_status <= nxt_status;
    end


    logic [1:0]          mtvec_mode; // machine trap mode
    logic [61:0]         mtvec_base; // machine trap base address
    assign mtvec_base = mtvec_i[63:2];
    assign mtvec_mode = mtvec_i[1:0];

    
    // mtvec = { base[maxlen-1:2], mode[1:0]}
    // The value in the BASE field must always be aligned on a 4-byte boundary, and the MODE setting may impose
    // additional alignment constraints on the value in the BASE field.
    // when mode =2'b00, direct mode, When MODE=Direct, all traps into machine mode cause the pc to be set to the address in the BASE field.
    // when mode =2'b01, Vectored mode, all synchronous exceptions into machine mode cause the pc to be set to the address in the BASE
    // field, whereas interrupts cause the pc to be set to the address in the BASE field plus four times the interrupt cause number.
    logic[63:0] trap_mux_out;
    logic [63:0] vec_mux_out;
    logic [63:0] base_offset;

    
    assign base_offset = {58'b0, trap_cause_o, 2'b0};  // trap_cause_o * 4
    assign vec_mux_out = mtvec_i[0] ? {mtvec_base, 2'b00} + base_offset : {mtvec_base, 2'b00};
    assign trap_mux_out = ie_type_o ? vec_mux_out : {mtvec_base, 2'b00};

    always_comb   begin
        case(nxt_status)
            MSTATE_RESET: begin
                flush_o = 1'b0;
                new_pc_o = 64'h80000000;
                set_epc_o = 1'b0;
                set_cause_o = 1'b0;
                mstatus_ie_clear_o = 1'b0;
                mstatus_ie_set_o = 1'b0;
            end
            MSTATE_OPERATING: begin
                flush_o = 1'b0;
                new_pc_o = 0;
                set_epc_o = 1'b0;
                set_cause_o = 1'b0;
                mstatus_ie_clear_o = 1'b0;
                mstatus_ie_set_o = 1'b0;
            end

            MSTATE_TRAP_TAKEN: begin
                flush_o = 1'b1;
                new_pc_o = trap_mux_out;       // jump to the trap handler
                set_epc_o = 1'b1;              // update the epc csr
                set_cause_o = 1'b1;            // update the mcause csr
                mstatus_ie_clear_o = 1'b1;     // disable the mie bit in the mstatus
                mstatus_ie_set_o = 1'b0;
            end

            MSTATE_TRAP_RETURN: begin
                flush_o = 1'b1;
                new_pc_o =  epc_i;
                set_epc_o = 1'b0;
                set_cause_o = 1'b0;
                mstatus_ie_clear_o = 1'b0;
                mstatus_ie_set_o = 1'b1; 
            end

            default: begin
                flush_o = 1'b0;
                new_pc_o = 0;
                set_epc_o = 1'b0;
                set_cause_o = 1'b0;
                mstatus_ie_clear_o = 1'b0;
                mstatus_ie_set_o = 1'b0;
            end
        endcase
    end


   // update the mcause csr 
    always_comb begin
        if(rst) begin
            trap_cause_o = 4'b0;
            ie_type_o = 1'b0;
            set_mtval_o = 1'b0;
            mtval_o = 0;

        end 
        else if(nxt_status == MSTATE_TRAP_TAKEN) begin
            if(mstatus_ie_i & eip) begin
                trap_cause_o = 4'b1011; // M-mode external interrupt
                ie_type_o = 1'b1;
                set_mtval_o = 1'b0;
                mtval_o = 0;
            end else if(mstatus_ie_i & sip) begin
                trap_cause_o = 4'b0011; // M-mode software interrupt
                ie_type_o = 1'b1;
                set_mtval_o = 1'b0;
                mtval_o = 0;
            end else if(mstatus_ie_i & tip) begin
                trap_cause_o = 4'b0111; // M-mode timer interrupt
                ie_type_o = 1'b1;
                set_mtval_o = 1'b0;
                mtval_o = 0;
            end else if(misaligned_inst) begin
                trap_cause_o = 4'b0000; // Instruction address misaligned, cause = 0
                ie_type_o = 1'b0;
                set_mtval_o = 1'b1;
                mtval_o = pc_i;
            end else if(illegal_inst) begin
                trap_cause_o = 4'b0010; // Illegal instruction, cause = 2
                ie_type_o = 1'b0;
                set_mtval_o = 1'b1;
                mtval_o = {32'b0,instr};     //set to the instruction

            end else if(ebreak) begin
                trap_cause_o = 4'b0011; // Breakpoint, cause =3
                ie_type_o = 1'b0;
                set_mtval_o = 1'b1;
                mtval_o = pc_i;

            end else if(misaligned_store) begin
                trap_cause_o = 4'b0110; // Store address misaligned  //cause 6
                ie_type_o = 1'b0;
                set_mtval_o = 1'b1;
                mtval_o = pc_i;

            end else if(misaligned_load) begin
                trap_cause_o = 4'b0100; // Load address misaligned  cause =4
                ie_type_o = 1'b0;
                set_mtval_o = 1'b1;
                mtval_o = pc_i;

            end else if(ecall) begin
                trap_cause_o = 8; 
                ie_type_o = 1'b0;
                set_mtval_o = 1'b0;
                mtval_o = 0;
            end
            else begin
                trap_cause_o = 4'b0;
                ie_type_o = 1'b0;
                set_mtval_o = 1'b0;
                mtval_o = 0;
            end
        end
        else begin
            trap_cause_o = 4'b0;
            ie_type_o = 1'b0;
            set_mtval_o = 1'b0;
            mtval_o = 0;
        end

    end





    

    










    
endmodule


`endif