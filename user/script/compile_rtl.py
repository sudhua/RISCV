import sys
import subprocess
import sys


# 主函数
def main():
    rtl_dir = sys.argv[1]
    tb_file = r'/sim/testbench.v'
    '''
    if rtl_dir != r'..':
        tb_file = r'./sim/testbench.v'
    else:
        tb_file = r'testbench.v'
    '''
    # iverilog程序
    iverilog_cmd = ['iverilog']
    # 顶层模块
    #iverilog_cmd += ['-s', r'tinyriscv_soc_tb']
    # 编译生成文件
    iverilog_cmd += ['-o', r'../sim/out.vvp']
    # 头文件(defines.v)路径
    iverilog_cmd += ['-I', rtl_dir + r'/src/core']
    # 宏定义，仿真输出文件
    iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    # testbench文件
    iverilog_cmd.append(rtl_dir + tb_file)
    # ../rtl/core
    iverilog_cmd.append(rtl_dir + r'/src/core/clint.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/csr_reg.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/ctrl.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/defines.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/div.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/ex.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/id.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/id_ex.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/if_id.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/pc_reg.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/regs.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/rib.v')
    iverilog_cmd.append(rtl_dir + r'/src/core/tiny_riscv.v')
    # ../rtl/perips
    iverilog_cmd.append(rtl_dir + r'/src/peripheral/ram.v')
    iverilog_cmd.append(rtl_dir + r'/src/peripheral/rom.v')
    iverilog_cmd.append(rtl_dir + r'/src/peripheral/timer.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/perips/uart.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/perips/gpio.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/perips/spi.v')
    # ../rtl/debug
    # iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_dm.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_driver.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_top.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/debug/uart_debug.v')
    # ../rtl/soc
    iverilog_cmd.append(rtl_dir + r'/src/soc/tinyriscv_soc_top.v')
    # ../rtl/utils
    # iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_rx.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_tx.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/utils/gen_buf.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/utils/gen_dff.v')

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

if __name__ == '__main__':
    sys.exit(main())
