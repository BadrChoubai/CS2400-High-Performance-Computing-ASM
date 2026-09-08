    .global _start

    .text 
_start:
    LDR sp, =stack_top

    LDR r0, =readings
    LDR r1, =num_readings
    LDR r1, [r1]
    BL  count_thermal_shocks

    LDR r1, =shock_count
    STR r0, [r1]

stop:
    B stop

@ params    r0 = first integer, r1 = second integer
@ returns   r0 = absolute_difference 
absolute_difference:
    SUBS    r0, r0, r1
    RSBLT   r0, r0, #0
    BX      lr

@ params    r0 = array address, r1 = number of readings
@ returns   r0 = number of thermal shocks
@ preserves r4-r6 
count_thermal_shocks:
    PUSH {r4-r6, lr}

    @ Register Plan
    @ r4 = array pointer
    @ r5 = adjacent pairs remaining
    @ r6 = shock count
    MOV r4, r0
    MOV r6, #0
    @ Handle length 0 or 1.
    CMP r1, #2 
    BLT return_zero
    MOV r5, r1
    SUB r5, r5, #1

loop:
    @ Load each adjacent pair.
    LDR r7, [r4]
    LDR r8, [r4, #4]

    @ Call absolute_difference(r0, r1)
    MOV r0, r7
    MOV r1, r8
    BL  absolute_difference

    @ Count differences greater than 20
    ADD   r4, r4, #4
    CMP   r0, #20
    ADDGT r6, r6, #1

    @ Advance and repeat.
    SUBS  r5, r5, #1
    BGT   loop

    @ Move the final count into r0.
    MOV r0, r6
    POP {r4-r6, pc}

return_zero:
    MOV r0, #0
    POP {r4-r6, pc}

    .data 
readings:
    .word 12, -5, 0, 27, 31, -18, 7, 42, -2, 15
num_readings:
    .word 10
shock_count:
    .word 0

    .balign 8
stack_space:
    .space 1024
stack_top:


