OUTPUT_ARCH( "riscv" ) /*指定输入平台为riscv*/
ENTRY(_start) /*指定输出可执行文件的起始代码为_start*/

MEMORY
{
  flash (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 16K
  ram (wxa!ri) :   ORIGIN = 0x10000000, LENGTH = 16K
}


SECTIONS
{
   __stack_size = DEFINED(__stack_size) ? __stack_size : 8K;/*DEFINED(SYMBOL):定义了SYMBOL则返回1，否则返回0*/

  .init           :
  {
    KEEP (*(SORT_NONE(.init))) /*KEEP:强制编译器保留特定的section*/
  } >flash AT>flash /*>REGION表达式将该输出section限定于在程序地址空间内的某块存储区域 */
                    /*AT>LMA_REGION表达式设置指定该section加载地址的范围*/
                    /*>运行地址，AT>装入地址*/
  .text           :
  {
    *(.text.unlikely .text.unlikely.*)/*星号是通配符，表示任意多字符，这段的意思是将所有输入文件中的.text.unlikely 和 .text.unlikely.*section放入.text section*/
    *(.text.startup .text.startup.*)  /*放入的顺序是第一个文件中的.text.unlikely section和第一文件中的所有.text.unlikely.* secton*/                   
    *(.text .text.*)                  /*接着是第二个文件中的.text.unlikely section和第二文件中的所有.text.unlikely.* secton*/
    *(.gnu.linkonce.t.*)
  } >flash AT>flash 

  . = ALIGN(4); /*返回定位符'.'的按照EXP进行对齐后的修调值，返回的值相当于(. + exp - 1) & ~( exp - 1),本句中，如果. 为6，则返回8，3就返回4*/

  PROVIDE (__etext = .);/*如果程序中定义了__etext符号，则链接器使用程序中的定义，如果没有定义__etext符号，链接器使用到__etext符号时，将使用连接器提供的__etext符号*/
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  .preinit_array  :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >flash AT>flash 

  .init_array     :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >flash AT>flash 

  .fini_array     :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >flash AT>flash 

  .ctors          :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  } >flash AT>flash 

  .dtors          :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  } >flash AT>flash 

  .lalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data_lma = . );
  } >flash AT>flash 

  .dalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data = . );
  } >ram AT>flash 

  .data          :
  {
    *(.rdata)
    *(.rodata .rodata.*)
    *(.gnu.linkonce.r.*)
    *(.data .data.*)
    *(.gnu.linkonce.d.*)
    . = ALIGN(8);
    PROVIDE( __global_pointer$ = . + 0x800 );
    *(.sdata .sdata.*)
    *(.gnu.linkonce.s.*)
    . = ALIGN(8);
    *(.srodata.cst16)
    *(.srodata.cst8)
    *(.srodata.cst4)
    *(.srodata.cst2)
    *(.srodata .srodata.*)
  } >ram AT>flash 

  . = ALIGN(4);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );

  PROVIDE( _fbss = . );
  PROVIDE( __bss_start = . );
  .bss            :
  {
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss .bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
  } >ram AT>ram 

  . = ALIGN(8);
  PROVIDE( _end = . );
  PROVIDE( end = . );

  .stack ORIGIN(ram) + LENGTH(ram) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    . = __stack_size;
    PROVIDE( _sp = . );
    __freertos_irq_stack_top = .;
  } >ram AT>ram

}
