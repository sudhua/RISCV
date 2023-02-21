`include "../core/defines.v"

module rom
    (
    input               clk,   
    input               rst_n,
    // form pc_reg
    input [31:0]        addr_i,
    // to if_id
    output reg [31:0]   data_o
);
    reg [31:0] _rom [0 : 4095];

    always @(*)
        if(!rst_n)
            data_o <= 0;
        else
            data_o <= _rom[addr_i[31:2]];

endmodule