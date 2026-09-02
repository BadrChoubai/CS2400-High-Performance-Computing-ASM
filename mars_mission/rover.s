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

    MOV r3, #0                @ r3 = Sum






@   Mission Four Data
@   Create a corrected copy of the telemetry in the array labeled `corrected`. 
@   Clamp each value to the safe range


@   Mission Five Data -- Optional
@   Offset 28


@ Scaffold rest of application data
    LDR r12, =report        @ r12 = &report

    LDR r5, [r1]            @ peek at readings[0]
    MOV r10, r5             @ seed min
    MOV r11, r5             @ seed max
    MOV r6, #0              @ positive_count
    MOV r7, #0              @ negative_count
    MOV r8, #0              @ unsafe_count

loop:
@   have we processed num_readings?
    CMP r2, r0
    BGE finished

    LDR r4, [r1, r2, LSL #2]
    ADD r3, r3, r4        @ sum+=n

    CMP   r4, r10
    MOVLT r10, r4         @ n < current_min

    CMP   r4, r11
    MOVGT r11, r4         @ n > current_max

    CMP   r4, #0
    ADDGT r6, r6, #1
    ADDLT r7, r7, #1

    CMP   r4, #SAFE_MIN
    ADDLT r8, r8, #1      @ n < SAFE_MIN

    CMP   r4, #SAFE_MAX
    ADDGT r8, r8, #1      @ n > SAFE_MAX

    ADD r2, r2, #1        @ increment counter

    B loop

finished:
@   Mission One Data -- Sum of all readings, lowest and highest reading
@   Offset 0, 4, 8
    STR r3, [r12, #0]         @ store sum
    STR r10, [r12, #4]        @ store min
    STR r11, [r12, #8]        @ store max

@   Mission Two Data -- Count positives, negatives, and zeroes
@   Offset 12, 16, 20
    STR r6, [r12, #12]        @ store positive_count
    STR r7, [r12, #16]        @ store negative_count

@   Calculate zero_count for Mission Two
@   Count of zeroes may be done by taking the difference of positive_count and negative_count  
    SUB r9, r0, r6            @ r9 = num_readings - positives
    SUB r9, r9, r7            @ r9 -= negatives
    STR r9, [r12, #20]        @ store zero_count

@   Mission Three Data -- Safety Analysis (How many readings outside of safe range?)
@   Offset 24
    STR r8, [r12, #24]        @ store unsafe_count

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
