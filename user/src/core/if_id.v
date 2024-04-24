`include "defines.v"

module if_id
    (
    input               clk          ,
    input               rst_n        ,
    //from pc_reg
    input [31:0]        inst_i       , // 指令
    input [31:0]        inst_addr_i  , // 指令地址
    //from ctrl 
    input [2:0]         hold_flag_i  ,
    // to id
    output reg [31:0]   inst_o       ,
    output reg [31:0]   inst_addr_o
);

    wire [2:0] pause_en;
    assign pause_en = (hold_flag_i >= `Pause_If);

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
    else if(pause_en)         // 暂停时，为何地址被置为0？
        inst_addr_o <= 32'h0; 
    else
        inst_addr_o <= inst_addr_i;
    
    
endmodule
