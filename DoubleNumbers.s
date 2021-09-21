	.arch armv8-a

	.data
	MSG_ERROR_FORMAT: .asciz "Incorrect format\n"
	LMSG_ERROR_FORMAT = . - MSG_ERROR_FORMAT

	MSG_ERROR_FILE: .asciz "Incorrect file content\n"
	LMSG_ERROR_FILE = . - MSG_ERROR_FILE

	FORM_DOUBLE: .asciz "%lf\n"
	LFORM_DOUBLE = . - FORM_DOUBLE

	FORM_INT: .asciz "%d\n"
	LFORM_INT = . - FORM_INT
	
	type: .asciz "r"
	count: .word 8
	buffer_element: .skip 8

	.text
	.align 2
	.global main
	.type main, %function
	.equ prog_name, 32
	.equ file_name, 40
	.equ file_pointer, 48
	.equ count_of, 56
	.equ vector, 64

main:
	sub sp, sp, 544
	stp x29, x30, [sp]
	stp x27, x28, [sp, 16]
	mov x29, sp

	cmp w0, 2
	beq check_args
	bl error_format
	b exit


exit:
	mov w0, 1
	ldp x29, x30, [sp]
	ldp x27, x28, [sp, 16]
	add sp, sp, 544
	ret


check_args:
	ldr x0, [x1]
	str x0, [x29, prog_name]
	ldr x0, [x1, 8]
	str x0, [x29, file_name]
	
	ldr x1, =type
	bl fopen
	cbnz x0, 1f
	ldr x0, [x29, file_name]
	bl perror
	b exit

1:
	str x0, [x29, file_pointer]
	ldr x1, =FORM_INT
	ldr x2, =count
	bl fscanf

	cmp w0, 1
	bne 93f

	/*adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_INT
	ldr x2, =count
	ldr x2, [x2]
	bl fprintf */ //printf count

	adr x0, count
	ldr x0, [x0]
	cmp x0, 20
	bgt 93f
	cmp x0, 1
	blt 93f
	b do_work

93:
	bl error_file_content
	b exit


error_format:
	str x30, [sp, -8]!

	adr x0, stderr
	ldr x0, [x0]
	ldr x1, =MSG_ERROR_FORMAT
	bl fprintf

	ldr x30, [sp], 8
	ret

error_file_content:
	str x30, [sp, -8]!
	
	ldr x0, [x29, file_pointer]
	bl fclose

	adr x0, stderr
	ldr x0, [x0]
	ldr x1, =MSG_ERROR_FILE
	ldr x2, =LMSG_ERROR_FILE
	bl fprintf

	ldr x30, [sp], 8
	ret


do_work:
	ldr x0, [x29, file_pointer]
	ldr x1, =FORM_DOUBLE
	add x2, x29, vector
	bl fscanf
	cmp w0, 1
	bne 93f

	/*ldr d20, [x29, vector]
	adr x0, buffer_element
	str d20, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf*/
	
	mov x4, 8
	ldr x0, [x29, file_pointer]
	ldr x1, =FORM_DOUBLE
	add x2, x29, vector
	add x2, x2, x4
	bl fscanf
	cmp w0, 1
	bne 93f

	//mov x4, 8
	//add x2, x4, vector
	/*ldr d21, [x29, vector]
	adr x0, buffer_element
	str d21, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf*/

	/*adr x0, buffer_element
	str d21, [x0]
	/*adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr x2, [x2]
	bl fprintf*/
	
	mov x4, 16
	ldr x0, [x29, file_pointer]
	ldr x1, =FORM_DOUBLE
	add x2, x29, vector
	add x2, x2, x4
	bl fscanf
	cmp w0, 1
	bne 93f

	/*mov x4, 16
	add x2, x4, vector
	ldr d22, [x29, x2]
	adr x0, buffer_element
	str d22, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr x2, [x2]
	bl fprintf*/

	/*adr x0, buffer_element
	str d22, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr x2, [x2]
	bl fprintf*/

	mov x27, 1

1:
	mov x28, 0

2:
	mov x4, 24
	ldr x0, [x29, file_pointer]
	ldr x1, =FORM_DOUBLE
	lsl x2, x28, 3
	add x2, x2, x29
	add x2, x2, vector
	add x2, x2, x4
	bl fscanf

	/*mov x4, 32
	add x2, x4, vector
	ldr d20, [x29, x2]
	adr x0, buffer_element
	str d20, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf*/

	cmp w0, 1
	bne 93f
	



	mov x0, 1
	add x28, x28, x0
	cmp x28, 3
	blt 2b

	mov x4, 8
	ldr d20, [x29, vector]
	add x2, x4, vector
	ldr d21, [x29, x2]
	add x2, x2, x4
	ldr d22, [x29, x2]
	add x2, x2, x4
	ldr d23, [x29, x2]
	add x2, x2, x4
	ldr d24, [x29, x2]
	add x2, x2, x4
	ldr d25, [x29, x2]
	
	/*adr x0, buffer_element
	str d24, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf*/

	fmul d0, d21, d25
	fmul d1, d22, d24
	fsub d3, d0, d1

	fmul d0, d20, d25
	fmul d1, d22, d23
	fsub d4, d0, d1
	fneg d4, d4

	fmul d0, d20, d24
	fmul d1, d21, d23
	fsub d5, d0, d1
	
	mov x0, 8
	str d3, [x29, vector]
	add x2, x0, vector
	str d4, [x29, x2]
	add x2, x2, x0
	str d5, [x29, x2]

	mov x0, 1
	add x27, x27, x0
	adr x0, count
	ldr x0, [x0]
	cmp x27, x0
	blt 1b
	
	ldr d20, [x29, vector]
	adr x0, buffer_element
	str d20, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf

	mov x0, 8
	add x2, x0, vector
	ldr d20, [x29, x2]
	adr x0, buffer_element
	str d20, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf

	mov x0, 16
	add x2, x0, vector
	ldr d20, [x29, x2]
	adr x0, buffer_element
	str d20, [x0]
	adr x0, stdout
	ldr x0, [x0]
	ldr x1, =FORM_DOUBLE
	ldr x2, =buffer_element
	ldr d0, [x2]
	bl fprintf

	b exit

93:
	bl error_file_content
	b exit
