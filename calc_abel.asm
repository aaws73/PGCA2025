; PGCA 2025 - Arquitetura
; Abel Augusto Wakasugui de Souza / Rodrigo Bortoleto
; Calculadora em assembly
; Comando de iniciacao: nasm -felf64 calc.asm && gcc calc.o -o calc -no-pie && ./calc

global main
default rel
extern printf
extern scanf

section .data
    promptNum db "Digite um numero: ", 0
    promptOp  db "Digite um operador (+, -, *, /, q = encerrar processo): ", 0
    msgRes    db "Resultado: %.15g", 10, 0
    msgErr    db "Erro: divisao por zero mantem o valor anterior.", 10, 0
    msgInvOp  db "Erro: operacao invalida. Preencha com numeros validos e use os operadores +, -, *, / ou q.", 10, 0
    fmtNum    db "%lf", 0
    fmtOp     db " %c", 0

section .bss
    n1  resq 1
    n2  resq 1
    op  resb 1

section .text

main:
get_n1:
    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, promptNum
    call printf
    add rsp, 8

    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, fmtNum
    mov rsi, n1
    call scanf
    add rsp, 8
    cmp rax, 1      ; scanf retorna o número de itens lidos com sucesso
    je loopCalc    ; Se leu um número, vá para o loop de cálculo

    ; Se scanf não leu um número válido
    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8

    ; Limpar o buffer de entrada (ler o caractere inválido)
    sub rsp, 8
    mov rdi, fmtOp
    mov rsi, op
    call scanf
    add rsp, 8

    jmp get_n1

loopCalc:
    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, promptOp
    call printf
    add rsp, 8

    ; Alinhar a pilha para chamada de função (16 bytes)
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

    ; Se o operador não for válido
    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8
    jmp loopCalc

validOp:
get_n2:
    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, promptNum
    call printf
    add rsp, 8

    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, fmtNum
    mov rsi, n2
    call scanf
    add rsp, 8
    cmp rax, 1      ; scanf retorna o número de itens lidos com sucesso
    je validInput  ; Se leu um número, vá para a entrada válida

    ; Se scanf não leu um número válido
    sub rsp, 8
    mov rdi, msgInvOp
    call printf
    add rsp, 8

    ; Limpar o buffer de entrada (ler o caractere inválido)
    sub rsp, 8
    mov rdi, fmtOp
    mov rsi, op
    call scanf
    add rsp, 8

    jmp get_n2

validInput: ; Carregar n1 e n2 em registradores XMM (128 bits para double)
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
    ; Tratar erro de divisão por zero
    movsd xmm2, [n2]
    pxor xmm3, xmm3 ; Zero out xmm3
    ucomisd xmm2, xmm3 ; Comparar xmm2 com zero (unordered compare)
    jne fazdiv      ; Se não for zero, realizar a divisão

    sub rsp, 8
    mov rdi, msgErr
    call printf
    add rsp, 8
    jmp resultadoconta

fazdiv:
    divsd xmm0, xmm1

resultadoconta:
    movsd [n1], xmm0 ; Salvar o resultado de volta em n1 para a próxima operação

    ; Alinhar a pilha para chamada de função (16 bytes)
    sub rsp, 8
    mov rdi, msgRes
    mov rsi, [n1]
    movq xmm0, [n1] ; Carregar o double para o registro correto para printf
    call printf
    add rsp, 8

    jmp loopCalc

fim: ; Encerrar o programa
    xor rax, rax    ; Definir o código de saída para 0
    ret

section .note.GNU-stack
    db 0
