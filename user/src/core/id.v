`include "defines.v"

module id
    (
    input               clk,
    input               rst_n,
    // from if_id
    input [31:0]        inst_i,
    input [31:0]        inst_addr_i,
    // from regs
    input [31:0]        reg_rdata1_i,
    input [31:0]        reg_rdata2_i,
    // to regs
    output reg [4:0]    reg_raddr1_o,
    output reg [4:0]    reg_raddr2_o,        
    // to id_ex
    output reg [31:0]   inst_o,
    output reg [31:0]   inst_addr_o,
    output reg          reg_we_o,
    output reg [4:0]    reg_waddr_o,
    output reg [31:0]   op1_o,
    output reg [31:0]   op2_o,
    output reg          csr_we_o,
    output reg [31:0]   csr_waddr_o,
    output reg [31:0]   csr_rdata_o,
    // from csr_reg
    input [31:0]        csr_rdata_i,
    // to csr_reg
    output reg [31:0]   csr_raddr_o
);
    
    wire [6:0]  funct7     ;
    wire [4:0]  rs2        ;
    wire [4:0]  rs1        ;
    wire [2:0]  funct3     ;
    wire [4:0]  rd         ;
    wire [6:0]  opcode     ;
    wire [31:0] csr_raddr  ;
    wire [31:0] csr_zimm   ;

    assign funct7    = inst_i[31:25]           ;
    assign rs2       = inst_i[24:20]           ;
    assign rs1       = inst_i[19:15]           ;
    assign funct3    = inst_i[14:12]           ;
    assign rd        = inst_i[11:7]            ;
    assign opcode    = inst_i[6:0]             ;
    assign csr_addr  = {20'b0, inst_i[31:20]}  ;
    //assign csr_zimm = {27'b0,inst_i[19:15]};

	// CSR 寄存器有LATCH 生成 后续需要解决
    always @(*)begin
      inst_o       = inst_i       ;
      inst_addr_o  = inst_addr_i  ;
      //to regs
      reg_raddr1_o = `ZeroWord    ;
      reg_raddr2_o = `ZeroWord    ;     
      //to id_ex
      reg_waddr_o  = `ZeroWord    ;
      reg_we_o     = `WriteDisable;
      op1_o        = `ZeroWord    ;
      op2_o        = `ZeroWord    ;

      case (opcode) 
          `INST_TYPE_I:
              case(funct3)
                  `INST_ADDI, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRI, `INST_SLTI, `INST_SLTIU:begin
                      reg_we_o     = `WriteEnable                     ;
                      reg_waddr_o  = rd                               ;
                      reg_raddr1_o = rs1                              ;
                      reg_raddr2_o = `ZeroReg                         ;
                      op1_o        = reg_rdata1_i                     ;
                      op2_o        = {{20{inst_i[31]}},inst_i[31:20]} ;
                  end
                  default:begin 
                      reg_we_o     = `WriteDisable  ;
                      reg_waddr_o  = `ZeroReg       ;
                      reg_raddr1_o = `ZeroReg       ;
                      reg_raddr2_o = `ZeroReg       ;
                      op1_o        = `ZeroWord      ;
                      op2_o        = `ZeroWord      ;
                  end
              endcase
          `INST_TYPE_R_M:
              if((funct7 == 7'b0100000) || (funct7 == 7'b0000000))
                  case(funct3)
                          `INST_ADD_SUB, `INST_XOR, `INST_OR, `INST_AND, `INST_SLL, `INST_SR, `INST_SLT, `INST_SLTU:begin
                              reg_we_o      =   `WriteEnable   ;
                              reg_waddr_o   =   rd             ;
                              reg_raddr1_o  =   rs1            ;
                              reg_raddr2_o  =   rs2            ;
                              op1_o         =   reg_rdata1_i   ;
                              op2_o         =   reg_rdata2_i   ;
                          end
                          default:begin 
                              reg_we_o      = `WriteDisable    ;
                              reg_waddr_o   = `ZeroReg         ;
                              reg_raddr1_o  = `ZeroReg         ;
                              reg_raddr2_o  = `ZeroReg         ;
                              op1_o         = `ZeroWord        ;
                              op2_o         = `ZeroWord        ;
                          end
                  endcase
              else if(funct7 == 7'b0000001)
                  case(funct3)
                      `INST_MUL, `INST_MULH, `INST_MULHSU, `INST_MULHU:begin
                          reg_we_o          = `WriteEnable     ;
                          reg_waddr_o       = rd               ;
                          reg_raddr1_o      = rs1              ;
                          reg_raddr2_o      = rs2              ;
                          op1_o             = reg_rdata1_i     ;
                          op2_o             = reg_rdata2_i     ;
                      end
                      `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU:begin
                          reg_we_o          = `WriteDisable    ;
                          reg_waddr_o       = rd               ;
                          reg_raddr1_o      = rs1              ;
                          reg_raddr2_o      = rs2              ;
                          op1_o             = reg_rdata1_i     ;
                          op2_o             = reg_rdata2_i     ;
                      end
                      default:begin
                          reg_we_o          = `WriteDisable    ;
                          reg_waddr_o       = `ZeroReg         ;
                          reg_raddr1_o      = `ZeroReg         ;
                          reg_raddr2_o      = `ZeroReg         ;
                          op1_o             = `ZeroWord        ;
                          op2_o             = `ZeroWord        ;
                      end
                  endcase
              else begin
                  reg_we_o     = `WriteDisable  ;
                  reg_waddr_o  = `ZeroReg       ;
                  reg_raddr1_o = `ZeroReg       ;
                  reg_raddr2_o = `ZeroReg       ;
                  op1_o        = `ZeroWord      ;
                  op2_o        = `ZeroWord      ;
              end
              `INST_TYPE_B:
              case(funct3)
                  `INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU:begin
                      reg_we_o     = `WriteDisable ;
                      reg_waddr_o  = `ZeroReg      ;
                      reg_raddr1_o = rs1           ;
                      reg_raddr2_o = rs2           ;
                      op1_o        = reg_rdata1_i  ;
                      op2_o        = reg_rdata2_i  ;
                  end
                  default:begin 
                      reg_we_o     = `WriteDisable ;
                      reg_waddr_o  = `ZeroReg      ;
                      reg_raddr1_o = `ZeroReg      ;
                      reg_raddr2_o = `ZeroReg      ;
                      op1_o        = `ZeroWord     ;
                      op2_o        = `ZeroWord     ;
                  end
              endcase
          `INST_TYPE_JAL:begin
              reg_we_o     = `WriteEnable  ;
              reg_waddr_o  = rd            ;
              reg_raddr1_o = `ZeroReg      ;
              reg_raddr2_o = `ZeroReg      ;
              op1_o        = `ZeroWord     ;
              op2_o        = `ZeroWord     ;
          end
          `INST_TYPE_JALR:
              case(funct3)
                  `INST_JALR:begin
                      reg_we_o     = `WriteEnable ;
                      reg_waddr_o  = rd           ;
                      reg_raddr1_o = rs1          ;
                      reg_raddr2_o = `ZeroReg     ;
                      op1_o        = reg_rdata1_i ;
                      op2_o        = `ZeroWord    ;
                  end
                  default:begin
                      reg_we_o     = `WriteDisable;
                      reg_waddr_o  = `ZeroReg     ;
                      reg_raddr1_o = `ZeroReg     ;
                      reg_raddr2_o = `ZeroReg     ;
                      op1_o        = `ZeroWord    ;
                      op2_o        = `ZeroWord    ;
                  end
              endcase
          `INST_TYPE_LUI:begin
              reg_we_o     = `WriteEnable;
              reg_waddr_o  = rd;
              reg_raddr1_o = `ZeroReg;
              reg_raddr2_o = `ZeroReg;
              op1_o        = ({{12{inst_i[31]}}, inst_i[31:12]} << 4'd12) & 32'hffff_f000;
              op2_o        = `ZeroWord;
          end
          `INST_TYPE_AUIPC:begin
              reg_we_o     = `WriteEnable;
              reg_waddr_o  = rd;
              reg_raddr1_o = `ZeroReg;
              reg_raddr2_o = `ZeroReg;
              op1_o        =  ({{12{inst_i[31]}}, inst_i[31:12]} << 4'd12) & 32'hffff_f000;
              op2_o        = inst_addr_i;
          end
          `INST_TYPE_S:begin
              case(funct3)
                  `INST_SB, `INST_SH, `INST_SW:begin
                      reg_we_o     = `WriteDisable ;
                      reg_waddr_o  = `ZeroWord     ;
                      reg_raddr1_o = rs1           ;
                      reg_raddr2_o = rs2           ;
                      op1_o        = reg_rdata1_i  ;
                      op2_o        = reg_rdata2_i  ;
                  end
                  default:begin
                      reg_we_o     = `WriteDisable;
                      reg_waddr_o  = `ZeroReg     ;
                      reg_raddr1_o = `ZeroReg     ;
                      reg_raddr2_o = `ZeroReg     ;
                      op1_o        = `ZeroWord    ;
                      op2_o        = `ZeroWord    ;
                  end
              endcase
          end
          `INST_TYPE_L:
          case(funct3)
              `INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU:begin
                  reg_we_o     = `WriteEnable;
                  reg_waddr_o  = rd          ;
                  reg_raddr1_o = rs1         ;
                  reg_raddr2_o = `ZeroWord   ;
                  op1_o        = reg_rdata1_i;
                  op2_o        = `ZeroWord   ;
              end
              default:begin
                  reg_we_o     = `WriteDisable;
                  reg_waddr_o  = `ZeroReg     ;
                  reg_raddr1_o = `ZeroReg     ;
                  reg_raddr2_o = `ZeroReg     ;
                  op1_o        = `ZeroWord    ;
                  op2_o        = `ZeroWord    ;
              end
          endcase
      `INST_TYPE_CSR:
          case(funct3)
              `INST_CSRRW, `INST_CSRRS, `INST_CSRRC:begin
                  reg_we_o     = `WriteEnable ;
                  reg_waddr_o  = rd           ;
                  reg_raddr1_o = rs1          ;
                  reg_raddr2_o = `ZeroWord    ;
                  op1_o        = reg_rdata1_i ;
                  op2_o        = `ZeroWord    ;
                  csr_raddr_o  = csr_addr     ;
                  csr_rdata_o  = csr_rdata_i  ;
                  csr_we_o     = `WriteEnable ;
                  csr_waddr_o  = csr_addr     ;
              end
              `INST_CSRRWI, `INST_CSRRSI, `INST_CSRRCI:begin
                  reg_we_o     = `WriteEnable ;
                  reg_waddr_o  = rd           ;
                  reg_raddr1_o = `ZeroWord    ;
                  reg_raddr2_o = `ZeroWord    ;
                  op1_o        = `ZeroWord    ;
                  op2_o        = `ZeroWord    ;
                  csr_raddr_o  = csr_addr     ;
                  csr_rdata_o  = csr_rdata_i  ;
                  csr_we_o     = `WriteEnable ;
                  csr_waddr_o  = csr_addr     ;
              end
              default:begin
                  reg_we_o     = `WriteDisable;
                  reg_waddr_o  = `ZeroReg     ;
                  reg_raddr1_o = `ZeroReg     ;
                  reg_raddr2_o = `ZeroReg     ;
                  op1_o        = `ZeroWord    ;
                  op2_o        = `ZeroWord    ;
                  csr_raddr_o  = `ZeroWord    ;
                  csr_rdata_o  = `ZeroWord    ;
                  csr_we_o     = `WriteDisable;
                  csr_waddr_o  = `ZeroWord    ;
              end
          endcase
      default:begin
          reg_we_o     = `WriteDisable;
          reg_waddr_o  = `ZeroReg     ;
          reg_raddr1_o = `ZeroReg     ;
          reg_raddr2_o = `ZeroReg     ;
          op1_o        = `ZeroWord    ;
          op2_o        = `ZeroWord    ;
          csr_raddr_o  = `ZeroWord    ;
          csr_rdata_o  = `ZeroWord    ;
          csr_we_o     = `WriteDisable;
          csr_waddr_o  = `ZeroWord    ;
      end

      endcase
    end

endmodule
