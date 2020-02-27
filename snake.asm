.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy

; 0 - gora
; 1 - lewo
; 2 - prawo
; 3 - dol


snake PROC

    push ax
    push bx
    push dx
    push es
    

    mov ax, 0B800H 
    mov es, ax

    cmp     cs:start,0
    je      pomin
    ; 1960 = 12 * 160
    mov     byte ptr es:[2000], '='
    mov     byte ptr es:[2001],  0Dh
    mov     byte ptr es:[1998],  '='
    mov     byte ptr es:[1999],  0Dh
    mov     byte ptr es:[1996],  '='
    mov     byte ptr es:[1997],  0Dh  
    mov     cs:start, 0

pomin:

    mov     ax,  cs:head_x
    mov     dx,  cs:head_y
    cmp     ax,  cs:tail_x 
    jne     okay
    cmp     dx,  cs:tail_y 
    jne     okay
    mov     byte ptr cs:blad, 1
okay:

    mov     dl,cs:wektor_ruchu
    shl     dl,2
    add     dl,cs:kierunek    

    mov     cs:wektor_ruchu,dl

    cmp     cs:kierunek,0
    jne     nie_zero
    dec     cs:head_y
    jmp     dalej
nie_zero:
    cmp     cs:kierunek,1
    jne     nie_jeden
    dec     cs:head_x
    jmp     dalej
nie_jeden:
    cmp     cs:kierunek,2
    jne     nie_dwa
    inc     cs:head_x
    jmp     dalej
nie_dwa:
    inc     cs:head_y

dalej:


    mov     ax, cs:head_y
    mov     dx, 160
    mul     dx
    mov     dx, cs:head_x
    shl     dx, 1
    add     ax, dx
    mov     bx, ax

    mov     byte ptr es:[bx], '='
    mov     byte ptr es:[bx + 1],  0Dh


    mov     ax, cs:tail_y
    mov     dx, 160
    mul     dx
    mov     dx, cs:tail_x
    shl     dx, 1
    add     ax, dx
    mov     bx, ax

    cmp     cs:blad,1
    je      pomin_blad
    mov     byte ptr es:[bx], ' '
    mov     byte ptr es:[bx + 1],  07h
    
pomin_blad:
    mov     byte ptr cs:blad,0

    mov     dl,cs:wektor_ruchu
    shr     dl,4
    and     dl,00000011b

    cmp     dl,0
    jne     nie_zero1
    dec     cs:tail_y
    jmp     dalej1
nie_zero1:
    cmp     dl,1
    jne     nie_jeden1
    dec     cs:tail_x
    jmp     dalej1
nie_jeden1:
    cmp     dl,2
    jne     nie_dwa1
    inc     cs:tail_x
    jmp     dalej1
nie_dwa1:
    inc     cs:tail_y

dalej1:


    pop es
    pop dx
    pop bx
    pop ax 
    jmp dword PTR cs:wektor8

    blad     db 0
    start    db 1
    kierunek db 2
    wektor8 dd  ?

    head_x  dw 40
    head_y  dw 12

    tail_x  dw 38
    tail_y  dw 12
   
    wektor_ruchu db 10101010b

snake ENDP

    
zacznij:
    mov     al,0
    mov     ah,5
    int     10H

    mov     bx, 0
    mov     es,bx
    mov     eax, es:[32] 
    mov     cs:wektor8, eax 


    mov     ax, SEG snake
    mov     bx, OFFSET snake

    cli
    
    mov     es:[32], bx
    mov     es:[34], ax

    sti
    
czekaj:

    mov     ah,1
    int     16h 
    jz      czekaj

    in      al, 60H

    cmp     al, 45
    je      koniec

    cmp     al,72
    je      wyznacz_kierunek
    cmp     al,75
    je      wyznacz_kierunek
    cmp     al,77
    je      wyznacz_kierunekplus
    cmp     al,80
    je      wyznacz_kierunekplus
    jmp     czekaj

wyznacz_kierunekplus:
    inc     al
wyznacz_kierunek:
    mov     ah,0
    sub     al,72
    mov     cl,3

    div     cl
    mov     cs:kierunek, al
    jmp     czekaj

koniec:

    mov     ah,0
    mov     al,3h
    int     10h

    mov     eax, cs:wektor8
    mov     es:[32], eax


    mov     ax,4c00h
    int     21h

    rozkazy ENDS

    stosik SEGMENT stack
        db 256 dup(?)
    stosik ENDS

    END zacznij
