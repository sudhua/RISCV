`include "defines.v"

module csr_reg
    (
        input               clk,
        input               rst_n,
        // from ex
        input               we_i,
        input [31:0]        waddr_i,
        input [31:0]        wdata_i,
        // to id
        output reg [31:0]   rdata_o,
        // from id
        input [31:0]        raddr_i,
        // from clint
        input               clint_we_i,
        input [31:0]        clint_waddr_i,
        input [31:0]        clint_wdata_i,
        // to clint
        output [31:0]       mcause_o,
        output [31:0]       mstauts_o,
        output [31:0]       mtvec_o,
        output              global_int_en_o
    );
    wire [11:0] csr_raddr;
    wire [11:0] csr_waddr;

    reg [31:0] mtvec; // 保存发生异常时处理器需要跳转的地址
    reg [31:0] mepc; // 保存发生异常的指令
    reg [31:0] mcause; // 指示发生异常的种类
    reg [31:0] mie; // 指出处理器目前能处理和必须忽略的中断
    reg [31:0] mip; // 列出目前正准备处理的中断
    reg [31:0] mtval; // 保存了陷入的附加信息，地址例外中出错的地址、发生非法指令例外的指令本身，对于其他异常，值为0
    reg [31:0] mscratch; // 暂时存放一个字大小的数据
    reg [31:0] mstatus; // 保存全局中断使能，以及许多其他的状态

    assign csr_raddr = raddr_i[11:0];
    assign csr_waddr = waddr_i[11:0];
    assign mcause_o = mcause;
    assign mstauts_o = mstatus;
    assign mtvec_o = mtvec;
    assign global_int_en_o = mstatus[3];

    // 读csr_reg
    always @(*)
        if(!rst_n)
            rdata_o = `ZeroWord;
        else if ((we_i == `WriteEnable) && (raddr_i == waddr_i))
            rdata_o = wdata_i;
        else
        case(csr_raddr)
            `CSR_MTVEC:
                rdata_o = mtvec;
            `CSR_MEPC:
                rdata_o = mepc;
            `CSR_MCAUSE:
                rdata_o = mcause;
            `CSR_MIE:
                rdata_o = mie;
            `CSR_MIP:
                rdata_o = mip;
            `CSR_MTVAL:
                rdata_o = mtval;
            `CSR_MSCRATCH:
                rdata_o = mscratch;
            `CSR_MSTATUS:
                rdata_o = mstatus;
            default:
                rdata_o = `ZeroWord;
        endcase

    // 写csr_reg
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            mtvec = `ZeroWord;
            mepc = `ZeroWord;
            mcause = `ZeroWord;
            mie = `ZeroWord;
            mip = `ZeroWord;
            mtval = `ZeroWord;
            mscratch = `ZeroWord;
            mstatus = `ZeroWord;
        end 
        else if (we_i == `WriteEnable) // 优先ex写
        case(csr_waddr)
            `CSR_MTVEC:
                mtvec = wdata_i;
            `CSR_MEPC:
                mepc = wdata_i;
            `CSR_MCAUSE:
                mcause = wdata_i;
            `CSR_MIE:
                mie = wdata_i;
            `CSR_MIP:
                mip = wdata_i;
            `CSR_MTVAL:
                mtval = wdata_i;
            `CSR_MSCRATCH:
                mscratch = wdata_i;
            `CSR_MSTATUS:
                mstatus = wdata_i;
            default: begin

            end
        endcase
        else if (clint_we_i == `WriteEnable)
        case(clint_waddr_i[11:0])
            `CSR_MTVEC:
                mtvec = clint_wdata_i;
            `CSR_MEPC:
                mepc = clint_wdata_i;
            `CSR_MCAUSE:
                mcause = clint_wdata_i;
            `CSR_MIE:
                mie = clint_wdata_i;
            `CSR_MIP:
                mip = clint_wdata_i;
            `CSR_MTVAL:
                mtval = clint_wdata_i;
            `CSR_MSCRATCH:
                mscratch = clint_wdata_i;
            `CSR_MSTATUS:
                mstatus = clint_wdata_i;
            default: begin

            end
        endcase

endmodule
