# 031 — A evidência do CI responde por erro e por turno, e o padrão do erro não é `ERROR`

**18/09/2026 · R2 da §7.1 do plano v3 · achado pela revisão externa de 17/09 (§2.8 e §2.11)**

## O defeito, em duas metades

**(a) Os logs.** O Godot encerra com **0** depois de um erro — é a lição de
07/09, escrita no `CLAUDE.md` desde então. Por isso cada passo de CI que roda
`--script` exige o MARCADOR de sucesso em vez do código de saída. Só que o
marcador diz que a ferramenta chegou ao fim, e não que ela não se queixou pelo
caminho. Contados no workflow real em 18/09:

| Workflow | passos com `--script` | com guarda de erro |
|---|---:|---:|
| `testes.yml` | 9 | 6 |
| `balanceamento.yml` | 2 | 0 |
| `captura.yml` | 0 diretos — 16 execuções pelo `capturar_evidencia.sh` | 0 |

E os dezasseis logs da captura eram **apagados** no fim (`rm -f "$SAIDA"/*.log`),
depois de uma única pergunta: se a linha `(Tela|Folha) salva em` aparecia.

**(b) O avanço da captura.** `capturar_tela.gd` contava VOLTAS de laço, e o
`continue` da oferta do rival gastava uma sem virar o dia. E avançava por baixo
de modal: o botão "Avançar dia" do jogo fica debaixo do escurecer de todo
`PainelNarrativo` — um `ColorRect` a tela cheia, no `CanvasLayer` do Overlay —,
de modo que com um painel aberto o toque não lhe chega.

Medido nesta semente, e **maior do que o briefing previa**:

| Pedido | Turno entregue | Painéis | O que isso é |
|---:|---:|---:|---|
| `-- 10` | 9 | 0 | duas voltas comidas, não uma |
| `-- 12` | 11 | 1 | três dias avançados sob o Boletim |
| `-- 34` | 27 | **3** | sete voltas comidas, **três Boletins empilhados** |

## A decisão

**A guarda de erro é `SCRIPT ERROR` OU `at: push_error (` — e nunca `ERROR`.**

Isto não é gosto, é medição. Em corridas **verdes** do mesmo código, em 18/09:

- **cinco das seis suítes** e o simulador de 600 partidas encerram com
  `ERROR: 1 resources still in use at exit` — contabilidade de encerramento do
  motor, e no simulador ela sai **depois** do `=== Leitura ===`, que é
  literalmente o caso que a §7.1 manda reprovar;
- o `teste_fumaca` imprime ainda um `ERROR: Parse JSON failed` **de propósito**:
  é o save inválido que ele injeta para provar que o jogo o recusa.

Uma guarda por `ERROR` deixaria o CI vermelho em cinco passos verdes, um deles
por um teste a fazer exatamente o seu trabalho — o "validador que reprova o que
está certo" que o `CLAUDE.md` avisa que se gasta depressa.

⚠️ **E o prefixo não separa as classes.** Medido numa sonda: `push_error()` sai
como `ERROR:`, **não** como `USER ERROR:`. Ou seja, a queixa da própria
ferramenta — o `"captura: nao consegui comprar X"` que já mordeu aqui — tem o
mesmo prefixo do barulho do motor. O que as separa é a ORIGEM, escrita na linha
`at:`: só quem chamou `push_error` a traz. Fica de fora, deliberadamente, todo
`ERROR:` do motor sem rasto de GDScript — e isso está escrito ao lado da guarda.

**A lista de quem tem guarda deixou de ser escrita à mão.** Ela era, e foi por
isso que faltou em cinco passos: cada passo novo nascia sem ela. Hoje
`tools/conferir_guardas_ci.py` DERIVA a lista do workflow real e reprova quem
rode `--script` sem preservar a saída, sem marcador ou sem varredura. Corre
antes do download do Godot, porque custa um segundo.

**A captura avança por TURNO EFETIVO, pelo caminho do jogador, e pára diante do
modal.** `_main._on_advance_pressed()` em vez de `GS.advance_turn()`; `while
GS.turn < alvo` em vez de `for t in range(turnos)`; teto de voltas para
travamento; e, com um painel por cima, ou ele é de rotina e fecha como o
jogador o fecharia, ou o dia acaba ali. O menu de pausa abre **depois** de
jogar — estava antes, e os oito turnos daquele tiro corriam por baixo dele.

**E cada tiro declara em que turno pára**, ao lado de quantos painéis aceita.
São duas fontes: a ferramenta imprime onde parou, o `capturar_evidencia.sh` diz
onde devia parar.

## Por que a contagem de painéis não bastava

Ela existe desde que o `porto` saiu com o Boletim por cima, e conta o estado no
FIM. O mutante "avançar sob modal" mostrou o buraco: com ele, o tiro do boletim
chegou ao turno 13 **com 1 painel** — exatamente o número que a guarda velha
exigia. Só o turno declarado o apanhou.

## O que foi injetado, e o que reprovou

Sete mutantes, cada um sozinho, com controle positivo verde entre eles:

| # | Defeito | Quem reprovou |
|---|---|---|
| M1 | a decisão volta a consumir um avanço | `'porto' esperava parar no turno 11 e parou no 9` |
| M2 | avançar sob modal | `'boletim' esperava parar no turno 9 e parou no 13` — **com 1 painel** |
| M3a | `rm` dos logs depois da inspeção | `boletim.png ficou sem o log dela` |
| M3b | a ferramenta deixa de escrever o log | `'inicio' não deixou log nenhum` |
| M4a | `push_error` **depois** do marcador, saída 0 | a guarda de erro do `tirar()` |
| M4b | idem no `despejar_constantes.gd` | saída 0 + `CONSTANTES OK` presente, e a guarda nova reprova |
| M5 | passo de CI novo com `--script` e sem guarda | `conferir_guardas_ci.py` |
| M6a | `--script` sem `tee` nenhum | idem, "não preserva a saída" |
| M6b | indentação deslocada — amostra vazia | idem, recusa-se a aprovar o que não entendeu |
| M7 | a guarda existe **só no comentário** | idem — a varredura corta os comentários antes |

⚠️ **O portão novo reprovou o código certo à primeira, e isso foi o achado.**
A primeira versão pedia guarda de erro para todo arquivo `tee`ado num passo que
rodasse `--script`, e reprovou "Gravar partidas" por causa de `/tmp/leitura.txt`
— que é a saída do leitor em **Python**, onde uma exceção sai com código ≠ 0 e o
`set -e` apanha. Sair com zero depois de um erro é problema do Godot e **só
dele**; a regra passou a prender o `tee` ao comando que o produziu.

## O que mudou nas imagens

Cinco das dezasseis: `porto` e `docas` (turno 9 → 11), `pesca` (5 → 7),
`boletim` (11 → 9, que é o dia em que ele abre de verdade) e `pausa` (7 → 9,
com o menu aberto no fim em vez do princípio). As outras onze saíram byte a
byte iguais, e a bateria corrida duas vezes devolve os mesmos bytes. Nenhuma
arte mudou, nenhum `# TUNING:` foi tocado. **Olhar as cinco continua a ser o
gate A5, do Bruno.**

## O que ficou de fora, e por quê

- `captura.yml` continua sem `--script` direto e por isso não aparece na
  contagem do portão; quem o cobre é o `tirar()`, provado pelos mutantes.
- O resumo do `balanceamento.yml` continua a filtrar `ERROR`/`WARNING` antes de
  publicar. A guarda nova reprova o passo **antes** disso, e o arquivo cru vai
  no artefato — mas a filtragem em si é do R3, que reconcilia fonte operacional.
- A reconciliação dos três valores de balanceamento (100/79,5/31,0 contra
  100/80,2/37,3 contra 100/79,5/35,7) é o **R3**, e não se tocou nela.
