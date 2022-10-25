TITLE André Marques - 22001640 // Plínio Zanchetta - 22023003
.model small
.stack 100h
.data 

select_op db 10,"Selecione sua operacao: + - / *:$"
error_sinal db 10,"A sinalização pode ser feita somente com (-) !!:"
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

main proc 

MOV AX,@DATA           ;inicializa a data, setando ela para o registrador AX
MOV DS,AX              ;seta a data para o registrador DS

start: 

print_msg select_op ;printo a msg pedindo o operador

mov ah,01h ;pegando input do operador
int 21h
mov ch,al ;ch vai ser no codigo inteiro somente para definir a operacao

    cmp ch,"+"
    jz cont
    cmp ch,"-"
    jz cont       ;verifica os inputs se sao possiveis, se estao erradas ele da erro e fecha o programa
    cmp ch,"/"
    jz cont
    cmp ch,"*"
    jz cont
    jnz erro ;caso seja diferente dos inputs escolhidos ele vai pular pro erro e fecha o programa


cont:

print_msg num1  ;printa msg pedindo numero 1

call pegar_input ;chama a funcao de input
mov bh,al ;move al para bh

print_msg num2 ;printa msg  pedindo numero  2

call pegar_input
mov bl,al ;o segundo numero vai sempre ficar salvo em bl

cmp ch,"+" ;soma deu tudo certo
jnz not_soma
call soma   ;chama o procedimento de soma 
jmp print
not_soma:

cmp ch,"-"  ;sub deu tudo certo
jnz not_menos
call menos  ;chama o procedimento de subtracao
jmp print
not_menos:

cmp ch,"*" ;introducao a multiplicacao
jnz not_mult
call mult   ;chama o procedimento de multiplicacao
jmp print
not_mult: ;como se fosse um switch case, vai testando todos até que encontra o que ele quis

cmp ch,"/"
jnz not_divi
call divi   ;chama o procedimenot de divisao
jmp print
not_divi:

print:
call printar ;chama o procedimento de print 
jmp exit

exit:
mov ah,4ch ;finaliza o codigo
int 21h

erro:
print_msg error ;printa msg de error  
jmp start

main endp 

soma proc

    add bh,bl
    mov cl,bh ;o cl vai sempre ser o resultado das operacoes

    js negsoma  ;caso o resultado seja negativo ele vai pular para o negsoma:
    mov bl,"+" ;transformo bl no sinal para ser printado

    negsoma:
    neg cl
    mov bl,"-"
    
    ret
soma endp

menos proc

    sub bh,bl ;faz o sub 
    mov cl,bh ;movo o resultado para CL << registrador padrao de respostas
    js sub_neg_print
    mov bl,"+"  ;caso o numero NAO SEJA NEGATIVO ele vai printar como positivo
    ret

    sub_neg_print: 
    neg cl ;ele vai pegar o valor do modulo de Cl
    mov bl,"-"  ;transforma o registrador que salva o sinal em negativo para que printe como um numero negativo
    
    ret
menos endp

mult proc ; ta funcionando mas tem 2 problemas: printar numeros com mais de 1 casa decimal e receber input com mais de uma casa decimal

    ;BH é o multiplicando que será modificado e shiftado para que possa ser adicionado em ch, que foi zerado
    mov ch,0 ;ch foi zerado para que ele possa servir de somatória dos resultados 
    mov cl,bl  ;manda o valor de bl(input multiplicador=const) para multiplicador = variavel
    mov bl,0    ;zero o contador
    jmp primeira    ;a primeira vez que o codigo rodar ele vai pular direto para que o multiplicano nao da shift para esquerda
    restart:    ;o loop recomeca
    shl bh,1    ;shift de multiplicando para esquerda por 1 bit
    inc bl ;transofrma bl em contador para loop
    primeira:   ;pula pra primeira vez
    ror cl,1 ;rotate de multiplicador para direita com o intuito de saber o valor de carry
    jnc carry0
    jc carry1
    carry1:
    add ch,bh ;q sofreu shift pra esquerda toda vez q o loop roda <<<<<<<<<<<<< testar com ADD
    cmp bl,3;compara contador com 4 para saber se ele teria que reiniciar o loop ou printar
    jnz restart ;se for diferente de 4, o loop vai recomecar e o contador vai ser adicionado
    mov cl,ch ;mandando o valor de ch completo para cl ser printado
    mov bl,"+"
    jmp print   
    carry0:
    or ch,00h  ;no caso de carry0 a soma vai ser com 0 por conta de ser zerado
    cmp bl,3  ;caso contador seja 4 ele vai printar direto
    jnz restart
    mov cl,ch
    mov bl,"+"
    
    ret
mult endp

divi proc
        ;colocar as funcoes de divisao 
        ;bh / bl
        ;loop de bh sub bl enquanto bh for maior ou igual a 0 e toda vez no loop faz inc do resultado 

    ret
divi endp

printar proc

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
    
    ret
printar endp

pegar_input proc
;============================== validacao de input  ========================
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
RET 

isneg: ;caso ele seja um valor negativo ele vai ter seu valor negado
mov bl,al;manda o input do sinal para bl
mov ah,01h
int 21h
jmp continue

erro_numero:
print_msg error_num
jmp start_numero    ;reinicia 

pegar_input endp 

end main 
