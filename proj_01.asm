.model small
.data 

selec_op db 10,"Selecione sua operacao: + - / *:$"
num1 db 10,"Defina o primeiro numero da operacao:$"
num2 db 10,"Defina o segundo numero da operacao:$"
result db 10,"Resultado:$"
error db 10,"Algo deu errado, tente novamente.$"


.code
main proc 
;criei a branch de Feature para trabalhar nas feature, por enquanto a de hoje vai ser a de soma e subtracao, amanha crio os jumps e 
;as multiplicacoes e divisoes
    MOV AX,@DATA           ;inicializa a data, setando ela para o registrador AX
    MOV DS,AX              ;seta a data para o registrador DS

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
jz soma 

cmp ch,"-"  ;sub deu tudo certo
jz subtracao 

soma: 
add bh,bl
mov cl,bh ;o cl vai sempre ser o resultado das operacoes
mov bl,"+" ;transformo bl no sinal para ser printado
jmp print ;vai enviar o valor para printar normalmente


subtracao: 
sub bh,bl
mov cl,bh
js sub_neg_print
mov bl,"+"
jmp print ;se for positivo vai printar normalmente

sub_neg_print: 
neg cl 
mov bl,"-"  ;transforma o registrador que salva o sinal em negativo para que printe como um numero negativo
jmp print



print:
mov ah,09h
lea dx,result ;printa a frase falando o resultado 
int 21h

mov ah,02h ;printo o sinal do numero
mov dl,bl ;printo o sinal do numero
int 21h

mov ah,02h ;printa o numero
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
jmp exit


main endp 
end main 
