`include "defines.v"

module pc_reg
    (
    input               clk            ,
    input               rst_n          ,
    // from ctrl
    input [31:0]        jump_addr_i    ,
    input               jump_flag_i    ,
    input [2:0]         hold_flag_i    ,
    // to if_id
    output reg [31:0]   pc_o
);
    always@ (posedge clk or negedge rst_n)
        if(!rst_n)
            pc_o <= 32'h0;
        else if(jump_flag_i == `JumpEnable)
            pc_o <= jump_addr_i;
        else if(hold_flag_i >= `Pause_Pc)
            pc_o <= pc_o;
        else
            pc_o <= pc_o + 4'h4;

endmodule
