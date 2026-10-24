# Medições de 24/10 — a velocidade dos testes e as lacunas deles

A medição da `docs/decisoes/137`. Contêiner de 4 núcleos (Xeon 2,1 GHz,
15 GB), Godot 4.6.3, main `bf2eafe` para o catálogo e a amostra, `b0ae8ee`
(o #149 fundido) para a prova final. O CI foi lido nas corridas do GitHub
Actions dos PRs #148 e #149.

## Para onde vai o tempo

| O quê | Medido |
|---|---|
| arranque do Godot (`--quit`) | 0,82 s |
| `run_tests` / `teste_design` / `teste_fumaca` / `asset_validator` / `teste_audio` / `teste_registro` | 32,5 / 57,7 / 15,5 / 11,3 / 0,5 / 0,6 s — 118,1 s em série |
| as mesmas com `--fixed-fps 60` | 24,2 / 47,5 / 12,7 / 11,0 / 0,6 / 0,7 s — 96,6 s, as seis verdes |
| as mesmas com o sono do laço a zero (`low_processor_mode_sleep_usec=0`) | o F10 reprovou: conta frames, e cada frame passou a valer menos tempo |
| quatro `run_tests` ao mesmo tempo, quatro cópias | 35,0–36,0 s cada (contra 32,5 sozinho) |
| quatro `teste_design` ao mesmo tempo | 56,3–57,4 s cada (contra 57,7) |
| as seis suítes ao mesmo tempo, um `user://` cada, na mesma pasta (a cópia com as sondas de cobertura) | 55,9 s de parede, os seis marcadores, zero `SCRIPT ERROR` |
| o D35 (camiões em 5400 s de jogo) | 25 s do `teste_design`; o laço dos 2931 tweens acumulados custa 4,5 s (emparelhado, 2 voltas: 27,3/26,5 → 21,8/22,7); o resto é a lógica de trânsito do jogo |
| o T26 (24 partidas ao acaso) | 13,7 s do `run_tests`: metade é o jogo a andar, metade é gravar e reler o save a cada passo — que É a prova do invariante |

**CI, PR #148 (corrida 40023084082):** «Defeitos já provados» 90:06 para 158
mutantes (~34 s cada, o tempo da suíte que o reprova); «Godot headless» 8 min
(suítes 1:50, simulador 3:12, régua do boletim 1:11, âncoras 0:56); export
1:30; «Evidência visual» 18 min (8:26 o commit + 8:25 a base, em série).
**PR #149 (corrida 40043684224):** os 166 mutantes em 100,4 min.
Três corridas do `Testes` correram ao mesmo tempo (a da main e duas do #149),
cada uma com o catálogo inteiro.

## O catálogo em quatro cópias (`tempos_catalogo.json`)

Cada cópia é o repositório sem o `.git`, com o seu `user://`; o executor de
sempre corre dentro dela. Fatias em roda por suíte (`ferramentas/repartir.py`
é a primeira versão, por peso).

| Rodada | Reprovados pela guarda declarada | Godot somado | Parede | Núcleos usados |
|---|---|---|---|---|
| tempo real | 158 de 158 | 120,4 min | 30,8 min | 98% |
| `--fixed-fps 60` | 158 de 158, as mesmas guardas | 96,6 min | 24,8 min | 97% |

E quanto pouparia parar a suíte no instante em que a guarda declarada
reprova (o `t_guarda` de cada corrida): 33% do tempo de mutante em tempo
real, 24% com o passo fixo. **Não escolhido.**

## A bateria de fotos em paralelo

O mesmo script, `PARALELO=1` contra `PARALELO=4`, sobre a mesma árvore:
**107 de 107 fotos iguais ao byte**, zero `::error::` e `COBERTURA OK` nas
duas — e outra vez igual numa segunda corrida em paralelo. Tempo: 254 s em
paralelo com a máquina livre. A série correu ao mesmo tempo que a amostra
de mutação (771 s), e por isso não se compara com aquele número (`gerais.md`,
tempo emparelhado); no CI a série levava 8,4 min por lado. As duas primeiras
corridas saíram com código 2 com tudo verde: o trap de limpeza (abaixo, na
`137`).

## A seleção por diff, simulada nos últimos quinze PRs

Correr no PR só os mutantes cujo alvo ou suíte o diff toca: sete dos quinze
tocaram no workflow, no executor ou no `project.godot` e correriam tudo; nos
outros, de 0% a 94% do catálogo (o #149 correria 72 dos 166). Ganho
irregular, e a prova de um defeito indireto sairia do PR para depois do
merge. **Descartada.**

## A pesquisa (pela busca; as páginas não foram lidas, `063`)

- Runner `ubuntu-latest` de repositório público: 4 vCPU, 16 GB, minutos
  livres; 20 jobs simultâneos no plano gratuito; matriz até 256 jobs
  (docs.github.com, «Supported runners and hardware resources» e «Limits»).
- Stryker e PIT correm mutantes em paralelo, um processo por trabalhador; o
  Stryker avisa que a cópia dele não isola arquivos que os testes escrevem —
  aqui cada cópia tem o seu `user://`. O PIT corre só os testes que cobrem a
  linha mutada, que é o que o `reprova` do catálogo já faz por suíte.
- A literatura divide o custo da mutação em «fazer menos», «mais esperto» e
  «mais depressa» (revisão de Offutt et al.). Fazer menos — amostrar
  mutantes, podar testes — perde defeitos: Gopinath et al. («Mutation
  reduction strategies considered harmful») acham que nenhuma estratégia
  passa a amostragem ao acaso por mais de 5%; estudos de minimização de suíte
  medem perdas de quase nada a 88%.
- Fan-in da matriz por artefato, nunca por output de job (só a última
  fatia escreveria); a EdgeDB conta ter posto uma conferência final de que
  todo teste correu.
- `xvfb-run -a` concorrente pode escolher o mesmo número de tela (Debian
  521075).
- `--fixed-fps <fps>`: *«Force a fixed number of frames per second. This
  setting disables real-time synchronization»* — do `--help` do próprio
  4.6.3, este sim lido.
- Cobertura de GDScript: o addon conhecido (godot-code-coverage) é do 3.5;
  para o 4.6 escreveu-se um instrumentador de medição (`ferramentas/`).

## As lacunas

### Cobertura por função (`cobertura_funcoes.json`)

Numa cópia com uma sonda no início de cada uma das 757 funções dos 61
scripts do jogo, as seis suítes executam **741 (98%)**. As 16 que nenhuma
executa são quase todas toques do jogador: tocar na faixa de mensagem, na
fauna, no mar e na gaivota, fechar a tela de nomes; mais o «Construir» do
`Main` e quatro funções do `PainelNarrativo` que talvez sejam código morto.

### Mutação amostrada (`amostra_mutacao.json`)

209 defeitos sorteados com semente (`ferramentas/amostra.py`) nas funções
executadas — até três por arquivo, mais 27 nos seis arquivos de lógica
maiores —, cada um corrido contra as seis suítes, da mais rápida para a mais
lenta, até à primeira que reprova. Três caíram numa cena de teste e um não
compila: **205 válidos, 106 apanhados (52%), 99 passam nas seis**; descontados
os 15 equivalentes (mesmo texto, valores que não existem), **56%**.

Quem apanhou: `teste_fumaca` 48, `teste_design` 33, `run_tests` 22, os outros
três 1 cada. Por arquivo: os scripts de painel e de apresentação são os que
mais escapam; `FilaDeMensagens`, `NarradoraDaCida`, `TextoDaInterface`,
`PreferenciasDeApresentacao`, `VezDasTelas`, `DebtPaymentPanel` e
`PainelReputacao` apanharam os três.

| Sobreviventes | n | alta | média | baixa |
|---|---|---|---|---|
| visual fino (estilo, espaço, animação, ordem) | 47 | 1 | 13 | 33 |
| equivalentes | 15 | — | — | — |
| painéis: o que mostram e o que os botões fazem | 13 | 6 | 4 | 3 |
| lógica do jogo | 7 | 2 | 3 | 2 |
| preferências, acessibilidade e toque | 7 | 3 | 3 | 1 |
| telemetria do playtest | 3 | — | 3 | — |
| som | 3 | 1 | — | 2 |
| texto; não exercido em headless | 1; 3 | — | 1; 1 | —; 2 |

**As treze de gravidade alta**, cada uma um defeito que passa verde hoje:

| Defeito | O que se veria |
|---|---|
| `GameState.gd:1784` apagar | atender um barco deixa de subir a reputação |
| `GameState.gd:1048` `not` tirado | no arranque, o save que carrega é trocado por partida nova |
| `PainelCaixa.gd:90` `!=` → `==` | o bloco «Entrou» só aparece com receita zero |
| `PainelCancelarServico.gd:50` apagar | o botão de confirmar o cancelamento some |
| `PainelCancelarServico.gd:57` `true` → `false` | confirmar duas vezes cancela duas vezes |
| `PainelMeta.gd:11` apagar | a meta antes da Fase 2 abre sem botão de fechar |
| `PainelParcela.gd:98` apagar | a parcela com falta abre sem botão de fechar |
| `DocaCartao.gd:115` apagar | o cartão da doca não mostra o valor do barco |
| `PainelAjustes.gd:61` `==` → `!=` | os rótulos Padrão e Maior trocam de lugar |
| `Audio.gd:198` apagar | o volume escolhido não é gravado |
| `RolagemDaOperacao.gd:34` `==` → `!=` | o arrasto com um dedo deixa de rolar a operação |
| `AmbienteCosteiro.gd:26` apagar | mar e gaivota nunca tocam |
| `BarcoFila.gd:195` `>` → `>=` | a escala dos cascos fica 0, e os barcos ao largo somem |

O passo do simulador no CI só confere que ele chega ao fim, não as taxas: a
reputação que não sobe passaria também lá. Os defeitos visuais mudam as
fotos do «Evidência visual» do PR, que diz «mudou» — mas isso pede alguém a
olhar, e não reprova.

**O padrão:** a lógica que as suítes perguntam está guardada; o que escapa
é o que os painéis MOSTRAM e o que os botões FAZEM (as suítes perguntam se o
painel abre e cabe), as preferências que se gravam, o som que se agenda e a
telemetria do playtest.
