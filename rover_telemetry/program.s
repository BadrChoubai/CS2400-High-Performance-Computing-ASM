@ Badr Choubai
@
@ Why ASR for the signed temperature field:
@   The temperature byte is a two's-complement signed value sitting in the
@   top byte of the packet. A logical shift (LSR) would fill the vacated high
@   bits with 0s, turning a negative temperature into a large positive
@   number. ASR instead copies the sign bit into every bit it shifts in, so
@   a negative byte stays negative once sign-extended to a full word.
@
@ What BIC does, in our own words:
@   BIC computes Rd = Rn AND (NOT Op2). Any bit set in Op2 is forced to 0 in
@   the result; every other bit passes through from Rn unchanged. It's how
@   you turn specific bits off without disturbing the rest of the word.
@
@ Final values:
@   packed_packet    = 0xF4582595
@   modified_packet  = 0xF458253E
@   inverted_flags   = 1
@   rotated_packet   = 0x3EF45825
@
@ Where each required instruction appears:
@   AND  - masking fields in Mission 1 and Mission 2, masking flags in Mission 4A
@   ORR  - combining fields in Mission 2, thermal-on and new-error-field in Mission 3
@   EOR  - toggling communications in Mission 3
@   BIC  - motor-off and clearing the old error field in Mission 3
@   MVN  - inverting the flag nibble in Mission 4A
@   LSL  - shifting fields into position in Mission 2 and Mission 3
@   LSR  - extracting battery/sensor/error in Mission 1
@   ASR  - extracting signed temperature in Mission 1
@   TST  - testing each flag bit in Mission 1
@   ROR  - rotating the final packet in Mission 4B

    .global _start

    @ Field positions within the packet (bit offsets from bit 0)
    .equ TEMP_SHIFT,     24
    .equ BATTERY_SHIFT,  16
    .equ SENSOR_SHIFT,   8
    .equ ERROR_SHIFT,    4

    @ Field masks
    .equ BYTE_MASK,      0xFF
    .equ NIBBLE_MASK,    0x0F

    @ Flag bit masks
    .equ MOTOR_MASK,     0x01
    .equ COMM_MASK,      0x02
    .equ LOWBATT_MASK,   0x04
    .equ THERMAL_MASK,   0x08

    @ Mission 2 build inputs
    .equ IN_TEMP,        -12
    .equ IN_BATTERY,     88
    .equ IN_SENSOR,      37
    .equ IN_ERROR,       9
    .equ IN_FLAGS,       5

    @ Mission 3 replacement error code
    .equ NEW_ERROR,      3

    .text
_start:
    @ Mission 1: decode 0xEE492A5B
    LDR r0, =0xEE492A5B        @ r0 = packet

    ASR r1, r0, #TEMP_SHIFT           @ r1 = signed temperature
    LDR r4, =decoded_temp
    STR r1, [r4]

    LSR r1, r0, #BATTERY_SHIFT
    AND r1, r1, #BYTE_MASK             @ r1 = battery
    LDR r4, =decoded_battery
    STR r1, [r4]

    LSR r1, r0, #SENSOR_SHIFT
    AND r1, r1, #BYTE_MASK             @ r1 = sensor ID
    LDR r4, =decoded_sensor
    STR r1, [r4]

    LSR r1, r0, #ERROR_SHIFT
    AND r1, r1, #NIBBLE_MASK           @ r1 = error code
    LDR r4, =decoded_error
    STR r1, [r4]

    AND r2, r0, #NIBBLE_MASK           @ r2 = flags nibble (mask r0, not the leftover r1)
    LDR r4, =decoded_flags
    STR r2, [r4]

    @ Register Plan
    @ r2 = flags nibble (from above)
    @ r3 = scratch: holds 1 or 0 for each TST result
    TST r2, #MOTOR_MASK
    MOVNE r3, #1
    MOVEQ r3, #0
    LDR r4, =motor_on
    STR r3, [r4]

    TST r2, #COMM_MASK
    MOVNE r3, #1
    MOVEQ r3, #0
    LDR r4, =comm_on
    STR r3, [r4]

    TST r2, #LOWBATT_MASK
    MOVNE r3, #1
    MOVEQ r3, #0
    LDR r4, =low_battery_on
    STR r3, [r4]

    TST r2, #THERMAL_MASK
    MOVNE r3, #1
    MOVEQ r3, #0
    LDR r4, =thermal_on
    STR r3, [r4]

    @ Mission 2: build 0xF4582595 from separate inputs
    @ Register Plan
    @ r0 = packet under construction
    @ r1 = scratch: holds each field while it's masked and shifted
    MOV r0, #0

    LDR r1, =IN_TEMP
    AND r1, r1, #BYTE_MASK
    LSL r1, r1, #TEMP_SHIFT
    ORR r0, r0, r1                     @ place temperature

    MOV r1, #IN_BATTERY
    AND r1, r1, #BYTE_MASK
    LSL r1, r1, #BATTERY_SHIFT
    ORR r0, r0, r1                     @ place battery

    MOV r1, #IN_SENSOR
    AND r1, r1, #BYTE_MASK
    LSL r1, r1, #SENSOR_SHIFT
    ORR r0, r0, r1                     @ place sensor ID

    MOV r1, #IN_ERROR
    AND r1, r1, #NIBBLE_MASK
    LSL r1, r1, #ERROR_SHIFT
    ORR r0, r0, r1                     @ place error code

    MOV r1, #IN_FLAGS
    AND r1, r1, #NIBBLE_MASK
    ORR r0, r0, r1                     @ place flags

    LDR r4, =packed_packet
    STR r0, [r4]                       @ r0 = 0xF4582595

    @ Mission 3: modify packet without rebuilding it
    @ r0 still holds the packed packet from Mission 2
    ORR r0, r0, #THERMAL_MASK          @ turn thermal warning ON
    BIC r0, r0, #MOTOR_MASK            @ turn motor OFF
    EOR r0, r0, #COMM_MASK             @ toggle communications

    BIC r0, r0, #0xF0                  @ clear old error field (bits 7-4)
    MOV r1, #NEW_ERROR
    LSL r1, r1, #ERROR_SHIFT
    ORR r0, r0, r1                     @ insert new error field

    LDR r4, =modified_packet
    STR r0, [r4]                       @ r0 = 0xF458253E

    @ Mission 4: NOT and rotation
    AND r1, r0, #NIBBLE_MASK           @ r1 = low 4 flag bits
    MVN r1, r1                         @ invert all 32 bits
    AND r1, r1, #NIBBLE_MASK           @ mask back to 4 bits
    LDR r4, =inverted_flags
    STR r1, [r4]                       @ r1 = 1

    ROR r1, r0, #8                     @ rotate final packet right 8 bits
    LDR r4, =rotated_packet
    STR r1, [r4]                       @ r1 = 0x3EF45825

stop:
    B stop


    .data
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
