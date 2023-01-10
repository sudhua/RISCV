`include "defines.v"
module regs(
    clk,
    rst_n,

    // from id
    reg_raddr1_i,
    reg_raddr2_i,

    // from ex
    reg_we_i,
    reg_waddr_i,
    reg_wdata_i,
    
    // to id
    reg_data1_o,
    reg_data2_o

);
    input wire clk;
    input wire rst_n;

    input wire [4:0] reg_raddr1_i;
    input wire [4:0] reg_raddr2_i;
    input wire reg_we_i;
    input wire [4:0] reg_waddr_i;
    input wire [31:0] reg_wdata_i;

    output reg [31:0] reg_data1_o;
    output reg [31:0] reg_data2_o;

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


    



    
    

endmodule
