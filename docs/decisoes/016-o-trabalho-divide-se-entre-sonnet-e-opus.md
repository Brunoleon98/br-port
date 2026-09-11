# 016 — O trabalho divide-se entre Sonnet e Opus, e o eixo é DECIDIR contra EXECUTAR

**08/09/2026.** Pedido do Bruno: *"devo dividir o trabalho devido ao consumo do
Opus, que tenho usado em todas as partes do projeto"*. Não é uma mudança no
jogo — é uma regra de como o projeto se toca daqui para a frente.

---

## 1. O número, e o que ele é

| Modelo | ID | Entrada $/1M | Saída $/1M |
|---|---|---|---|
| Claude Opus 5 | `claude-opus-5` | 5,00 | 25,00 |
| Claude Sonnet 5 | `claude-sonnet-5` | 2,00 | 10,00 |

**Sonnet 5 custa 2,5× menos nas duas pontas.** ⚠️ Isto é preço de lista da API,
e o Bruno trabalha por plano de assinatura — o que ele sente não é uma fatura, é
o orçamento de uso a acabar mais cedo. A razão entre os dois é o que interessa
aqui; o valor absoluto não se aplica ao caso dele e não deve ser citado como se
aplicasse.

## 2. Por que o eixo é DECIDIR contra EXECUTAR, e não "difícil contra fácil"

A tentação é dividir por dificuldade aparente, e ela leva ao sítio errado:
escrever um script de medição em GDScript *parece* mais difícil do que olhar
para um render, e é o contrário — o script é receita, e olhar é julgamento.

O eixo que separa de verdade é **quem escolhe**. Medido na sessão do item 6,
que é a mais recente e é típica:

| O que se fez | Julgamento? |
|---|---|
| Ler *"o design do guindaste pode ser melhorado"* e descobrir que o defeito era a treliça ser a assinatura do n2 | **sim** |
| Escolher a gramática que a substitui (o triângulo mastro/pau/amantilho) com o pivô preso | **sim** |
| Ver que o que prendia a lança era o MASTRO, que vive noutro grupo | **sim** |
| Reparar que o D17 prometia o desenho e media a moldura | **sim** |
| Escolher o defeito injetado que faz a guarda velha passar e só a nova reprovar | **sim** |
| Regerar os props, `--import`, tirar as nove capturas, comparar | não |
| Escrever o script que mede a luminância da peça contra o fundo | não |
| Recortar, ampliar, montar o antes/depois | não |
| Rodar as seis suítes e ler o código de saída de cada uma | não |
| Arrastar o rasto de prosa por seis arquivos | não |
| Comprimir o `ESTADO_DO_PROJETO.md` para caber no teto | não |
| Commit e push | não |

**Cinco decisões e uma cauda longa.** É essa a forma de quase toda sessão deste
projeto, e é por isso que a divisão vale a pena: o que é caro decidir é pouco, e
o que sobra é receita escrita — em `CLAUDE.md`, nas três skills e nas decisões
anteriores.

## 3. A regra de paragem é o que torna isto seguro

Dividir sem uma regra de paragem seria trocar consumo por defeito, e este
projeto já sabe quanto custa um defeito que nenhuma suíte vê.

**A sessão barata não decide.** Ao encontrar uma escolha, ela para e devolve em
vez de escolher — e a lista do que conta como escolha está no `CLAUDE.md`, para
carregar sozinha.

⚠️ **E há um item que nunca desce, por medição e não por gosto: o DEFEITO
INJETADO.** O `CLAUDE.md` tem doze parágrafos de maneiras diferentes de um
defeito injetado não provar nada — variável de ambiente já definida, arquivo
lido de `/tmp`, regra duplicada em dois sítios, `$?` do `tail`, contagem testada
com um, `mini`/`maxi` iguais em quase todo estado, asserção que monta o esperado
da mesma fonte do defeito, guarda errada a segurar, base suja entre um defeito e
o seguinte. Cada um desses parágrafos é um caso real em que alguém acreditou num
validador que nunca tinha visto defeito nenhum. **Um teste que "passa" sem nunca
ter sido exercido é pior do que teste nenhum, porque agora há confiança** — e
isso já está escrito na regra 7. É o pior sítio do projeto para poupar.

## 4. O que isto NÃO resolve

**Nenhum modelo troca o próprio modelo.** Quem troca é o Bruno, com `/model` no
Claude Code ou pelo seletor. O que a regra consegue é que a sessão **anuncie**,
numa linha, qual modelo o próximo bloco pede — e pare, se for para cima.

Há uma saída parcial e ela é dele pedir, não do modelo decidir sozinho: um
subagente aceita `model` próprio, então uma sessão de Opus pode despachar um
bloco fechado de execução ("roda as seis suítes e reporta") para um subagente
Sonnet. O `CLAUDE.md` já desaconselha subagente para o que a sessão tem em
contexto, por isso isto fica como opção sob pedido e não como omissão.

## 4b. ⚠️ A premissa está certa e é INCOMPLETA — medido em 11/09

Esta decisão assenta na razão de preço entre os dois modelos, e ela vale. O que
ela não dizia é onde o dinheiro está de facto numa sessão longa.

Medido na sessão que a escreveu, ao fim de nove dias e cinco itens: **672 mil
tokens de contexto e 65 milhões de tokens de LEITURA DE CACHE**. A forma da
conta é clara — a maior parte do gasto não é produzir trabalho novo, é
**reprocessar o histórico a cada turno**.

Três consequências, e a terceira é a que muda o modo de trabalhar:

1. **Trocar de modelo a meio da conversa ajuda menos do que parece.** O
   contexto viaja junto; só o preço por token é que desce.
2. **Um subagente com modelo próprio poupa pouco** quando a tarefa é curta: ele
   evita que a saída dela entre no contexto do pai, e nada mais.
3. **Sessão NOVA no modelo certo é o corte grande** — arranca perto de zero. E
   só é possível se o ponto de partida estiver escrito num DOCUMENTO em vez de
   viver na conversa. É por isso que a F1 termina com o desenho da medição
   registado (o do item 5 está na §7 do plano), e não com um resumo em chat.

Isto não muda a divisão de trabalho; muda o que se faz com uma sessão que já
ficou grande: **fecha-se e abre-se outra**, em vez de a arrastar.

## 5. Onde a regra vive

- **`CLAUDE.md`** — as duas listas e a regra de paragem, porque é a camada que
  carrega sozinha e a regra tem de estar viva no primeiro turno da sessão.
- **As três skills** (`/arte`, `/balancear`, `/fechar-sessao`) — uma linha no
  topo de cada, dizendo que modelo cada etapa pede. É onde se lê no momento de
  usar, que é o momento em que a decisão de modelo é tomada.
- **Aqui** — o porquê, e o número.

Não entra no `ESTADO_DO_PROJETO.md`: ele descreve o JOGO, e isto não é o jogo.
(De caminho, ele está a 121 bytes do teto de 26.000 — mais uma razão para não
lhe acrescentar o que pertence a outra camada.)
