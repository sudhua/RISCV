`include "defines.v"

module tiny_riscv(
        clk,
        rst_n,
        inst_i,
        inst_addr_o,
        mem_raddr_o,
        mem_we_o,
        mem_waddr_o,
        mem_wdata_o,
        mem_rdata_i
    );
    input clk;
    input rst_n;
    input [31:0] inst_i;
    output [31:0] inst_addr_o;
    output [31:0] mem_raddr_o;
    output mem_we_o;
    output [31:0] mem_waddr_o;
    output [31:0] mem_wdata_o;
    input [31:0] mem_rdata_i;

    //ctrl module output signal
    wire [31:0]	ctrl_jump_addr_o;
    wire ctrl_jump_flag_o;
    wire [2:0]	ctrl_pause_flag_o;

    // pc_reg module output signal
    wire [31:0]	pc_reg_pc_o;

    // if_id module output signal
    wire [31:0]	if_id_inst_o;
    wire [31:0]	if_id_inst_addr_o;

    // regs module output signal
    wire [31:0]	regs_reg_data1_o;
    wire [31:0]	regs_reg_data2_o;

    // id module output signal
    wire [31:0]	id_inst_o;
    wire [31:0]	id_inst_addr_o;
    wire [4:0]	id_reg_waddr_o;
    wire id_reg_we_o;
    wire [4:0]	id_reg_raddr1_o;
    wire [4:0]	id_reg_raddr2_o;
    wire [31:0]	id_op1_o;
    wire [31:0]	id_op2_o;

    // id_ex module output signal
    wire [31:0]	id_ex_inst_o;
    wire [31:0]	id_ex_inst_addr_o;
    wire [4:0]	id_ex_reg_waddr_o;
    wire id_ex_reg_we_o;
    wire [31:0]	id_ex_op1_o;
    wire [31:0]	id_ex_op2_o;

    // ex module output signal
    wire [31:0]	ex_reg_wdata_o;
    wire ex_reg_we_o;
    wire [4:0]	ex_reg_waddr_o;
    wire [31:0] ex_jump_addr_o;
    wire ex_jump_flag_o;
    wire ex_mem_we_o;
    wire [31:0] ex_mem_waddr_o;
    wire [31:0] ex_mem_wdata_o;
    wire [31:0] ex_mem_raddr_o;


    //assign inst_i = rom_data_o;
    assign inst_addr_o = pc_reg_pc_o;
    assign mem_we_o = ex_mem_we_o;
    assign mem_waddr_o = ex_mem_waddr_o;
    assign mem_wdata_o = ex_mem_wdata_o;
    assign mem_raddr_o = ex_mem_raddr_o;

    ctrl u_ctrl(
        //ports
        .rst_n        		( rst_n        		),
        .jump_addr_i  		( ex_jump_addr_o  	),
        .jump_flag_i  		( ex_jump_flag_o  	),
        .jump_addr_o  		( ctrl_jump_addr_o  ),
        .jump_flag_o  		( ctrl_jump_flag_o  ),
        .pause_flag_o 		( ctrl_pause_flag_o )
    );

    pc_reg u_pc_reg(
        //ports
        .clk   		( clk   		    ),
        .rst_n 		( rst_n 		    ),
        .jump_addr_i( ctrl_jump_addr_o  ),
        .jump_flag_i( ctrl_jump_flag_o  ),
        .pc_o  		( pc_reg_pc_o  	    )   
    );

    if_id u_if_id(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .inst_i      		( inst_i      	    ),
        .inst_addr_i 		( pc_reg_pc_o       ),
        .pause_flag_i       ( ctrl_pause_flag_o ),
        .inst_o      		( if_id_inst_o      ),
        .inst_addr_o 		( if_id_inst_addr_o )
    );

    regs u_regs(
        //ports
        .clk          		( clk          		),
        .rst_n        		( rst_n        		),
        .reg_raddr1_i 		( id_reg_raddr1_o 	),
        .reg_raddr2_i 		( id_reg_raddr2_o 	),
        .reg_we_i     		( ex_reg_we_o     	),
        .reg_waddr_i  		( ex_reg_waddr_o  	),
        .reg_wdata_i  		( ex_reg_wdata_o  	),
        .reg_data1_o  		( regs_reg_data1_o  ),
        .reg_data2_o  		( regs_reg_data2_o  )
    );


    id u_id(
        //ports
        .clk          		( clk          		),
        .rst_n        		( rst_n        		),
        .inst_i       		( if_id_inst_o      ),
        .inst_addr_i  		( if_id_inst_addr_o ),
        .reg_rdata1_i 		( regs_reg_data1_o 	),
        .reg_rdata2_i 		( regs_reg_data2_o 	),
        .inst_o       		( id_inst_o       	),
        .inst_addr_o  		( id_inst_addr_o  	),
        .reg_waddr_o  		( id_reg_waddr_o  	),
        .reg_we_o     		( id_reg_we_o     	),
        .reg_raddr1_o 		( id_reg_raddr1_o 	),
        .reg_raddr2_o 		( id_reg_raddr2_o 	),
        .op1_o        		( id_op1_o        	),
        .op2_o        		( id_op2_o        	)
    );

    id_ex u_id_ex(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .inst_i      		( id_inst_o      	),
        .inst_addr_i 		( id_inst_addr_o 	),
        .reg_waddr_i 		( id_reg_waddr_o 	),
        .reg_we_i    		( id_reg_we_o    	),
        .op1_i       		( id_op1_o       	),
        .op2_i       		( id_op2_o       	),
        .pause_flag_i       ( ctrl_pause_flag_o ),
        .inst_o      		( id_ex_inst_o      ),
        .inst_addr_o 		( id_ex_inst_addr_o ),
        .reg_waddr_o 		( id_ex_reg_waddr_o ),
        .reg_we_o    		( id_ex_reg_we_o    ),
        .op1_o       		( id_ex_op1_o       ),
        .op2_o       		( id_ex_op2_o       )
    );

    ex u_ex(
        //ports
        .rst_n       		( rst_n       		),
        .inst_i      		( id_ex_inst_o      ),
        .inst_addr_i 		( id_ex_inst_addr_o ),
        .reg_waddr_i 		( id_ex_reg_waddr_o ),
        .reg_we_i    		( id_ex_reg_we_o    ),
        .op1_i       		( id_ex_op1_o       ),
        .op2_i       		( id_ex_op2_o       ),
        .mem_rdata_i        ( mem_rdata_i       ),
        .reg_wdata_o 		( ex_reg_wdata_o 	),
        .reg_we_o    		( ex_reg_we_o    	),
        .reg_waddr_o 		( ex_reg_waddr_o 	),
        .jump_addr_o        ( ex_jump_addr_o 	),
        .jump_flag_o        ( ex_jump_flag_o	),
        .mem_we_o           ( ex_mem_we_o       ),
        .mem_waddr_o        ( ex_mem_waddr_o    ),
        .mem_wdata_o        ( ex_mem_wdata_o    ),
        .mem_raddr_o        ( ex_mem_raddr_o    )
    );


endmodule
