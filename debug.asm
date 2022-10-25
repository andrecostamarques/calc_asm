.model small
.data

    select_op db 10,"Selecione sua operacao: + - / *:$"
    error_sinal db 10,"A sinalização pode ser feita somente com (-) !!:"
    num1 db 10,"Defina o primeiro numero da operacao:$"
    num2 db 10,"Defina o segundo numero da operacao:$"
    result db 10,"Resultado:$"
    error db 10,"Algo deu errado, tente novamente:$"
    error_num db 10,"Algo deu errado, tente novamente o numero:$"

.stack 100h
.code

print_msg macro var1
    mov ah,09h
    lea dx,var1
    int 21h
    endm

main proc

MOV AX,@DATA           ;inicializa a data, setando ela para o registrador AX
MOV DS,AX              ;seta a data para o registrador DS

start_numero:
mov ah,01h  ;manda a funcao de inputs
int 21h

cmp al,"-"  ;compara o valor lido com -, se for, ele vai pular para o jmp isneg
je isneg
continue:   ;depois do jmp ele retorna para ca para pegar os inputs

cmp al,30h  ;comparo o resultado com 0,se al ele é mandado pra error 
jl erro_numero  ;da jmp erro_numero
cmp al,39h  ;comparo o resultado com 9, se ele for maior é mandado pra error
jg erro_numero

and al,0fh  ;transformo em decimal

cmp bl,"-"  ;comparo para ver se o sinal é negativo
jne resultado_positivo   ;ele da jump se for positivo pro ret
neg al  ;sendo negativo ele nega o numero em seu complemento de 2
resultado_positivo: 
jmp fora

isneg: ;caso ele seja um valor negativo ele vai ter seu valor negado
mov bl,al;manda o input do sinal para bl
mov ah,01h
int 21h
jmp continue

erro_numero:
print_msg error_num
jmp start_numero    ;reinicia 

fora:
mov bh,al
mov bl,3

add bh,bl
mov cl,bh ;o cl vai sempre ser o resultado das operacoes

js negsoma  ;caso o resultado seja negativo ele vai pular para o negsoma:
mov bl,"+" ;transformo bl no sinal para ser printado

negsoma:
neg cl
mov bl,"-"

xor ch,ch ;comecamos a divisao do resultado para que possamos imprimir 2 valores
mov ax,cx
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