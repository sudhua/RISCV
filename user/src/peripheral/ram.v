`include "../core/defines.v"

module ram
    (
    input               clk,
    input               rst_n,
    input               mem_we_i,
    input [31:0]        mem_waddr_i,
    input [31:0]        mem_wdata_i,
    input [31:0]        mem_raddr_i,
    output reg [31:0]   mem_rdata_o
);
    reg [31:0] _ram [0:255];

    always @(posedge clk or negedge rst_n)
        if(mem_we_i == `WriteEnable)
            _ram[mem_waddr_i[31:2]] <= mem_wdata_i;
    
    always @(*)
        if(!rst_n)
            mem_rdata_o = `ZeroWord;
        else
            mem_rdata_o = _ram[mem_raddr_i[31:2]];




endmodule
