.model small
.stack 100h
.data

select_op db 10,"Selecione sua operacao: + - / *:$"
num1 db 10,"Defina o primeiro numero da operacao:$"
num2 db 10,"Defina o segundo numero da operacao:$"
result db 10,"Resultado:$"
error db 10,"Algo deu errado, tente novamente:$"
error_num db 10,"Algo deu errado, tente novamente o numero:$"


.code

print_msg macro var1

    mov ah,09h
    lea dx,var1
    int 21h
    endm

valid_num macro 

    cmp al,30h  ;comparo o resultado com 0,se al ele é mandado pra error 
    jl erro_numero  ;da jmp erro_numero
    cmp al,39h  ;comparo o resultado com 9, se ele for maior é mandado pra error
    jg erro_numero
    endm


main proc
;============================== validacao de input  ========================
start_numero:
mov ah,01h  ;manda a funcao de inputs
int 21h

cmp al,"-"  ;compara o valor lido com -, se for, ele vai pular para o jmp isneg
je isneg
continue:   ;depois do jmp ele retorna para ca para pegar os inputs

valid_num ;valida o numero do input

and al,0fh  ;transformo em decimal 
mov cl,al   ;salva o numero lido em cl para que seja feita a multiplicacao depois

mov ah,01h   ;pegando segundo input
int 21h

cmp al,13 ;comparo se o input lido foi o ENTER, para que possa seguir o algoritmo e receber o input do numero
je unitario

valid_num   ;valida o numero do input 

and al,0fh  ;transforma em decimal o valor lido
xchg al,cl ;transforma o numero a ser multiplicado em al para que a funcao de multiplicacao realize-a corretamente
mov bh,10 ;salvando o valor a ser multiplicado em bh para que a funcao seja multiplicada corretamente
mul bh   ;multiplica o al em 10, o resultado é salvo em AX (descobrir onde em AX)

add cl,al ;adiciona o valor de cl em al, para que o numero seja decimal 

unitario:
mov al,cl ;retornam os valores para seus locais originais
cmp bl,"-"  ;comparo para ver se o sinal é negativo
jne resultado_positivo   ;ele da jump se for positivo pro ret
neg al  ;sendo negativo ele nega o numero em seu complemento de 2
resultado_positivo:
jmp fora_input1

isneg: ;caso ele seja um valor negativo ele vai ter seu valor negado
mov bl,al;manda o input do sinal para bl
mov ah,01h
int 21h
jmp continue1

erro_numero:
print_msg error_num
jmp start_numero1    ;reinicia 
fora_input1:
mov bh,al

;============================== validacao de input  ========================
start_numero1:
mov ah,01h  ;manda a funcao de inputs
int 21h

cmp al,"-"  ;compara o valor lido com -, se for, ele vai pular para o jmp isneg
je isneg1
continue1:   ;depois do jmp ele retorna para ca para pegar os inputs

valid_num ;valida o numero do input

and al,0fh  ;transformo em decimal 
mov cl,al   ;salva o numero lido em cl para que seja feita a multiplicacao depois

mov ah,01h   ;pegando segundo input
int 21h

cmp al,13 ;comparo se o input lido foi o ENTER, para que possa seguir o algoritmo e receber o input do numero
je unitario1

valid_num   ;valida o numero do input 

and al,0fh  ;transforma em decimal o valor lido
xchg al,cl ;transforma o numero a ser multiplicado em al para que a funcao de multiplicacao realize-a corretamente
mov bh,10 ;salvando o valor a ser multiplicado em bh para que a funcao seja multiplicada corretamente
mul bh   ;multiplica o al em 10, o resultado é salvo em AX (descobrir onde em AX)

add cl,al ;adiciona o valor de cl em al, para que o numero seja decimal 

unitario1:
mov al,cl ;retornam os valores para seus locais originais
cmp bl,"-"  ;comparo para ver se o sinal é negativo
jne resultado_positivo1   ;ele da jump se for positivo pro ret
neg al  ;sendo negativo ele nega o numero em seu complemento de 2
resultado_positivo1:
jmp fora_input2

isneg1: ;caso ele seja um valor negativo ele vai ter seu valor negado
mov bl,al;manda o input do sinal para bl
mov ah,01h
int 21h
jmp continue

erro_numero1:
print_msg error_num
jmp start_numero    ;reinicia 

fora_input2:
mov bl,al

    add bh,bl
    mov cl,bh ;o cl vai sempre ser o resultado das operacoes
    and cl,cl

    js negsoma  ;caso o resultado seja negativo ele vai pular para o negsoma:
    mov bl,"+" ;transformo bl no sinal para ser printado
    jmp out1

    negsoma:
    neg cl
    mov bl,"-"
    jmp out1
    
out1:
 xor ch,ch ;comecamos a divisao do resultado para que possamos imprimir 2 valores
    mov ax,cx ;cl se torna cx
    mov ch,10
    div ch ;al = quociente ah = resto

    mov cl,al   ;cl se torna cosciente
    mov ch,ah   ;ch se torna resto

    print_msg result

    mov ah,02h ;printo o sinal do numero
    mov dl,bl ;printo o sinal do numero
    int 21h

    mov ah,02h ;printa o modulo do cosciente do numero
    or cl,30h ;transforma o numeral em char
    mov dl,cl ;printa o resultado
    int 21h

    mov ah,02h ;printa o modulo do resto do numero
    or ch,30h ;transforma o numeral em char
    mov dl,ch ;printa o resultado
    int 21h



mov ah,4ch
int 21h

main endp
end main