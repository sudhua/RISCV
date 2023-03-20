`include "defines.v"

module clint
    (
        input                   clk,
        input                   rst_n,
        // from soc_top     
        input [31:0]            int_req_i,
        // from id      
        input [31:0]            inst_i,
        input [31:0]            inst_addr_i,
        // from csr_reg     
        input  [31:0]           csr_mtvec_i,
        input [31:0]            csr_mstatus_i,
        input [31:0]            csr_mepc_i,
        input                   global_int_en_i,
        // to csr_reg
        output reg              csr_we_o,
        output reg [31:0]       csr_waddr_o,
        output reg [31:0]       csr_wdata_o,
        // from ex
        input                   jump_flag_i,
        input [31:0]            jump_addr_i,
        input                   div_start_i,
        // to ex
        output reg              trap_en_o,
        output reg [31:0]       trap_addr_o

    );
    localparam [3:0]    TRAP_IDLE  =  4'b0001,
                        TRAP_SYNC  =  4'b0010, // 同步异常
                        TRAP_ASYNC =  4'b0100, // 异步异常 - 中断
                        TRAP_MRET  =  4'b1000; // 异常返回
    reg [3:0] trap_state;
    localparam [7:0]    CSR_IDLE         =  8'b0000_0001,
                        CSR_MEPC         =  8'b0000_0010, // Machine Exception Program Counter
                        CSR_MCAUSE       =  8'b0000_0100, // Machine Cause Register
                        CSR_MSTATUS      =  8'b0000_1000, // Machine Status Registers 
                        CSR_MRET_MSTATUS =  8'b0001_0000; // 异常返回时设置MSTATUS
    reg [3:0] csr_state;
    reg [31:0] mcause;
    reg [31:0] mepc;
    // 有异常时暂停流水线
    assign hold_flag_o = ((trap_state != TRAP_IDLE) || (csr_state != CSR_IDLE)) ? `HoldEnable : `HoldDisable;
    // 中断仲裁 同步异常 > 异步异常 > 异常返回
    always @(*)
        if(!rst_n)
            trap_state = TRAP_IDLE;
        else if ((inst_i == `INST_EBREAK) | (inst_i == `INST_ECALL)) // 异常为ebreak或者ecall
            trap_state = TRAP_SYNC;
        else if (int_req_i  != `INT_NONE && global_int_en_i == `WriteEnable) //中断请求有效且全局中断使能有效时触发中断
            trap_state = TRAP_ASYNC;
        else if (inst_i == `INST_MRET) // 指令为异常返回
            trap_state = TRAP_MRET;
        else
            trap_state = TRAP_IDLE;

    // 写CSR寄存器
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            csr_state = CSR_IDLE;
        else
        case(csr_state)
            CSR_IDLE: begin
                case(trap_state)
                    TRAP_SYNC: begin 
                                                        csr_state = CSR_MEPC;
                        if (jump_flag_i == `WriteEnable)
                            mepc = jump_addr_i -3'h4;
                        else
                            mepc = inst_addr_i; // 同步异常中mepc保存的是异常指令的地址
                        case (inst_i) // 判断异常原因
                            `INST_EBREAK:
                                mcause = 32'd3;
                            `INST_ECALL:
                                mcause = 32'd11;
                            default:
                                mcause = 32'd10;
                        endcase
                    end
                    TRAP_ASYNC: begin
                                                        csr_state = CSR_MEPC;
                        if (jump_flag_i == `WriteEnable)
                            mepc = jump_addr_i;
                        else if (div_start_i == `DivStart)
                            mepc = inst_addr_i - 3'h4;
                        else
                            mepc = inst_addr_i; // 异步异常中mepc保存的是执行完中断的返回地址
                        mcause = 32'h8000_0007; //Machine timer interrupt
                    end
                    TRAP_MRET: begin
                                                        csr_state = CSR_MRET_MSTATUS;
                    end
                    default:
                                                        csr_state = CSR_IDLE;
                endcase
            end
            CSR_MEPC:
                                                        csr_state = CSR_MCAUSE;
            CSR_MCAUSE:
                                                        csr_state = CSR_MSTATUS;
            CSR_MRET_MSTATUS:
                                                        csr_state = CSR_IDLE;
            default:
                                                        csr_state = CSR_IDLE;
        endcase

    //写csr寄存器

    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            csr_we_o = `WriteDisable;
            csr_waddr_o = `ZeroWord;
            csr_wdata_o = `ZeroWord;
        end
        else
        case(csr_state)
            CSR_MEPC: begin
                csr_we_o = `WriteEnable;
                csr_waddr_o = {20'b0, `CSR_MEPC};
                csr_wdata_o = mepc;
            end
            CSR_MCAUSE: begin
                csr_we_o = `WriteEnable;
                csr_waddr_o = {20'b0, `CSR_MCAUSE};
                csr_wdata_o = mcause;
            end
            CSR_MSTATUS: begin
                csr_we_o = `WriteEnable;
                csr_waddr_o = {20'b0, `CSR_MSTATUS};
                csr_wdata_o = {csr_mstatus_i[31:4], 1'b0, csr_mstatus_i[2:0]};
            end
            CSR_MRET_MSTATUS: begin
                csr_we_o = `WriteEnable;
                csr_waddr_o = {20'b0, `CSR_MSTATUS};
                csr_wdata_o = {csr_mstatus_i[31:4], csr_mstatus_i[7], csr_mstatus_i[2:0]};
            end
        endcase


    // 发出中断信号到执行阶段
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            trap_en_o = `TrapDisable;
            trap_addr_o = `ZeroWord;
        end
        else
        case(csr_state)
            CSR_MSTATUS: begin
                trap_en_o = `TrapEnable;
                trap_addr_o = csr_mtvec_i;
            end
            CSR_MRET_MSTATUS: begin
                trap_en_o = `TrapDisable;
                trap_addr_o = csr_mepc_i;
            end
            default: begin
                trap_en_o = `TrapDisable;
                trap_addr_o = `ZeroWord;
            end
        endcase


endmodule
