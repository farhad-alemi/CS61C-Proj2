.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

	addi t0, zero, 1					# t0 = 1
	bge a1, t0, loop_start				# if a1 >= t0 then loop_start 
    li a1, 77							# else a1 = 77 'error code'
    j exit2								# call exit2

	# Prologue

loop_start:
    li t0, 0							# t0 = 0
    li t1, 4							# t1 = 4
    mul a1, a1, t1						# a1 = a1 * 4 (calculating byte offset for vector size)
    lw t3, 0(a0)						# t3 = *a0 (initializing max to first elem)
    li t4, 0							# t4 = 0 (max_index = 0)
    
loop_continue:
	bge t0, a1, loop_end				# while t0 < a1
    
    add t1, a0, t0						# t1 = a0 + t0 (pointer arithmetic)
    lw t2, 0(t1)						# t2 = *t1
    
    bge t3, t2, loop_inc				# if t3 >= t2 then loop_inc
    add t3, zero, t2					# else t3"max" = t2
    add t4, zero, t0					#      t4"max_index" = t0
    
    loop_inc:
	addi t0, t0, 4						# t0 += 1 (sizeof(int))
    j loop_continue						# go back to loop

loop_end:
    srli a0, t4, 2						# a0 = t4 >> 2 (t4 / 2 / 2) changing offset val to index

    # Epilogue


    ret
