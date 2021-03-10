  1     .arch armv8-a
  2 // (a^3 + b^3)/(a^2 * c - b^2 * d + e)
  3     .data
  4     .align 3
  5 b:
  6     .byte 2
  7 res:
  8     .skip 8
  9 a:
 10     .short 40
 11 c:
 12     .word 150000
 13 d:
 14     .word 10500
 15 e:
 16     .word 2000000
 17
 18     .text
 19     .align 2
 20     .global _start
 21     .type _start, %function
 22 _start:
 23     adr x0, a
 24     ldrh w1, [x0]
 25     adr x0, b
 26     ldrb w2, [x0]
 27     adr x0, c
 28     ldr w3, [x0]
 29     adr x0, d
 30     ldr w4, [x0]
 31     adr x0, e
 32     mov x5, #0
 33     ldr w5, [x0]
 34
 35     mul w6, w1, w1
 36     umull x7, w6, w1
 37
 38     mul w6, w2, w2
 39     umull x8, w6, w2
 40
 41     add x9, x7, x8
 42
 43     mul w6, w1, w1
 44     umull x7, w6, w3
 45
 46     mul w8, w2, w2
 47     umull x10, w8, w4
 48
 49     subs x11, x7, x10
 50     bcc L1
 51
 52     adds x12, x11, x5
 53     bcs L0
 54     b L2
 55 L0:
 56     mov x0, #1
 57     b L3
 58
 59 L1:
 60     mov x0, #2
 61     b L3
 62
 63 L4:
 64     mov x0, #3
 65     b L3
 66
 67 L2:
 68     cbz x12, L4
 69     udiv x13, x9, x12
 70
 71     adr x0, res
 72	str x13, [x0]
 73     mov x0, #0
 74
 75 L3:
 76     mov x8, #93
 77     svc #0
 78     .size _start, .-_start