`timescale 1ns / 1ns

`define TEST_PROG 1

module testbench;
    reg clk;
    reg rst_n;

    tinyriscv_soc_top u_tinyriscv_soc_top(
        //ports
        .clk   		( clk   		),
        .rst_n 		( rst_n 		)
    );

    // clk
    initial clk = 1'b1;
    always #10 clk = ~clk;

    integer r;
    wire [31:0] x3 = u_tinyriscv_soc_top.u_tiny_riscv.u_regs.regs[3];
    wire [31:0] x26 = u_tinyriscv_soc_top.u_tiny_riscv.u_regs.regs[26];
    wire [31:0] x27 = u_tinyriscv_soc_top.u_tiny_riscv.u_regs.regs[27];

    // read mem data
    initial begin
        //$readmemh ("../sim/inst.data", u_tinyriscv_soc_top.u_rom._rom);
        // 路径是按照仿真程序所在的目录计算，不是testbench.v 所在的目录。4
        $readmemh ("../../../../../../user/sim/inst.data", u_tinyriscv_soc_top.u_rom._rom);
    end
    initial begin
        rst_n = 1'b0;
        #201;
        rst_n = 1'b1;
        #20000;
        $finish();
    end
    initial begin
        `ifdef TEST_PROG
                wait(x26 == 32'b1)   // wait sim end, when x26 == 1
                #100
                if (x27 == 32'b1)begin
                    $display("----------------------------------------------------");
                    $display("----------------------- PASS -----------------------");
                    $display("----------------------------------------------------");
                end
                else begin
                    $display("----------------------------------------------------");
                    $display("----------------------- FAIL -----------------------");
                    $display("----------------------------------------------------");
                    $display("fail testnum = %2d", x3);
                    for (r = 0; r < 32; r = r + 1)
                        $display("x%2d = 0x%x", r, u_tinyriscv_soc_top.u_tiny_riscv.u_regs.regs[r]);
                end
        `endif
    end
    //vcd file
    // initial begin
    //     $dumpfile("../sim/wave.vcd");
    //     $dumpvars();
    // end

endmodule