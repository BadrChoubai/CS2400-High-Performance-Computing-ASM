    .global _start

@   Define compile time constants to store our safe min and max values
    .equ SAFE_MAX, 30
    .equ SAFE_MIN, -10

    .text 
_start:
    LDR r0, =num_readings     @ r0 = &num_readings
    LDR r0, [r0]              @ r0 = num_readings

    LDR r1, =readings         @ r1 = address of readings[0]

    MOV r2, #0                @ r2 = loop counter
    MOV r3, #0                @ r3 = array offset
    MOV r4, #0                @ r4 = total

@   Mission One Data -- Sum of all readings, lowest and highest reading
@   Offset 0, 4, 8
    MOV r5, #0                @ r5 = Sum
    MOV r6, #0                @ r6 = Min
    MOV r7, #0                @ r7 = Max


@ Mission Two Data -- Count positives, negatives, and zeroes, same loop as mission 1
@ Offset 12, 16, 20
    MOV r8, #0                @ r8 = count of positive numbers
    MOV r9, #0                @ r9 = count of negative numbers
    MOV r10, #0               @ r10 = count of zeroes


@ Mission Three Data -- Safety Analysis (How many readings outside of safe range?)
@ Offset 24

@ Mission Four Data
@ Create a corrected copy of the telemetry in the array labeled `corrected`. 
@ Clamp each value to the safe range

@ Mission Five Data -- Optional
@ Offset 28

@ Scaffold rest of application data
    LDR r12, =report        @ r12 = &report

    LDR r6, [r1]            @ peek at readings[0]
    MOV r10, r6             @ seed min
    MOV r11, r6             @ seed max

loop:
@   have we processed num_readings?
    CMP r2, r0
    BGE finished

    LDR r6, [r1, r3]
    ADD r5, r5, r6

    CMP   r6, r10
    MOVLT r10, r6

    CMP   r6, r11
    MOVGT r11, r6

    ADD r2, r2, #1        @ increment counter
    ADD r3, r3, #4        @ increment offset

    B loop

finished:
    STR r5, [r12, #0]        @ store sum
    STR r10, [r12, #4]       @ store min
    STR r11, [r12, #8]       @ store max
@   SVC 0

stop:
    B stop

    .data 
readings:
    .word 12, -5, 0, 27, 31, -18, 7, 42, -2, 15
num_readings:
    .word 10
report:
    .space 32
corrected:
    .space 40


