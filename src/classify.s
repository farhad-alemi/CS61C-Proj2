.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminates the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

	li t0, 5														# num. of args
	bne a0, t0, incorrect_num_args									# if incorrect num. args then

	# Prologue
	addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)
    
    
	# Saving arguments
    mv s0, a1														# [FILE_NAME] <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    addi s0, s0, 4													# <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    mv s1, a2														# print_classification
    
	# =====================================
    # LOAD MATRICES
    # =====================================
    
    # --- Functions Signatures ---    
    # malloc:-    a0 is the # of bytes to allocate heap memory for
	# return:
	#		      a0 is the pointer to the allocated heap memory
    
    # read_matrix:- a0 (char*) is the pointer to string representing the filename
	#			    a1 (int*)  is a pointer to an integer, we will set it to the number of rows
    #  			    a2 (int*)  is a pointer to an integer, we will set it to the number of columns
	# Returns:
	#   		    a0 (int*)  is the pointer to the matrix in memory
    
    # Load pretrained m0
	# malloc space for rows and cols of m0
    li a0, 8
    jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error

    mv, s2, a0														# rows and cols for m0
    
	# reading m0
   	mv a0, s0														# pointer to m0_path
    lw a0, 0(a0)													# m0_path
    mv a1, s2														# pointer to m0_rows
    addi a2, s2, 4													# pointer to m0_cols
    jal read_matrix
    
    # retrieving pointer to m0
    mv s3, a0														# pointer to m0
    
    
    
    # Load pretrained m1
    # malloc space for rows and cols of m1
    li a0, 8
    jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error

    mv, s4, a0														# rows and cols for m1
    
	# reading m1
   	mv a0, s0														# pointer to m0_path
    addi a0, a0, 4													# pointer to m1_path
    lw a0, 0(a0)													# m1_path
    
    mv a1, s4														# pointer to m1_rows
    
    mv a2, s4														
    addi a2, a2, 4													# pointer to m1_cols
    jal read_matrix
    
    # retrieving pointer to m1
    mv s5, a0														# pointer to m1


    # Load input matrix
	# malloc space for rows and cols of input_matrix
    li a0, 8
    jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error

    mv, s6, a0														# rows and cols for input_matrix
    
	# reading input_matrix
   	mv a0, s0														# pointer to m0_path
    addi a0, a0, 8													# pointer to input_matrix
    lw a0, 0(a0)													# input_matrix
    
    mv a1, s6														# pointer to input_matrix_rows														
    addi a2, s6, 4													# pointer to input_matrix_cols
    jal read_matrix
    
    # retrieving pointer to input_matrix
    mv s7, a0														# pointer to input_matrix

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    
    # matmul:- # 	d = matmul(m0, m1)
    # Arguments:
    # 	a0 (int*)  is the pointer to the start of m0 
    #	a1 (int)   is the # of rows (height) of m0
    #	a2 (int)   is the # of columns (width) of m0
    #	a3 (int*)  is the pointer to the start of m1
    # 	a4 (int)   is the # of rows (height) of m1
    #	a5 (int)   is the # of columns (width) of m1
    #	a6 (int*)  is the pointer to the the start of d
    
	# calculating dimensions of hidden_layer
    lw t0, 0(s2)													# m0_rows
    lw t1, 4(s6)													# input_matrix_cols
    mul a0, t0, t1													# total # of elems in hidden_layer
    mv s9, a0														# saving # of elems in hidden_layer
    
    # call to malloc
    slli a0, a0, 2													# # of bytes in # of elems in hidden_layer
	jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error
    
    # retrieving pointer to malloced memory
    mv s8, a0														# pointer to hidden_layer
    
    # call to matmul
    mv a0, s3														# copying pointer to m0
    lw a1, 0(s2)													# copying the number of m0_rows
    lw a2, 4(s2)													# copying the number of m0_cols
    
    mv a3, s7														# copying pointer to input_matrix
    lw a4, 0(s6)													# copying the number of input_matrix_rows
    lw a5, 4(s6)													# copying the number of input_matrix_cols
    mv a6, s8
    jal matmul
    
    # ReLU: Performs an inplace element-wise ReLU on an array of ints
    # Arguments:
    # 	a0 (int*) is the pointer to the array
    #	a1 (int)  is the # of elements in the array
    
	mv a0, s8														# copying pointer to hidden_layer
    mv a1, s9														# copying # of elems in hidden_layer
    jal relu
    
    
    # mallocing space for scores
    lw t0, 0(s4)													# m1_rows
    lw t1, 4(s6)													# hidden_layer_cols
    mul a0, t0, t1													# # of elems in scores
    slli a0, a0, 2													# # of bytes in # of elems in scores
	jal malloc
    
    # malloc error check
    beq a0, zero, malloc_error
    
    mv s10, a0														# copying pointer to scores
    
    # calling matmul(m1, hidden_layer)
    mv a0, s5														# copying pointer to m1
    lw a1, 0(s4)													# m1_rows
    lw a2, 4(s4)													# m1_cols
    mv a3, s8														# copying pointer to hidden_layer
    lw a4, 0(s2)													# m0_rows == hidden_layer_rows
    lw a5, 4(s6)													# input_matrix_cols  == hidden_layer_cols
    mv a6, s10														# copying pointer to scores
	jal matmul
    
	
    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    # write_matrix:-
    #   a0 (char*) is the pointer to string representing the filename
	#   a1 (int*)  is the pointer to the start of the matrix in memory
	#   a2 (int)   is the number of rows in the matrix
	#   a3 (int)   is the number of columns in the matrix
    addi a0, s0, 12													# copying pointer (s0 + 3 * (sizeof(int))) == output_path
    lw a0, 0(a0)													# output_path
    mv a1, s10														# copying pointer to scores
    lw a2, 0(s4)													# m1_rows == scores_rows
    lw a3, 4(s6)													# input_matrix_cols  == hidden_layer_cols == scores_cols	
	jal write_matrix


    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    
	# argmax:- 
    # Arguments:
    # 	a0 (int*) is the pointer to the start of the vector
    #	a1 (int)  is the # of elements in the vector
    # Returns:
    #	a0 (int)  is the first index of the largest element
	mv a0, s10														# copying pointer to scores
    
    lw t0, 0(s4)													# m1_rows == scores_rows
    lw t1, 4(s6)													# input_matrix_cols  == hidden_layer_cols == scores_cols	
    mul a1, t0, t1													# total number of elements in scores
    jal argmax
    
    mv s11, a0														# copying classification
    
	bne s1, zero, free_mallocs
    
    # Print classification
    
    # --- functions signatures ---
    # print_int:-
    # args:
	#   a1 = integer to print
    
    # print_char:-
    # args:
    # a1 = character to print
        
    mv a1, s11														# copying classification value
    jal print_int
    
    # Print newline afterwards for clarity
    li a1, 10
    jal print_char

	free_mallocs:
    # void free(int a0)
	# args:
	#   a0 is the pointer to heap memory to free
    mv a0, s2
    jal free														# free m0_rows-cols
    
    mv a0, s3
    jal free														# free m0
    
    mv a0, s4
    jal free														# free m1_rows-cols
    
    mv a0, s5
    jal free														# free m1
	
    mv a0, s6
    jal free														# free input_matrix_rows-cols
    
    mv a0, s7
    jal free														# free input_matrix
    
    mv a0, s9
    jal free														# free # of elems in hidden_layer
    
    mv a0, s8
    jal free														# free hidden_layer
    
    mv a0, s10
    jal free														# free scores
  

	mv a0, s11

	# Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52

	ret

incorrect_num_args:
	li a1, 89
    j exit2
    
malloc_error:
	li a1, 88
    j exit2