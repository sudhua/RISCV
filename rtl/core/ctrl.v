`include "defines.v"
module ctrl(
    rst_n,
    // from ex
    jump_addr_i,
    jump_flag_i,
    // to pc_reg 
    jump_addr_o,
    jump_flag_o,
    // to if_id 、id_ex
    pause_flag_o
    );
    input rst_n;
    input [31:0] jump_addr_i;
    input jump_flag_i;
    output reg [31:0] jump_addr_o;
    output reg jump_flag_o; 
    output reg [2:0]pause_flag_o;

    always @(*)begin
        jump_addr_o = jump_addr_i;
        jump_flag_o = jump_flag_i;
        pause_flag_o = 1'b0;
        if(jump_flag_i == `JumpEnable)
            pause_flag_o = `Pause_Id;
        else
            pause_flag_o = pause_flag_o;

    end





endmodule
