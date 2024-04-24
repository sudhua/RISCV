`include "defines.v"

module ex
    (
    input               rst_n,
    // from id_ex
    input [31:0]        inst_i,
    input [31:0]        inst_addr_i,
    input [4:0]         reg_waddr_i,
    input               reg_we_i,
    input [31:0]        op1_i,
    input [31:0]        op2_i,
    input               csr_we_i,
    input [31:0]        csr_waddr_i,
    input [31:0]        csr_rdata_i,
    // from ram
    input [31:0]        mem_rdata_i,
    // to regs
    output [31:0]       reg_wdata_o,
    output              reg_we_o,
    output[4:0]         reg_waddr_o,
    // to ctrl
    output[31:0]        jump_addr_o,
    output              jump_flag_o,
    output reg          hold_flag_ex_o,
    // to ram
    output reg          mem_we_o,
    output reg          mem_req_o,
    output reg [31:0]   mem_waddr_o,
    output reg [31:0]   mem_wdata_o,
    output reg [31:0]   mem_raddr_o,

    // from div
    input [31:0]        div_result_i,   // 除法结果输出
    input               div_busy_i,     // 除法计算中标志
    input               div_ready_i,    // 计算完成标志
    // to div
    output reg          div_strat_o,
    output reg [2:0]    div_op_o,       // 除法指令类型输入
    output reg [31:0]   dividend_o,     // 被除数输入
    output reg [31:0]   divisor_o,      // 除数输入
    // to csr_reg
    output reg          csr_we_o,       // csr寄存器写使能
    output reg [31:0]   csr_waddr_o,    // csr寄存器写地址
    output reg [31:0]   csr_wdata_o,    // csr寄存器写数据
    // from clints
    input               trap_en_i,
    input [31:0]        trap_addr_i

);

    reg [31:0]  mul_op1;
    reg [31:0]  mul_op2;
    reg         div_jump_flag;
    reg [31:0]  div_jump_addr;
    reg [31:0]  div_reg_waddr;
    reg         div_reg_we;
    reg [31:0]  div_reg_wdata;
    reg [31:0]  div_reg_waddr_tmp;
    reg         jump_flag;
    reg [31:0]  jump_addr;
    reg         reg_we;
    reg [31:0]  reg_wdata;
    reg [31:0]  reg_waddr;
    
    wire [6:0]  funct7;
    wire [4:0]  rs2;
    wire [4:0]  rs1;
    wire [2:0]  funct3;
    wire [4:0]  rd;
    wire [6:0]  opcode;
    wire [31:0] Imm_Inst_B;
    wire [31:0] Imm_Inst_J;
    wire [31:0] Imm_Inst_I;
    wire [31:0] current_pc;
    wire [31:0] jump_addr_jalr;
    wire [1:0]  mem_waddr_index;
    wire [1:0]  mem_raddr_index;
    wire [63:0] mul_temp;
    wire [31:0] op1_i_complement;
    wire [31:0] op2_i_complement;
    wire [63:0] mul_temp_complement;
    wire [31:0] Zimm;

    assign funct7 = inst_i[31:25];
    assign rs2 = inst_i[24:20];
    assign rs1 = inst_i[19:15];
    assign funct3 = inst_i[14:12];
    assign rd = inst_i[11:7];
    assign opcode = inst_i[6:0];
    assign Imm_Inst_B = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    assign Imm_Inst_J = {{11{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    assign Imm_Inst_I = {{20{inst_i[31]}}, inst_i[31:20]};
    assign current_pc = inst_addr_i;
    assign jump_addr_jalr = (op1_i + Imm_Inst_I)& 32'hffff_fffe;
    assign mem_waddr_index = mem_waddr_o[1:0];
    assign mem_raddr_index = mem_raddr_o[1:0];
    assign mul_temp = mul_op1 * mul_op2;
    assign op1_i_complement = ~op1_i + 32'b1;
    assign op2_i_complement = ~op2_i + 32'b1;
    assign mul_temp_complement = ~mul_temp + 64'b1;
    assign jump_flag_o = (trap_en_i == `TrapEnable) ? `JumpEnable : (jump_flag | div_jump_flag);
    assign jump_addr_o = (trap_en_i == `TrapEnable) ? trap_addr_i : (jump_addr | div_jump_addr);
    assign reg_we_o = reg_we | div_reg_we;
    assign reg_wdata_o = reg_wdata | div_reg_wdata;
    assign reg_waddr_o = reg_waddr | div_reg_waddr;
    assign Zimm = {27'b0,inst_i[19:15]};
    // 处理除法
    always @(*)begin
        div_op_o      = funct3        ;
        dividend_o    = op1_i         ;
        divisor_o     = op2_i         ;
        div_jump_flag = `Reset        ;
        div_jump_addr = `ZeroWord     ;
        div_reg_we    = `WriteDisable ;
        div_reg_waddr = reg_waddr_i   ;
        div_reg_wdata = `ZeroWord     ;
        if((funct7 == 7'b0000001) || (opcode == `INST_TYPE_R_M))
            case(funct3)
                `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU:begin
                    div_strat_o       = `DivStart;
                    div_jump_flag     = `JumpEnable;
                    div_jump_addr     = inst_addr_i + 3'h4; //div为多周期计算，当流水线暂停时，流水线上的地址全为0，故用跳转保存除法的后一条指令的地址
                    div_reg_we        = `WriteDisable;
                    div_reg_waddr_tmp = div_reg_waddr;
                end
                default:begin
                    div_strat_o       = `DivStop;
                    div_jump_flag     = `JumpDisable;
                    div_jump_addr     = `ZeroWord;
                    div_reg_we        = `WriteDisable;
                    div_reg_waddr_tmp = `ZeroWord;
                end
            endcase
        if(div_ready_i == `ResultReady)begin
            div_strat_o   = `DivStop;
            div_reg_we    = `WriteEnable;
            div_reg_waddr =  div_reg_waddr_tmp;
            div_reg_wdata = div_result_i;
        end
        else begin
            div_strat_o   = div_strat_o;
            div_reg_we    = `WriteDisable;
            div_reg_waddr =  `ZeroWord;
            div_reg_wdata = `ZeroWord;
        end
        if (div_busy_i) begin
            hold_flag_ex_o = 1;
            div_jump_flag  = `JumpDisable;
            div_jump_addr  = `ZeroWord;
            
        end
        else begin
            hold_flag_ex_o = 0;
            div_jump_flag  = div_jump_flag;
            div_jump_addr  = div_jump_addr;
        end
    end




    // 处理乘法
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
        reg_we      = reg_we_i;
        reg_waddr   = reg_waddr_i;
        reg_wdata   = `ZeroWord;
        // to pc_reg
        jump_addr   = `ZeroWord;
        jump_flag   = `JumpDisable;
        // to ram
        mem_we_o    = `WriteDisable;
        mem_waddr_o = `ZeroWord;
        mem_wdata_o = `ZeroWord;
        mem_req_o   = `RIB_NREQ;
        // to csr_reg
        csr_we_o    = csr_we_i;
        csr_waddr_o = csr_waddr_i;
        csr_wdata_o = `ZeroWord;
        case(opcode)
            `INST_TYPE_I:
                case(funct3)
                    `INST_ADDI:begin
                        reg_wdata = op1_i + op2_i;
                    end
                    `INST_XORI:begin
                        reg_wdata = op1_i ^ op2_i;
                    
                    end
                    `INST_ORI:begin
                        reg_wdata = op1_i | op2_i;
                    
                    end
                    `INST_ANDI:begin
                        reg_wdata = op1_i & op2_i;
                    
                    end
                    `INST_SLLI:begin // Shift Left Logical Immediate
                        reg_wdata = op1_i << inst_i[24:20];
                    end
                    `INST_SRI:begin
                        if(inst_i[30] == 1'b1) // Shift Right Arithmetic Immediate
                            reg_wdata = (op1_i >> inst_i[24:20]) | ({32{op1_i[31]}} & (~(32'hffff_ffff >> inst_i[24:20])));
                        else // Shift Right Logical Immediate
                            reg_wdata = op1_i >> inst_i[24:20];
                    end
                    `INST_SLTI:begin
                        reg_wdata = ($signed(op1_i) < $signed(op2_i)) ? 1 : 0;
                    end
                    `INST_SLTIU:begin
                        reg_wdata = (op1_i < op2_i) ? 1 : 0;
                        end
                    default:begin
                        reg_wdata = `ZeroWord;
                    end
                endcase
            `INST_TYPE_R_M:
                if((funct7 == 7'b0100000) || (funct7 == 7'b000000))
                    case(funct3)
                        `INST_ADD_SUB:begin
                            if(inst_i[30] == 1'b1)
                                reg_wdata = op1_i - op2_i;
                            else
                                reg_wdata = op1_i + op2_i;
                        end
                        `INST_XOR:begin
                            reg_wdata = op1_i ^ op2_i;
                        end
                        `INST_OR:begin
                            reg_wdata = op1_i | op2_i;
                        
                        end
                        `INST_AND:begin
                            reg_wdata = op1_i & op2_i;
                        
                        end
                        `INST_SLL:begin // Shift Left Logical Immediate
                            reg_wdata = op1_i << op2_i[4:0];
                        end
                        `INST_SR:begin
                            if(inst_i[30] == 1'b1) // Shift Right Arithmetic Immediate
                                reg_wdata = (op1_i >> op2_i[4:0]) | ({32{op1_i[31]}} & (~(32'hffff_ffff >> op2_i[4:0])));
                            else // Shift Right Logical Immediate
                                reg_wdata = op1_i >> op2_i[4:0];
                        end
                        `INST_SLT:begin
                            reg_wdata = ($signed(op1_i) < $signed(op2_i)) ? 1 : 0;
                        end
                        `INST_SLTU:begin
                            reg_wdata = (op1_i < op2_i) ? 1 : 0;
                            end
                        default:begin
                            reg_wdata = `ZeroWord;
                        end
                    endcase
                else if (funct7 == 7'b0000001)
                    case(funct3)
                        `INST_MUL:
                            reg_wdata = mul_temp[31:0];
                        `INST_MULHU:
                            reg_wdata = mul_temp[63:32];
                        `INST_MULHSU:
                            reg_wdata = (op1_i[31] == 1'b1) ? mul_temp_complement[63:32] : mul_temp[63:32];
                        `INST_MULH:
                            case({op1_i[31],op2_i[31]})
                                2'b00:
                                    reg_wdata = mul_temp[63:32];
                                2'b01: 
                                    reg_wdata = mul_temp_complement[63:32];
                                2'b10:
                                    reg_wdata = mul_temp_complement[63:32];
                                default:
                                    reg_wdata = mul_temp[63:32];
                            endcase
                        default:
                            reg_wdata = `ZeroWord;
                    endcase

            `INST_TYPE_B:
                case(funct3)
                    `INST_BEQ:begin
                        if(op1_i == op2_i)begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    `INST_BNE:begin
                        if(op1_i != op2_i)begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    `INST_BLT:begin
                        if($signed(op1_i) < $signed(op2_i))begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    `INST_BGE:begin
                        if($signed(op1_i) >= $signed(op2_i))begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    `INST_BLTU:begin // Shift Left Logical Immediate 
                        if(op1_i < op2_i)begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    `INST_BGEU:begin
                        if(op1_i >= op2_i)begin
                            jump_flag = `JumpEnable;
                            jump_addr = current_pc + Imm_Inst_B;
                        end
                        else begin
                            jump_addr = `ZeroWord;
                            jump_flag = `JumpDisable;
                        end
                    end
                    default:begin
                        jump_addr = `ZeroWord;
                        jump_flag = `JumpDisable;
                    end
                endcase
            `INST_TYPE_JAL:begin
                jump_flag = `JumpEnable;
                jump_addr = current_pc + Imm_Inst_J;
                reg_wdata = current_pc + 3'h4;
            end
            `INST_TYPE_JALR:
                case(funct3)
                    `INST_JALR:begin
                        jump_flag = `JumpEnable;
                        jump_addr = jump_addr_jalr;
                        reg_wdata = current_pc + 3'h4;
                    end
                    default:begin
                         jump_flag = `JumpDisable;
                         reg_wdata = `ZeroWord;
                    end
                endcase
            `INST_TYPE_LUI, `INST_TYPE_AUIPC:begin
                reg_wdata = op1_i + op2_i;
             end
            `INST_TYPE_S:
                case(funct3)
                    `INST_SB:begin
                        mem_we_o = `WriteEnable;
                        mem_req_o = `RIB_REQ; 
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
                        mem_req_o = `RIB_REQ; 
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
                        mem_req_o = `RIB_REQ; 
                        mem_waddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        mem_wdata_o = op2_i;
                    end
                    default: begin
                        mem_we_o = `WriteDisable;
                        mem_req_o = `RIB_NREQ; 
                        mem_waddr_o = `ZeroWord;
                        mem_raddr_o = `ZeroWord;
                    end
                endcase
            `INST_TYPE_L:
                case(funct3)
                    `INST_LB:begin
                        mem_req_o = `RIB_REQ;
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                            2'h1:
                                reg_wdata = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                            2'h2:
                                reg_wdata = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                            default:
                                reg_wdata = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                        endcase
                       
                    end
                    `INST_LH:begin
                        mem_req_o = `RIB_REQ;
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                            default:
                                reg_wdata = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                        endcase
                    end
                    `INST_LW:begin
                        mem_req_o = `RIB_REQ;
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        reg_wdata = mem_rdata_i;   
                    end
                    `INST_LBU:begin
                        mem_req_o = `RIB_REQ;
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata = {24'h0, mem_rdata_i[7:0]};
                            2'h1:
                                reg_wdata = {24'h0, mem_rdata_i[15:8]};
                            2'h2:
                                reg_wdata = {24'h0, mem_rdata_i[23:16]};
                            default:
                                reg_wdata = {24'h0, mem_rdata_i[31:24]};
                        endcase
                    end
                    `INST_LHU:begin
                        mem_req_o = `RIB_REQ;
                        mem_raddr_o = op1_i + {{20{inst_i[31]}}, inst_i[31:20]};
                        case(mem_raddr_index)
                            2'h0:
                                reg_wdata = {16'h0, mem_rdata_i[15:0]};
                            default:
                                reg_wdata = {16'h0, mem_rdata_i[31:16]};
                        endcase
                    end
                    default:begin
                        mem_req_o = `RIB_NREQ;
                        mem_raddr_o = `ZeroWord;
                        reg_wdata = `ZeroWord;
                    end
                endcase

            `INST_TYPE_CSR:
                case(funct3)
                    `INST_CSRRW: begin
                        reg_wdata = csr_rdata_i;
                        csr_wdata_o = op1_i;
                    end
                    `INST_CSRRS: begin
                        csr_wdata_o = (op1_i | csr_rdata_i);
                        reg_wdata = csr_rdata_i;
                    end
                    `INST_CSRRC: begin
                        csr_wdata_o = (op1_i & csr_rdata_i);
                        reg_wdata = csr_rdata_i;
                    end
                    `INST_CSRRWI: begin
                        csr_wdata_o = Zimm;
                        reg_wdata = csr_rdata_i;
                    end
                    `INST_CSRRSI: begin
                        csr_wdata_o = (op1_i | Zimm);
                        reg_wdata = csr_rdata_i;
                    end
                    `INST_CSRRCI: begin
                        csr_wdata_o =  (op1_i & Zimm);
                        reg_wdata = csr_rdata_i;
                    end
                    default: begin
                        csr_wdata_o = `ZeroWord;
                        reg_wdata = `ZeroWord;
                    end
                endcase
            default:begin
                //reg_waddr_o = `ZeroWord;
                jump_addr = `ZeroWord;
                jump_flag = `JumpDisable;
                mem_we_o = `WriteDisable;
                mem_waddr_o = `ZeroWord;
                mem_wdata_o = `ZeroWord;
            end
            
        endcase
    end


endmodule
