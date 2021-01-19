.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
	addi, sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    sw s4, 20(sp)
	
    beq a0, zero, fopen_error							# if a0 is a null pointer then exit with fopen error
    
    mv s0, a0											# is the pointer to string representing the filename
    mv s1, a1											# is a pointer to an integer, we will set it to the number of rows
    mv s2, a2											# is a pointer to an integer, we will set it to the number of columns

	# call to fopen:- int fopen(char *a1, int a2) _ a1 = filepath, a2 = permissions (0, 1, 2, 3, 4, 5 = r, w, a, r+, w+, a+)
    mv a1, s0											# loading filename
    li a2, 0											# read only permission
    jal fopen
    
    # retrieving return value
    mv s3, a0											# file descriptor
    
    # fopen error check
    li t0, -1											# fopen error flag
    beq a0, t0, fopen_error
    
    # call to fread:- rows
    # int fread(int a1, void *a2, size_t a3) _ a1 = file descriptor, a2 = pointer to the buffer you want to write 
    # the read bytes to, a3 = Number of bytes to be read.
    mv a1, s3											# copying file descriptor
    mv a2, s1											# copying address of rows
    li a3, 4											# read 4 bytes (sizeof(int))
    jal fread
    
    # fread error check
    li t0, 4
	bne a0, t0, fread_error								# if the number of bytes read does not equal 4 (sizeof(int)) [columns]

	# call to fread:- columns
    mv a1, s3											# copying file descriptor
    mv a2, s2											# copying address of rows
    li a3, 4											# read 4 bytes (sizeof(int))
    jal fread
    
    # fread error check
    li t0, 4
	bne a0, t0, fread_error								# if the number of bytes read does not equal 4 (sizeof(int)) [columns]
    
    lw t1, 0(s1)										# loading number of rows
    lw t2, 0(s2)										# loading number of columns
    
    # rows and columns validity check
    bge zero, t1, fread_error							# 0 >= t1 (invalid # of rows)
    bge zero, t2, fread_error							# 0 >= t2 (invalid # of cols)
    
    mul t3, t1, t2										# t3"number of entries" = rows * columns
    
    # call to malloc:- void* malloc(int a0) is the # of bytes to allocate heap memory for
    slli t3, t3, 2										# # of bytes for rows * columns
    mv a0, t3
    
    # saving # of bytes for rows * columns
    addi sp, sp, -4
    sw t3, 0(sp)
    
    jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error
    
    # retrieving t3, the # of bytes for rows * columns
    lw t3, 0(sp)
    # addi sp, sp, 4
    
    # saving pointer to malloc(k)ed space
    mv s4, a0
    
    # call to fread - reading the elements
	mv a1, s3											# copying file descriptor
    mv a2, s4											# copying pointer to buffer
    mv a3, t3											# # of bytes to be read
	jal fread
    
    # fread error check
    lw t3, 0(sp)
    addi sp, sp, 4
    bne a0, t3, fread_error
    
    # closing file stream
    mv a1, s3
    jal fclose
    
    # fclose error check
    li t0, -1
    beq a0, t0, fclose_error
    
    mv a0, s4											# copying pointer to malloced space to a0
    mv a1, s1
    mv a2, s2

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    lw s4, 20(sp)
	addi, sp, sp, +24

    ret

malloc_error:
	li a1, 88
    j exit2

fopen_error:
	li a1, 90
    j exit2
    
fread_error:
	li a1, 91
    j exit2
    
fclose_error:
	li a1, 92
    j exit2