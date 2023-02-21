import sys
import subprocess
import os


# 主函数
def main():
    #print(sys.argv[0] + ' ' + sys.argv[1] + ' ' + sys.argv[2])

    # 1.将bin文件转成mem文件
    cmd = r'python ./BinToMem_CLI.py' + ' ' + sys.argv[1] + ' ' + sys.argv[2]
    f = os.popen(cmd)
    f.close()
    
    # 2.编译rtl文件
    cmd = r'python compile_rtl.py' + r' ..'
    f = os.popen(cmd)
    f.close()

    # 3.运行
    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'../sim/out.vvp')
    process_vpp = subprocess.Popen(vvp_cmd)
    try:
        process_vpp.wait(timeout=20)
    except subprocess.TimeoutExpired:
        print('!!!Fail, vvp exec timeout!!!')
    
    # 4.显示波形
    wave_display = sys.argv[3]
    if wave_display == r'-on':
        gtkwave_cmd = [r'gtkwave']
        gtkwave_cmd.append(r'../sim/wave.vcd')
        process_gtkwave = subprocess.Popen(gtkwave_cmd)
        try:
            process_gtkwave.wait(timeout=20)
        except subprocess.TimeoutExpired:
            print('!!!Fail, gtkwave exec timeout!!!')
    #else:
        #print('\r\ngtkwave no wave display')


if __name__ == '__main__':
    sys.exit(main())
