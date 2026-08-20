.global _start

.section .data
hello_world: 
  .asciz "Hello, World\n"

.section .text
_start:
  mov r0, #1
  ldr r1, =hello_world
  mov r2, #14
  mov r7, #4
  svc #0

  mov r0, #0
  mov r7, #1
  svc #0

