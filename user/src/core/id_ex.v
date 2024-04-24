`include "defines.v"

module id_ex
    (
    input               clk,
    input               rst_n,
    // from id
    input [31:0]        inst_i,
    input [31:0]        inst_addr_i,
    input [4:0]         reg_waddr_i,
    input               reg_we_i,
    input [31:0]        op1_i,
    input [31:0]        op2_i,
    input               csr_we_i, 
    input [31:0]        csr_waddr_i,
    input [31:0]        csr_rdata_i,
    //from ctrl 
    input [2:0]         hold_flag_i,
    // to ex
    output reg [31:0]   inst_o,
    output reg [31:0]   inst_addr_o,
    output reg [4:0]    reg_waddr_o,
    output reg          reg_we_o,
    output reg [31:0]   op1_o,
    output reg [31:0]   op2_o,
    output reg          csr_we_o, 
    output reg [31:0]   csr_waddr_o,
    output reg [31:0]   csr_rdata_o

);

    wire [2:0] hold_en;

    assign hold_en = (hold_flag_i >= `Pause_Id);

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     inst_o <= `ZeroWord       ;
    else                     inst_o <= inst_i          ;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     inst_addr_o <= `ZeroWord  ;
    else                     inst_addr_o <= inst_addr_i;
    
    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     reg_waddr_o <= `ZeroWord  ;
    else                     reg_waddr_o <= reg_waddr_i;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     reg_we_o <= `WriteDisable ;
    else                     reg_we_o <= reg_we_i      ;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     op1_o <= `ZeroWord        ;
    else                     op1_o <= op1_i            ;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     op2_o <= `ZeroWord        ;
    else                     op2_o <= op2_i            ;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     csr_we_o <= `WriteDisable ;
    else                     csr_we_o <= csr_we_i      ;

    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     csr_waddr_o <= `ZeroWord  ;
    else                     csr_waddr_o <= csr_waddr_i;
    
    always @(posedge clk or negedge rst_n)
    if(!rst_n | hold_en)     csr_rdata_o <= `ZeroWord  ;
    else                     csr_rdata_o <= csr_rdata_i;
    

endmodule
