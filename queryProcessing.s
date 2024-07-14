.data
array: .space 40000
larray: .space 40000
rarray: .space 40000
inputstring: .asciiz "n"
outputstring: .asciiz "\n"
blank: .asciiz " "
enter: .asciiz "\n"
jaluMC1 : .asciiz "loop1"
jaluMC2 : .asciiz "loop2"
jaluMC3 : .asciiz "loop3"
jaluMC4 : .asciiz "loop4"
jaluMC5 : .asciiz "loop5"
jaluMC6 : .asciiz "loop6" 

.text
main:
    # li $v0,4
    # la $a0 ,inputstring#print input statement
    # syscall
    li $v0,5
    syscall
    move $a0 $v0#take input n in a0
    addi $t0, $zero, 0 #byte counter
    li $s4,0#i=0
    addi $t1, $zero, 0 #number counter
    la $t4, array
    li $t3, 0
array_store:
    beq $t1,$a0,array_full #if required numbers already in then stop
    li $v0,5    #keep inputting numbers
    syscall
    sw $v0,array($t0)       #store in array
    addi $t0,$t0,4  #update byte counter
    addi $t1,$t1,1  #update number counter
    j array_store
array_full:
    # li $v0,4 #output output string
    # la $a0,outputstring
    # syscall
    
    li $t5,0#begin initialized to 0
    add $s0,$t1,$zero
    sub $s0,$s0,1
    add $t6,$s0,$zero#end initialized to n-1
    
    jal mergesort
    #binary search vaala part
    li $v0,5#input q
    syscall      
    move $s0 $v0  
    # addi $s1, $zero, 0 #byte counter
    addi $s2, $zero, 0 #number counter
    j q_store
    # li $t3,0 print kahin aur karenge
    # j print_loop
q_store:
    beq $s2,$s0,end_print #if required numbers already in then stop
    li $v0,5    #keep inputting numbers
    syscall
    move $t2 $v0 
    li $t5,0#l
    sub $t6,$t1,1#n-1
    jal bin
    # sw $t2,array($s1)  #store in array
    # addi $s1,$s1,4  #update byte counter
    addi $s2,$s2,1  #update number counter 
    j q_store
bin:
    bgt $t5,$t6,notf
    add $t7,$t5,$t6#computing mid
    divu $t7,$t7,2
    mul $t7,$t7,4
    lw $t0,array($t7)
    beq $t0,$t2,endbin
    blt $t0,$t2,updatel
    bgt $t0,$t2,updater
    j bin
notf:
    li $t8,-1
    add $a0,$t8,$zero
    li $v0,1
    syscall
    li $v0,4
    la $a0,outputstring
    syscall

    jr $ra
endbin:
    divu $t7,$t7,4
    add $t8,$t7,$zero
    add $a0,$t8,$zero
    li $v0,1
    syscall
    li $v0,4
    la $a0,outputstring
    syscall

    jr $ra
updatel:
    divu $t7,$t7,4
    addi $t5,$t7,1
    j bin 
updater:
    divu $t7,$t7,4
    addi $t6,$t7,-1
    j bin
mergesort:
    
    addi $sp, $sp, -12
    sw $ra,0($sp)
    sw $t5,4($sp)
    sw $t6,8($sp)
    bge $t5,$t6,end_merge_sort

    #t5-begin t6-end t7-mid
    
    add $t7,$t5,$t6
    srl $t7,$t7,1 #mid=begin+end/2
    
    add $t6,$t7,$zero#end=mid
    jal mergesort#mergesort(begin,mid)
    addi $sp,$sp,12
    lw $ra,0($sp)
    lw $t6,8($sp)
    lw $t5,4($sp)
    add $t7,$t5,$t6
    srl $t7,$t7,1
    addi $t5,$t7,1
    jal mergesort#mergersort(mid+1,end)
    addi $sp,$sp,12
    lw $ra,0($sp)
    lw $t5,4($sp)
    lw $t6, 8($sp)
    add $t7,$t5,$t6
    srl $t7,$t7,1
    jal merge
    addi $sp,$sp,12
    lw $ra,0($sp)
    lw $t6,8($sp)
    lw $t5,4($sp)
    add $t7,$t5,$t6
    srl $t7,$t7,1
    jr $ra
merge:

    addi $sp, $sp, -12
    sw $ra,0($sp)
    sw $t5,4($sp)
    sw $t6,8($sp)
    sub $t8,$t7,$t5
    addi $t8,$t8,1 #subarray1=mid-left+1
    sub $t9,$t6,$t7 #subarray2=right-mid
    li $s4,0
    j loop1
loop1:
    #leftarray initialization
    #using counter i=$s4
    #i=0;i<subarray1;i++ leftarray[i]=array[left+i]
    #  li $v0,4 #output output string
    # la $a0,jaluMC1
    # syscall
    
    bge $s4,$t8,loopx#i=subarray1 then exit
    add $s6,$t5,$s4#left+i calculation
    mul $s4,$s4,4
    mul $s6,$s6,4#bytes
    lw $t0,array($s6)#leftArray[i] = array[left + i];
    sw $t0,larray($s4)
    srl $s6,$s6,2
    srl $s4,$s4,2
    addi $s4,$s4,1#i++
    j loop1
loopx:
    li $s4,0#i=0
    j loop2
loop2:
    # li $v0,4 #output output string
    # la $a0,jaluMC2
    # syscall
    
    bge $s4,$t9,loop3#i=subarray2 then next
    add $s6,$t7,$s4
    addi $s6,$s6,1 #mid+1+j
    mul $s4,$s4,4#bytes i multiplied by 4
    mul $s6,$s6,4#bytes
    lw $t0,array($s6)#rightArray[j] = array[mid + 1 + j];
    sw $t0,rarray($s4)
    srl $s6,$s6,2
    srl $s4,$s4,2
    addi $s4,$s4,1#i++
    j loop2
loop3:
    # li $v0,4 #output output string
    # la $a0,jaluMC3
    # syscall
    li $s4,0#index of subarray1
    li $s5,0#index of subarray2
    add $s6,$t5,$zero#indexofmergedarray =left
    li $t3,0
    j loop4
loop4:
    # li $v0,4 #output output string
    # la $a0,jaluMC4
    # syscall
    bge $s4,$t8,loop5
    bge $s5,$t9,loop5
    mul $s4,$s4,4
    mul $s5,$s5,4
    lw $t0,larray($s4)#freeregisters t0,t2,s7
    lw $t2,rarray($s5)
    srl $s4,$s4,2
    srl $s5,$s5,2
    ble $t0,$t2,ifcon#leftArray[indexOfSubArrayOne] <=  rightArray[indexOfSubArrayTwo])
    bgt	$t0,$t2,elsecon
    j loop4
ifcon:
    #array[indexOfMergedArray] = leftArray[indexOfSubArrayOne];indexOfSubArrayOne++;
    mul $s4,$s4,4
    mul $s6,$s6,4
    lw $t0,larray($s4)
    sw $t0,array($s6)
    srl $s4,$s4,2
    srl $s6,$s6,2
    addi $s4,$s4,1
    #indexOfMergedArray++;
    addi $s6,$s6,1
    j loop4
elsecon:
    #array[indexOfMergedArray] = rightArray[indexOfSubArrayTwo];indexOfSubArrayTwo++;
    mul $s5,$s5,4
    mul $s6,$s6,4
    lw $t0,rarray($s5)
    sw $t0,array($s6)
    srl $s5,$s5,2
    srl $s6,$s6,2
    addi $s5,$s5,1
    #indexOfMergedArray++;
    addi $s6,$s6,1
    j loop4
loop5:
    # li $v0,4 #output output string
    # la $a0,jaluMC5
    # syscall
    bge $s4,$t8,loop6 #indexOfSubArrayOne < subArrayOne
    mul $s4,$s4,4
    mul $s6,$s6,4
    lw $t0,larray($s4)
    sw $t0,array($s6)#array[indexOfMergedArray] = leftArray[indexOfSubArrayOne];
    srl $s4,$s4,2
    srl $s6,$s6,2
    addi $s4,$s4,1#indexOfSubArrayOne++;
    addi $s6,$s6,1#indexOfMergedArray++;
    j loop5
loop6:
    # li $v0,4 #output output string
    # la $a0,jaluMC6
    # syscall
    bge $s5,$t9,end_merge #indexOfSubArrayTwo < subArrayTwo
    mul $s5,$s5,4
    mul $s6,$s6,4
    lw $t0,rarray($s5)
    sw $t0,array($s6)#array[indexOfMergedArray] = rightArray[indexOfSubArrayTwo];
    srl $s5,$s5,2
    srl $s6,$s6,2
    addi $s5,$s5,1#iindexOfSubArrayTwo++;
    addi $s6,$s6,1#indexOfMergedArray++;
    j loop6
end_merge_sort:
    # la $t4, array
    #counter

    # li $t3,0
    # j print_loop
    jr $ra
end_merge:
    li $t3,0
    jr $ra
# print_loop:  

#     beq $t3, $t1, end_print #counter = no.of elements
#     mul $t3,$t3,4
#     li $v0,1    
#     lw $a0,array($t3)
#     syscall
#     srl $t3,$t3,2
#     addi $t3, $t3, 1
#     j print_loop

end_print:
    li $v0, 10
    syscall
    # jr $ra