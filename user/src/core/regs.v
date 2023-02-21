`include "defines.v"

module regs
    (
    input               clk,
    input               rst_n,
    // from id
    input [4:0]         reg_raddr1_i,
    input [4:0]         reg_raddr2_i,
    // from ex
    input               reg_we_i,
    input [4:0]         reg_waddr_i,
    input [31:0]        reg_wdata_i,
    // to id
    output reg [31:0]   reg_data1_o,
    output reg [31:0]   reg_data2_o
);
    reg [31:0] regs [0:31];

    always @(*)
    if (!rst_n) //需要复位吗？
        reg_data1_o = `ZeroWord;
    else if (reg_raddr1_i == `ZeroReg)
        reg_data1_o = `ZeroWord;
    else if (reg_raddr1_i == reg_waddr_i && reg_we_i == `WriteEnable)
        reg_data1_o = reg_wdata_i;
    else
        reg_data1_o = regs[reg_raddr1_i];
   
    always @(*)
    if(!rst_n)
        reg_data2_o = `ZeroWord;
    else if (reg_raddr2_i == `ZeroReg)
        reg_data2_o = `ZeroWord;
    else if (reg_raddr2_i == reg_waddr_i && reg_we_i == `WriteEnable)
        reg_data2_o = reg_wdata_i;
    else 
        reg_data2_o = regs[reg_raddr2_i];

    always @(posedge clk) //需要复位吗？
    if (reg_waddr_i != `ZeroReg && reg_we_i == `WriteEnable)
         regs[reg_waddr_i] = reg_wdata_i;
    /*
    为什么写地址等于读地址的时候，读数据直接返回正在写的值？
    考虑到一种情况：
    ------------------------------
    -    add t0, t1, t2 # inst_1 -
    -    add a0, t0, a2 # inst_2 -
    ------------------------------
    inst_1在执行阶段时，inst_2在译码阶段。
    inst_1执行阶段需要将t1 + t2的值写入t0寄存器中，由于是写寄存器是时序逻辑，需要下一个时钟才能写入，
    inst_1在执行阶段，inst_2正在译码，译码需要读取t0寄存器的值，读寄存器是组合逻辑，
    如果直接读取t0寄存器，则不能得到inst_1写入t0的值，
    因此，假如读地址和写地址相同时，读寄存器值直接返回写寄存器的值，就可以得到读取到t0正确的值。

    */

    



    
    

endmodule
