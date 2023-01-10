`include "defines.v"
module id_ex(
    clk,
    rst_n,
    // from id
    inst_i,
    inst_addr_i,
    reg_waddr_i,
    reg_we_i,
    op1_i,
    op2_i,
    //from ctrl 
    pause_flag_i,
    // to ex
    inst_o,
    inst_addr_o,
    reg_waddr_o,
    reg_we_o,
    op1_o,
    op2_o


);
    input clk;
    input rst_n;
    input [31:0] inst_i;
    input [31:0] inst_addr_i;
    input [4:0] reg_waddr_i;
    input reg_we_i;
    input [31:0] op1_i;
    input [31:0] op2_i;
    input [2:0] pause_flag_i;

    output reg [31:0] inst_o;
    output reg [31:0] inst_addr_o;
    output reg [4:0] reg_waddr_o;
    output reg reg_we_o;
    output reg [31:0] op1_o;
    output reg [31:0] op2_o;
    
    wire [2:0] pause_en;
    assign pause_en = (pause_flag_i >= `Pause_Id);

    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        inst_o <= `ZeroWord;
    else 
        inst_o <= inst_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        inst_addr_o <= `ZeroWord;
    else 
        inst_addr_o <= inst_addr_i;
    
    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        reg_waddr_o <= `ZeroWord;
    else 
        reg_waddr_o <= reg_waddr_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        reg_we_o <= `ZeroWord;
    else 
        reg_we_o <= reg_we_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        op1_o <= `ZeroWord;
    else 
        op1_o <= op1_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | pause_en)
        op2_o <= `ZeroWord;
    else 
        op2_o <= op2_i;

endmodule