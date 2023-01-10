`define ADDR_WIDTH 31:0
`define ROM_ADDR_NUM 4096 

`define WriteEnable  1'b1
`define WriteDisable 1'b0

`define JumpEnable  1'b1
`define JumpDisable 1'b0

`define ZeroReg 4'h0
`define ZeroWord 32'h0

`define Pause_Id 3'h2
`define Pause_If 3'h1
//inst type

`define INST_TYPE_R_M 7'b0110011
`define INST_TYPE_I 7'b0010011
`define INST_TYPE_S 7'b0100011
`define INST_TYPE_B 7'b1100011

`define INST_TYPE_LUI 7'b0110111
`define INST_TYPE_AUIPC 7'b0010111

`define INST_TYPE_JAL 7'b1101111
`define INST_TYPE_JALR 7'b1100111
`define INST_TYPE_L 7'b0000011 
//`define INST_TYPE_J 7'b1101111
//inst_type_i
`define INST_ADDI  3'h0
`define INST_XORI  3'h4
`define INST_ORI   3'h6
`define INST_ANDI  3'h7
`define INST_SLLI  3'h1
`define INST_SRI   3'h5
`define INST_SLTI  3'h2
`define INST_SLTIU 3'h3
//inst_type_r_m
`define INST_ADD_SUB 3'h0
`define INST_XOR 3'h4
`define INST_OR 3'h6
`define INST_AND 3'h7
`define INST_SLL 3'h1
`define INST_SR  3'h5
`define INST_SLT 3'h2
`define INST_SLTU 3'h3
`define INST_ADD_SUB 3'h0
`define INST_MUL 3'h0
`define INST_MULH 3'h1
`define INST_MULHSU 3'h2
`define INST_MULHU 3'h3
`define INST_DIV 3'h4
`define INST_DIVU 3'h5
`define INST_REM 3'h6
`define INST_REMU 3'h7

//inst_type_s
`define INST_SB 3'h0
`define INST_SH 3'h1
`define INST_SW 3'h2
//inst_type_b
`define INST_BEQ 3'h0
`define INST_BNE 3'h1
`define INST_BLT 3'h4
`define INST_BGE 3'h5
`define INST_BLTU 3'h6
`define INST_BGEU 3'h7
//
`define INST_JALR 3'h0
// inst_type_l
`define INST_LB 3'h0
`define INST_LH 3'h1
`define INST_LW 3'h2
`define INST_LBU 3'h4
`define INST_LHU 3'h5
