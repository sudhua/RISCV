`include "defines.v"

module pc_reg(
    clk,
    rst_n,
    // from ctrl
    jump_addr_i,
    jump_flag_i,
    // to if_id
    pc_o
);
    input wire clk;
    input wire rst_n;
    input wire [31:0] jump_addr_i;
    input wire jump_flag_i;
    output reg [`ADDR_WIDTH] pc_o;
    always@ (posedge clk or negedge rst_n)
        if(!rst_n)
            pc_o <= 32'h0;
        else if(jump_flag_i == `JumpEnable)
            pc_o <= jump_addr_i;
        else 
            pc_o <= pc_o + 3'h4;

    
endmodule 