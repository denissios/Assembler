  1	.arch armv8-a
  2 //  HeapSort
  3     .data
  4     .align 3
  5 matrix:
  6     .quad 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
  7     .quad 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  8     .quad 6, 3, 1, 5, 4, 9, 2, 8, 7, 0
  9     .quad -6, -3, -1, -5, -4, -9, -2, -8, -7, -0
 10     .quad -1, 5, 3, -4, -2, 2, 1, 0, 4, -5
 11 m:
 12     .byte 5
 13 n:
 14     .byte 10
 15
 16     .text
 17     .align 2
 18     .global _start
 19     .type _start, %function
 20 _start:
 21     adr x0, m
 22     mov x1, #0
 23     ldrb w1, [x0] // m
 24     adr x0, n
 25     mov x2, #0
 26     ldrb w2, [x0] // n
 27     mov x22, x2 // copy of n
 28     adr x3, matrix
 29     //mov x4, 0 // inc for first_for
 30     //mov x5, 0 // inc for second_for
 31     mov x15, 0 // inc for matrix_for
 32     mov x0, 2
 33     udiv x6, x2, x0 // n / 2
 34     //sub x6, x5, 1 // n / 2 - 1
 35 matrix_for:
 36     mov x4, 0
 37     mov x2, x22
 38     //udiv x6, x2, x0 // n / 2
 39     mov x20, 1 // to second_for or to first_for
 40
 41     mov x0, 8
 42     mul x7, x2, x0 // n * 8
 43     mul x7, x7, x15 // n * 8 * matrix_for iteration
 44     mov x0, 2
 45     adr x3, matrix
 46     add x3, x3, x7
 47
 48     //adr x3, matrix, x7, lsl 3
 49     add x15, x15, 1
 50     //mul x6, x2, x15
 51     //udiv x6, x6, x0
 52     //mul x21, x6, x15
 53     //mul x6, x6, x15
 54     cmp x15, x1
 55     ble first_for
 56     b end_matrix
 57
 58
 59
 60
 61 first_for:
 62     add x4, x4, 1
 63     cmp x4, x6
 64     ble heapify
 65
 66     mov x20, 0
 67     mov x4, 0
 68     mov x6, x2
 69     //sub x6, x2, 1
 70     //mul x21, x6, x15
 71 second_for:
 72     add x4, x4, 1
 73     cmp x4, x6
 74     ble if_second_for
 75     b matrix_for
 76
 77 if_second_for:
 78     sub x8, x6, x4
 79     //add x8, x7, 1 // index i
 80     ldr x12, [x3] // mas[0]
 81     ldr x13, [x3, x8, lsl 3] // mas[i]
 82     mov x14, x12
 83     mov x12, x13
 84     mov x13, x14
 85     str x12, [x3]
 86     str x13, [x3, x8, lsl 3]
 87     mov x2, x8
 88     mov x8, 0
 89     b heapify_1
 90
 91
 92
 93
 94
 95 heapify:
 96     sub x8, x6, x4
 97     //add x8, x7, 1 // index i
 98 heapify_1:
 99     mov x9, x8 // smallest
100     mov x0, 2
101     mul x7, x8, x0
102     add x10, x7, 1 // left = 2 * i + 1
103     add x11, x7, 2 // right = 2 * i + 2
104
105     cmp x10, x2
106     blt if_l_higher_root
107 continue_heapify_l:
108     cmp x11, x2
109     blt if_r_higher_root
110 continue_heapify_r:
111     cmp x9, x8
112     bne if_highest_elem_is_not_root
113     cbz x20, second_for
114     b first_for
115
116
117
118
119 if_l_higher_root:
120     ldr x12, [x3, x9, lsl 3]  // mas[largest]
121     ldr x13, [x3, x10, lsl 3]  // mas[l]
122     cmp x13, x12
123     blt if_l_yes
124     b continue_heapify_l
125 if_l_yes:
126     mov x9, x10 // largest = l
127     b continue_heapify_l
128
129 if_r_higher_root:
130     ldr x12, [x3, x9, lsl 3] // mas[largest]
131     ldr x13, [x3, x11, lsl 3] // mas[r]
132     cmp x13, x12
133     blt if_r_yes
134     b continue_heapify_r
135 if_r_yes:
136     mov x9, x11 // largest = r
137     b continue_heapify_r
138
139 if_highest_elem_is_not_root:
140     ldr x12, [x3, x9, lsl 3] // mas[largest]
141     ldr x13, [x3, x8, lsl 3] // mas[i]
142     mov x14, x12
143     mov x12, x13
144     mov x13, x14
145     str x12, [x3, x9, lsl 3]
146     str x13, [x3, x8, lsl 3]
147     mov x8, x9
148     b heapify_1
149
150
151
152
153 end_matrix:
154     mov x0, #0
155     mov x8, #93
156     svc #0
157     .size _start, .-_start