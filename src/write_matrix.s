.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi, sp, sp, -24
	sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

	beq a0, zero, fopen_error							# if a0 is a null pointer then exit with fopen error
		
    mv s0, a0											# copying the pointer to string representing the filename
    mv s1, a1											# copying the pointer to the start of the matrix in memory
    mv s2, a2											# copying the number of rows in the matrix
    mv s3, a3											# copying the number of columns in the matrix 
    
    
	# call to fopen:- int fopen(char *a1, int a2) _ a1 = filepath, a2 = permissions (0, 1, 2, 3, 4, 5 = r, w, a, r+, w+, a+)
    mv a1, s0											# loading filename
    li a2, 1											# write permission
	jal fopen
    
    # fopen error check
    li t0, -1											# value returned by fopen in case of error
    beq a0, t0, fopen_error
    
    mv s4, a0											# saving file descriptor

	# --- writing number of rows ---
	# call to fwrite:- int fwrite(int a1, void *a2, size_t a3, size_t a4)
	# a1 = file descriptor, a2 = Buffer to read from, a3 = Number of items to read from the buffer.
    # a4 = Size of each item in the buffer.
    mv a1, s4											# copying file descriptor
	
    # copying the # of rows
    addi sp, sp, -4
    sw s2, 0(sp)
    mv a2, sp											
    
    li a3, 1											# number of items in the buffer
    li a4, 4											# size of each item.
    jal fwrite
    
    # fwrite error check
    li t0, 1											# # of items to be written
    bne t0, a0, fwrite_error
    
    
    # --- writing number of columns ---
    mv a1, s4											# copying file descriptor
    
    # copying the # of columns to stack 
    sw s3, 0(sp)
    mv a2, sp											
    
    li a3, 1											# number of items in the buffer
    li a4, 4											# size of each item.
    jal fwrite
    addi sp, sp, 4										# balancing the stack
    
    # fwrite error check
    li t0, 1											# # of items to be written
    bne t0, a0, fwrite_error
    
    # --- writing the entire contents of matrix ---
	# call to fwrite:- int fwrite(int a1, void *a2, size_t a3, size_t a4)
	# a1 = file descriptor, a2 = Buffer to read from, a3 = Number of items to read from the buffer.
    # a4 = Size of each item in the buffer.
    mv a1, s4											# copying file descriptor
    mv a2, s1											# copying address of matrix
    mul a3, s2, s3										# # of elems
	li a4, 4											# size of each elem
    jal fwrite
    
    # fwrite error check
    mul t0, s2, s3										# # of items to be written
    bne t0, a0, fwrite_error

	# closing file stream
    mv a1, s4
    jal fclose
    
    # fclose error check
    li t0, -1											# error code in case fclose fails
    beq a0, t0, fclose_error

    # Epilogue
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
	addi sp, sp, 24
    
    ret

fopen_error:
	li a1, 93
    j exit2
    
fwrite_error:
	li a1, 94
    j exit2
    
fclose_error:
	li a1, 95
    j exit2