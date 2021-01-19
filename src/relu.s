.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:

	addi t0, zero, 1					# t0 = 1
	bge a1, t0, loop_start				# if a1 >= t0 then loop_start 
    li a1, 78							# else a1 = 78 'error code'
    j exit2								# call exit2

	# Prologue

loop_start:
    li t0, 0							# t0 = 0
    li t1, 4							# t1 = 4
    mul a1, a1, t1						# a1 = a1 * 4 (calculating byte offset)
    
loop_continue:
	bge t0, a1, loop_end				# while t0 < a1
    
    add t1, a0, t0						# t1 = a0 + t0 (pointer arithmetic)
    lw t2, 0(t1)						# t2 = *t1
    
    bge t2, zero, loop_inc				# if t2 >= 0 then loop_inc
    add t2, zero, zero					# else t2 = 0
    sw t2, 0(t1)						#      *t1 = t2
    
    loop_inc:
	addi t0, t0, 4						# t0 += 1 (sizeof(int))
    j loop_continue						# go back to loop

loop_end:

    # Epilogue
    
	ret
