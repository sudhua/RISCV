
    .section .init; 
    .globl _start; 
    .type _start,@function  
		                      
_start:
.option push
.option norelax
	la gp, __global_pointer$
.option pop
	la sp, _sp
#ifdef SIMULATION
    li x26, 0x00
    li x27, 0x00
#endif

	/* Load data section */
  //将data段从程序存储器(ROM)搬运至数据存储器(RAM)，作为可读可写的变量。
	//如果a1 >= a2 则表明data段没有数据，不需要把数据搬到ram中。
	la a0, _data_lma //程序存储器的data段起始地址
	la a1, _data //数据存储器的data段起始地址
	la a2, _edata //数据存储器的data段结束地址
	bgeu a1, a2, 2f //bgeu无符号大于等于 f向后搜索标签1
1:
	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b //bltu 无符号小于时分支
2:

	/* Clear bss section */
	la a0, __bss_start
	la a1, _end
	bgeu a0, a1, 2f
1:
	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, 1b 
2:

    call _init
    call main

#ifdef SIMULATION
    li x26, 0x01
#endif

loop:
    j loop
