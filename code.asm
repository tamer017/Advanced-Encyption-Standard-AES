;subByte 
subByte macro  
        local l
        Mov si,0
        mov di,0
       l: mov al,array[si] 
          mov ah,0
          mov di,ax
          mov al,sbox[di]
          mov array[si],al 
          inc si
          cmp si,16
          jnz l
endm 
;shift raws iterative 
     shiftraws macro 
        mov al,0
        mov ah,0
        mov bl,0
        mov bh,0
        mov si,7
        mov al,array[si]
        mov ah,array[si-1]
        mov bl,array[si-2]
        mov bh,array[si-3]
        mov array[si],bh
        mov array[si-1],al
        mov array[si-2],ah
        mov array[si-3],bl
        add si,4   
        mov al,array[si]
        mov ah,array[si-1]
        mov bl,array[si-2]
        mov bh,array[si-3]
        mov array[si],bl
        mov array[si-1],bh
        mov array[si-2],al
        mov array[si-3],ah  
        add si,4   
        mov al,array[si]
        mov ah,array[si-1]
        mov bl,array[si-2]
        mov bh,array[si-3]
        mov array[si],ah
        mov array[si-1],bl
        mov array[si-2],bh
        mov array[si-3],al
     endm 
     ;shift raws with loops 
     shiftraws1 macro 
        local r,shift,l1,l2,fillx,fillarray,l
          mov dx,4;constent(length of x)
        mov cx,1;number of shifts
        mov al,0  
        mov si,4
        r: 
        mov di,0
        fillx:mov al,array[si]
        mov x[di],al
        inc di
        inc si
        cmp di,4
        jnz fillx
        sub si,dx 
        mov bx,dx
        sub bx,cx
        mov di,bx
        shift:mov al,array[si]
              mov x[di],al 
              inc di
              inc si 
              cmp dx,di
              jz l1
              jmp shift 
        l1:mov di,0
        l:mov al,array[si]
        mov x[di],al
        inc di
        inc si
        cmp di,bx
        jz l2 
        jmp l 
        l2:mov di,0 
        sub si,dx
        fillarray:mov al,x[di]
        mov array[si],al
        inc di
        inc si
        cmp di,4
        jnz fillarray
        inc cx
        cmp cx,4
        jnz r
     endm  
     mixcolumns macro 
        local r,fillx,l,l1,l2,l3,raws,columns,resetsi,end1,one,two,two1,three,end
        mov si,0
        mov cx,0
        mov dx,4 
        mov di,0
        r:
        mov dx,0
        mov si,cx
        fillx:   ;fill x with the columns of the array
        mov al,array[si]
        mov x[di],al
        inc di
        add si,4 
        inc dx
        cmp dx,4
        jnz fillx
        inc cx
        cmp cx,4
        jnz r  
         mov al,0
        mov bl,0
        mov cl,0
        mov dl,0
        mov ah,0
        mov bh,0
        mov ch,0
        mov dh,0
        mov bp,0
        
        
        
        
        
        raws:
        mov sp,bp
        mov si,bp
        add bp,4 
        mov ch,0 
        mov di,0
       columns:
       mov ch,0 
       l3: mov al,x[di]
           mov bl,a[si]        
        cmp bl,01h
        jz one 
        cmp bl,02h 
        jz two
        cmp bl,03h
        jz three
        l:xor ch,al 
        inc si
        inc di
        cmp si,bp   
        jnz l3                                           
        mov al,ch  
        cmp di,16
        jz end1
        cmp di,4
        jz resetsi
        cmp di,8
        jz resetsi
        cmp di,12
        jz resetsi
        resetsi:
        mov si,dx 
        mov array[si],al
        mov si,sp     
        inc dx
        jmp columns
        end1:
        mov si,dx 
        mov array[si],al
        inc dx 
        cmp dx,16  
        jnz raws
         jmp end
        ;end:ret 
        one:
        mov al,x[di] 
        cmp bl,03h
        jz l2
        jmp l
        two:
        cmp al,10000000b
        jae two1
        mov bh,2
        mul bh
        cmp bl,03h
        jz l1
        jmp l
        two1:
        mov bh,10000000b
        sub al,bh
        mov bh,2
        mul bh
        xor al,01bh 
        cmp bl,03h
        jz l1
        jmp l
        three:
        jmp two
        l1:mov cl,al 
        jmp one
        l2:xor al,cl 
        jmp l
        end:
     endm 
     AddRoundKey macro   
        local l
        mov si,0
        l:mov al,array[si]
        mov bl,roundkey[si]
        xor al,bl
        mov array[si],al
        inc si
        cmp si,16
        jnz l
        ret 
     endm 
     generatew0 macro
        local l1,l2,l3,l4,l5,l6,end,l 
        mov si,0
        mov di,0
        transpose: ; find the round key transpose and put the answer in temp roundkey
        mov al,roundkey[si]
        mov temproundkey[di],al
        inc di
        cmp si,12
        jz one
        cmp si,13 
        jz two
        cmp si,14
        jz three
        add si,4
        l:cmp di,16
        jnz transpose
        mov si,0
        mov di,0
        ;generate w0
        l1:
        mov al,temproundkey[si]
        mov word2[di],al 
        inc di
        inc si
        cmp di,4 
        jnz l1
        mov si,rconindex;m4 keda
        mov di,0 
        l2:
        mov al,rcon[si]
        mov word1[di],al
        inc di
        inc si
        cmp di,4 
        jnz l2
        ;w3 with 8bit shift
        mov si,13
        mov di,0
        l3:mov al,temproundkey[si]
        mov word3[di],al
        inc di
        inc si
        cmp di,3 
        jnz l3
        mov al,temproundkey[12]
        mov word3[3],al
        ;subByte of w3 after shift
        Mov si,0
        mov di,0
       l4: mov al,word3[si] 
          mov ah,0
          mov di,ax
          mov al,sbox[di]
          mov word3[si],al 
          inc si
          cmp si,4
          jnz l4 
        mov si,0  
        l5:mov al,0
           xor al,word1[si]
           xor al,word2[si]
           xor al,word3[si]
           mov w0[si],al
           inc si
           cmp si,4
           jnz l5
           mov si,0
         l6: 
           mov al,w0[si]
           mov roundkey[si],al
           inc si
           cmp si,4
           jnz l6
           jmp end
        one:mov si,1
        jmp l
        two:mov si,2
        jmp l
        three:mov si,3
        jmp l
        end:       
     endm
     generatewi macro
        local l1,l2,l3,l4,l5 
     mov dx,0;m4 keda bymshy 3ala k[n] men 0:12  roundkey 
     mov cx,4;m4 keda bymshy 3ala k[n-1] men 4:16 temproundkey 
     
     l5:
     mov si,0
     mov di,cx
     
     l1:mov al,temproundkey[di]
     mov word1[si],al
     inc di
     inc si
     cmp si,4
     jnz l1 
     add cx,4
     mov si,dx
     mov di,0
     
     l2:mov al,roundkey[si]
     mov word2[di],al
     inc si
     inc di
     cmp di,4
     jnz l2
     add dx,4 
     mov si,0
     l3:
     mov al,0
     xor al,word1[si]
     xor al,word2[si]
     mov word3[si],al
     inc si
     cmp si,4
     jnz l3
     
     mov si,0
     mov di,dx  
     l4:mov al,word3[si]
     mov roundkey[di],al
     inc di
     inc si
     cmp si,4
     jnz l4
     cmp dx,12
     jnz l5 
     
     endm 
 generateroundkey macro
    local transpose,l,one,two,three,l1,end
    mov di,0
    mov si,0
     
     transpose: ; find the round key transpose and put the answer in temp roundkey
        mov al,roundkey[si]
        mov temproundkey[di],al
        inc di
        cmp si,12
        jz one
        cmp si,13 
        jz two
        cmp si,14
        jz three
        add si,4
        l:cmp di,16
        jnz transpose
        mov di,0
        l1:mov al, temproundkey[di]
        mov roundkey[di],al
        inc di
        cmp di,16
        jnz l1
        jmp end
        one:mov si,1
        jmp l
        two:mov si,2
        jmp l
        three:mov si,3
        jmp l
        end:      
 endm
 arrayxorkey macro 
    local l
    mov si,0
    
    l:
    mov al,0
    xor al,array[si]
    xor al,roundkey[si]
    mov array[si],al
    inc si
    cmp si,16
    jnz l
    
    endm
 
 org 100h
.data segment       
    a db 02h,03h,01h,01h,01h,02h,03h,01h,01h,01h,02h,03h,03h,01h,01h,02h   
    ;roundkey db 0F2h, 7Ah, 59h, 73h, 0C2h, 96h, 35h, 59h, 95h, 0B9h, 80h, 0F6h, 0F2h, 43h, 7Ah, 7Fh
    ;roundkey db 0a0h,088h,023h,02ah,0fah,054h,0a3h,06ch,0feh,02ch,039h,076h,017h,0b1h,039h,005h 
    roundkey db 02bh,028h,0abh,009h,07eh,0aeh,0f7h,0cfh,015h,0d2h,015h,04fh,016h,0a6h,088h,03ch
    temproundkey db 0a0h,088h,023h,02ah,0fah,054h,0a3h,06ch,0feh,02ch,039h,076h,017h,0b1h,039h,005h
    array db 032h,088h,031h,0e0h,043h,05ah,031h,037h,0f6h,030h,098h,007h,0a8h,08dh,0a2h,034h
    ;array db 019h,0a0h,09ah,0e9h,03dh,0f4h,0c6h,0f8h,0e3h,0e2h,08dh,048h,0beh,02bh,02ah,008h 
    ;array db 04h, 0E0h, 48h, 28h, 66h, 0CBh, 0F8h, 06h, 81h, 19h, 0D3h, 26h, 0E5h, 9Ah, 7Ah, 4Ch
    sbox    db 63h,7ch,77h,7bh,0f2h,6bh,6fh,0c5h,30h,01h,67h,2bh,0feh,0d7h,0abh,76h 
       db 0cah,82h,0c9h,7dh,0fah,59h,47h,0f0h,0adh,0d4h,0a2h,0afh,9ch,0a4h,72h,0c0h 
         db 0b7h,0fdh,93h,26h,36h,3fh,0f7h,0cch,34h,0a5h,0e5h,0f1h,71h,0d8h,31h,15h
       db 04h,0c7h,23h,0c3h,18h,96h,05h,9ah,07h,12h,80h,0e2h,0ebh,27h,0b2h,75h 
       db 09h,83h,2ch,1ah,1bh,6eh,5ah,0a0h,52h,3bh,0d6h,0b3h,29h,0e3h,2fh,84h 
       db 53h,0d1h,00h,0edh,20h,0fch,0b1h,5bh,6ah,0cbh,0beh,39h,4ah,4ch,58h,0cfh 
       db 0d0h,0efh,0aah,0fbh,43h,4dh,33h,85h,45h,0f9h,02h,7fh,50h,3ch,9fh,0a8h 
       db 51h,0a3h,40h,8fh,92h,9dh,38h,0f5h,0bch,0b6h,0dah,21h,10h,0ffh,0f3h,0d2h 
       db 0cdh,0ch,13h,0ech,5fh,97h,44h,17h,0c4h,0a7h,7eh,3dh,64h,5dh,19h,73h 
       db 60h,81h,4fh,0dch,22h,2ah,90h,88h,46h,0eeh,0b8h,14h,0deh,5eh,0bh,0dbh 
       db 0e0h,32h,3ah,0ah,49h,06h,24h,5ch,0c2h,0d3h,0ach,62h,91h,95h,0e4h,79h 
        db 0e7h,0c8h,37h,6dh,8dh,0d5h,4eh,0a9h,6ch,56h,0f4h,0eah,65h,7ah,0aeh,08h 
       db 0bah,78h,25h,2eh,1ch,0a6h,0b4h,0c6h,0e8h,0ddh,74h,1fh,4bh,0bdh,8bh,8ah 
       db 70h,3eh,0b5h,66h,48h,03h,0f6h,0eh,61h,35h,57h,0b9h,86h,0c1h,1dh,9eh 
       db 0e1h,0f8h,98h,11h,69h,0d9h,8eh,94h,9bh,1eh,87h,0e9h,0ceh,55h,28h,0dfh 
       db 8ch,0a1h,89h,0dh,0bfh,0e6h,42h,68h,41h,99h,2dh,0fh,0b0h,54h,0bbh,16h
       x db 01h,02h,03h,04h,05h,06h,07h,8h,9h,10h,011h,012h,013h,014h,015h,016h   
       rcon db 01h,00h,00h,00h,02h,00h,00h,00h,04h,00h,00h,00h,08h,00h,00h,00h,010h,00h,00h,00h,
            db 020h,00h,00h,00h,040h,00h,00h,00h,080h,00h,00h,00h,01bh,00h,00h,00h,036h,00h,00h,00h
       word1 db 01h,02h,03h,04h ;rcon column
       word2 db 01h,02h,03h,04h ;
       word3 db 01h,02h,03h,04h 
       w0 db 01h,02h,03h,04h 
       rconindex dw 0000h 
       enter db 0ah,0dh,"enter the message : $"
       enterround db 0ah,0dh,"enter the round key : $" 
       op db 0ah,0dh,"the message after encryption : $"
       ;roundkey db 0a0h,088h,023h,02ah,0fah,054h,0a3h,06ch,0feh,02ch,039h,076h,017h,0b1h,039h,005h 
    .code segment 
    
    
    
        
    lea dx,enter    
    mov ah,09h
    int 21h 
    MOV CL,16
    MOV SI,0H
    IL:  
    MOV AH,01H
    INT 21H
    MOV array[SI],AL 
    INC SI
    cmp si,16
    jnz IL 
    ;LOOP IL
    
    lea dx,enterround
    mov ah,09h
    int 21h
    MOV CL,16
    MOV SI,0H
    IL1:  
    MOV AH,01H
    INT 21H
    MOV roundkey[SI],AL 
    INC SI 
    cmp si,16
    jnz IL1
    ;LOOP IL1
        ;7aga leh 3la8a bel round kam 3alashan rcon
        mov bx,rconindex;0,4,8.......3ala 7sab el lafa 
        ;arrayxorkey
        l: 
        mov bx,rconindex
        ;array xor key
        arrayxorkey
        subByte 
        shiftraws1
        mov bx,rconindex 
        cmp bx,36
        jz l1
        mixcolumns
        l1:
        mov bx,rconindex
        generatew0 
        generatewi
        generateroundkey
        mov bx,rconindex
        add bx,4
        mov rconindex,bx 
  
         
        cmp bx,40
        jnz l
        arrayxorkey  
        lea dx,op
        mov ah,09h
        int 21h
        MOV CL,16
        MOV SI,0H
        OL:
        MOV AH,02H 
        MOV DL,array[SI]
        INT 21H   
        INC SI
        LOOP OL
        ret
        
        
