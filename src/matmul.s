.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    li t0, 1							# t0 = 1
    
	# m0 dimensions check
    blt a1, t0, m0_fail					# if a1"rows0" < 1 then m0_fail
    bge a2, t0, m1_check				# if a2"cols0 >= t0"1" then m1_check
    
    m0_fail:
    li a1, 72							# else a1 = 72
    j exit2								# call exit2
    
    # m1 dimensions check
    m1_check:
    blt a4, t0, m1_fail					# if a1"rows1" < 1 then m1_fail
    bge a5, t0, matching_check			# if a2"cols1 >= t0"1" then matching_check
    
    m1_fail:
    li a1, 73							# else a1 = 72
    j exit2								# call exit2

	# matrices matching check
	matching_check:
    beq a2, a4, calc_offsets			# if cols0 == rows1 then loop_start
    li a1, 74							# load error code 74
    j exit2								# call exit2
    
    calc_offsets:
    # calculating offsets
    mul t2, a1, a2						# calculating max rows0 offset
    slli t2, t2, 2						# byte offset
    slli t5, a5, 2						# t5 = a5 * 2 * 2 (calculating byte offset for cols1)
    
	li t0, 0							# t0"i" = 0
	li t4, 0
    
outer_loop_continue:
	li t1, 0							# t1"j" = 0
	bge t0, t2, outer_loop_end			# while i < rows0
	
inner_loop_continue:
	bge t1, t5, inner_loop_end			# while j < cols1

	# Backing up registers
    addi sp, sp, -52
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw t0, 28(sp)
    sw t1, 32(sp)
    sw t2, 36(sp)
    sw t5, 40(sp)
    sw ra, 44(sp)
    sw t4, 48(sp)
    
    # a0: is in correct position, we just need to adjust for correct offset.
    add a0, a0, t0						# &mul0 += cols0 * row
    # a1: copying and adjusting offeset
    add a1, t1, a3						# a1 = a3"pointer to m1"
    # a2 is in correct position.    
    li a3, 1							# a3 = 1"stride_0"
    add a4, zero, a5					# a4 = cols1"stride_1"
    
    jal dot
    add t6, zero, a0					# retrieving return val before it is lost!
    
    # Restoring registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw t0, 28(sp)
    lw t1, 32(sp)
    lw t2, 36(sp)
    lw t5, 40(sp)
    lw ra, 44(sp)
    lw t4, 48(sp)
    addi sp, sp, 52

	add t3, t4, t1
    add t3, t3, a6						# t3 = "&m2 + cols0 * row + col
    sw t6, 0(t3)						# *C(&m2 + cols0 * row + col) = dot(Ai, Bj)
    
	addi t1, t1, 4						# increment j
    j inner_loop_continue
    
inner_loop_end:
	li t3, 4
	mul t3, t3, a2
	add t0, t0, t3						# increment i

	li t3, 4,
	mul t3, t3, a5
	add t4, t4, t3
	j outer_loop_continue
    
outer_loop_end:
    
    ret
