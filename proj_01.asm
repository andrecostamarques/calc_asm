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
jnz erro
cmp ch,"-"
jz cont
jnz erro
cmp ch,"/"
jz cont
jnz erro
cmp ch,"*"
jz cont
jnz erro


cont:
mov ah,09h
lea dx,num1 ;printa a frase pedindo o primeiro numero
int 21h

mov ah,01h
int 21h
mov bh,al ;o primeiro numero vai sempre ficar salvo em bh

mov ah,09h
lea dx,num2 ;printa a frase pedindo o primeiro numero
int 21h

mov ah,01h
int 21h
mov bl,al ;o segundo numero vai sempre ficar salvo em bl

cmp ch,"+" ;soma deu tudo certo
jz soma 

cmp ch,"-"
jz subtracao ;alguma coisa ta dando errado na subtracao 

soma: 
add bh,bl
mov cl,bh ;o cl vai sempre ser o resultado das operacoes
sub cl,30h
jmp print


subtracao: 
sub bh,bl
mov cl,bh
sub cl,30h
jmp print


print:
mov ah,09h
lea dx,result ;printa a frase pedindo o operador
int 21h
mov ah,02h
mov dl,cl ;printa o resultado
int 21h

exit:
mov ah,4ch ;finaliza o codigo
int 21h

erro:
mov ah,09h
lea dx,error ;printa a frase pedindo o operador
int 21h
mov ah,4ch ;finaliza o codigo
int 21h


main endp 
end main 
