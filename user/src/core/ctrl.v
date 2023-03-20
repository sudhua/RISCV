`include "defines.v"

module ctrl
    (
    input               rst_n,
    // from ex
    input [31:0]        jump_addr_i,
    input               jump_flag_i,
    input               hold_flag_ex_i,
    // from clint
    input               clint_hold_flag_i,
    // to pc_reg 
    output reg [31:0]   jump_addr_o,
    output reg          jump_flag_o,
    // to if_id id_ex pc_reg
    output reg [2:0]    hold_flag_o,
    // from rib
    input               rib_hold_flag_i
    );

    always @(*)
    begin
        jump_addr_o = jump_addr_i;
        jump_flag_o = jump_flag_i;
        hold_flag_o = 1'b0;
        if(jump_flag_i == `JumpEnable | hold_flag_ex_i == `Set | clint_hold_flag_i == `HoldEnable)
            hold_flag_o = `Pause_Id;
        else if (rib_hold_flag_i == `Set)
            hold_flag_o = `Pause_Pc;
        else
            hold_flag_o = hold_flag_o;
    end
    
endmodule
