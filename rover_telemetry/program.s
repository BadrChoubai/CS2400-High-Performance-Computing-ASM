@ Badr Choubai
    .global _start

    .text 
_start:
  @ mission 1: decode 0xEE492A5B
  LDR r0, =0xEE492A5B
  @ TODO - extract/store fields and flag states
  
  @ extract temperature
  ASR r1, r0, #24
  LDR r4, =decoded_temp
  STR r1, [r4]

  @ extract battery
  LSR r1, r0, #16
  AND r1, r1, #0xFF
  LDR r4, =decoded_battery
  STR r1, [r4]

  @ extract sensor
  LSR r1, r0, #8
  AND r1, r1, #0xFF
  LDR r4, =decoded_sensor
  STR r1, [r4]

  @ extract error
  LSR r1, r0, #4
  AND r1, r1, #0x0F
  LDR r4, =decoded_error
  STR r1, [r4]

  @ extract flags
  AND r1, r0, #0x0F
  LDR r4, =decoded_flags
  STR r1, [r4]

    @ flag states (TST sets Z; NE = bit set, EQ = bit clear)
  @ motor enabled (bit 0)
  TST   r0, #0x01
  MOVNE r1, #1
  MOVEQ r1, #0
  LDR   r4, =motor_on
  STR   r1, [r4]

  @ communications enabled (bit 1)
  TST   r0, #0x02
  MOVNE r1, #1
  MOVEQ r1, #0
  LDR   r4, =comm_on
  STR   r1, [r4]

  @ low battery (bit 2)
  TST   r0, #0x04
  MOVNE r1, #1
  MOVEQ r1, #0
  LDR   r4, =low_battery_on
  STR   r1, [r4]

  @ thermal warning (bit 3)
  TST   r0, #0x08
  MOVNE r1, #1
  MOVEQ r1, #0
  LDR   r4, =thermal_on
  STR   r1, [r4]

  @ mission 2: build 0xF4582595
  @ TODO - Mask, Shift, ORR


  @ mission 3: modify packet without rebuilding it
  @ TODO - ORR, BIC, EOR, replace error field

  @mission 4: MVN + mask, then ROR #8
  @TODO

stop:
    B stop


    .data 
  @ Store your results in words like these
  decoded_temp:     
    .word 0
  decoded_battery:  
    .word 0
  decoded_sensor:  
    .word 0
  decoded_error:  
    .word 0
  decoded_flags: 
    .word 0
  motor_on:     
    .word 0
  comm_on:     
    .word 0
  low_battery_on:
    .word 0
  thermal_on:   
    .word 0
  packed_packet: 
    .word 0
  modified_packet:
    .word 0
  inverted_flags:
    .word 0
  rotated_packet:
    .word 0
