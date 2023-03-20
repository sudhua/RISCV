`include "defines.v"
module rib
    (
        input clk,
        input rst_n,

        output reg [31:0]   m0_rdata_o, // 主设备0读数据
        input               m0_req_i, // 主设备0访问外设请求
        input               m0_we_i, // 主设备0写使能
        input [31:0]        m0_addr_i, // 主设备0读/写地址
        input [31:0]        m0_wdata_i, // 主设备0写数据

        output reg [31:0]   m1_rdata_o,
        input               m1_req_i,
        input               m1_we_i,
        input [31:0]        m1_addr_i,
        input [31:0]        m1_wdata_i,

        output reg          s0_we_o, // 从设备0写使能
        output reg [31:0]   s0_addr_o, // 从设备0读/写地址
        output reg [31:0]   s0_wdata_o, // 从设备0写数据
        input [31:0]        s0_rdata_i, // 从设备0读数据

        output reg          s1_we_o, // 从设备0写使能
        output reg [31:0]   s1_addr_o, // 从设备0读/写地址
        output reg [31:0]   s1_wdata_o, // 从设备0写数据
        input [31:0]        s1_rdata_i, // 从设备0读数据
        
        output reg          s2_we_o, // 从设备0写使能
        output reg [31:0]   s2_addr_o, // 从设备0读/写地址
        output reg [31:0]   s2_wdata_o, // 从设备0写数据
        input [31:0]        s2_rdata_i, // 从设备0读数据

        output reg          hold_flag_o
    );
    /*
    m0 cpu
    m1 pc_reg
    ...
     
    s0 rom
    s1 ram
    s2 timer
    ...
    */

    localparam  SLAVE_0 = 4'b0000,
                SLAVE_1 = 4'b0001,
                SLAVE_2 = 4'b0010;

    localparam  HOST_0 = 2'b0,
                HOST_1 = 2'b1;


    wire [1:0] m_req;
    reg host;
    assign m_req = {m1_req_i,m0_req_i};

    always @(*)
        if(!rst_n) begin
            host = HOST_1;
            hold_flag_o = `HoldDisable;
        end
        else if(m_req[0] == 1'b1)begin
            host = HOST_0;
            hold_flag_o = `HoldEnable;
        end
        else begin
            host = HOST_1;
            hold_flag_o = `HoldDisable;
        end


    always @(*)begin
        m0_rdata_o = `ZeroWord;
        m1_rdata_o = `INST_NOP;

        s0_we_o = `WriteDisable;
        s1_we_o = `WriteDisable;
        s2_we_o = `WriteDisable;
        
        s0_addr_o = `ZeroWord; 
        s1_addr_o = `ZeroWord; 
        s2_addr_o = `ZeroWord; 

        s0_wdata_o = `ZeroWord;
        s1_wdata_o = `ZeroWord;
        s2_wdata_o = `ZeroWord;
        case(host)
            HOST_0:
                case(m0_addr_i[31:28])
                    SLAVE_0: begin 
                        s0_we_o = `WriteDisable;
                        s0_addr_o = m0_addr_i;
                        s0_wdata_o = `ZeroWord;
                        m0_rdata_o = s0_rdata_i;
                    end
                    SLAVE_1: begin
                        s1_we_o = `WriteEnable;
                        s1_addr_o = m0_addr_i;
                        s1_wdata_o = m0_wdata_i;
                        m0_rdata_o = s1_rdata_i;
                    end
                    SLAVE_2: begin
                        s2_we_o = `WriteEnable;
                        s2_addr_o = m0_addr_i;
                        s2_wdata_o = m0_wdata_i;
                        m0_rdata_o = s2_rdata_i;
                    end
                    default: begin
                        
                    end
                endcase
            HOST_1:
                case(m1_addr_i[31:28])
                        SLAVE_0: begin 
                            s0_we_o = `WriteDisable;
                            s0_addr_o = m1_addr_i;
                            s0_wdata_o = `ZeroWord;
                            m1_rdata_o = s0_rdata_i;
                        end
                        SLAVE_1: begin
                            s1_we_o = `WriteEnable;
                            s1_addr_o = m1_addr_i;
                            s1_wdata_o = m1_wdata_i;
                            m1_rdata_o = s1_rdata_i;
                        end
                        SLAVE_2: begin
                            s2_we_o = `WriteEnable;
                            s2_addr_o = m1_addr_i;
                            s2_wdata_o = m1_wdata_i;
                            m1_rdata_o = s2_rdata_i;
                        end
                        default: begin
                            
                        end
                endcase
            default: begin

            end
        endcase
        
        end


endmodule
