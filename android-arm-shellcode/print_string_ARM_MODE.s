.section .text
.global _start

_start:

    # _write()
    mov     r2, #16
    mov r1, pc          <= r1 = pc
    add r1, #24         <= r1 = pc + 24 (which points to our string)
    mov     r0, $0x1
    mov     r7, $0x4
    svc     0

    # _exit()
    sub r0, r0, r0
    mov     r7, $0x1
    svc 0

.ascii "shell-storm.org\n"


;root@ARM9:/home/jonathan/shellcode/write# as -o write.o write.s
;root@ARM9:/home/jonathan/shellcode/write# ld -o write write.o
;root@ARM9:/home/jonathan/shellcode/write# ./write
;shell-storm.org
