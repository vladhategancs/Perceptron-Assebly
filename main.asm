.586
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern printf: proc

extern fopen: proc
extern fclose: proc
extern fscanf: proc
extern fprintf: proc

public start

.data
	
	data_file_mode DB "r", 0
	data_file_name DB "data.txt", 0
	
	predictions_file_mode DB "w", 0
	predictions_file_name DB "predictions.txt", 0
	
	weights_file_mode DB "w", 0
	weights_file_name DB "weights.txt", 0
	
	read_format DB "%d %d %d", 0
	weights_format DB "%f %f %f", 0AH, 0
	predictions_format DB "%d", 0AH,0
	
	format DB "%d ", 0
	variable DD 0, 0
	
	column_format DB "%f ", 0
	row_format DB 0AH, 0
	message DB "Matrix: ", 0
	
	Matrix STRUCT
		rows DD ?			; Number of rows
		cols DD ?			; Number of columns
		data DD 2400 dup(?)	; The data stored in the matrix
	Matrix ENDS
	
	INPUT_MATRIX Matrix{200, 3, {0}}
	WEIGHTS_MATRIX Matrix{1, 3, {-0.040, 0.893, -0.576}}
	
	WEIGHTS_TRANSPOSED Matrix {, , {}}
	
	LABELS Matrix {200, 1, {}}
	
	PREDICTIONS Matrix {200, 1, {}}
	
	WEIGHTED_SUM Matrix {200, 1 , {}}
	
	temp DQ 0
	counter dd 0
	var dd 0
	
	a dd 0
	b dd 0
	l dd 0
	
	err dd 0
	
	data_file_adress dd 0
	predictions_file_adress dd 0
	weights_file_adress dd 0
	
	learning_rate dd 0.00001
	epochs DD 1500

	
.code

matrix_print PROC
	
	PUSH OFFSET message
	CALL printf
	ADD ESP, 4
	
	; EAX -> row count
	MOV EAX, -1
	MOV EDX, 0
	
	; ESI is pointing to the data stored in the matrix
	MOV ESI, [ESP + 4]
	
	rows_loop:
		; We increment the row count, reset the column count and then we check to see if we are out of bounds
		INC EAX
		; EBX -> column count
		MOV EBX, -1
		MOV ECX, DWORD PTR[ESI]
		CMP ECX, EAX
		JE finish
		
		; These registers are saved on the stack
		; because the printf function modifies them
		PUSH EAX
		PUSH ECX
		PUSH EDX
		
		PUSH OFFSET row_format
		CALL printf
		ADD ESP, 4
		
		POP EDX
		POP ECX
		POP EAX
		
		cols_loop:
			; We increment the column count and then we check to see if we are out of bounds
			; If we are we go to the next row
			INC EBX
			MOV ECX, DWORD PTR[ESI + 4]
			CMP ECX, EBX
			JE rows_loop
			
			; EAX and EBX are saved on the stack because the current row and column are saved in them.
			; The piece of code that follows modifies EAX and EBX.
			
			PUSH EAX
			PUSH EBX
			
			; We call index converter in order to find
			; the element at the position (i, j) in the matrix
			MOV EDX, DWORD PTR[ESI + 4]
			PUSH EDX
			PUSH EBX
			PUSH EAX
			CALL index_converter
			
			; These registers are saved on the stack
			; Because the printf function modifies them
			PUSH EAX
			PUSH ECX
			PUSH EDX
			
			; We write the element found at (i, j) on the screen
			fld DWORD PTR[ESI + 8 + 4*EAX]
			sub esp, 8
			fstp QWORD PTR[ESP]
			;MOV EDX, DWORD PTR[ESI + 8 + 4*EAX]
			
			PUSH OFFSET column_format
			CALL printf
			ADD ESP, 12
			
			; Restore the registers
			pop EDX
			POP ECX
			POP EAX
			
			; The row count and column count are restored
			POP EBX
			POP EAX
			
			; Go to the next iteration
			JMP cols_loop
	finish:
		; Print a new line
		PUSH OFFSET row_format
		CALL printf
		ADD ESP, 4
	; Clean up the stack
	ret 4
matrix_print ENDP

matrix_print1 PROC
	
	PUSH OFFSET message
	CALL printf
	ADD ESP, 4
	
	; EAX -> row count
	MOV EAX, -1
	MOV EDX, 0
	
	; ESI is pointing to the data stored in the matrix
	MOV ESI, [ESP + 4]
	
	rows_loop:
		; We increment the row count, reset the column count and then we check to see if we are out of bounds
		INC EAX
		; EBX -> column count
		MOV EBX, -1
		MOV ECX, DWORD PTR[ESI]
		CMP ECX, EAX
		JE finish
		
		; These registers are saved on the stack
		; because the printf function modifies them
		PUSH EAX
		PUSH ECX
		PUSH EDX
		
		PUSH OFFSET row_format
		CALL printf
		ADD ESP, 4
		
		POP EDX
		POP ECX
		POP EAX
		
		cols_loop:
			; We increment the column count and then we check to see if we are out of bounds
			; If we are we go to the next row
			INC EBX
			MOV ECX, DWORD PTR[ESI + 4]
			CMP ECX, EBX
			JE rows_loop
			
			; EAX and EBX are saved on the stack because the current row and column are saved in them.
			; The piece of code that follows modifies EAX and EBX.
			
			PUSH EAX
			PUSH EBX
			
			; We call index converter in order to find
			; the element at the position (i, j) in the matrix
			MOV EDX, DWORD PTR[ESI + 4]
			PUSH EDX
			PUSH EBX
			PUSH EAX
			CALL index_converter
			
			; These registers are saved on the stack
			; Because the printf function modifies them
			PUSH EAX
			PUSH ECX
			PUSH EDX
			
			; We write the element found at (i, j) on the screen
			;fld DWORD PTR[ESI + 8 + 4*EAX]
			;sub esp, 8
			;fstp QWORD PTR[ESP]
			MOV EDX, DWORD PTR[ESI + 8 + 4*EAX]
			push EDX
			PUSH OFFSET format
			CALL printf
			ADD ESP, 8
			
			; Restore the registers
			pop EDX
			POP ECX
			POP EAX
			
			; The row count and column count are restored
			POP EBX
			POP EAX
			
			; Go to the next iteration
			JMP cols_loop
	finish:
		; Print a new line
		PUSH OFFSET row_format
		CALL printf
		ADD ESP, 4
	; Clean up the stack
	ret 4
matrix_print1 ENDP

matrix_transpose PROC
	; Create a stack frame
	; to be able to use local variables
	PUSH EBP
	MOV EBP, ESP
	; Allocate memory for 2 local variables
	; i and j which will be used for indexing the rows and columns of the matrix
	; to be transposed.
	SUB ESP, 8
	
	; The matrix to be transposed
	MOV ESI, [EBP + 8]
	; The transposed matrix
	MOV EDI, [EBP + 12]
	
	; The tranpose matrix will have the reversed dimensions of the original matrix
	; i.e. a matrix with dimensions M X N will be transposed into a matrix N X M
	MOV EAX, DWORD PTR[ESI]
	MOV EBX, DWORD PTR[ESI + 4]
	MOV [EDI], BX
	MOV [EDI + 4], AX
	
	; Initialize i and j to -1
	MOV EAX, -1
	MOV [EBP-4], EAX
	MOV [EBP-8], EAX
	
	i_loop:
		; Increment i
		MOV EAX, [EBP - 4]
		INC EAX
		MOV [EBP - 4], EAX
		; Out of bounds?
		CMP EAX, DWORD PTR[ESI]
		JE end_transpose
		; Reset j
		MOV EAX, -1
		MOV [EBP - 8], EAX
	
		j_loop:
			; Increment j
			MOV EAX, [EBP-8]
			INC EAX
			MOV [EBP-8], EAX
			; Out of bounds?
			CMP EAX, DWORD PTR[ESI + 4]
			JE i_loop
			
			; Convert (i, j) to (i * cols + j)
			MOV EAX, DWORD PTR[ESI + 4]
			PUSH EAX
			MOV EAX, DWORD PTR[EBP - 8]
			PUSH EAX
			MOV EAX, DWORD PTR[EBP - 4]
			PUSH EAX
			CALL index_converter
			
			MOV EDX, 0
			MOV EDX, EAX
			
			; Save EDX on the stack
			; so it's value is not lost
			PUSH EDX
			
			; Convert (j, i) to (j * cols + i)
			MOV EAX, DWORD PTR[EDI + 4]
			PUSH EAX
			MOV EAX, DWORD PTR[EBP - 4]
			PUSH EAX
			MOV EAX, DWORD PTR[EBP - 8]
			PUSH EAX
			CALL index_converter
			
			; Restore the old value of EDX
			POP EDX
			
			MOV ECX, 0
			MOV ECX, EAX
			
			; transpode[j][i] = matrix[i][j]
			MOV EAX, DWORD PTR[ESI + 8 + 4*EDX]
			MOV DWORD PTR[EDI + 8 + 4*ECX], EAX
			
			; Go to the next iteration
			JMP j_loop
		
	end_transpose:
	
	; Restore the stack pointer`
	MOV ESP, EBP
	POP EBP
	
	; Clean up the stack
	ret 8
matrix_transpose ENDP

matrix_multiply PROC
	
	; Creating a stack frame
	; to be able to use local variables
	PUSH EBP
	MOV EBP, ESP
	
	; We allocate space for 3 local variables
	; i.e. i, j and k which will be used for indexing
	SUB ESP, 12
	
	; We initialize the indices to -1
	MOV EAX, -1
	MOV [EBP-4], EAX
	MOV [EBP-8], EAX
	MOV [EBP-12], EAX
	
	; The result of the matrix multiplication
	; will be stored in ESI
	MOV ESI, [EBP + 16]
	
	; EDI and EDX are the matrices we are multiplying
	MOV EDI, [EBP + 12]
	MOV EDX, [EBP + 8]
	
	; We check to see if the multiplication is possible
	; if not we jump to the end of the program, meaning
	; the multiplication will not occur
	MOV EAX, DWORD PTR[EDX + 4]
	CMP EAX, DWORD PTR[EDI]
	JNE multiply_end
	
	; If the multiplication is possible
	; the resulting matrix will have the number of rows of the first matrix
	; and the number of columns of the second matrix
	MOV EAX, DWORD PTR[EDX]
	MOV EBX, DWORD PTR[EDI + 4]
	MOV DWORD PTR[ESI], EAX
	MOV DWORD PTR[ESI + 4], EBX
	
	i_loop:
		; Increment i
		MOV EAX, [EBP-4]
		INC EAX
		MOV [EBP-4], EAX
		
		; Out of bounds?
		CMP EAX, DWORD PTR[ESI]
		JE multiply_end
		
		; Reset j
		MOV EAX, -1
		MOV [EBP-8], EAX
		j_loop:
			; Increment j
			MOV EAX, [EBP-8]
			INC EAX
			MOV [EBP-8], EAX
			
			; Out of bounds?
			CMP EAX, DWORD PTR[ESI + 4]
			JE i_loop
			
			; Reset k
			MOV EAX, -1
			MOV [EBP-12], EAX
			k_loop:
				; Increment k
				MOV EAX, [EBP-12]
				INC EAX
				MOV [EBP-12], EAX
				; Out of bounds?
				CMP EAX, DWORD PTR[EDX + 4]
				JE j_loop
				
				; Save the adress of one of the matrices on the stack
				; so we don't lose the reference to it
				PUSH EDX
				PUSH EDX
				
				; Convert (i, k) to (i * col + k)
				MOV EAX, DWORD PTR[EDX + 4]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP - 12]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP - 4]
				PUSH EAX
				CALL index_converter
				
				; Restore EDX
				POP EDX
				
				;CX = A[i][k]
				fild DWORD PTR[EDX + 8 + 4*EAX]
				
				; Convert (k, j) to (k * col + j)				
				PUSH ECX
				MOV EAX, DWORD PTR[EDI + 4]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP-8]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP-12]
				PUSH EAX
				CALL index_converter
				pop ECX
				
				; AX = B[k][j]
				fld DWORD PTR[EDI + 8 + 4*EAX]
				
				; CX = A[i][k] * B[k][j] 
				fmulp st(1), st(0)               ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				fstp DWORD PTR[var]
				
				
				; Convert (i, j) to (i * col + j)
				PUSH ECX
				MOV EAX, DWORD PTR[ESI + 4]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP - 8]
				PUSH EAX
				MOV EAX, DWORD PTR[EBP - 4]
				PUSH EAX
				CALL index_converter
				POP ECX
				
				;AX = RESULT[i][j]
				;ADD DWORD PTR[ESI + 8 + 4*EAX], ecx
				fld var
				fld DWORD PTR[ESI + 8 + 4*EAX]
				faddp st(1), st(0)
				fstp DWORD PTR[ESI + 8 + 4*EAX]
				
				; Restore the adress of one of the matrices
				POP EDX
				
				; Go to the next iteration
				JMP k_loop
	multiply_end:
	
	; Restore the stack pointer
	MOV ESP, EBP
	POP EBP
	; Clean up the stack
	ret 12
matrix_multiply ENDP

index_converter PROC
	
	; This function maps a 2 dimensional array index into an unidimensional array index
	; using the formula: (i, j) => (i * cols + j) where cols is the number of columns of the bidimensional array
	; and i and j are the current row and column
	
	; The number of columns
	MOV EAX, [ESP + 12]
	
	; The current column
	MOV EBX, [ESP + 8]
	
	; The current row
	MOV ECX, [ESP + 4]
	
	; EAX = i * cols
	MUL ECX
	; EAX = i * cols + j
	ADD EAX, EBX
	; Clean up the stack
	ret 12
index_converter ENDP

File_Read PROC
	; Open up the file
	PUSH OFFSET data_file_mode
	PUSH OFFSET data_file_name
	CALL fopen
	ADD ESP, 8
	
	MOV data_file_adress, EAX
	
	; We are going to read 200 points and labels
	MOV counter, 200
	MOV ESI, 8
	MOV EDI, 8
	
	read:
		PUSH OFFSET l
		PUSH OFFSET b
		PUSH OFFSET a
		PUSH OFFSET read_format
		PUSH data_file_adress
		CALL fscanf
		ADD ESP, 20
		
		MOV EBX, DWORD PTR[ESP + 4]
		MOV ECX, DWORD PTR[ESP + 8]
		
		MOV EAX, a
		MOV DWORD PTR[EBX + ESI], EAX
		ADD ESI, 4
		
		MOV EAX, b
		MOV DWORD PTR[EBX + ESI], EAX
		ADD ESI, 4
		
		MOV DWORD PTR[EBX + ESI], 1
		ADD ESI, 4
		
		MOV EAX, l
		MOV DWORD PTR[ECX + EDI], EAX
		ADD EDI, 4
		
		SUB counter, 1
		CMP counter, 0
		JNE read
	
	RET 8
File_Read ENDP

start:
	
	; MOV counter, 3
	; MOV EBX, 8
	; init_weights:
		; rdtsc				;EDX:EAX = SOME NUMBER
		; push EAX		    ;save the value of EAX on the CPU stack
		
		; fild dword ptr[ESP] ;Take the value of EAX from the top of the CPU stack and put it on the FPU stack
							  ;(also there's an implicit conversion from integer to 80bit floating point), ST(0) = THE VALUE OF EAX
		; push 7FFFFFFFH		;Push MAX_INT on the CPU stack
		; fild dword ptr[ESP] ;Load MAX_INT on the FPU stack, ST(0) = 7FFFFFFFH, ST(1) = THE VALUE OF EAX
		; fdivp st(1), st(0)	; ST(1) = ST(1) / ST(0) and pop ST(0) from the FPU stack => ST(0) = THE RESULT OF THE DIVISION
		
		; FSTP DWORD PTR[WEIGHTS_MATRIX + EBX]
		; ADD EBX, 4
		
		; ADD ESP, 8
		
		; SUB counter, 1
		; CMP counter, 0
		; JNE init_weights
		
	PUSH OFFSET WEIGHTS_MATRIX
	CALL matrix_print
	
	PUSH OFFSET LABELS
	PUSH OFFSET INPUT_MATRIX
	CALL File_Read
	
	PUSH OFFSET WEIGHTS_TRANSPOSED
	PUSH OFFSET WEIGHTS_MATRIX
	CALL matrix_transpose
	
	PUSH OFFSET weights_file_mode
	PUSH OFFSET weights_file_name
	CALL fopen
	ADD ESP, 8
	MOV weights_file_adress, EAX
	
	
	MOV EAX, epochs
	MOV a, EAX
	
	training_loop:
	
		PUSH OFFSET WEIGHTED_SUM
		PUSH OFFSET WEIGHTS_TRANSPOSED
		PUSH OFFSET INPUT_MATRIX
		call matrix_multiply
		
		FLD DWORD PTR[WEIGHTS_TRANSPOSED + 16]
		SUB ESP, 8
		FSTP QWORD PTR[ESP]
		FLD DWORD PTR[WEIGHTS_TRANSPOSED + 12]
		SUB ESP, 8
		FSTP QWORD PTR[ESP]
		FLD DWORD PTR[WEIGHTS_TRANSPOSED + 8]
		SUB ESP, 8
		FSTP QWORD PTR[ESP]
		PUSH OFFSET weights_format
		PUSH weights_file_adress
		CALL fprintf
		ADD ESP, 20
		
		MOV var, 200
		MOV ESI, 8
		Predict:
			MOV EAX, 1
			CMP DWORD PTR[WEIGHTED_SUM + ESI], 0
			JLE Negative
			JMP Done
			
			Negative:
				MOV EAX, -1
			
			Done:
				MOV DWORD PTR[PREDICTIONS + ESI], EAX
			
			ADD ESI, 4
			SUB var, 1
			CMP var, 1
			JNE Predict
			
			mov var, 200
			mov esi, 8
			mov edi, 8
			points:
				MOV eax, DWORD PTR[LABELS + ESI]
				CMP DWORD PTR[PREDICTIONS + ESI], EAX
				JE no_backprop
				
				mov b, 3
				mov EDX, 0
				backprop:
					
					FILD DWORD PTR[LABELS + ESI]
					FLD DWORD PTR[learning_rate]
					FMULP st(1), st(0)
						
					FILD DWORD PTR[INPUT_MATRIX + EDI + EDX]
					FMULP st(1), st(0)
					FLD DWORD PTR[WEIGHTS_TRANSPOSED + EDX + 8]
					FADDP st(1), st(0)
					FSTP DWORD PTR[WEIGHTS_TRANSPOSED + EDX + 8]
						
					ADD EDX, 4
					SUB b, 1
					CMP b, 0
					JNE backprop
					
				no_backprop:
					ADD EDI, 12
					
					ADD ESI, 4
					SUB var, 1
					CMP var, 0
				JNE points
		
		SUB a, 1
		CMP a, 0
	JNE training_loop
	
	PUSH OFFSET predictions_file_mode
	PUSH OFFSET predictions_file_name
	CALL fopen
	ADD ESP, 8
	
	MOV predictions_file_adress, EAX
	
	MOV counter, 200
	MOV ESI, 8
	
	write:
		PUSH DWORD PTR[PREDICTIONS + ESI]
		PUSH OFFSET predictions_format
		PUSH predictions_file_adress
		CALL fprintf
		ADD ESP, 12
		
		ADD ESI, 4
		SUB counter, 1
		CMP counter, 0
		JNE write
		
	PUSH predictions_file_adress
	CALL fclose
	
	PUSH weights_file_adress
	CALL fclose
	
	PUSH 0
	CALL exit
	
end start