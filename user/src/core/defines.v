`define ADDR_WIDTH 31:0
`define ROM_ADDR_NUM 4096 

`define WriteEnable  1'b1
`define WriteDisable 1'b0

`define JumpEnable  1'b1
`define JumpDisable 1'b0

`define ZeroReg 4'h0
`define ZeroWord 32'h0

`define Reset 1'b0
`define Set 1'b1
`define Pause_Id 3'h2
`define Pause_If 3'h1

`define ResultReady 1'b1
`define ResultNoReady 1'b0

`define DivStart 1'b1
`define DivStop 1'b0

`define  TrapEnable 1'b1
`define  TrapDisable 1'b0
`define  INT_NONE 32'b0
`define  HoldEnable 1'b1
`define  HoldDisable 1'b1
//inst type

`define INST_TYPE_R_M 7'b0110011
`define INST_TYPE_I 7'b0010011
`define INST_TYPE_S 7'b0100011
`define INST_TYPE_B 7'b1100011
`define INST_TYPE_CSR 7'b1110011

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
// inst_type_csr
`define INST_CSRRW 3'h1
`define INST_CSRRS 3'h2
`define INST_CSRRC 3'h3
`define INST_CSRRWI 3'h5
`define INST_CSRRSI 3'h6
`define INST_CSRRCI 3'h7
// CSR
`define CSR_MTVEC     12'h305
`define CSR_MEPC      12'h341
`define CSR_MCAUSE    12'h342
`define CSR_MIE       12'h304
`define CSR_MIP       12'h344
`define CSR_MTVAL     12'h343
`define CSR_MSCRATCH  12'h340
`define CSR_MSTATUS   12'h300

`define INST_EBREAK   32'b000000000001_00000_000_00000_1110011
`define INST_ECALL   32'b000000000000_00000_000_00000_1110011
`define INST_MRET  32'b0011000_00010_00000_000_00000_1110011


