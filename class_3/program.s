    .global _start

    .text 
_start:
  LDR sp, =stack_top

  LDR r0, =readings
  LDR r1, =num_readings
  LDR r1, [r1]
  BL count_thermal_shocks

  LDR r1, =shock_count
  STR r0, [r1]

stop:
  B stop

@ Inputs: r0 = first integer, r1 = second integer  
@ Return: r0 = absolute difference
@ Must Preserve: r4-r6
count_thermal_shocks:
  PUSH {r4-r6, pc}

  @ Register Plan
  @ r4 = array pointer
  @ r5 = adjacent pairs remaining
  @ r6 = shock count

  @ TODO: Handle length 0 or 1.
  @ TODO: Load each adjacent pair.
  @ TODO: Call absolute_difference
  @ TODO: Count differences greater than 20
  @ TODO: Advance and repeat.
  @ TODO: Move the final count into r0.

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
