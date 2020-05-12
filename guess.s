.code16
.globl start


start: #to set up printing a welcome message
movb $0x00, %ah
movb $0x03, %al
int $0x10
push $startmessage
call _printMSG

getsecs: #this section is specifically to put seconds into bl
xor %eax, %eax
xor %ebx, %ebx
xor %ecx, %ecx
xor %edx, %edx  #clearing all registers from now 

movb $0x00, %al
outb %al,$0x70 
inb $0x71, %al 
#this code places the clock's seconds into al. port 0x70 selects 
#a register (based on the value in al -- 0x00 is the seconds register) 
#and 0x71 will read the value from the selected register

#at this point, al contains a value between 0 and 59. to reduce it to 
#our desired range, we can use the div instruction.
#div can divide ax by any 8bit reg with the remainder stored in ah

movb $10, %cl 
div %cl
mov %ah, %bl 
#bl will now contain some seconds value between 0 and 9
#we moved the seconds there because to retrieve input, we need to use ax

comploop: #this loop compares user input with the value inside of bl
movb $0x0, %ah
int $0x16 #to accept user input -- the character will be in al
mov %al, %dl #moving the num to dl so we can print \n and \r 
movb $0x0E, %ah  #first printing the input -- moving 0E allows for single char prints 
int $0x10 
movb $0xA, %al #to print \n 
int $0x10 
movb $0xD, %al #to print \r 
int $0x10
sub $48, %dl #to convert the ascii num into a number between 0 and 9 
cmp %dl, %bl #the actual comparison step between input vs ournum 
je printright #a je to print out a success message
jmp printwrong #a jmp to print out a wrong message and redo the loop


printwrong: #this label is for printing if we guess incorrectly
push $wrongmessage
call _printMSG
restartmessage: #the printing of the original message if the wrong message was printed
push $startmessage
call _printMSG
jmp comploop

printright: #this section is for printing the success msg and ending
push $rightmessage
call _printMSG

done:
jmp done


startmessage:
.string "What number am I thinking of? (0-9) "

rightmessage:
.string "Right! Congratulations.\n\r"

wrongmessage:
.string "Wrong!\n\r"

_printMSG: #a function to print -- mimics the print loop from hello.s
push %bp
mov %sp,%bp

mov 4(%bp),%si
#the stack is 16 bits so we push the 16 bit base and stack ptrs and retrieve 
#our param from bp+4 (since bp+2 is the ret) 
printing: #the loop to print
lodsb
testb %al, %al
jz epi
movb  $0x0E,%ah
int $0x10
jmp printing


epi:
mov %bp,%sp
pop %bp
ret


.fill 510 - (. - start), 1, 0

.byte 0x55
.byte 0xAA
