;Dacz Krisztian,dkim2226,521/2
;L4_2

;Készítsünk el egy olyan stringbeolvasó eljárást, amely megfelelőképpen kezeli le a backspace billentyűt
;(azaz visszalépteti a kurzort és letörli az előző karaktert). Teszteljük ezt az eljárást különböző kritikus esetekre 
;(pl. a string elején a backspace-nek ne legyen hatása, valamint ha már több karaktert vitt be a felhasználó, mint a megengedett hossz és
;lenyomja a backspace-t akkor nem az elmentett utolsó karaktert kell törölni, hanem az elmentetlenekből az utolsót). <Enter>-ig olvas.
;Ebben a feladatban C stringekkel dolgozunk, itt a string végét a bináris 0 karakter jelenti.

;Készítsünk el egy olyan IOSTR.ASM / INC modult, amely a következő eljárásokat tartalmazza:

;    ReadStr(EDI vagy ESI, ECX max. hossz):()   – C-s (bináris 0-ban végződő) stringbeolvasó eljárás, <Enter>-ig olvas
;    WriteStr(ESI):()                                – stringkiíró eljárás
;    ReadLnStr(EDI vagy ESI, ECX):()   – mint a ReadStr() csak újsorba is lép
;    WriteLnStr(ESI):()                            – mint a WriteStr() csak újsorba is lép
;    NewLine():()                                     – újsor elejére lépteti a kurzort

%include 'mio.inc'

global ReadStr,WriteStr,ReadLnStr,WriteLnStr,NewLine

section .text

ReadStr:

    pusha

    xor ebx,ebx       ; indexel - azert 0 , mert nem kerul a string elejere a hossz
    
    .readchar:
        cmp ebx,ecx
        je .end
            call mio_readchar
            cmp al,13   ;ENTER
            je .end
                cmp al,8    ;BACKSPACE - torles
                je .bspace
                    mov [esi+ebx],al
                    inc ebx
                    call mio_writechar                
                    jmp .readchar

    .end:
        mov [esi+ebx],byte 0

        popa

        ret

    .bspace:
        dec     ebx
        call    mio_writechar
        mov     al,32
        call    mio_writechar
        mov     al,8
        call    mio_writechar    
        mov     [esi+ebx],al
        jmp .readchar 


WriteStr:

    pusha

    xor ebx,ebx
    .print:
        mov al,[esi+ebx]
        cmp al,byte 0
        je .end
            call mio_writechar
            inc ebx
            jmp .print

    .end:
        popa
        ret


ReadLnStr:
    
    pusha

    call ReadStr
    mov al,10
    call mio_writechar

    popa
    ret


WriteLnStr:

    pusha
    
    call WriteStr
    mov al,10
    call mio_writechar

    popa
    ret


NewLine:


    pusha

    mov al,10
    call mio_writechar
    
    popa
    ret



