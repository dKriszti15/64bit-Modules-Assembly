;Dacz Krisztian,dkim2226,521/2
;L4_1

;Készítsünk el egy olyan saját IONUM.ASM / INC modult, amely a következő eljárásokat tartalmazza, a megadott pontos paraméterezéssel
; (az első zárójelben a bemeneti, a másodikban a kimeneti paramétereket adtuk meg, az eljárások globálisak!). Hexa olvasásnál kis- és nagybetűket 
;is el kell fogadjon. Hexa és bináris olvasásnál nem kötelező az összes számjegyet beírni (azaz nem lehet a számjegyek száma az egyetlen leállási feltétel).
;Az olvasás kell kezelje a túlcsordulást és a backspace-t (hasonlóan a második feladathoz, érdemes egyszer annak az első részét megoldani).
;Minden függvény kötelezően <Enter>-ig olvas. Csak az <Enter> lenyomása után tekintünk egy beírt adatot hibásnak. A függvény a hibát a CF beállításával
;jelzi a főprogramnak. Hiba esetén a főprogram írja ki, hogy Hiba és utána kérje újra az adatot.

;A hexa és bináris eljárásoknál a szám felépítését/számjegyekre bontását bitműveletekkel kell megoldani (tehát szorzás/osztás használata nélkül
;kell megoldani). 

;    ReadInt():(EAX)                  – 32 bites előjeles egész beolvasása
;    WriteInt(EAX):()                  – 32 bites előjeles egész kiírása
;    ReadInt64():(EDX:EAX)      – 64 bites előjeles egész beolvasása
;    WriteInt64(EDX:EAX):()      – 64 bites előjeles egész kiírása
;    ReadBin():(EAX)                 – 32 bites bináris pozitív egész beolvasása
;    WriteBin(EAX):()                 –                    - || -                   kiírása
;    ReadBin64():(EDX:EAX)     – 64 bites bináris pozitív egész beolvasása
;    WriteBin64(EDX:EAX):()     –                    - || -                   kiírása
;    ReadHex():(EAX)                – 32 bites pozitív hexa beolvasása
;    WriteHex(EAX):()                –                    - || -                   kiírása
;    ReadHex64():(EDX:EAX)     – 64 bites pozitív hexa beolvasása
;    WriteHex64(EDX:EAX):()     –                    - || -                   kiírása

%include 'mio.inc'
%include 'iostr.inc'
%include 'strings.inc'

global ReadInt,WriteInt,ReadBin,WriteBin,ReadHex,WriteHex,ReadInt64,WriteInt64,ReadBin64,WriteBin64,ReadHex64,WriteHex64

section .text

ReadInt:
    push ebx
    push ecx
    push edi

    xor ebx,ebx   ;ebx-be epitem fel a szamot , majd eax-ben teritem vissza
    xor ecx,ecx
    xor edi,edi
        .read:
            xor eax,eax
            call mio_readchar                                   ; al-be olvas
            cmp al,13                                           ;ENTER
            je  .end
                cmp al,8                                        ;BACKSPACE - torles
                je .bspace
                    cmp al,45                                       ; - 
                    je .negative
                        call mio_writechar
                            
                        push eax
                        inc edi

                        jmp .read

            .bspace:
                cmp edi, 0          ; hogyha van mit torolni
                je .read            ; ha nincs , akkor nem torlok
                    call mio_writechar
                    mov al, 32
                    call mio_writechar
                    mov al, 8
                    call mio_writechar

                    pop eax           ;torles
                    dec edi
                    jmp .read


            .negative:
                call mio_writechar          ; kiir -
                mov ecx,1                   ;ez mondja meg a vegen majd, hogy kell-e negalni a szamot vagy sem
                jmp .read

            .end:

                mov esi,10
                pop eax                     ;az utolsot kiveszem a loop elott, hogy tudjam utana az esi-t mindig szorozni 10el
                dec edi

                cmp al,'0'
                    jl .error
                        cmp al,'9'
                        jg .error
                
                sub al,48
                
                mov ebx,eax

                .startpop:                  ;kiveszem a tobbi szamjegyet a verembol, felepitem a beolvasott szamot belowluk
                    cmp edi,0
                    je .szamfelepitve

                        dec edi
                        pop eax

                        cmp al,'0'
                        jl .error
                            cmp al,'9'
                            jg .error
                                sub al,48                           ; szamma alakit

                                imul eax,esi

                                jo .error

                                add eax,ebx
                                
                                xchg eax,ebx

                                imul esi,10

                                jmp .startpop

                .szamfelepitve:

                cmp ecx,0
                je .end2
                    neg ebx
                .end2:
                    call mio_writeln
                    mov eax,ebx
                    pop ebx
                    pop ecx
                    pop edi
                ret

        .error: 
            call NewLine
            mov al,'H'
            call mio_writechar
            mov al,'i'
            call mio_writechar
            mov al,'b'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'s'
            call mio_writechar
            mov al,':'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,' '
            call mio_writechar
            mov al,'u'
            call mio_writechar
            mov al,'j'
            call mio_writechar
            mov al,'r'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,':'
            call mio_writechar       
            
            .urit_stack:
                cmp edi,0
                je .cleared
                    pop eax
                    dec edi
                    jmp .urit_stack

            .cleared:
            
            pop ebx
            pop ecx
            pop edi

            STC
            ret


WriteInt:
        pusha

        .check_if_neg:
            cmp eax,0
            jl .printminus
            
        .digit_init:
            xor ecx,ecx


        .decomp:
            
            mov ebx,10
            cdq
            idiv ebx
            push edx        ;lementem a szamjegyeket a verembe
            inc ecx         ;szamolom a szamjegyeket
            
            cmp eax,0
            je .print
                jmp .decomp

        .print:
            cmp ecx,0
            je .end
                pop eax         ;veszem ki a kov szamjegyet
                add al,48
                call mio_writechar
                dec ecx
                jmp .print

        .end:
            popa
            ret

        .printminus:        
            mov ebx,eax
            mov al,45
            call mio_writechar
            neg ebx
            mov eax,ebx
            jmp .digit_init


ReadHex:
    push ebx
    push ecx
    push edi
    xor ebx,ebx
    xor edi,edi
    .read:
        xor  eax,eax   
        call mio_readchar                                       ;al-be
        cmp  al, 13                                             ;ENTER
        je   .end
            cmp al,8                                        ;BACKSPACE - torles
            je .bspace
                call mio_writechar
                push eax
                inc edi
                jmp .read

        .bspace:
            cmp edi, 0          ; hogyha van mit torolni
            je .read            ; ha nincs , akkor nem torlok
                call mio_writechar
                mov al, 32
                call mio_writechar
                mov al, 8
                call mio_writechar

                pop eax           ;torles
                dec edi
                jmp .read

        .error: 
            call NewLine
            mov al,'H'
            call mio_writechar
            mov al,'i'
            call mio_writechar
            mov al,'b'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'s'
            call mio_writechar
            mov al,':'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,' '
            call mio_writechar
            mov al,'u'
            call mio_writechar
            mov al,'j'
            call mio_writechar
            mov al,'r'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,':'
            call mio_writechar       
            
            .urit_stack:
                cmp edi,0
                je .cleared
                    pop eax
                    dec edi
                    jmp .urit_stack

            .cleared:
            pop ebx
            pop ecx
            pop edi

            STC
            ret

        .casual_digit:
            call   mio_writechar
            sub  al, 48          ;atalakitas
            jmp  .atalakitva
        
        .uppercase:
            call  mio_writechar
            sub   al, 55    
            jmp  .atalakitva   
        
        .lowercase:
            call  mio_writechar
            sub   al, 87    
            jmp  .atalakitva
        

        .casual_digit2:
            sub  al, 48          ;atalakitas
            jmp  .atalakitva2
        
        .uppercase2:
            sub   al, 55    
            jmp  .atalakitva2  
        
        .lowercase2:
            sub   al, 87    
            jmp  .atalakitva2

        .end:
            
            pop eax
            dec edi

            cmp  al,48             
                jl  .error                                          ;<0                 
                    cmp  al,57              
                    jle  .casual_digit                              ;<=9
                        cmp  al,65                        
                        jl   .error                                 ;<A                
                            cmp  al,70              
                            jle  .uppercase                         ;<=F
                                cmp  al,97
                                jl   .error                         ;<a
                                    cmp  al,102
                                    jle  .lowercase                 ;<=f
                                        cmp  al,102
                                        jg   .error                 ;>f
            
            .atalakitva:
            
            mov ebx,eax
            xor ecx,ecx             ;ennyivel kell mindig shifteljem a kovetkezo szamjegyet

            .startpop:                  ;kiveszem a tobbi szamjegyet a verembol, felepitem a beolvasott szamot belowluk
                cmp edi,0
                je .szamfelepitve
                    
                    dec edi
                    add ecx,4
                    pop eax

                    cmp  al,48             
                    jl  .error                                          ;<0                 
                        cmp  al,57              
                        jle  .casual_digit2                              ;<=9
                            cmp  al,65                        
                            jl   .error                                 ;<A                
                                cmp  al,70              
                                jle  .uppercase2                         ;<=F
                                    cmp  al,97
                                    jl   .error                         ;<a
                                        cmp  al,102
                                        jle  .lowercase2                 ;<=f
                                            cmp  al,102
                                            jg   .error                 ;>f

                                            .atalakitva2:

                                                shl eax,cl
                                                
                                                add eax,ebx
                                                
                                                xchg eax,ebx

                                                jmp .startpop

                .szamfelepitve:

                call mio_writeln
                mov eax,ebx
                
                pop ebx
                pop ecx
                pop edi
                ret



WriteHex:
    pusha

    mov ecx,8

    .decomp:
        cmp ecx,0
        je .lebontva
            mov ebx,eax
            and ebx,0xF                 ;maszk 0000 0000 0000 0000 0000 0000 0000 1111-el
            push ebx
            shr eax,4                   ;itt most 4el tolom jobbra, mert egy hexa szamjegy 4 bites
            dec ecx
            jmp .decomp

    .lebontva:

    mov ecx,8
    xor edx,edx

    mov al,'0'
    call mio_writechar
    mov al,'x'
    call mio_writechar

    .ki:
        cmp ecx,0
        je .vege
            pop eax
            cmp eax, 0
            jne .nemnulla
                add al, 48
                jmp .ujrakar

            .nemnulla:
                add al, 48  ;mindig hozza kell adni
                cmp al, 58
                jl .ujrakar
                    add al, 7   ;betuve alakitom ha az volt eredetileg

            .ujrakar:
                call mio_writechar
                dec ecx
                jmp .ki

    .vege:
    
    popa

    ret
ReadBin:
    push ebx
    push ecx
    push edi

    xor ebx,ebx   ;ebx-be epitem fel a szamot , majd eax-ben teritem vissza
    xor ecx,ecx
    xor edi,edi
        .read:
            xor eax,eax
            call mio_readchar                                   ; al-be olvas
            cmp al,13                                           ;ENTER
            je  .end
                cmp al,8                                        ;BACKSPACE - torles
                je .bspace
                    call mio_writechar
                            
                    push eax
                    inc edi

                    jmp .read

            .bspace:
                cmp edi, 0          ; hogyha van mit torolni
                je .read            ; ha nincs , akkor nem torlok
                    call mio_writechar
                    mov al, 32
                    call mio_writechar
                    mov al, 8
                    call mio_writechar

                    pop eax           ;torles
                    dec edi
                    jmp .read

            .end:

                pop eax                     ;az utolsot kiveszem a loop elott
                dec edi

                cmp al,'0'
                    jl .error
                        cmp al,'1'
                        jg .error
                
                sub al,48                   ; -> szam
                
            ;0000 0001
            ;0000 0010
            ;==== ==11

                mov ebx,eax
                xor ecx,ecx             ;ennyivel kell mindig shifteljem a kovetkezo bitet

                .startpop:                  ;kiveszem a tobbi szamjegyet a verembol, felepitem a beolvasott szamot belowluk
                    cmp edi,0
                    je .szamfelepitve

                        dec edi
                        inc ecx
                        pop eax

                        cmp al,'0'
                        jl .error
                            cmp al,'1'
                            jg .error
                                sub al,48                           ; szamma alakit

                                shl eax,cl

                                add eax,ebx
                                
                                xchg eax,ebx

                                jmp .startpop

                .szamfelepitve:

                call mio_writeln
                mov eax,ebx
                pop ebx
                pop ecx
                pop edi
                ret

        .error: 
            call NewLine
            mov al,'H'
            call mio_writechar
            mov al,'i'
            call mio_writechar
            mov al,'b'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'s'
            call mio_writechar
            mov al,':'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,' '
            call mio_writechar
            mov al,'u'
            call mio_writechar
            mov al,'j'
            call mio_writechar
            mov al,'r'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,':'
            call mio_writechar      
            
            .urit_stack:
                cmp edi,0
                je .cleared
                    pop eax
                    dec edi
                    jmp .urit_stack

            .cleared:
            
            pop ebx
            pop ecx
            pop edi

            STC
            ret        

WriteBin:

    pusha

    mov ecx,32

    .decomp:
        cmp ecx,0
        je .lebontva
            mov ebx,eax
            and ebx,0x1                 ;maszk 0000 0000 0000 0000 0000 0000 0000 0001-el
            push ebx
            shr eax,1
            dec ecx
            jmp .decomp

    .lebontva:

    mov ecx,32
    xor edx,edx

    .ki:
        cmp ecx,0
        je .vege
            pop eax
            add al,48
            call mio_writechar
            dec ecx
            inc edx

            cmp edx,4
            jne .ki
                mov al,32
                call mio_writechar
                xor edx,edx
                jmp .ki


    .vege:

    popa

    ret

;----64----
ReadInt64:  
    ;a verembe fogom beolvasmi a szamot
    push esi
    push edi
    push ecx
    
    mov ebp,esp

    sub esp,255         ; megnovelem a stack meretet a maximalis beolvashato karakterek szamaval
    
    mov ecx,255         ; maxhossz

    mov esi,esp         ; esi-t a veremmutatora allitom

    call ReadStr        ; a beolvasott szamot , beteszi a verembe , mint karaktererk

    call StrLen         ; eax - hossz
   
    mov ecx, eax        ; ecx = eax - hosdsz

    cmp ecx,0        
    je .szam_felepitve  ; ha van mit feldolgozni
        
        xor eax,eax     ; ebben fogom epiteni a szamot
        xor edx,edx
        mov edi,0       ; 0 marad ha nem negativ szamot olvastam be
        
        .kivesz_szamjegyek:
            cmp ecx,0
            je .szam_felepitve
                
                dec ecx

                push eax
                xor eax,eax
                lodsb               ; betoltom a kov karaktert
                mov ebx,eax
                pop eax

                cmp bl,'-'      ; csak a legelso karakter lehet - 
                je .minusz      ; ha - akkor az edibe 1 kerul
                
                
                .start:                

                    cmp bl,'0'
                    jl .error
                        cmp bl,'9'
                        jg .error
                            sub bl,48       ; szamjeggye alakitas
                            
                            push ecx        ;ecxet lementem , hogy felhasznaljam a szorzashoz.majd kiveszem
                            mov ecx,10
                            imul edx,ecx    ; edx nem csordulhat tul
                            pop ecx

                            jo .error
                            
                            push edi  

                            mov edi,edx
                            
                            push ecx        
                            mov ecx,10
                            mul ecx         ; eax tulcsordulhat , edxbe
                            pop ecx

                            add edx,edi

                            pop edi
                            jo .error

                            add eax,ebx
                            
                            adc edx,0

                            jo .error

                            jmp .kivesz_szamjegyek
                            


    .szam_felepitve:
        cmp edi,1
        jne .done               ; ha edi=1 vagyis negativ szamo olvastam be, akkor not-olok
            CLC
            not eax
            not edx
            add eax,1
            adc edx,0

    .done:
    
        mov esp,ebp
        
        pop ecx
        pop edi
        pop esi

        CLC
        ret
    
    .minusz:
        mov edi,1
        jmp .kivesz_szamjegyek
    
    .error: 
        call NewLine
        mov al,'H'
        call mio_writechar
        mov al,'i'
        call mio_writechar
        mov al,'b'
        call mio_writechar
        mov al,'a'
        call mio_writechar
        mov al,'s'
        call mio_writechar
        mov al,':'
        call mio_writechar
        mov al,'a'
        call mio_writechar
        mov al,'d'
        call mio_writechar
        mov al,'d'
        call mio_writechar
        mov al,' '
        call mio_writechar
        mov al,'u'
        call mio_writechar
        mov al,'j'
        call mio_writechar
        mov al,'r'
        call mio_writechar
        mov al,'a'
        call mio_writechar
        mov al,':'
        call mio_writechar       
        
        mov esp,ebp

        pop eax
        pop ecx
        pop edi
        pop esi

        STC         ; CF be

        ret

WriteInt64:
    
    pusha           ; semmi ne valtozzon

    xor edi,edi
    mov ecx,10      ; szamjegyek levalasztasahoz
    cmp edx,0
    jge .lebont     ; hogyha < 0 , not-olok
    
        jmp .negativ_not
    

    .lebont:
        cmp 	eax, 0
        je 		.eax_done
            
            inc edi

            mov	ebx, eax
            mov eax, edx
            xor edx,edx			; ide fog kerulni a maradek
            div	ecx				; osztom eax=edx-et
            mov esi, eax        ; esi = eax az utolso szjegy levalasztasa utan
            mov	eax, ebx
            div ecx				; osztom eax=eax-et
            push edx			; szamjegy mentese     
            mov edx, esi        ; leptet

            jmp 	.lebont
        
                                                                    
    .eax_done:
        cmp 	edi, 0
        je		.end
            cmp 	edx, 0
            jne		.lebont 
                pop		eax
                call	WriteInt		;szamjegy kiiratasa
                dec		edi
                jmp 	.eax_done

    .end:

        popa

        ret			

    .negativ_not:
        push eax            
        mov al,'-'              ;kiirom a minuszt
        call mio_writechar
        pop eax
        
        sub eax,1           ;felepiteskor add-oltam , most sub-olok 1et
        not eax
        not edx
        jmp .lebont

ReadHex64:
    
    push ebx
    push ecx
    push edi
    xor ebx, ebx
    xor edx, edx
    xor esi, esi
    xor ecx, ecx
    xor edi, edi
    .read:
        xor  eax,eax   
        call mio_readchar                                       ;al-be
        cmp  al, 13                                             ;ENTER
        je   .end
            cmp al,8                                        ;BACKSPACE - torles
            je .bspace
                call mio_writechar
                push eax
                inc edi
                jmp .read

        .bspace:
            cmp edi, 0          ; hogyha van mit torolni
            je .read            ; ha nincs , akkor nem torlok
                call mio_writechar
                mov al, 32
                call mio_writechar
                mov al, 8
                call mio_writechar

                pop eax           ;torles
                dec edi
                jmp .read

        .error: 
            call NewLine
            mov al,'H'
            call mio_writechar
            mov al,'i'
            call mio_writechar
            mov al,'b'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'s'
            call mio_writechar
            mov al,':'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,' '
            call mio_writechar
            mov al,'u'
            call mio_writechar
            mov al,'j'
            call mio_writechar
            mov al,'r'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,':'
            call mio_writechar       
            
            .urit_stack:
                cmp edi,0
                je .cleared
                    pop eax
                    dec edi
                    jmp .urit_stack

            .cleared:
            pop ebx
            pop ecx
            pop edi

            STC
            ret

        .casual_digit:
            call   mio_writechar
            sub  al, 48          ;atalakitas
            jmp  .atalakitva
        
        .uppercase:
            call  mio_writechar
            sub   al, 55    
            jmp  .atalakitva   
        
        .lowercase:
            call  mio_writechar
            sub   al, 87    
            jmp  .atalakitva
        

        .casual_digit2:
            sub  al, 48          ;atalakitas
            jmp  .atalakitva2
        
        .uppercase2:
            sub   al, 55    
            jmp  .atalakitva2  
        
        .lowercase2:
            sub   al, 87    
            jmp  .atalakitva2

        .end:
            
            pop eax
            dec edi

            cmp  al,48             
                jl  .error                                          ;<0                 
                    cmp  al,57              
                    jle  .casual_digit                              ;<=9
                        cmp  al,65                        
                        jl   .error                                 ;<A                
                            cmp  al,70              
                            jle  .uppercase                         ;<=F
                                cmp  al,97
                                jl   .error                         ;<a
                                    cmp  al,102
                                    jle  .lowercase                 ;<=f
                                        cmp  al,102
                                        jg   .error                 ;>f
            
            .atalakitva:
            
            mov ebx,eax
            xor ecx,ecx             ;ennyivel kell mindig shifteljem a kovetkezo szamjegyet

            .startpop:                  ;kiveszem a tobbi szamjegyet a verembol, felepitem a beolvasott szamot belowluk
                cmp edi,0
                je .szamfelepitve
                    
                    dec edi
                    add ecx,4
                    pop eax

                    cmp  al,48             
                    jl  .error                                          ;<0                 
                        cmp  al,57              
                        jle  .casual_digit2                              ;<=9
                            cmp  al,65                        
                            jl   .error                                 ;<A                
                                cmp  al,70              
                                jle  .uppercase2                         ;<=F
                                    cmp  al,97
                                    jl   .error                         ;<a
                                        cmp  al,102
                                        jle  .lowercase2                 ;<=f
                                            cmp  al,102
                                            jg   .error                 ;>f

                                            .atalakitva2:

                                                cmp cl,32
                                                jge .edx_bekerul
                                                    shl eax,cl
                                                    
                                                    add ebx,eax

                                                    jmp .startpop

                                                .edx_bekerul:
                                                    push ecx
                                                    sub ecx,32
                                                    shl eax,cl
                                                    pop ecx

                                                    add edx,eax

                                                    jmp .startpop
                .szamfelepitve:

                call mio_writeln
                mov eax,ebx
                
                pop ebx
                pop ecx
                pop edi
                ret
    

    ret


WriteHex64:
    pusha

    xchg eax,edx

    mov ecx,8

    .decomp:
        cmp ecx,0
        je .lebontva
            mov ebx,eax
            and ebx,0xF                 ;maszk 0000 0000 0000 0000 0000 0000 0000 1111-el
            push ebx
            shr eax,4                   ;itt most 4el tolom jobbra, mert egy hexa szamjegy 4 bites
            dec ecx
            jmp .decomp

    .lebontva:

    mov ecx,8

    mov al,'0'
    call mio_writechar
    mov al,'x'
    call mio_writechar

    .ki:
        cmp ecx,0
        je .vege
            pop eax
            cmp eax, 0
            jne .nemnulla
                add al, 48
                jmp .ujrakar

            .nemnulla:
                add al, 48  ;mindig hozza kell adni
                cmp al, 58
                jl .ujrakar
                    add al, 7   ;betuve alakitom ha az volt eredetileg

            .ujrakar:
                call mio_writechar
                dec ecx
                jmp .ki

    .vege:
    
    xchg eax,edx

    mov ecx,8

    .decomp2:
        cmp ecx,0
        je .lebontva2
            mov ebx,eax
            and ebx,0xF                 ;maszk 0000 0000 0000 0000 0000 0000 0000 1111-el
            push ebx
            shr eax,4                   ;itt most 4el tolom jobbra, mert egy hexa szamjegy 4 bites
            dec ecx
            jmp .decomp2

    .lebontva2:

    mov ecx,8
    xor edx,edx

    .ki2:
        cmp ecx,0
        je .vege2
            pop eax
            cmp eax, 0
            jne .nemnulla2
                add al, 48
                jmp .ujrakar2

            .nemnulla2:
                add al, 48  ;mindig hozza kell adni
                cmp al, 58
                jl .ujrakar2
                    add al, 7   ;betuve alakitom ha az volt eredetileg

            .ujrakar2:
                call mio_writechar
                dec ecx
                jmp .ki2

    .vege2:
    
    popa

    ret


ReadBin64:
    push ebx
    push ecx
    push edi
    xor eax,eax
    xor edx,edx
    xor ebx,ebx   ;ebx-be epitem fel a szamot , majd eax-ben teritem vissza
    xor ecx,ecx
    xor edi,edi
        .read:
            xor eax,eax
            call mio_readchar                                   ; al-be olvas
            cmp al,13                                           ;ENTER
            je  .end
                cmp al,8                                        ;BACKSPACE - torles
                je .bspace
                    call mio_writechar

                    push eax
                    inc edi

                    jmp .read

            .bspace:
                cmp edi, 0          ; hogyha van mit torolni
                je .read            ; ha nincs , akkor nem torlok
                    call mio_writechar
                    mov al, 32
                    call mio_writechar
                    mov al, 8
                    call mio_writechar

                    pop eax           ;torles
                    dec edi
                    jmp .read

            .end:

                pop eax                     ;az utolsot kiveszem a loop elott
                dec edi

                cmp al,'0'
                    jl .error
                        cmp al,'1'
                        jg .error
                
                sub al,48                   ; -> szam
                
            ;0000 0001
            ;0000 0010
            ;==== ==11

                mov ebx,eax
                xor ecx,ecx             ;ennyivel kell mindig shifteljem a kovetkezo bitet

                .startpop:                  ;kiveszem a tobbi szamjegyet a verembol, felepitem a beolvasott szamot belowluk
                    cmp edi,0
                    je .szamfelepitve

                        dec edi
                        inc ecx
                        pop eax

                        cmp al,'0'
                        jl .error
                            cmp al,'1'
                            jg .error
                                sub al,48                           ; szamma alakit

                                cmp cl,32
                                jge .edx_bekerul
                                    shl eax,cl
                                    
                                    add ebx,eax

                                    jmp .startpop

                                .edx_bekerul:
                                    push ecx
                                    sub ecx,32
                                    shl eax,cl
                                    pop ecx

                                    add edx,eax

                                    jmp .startpop

        .szamfelepitve:

            call mio_writeln
            mov eax,ebx
            pop ebx
            pop ecx
            pop edi
            ret

        .error: 
            call NewLine
            mov al,'H'
            call mio_writechar
            mov al,'i'
            call mio_writechar
            mov al,'b'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'s'
            call mio_writechar
            mov al,':'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,'d'
            call mio_writechar
            mov al,' '
            call mio_writechar
            mov al,'u'
            call mio_writechar
            mov al,'j'
            call mio_writechar
            mov al,'r'
            call mio_writechar
            mov al,'a'
            call mio_writechar
            mov al,':'
            call mio_writechar       
            
            .urit_stack:
                cmp edi,0
                je .cleared
                    pop eax
                    dec edi
                    jmp .urit_stack

            .cleared:
            
            pop ebx
            pop ecx
            pop edi

            STC
            ret      

WriteBin64:

    push eax
    push edx

    pop eax
    call WriteBin

    pop eax
    call WriteBin

    ret





