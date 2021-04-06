  1     .arch armv8-a
  2
  3     .data
  4     MSG_ABOUT: .asciz "\nUsage: ./prog <e|d> <input file> <output file>\n\te - encode\n\td - decode\n\n"
  5     LMSG_ABOUT = . - MSG_ABOUT
  6
  7     MSG_ERROR: .asciz "[ERROR]: "
  8     LMSG_ERROR = . - MSG_ERROR
  9
 10     MSG_ERROR_FILE_WRITE: .asciz "Do you want to delete file contents?\n"
 11     LMSG_ERROR_FILE_WRITE = . - MSG_ERROR_FILE_WRITE
 12
 13     EMSG_INPUT_FILE_NOT_FOUND: .asciz "Input file not found\n"
 14     LEMSG_INPUT_FILE_NOT_FOUND = . - EMSG_INPUT_FILE_NOT_FOUND
 15
 16     EMSG_WRONG_PARAM: .asciz "Wrong parameter(s)\n"
 17     LEMSG_WRONG_PARAM = . - EMSG_WRONG_PARAM
 18
 19     EMSG_OUTPUT_FILE_ERROR: .asciz "Cannot create output file\n"
 20     LEMSG_OUTPUT_FILE_ERROR = . - EMSG_OUTPUT_FILE_ERROR
 21
 22     InputFD: .skip 4
 23     OutputFD: .skip 4
 24     bufferChar: .skip 4
 25     bufferCount: .skip 8
 26
 27     .equ SYS_EXIT, 93
 28     .equ SYS_OPENAT, 56
 29     .equ SYS_CLOSE,57
 30     .equ SYS_READ, 63
 31     .equ SYS_WRITE,64
 32
 33     .equ STDIN, 0
 34     .equ STDOUT, 1
 35
 36     .equ O_RDONLY, 0
 37     .equ O_WRONLY, 1
 38     .equ O_RDWR, 2
 39     .equ O_CREAT, 0x40
 40
 41     .equ AD_FDCWD, -100
 42
 43     .text
 44     .global _start
 45
 46 _start:
 47     ldp x0, x1, [sp], 16
 48
 49     cmp x0, 4
 50     beq check_args
 51     bl print_help
 52     b nrc
 53
 54 check_args:
 55     ldp x9, x10, [sp], 16
 56     ldr x11, [sp], 8
 57
 58     ldrb w9, [x9]
 59     cmp w9, 0x65
 60     beq 1f
 61     cmp x9, 0x64
 62     bne wrong_param
 63
 64  1:
 65     // open input
 66     mov x0, x10
 67     mov x1, O_RDONLY
 68     bl fopen
 69
 70     cmp x0, 0
 71     ble wrong_input_file
 72
 73     ldr x1, =InputFD
 74     str x0, [x1]
 75
 76     // open output
 77     mov x0, x11
 78     mov x1, O_WRONLY
 79     add x1, x1, 0xc0
 80     bl fopen
 81     cmp x0, -17
 82     bne 2f
 83     bl check_write_if_exists
 84
 85 2:
 86     cmp x0, 0
 87     ble wrong_output_file
 88
 89     ldr x1, =OutputFD
 90     str x0, [x1]
 91
 92     // choose method
 93     cmp x9, 0x65
 94     bne for_decode
 95     bl encode
 96     b close_files
 97
 98 check_write_if_exists:
 99     str x30, [sp, -8]!
100     ldr x1, =MSG_ERROR_FILE_WRITE
101     ldr x2, =LMSG_ERROR_FILE_WRITE
102     bl write
103
104     mov x0, 0
105     ldr x1, =bufferChar
106     mov x2, 1
107     bl fread
108
109
110     adr x21, bufferChar
111     mov x22, #0
112     ldrb w22, [x21]
113     cmp w22, 'y'
114     bne error
115     bl delete_file_contents
116
117 3:
118     ldr x30, [sp], 8
119     ret
120
121 delete_file_contents:
122     str x30, [sp, -8]!
123
124     mov x0, x11
125     mov x1, O_WRONLY
126     add x1, x1, 0x200
127     bl fopen
128
129     ldr x30, [sp], 8
130     ret
131
132 for_decode:
133     bl decode
134     b close_files
135
136 close_files:
137     ldr x0, =InputFD
138     ldr x0, [x0]
139     bl fclose
140
141     ldr x0, =OutputFD
142     ldr x0, [x0]
143     bl fclose
144     b nrc
145
146 wrong_param:
147     ldr x1, =EMSG_WRONG_PARAM
148     ldr x2, =LEMSG_WRONG_PARAM
149     b print_error
150
151 wrong_input_file:
152     ldr x1, =EMSG_INPUT_FILE_NOT_FOUND
153     ldr x2, =LEMSG_INPUT_FILE_NOT_FOUND
154     b print_error
155
156 wrong_output_file:
157     ldr x0, =InputFD
158     ldr x0, [x0]
159     bl fclose
160
161     ldr x1, =EMSG_OUTPUT_FILE_ERROR
162     ldr x2, =LEMSG_OUTPUT_FILE_ERROR
163     b print_error
164
165
166 error:
167     mov x0, 1
168     b exit
169
170 nrc:
171     mov x0, 0
172
173 exit:
174     mov x8, SYS_EXIT
175     svc 0
176
177     /*
178      * Closes the file
179      *
180      * x0 - fd
181      */
182 fclose:
183     str x30, [sp, -8]!
184
185     mov x8, SYS_CLOSE
186     svc 0
187
188     ldr x30, [sp], 8
189     ret
190
191     /*
192      * Opens the file <filename>
193      *
194      * x0 - filename
195      * x1 - flags
196      */
197 fopen:
198     str x30, [sp, -8]!
199
200     mov x2, x1 // flags
201     mov x1, x0 // filename
202     mov x0, AD_FDCWD // dir
203     mov x3, 0000700  // mode
204     mov x8, SYS_OPENAT
205     svc 0
206
207     ldr x30, [sp], 8
208     ret
209
210     /*
211      * Encodes <input> with RLE and writes the result in
212      * <output>
213      */
214 encode:
215     mov x15, #0 // for first symbol
216     mov x16, #1 // counter
217     str x30, [sp, -8]!
218
219
220 1:
221     ldr x0, =InputFD
222     ldr w0, [x0]
223     ldr x1, =bufferChar
224     mov x2, 1
225     mov x8, SYS_READ
226     svc 0
227
228     cmp x0, 0
229     beq 98f
230
231
232     adr x21, bufferChar
233     mov x22, #0
234     ldrb w22, [x21]
235     //cmp w22, 10
236     //beq 5f
237     cmp x15, 0
238     beq 2f
239     b 3f
240
241 2:                // for first symbol
242     mov x23, #0
243     mov w23, w22
244     add x15, x15, 1
245     b 1b
246
247 3:  cmp w22, w23 // compare cur and prev symbol
248     beq 4f
249     b 5f
250
251 4:
252     cmp x16, 255
253     beq 5f
254     add x16, x16, 1
255     b 1b
256
257
258     // proceed
259 5:
260     //add x16, x16, 0x30
261     adr x0, bufferCount
262     str x16, [x0]
263
264     ldr x0, =OutputFD
265     ldr w0, [x0]
266     ldr x1, =bufferCount
267     mov x2, 1
268     bl fwrite
269
270
271     adr x0, bufferChar
272     str w23, [x0]
273
274     ldr x0, =OutputFD
275     ldr w0, [x0]
276     ldr x1, =bufferChar
277     mov x2, 1
278     bl fwrite
279
280     cmp x11, 0
281     beq 99f
282     //cmp w22, 10
283     //beq 99f
284     mov w23, w22
285     mov x16, #1
286     b 1b
287
288 98:
289     mov x11, x0
290     cmp w22, 10
291     beq 5b
292     b 99f
293
294 99:
295     ldr x30, [sp], 8
296     ret
297
298
299     /*
300      * Decodes <input> with RLE and writes the result in <output>
301      */
302 decode:
303     str x30, [sp, -8]!
304
305 1:
306     mov x16, #1 // counter
307     ldr x0, =InputFD
308     ldr w0, [x0]
309     ldr x1, =bufferCount
310     mov x2, 1
311     mov x8, SYS_READ
312     svc 0
313
314     cmp x0, 0
315     beq 99f
316
317     adr x21, bufferCount
318     ldr x22, [x21]
319     //cmp x22, 10
320     //beq 99f
321     //sub x22, x22, 0x30
322
323     ldr x0, =InputFD
324     ldr w0, [x0]
325     ldr x1, =bufferChar
326     mov x2, 1
327     mov x8, SYS_READ
328     svc 0
329
330 2:
331     ldr x0, =OutputFD
332     ldr w0, [x0]
333     ldr x1, =bufferChar
334     mov x2, 1
335     bl fwrite
336     cmp x16, x22
337     beq 1b
338
339     add x16, x16, 1
340     b 2b
341
342
343 99:
344     ldr x30, [sp], 8
345     ret
346
347
348     /*
349      * Prints program user guide
350      */
351 print_help:
352     str x30, [sp, -8]!
353
354     ldr x1, =MSG_ABOUT
355     ldr x2, =LMSG_ABOUT
356     bl write
357
358     ldr x30, [sp], 8
359     ret
360
361
362     /*
363      * Writes <msg> in fmt "[ERROR]: <msg>" and aborts with rc 1
364      *
365      * x0 - msg
366      * x1 - len
367      */
368 print_error:
369     stp x1, x2, [sp, -16]!
370
371     ldr x1, =MSG_ERROR
372     ldr x2, =LMSG_ERROR
373     bl write
374
375     ldp x1, x2, [sp], 16
376     bl write
377
378     b error
379
380     /*
381      * Writes <msg> to STDOUT
382      *
383      * x1 - msg
384      * x2 - len
385      */
386 write:
387     str x30, [sp, -8]!
388
389     mov x0, STDOUT
390     bl fwrite
391
392     ldr x30, [sp], 8
393     ret
394
395     /*
396      * Writes <msg> to <out>
397      *
398      * x0 - out
399      * x1 - msg
400      * x2 - len
401      */
402 fwrite:
403     mov x8, SYS_WRITE
404     svc 0
405     ret
406
407 fread:
408     mov x8, SYS_READ
409     svc 0
410     ret