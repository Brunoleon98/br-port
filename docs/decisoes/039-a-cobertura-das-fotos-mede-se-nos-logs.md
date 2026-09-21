# 039 — A cobertura das fotos MEDE-SE nos logs, não se declara ao lado do tiro

**21/09/2026 · item próprio, herdado da sessão das capturas · origem:
`docs/decisoes/038`, o último parágrafo de "o que fica de fora"**

## A pergunta que faltava ao projeto inteiro

A `038` pôs foto nos quinze painéis e escreveu, no fim, o que ficava por fazer:
**nada pergunta se um painel novo tem fotografia**. Cada `tirar()` da bateria
responde pelo SEU tiro — a imagem saiu, o erro não apareceu, a contagem e o
turno batem — e nenhum responde pelo CATÁLOGO.

O que isso custou, medido:

- o R7 e o R8 mexeram em **quatro** telas sem foto nenhuma, e olharam à mão;
- **três sessões contaram os painéis e as três disseram treze**; são **quinze**;
- as duas que faltavam escapam por razões diferentes: o `EndGame.tscn` não vive
  em `scenes/panels/`, e a `TelaNomes` é dispensada de propósito pela
  ferramenta que fotografa o jogo.

## A decisão 1 — a lista sai do que o jogo ABRE, não da pasta

A fonte é `_abrir_painel(...)` no `Main.gd`, com os `const ... := preload(...)`
do topo a resolver cada argumento. **A pasta não serve**, e é o facto medido
acima que o prova: foi ela que perdeu o `EndGame` três vezes.

E a diferença não é só de contagem — é de significado. Um painel que o jogo
nunca abre **não é buraco de foto**: é arte órfã, e quem pergunta isso já
existe (`tools/arte_orfa.py`).

⚠️ **E A ABERTURA QUE NÃO SE RESOLVE REPROVA, em vez de ser saltada.** O `Main`
tem uma dinâmica — `_abrir_painel(load(cena) as PackedScene)`, o app do
menu-celular —, e ela resolve-se pela tabela `APPS` do `PainelMenu.gd`, que é
quem sabe o que cada app abre (hoje só o Diário; as outras quatro portas têm
`cena` vazia). Qualquer forma que a ferramenta não saiba ler fica VERMELHA:
saltá-la em silêncio devolvia o buraco que o portão veio tapar.

## A decisão 2 — a cobertura é MEDIDA, e é aqui que está a sessão

A saída fácil era o tiro **declarar** que painel cobre, num comentário
`# cobre: res://...`. Havia três formas de cobertura e uma delas não é chamada
nenhuma — o Boletim abre-se sozinho na virada da semana —, de modo que a
declaração parecia inevitável para pelo menos um caso.

**Uma declaração à mão mente.** Escreve-se "cobre o Caixa" num tiro que
fotografa o Calendário, e as outras guardas não notam: é o mutante **N6**, e
está medido — a contagem viu 1 painel, o turno viu 13, a foto pesou 306.639
bytes, e as três passaram.

A saída que mede custa mais e mente menos: as duas ferramentas de captura
IMPRIMEM a cena de cada painel que estava na tela —

```
Paineis: res://scenes/panels/PainelCaixa.tscn
```

— e o portão lê os LOGS que a bateria já guardava. **O que prova a cobertura é
a fotografia, e não quem a escreveu.** O Boletim entra de graça: ele aparece no
log do tiro que o espera, sem ninguém ter de o nomear.

São duas fontes que nada obriga a concordar, que é a receita deste projeto
desde o D20: o que o jogo ABRE (`Main.gd`) contra o que foi À TELA (os logs).

⚠️ **E O RÓTULO É ASCII DE PROPÓSITO** (`Paineis:`, sem til). A saída destas
ferramentas é contrato — o `capturar_evidencia.sh` procura `Overlay:` e `Tela
salva em` —, e um padrão com acento depende do locale de quem corre o `grep`.
Perde-se um til; ganha-se a guarda não mudar de comportamento entre o contêiner
e o runner. E o `(nenhum)` está escrito por extenso porque **uma linha vazia
não se distingue de uma linha que não chegou a ser impressa**.

## A decisão 3 — o portão corre no FIM da bateria

Precisa dos logs de todos os tiros, portanto não pode correr antes. Em Python,
como o `conferir_escopo_ui.py` e o `conferir_guardas_ci.py`, porque aqui uma
exceção sai com código ≠ 0 e o `set -e` apanha — enquanto o Godot encerra com 0
depois de um erro. Marcador `COBERTURA OK`.

É também a razão de os logs não se apagarem, que até 18/09 acontecia.

## ⚠️ As duas armadilhas que morderam na estreia da própria ferramenta

A expressão que lia as chamadas era `_abrir_painel\(\s*([^)]*?)\s*\)`, e
reprovou a base CERTA por duas razões, ambas registadas neste projeto:

1. **`[^)]*` PARA NO PRIMEIRO PARÊNTESE.** A chamada dinâmica traz outra
   dentro, e a expressão leu `load(cena` — acusando uma forma desconhecida que
   ela própria tinha partido ao meio. É a lição do F9 (`037`), onde o argumento
   com parênteses E aspas fez a expressão achar 9 de 11.
2. **A DEFINIÇÃO NÃO É UMA CHAMADA.** `func _abrir_painel(cena: PackedScene)`
   casa tão bem quanto uma chamada de verdade, e a ferramenta exigiu fotografia
   de um painel chamado `cena: PackedScene`.

Hoje o argumento lê-se com **parênteses equilibrados** e a definição está
excluída por `(?<!func )`.

## Os mutantes

Seis, cada um sozinho, com a base exigida VERDE entre eles, a cópia guardada
com `cp` e não com `git`, e o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| N1 | o tiro da `TelaNomes` retirado da bateria | reprovou, nomeando a cena |
| N2 | a MESMA abertura dentro de um COMENTÁRIO | **passou**, como devia |
| N3 | as mesmas duas linhas **sem o `#`** | reprovou |
| N4 | abertura dinâmica que a ferramenta não sabe resolver | reprovou, em vez de saltar |
| N5 | o rótulo `Paineis:` apagado dos logs | reprovou — e **nomeou o rótulo** |
| N6 | o tiro do Caixa a fotografar **outro painel** | reprovou; a contagem (1), o turno (13) e o tamanho (306.639 bytes) passaram todos |

⚠️ **O N2 SOZINHO NÃO PROVA NADA**, e é por isso que o N3 é no MESMO arquivo e
nas mesmas linhas: a única diferença entre os dois é o `#`, e um passa e o
outro reprova. Sem o par, "verde" podia querer dizer *"o scanner nunca olhou
para este arquivo"* (`036`, M7/M8).

⚠️ **E O N5 EXISTE POR CAUSA DA FORMA DO VERMELHO, não da sua existência.** Sem
a pergunta *"algum log trouxe a linha?"*, apagar o rótulo das duas ferramentas
daria **quinze** faltas — e quem lesse o vermelho procuraria quinze painéis
perdidos em vez de um `print`. Um portão diz também **onde** olhar.

⚠️ **E O N6 É A SESSÃO INTEIRA NUMA LINHA.** Ele é o defeito que uma declaração
à mão não podia apanhar, porque a declaração é que estaria errada. Medido: as
outras três guardas do tiro passaram todas.

## O que fica de fora, dito

- **O portão não pergunta o que o painel DIZ.** Um tiro com o estado errado —
  o Docas num turno em que a contagem é 1 — continua a não reprovar nada. O que
  separa foto boa de foto inútil é quem olha; o portão só garante que há foto.
- **Ele não corre sem a bateria.** É o preço de medir em vez de declarar: a
  pergunta só tem resposta depois de as fotos existirem, e por isso ela vive no
  fim do `capturar_evidencia.sh` e não num passo de CI próprio.
- **Um painel que o jogo abre mas que nenhuma condição alcança** — se um dia
  houver — passa por coberto se calhar aparecer numa foto, e passa por buraco
  se não aparecer. O portão responde pelo CATÁLOGO, não pela alcançabilidade.
