#define REGBYTES  4


    .section      .text.entry	
    .align 2
    .global trap_entry
trap_entry:

    addi sp, sp, -32*REGBYTES

    sw x1, 1*REGBYTES(sp) //进入中断前保护现场，将寄存器中的值存入ROM中
    sw x2, 2*REGBYTES(sp)
    sw x3, 3*REGBYTES(sp)
    sw x4, 4*REGBYTES(sp)
    sw x5, 5*REGBYTES(sp)
    sw x6, 6*REGBYTES(sp)
    sw x7, 7*REGBYTES(sp)
    sw x8, 8*REGBYTES(sp)
    sw x9, 9*REGBYTES(sp)
    sw x10, 10*REGBYTES(sp)
    sw x11, 11*REGBYTES(sp)
    sw x12, 12*REGBYTES(sp)
    sw x13, 13*REGBYTES(sp)
    sw x14, 14*REGBYTES(sp)
    sw x15, 15*REGBYTES(sp)
    sw x16, 16*REGBYTES(sp)
    sw x17, 17*REGBYTES(sp)
    sw x18, 18*REGBYTES(sp)
    sw x19, 19*REGBYTES(sp)
    sw x20, 20*REGBYTES(sp)
    sw x21, 21*REGBYTES(sp)
    sw x22, 22*REGBYTES(sp)
    sw x23, 23*REGBYTES(sp)
    sw x24, 24*REGBYTES(sp)
    sw x25, 25*REGBYTES(sp)
#ifndef SIMULATION
    sw x26, 26*REGBYTES(sp)
    sw x27, 27*REGBYTES(sp)
#endif
    sw x28, 28*REGBYTES(sp)
    sw x29, 29*REGBYTES(sp)
    sw x30, 30*REGBYTES(sp)
    sw x31, 31*REGBYTES(sp)

    csrr a0, mcause //把mcause(发生异常的种类)的值写入a0寄存器，mcause[31] = 1 表示是异步异常（中断）mcause[31] = 0 表示是同步异常。
    csrr a1, mepc   //把mepc(发生异常的指令)的值写入a1寄存器
test_if_asynchronous: //判断是否是异步异常
	srli a2, a0, 31		                /* MSB of mcause is 1 if handing an asynchronous interrupt - shift to LSB to clear other bits. */
	beq a2, x0, handle_synchronous		/* Branch past interrupt handing if not asynchronous. */

    call trap_handler
    j asynchronous_return

handle_synchronous:
    addi a1, a1, 4
    csrw mepc, a1

asynchronous_return:
    lw x1, 1*REGBYTES(sp)
    lw x2, 2*REGBYTES(sp)
    lw x3, 3*REGBYTES(sp)
    lw x4, 4*REGBYTES(sp)
    lw x5, 5*REGBYTES(sp)
    lw x6, 6*REGBYTES(sp)
    lw x7, 7*REGBYTES(sp)
    lw x8, 8*REGBYTES(sp)
    lw x9, 9*REGBYTES(sp)
    lw x10, 10*REGBYTES(sp)
    lw x11, 11*REGBYTES(sp)
    lw x12, 12*REGBYTES(sp)
    lw x13, 13*REGBYTES(sp)
    lw x14, 14*REGBYTES(sp)
    lw x15, 15*REGBYTES(sp)
    lw x16, 16*REGBYTES(sp)
    lw x17, 17*REGBYTES(sp)
    lw x18, 18*REGBYTES(sp)
    lw x19, 19*REGBYTES(sp)
    lw x20, 20*REGBYTES(sp)
    lw x21, 21*REGBYTES(sp)
    lw x22, 22*REGBYTES(sp)
    lw x23, 23*REGBYTES(sp)
    lw x24, 24*REGBYTES(sp)
    lw x25, 25*REGBYTES(sp)
#ifndef SIMULATION
    lw x26, 26*REGBYTES(sp)
    lw x27, 27*REGBYTES(sp)
#endif
    lw x28, 28*REGBYTES(sp)
    lw x29, 29*REGBYTES(sp)
    lw x30, 30*REGBYTES(sp)
    lw x31, 31*REGBYTES(sp)

    addi sp, sp, 32*REGBYTES

    mret


.weak trap_handler //.weak用于声明一个弱符号，如果这个符号没有定义，编译就忽略，而不会报错
trap_handler:
1:
    j 1b
