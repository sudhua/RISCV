`include "defines.v"

module if_id(
    clk,
    rst_n,
    //from pc_reg
    inst_i,
    inst_addr_i,
    //from ctrl 
    pause_flag_i,
    // to id
    inst_o,
    inst_addr_o

);
    input clk;
    input rst_n;
    input [31:0] inst_i;
    input [31:0] inst_addr_i;
    input [2:0] pause_flag_i;
    output reg [31:0] inst_o;
    output reg [31:0] inst_addr_o;

    wire [2:0] pause_en;
    assign pause_en = (pause_flag_i >= `Pause_If);

    always @(posedge clk or negedge rst_n)
    if(!rst_n)
        inst_o <= 32'h0;
    else if(pause_en)
        inst_o <= 32'h0;
    else
        inst_o <= inst_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n)
        inst_addr_o <= 32'h0;
    else if(pause_en)
        inst_addr_o <= 32'h0;
    else
        inst_addr_o <= inst_addr_i;
    
    
endmodule