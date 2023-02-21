`include "defines.v"

module div
    (
    input               clk,
    input               rst_n,
    input               start_i,  // 除法开始信号
    input [2:0]         op_i, // 除法指令类型输入
    input [31:0]        dividend_i, // 被除数输入
    input [31:0]        divisor_i, // 除数输入
    // to ex
    output reg [31:0]   result_o, // 除法结果输出
    output reg          busy_o, // 除法计算中标志
    output reg          ready_o // 计算结果准备好标志
);
    localparam [3:0] DIV_IDLE  =  4'b0001,
                     DIV_START =  4'b0010,
                     DIV_CLAC  =  4'b0100,
                     DIV_END   =  4'b1000;

    reg [3:0]   state; // 状态机状态
    reg [2:0]   div_op; // 除法指令
    reg [31:0]  calc_cnt; // 除法计数
    reg [31:0]  minuend; // 被减数
    reg [31:0]  dividend; // 被除数
    reg [31:0]  divisor; // 除数
    reg         result_invert; // 计算结果取反标志
    reg [31:0]  result_remain; // 除法结果 - 余数
    reg [31:0]  result_quot; // 除法结果 - 商

    wire        minuend_ge_divisor; // 被减数大于余数标志
    wire [31:0] dividend_invert; // 被除取反（负变正）
    wire [31:0] divisor_invert; // 除数取反（负变正）
    wire [31:0] result_remain_invert; // 余数取反
    wire [31:0] result_quot_invert; // 商取反
    wire [31:0] minuend_tmp; // 求被减数值
    wire [31:0] result_quot_tmp; // 商值计算暂存
    wire [31:0] result_remain_tmp; // 余数计算暂存
    wire [31:0] result_o_quot_tmp; // 商输出暂存
    wire [31:0] result_o_remain_tmp; // 余数输出暂存

    assign minuend_ge_divisor = ( minuend >= divisor);
    assign dividend_invert = (-dividend);
    assign divisor_invert = (-divisor);
    assign result_remain_invert = (-result_remain);
    assign result_quot_invert = (-result_quot);
    assign minuend_tmp = {((minuend_ge_divisor) ? (minuend - divisor) : minuend[30:0]), dividend[30]};
    assign result_quot_tmp = (minuend_ge_divisor == 1) ? {result_quot[30:0], 1'b1} : {result_quot[30:0], 1'b0};
    assign result_remain_tmp = ( minuend_ge_divisor == 1) ? (minuend - divisor) : minuend;
    assign result_o_quot_tmp = (result_invert == 1) ? result_quot_invert : result_quot;
    assign result_o_remain_tmp = (result_invert == 1) ? result_remain_invert: result_remain;
/*

    DIV_IDLE:  主要完成输入信号的寄存：div_op、dividend、divisor；标志位的复位（ready_o）和置位（busy_o）：其他寄存器的清零。
    DIV_START：主要完成除法计算的准备工作：对有符号除法的除数，被除数，以及除法结果的符号进行判断（计算时全部按照正数进行计算，最后根据符号位的判断得出最终的值），
               并把结果都化成正数。另外如果被除数是0，则单独处理，除法结果的商为-1, 余数为被除数本身。
    DIV_CLAC： 主要通过试商法计算除法的结果，对被除数的每一位进行试商（被减数减去除数，大于等于0则商1，小于0则商0）；
               被减数的确定：初始被减数为被除数的最高位，如果此时被减数减去除数为非负数，则下一次的被减数为此时减的结果加上被除数下一位，如果为负数，则下一次被减数就是此时的被减数加上被除数的下一位。
               原理其实就是列的除法算式的计算方式，不妨列个除法算式来理解，只是把10进制换成了2进制。
    DIV_END：  主要完成除法结果的输出，根据结果符号标志位，对计算得出的除法结果进行符号位确定，然后输出结果，并置位标志位（ready_o）和清零标志位（busy_o）。

*/
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            state <= DIV_IDLE;
            div_op <= 0;
            dividend <= 0;
            divisor <= 0;
            minuend <= 0;
            result_remain <= 0;
            result_quot <= 0;
            result_invert <= 0;
            calc_cnt <= 0;
            result_o <= 0;
            busy_o <= 0;
            ready_o <= 0;
        end
        else case(state)
            DIV_IDLE:begin
                if(start_i == `DivStart)begin
                                                                state <= DIV_START;
                    div_op <= op_i;                          
                    dividend <= dividend_i;
                    divisor <= divisor_i;
                    minuend <= 0;
                    result_remain <= 0;
                    result_quot <= 0;
                    result_invert <= 0;
                    calc_cnt <= 0;
                    result_o <= 0;
                    busy_o <= 1'b1;
                    ready_o <= 0;
                end
                else begin
                                                                state <= DIV_IDLE;
                    div_op <= 0;
                    dividend <= 0;
                    divisor <= 0;
                    minuend <= 0;
                    result_remain <= 0;
                    result_quot <= 0;
                    result_invert <= 0;
                    calc_cnt <= 0;
                    result_o <= 0;
                    busy_o <= 0;
                    ready_o <= 0;
                end
            end
            DIV_START:begin
                if(start_i == `DivStart)begin
                    if(divisor != 32'b0) //除数不等于零                                        
                        case(div_op)
                            `INST_DIV, `INST_REM:begin // 指令为有符号的除法时
                                                                    state <= DIV_CLAC;
                                calc_cnt <= 32'h8000_0000;
                                busy_o <= 1'b1;
                                if(dividend[31] == 1'b1) begin// 判断被除数是否为负数
                                    dividend <= dividend_invert; // 负数取反得到正数
                                    minuend <= dividend_invert[31];
                                end
                                else begin
                                    dividend <= dividend; // 正数保持不变
                                    minuend <= dividend[31];
                                end
                                if(divisor[31] == 1'b1) // 判断被除数是否为负数
                                    divisor <= divisor_invert; // 负数取反得到正数
                                else
                                    divisor <= divisor; // 正数保持不变
                                if((div_op == `INST_DIV) && (dividend[31] ^ divisor[31])) // 根据除数和被除数符号判断商的正负
                                    result_invert <= 1'b1; // 商为负把结果取反标志置位1
                                else if((div_op == `INST_REM) && (dividend[31] == 1'b1)) // 根据被除数符号判断余数的符号
                                    result_invert <= 1'b1; // 余数为负把结果取反标志位置1
                                else
                                    result_invert <= 1'b0; // 以上情况都不是则结果符号标志位清零                                
                            end
                            `INST_DIVU, `INST_REMU:begin // 指令为无符号的除法
                                                                    state <= DIV_CLAC;
                                calc_cnt <= 32'h8000_0000;
                                busy_o <= 1'b1;
                                dividend <= dividend;
                                divisor <= divisor;
                                minuend <= dividend[31];
                                result_invert <= 1'b0;            
                            end
                            default:begin
                                                                    state <= DIV_IDLE;
                                calc_cnt <= 0;
                                busy_o <= 0;
                                dividend <= 0;
                                divisor <= 0;
                                minuend <= 0;
                                result_invert <= 1'b0;                                                                
                            end
                        
                        endcase
                    else begin // 除数为零
                                                                    state <= DIV_END;
                        result_invert <= 1'b0;
                        result_quot <= 32'hffff_ffff; 
                        result_remain <= dividend;
                                                                                                
                    end
                end
                else begin
                    state <= DIV_IDLE;
                end
            end
           
            DIV_CLAC:begin
                if (start_i == `DivStart)begin
                    if (|calc_cnt)begin
                                                                    state <= DIV_CLAC;
                        calc_cnt <= {1'b0,calc_cnt[31:1]}; // 计数值右移一位
                        result_quot <= result_quot_tmp; // 除法结果 - 商 
                        dividend <= {dividend[30:0], 1'b0}; // 被除数左移一位
                        minuend <= minuend_tmp;
                        result_remain <= result_remain_tmp;
                                                                    
                    end
                    else
                                                                    state <= DIV_END;
                end
                else begin
                    state <= DIV_IDLE;
                end
            end
            DIV_END:begin
                if (start_i == `DivStart)begin
                                                                    state <= DIV_IDLE;
                busy_o <= 1'b0;
                ready_o <= `ResultReady;
                case(div_op)
                    `INST_DIV, `INST_DIVU:
                        result_o <= result_o_quot_tmp;
                    `INST_REM, `INST_REMU:
                        result_o <= result_o_remain_tmp;
                    default:
                        result_o <= 32'b0;
                endcase                                         
                end
                else begin
                    state <= DIV_IDLE;
                end
            end
        endcase

endmodule
