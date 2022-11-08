TITLE André Marques - 22001640 
; Consideracoes iniciais:
; infelizmente pelas ultimas semanas terem sido mais conturbadas que normalmente nao pude fazer o trabalho que me planejei e me orgulharia
; todavia ainda consegui adicionar algumas funcionalidades adicionais, mas ainda faltando das em meu planejamento e que ja havia comecado
; no codigo.
; planejo apos a data de entrega fazer mudancas no codigo para deixa-lo mais eficiente e com todas as funcionalidades que eu previa
; pois acho que acabou se saindo muito pouco eficiente e há um espaco grande para melhorias.

.model small
.stack 100h
.data 

start1 db 10,"Bem vindo! Inputs: -99 a 99 || Outputs: -127 a 127.$"
select_op db 10,"Selecione sua operacao: + - / *:$"
num1 db 10,"Defina o primeiro numero da operacao:$"
num2 db 10,"Defina o segundo numero da operacao:$"
result db 10,"Resultado:$"
error db 10,"Algo deu errado, tente novamente:$"
error_num db 10,"Algo deu errado, tente novamente o numero:$"
error_zero db 10,"Divisao por zero, impossivel.$"
divisor db "?$" ;evitei ao maximo fazer isso mas infelizmente foi necessario 

.code

print_msg macro var1 ;macro que funciona para printar mensagens

    mov ah,09h
    lea dx,var1
    int 21h
    endm

valid_num macro ;serve para validar um numero 

    cmp al,30h  ;comparo o resultado com 0,se al ele é mandado pra error 
    jl erro_numero  ;da jmp erro_numero
    cmp al,39h  ;comparo o resultado com 9, se ele for maior é mandado pra error
    jg erro_numero
    endm

main proc 

MOV AX,@DATA           ;inicializa a data, setando ela para o registrador AX
MOV DS,AX              ;seta a data para o registrador DS



print_msg start1

start: 

print_msg select_op ;printo a msg pedindo o operador

mov ah,01h ;pegando input do operador
int 21h
mov ch,al ;ch vai ser no codigo inteiro somente para definir a operacao

    cmp ch,"+"  ;juntar essa parte do codigo junto com o switch case debaixo 
    jz cont 
    cmp ch,"-"
    jz cont       ;verifica os inputs se sao possiveis, se estao erradas ele da erro e fecha o programa
    cmp ch,"/"      ;na refatoracao integrar com o proximo passo
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
mov divisor,bl ;manda bl para divisor << tentei evitar ao maximo pra nao ficar confuso mas nao consegui 

;=================== chance de melhorar o codigo // fazer igual o ENZO

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
call divi           ;chama o procedimenot de divisao
call printar        ;printa o sinal e printa e o modulo
call printar_virg   ;printa a virgula e os 2 decimais apois a virgula
jmp exit
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

soma proc   ;ja ta funcionando o menos e o mais
    ;realiza a soma 
    ;recebe como inputs bh e bl (nessa ordem)
    ;retorna o produto em cl
    ;retorna o sinal em bl

    add bh,bl
    mov cl,bh ;o cl vai sempre ser o resultado das operacoes
    and cl,cl 

    js negsoma  ;caso o resultado seja negativo ele vai pular para o negsoma:
    mov bl,"+" ;transformo bl no sinal para ser printado
    ret

    negsoma:
    neg cl
    mov bl,"-"
    
    ret
soma endp

menos proc  ;ja ta funcionando o menos e o mais
    ;realiza a subtracao 
    ;recebe como inputs bh e bl (nessa ordem)
    ;retorna o produto em cl
    ;retorna o sinal em bl

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

mult proc ;funcionando com os valores positivos e negativos na multiplicacao >> sinal e magnitude e nao complemento de 2
    ;realiza a multiplicacao 
    ;recebe como inputs bh e bl (nessa ordem)
    ;retorna o produto em cl
    ;retorna o sinal em dh (que apos é transofrmado em bl)
    ;utiliza a funcao de sinalizacao para receber o valor do sinal
    ;seu algoritmo principal é realizar a soma do multiplicando caso o bit do multiplicador seja 1
    ;e ir realizando o deslocamento assim que necessário 


;========= vai verificar a sinalizacao da multiplicacao =====

call sinalizacao

;========== algoritmo da multiplicacao ===========

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
jmp end_mult

carry0:
or ch,00h  ;no caso de carry0 a soma vai ser com 0 por conta de ser zerado
cmp bl,3  ;caso contador seja 4 ele vai printar direto
jnz restart

end_mult:
mov cl,ch   ;mandando valor de ch para cl
mov bl,dh   ;mandando o valor de dh para bl, o dh é onde fica salvo o sinal no proc de sinalizacao 
ret

    
mult endp

divi proc
    ;realiza a divisao 
    ;recebe como inputs bh e bl (nessa ordem)
    ;retorna o produto em cl
    ;retorna o sinal em dh (que apos é transofrmado em bl)
    ;utiliza a funcao de sinalizacao para receber o valor do sinal
    ;seu algoritmo principal é realizar a subtracao do divdendo pelo divisor 1
    ;e ir realizando o deslocamento assim que necessário 

        
        call sinalizacao ;primeiro ele ta vendo qual vai ser o sinal do resultado
        ;sinalizacao é salva em dh (portanto nao usar dh no codigo)

        xor dl,dl ;reseta dl que foi utilizado na sinalizacao
        mov ah,bl ;manda bl para ah

        ;bh é o dividendo
        ;bl é o divisor
        ;ch e cl sao os digitos uteis de bh e bl
        ;dl é a resposta 
        ;dh é o sinal

        cmp bl,0 ;compara se o divisor for 0
        je zero_erro

        mov cl,bh ;mandando bh pra cl pra ver a quantidade de digitos uteis
        call dig_uteis ;vai retornar em cl o valor dos numeros uteis de bh
        mov ch,cl   ;mandando digitos uteis de bh para ch

        mov cl,bl   ;pega o valor dos digitos uteis de bl
        call dig_uteis  ;retorna cl
        ;como cl já é o registrador dos uteis de bl eu vou mandar como ta

        mov dl,ch ;salva o valor de ch em dl para que seja retornado

        sub ch,cl ;pega o valor de quantas vezes precisa deslocar pra esquerda pra ficar o maximo
        xchg ch,cl ;o valor de quantas vezes é deslocado é mandado pra cl
        shl bl,cl ;faz o shift da quantidade de vezes que é necessário
        xchg ch,cl ;e depois é voltado pra ch e cl se mantem normal

        mov ch,dl ;manda dl para ch parq que o volte o valor normal de ch

        xor dl,dl ;reseta dl para que seja usado como contador

        comeca_divi:
        cmp bh,bl ;se o valor for negativo, significa que ele tem que ser jogado para a direita uma vez
        js blmaiorbh ;se for maior vai pular para isso

        sub bh,bl ;retira bl de bh pela primeira vez
        shr bl,1 ;joga o divisor para a direita para a proxima sub
        dec ch ;diminui uma unidade de ch (ele ja fez UM dos digitos uteis) 
        shl dl,1 ;ele joga o resultado para direita para adicionar um valor
        or dl,1 ;adiciona um bit 1 para o resultado (pois bl NAO era maior que bh)
        cmp ch,cl ;compara o valor de cl com ch para ver se ja chegou na ultima subtracao
        jns comeca_divi ;se for positivo ou 0, ele volta, caso contrario ele para
        js fora ;senao ele vai pra fora

        blmaiorbh: ;caso o valor for negativo ele vai vir pra ca, ou seja, vai ter um 0 nesse bit da resposta
        shr bl,1 ;desloca o divisor pra direita
        dec ch ;faz decrease de ch
        shl dl,1 ;faz o deslocamento da reposta para a esquerda
        or dl,0 ;adiciona o bit desse loop como 0 
        cmp ch,cl ;novamente compara se o valor de cl com ch para saber se ele vai voltar ou sair
        jns comeca_divi
        js fora

    fora:
    ;nessa situacao bh se torna o resto enquanto o quosciente é dl, nessa situacao deverá ter alguma maneira de repetir o processo com o resto
    ;a menor multiplicacao possivel é 99/9, portanto o sistema de print DO QUOCIENTE ja funciona, agora é necessário um sistema de pritnar 
    ;para printar as virgulas.
    ;nesse caso vamos fazer o call de printar aqui mesmo na funcao e nao pela main.
    ;queremos printar 2 numeros apos a virgula, portanto vamos pegar o resto x 10 e dividir novamente


    ;dl = resultado
    ;dh = sinal
    ;bh = resto
    ;ah = divisor

    mov cl,dl ;manda o valor de dl para cl para chamar a funcao de print
    mov bl,dh ;manda o valor do sinal

    ret

    zero_erro:
    print_msg error_zero
    mov ah,4ch
    int 21h
    ret
divi endp

printar proc ;nao usa bh portanto posso usar na printar_virg
    ;essa é a funcao para print do numeros antes da virgula
    ;ela recebe os valores de cl para numero e bl como sinal
    ;todos os numeros sao enviados como numerais ent sao traduzidos para char
    ;e feito as divisoes para imprimir os numeros em suas casas decimais


    xor ch,ch ;comecamos a divisao do resultado para que possamos imprimir 2 valores
    mov ax,cx ;cl se torna cx
    mov ch,100
    div ch ;al = quociente ah = resto

    mov cl,al   ;cl se torna quociente
    mov ch,ah   ;ch se torna resto

    print_msg result

    mov ah,02h ;printo o sinal do numero
    mov dl,bl ;printo o sinal do numero
    int 21h

    mov ah,02h ;printa o modulo do cosciente do numero
    or cl,30h ;transforma o numeral em char
    mov dl,cl ;printa o resultado
    int 21h

    mov cl,ch ;mando o resto para cl para ser printado de novo
    xor ch,ch ;comecamos a divisao do resultado para que possamos imprimir 2 valores
    mov ax,cx ;cl se torna cx
    mov ch,10
    div ch ;al = quociente ah = resto

    mov cl,al   ;cl se torna quociente
    mov ch,ah   ;ch se torna resto

    mov ah,02h ;printa o modulo do cosciente do numero
    or cl,30h ;transforma o numeral em char
    mov dl,cl ;printa o resultado
    int 21h ;printa o modulo decimal

    or ch,30h ;transformo o resto em char
    mov dl,ch ;mando para printar
    mov ah,02h
    int 21h ;printo
    ret
printar endp

printar_virg proc
    ;essa é a funcao para printar os numeros apos a virugla
    ;ela é utilizada somente para a divisao, por isso seus inputs sao especifiso porem ainda
    ;sao citados abaixo.
    ;ela recebe o resto principal da divisao, multiplica por 10 e refaz a divisao para que seja printada as casas deciamsi

    ;bh = resto
    ;bl = divisor
    ;vai fazer bh * 10 e depois dividir pelo divisor, pegar o resto e fazer a mesma coisa
    
    mov bl,divisor ;recebe o valor do divisor para bl 

    mov ah,02h
    mov dl,"."
    int 21h ;print o valor da virgula primeiro
    
    mov al,bh ;mando bh para al para q seja multiplicado
    mov ch,10 ;mando 10 para ch 
    mul ch ;multiplico al por 10, o resultado é salvo em al

    ;portanto o resto multiplicado por 10 ta salvo em al
    ;agr divido ele por bh

    xor ah,ah ;reseta ah para q al seja ax, necessario na div

    div bl ;divido al por bl(divisor) e o resultado é salvo em al e o resto em ah

    or al,30h ;transformo em char
    mov dl,al ;mando o quociente para dl
    mov bh,ah ;mando o resto para bh ser pritnado 

    mov ah,02h
    int 21h ;print o valor salvo em dl (o primeiro decimal)

    mov al,bh ;mando bh para al para q seja multiplicado
    mov ch,10 ;mando 10 para ch 
    mul ch ;multiplico al por 10, o resultado é salvo em al

    ;portanto o resto multiplicado por 10 ta salvo em al
    ;agr divido ele por bh

    xor ah,ah ;reseta ah para q al seja ax, necessario na div

    div bl ;divido al por bl(divisor) e o resultado é salvo em al e o resto em ah

    or al,30h ;transformo em char
    mov dl,al ;mando o quociente para dl

    mov ah,02h  ;printo o segundo decimal
    int 21h


    ret

printar_virg endp

pegar_input proc ;com possibilidade de pegar inputs negativos e números decmais (tanto os valores quanto os sinais estão dando certinho)
    ;essa funcao é uma das quais mais facilitas
    ;ela nao tem input e somente retorna output, em al
    ;ela recebe o sinal dos numeros nas contas de soma e subtracao (os unicos q necessitam q sejam complemento de 2
    ;realiza a negacao dos numeros caso necessario e recebe o input de numeros com 2 casas decimais, multiplicando os se necessario

xor bl,bl   ;reseta bl para que o sinal seja mantido neutro
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
mov dh,10 ;salvando o valor a ser multiplicado em dh para que a funcao seja multiplicada corretamente
mul dh   ;multiplica o al em 10, o resultado é salvo em AX (salvo oficialmentem em AL)

add cl,al ;adiciona o valor de cl em al, para que o numero seja decimal 

unitario:
mov al,cl ;retornam os valores para seus locais originais
cmp bl,"-"  ;comparo para ver se o sinal é negativo
jne resultado_positivo   ;ele da jump se for positivo pro ret
neg al  ;sendo negativo ele nega o numero em seu complemento de 2
resultado_positivo:
xor cl,cl
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

sinalizacao proc    ;arruma a sinalizacao para procedimentos que nao possam ser feitos em complemento de 2 (mult e div)
    ;assim como citado acima, multiplicacao e divisao nao é por complemento de 2, porntanto para casos sinalizados
    ;é necessário um algoritmo diferente para mostrar seus sinais, por conta disso essa funcao nao tem input, ela verifica na hora
    ;os valores dos numeros e retorna o sinal do resultado por meio de dh



    ;======== verifica o sinal da multiplicacao =========
    xor dh,dh
    xor dl,dl

    and bh,bh ;verifica as flags relacionadas a bh
    js neg_bh   ;da o jmp se bh for negativo
    jns pos_bh  ;da jmp se bh for positivo 
    neg_bh:
    mov dh,1  ;adiciona um em dh
    neg bh ;pega o modulo de bh

    pos_bh: ;se bh for positivo ele pula diretamente pra ca
    and bl,bl   ;verifica as flags relacionadas a bl
    js neg_bl   ;pula se bl for negativo
    jns pos_bl  ;sai da parte do sinal se for positivo
    neg_bl:
    mov dl,1  ;adiciona um em dl
    neg bl  ;pega o modulo de bl

    pos_bl:

    xor dl,dh ;verifico se haverá sinalizacao negativa
    jz ch_pos   
    jnz ch_neg
    jmp erro

    ch_pos:
    mov dh,"+"  ;move o sinal positivo para o dh que será printado
    ret ;retorna pro procedimento que esta sendo chamado

    ch_neg:
    mov dh,"-"  ;move o sinal negativo que sera printado de dh
    ret ;retorna pro procedimento que esta sendo schamado

sinalizacao endp

dig_uteis proc  ;recebe um valor e pega a quantidade de digitos uteis dele (00001010 = 4 digitos uteis)
;essa funcao so é necessário para a divisao, todavia achei interessante e util para proximas funcionliades
;ela recebe um numero decimal e retorna a quantidade de "digitos uteis" em binários, ignorando os zeros a esquerda
;recebe cl como seu digito util
;retorna o valor de digitos uteis em cl

    mov ah,8 ;ah se torna o contador que sera decrementado para que saibamos a quantidade de digitos uteis

    recontar:
    rol cl,1 ;rotaciona cl para esquerda para checar sua quantidade de digitos uteis
    dec ah  ;decrementa um de ah toda vez que o loop rodar. até que ache o primeiro valor de 1
    jc carry_inicial    ; é 1? vai sair entao
    cmp ah,0    ;nao é 1 mas o valor de ah virou 0? (numero inutil)
    jne recontar    ;ele sai tbm
    ret ;retorna se o numero de ah for 0

    carry_inicial:
    inc ah ;o codigo faz um decrease a mais que deve ser compensado aqui
    mov cl,ah   ;manda o valor de ah para cl ser retornado
    ret ;retorna o valor de digitos uteis para cl

dig_uteis endp

end main 
