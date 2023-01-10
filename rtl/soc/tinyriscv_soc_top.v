
module tinyriscv_soc_top(
    clk,
    rst_n
);
    input clk;
    input rst_n;

    // tiny_riscv module output signal
    wire [31:0]	tv_inst_addr_o;
    wire [31:0] tv_mem_raddr_o;
    wire tv_mem_we_o;
    wire [31:0]	tv_mem_waddr_o;
    wire [31:0]	tv_mem_wdata_o;

    // rom module output signal
    wire [31:0]	rom_data_o;

    // rom module output signal
    wire [31:0]	ram_mem_rdata_o;
    tiny_riscv u_tiny_riscv(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .inst_i      		( rom_data_o      	),
        .inst_addr_o 		( tv_inst_addr_o 	),
        .mem_raddr_o        ( tv_mem_raddr_o    ),
        .mem_we_o           ( tv_mem_we_o       ),
        .mem_waddr_o        ( tv_mem_waddr_o    ),
        .mem_wdata_o        ( tv_mem_wdata_o    ),
        .mem_rdata_i        ( ram_mem_rdata_o   )
    );

    rom u_rom(
        //ports
        .clk    		( clk    		    ),
        .rst_n  		( rst_n  		    ),
        .addr_i 		( tv_inst_addr_o 	),
        .data_o 		( rom_data_o 		)
    );

    ram u_ram(
        //ports
        .clk         		( clk         		),
        .rst_n       		( rst_n       		),
        .mem_we_i    		( tv_mem_we_o    	),
        .mem_waddr_i 		( tv_mem_waddr_o 	),
        .mem_wdata_i 		( tv_mem_wdata_o 	),
        .mem_raddr_i 		( tv_mem_raddr_o 	),
        .mem_rdata_o 		( ram_mem_rdata_o 	)
    );


endmodule