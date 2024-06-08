`ifndef __CSR_SV
`define __CSR_SV
`ifdef VERILATOR
`include "param.sv"
`include "include/common.sv"
`else
`endif
module csr(
    input clk,
    input rst,
     /*-- wb module update the csr  --*/
    input csr_we_i,
    input [11:0] waddr_i,         // the logicister to write
    input [63:0] wdata_i,         // the data to write
     /*-- interrupt signals from clint or plic --*/
    input              irq_software_i,
    input              irq_timer_i,
    input              irq_external_i,
     /*-- exu read csr --*/
    input [11:0]      raddr_i, 
    output logic [63:0]      rdata_o, 

     /*-- ctrl update epc, mcause, mtval, global ie --*/
    input                ie_type_i,          // interrupt or exception
    input                set_cause_i,
    input  [3:0]         trap_cause_i,

    input                set_epc_i,
    input [63:0]      epc_i,

    input                set_mtval_i,
    input [63:0]      mtval_i,

    input                mstatus_ie_clear_i,
    input                mstatus_ie_set_i,

    /*-- to control , interrupt enablers, mtvec, epc etc-----*/
    output logic [63:0] mstatus,
	output logic [63:0]	mepc    ,
	output logic [63:0]	mtval   ,
	output logic [63:0]	mtvec   ,
	output logic [63:0]	mcause  ,
	output logic [63:0]	satp    ,
	output logic [63:0]	mip     ,
	output logic [63:0]	mie     ,
	output logic [63:0]	mscratch,
    output logic               mstatus_ie_o,
    output logic              mie_external_o,
    output logic              mie_timer_o,
    output logic              mie_sw_o,

    output logic              mip_external_o,
    output logic              mip_timer_o,
    output logic              mip_sw_o,
    output logic[63:0]     mtvec_o,
    output logic[63:0]     epc_o,
    output logic[1:0] mode_o
);
    
    /*--mode--*/
    always_ff@(posedge clk) begin
        if(rst) begin
            mode_o<=2'b11;
        end
        else if(mstatus_ie_set_i)begin
            mode_o <= mstatus_mpp;
        end
        else if(set_cause_i)begin
            mode_o <=3;
        end
    end
    
    
    
      /*-- mtvec--*/
    always @(posedge clk) begin
        if(rst) begin
            mtvec <= 0;
        end else if( (waddr_i == `CSR_MTVEC_ADDR) && csr_we_i ) begin
            mtvec <= wdata_i;
        end
    end

     /*-- mstatus --*/
     
    logic               mstatus_pie; // prior interrupt enable
    logic               mstatus_ie;
    logic[1:0]          mstatus_mpp;
    assign             mstatus_ie_o = mstatus_ie;
    assign mstatus = {48'b0, 3'b000,mstatus_mpp ,3'b000, mstatus_pie, 3'b0 , mstatus_ie, 3'b0};

    always @(posedge clk) begin
        if(rst) begin
            mstatus_ie <= 1'b0;
            mstatus_pie <= 1'b1;
            mstatus_mpp <= 2'b00;
        end else if( (waddr_i[11:0] == `CSR_MSTATUS_ADDR) && csr_we_i ) begin
            mstatus_ie <= wdata_i[3];
            mstatus_pie<=wdata_i[7];
            mstatus_mpp <= wdata_i[12:11];
        end else if(mstatus_ie_clear_i == 1'b1) begin
            mstatus_pie <= mstatus_ie;
            mstatus_ie <= 1'b0;
        end else if(mstatus_ie_set_i == 1'b1) begin
            mstatus_ie <= mstatus_pie;
            mstatus_pie <= 1'b1;
            mstatus_mpp <= 2'b0;
        end
    end
      /*-- mscratch --*/
    // mscratch : Typically, it is used to hold a pointer to a machine-mode hart-local context space and swapped
    // with a user logicister upon entry to an M-mode trap handler.
    always @(posedge clk) begin
        if(rst)
            mscratch <= 0;
        else if( (waddr_i[11:0] == `CSR_MSCRATCH_ADDR) && csr_we_i )
            mscratch <= wdata_i;
    end

    /*--mepc--*/
    // When a trap is taken into M-mode, mepc is written with the virtual address of the instruction
    // that was interrupted or that encountered the exception.
    // The low bit of mepc (mepc[0]) is always zero.
    // On implementations that support only IALIGN=32, the two low bits (mepc[1:0]) are always zero.
    assign epc_o = mepc;
    always @(posedge clk) begin
        if(rst)
            mepc <= 0;
        else if(set_epc_i)
            mepc <= {epc_i[63:2], 2'b00};
        else if( (waddr_i[11:0] == `CSR_MEPC_ADDR) && csr_we_i)
            mepc <= {wdata_i[63:2], 2'b00};
    end

    /*-- mie --*/
    // mie: {WPRI[63:12], MEIE(1), WPRI(1), SEIE(1), UEIE(1), MTIE(1), WPRI(1), STIE(1), UTIE(1), MSIE(1), WPRI(1), SSIE(1), USIE(1)}
    // MTIE, STIE, and UTIE for M-mode, S-mode, and U-mode timer interrupts respectively.
    // MSIE, SSIE, and USIE fields enable software interrupts in M-mode, S-mode software, and U-mode, respectively.
    // MEIE, SEIE, and UEIE fields enable external interrupts in M-mode, S-mode software, and U-mode, respectively.
    logic        mie_external; // external interrupt enable
    logic        mie_timer;    // timer interrupt enable
    logic         mie_sw;       // software interrupt enable

    assign mie_external_o = mie_external;
    assign mie_timer_o = mie_timer;
    assign mie_sw_o = mie_sw;

    assign mie = {52'b0, mie_external, 3'b0, mie_timer, 3'b0, mie_sw, 3'b0};

    always @(posedge clk) begin
        if(rst) begin
            mie_external <= 1'b0;
            mie_timer <= 1'b0;
            mie_sw <= 1'b0;
        end else if((waddr_i[11:0] == `CSR_MIE_ADDR) && csr_we_i) begin
            mie_external <= wdata_i[11];
            mie_timer <= wdata_i[7];
            mie_sw <= wdata_i[3];
        end
    end

     /*-- mcause --*/
    // When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap.
    // Otherwise, mcause is never written by the implementation, though it may be explicitly written by software.
    // mcause = {interupt[31:30], Exception code }
    // The Interrupt bit in the mcause logicister is set if the trap was caused by an interrupt. The Exception
    // Code field contains a code identifying the last exception.

    logic [3:0]          cause; // interrupt cause
    logic [58:0]         cause_rem; // remaining bits of mcause logicister
    logic                int_or_exc; // interrupt or exception signal

    assign mcause = {int_or_exc, cause_rem, cause};
    always @(posedge clk) begin
        if(rst) begin
            cause <= 0;
            cause_rem <= 0;
            int_or_exc <= 0;
        end else if(set_cause_i) begin
            cause <= trap_cause_i;
            cause_rem <= 0;
            int_or_exc <= ie_type_i;
        end else if( (waddr_i[11:0] == `CSR_MCAUSE_ADDR) && csr_we_i) begin
            cause <= wdata_i[3:0];
            cause_rem <= wdata_i[62:4];
            int_or_exc <= wdata_i[63];
        end
    end

    /*-- mip --*/
    // mip: {WPRI[63:12], MEIP(1), WPRI(1), SEIP(1), UEIP(1), MTIP(1), WPRI(1), STIP(1), UTIP(1), MSIP(1), WPRI(1), SSIP(1), USIP(1)}
    // The MTIP, STIP, UTIP bits correspond to timer interrupt-pending bits for machine, supervisor, and user timer interrupts, respectively.
    logic                mip_external; // external interrupt pending
    logic                mip_timer; // timer interrupt pending
    logic                mip_sw; // software interrupt pending

    assign mip = {52'b0, mip_external, 3'b0, mip_timer, 3'b0, mip_sw, 3'b0};

    assign mip_external_o = mip_external;
    assign mip_timer_o = mip_timer;
    assign mip_sw_o = mip_sw;

    always @(posedge clk) begin
        if(rst) begin
            mip_external <= 1'b0;
            mip_timer <= 1'b0;
            mip_sw <= 1'b0;
        end else begin
            mip_external <= irq_external_i;
            mip_timer <= irq_timer_i;
            mip_sw <= irq_software_i;
        end
    end


    /*-- mtval --*/
    always @(posedge clk)  begin
        if(rst)
            mtval <= 64'b0;
        else if(set_mtval_i) begin
            mtval <= mtval_i;
        end else if( (waddr_i[11:0] == `CSR_MTVAL_ADDR) && csr_we_i)
            mtval <= wdata_i;
    end


     /*-- mcycle --*/
    logic[63:0] mcycle;  
    always @ (posedge clk) begin
        if (rst) begin
            mcycle <= 64'b0;
        end else begin
            mcycle <= mcycle + 64'd1;
        end
    end

    /*-- satp --*/  
    always_ff @ (posedge clk) begin
        if (rst) begin
            satp <= 64'b0;
        end else if( (waddr_i[11:0] == `CSR_SATP_ADDR) && csr_we_i) begin
            satp <= wdata_i;
        end
    end



    /* ---read csr --*/
    always_comb begin
        // bypass the write port to the read port
        if ((waddr_i[11:0] == raddr_i[11:0]) && csr_we_i) begin
            rdata_o = wdata_i;
        end else begin
            case (raddr_i[11:0])
                `CSR_MCYCLE_ADDR: begin
                    rdata_o = mcycle;
                end
                `CSR_MSTATUS_ADDR: begin
                    rdata_o = mstatus;
                end

                `CSR_MIE_ADDR: begin
                    rdata_o = mie;
                end

                `CSR_MTVEC_ADDR: begin
                    rdata_o = mtvec;
                end

                `CSR_MSCRATCH_ADDR: begin
                    rdata_o = mscratch;
                end

                `CSR_MEPC_ADDR: begin
                    rdata_o = mepc;
                end

                `CSR_MCAUSE_ADDR: begin
                    rdata_o = mcause;
                end

                `CSR_MIP_ADDR: begin
                    rdata_o = mip;
                end
                `CSR_SATP_ADDR: begin
                    rdata_o = satp;
                end

                default: begin
                    rdata_o = 0;
                end
            endcase 
        end 
    end 
endmodule

`endif