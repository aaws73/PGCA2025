; PGCA 2025 - Arquitetura
; Abel Augusto Wakasugui de Souza / Rodrigo Bortoleto
; Calculadora em assembly
; Comando de iniciacao: nasm -felf64 calc.asm && gcc calc.o -o a.out -no-pie && ./a.out

global main
default rel
extern printf
extern scanf

section .data
promptNum db "Digite um numero: ",0
promptOp db "Digite um operador (+, -, *, /, q = encerrar processo): ",0
msgRes   db "Resultado: %.15g",10,0 
msgErr   db "Erro: divisao por zero mantem o valor anterior.",10,0
msgInvOp db "Erro: operacao invalida. Preencha com numeros validos e use os operadores +, -, *, / ou q.",10,0
fmtNum   db "%lf",0
fmtOp    db " %c",0

section .bss
n1  resq 1
n2  resq 1
op  resb 1

section .text

main:
get_n1:
    sub rsp, 8 ; alinhar comando (16 b para o proximo)
    mov rdi, promptNum
    call printf
    add rsp, 8

    sub rsp, 8
    mov rdi, fmtNum
    mov rsi, n1
    call scanf
    add rsp, 8
    cmp rax, 1
    je loopCalc

    ; confere se n eh numero
    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8

    ; limpa
    sub rsp, 8
    mov rdi, fmtOp
    mov rsi, op
    call scanf
    add rsp, 8

    jmp get_n1

loopCalc:
    sub rsp, 8 ; alinhar comando (16 b para o proximo)
    mov rdi, promptOp
    call printf
    add rsp, 8

    sub rsp, 8
    mov rdi, fmtOp
    mov rsi, op
    call scanf
    add rsp, 8

    mov al, [op]
    cmp al, 'q'
    je fim

    cmp al, '+'
    je validOp
    cmp al, '-'
    je validOp
    cmp al, '*'
    je validOp
    cmp al, '/'
    je validOp

    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8
    jmp loopCalc

validOp:
get_n2:
    sub rsp, 8 ; alinhar comando (16 b para o proximo)
    mov rdi, promptNum
    call printf
    add rsp, 8

    sub rsp, 8
    mov rdi, fmtNum
    mov rsi, n2
    call scanf
    add rsp, 8
    cmp rax, 1
    je validInput

    ; confere se n eh numero
    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8

    ; limpa
    sub rsp, 8
    mov rdi, fmtOp
    mov rsi, op
    call scanf
    add rsp, 8

    jmp get_n2
 
validInput: ; sobe n1 e n2 em XMM 128 bits
    movsd xmm0, [n1]
    movsd xmm1, [n2]

    mov al, [op]
    cmp al, '+'
    je soma
    cmp al, '-'
    je subtracao
    cmp al, '*'
    je multiplicacao
    cmp al, '/'
    je divisao

soma:
    addsd xmm0, xmm1
    jmp resultadoconta

subtracao:
    subsd xmm0, xmm1
    jmp resultadoconta

multiplicacao:
    mulsd xmm0, xmm1
    jmp resultadoconta

divisao:
   ; trata erros de divisao
    movsd xmm2, [n2]
    pxor xmm3, xmm3
    ucomisd xmm2, xmm3
    jne fazdiv

    sub rsp, 8
    mov rdi, msgErr
    call printf
    add rsp, 8
    jmp resultadoconta

fazdiv:
    divsd xmm0, xmm1

resultadoconta:
    movsd [n1], xmm0

    sub rsp, 8
    mov rdi, msgRes
    mov rsi, [n1]
    movsd xmm0, [n1]
    call printf
    add rsp, 8

    jmp loopCalc

fim: ; encerra logica e zera operadores
    xor rax, rax
    ret

section .note.GNU-stack
db 0
