`include "defines.v"

module ex(
    rst_n,
    // from id_ex
    inst_i,
    inst_addr_i,
    reg_waddr_i,
    reg_we_i,
    op1_i,
    op2_i,
    // from ram
    mem_rdata_i,
    // to regs
    reg_wdata_o,
    reg_we_o,
    reg_waddr_o,
    // to pc_reg
    jump_addr_o,
    jump_flag_o,
    // to ram
    mem_we_o,
    mem_waddr_o,
    mem_wdata_o,
    mem_raddr_o
);
    input rst_n;
    input [31:0] inst_i;
    input [31:0] inst_addr_i;
    input [4:0] reg_waddr_i;
    input reg_we_i;
    input [31:0] op1_i;
    input [31:0] op2_i;
    input [31:0] mem_rdata_i;

    output reg [31:0] reg_wdata_o;
    output reg reg_we_o;
    output reg [4:0] reg_waddr_o;

    output reg [31:0] jump_addr_o;
    output reg jump_flag_o;

    output reg mem_we_o;
    output reg [31:0] mem_waddr_o;
    output reg [31:0] mem_wdata_o;
    output reg [31:0] mem_raddr_o;


    wire [6:0] funct7;
    wire [4:0] rs2;
    wire [4:0] rs1;
    wire [2:0] funct3;
    wire [4:0] rd;
    wire [6:0] opcode;

    assign funct7 = inst_i[31:25];
    assign rs2 = inst_i[24:20];
    assign rs1 = inst_i[19:15];
    assign funct3 = inst_i[14:12];
    assign rd = inst_i[11:7];
    assign opcode = inst_i[6:0];

    wire [31:0] Imm_Inst_B;
    wire [31:0] Imm_Inst_J;
    wire [31:0] Imm_Inst_I;

    assign Imm_Inst_B = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    assign Imm_Inst_J = {{11{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    assign Imm_Inst_I = {{20{inst_i[31]}}, inst_i[31:20]};

    wire [31:0] current_pc;
    assign current_pc = inst_addr_i;

    wire [31:0] jump_addr_jalr;
    assign jump_addr_jalr = (op1_i + Imm_Inst_I)& 32'hffff_fffe;

    wire [1:0] mem_waddr_index;
    assign mem_waddr_index = mem_waddr_o[1:0];
    wire [1:0] mem_raddr_index;
    assign mem_raddr_index = mem_raddr_o[1:0];

    wire [63:0] mul_temp;
    reg [31:0] mul_op1;
    reg [31:0] mul_op2;
    wire [31:0] op1_i_complement;
    wire [31:0] op2_i_complement;
    wire [63:0] mul_temp_complement;
    assign mul_temp = mul_op1 * mul_op2;
    assign op1_i_complement = ~op1_i + 32'b1;
    assign op2_i_complement = ~op2_i + 32'b1;
    assign mul_temp_complement = ~mul_temp + 64'b1;

    always @(*)begin
        if((funct7 == 7'b0000001) || (opcode == `INST_TYPE_R_M))
            case(funct3)
                `INST_MUL, `INST_MULHU:begin
                    mul_op1 = op1_i;
                    mul_op2 = op2_i;
                end
                `INST_MULH:begin
                    mul_op1 = (op1_i[31] == 1'b1) ? op1_i_complement : op1_i;
                    mul_op2 = (op2_i[31] == 1'b1) ? op2_i_complement : op2_i;
                end
                `INST_MULHSU:begin
                    mul_op1 = (op1_i[31] == 1'b1) ? op1_i_complement : op1_i;
                    mul_op2 = op2_i;
                end
                default:begin
                    mul_op1 = mul_op1;
                    mul_op1 = mul_op1;
                end
            endcase
    
    end
    always @(*)begin
        // to regs
        reg_waddr_o = reg_waddr_i;
        reg_wdata_o = `ZeroWord;
        reg_we_o = reg_we_i;
        // to pc_reg
        jump_addr_o = `ZeroWord;
        jump_flag_o = `JumpDisable;
        // to ram
        mem_we_o = `WriteDisable;
        mem_waddr_o = `ZeroWord;
        mem_wdata_o = `ZeroWord;
        case(opcode)
            `INST_TYPE_I:
                case(funct3)
                    `INST_ADDI:begin
                        reg_wdata_o = op1_i + op2_i;
                    end
                    `INST_XORI:begin
                        reg_wdata_o = op1_i ^ op2_i;
                    
                    end
                    `INST_ORI:begin
                        reg_wdata_o = op1_i | op2_i;
                    
                    end
                    `INST_ANDI:begin
                        reg_wdata_o = op1_i & op2_i;
                    
                    end
                    `INST_SLLI:begin // Shift Left Logical Immediate
                        reg_wdata_o = op1_i << inst_i[24:20];
                    end
                    `INST_SRI:begin
                        if(inst_i[30] == 1'b1) // Shift Right Arithmetic Immediate
                            reg_wdata_o = (op1_i >> inst_i[24:20]) | ({32{op1_i[31]}} & (~(32'hffff_ffff >> inst_i[24:20])));
                        else // Shift Right Logical Immediate
                            reg_wdata_o = op1_i >> inst_i[24:20];
                    end
                    `INST_SLTI:begin
                        reg_wdata_o = ($signed(op1_i) < $signed(op2_i)) ? 1 : 0;
                    end
                    `INST_SLTIU:begin
                        reg_wdata_o = (op1_i < op2_i) ? 1 : 0;
                        end
                    default:begin
                        reg_wdata_o = `ZeroWord;
                    end
                endcase
            `INST_TYPE_R_M:
                if((funct7 == 7'b0100000) || (funct7 == 7'b000000))
                    case(funct3)
                        `INST_ADD_SUB:begin
                            if(inst_i[30] == 1'b1)
                                reg_wdata_o = op1_i - op2_i;
                            else
                                reg_wdata_o = op1_i + op2_i;
                        end
                        `INST_XOR:begin
                            reg_wdata_o = op1_i ^ op2_i;
                        end
                        `INST_OR:begin
                            reg_wdata_o = op1_i | op2_i;
                        
                        end
                        `INST_AND:begin
                            reg_wdata_o = op1_i & op2_i;
                        
                        end
                        `INST_SLL:begin // Shift Left Logical Immediate
                            reg_wdata_o = op1_i << op2_i[4:0];
                        end
                        `INST_SR:begin
                            if(inst_i[30] == 1'b1) // Shift Right Arithmetic Immediate
                                reg_wdata_o = (op1_i >> op2_i[4:0]) | ({32{op1_i[31]}} & (~(32'hffff_ffff >> op2_i[4:0])));
                            else // Shift Right Logical Immediate
                                reg_wdata_o = op1_i >> op2_i[4:0];
                        end
                        `INST_SLT:begin
                            reg_wdata_o = ($signed(op1_i) < $signed(op2_i)) ? 1 : 0;
                        end
                        `INST_SLTU:begin
                            reg_wdata_o = (op1_i < op2_i) ? 1 : 0;
                            end
                        default:begin
                            reg_wdata_o = `ZeroWord;
                        end
                    endcase
                else if (funct7 == 7'b0000001)
                    case(funct3)
                        `INST_MUL:
                            reg_wdata_o = mul_temp[31:0];
                        `INST_MULHU:
                            reg_wdata_o = mul_temp[63:32];
                        `INST_MULHSU:
                            reg_wdata_o = (op1_i[31] == 1'b1) ? mul_temp_complement[63:32] : mul_temp[63:32];
                        `INST_MULH:
                            case({op1_i[31],op2_i[31]})
                                2'b00:
                                    reg_wdata_o = mul_temp[63:32];
                                2'b01: 
                                    reg_wdata_o = mul_temp_complement[63:32];
                                2'b10:
                                    reg_wdata_o = mul_temp_complement[63:32];
                                default:
                                    reg_wdata_o = mul_temp[63:32];
                            endcase
                        default:
                            reg_wdata_o = `ZeroWord;
                    endcase

            `INST_TYPE_B:
                case(funct3)
                    `INST_BEQ:begin
                        if(op1_i == op2_i)begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    `INST_BNE:begin
                        if(op1_i != op2_i)begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    `INST_BLT:begin
                        if($signed(op1_i) < $signed(op2_i))begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    `INST_BGE:begin
                        if($signed(op1_i) >= $signed(op2_i))begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    `INST_BLTU:begin // Shift Left Logical Immediate 
                        if(op1_i < op2_i)begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    `INST_BGEU:begin
                        if(op1_i >= op2_i)begin
                            jump_flag_o = `JumpEnable;
                            jump_addr_o = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr_o = `ZeroWord;
                            jump_flag_o = `JumpDisable;
                        end
                    end
                    default:begin
                        jump_addr_o = `ZeroWord;
                        jump_flag_o = `JumpDisable;
                    end
                endcase
            `INST_TYPE_JAL:begin
                jump_flag_o = `JumpEnable;
                jump_addr_o = current_pc + Imm_Inst_J;
                reg_wdata_o = current_pc + 3'h4;
            end
            `INST_TYPE_JALR:
                case(funct3)
                    `INST_JALR:begin
                        jump_flag_o = `JumpEnable;
                        jump_addr_o = jump_addr_jalr;
                        reg_wdata_o = current_pc + 3'h4;
                    end
                    default:begin
                         jump_flag_o = `JumpDisable;
                         reg_wdata_o = `ZeroWord;
                    end
                endcase
            `INST_TYPE_LUI, `INST_TYPE_AUIPC:begin
                reg_wdata_o = op1_i + op2_i;
             end
            `INST_TYPE_S:
                case(funct3)
                    `INST_SB:begin
                        mem_we_o = `WriteEnable; 
                        mem_waddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        case(mem_waddr_index)//RISC_V 是小端模式 - 低字节存储在低地址
                            2'h0:
                                mem_wdata_o = {mem_rdata_i[31:8], op2_i[7:0]};
                            2'h1:
                                mem_wdata_o = {mem_rdata_i[31:16], op2_i[7:0], mem_rdata_i[7:0]};
                            2'h2:
                                mem_wdata_o = {mem_rdata_i[31:24], op2_i[7:0], mem_rdata_i[15:0]};
                            default:
                                mem_wdata_o = { op2_i[7:0], mem_rdata_i[23:0]};
                        endcase
                    end
                    `INST_SH:begin
                        mem_we_o = `WriteEnable;
                        mem_waddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        case(mem_waddr_index)
                            2'h0:
                                mem_wdata_o = {mem_rdata_i[31:16], op2_i[15:0]};
                            default:
                                mem_wdata_o = { op2_i[15:0], mem_rdata_i[15:0]};
                        endcase   
                    end
                    `INST_SW:begin
                        mem_we_o = `WriteEnable;
                        mem_waddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_wdata_o = op2_i;
                    end
                    default: begin
                        mem_we_o = `WriteDisable;
                        mem_waddr_o = `ZeroWord;
                        mem_raddr_o = `ZeroWord;
                    end
                endcase
            `INST_TYPE_L:
                case(funct3)
                    `INST_LB:begin
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata_o = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                            2'h1:
                                reg_wdata_o = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                            2'h2:
                                reg_wdata_o = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                            default:
                                reg_wdata_o = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                        endcase
                       
                    end
                    `INST_LH:begin
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata_o = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                            default:
                                reg_wdata_o = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                        endcase
                    end
                    `INST_LW:begin
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        reg_wdata_o = mem_rdata_i;   
                    end
                    `INST_LBU:begin
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata_o = {24'h0, mem_rdata_i[7:0]};
                            2'h1:
                                reg_wdata_o = {24'h0, mem_rdata_i[15:8]};
                            2'h2:
                                reg_wdata_o = {24'h0, mem_rdata_i[23:16]};
                            default:
                                reg_wdata_o = {24'h0, mem_rdata_i[31:24]};
                        endcase
                    end
                    `INST_LHU:begin
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata_o = {16'h0, mem_rdata_i[15:0]};
                            default:
                                reg_wdata_o = {16'h0, mem_rdata_i[31:16]};
                        endcase
                    end
                    default:begin
                        mem_raddr_o = `ZeroWord;
                        reg_wdata_o = `ZeroWord;
                    end
                endcase
            default:begin
                //reg_waddr_o = `ZeroWord;
                jump_addr_o = `ZeroWord;
                jump_flag_o = `JumpDisable;
                mem_we_o = `WriteDisable;
                mem_waddr_o = `ZeroWord;
                mem_wdata_o = `ZeroWord;
            end
            
        endcase
    end


endmodule