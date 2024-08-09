;Dacz Krisztian,dkim2226,521/2
;L4_3
;Készítsük el a következő stringkezelő eljárásokat és helyezzük el őket egy STRINGS.ASM / INC nevű modulba.

;    StrLen(ESI):(EAX)              – EAX-ben visszatéríiti az ESI által jelölt string hosszát, kivéve a bináris 0-t
;    StrCat(EDI, ESI):()             – összefűzi az ESI és EDI által jelölt stringeket (azaz az ESI által jelöltet az EDI után másolja)
;    StrUpper(ESI):()                 – nagybetűssé konvertálja az ESI stringet
;    StrLower(ESI):()                 – kisbetűssé konvertálja az ESI stringet
;    StrCompact(ESI, EDI):()      – EDI-be másolja át az ESI stringet, kivéve a szóköz, tabulátor (9), kocsivissza (13) és soremelés (10) karaktereket

%include 'mio.inc'
%include 'iostr.inc'
%include 'ionum.inc'

global StrLen,StrCat,StrUpper,StrLower,StrCompact

section .text

StrLen:

    xor eax,eax
    .bejar:
        mov bl,[esi+eax]
        cmp bl,byte 0
        je .vege
            inc eax
            jmp .bejar
    
    .vege:

    ret

StrCat:
    push esi
    push edi

    .edi_vegeig:
        mov al,[edi]
        cmp al,byte 0
        je .hozzafuz
            inc edi
            jmp .edi_vegeig

    .hozzafuz:
        mov al,[esi]
        cmp al,byte 0
        je .vege
            mov [edi],al
            inc edi
            inc esi
            jmp .hozzafuz

    .vege:
    mov [edi],byte 0            ; lezarom

    pop edi
    pop esi

    ret

StrUpper:

    xor ecx,ecx
    .bejar:
        mov al,[esi+ecx]
        cmp al,byte 0
        je .vege
            cmp  al,97
            jl   .notlowerc                     ;<a
                cmp  al,122
                jle  .lowercase                 ;<=z
                    jmp .notlowerc

    .lowercase:
        sub al,32           ;nagybetuve alakitas
        mov [esi+ecx],al
        inc ecx
        jmp .bejar


    .notlowerc:
        inc ecx
        jmp .bejar

    .vege:

    ret

StrLower:
    xor ecx,ecx
    .bejar:
        mov al,[esi+ecx]
        cmp al,byte 0
        je .vege
            cmp  al,65                        
            jl   .notupperc                                 ;<A                
                cmp  al,90              
                jle  .uppercase                             ;<=F
                    jmp .notupperc

    .uppercase:
        add al,32               ;kisbetuve alakitas
        mov [esi+ecx],al
        inc ecx
        jmp .bejar


    .notupperc:
        inc ecx
        jmp .bejar

    .vege:

    ret

StrCompact:
    
    xor ecx,ecx
    xor edx,edx
    .esi_to_edi:
        mov al,[esi+ecx]
        cmp al,byte 0
        je .kesz
            cmp al,32                   ;szokoz
            je .nemkerulbe
                cmp al,9                ;tab
                je .nemkerulbe
                    cmp al,13           ;kocsivissza
                    je .nemkerulbe
                        cmp al,10           ;soremeles
                        je .nemkerulbe
                            mov [edi+edx],al
                            inc ecx
                            inc edx
                            jmp .esi_to_edi


    .nemkerulbe:
        inc ecx
        jmp .esi_to_edi

    .kesz:
    mov [edi+edx],byte 0                ; lezarom
    
    ret


section .bss
    szoveg resb 255
    szoveg2 resb 255




