.section .text
.global _start

_start:

    .code 32
    # Thumb-Mode on
    add     r6, pc, #1
    bx  r6

    .code   16
    # _write()
    mov     r2, #16
    mov r1, pc
    add r1, #12
    mov     r0, $0x1
    mov     r7, $0x4
    svc     0

    # _exit()
    sub r0, r0, r0
    mov     r7, $0x1
    svc 0

.ascii "shell-storm.org\n"


;root@ARM9:/home/jonathan/shellcode/write# as -mthumb -o write.o write.s
;root@ARM9:/home/jonathan/shellcode/write# ld -o write write.o
;root@ARM9:/home/jonathan/shellcode/write# ./write
;shell-storm.org
