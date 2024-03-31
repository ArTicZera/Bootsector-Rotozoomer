[BITS    16]
[ORG 0x7C00]

%define WSCREEN 320
%define HSCREEN 200

BootMain:
        ;Setup Video Memory
        push    0xA000
        pop     es

        ;Setup Mode 13h
        mov     ax, 0x13
        int     0x10

        xor     bp, bp ;X Pos
        xor     dx, dx ;Y Pos
        xor     di, di ;Index

        fninit

        call    SetPalette

        jmp     Rotozoomer

;----------------------------------------------

Draw:
        cmp     bp, WSCREEN
        jae     NextLine

        cmp     dx, HSCREEN
        jae     ResetDraw

        stosb

        inc     bp

        jmp     Rotozoomer

NextLine:
        xor     bp, bp
        inc     dx

        jmp     Rotozoomer

ResetDraw:
        ;Reset X, Y and Index
        xor     bp, bp
        xor     dx, dx
        xor     di, di

        fld     dword [alpha]
        fadd    dword [angle]
        fstp    dword [angle]

        jmp     Rotozoomer

;----------------------------------------------

SetPalette:
        pusha

        ;Color index = 0
        xor     bx, bx

        palette.loop:
                ;Setup VGA Palette
                mov     dx, 0x3C8
                mov     al, bl
                out     dx, al

                ;Color's index port
                mov     dx, 0x3C9

                ;R = 1
                mov     al, bl
                out     dx, al

                ;G = 1
                mov     al, bl
                out     dx, al

                ;B = 1
                mov     al, bl
                out     dx, al

                ;Next index
                inc     bx

                ;Compare 256
                cmp     bx, 0xFF
                jb      palette.loop

        popa

        ret

;----------------------------------------------

Rotozoomer:
        mov     word [x], bp
        mov     word [y], dx

        ;r1 = sin(angle) * y
        fild    qword [angle]
        fsin
        fmul    dword [y]
        fstp    dword [r1]

        ;gx = cos(angle) * zx - r1
        fild    qword [angle]
        fcos
        fmul    dword [x]
        fsub    dword [r1]
        fstp    dword [gx]

        ;r2 = cos(angle) * y
        fild    qword [angle]
        fcos
        fmul    dword [y]
        fstp    dword [r2]

        fild    qword [angle]
        fsin
        fmul    dword [x]
        fadd    dword [r2]
        fstp    dword [gy]

        ;x ^ y
        mov     bx, [gx]
        xor     bx, [gy]

        ;(x ^ y) & 10000
        and     bx, 10000

        mov     al, bl
        add     al, 50

        jmp     Draw

;----------------------------------------------

x: dd 0.0
y: dd 0.0

gx: dw 0.0
gy: dw 0.0

r1: dd 0.0
r2: dd 0.0

angle: dq 100.00
alpha: dq 0.01

;----------------------------------------------

;Fill 510 bytes with 0 + Magic number
times 510 - ($ - $$) db 0x00
dw 0xAA55
