# 011 — O camião entra na doca do navio que serve

**07/09/2026.** Item 3 da segunda jogada no telefone, escolhido pelo Bruno
depois de o primeiro bloco fechar. As palavras dele:

> *"Os caminhões poderiam entrar nas docas, no caso seriam caminhões
> relacionados aos serviços. Daí ao alocar um navio de um determinado serviço,
> um caminhão relacionado pode aparecer na estrada e ir para a doca desse
> navios. Caso o navio vá embora, esse caminhão vai embora também.*
>
> *Toma cuidado para não gerar um trânsito muito grande de caminhões, e tome
> cuidado para os caminhões não terem bugs"*

Nada aqui encosta na economia: nenhuma constante `# TUNING:` foi tocada, e o
camião continua a não gastar um único sorteio do `RandomNumberGenerator` que o
simulador usa. A `/balancear` não correu, e de propósito.

---

## A decisão, em quatro partes

### 1. O acesso ao berço já existia no mapa, e ninguém o percorria

O `vias()` desenha, desde sempre, uma ligação da rua até o avental na altura de
cada píer — *"é o que explica para que serve a rua"*, diz o comentário dela.
Até hoje era desenho e mais nada: o camião levava a carga da doca do mesmo
índice (`010`) e passava reto por cima dela.

Agora o mapa **publica** esses acessos na tabela de âncoras, como já publicava
os cotovelos, e o camião percorre-os. A regra deste repositório é a de sempre:
os números saem da mesma expressão que os desenha, a cópia que roda dentro do
jogo é conferida contra eles, e quem mexer no `RUA_RECUO` move os dois lados.

### 2. A visita é «barco E trabalhador», não «barco»

O pedido diz *"ao ALOCAR um navio"*, e a diferença importa. Um camião encostado
num berço sem ninguém a trabalhar afirmaria que o porto está a operar quando
não está — e é exatamente esse o aviso que o jogo dá em letra âmbar por baixo do
mapa (*"3 trabalhadores parados — 3 docas esperando"*).

Com as duas condições, alocar um trabalhador passa a ter **consequência
visível no mapa**, que é o que faltava: até aqui o retorno de alocar era um
número no cartão.

### 3. A decisão toma-se NO ACESSO, não à entrada do mapa

A primeira versão decidia quando o camião entrava no mapa. Funcionava e estava
errada: punha a decisão a um minuto de distância do jogador, porque uma volta
inteira leva ~69 s — alocar não fazia nada até o camião dar a volta.

Hoje ele passa **sempre** pelo ponto de entrada do acesso e decide ali. É
também a forma mais segura de o fazer, e isso responde ao segundo cuidado que
ele pediu: naquele ponto o camião está parado num vértice conhecido, e o que se
faz é **começar o percurso seguinte** — nunca remendar um a meio, que é onde
moram os defeitos.

Pela mesma razão a volta deixou de ser um `tween` em laço e passou a
rearmar-se: um laço só sabe repetir a mesma coisa, e com o desvio cada volta é
diferente da anterior.

### 4. O trânsito não cresce — encolhe

Continuam a ser **três camiões**, um por doca. O primeiro cuidado que ele pediu
— *"não gerar um trânsito muito grande"* — fica satisfeito por construção, e não
por moderação: um camião encostado num berço **não está na estrada**. Um porto
a operar nas três docas tem a rua mais vazia do que um porto parado, e isso
lê-se como o trabalho ter saído da estrada para o cais.

---

## O que NÃO se fez, e por quê

**Nenhum camião a mais.** Um camião por navio servido, com três docas, são três.
Fazer aparecer um camião extra por chegada seria a fila que ele pediu para
evitar.

**Nenhuma silhueta nova.** Ele encosta de frente e sai de ré, e isto é uma
escolha com custo declarado. São duas silhuetas por carga, uma por eixo, e as
duas foram desenhadas para o sentido POSITIVO — que era o único que a rota
usava. O acesso percorre-se para dentro em `+mx` e para fora em `-mx`: **uma das
duas pernas ia ser de ré fizesse-se o que se fizesse.** Um terceiro jogo de PNGs
viraria a cabine para `-mx` e mostraria a traseira — não é rodar o prop, é
reconstruí-lo, porque só as faces `+x` e `-y` se veem —, e são mais quatro peças
de arte para 74 px de movimento lento na beira do quadro. Encostar de frente e
sair de ré é o que um camião de carga faz numa baía.

**Nenhuma mecânica nova.** O camião não carrega, não descarrega e não entra em
conta nenhuma. Ele mostra.

---

## O defeito que este trabalho descobriu

Os **dois lotes reservados** que o bloco anterior desenhou no pátio estavam por
cima dos acessos aos berços — e a mais de 0,25 unidades dentro do avental. Foram
postos a olho, e o `my` de cada um calhava ser exatamente onde um acesso começa.
Ninguém viu enquanto o camião passava reto pela rua; **viu-se no primeiro frame
em que ele entrou na doca e foi encostar em cima da demarcação.**

Varrido o pátio inteiro contra os acessos, os cotovelos, os dois prédios e os
props da cena, um lote de 2,0 × 1,7 tem **uma** posição livre — e são precisas
duas, uma por estrutura de Fase 2. A 1,6 × 1,4 abrem-se duas, com folga de 0,73
e 0,30 unidades. São essas.

A lição fica escrita no teste: **nada perguntava se dois desenhos do MAPA se
sobrepõem.** O D2 mede pegada de PROP contra faixa, e um lote não é prop.

---

## O que passou a ser verificável

- O mapa publica `acessos` (um por vaga de doca) e `lotes_reservados`.
- O **D13** exige um acesso por vaga de doca, a entrada igual à publicada, a
  paragem derivada do fundo do acesso menos um recuo MEDIDO nos PNGs, a entrada
  num trecho reto da rota, o camião encostado inteiro dentro do quadro, e a
  condição da visita perguntada a quem decide — nos três estados que ela separa.
- E que **nenhum lote reservado pisa um acesso** nem transborda para o avental.
- A captura ganhou o tiro `docas`: o porto A OPERAR, com os camiões nos berços.
  Ele existe pela mesma razão que a folha da frota — os outros tiros fotografam
  sempre o instante em que os trabalhadores estão livres, e a mecânica não
  aparecia em imagem nenhuma.

As oito asserções novas foram provadas com defeito injetado, uma a uma, com a
base conferida limpa entre cada. **Uma delas foi reescrita por não conseguir
reprovar**: varria o desvio contra o retângulo do acesso, e o desvio é uma reta
entre dois pontos que outras duas asserções já prendem aos números publicados.
E **uma injeção teve de ser montada duas vezes**, porque a primeira parou numa
guarda anterior e a que se queria testar nunca chegou a ser exercida.
