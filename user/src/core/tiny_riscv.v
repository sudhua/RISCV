`include "defines.v"

module tiny_riscv
    (
    input           clk,
    input           rst_n,
    input [31:0]    inst_i,
    output [31:0]   inst_addr_o,
    output          mem_we_o,
    output          mem_req_o,
    output [31:0]   mem_waddr_o,
    output [31:0]   mem_wdata_o,
    input [31:0]    mem_rdata_i,
    output [31:0]   mem_raddr_o,
    input [31:0]    int_req_i,
    output [31:0]   rib_pc_o,
    input           rib_hold_flag_i
);
    // ctrl module output signal
    wire [31:0]	    ctrl_jump_addr_o;
    wire            ctrl_jump_flag_o;
    wire [2:0]	    ctrl_hold_flag_o;
    // pc_reg module output signal
    wire [31:0]	    pc_reg_pc_o;
    // if_id module output signal
    wire [31:0]	    if_id_inst_o;
    wire [31:0]	    if_id_inst_addr_o;
    // regs module output signal
    wire [31:0]	    regs_reg_data1_o;
    wire [31:0]	    regs_reg_data2_o;
    // id module output signal
    wire [31:0]	    id_inst_o;
    wire [31:0]	    id_inst_addr_o;
    wire [4:0]	    id_reg_waddr_o;
    wire            id_reg_we_o;
    wire [4:0]	    id_reg_raddr1_o;
    wire [4:0]	    id_reg_raddr2_o;
    wire [31:0]	    id_op1_o;
    wire [31:0]	    id_op2_o;
    wire            id_csr_we_o;
    wire [31:0]	    id_csr_waddr_o;
    wire [31:0]	    id_csr_rdata_o;
    wire [31:0]	    id_csr_raddr_o;

    // id_ex module output signal
    wire [31:0]	    id_ex_inst_o;
    wire [31:0]	    id_ex_inst_addr_o;
    wire [4:0]	    id_ex_reg_waddr_o;
    wire            id_ex_reg_we_o;
    wire [31:0]	    id_ex_op1_o;
    wire [31:0]	    id_ex_op2_o;
    wire    	    id_ex_csr_we_o;
    wire [31:0]	    id_ex_csr_waddr_o;
    wire [31:0]	    id_ex_csr_rdata_o;
    // ex module output signal
    wire [31:0]	    ex_reg_wdata_o;
    wire            ex_reg_we_o;
    wire [4:0]	    ex_reg_waddr_o;
    wire [31:0]     ex_jump_addr_o;
    wire            ex_jump_flag_o;
    wire            ex_hold_flag_ex_o;
    wire            ex_mem_we_o;
    wire            ex_mem_req_o;    
    wire [31:0]     ex_mem_waddr_o;
    wire [31:0]     ex_mem_wdata_o;
    wire [31:0]     ex_mem_raddr_o;
    wire            ex_div_strat_o;
    wire [2:0]      ex_div_op_o;   
    wire [31:0]     ex_dividend_o; 
    wire [31:0]     ex_divisor_o;
    wire            ex_csr_we_o;
    wire [31:0]     ex_csr_waddr_o;
    wire [31:0]     ex_csr_wdata_o;

    // div module output signal
    wire [31:0]     div_result_o;  
    wire            div_busy_o;    
    wire            div_ready_o; 
    
    // csr_reg module output signal  
    wire [31:0] 	csr_rdata_o;
    wire [31:0] 	csr_mepc_o;
    wire [31:0] 	csr_mstatus_o;
    wire [31:0] 	csr_mtvec_o;
    wire        	csr_global_int_en_o;
    // clint module output signal  
    wire        	clint_csr_we_o;
    wire [31:0] 	clint_csr_waddr_o;
    wire [31:0] 	clint_csr_wdata_o;
    wire        	clint_trap_en_o;
    wire [31:0] 	clint_trap_addr_o;

    // assign inst_i = rom_data_o;
    assign inst_addr_o = pc_reg_pc_o;
    assign mem_we_o = ex_mem_we_o;
    assign mem_waddr_o = ex_mem_waddr_o;
    assign mem_wdata_o = ex_mem_wdata_o;
    assign mem_raddr_o = ex_mem_raddr_o;
    assign rib_pc_o = pc_reg_pc_o;
    assign rib_inst_i = pc_reg_pc_o;

    assign mem_req_o = ex_mem_req_o;

    ctrl u_ctrl(
        //ports
        .rst_n        		( rst_n        		),
        .jump_addr_i  		( ex_jump_addr_o  	),
        .jump_flag_i  		( ex_jump_flag_o  	),
        .hold_flag_ex_i     ( ex_hold_flag_ex_o ),
        .jump_addr_o  		( ctrl_jump_addr_o  ),
        .jump_flag_o  		( ctrl_jump_flag_o  ),
        .hold_flag_o 		( ctrl_hold_flag_o  )
    );

    pc_reg u_pc_reg(
        //ports
        .clk   		( clk   		    ),
        .rst_n 		( rst_n 		    ),
        .jump_addr_i( ctrl_jump_addr_o  ),
        .jump_flag_i( ctrl_jump_flag_o  ),
        .hold_flag_i( ctrl_hold_flag_o   ),
        .pc_o  		( pc_reg_pc_o  	    )   
    );

    if_id u_if_id(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .inst_i      		( inst_i      	    ),
        .inst_addr_i 		( pc_reg_pc_o       ),
        .hold_flag_i        ( ctrl_hold_flag_o  ),
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
        .op2_o        		( id_op2_o        	),
        .csr_we_o           ( id_csr_we_o       ),
        .csr_waddr_o        ( id_csr_waddr_o    ),
        .csr_rdata_o        ( id_csr_rdata_o    ),
        .csr_rdata_i        ( csr_rdata_o       ),
        .csr_raddr_o        ( id_csr_raddr_o    )
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
        .hold_flag_i        ( ctrl_hold_flag_o  ),
        .inst_o      		( id_ex_inst_o      ),
        .inst_addr_o 		( id_ex_inst_addr_o ),
        .reg_waddr_o 		( id_ex_reg_waddr_o ),
        .reg_we_o    		( id_ex_reg_we_o    ),
        .op1_o       		( id_ex_op1_o       ),
        .op2_o       		( id_ex_op2_o       ),
        .csr_we_o       	( id_ex_csr_we_o    ),
        .csr_waddr_o       	( id_ex_csr_waddr_o ),
        .csr_rdata_o       	( id_ex_csr_rdata_o )

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
        .csr_we_i       	( id_ex_csr_we_o    ),
        .csr_waddr_i       	( id_ex_csr_waddr_o ),
        .csr_rdata_i       	( id_ex_csr_rdata_o ),
        .mem_rdata_i        ( mem_rdata_i       ),
        .reg_wdata_o 		( ex_reg_wdata_o 	),
        .reg_we_o    		( ex_reg_we_o    	),
        .reg_waddr_o 		( ex_reg_waddr_o 	),
        .jump_addr_o        ( ex_jump_addr_o 	),
        .jump_flag_o        ( ex_jump_flag_o	),
        .hold_flag_ex_o     ( ex_hold_flag_ex_o ),
        .mem_we_o           ( ex_mem_we_o       ),
        .mem_req_o          ( ex_mem_req_o      ),
        .mem_waddr_o        ( ex_mem_waddr_o    ),
        .mem_wdata_o        ( ex_mem_wdata_o    ),
        .mem_raddr_o        ( ex_mem_raddr_o    ),
        .div_result_i       ( div_result_o      ),
        .div_busy_i         ( div_busy_o        ),
        .div_ready_i        ( div_ready_o       ),
        .div_strat_o        ( ex_div_strat_o    ),
        .div_op_o           ( ex_div_op_o       ),
        .dividend_o         ( ex_dividend_o     ),
        .divisor_o          ( ex_divisor_o      ),
        .csr_we_o           ( ex_csr_we_o       ),
        .csr_waddr_o        ( ex_csr_waddr_o    ),
        .csr_wdata_o        ( ex_csr_wdata_o    ),
        .trap_en_i          ( clint_trap_en_o   ),
        .trap_addr_i        ( clint_trap_addr_o )
    );
    div u_div(
        //ports
        .clk              		( clk              	),
        .rst_n            		( rst_n            	),
        .start_i  		        ( ex_div_strat_o    ),
        .op_i       		    ( ex_div_op_o       ),
        .dividend_i        		( ex_dividend_o     ),
        .divisor_i 		        ( ex_divisor_o      ),
        .result_o     		    ( div_result_o      ),
        .busy_o  		        ( div_busy_o        ),
        .ready_o                ( div_ready_o       )
    );

    csr_reg u_csr_reg(
        // ports
        .clk             	( clk                  ),
        .rst_n           	( rst_n                ),
        .we_i            	( ex_csr_we_o          ),
        .waddr_i         	( ex_csr_waddr_o       ),
        .wdata_i         	( ex_csr_wdata_o       ),
        .rdata_o         	( csr_rdata_o          ),
        .raddr_i         	( id_csr_raddr_o       ),
        .clint_we_i      	( clint_csr_we_o       ),
        .clint_waddr_i   	( clint_csr_waddr_o    ),
        .clint_wdata_i   	( clint_csr_wdata_o    ),
        .mepc_o        	    ( csr_mepc_o           ),
        .mstatus_o       	( csr_mstatus_o        ),
        .mtvec_o         	( csr_mtvec_o          ),
        .global_int_en_o 	( csr_global_int_en_o  )
    );

    clint u_clint(
        // ports
        .clk             	( clk                 ),
        .rst_n           	( rst_n               ),
        .int_req_i       	( int_req_i           ),
        .inst_i          	( id_inst_o           ),
        .inst_addr_i     	( id_inst_addr_o      ),
        .csr_mtvec_i     	( csr_mtvec_o         ),
        .csr_mstatus_i   	( csr_mstatus_o       ),
        .csr_mepc_i      	( csr_mepc_o          ),
        .global_int_en_i 	( csr_global_int_en_o ),
        .csr_we_o        	( clint_csr_we_o      ),
        .csr_waddr_o     	( clint_csr_waddr_o   ),
        .csr_wdata_o     	( clint_csr_wdata_o   ),
        .jump_flag_i     	( ex_jump_flag_o      ),
        .jump_addr_i     	( ex_jump_addr_o      ),
        .div_start_i     	( ex_div_strat_o      ),
        .trap_en_o       	( clint_trap_en_o     ),
        .trap_addr_o     	( clint_trap_addr_o   )
    );
endmodule
