# Project 3
# ID = 03020812, N = (03020812 % 11) + 26 = 29, M = 29 - 10 = 19
.data
input: .space 1001 # Space required to save the input values
newLine: .asciiz "\n" 
cancel: .asciiz "?"
comma: .asciiz ","
slash: .asciiz "/"

.text
main:
li $t1, 29 # Storing N in registers t1

# Ask user for input value
la $a0, input
li $a1, 1001
li $v0, 8
syscall
li $v0, 4
la $a0, newLine
syscall

addi $t7, $zero, 1000 #characters left to parse through
la $t4, input
jal separate

# Exit Code
exit:
li $v0, 10
syscall

separate:
# Preprocessing (Remove leading and Trailing)
addi $s7, $zero, 0 
addi $t6, $zero, 0 # # of leading chars parsed through
adjustStart:
addu $t5,$t4,$t6                          
lbu $t0, 0($t5)                             
beq $t0,32,moveF 
beq $t0,9, moveF 
j endadjustStart

moveF:
addi $t6,$t6,1                             
j adjustStart           

endadjustStart:  
move $t4, $t5 

adjustEnd:
addi $t6, $zero, 0 
addi $t2, $zero, 0 

length:
addu $t4,$t5,$t6                           
lbu $t0, 0($t4)
beq $t0, 44, split
beq $t0, 10, endadjustEnd                           
blt $t0, 48, nextChar 
blt $t0, 123, validCount # probably a character 

j nextChar

validCount: addi $t2, $t2, 1
nextChar: addi $t6,$t6,1                             

bgt $t6, $t7, endadjustEnd
j length                             

split: addi $s7, $zero, 1

endadjustEnd: 
subu $t7, $t7, $t2 
beqz $t2, wrongInput 
bgt $t2, 4, wrongInput

addi $t3, $zero, 0 # Register to store final result. Initialized with 0
addi $sp, $sp, -4
sw $ra, 0($sp)
addu $a1, $t2, $zero 
addu $a0, $t5, $zero #Passing start of substring into 'begin' subroutine
jal begin
addu $t3, $zero, $v0
lw $ra, 0($sp)
addi $sp, $sp, 4

# Print output 

li $v0, 1
addu $a0, $zero, $a1
syscall
li $v0, 4
la $a0, slash
syscall
li $v0, 1
addu $a0, $zero, $t3
syscall

beq $s7, 1, nextSplit
jr $ra

nextSplit:
li $v0, 4
la $a0, comma
syscall
addi $t4, $t4, 1
j separate

wrongInput:
li $v0, 4
la $a0, cancel
syscall
beq $s7, 1, nextSplit
j exit

begin:
add $t0, $zero, $a0
add $t2, $zero, $a1
addi $v0, $zero, 0
addi $v1, $zero, 0

loop:
beq $t2, 1, bit0
beq $t2, 2, bit1
beq $t2, 3, bit2
beq $t2, 4, bit3
continue:
lb $s0, ($t0)
blt $s0, 48, wrongInputChar # invalid char

# Use case for char between 0 and 9
numberCase:
sub $s1, $s0, 48
bgt $s1, 9, upperCase
j sums

# Use case for char between A and S
upperCase:
sub $s1, $s0, 55
bgt $s1, 28, lowerCase
blt $s1, 10, wrongInputChar
j sums

# Use case for char between a and s
lowerCase:
sub $s1, $s0, 87
bgt $s1, 28, wrongInputChar
blt $s1, 10, wrongInputChar
j sums

# Adds up the current value of char to the total sum in output register
sums:
mul $s1, $s1, $s2 # multiply char by N^n
add $v0, $v0, $s1 # add to output register

addi $t0, $t0, 1
sub $t2, $t2, 1
bne $t2, 0, loop

jr $ra

bit0:
addi $s2, $zero, 1 
j continue
bit1:
addi $s2, $zero, 29
j continue 
bit2:
addi $s2, $zero, 841
j continue
bit3:
addi $s2, $zero, 24389
j continue

wrongInputChar:
lw $ra, 0($sp)
addi $sp, $sp, 4
j wrongInput
