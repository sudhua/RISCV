`include "../core/defines.v"
module tinyriscv_soc_top
    (
    input clk,
    input rst_n
);

    // tiny_riscv module output signal
    wire [31:0]	tv_inst_addr_o;
    wire [31:0] tv_mem_raddr_o;
    wire        tv_mem_we_o;
    wire        tv_mem_req_o;
    wire [31:0]	tv_mem_waddr_o;
    wire [31:0]	tv_mem_wdata_o;
    wire [31:0] tv_rib_pc_o;
    

    // rom module output signal
    wire [31:0]	rom_data_o;

    // rom module output signal
    wire [31:0]	ram_mem_rdata_o;
    // timer module output signal
    wire [31:0] 	timer_rdata_o;
    wire [31:0] 	timer_int_signal_o;
    // rib module output signal
    wire [31:0] 	m0_rdata_o;
    wire [31:0] 	m1_rdata_o;
    wire        	s0_we_o;
    wire [31:0] 	s0_addr_o;
    wire [31:0] 	s0_wdata_o;
    wire        	s1_we_o;
    wire [31:0] 	s1_addr_o;
    wire [31:0] 	s1_wdata_o;
    wire        	s2_we_o;
    wire [31:0] 	s2_addr_o;
    wire [31:0] 	s2_wdata_o;
    wire        	hold_flag_o;

    wire [31:0] int_req_o;
    assign int_req_o = timer_int_signal_o;
    wire [31:0] m0_addr;

    assign m0_addr = ( tv_mem_we_o == `WriteEnable ) ? tv_mem_waddr_o : tv_mem_raddr_o;

    tiny_riscv u_tiny_riscv(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .inst_i      		( m1_rdata_o      	),
        .inst_addr_o 		( tv_inst_addr_o 	),
        .mem_raddr_o        ( tv_mem_raddr_o    ),
        .mem_we_o           ( tv_mem_we_o       ),
        .mem_req_o          ( tv_mem_req_o      ),
        .mem_waddr_o        ( tv_mem_waddr_o    ),
        .mem_wdata_o        ( tv_mem_wdata_o    ),
        .mem_rdata_i        ( m0_rdata_o        ),
        .int_req_i          ( int_req_o         ),
        .rib_pc_o           ( tv_rib_pc_o       ),
        .rib_hold_flag_i    ( hold_flag_o       )

    );

    rom u_rom(
        //ports
        .clk    		( clk    		    ),
        .rst_n  		( rst_n  		    ),
        .addr_i 		( s0_addr_o 	),
        .data_o 		( rom_data_o 		)
    );

    ram u_ram(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .mem_we_i    		( s1_we_o    	),
        .mem_waddr_i 		( s1_addr_o 	),
        .mem_wdata_i 		( s1_wdata_o 	),
        .mem_raddr_i 		( s1_addr_o 	),
        .mem_rdata_o 		( ram_mem_rdata_o 	)
    );

    timer u_timer(
        // ports
        .clk          	( clk           ),
        .rst_n        	( rst_n         ),
        .we_i         	( s2_we_o          ),
        .addr_i       	( s2_addr_o        ),
        .wdata_i      	( s2_wdata_o       ),
        .rdata_o      	( timer_rdata_o       ),
        .int_signal_o 	( timer_int_signal_o  )
    );


rib u_rib(
	// ports
	.clk         	( clk               ),
	.rst_n       	( rst_n             ),
	.m0_rdata_o  	( m0_rdata_o        ),
	.m0_req_i    	( tv_mem_req_o      ),
	.m0_we_i     	( tv_mem_we_o       ),
	.m0_addr_i   	( m0_addr           ),
	.m0_wdata_i  	( tv_mem_wdata_o    ),
	.m1_rdata_o  	( m1_rdata_o        ),
	.m1_req_i    	( `RIB_REQ          ),
	.m1_we_i     	( `WriteDisable     ),
	.m1_addr_i   	( tv_rib_pc_o       ),
	.m1_wdata_i  	( `ZeroWord         ),
	.s0_we_o     	(  s0_we_o          ),
	.s0_addr_o   	( s0_addr_o         ),
	.s0_wdata_o  	( s0_wdata_o        ),
	.s0_rdata_i  	( rom_data_o        ),
	.s1_we_o     	( s1_we_o           ),
	.s1_addr_o   	( s1_addr_o         ),
	.s1_wdata_o  	( s1_wdata_o        ),
	.s1_rdata_i  	( ram_mem_rdata_o   ),
	.s2_we_o     	( s2_we_o           ),
	.s2_addr_o   	( s2_addr_o         ),
	.s2_wdata_o  	( s2_wdata_o        ),
	.s2_rdata_i  	( timer_rdata_o     ),
	.hold_flag_o 	( hold_flag_o       )
);




endmodule