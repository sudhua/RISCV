`include "../core/defines.v"
module timer
    (
        input clk,
        input rst_n,
        input we_i,
        input [31:0] addr_i,
        input [31:0] wdata_i,
        output reg [31:0] rdata_o,
        output [31:0]  int_signal_o
    );
    localparam  REG_CTRL  = 4'd0, // 32位处理器地址是4的倍数
                REG_VALUE = 4'd4,
                REG_CNT   = 4'd8;
    // timer_ctrl[0] : timer enable
    // timer_ctrl[1] : timer int enable
    // timer_ctrl[2] : timer int pending 定时器计数值到时被硬件置位触发中断信号，用户软件写1清零
    reg [31:0] timer_ctrl; // 定时器控制寄存器

    reg [31:0] timer_value; // 定时器定时值寄存器

    reg [31:0] timer_cnt; // 定时器计数寄存器

    assign int_signal_o = ((timer_ctrl[2] == 1'b1) && (timer_ctrl[1] == 1'b1)) ? `TIME_INT : `INT_NONE;
    // counter
    always @(posedge clk or negedge rst_n)
        if(!rst_n) 
        timer_cnt <= `ZeroWord;
        else if (timer_value[0] == 1'b1) // 定时器使能有效时，定时器自加
            timer_cnt <= timer_cnt + 1'b1;
        else if (timer_cnt >= timer_value) // 计数值大于设定值，定时器清零
            timer_cnt <= `ZeroWord;
        else
            timer_cnt <= `ZeroWord;

    // wirte regs
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            timer_ctrl <= `ZeroWord;
            timer_value <= `ZeroWord;
        end
        else if (we_i == `WriteEnable)
        case (addr_i[3:0])
            REG_CTRL:
                timer_ctrl <= {wdata_i[31:3],(timer_ctrl[2] & (~ wdata_i[2])),wdata_i[1:0]};
            REG_VALUE:
                timer_value <= wdata_i;
            default : begin
                timer_ctrl <= `ZeroWord;
                timer_value <= `ZeroWord;
            end
        endcase
        else if ((timer_ctrl[0] == 1'b1) && (timer_cnt >= timer_value)) begin
            timer_ctrl[0] <= 1'b0; // 定时器关闭
            timer_ctrl[2] <= 1'b1; // 
        end
        else begin
            timer_ctrl <= timer_ctrl;
            timer_value <= timer_value;
        end

    // read regs
    always @(*)
        case (addr_i[3:0])
        REG_CTRL: 
            rdata_o <= timer_ctrl;
        REG_VALUE: 
            rdata_o <= timer_value;
        REG_CNT: 
            rdata_o <= timer_cnt;
        default:
            rdata_o <= `ZeroWord;
        endcase


endmodule
