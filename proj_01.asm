.model small
.data 

selec_op db 10,"Selecione sua operacao: + - / *:$"
num1 db 10,"Defina o primeiro numero da operacao:$"
num2 db 10,"Defina o segundo numero da operacao:$"
result db 10,"Resultado:$"
error db 10,"Algo deu errado, tente novamente.$"


.code
main proc 

MOV AX,@DATA           ;inicializa a data, setando ela para o registrador AX
MOV DS,AX              ;seta a data para o registrador DS

start: 
mov ah,09h
lea dx,selec_op ;printa a frase pedindo o operador
int 21h

mov ah,01h
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
mov ah,09h
lea dx,num1 ;printa a frase pedindo o primeiro numero
int 21h

mov ah,01h
int 21h
mov bh,al ;o primeiro numero vai sempre ficar salvo em bh
and bh,0fh ;transforma bh em numeral

mov ah,09h
lea dx,num2 ;printa a frase pedindo o segundo numero
int 21h

mov ah,01h
int 21h
mov bl,al ;o segundo numero vai sempre ficar salvo em bl
and bl,0fh ;transforma bl em numeral


cmp ch,"+" ;soma deu tudo certo
jnz not_soma
call soma   ;chama o procedimento de soma 
not_soma:

cmp ch,"-"  ;sub deu tudo certo
jnz not_menos
call menos  ;chama o procedimento de subtracao
not_menos:

cmp ch,"*" ;introducao a multiplicacao
jnz not_mult
call mult   ;chama o procedimento de multiplicacao
not_mult: ;como se fosse um switch case, vai testando todos até que encontra o que ele quis

cmp ch,"/"
jnz not_divi
call divi   ;chama o procedimenot de divisao
not_divi:

print:
mov ah,09h
lea dx,result ;printa a frase falando o resultado 
int 21h

mov ah,02h ;printo o sinal do numero
mov dl,bl ;printo o sinal do numero
int 21h

mov ah,02h ;printa o modulo do numero
or cl,30h ;transforma o numeral em char
mov dl,cl ;printa o resultado
int 21h
jmp exit
;futuramente adicionar maneiras de salvar o resultado das operacoes e voltar pro inicio para poder fazer outras contas

exit:
mov ah,4ch ;finaliza o codigo
int 21h

erro:
mov ah,09h
lea dx,error ;printa a frase avisando o erro 
int 21h
jmp start

main endp 

soma proc

    add bh,bl
    mov cl,bh ;o cl vai sempre ser o resultado das operacoes
    mov bl,"+" ;transformo bl no sinal para ser printado
    jmp print ;vai enviar o valor para printar normalmente

soma endp

menos proc

    sub bh,bl
    mov cl,bh
    js sub_neg_print
    mov bl,"+"
    jmp print ;se for positivo vai printar normalmente

    sub_neg_print: 
    neg cl 
    mov bl,"-"  ;transforma o registrador que salva o sinal em negativo para que printe como um numero negativo
    jmp print

menos endp

mult proc           // ta funcionando mas tem 2 problemas: printar numeros com mais de 1 casa decimal e receber input com mais de uma casa decimal

    mov cl,0 ;inicia o loop zerado
    mov al,bh
    sub bl,1 ;para o algoritmo funcionar a soma tem que ser feita x-1 vezes seguidas 
    inicio_loop_mult:
    add bh,al ;adiciona al(valor incial de bh) em bh
    inc cl  ;aumenta o contador
    cmp cl,bl   ;compara se o contador é do tamanho do multiplicador 
    jl inicio_loop_mult ;se ele é menor a gnt comeca o loop de novo

    mov cl,bh   ;movemos o produto da multiplicao para cl ser printado
    mov bl,"+" ;se der pra inserir numeros NEGATIVOS <<< isso tem que mudar, colocar mesmo esquema de sub 
    jmp print 

mult endp

divi proc
        ;colocar as funcoes de divisao 
        ;bh / bl
        ;loop de bh sub bl enquanto bh for maior ou igual a 0 e toda vez no loop faz inc do resultado 
divi endp

end main 
