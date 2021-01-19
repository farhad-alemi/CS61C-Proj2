.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
	# length check
	addi t0, zero, 1					# t0 = 1
	bge a2, t0, check_stride			# if a2 >= t0 then check_stride 
    li a1, 75							# else a1 = 75 'error code'
    j exit2								# call exit2

	#stride check
	check_stride:
    blt a3, t0, stride_fail 			# if stride1 < 1 then stride_fail 
    bge a4, t0, loop_start				# if stride2 >= 1 then loop_start
    
    stride_fail:
    li a1, 76							# else a1 = 76
    j exit2								# call exit2
    
	# Prologue

loop_start:
    li t0, 0							# t0"loop_index" = 0 
    slli a2, a2, 2						# a2 = a2 * 2 * 2 (calculating byte offset for vector size)
    li t6, 0							# dot product final result
loop_continue:
	bge t0, a2, loop_end				# while loop_index < vector_size
    
    # vec1 loading process
    mul t1, t0, a3						# t1 = loop_index * stride_1
    add t1, a0, t1						# t1"&vect1" = a0 + t1 (pointer arithmetic)
    lw t2, 0(t1)						# t2"v1[t0]" = *t1
    
    # vec2 loading process
    mul t3, t0, a4						# t3 = loop_index * stride_2
    add t3, a1, t3						# t3"&vect2" = a1 + t3 (pointer arithmetic)
    lw t4, 0(t3)						# t4"v2[t0]" = *t3
    
    # performing dot product
    mul t5, t2, t4						# t5"temp_result" = t2 * t4
    add t6, t6, t5						# t6"result" += t5
    
    # loop inc.
	addi t0, t0, 4						# t0 += 1 (sizeof(int))
    j loop_continue						# go back to loop

loop_end:
    add a0, x0, t6

    # Epilogue

    
    ret
