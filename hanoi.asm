section .data
    ; Mensagem para input do usuário da quantidade de discos
    input db 'Digite a quantidade de discos (1 a 99): ', 0
    
    ; Mensagens auxiliares para compor a mensagem de saída
    mov_disco db 'Mova o disco ', 0
    origem db ' da coluna ', 0
    destino db ' até a coluna ', 0
    
    ; Identificadores das colunas A B C
    coluna_disco db 'A', 0
    coluna_auxiliar db 'B', 0
    coluna_destino db 'C', 0
    
    ; Caractere de quebra de linha
    quebra_de_linha db 10

section .bss
    ; Buffer para armazenar a entrada do usuário (2 caracteres + terminador nulo)
    entrada resb 3
    ; Variável para armazenar a quantidade de discos
    quant_discos resb 1
    ; Buffer para armazenar a conversão de inteiros para string
    len_buffer resb 2

section .text
    global _start

_start:
    ; Exibe a mensagem para receber o input
    mov ecx, input
    mov eax, 4
    mov ebx, 1
    mov edx, 40
    int 0x80

    ; Lê o input do usuário
    mov ecx, entrada
    mov eax, 3
    mov ebx, 0
    mov edx, 2
    int 0x80

    ; Chama a funcao Str_to_Int para converter a entrada do usuário em int
    call Str_to_Int
    mov [quant_discos], edx 

    ; Chama a função principal com a lógica da torre de hanoi
    call torre_de_hanoi

    ; Finaliza o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Definindo a funcao torre de hanoi
torre_de_hanoi:
    ; CASO BASE: Verifica se a quantidade de discos é 0, se sim, termina a função
    cmp byte [quant_discos], 0
    je fim
    
    ; Inicia a recursão para resolver as Torres de Hanoi
    jmp recursion_hanoi

recursion_hanoi:
; PSEUDOCÓDIGO:
; hanoi(n, origem, destino, auxiliar) - transfere n discos da origem p destino usando aux se preciso
; se n=1: 
;    move o disco da origem para o destino
; senao inicia recurssao:
;   hanoi (n-1 origem, auxiliar, destino) - troca as torres de destino e auxiliar para deslocar
;   hanoi (n-1, auxiliar, destino, origem) - troca as torres de origem e auxiliar para deslocar

    ; Decrementa a quantidade de discos
    ; (n-1, origem, aux, destino)
    dec byte [quant_discos]

    ; Empurra os valores necessários para a função torre_de_hanoi na pilha
    push word [quant_discos]
    push word [coluna_disco]
    push word [coluna_auxiliar]
    push word [coluna_destino]
    ; (n-1, origem, aux, destino)
    
    ; Troca a coluna auxiliar com a coluna destino
    mov dx, [coluna_auxiliar]
    mov cx, [coluna_destino]
    mov [coluna_destino], dx
    mov [coluna_auxiliar], cx
    ; (n-1, aux, destino, origem)

    ; Chama recursivamente a função torre_de_hanoi
    call torre_de_hanoi
    
    ; Desempilha os valores da pilha
    pop word [coluna_destino]
    pop word [coluna_auxiliar]
    pop word [coluna_disco]
    pop word [quant_discos]
    
    ; Exibe a mensagem indicando o disco a ser movido
    mov ecx, mov_disco
    call print
    ; Incrementa a quantidade de discos
    inc byte [quant_discos]

    ; Converte a quantidade de discos para string e imprime
    movzx eax, byte [quant_discos]
    lea edi, [len_buffer + 2]
    call Int_to_Str
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi]
    lea edx, [len_buffer + 2]
    sub edx, ecx
    int 0x80

    ; Concatena as mensagens alterando o valor em ecx e indicando a origem e o destino do disco
    dec byte [quant_discos]
    mov ecx, origem
    call print
    mov ecx, coluna_disco
    call print
    mov ecx, destino
    call print
    mov ecx, coluna_destino
    call print
    mov ecx, quebra_de_linha
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    
    ; Troca a coluna auxiliar com a coluna disco
    ; (n-1, aux, destino, origem)
    mov dx, [coluna_auxiliar]
    mov cx, [coluna_disco]
    mov [coluna_disco], dx
    mov [coluna_auxiliar], cx
    ; Chama recursivamente a função torre_de_hanoi
    call torre_de_hanoi

fim:
    ret

print:
    ; Função para imprimir uma string
    jackaloop:
        mov al, ecx[0]
        cmp al, 0
        je morreu
        mov eax, 4
        mov ebx, 1
        mov edx, 1
        int 0x80
        inc ecx
        jmp jackaloop
    morreu:
        ret
            
Str_to_Int:
    ; Converte uma string em um número inteiro
    mov edx, entrada[0]
    sub edx, '0'
    mov eax, entrada[1]
    cmp eax, 0x0a
    je ultimo
    sub eax, '0'
    imul edx, 10
    add edx, eax
ultimo:
    ret
        
Int_to_Str:
    ; Converte um número inteiro em uma string
    dec edi
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz Int_to_Str
    ret
