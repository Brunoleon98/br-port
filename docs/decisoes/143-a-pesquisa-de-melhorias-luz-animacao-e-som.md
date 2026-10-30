# 143 — A pesquisa de melhorias: luz, animação, som e o resto

**29/10/2026 · o primeiro tempo do bloco que o Bruno escolheu nesse dia**
(§7): pesquisar, aprofundar cada tema numa conversa própria, e só então
implementar, um item por conversa. Main `d310922` (PR #154, a `142`), CI
verde nos três workflows desse merge, nenhum PR aberto. A branch
`claude/br-port-continuacao-72yq7v` tinha dois commits só de documento por
fundir (os tempos das fatias do #154 na `142` e o registo do bloco na §7);
perguntado se abria o PR dela, o Bruno respondeu **«levar junto no PR da
pesquisa»**, e esta branch arranca da cabeça dela (`5e8b983`). 143 livre
pelo `tools/conferir_colaboracao.py`. **Nenhuma linha de jogo mudou.**

## O que se mediu antes de pesquisar

O documento é `docs/PESQUISA_MELHORIAS_2026-10-29.md`; o essencial:

- **Luz:** zero nós de luz e nenhuma hora do dia — é meio-dia sempre. A luz
  está cozida no rig de três pontos do Blender e nas faces pintadas do SVG;
  a única luz viva são 16 lâmpadas de sódio a bater de dia. O HUD e o mapa
  partilham o canvas, e o `+R$` vive dentro do `MapaWrap`.
- **Animação**, por uma sonda fora do repositório (semente 12345, 60 fps
  fixos, 20 s parado e duas viradas): de 310 a 318 nós visíveis, 123 a 136
  mexem — mata, coqueiros, água, barcos (os atracados também, 5 px em
  1,7 s), camiões, lanças, empilhadeira e fauna. Parados: a vila, as
  estruturas, os carros, a carga e o rolar do casco. Ao atracar, o barco
  entra no berço pelo lado do mar (`RUMO_DO_MAR`, `078`), e não do lugar ao
  largo onde foi tocado. Tudo é tween; nenhuma partícula.
- **Som:** os 14 rascunhos, `SINAL OK`, seis sobretudo abaixo de 500 Hz;
  sem música, variação, posição nem ambiente por zona. O A6 continua dele.
- **O resto:** nenhuma háptica; o «Pausar» no canto de cima; o berço que um
  toque enche distingue-se só pela cor; `playtest/` sem partida humana.
- **Desempenho** (`medir_desempenho.gd`): 405,7 chamadas de desenho e 99
  tweens na abertura, contra 273 e 20 na `099`, com 225 → 386 nós.

## A pesquisa

Pela ferramenta de busca; **nenhuma página foi lida**, e cada fonte fica
citada como pista de padrão (`gerais.md`, Ambiente). Os números de terceiros
não foram conferidos. O custo de cada técnica é julgamento a partir do
código, e o ganho é hipótese até ao gate do tema (A5, A6 ou A7).

## O que ele escolheu

| Pergunta | Resposta |
|---|---|
| O PR dos dois commits só de documento | Levar junto no PR da pesquisa |
| Que temas aprofundar | **Animação e toque** (a recomendada) |
| Por que ordem | **Animação → Luz → Som → resto** (a recomendada) |

Escolheu um tema, e a ordem diz o que vem depois dele. **A conversa da
animação é a única aberta agora**; a luz, o som e o resto abrem-se quando
ele os pedir, por essa ordem, e não por omissão.

A conversa do tema lê a pesquisa, aprofunda A1 (o retorno ao toque), A1′
(o barco que desliza do largo ao berço, que a `083` deixou para depois), A3
(o casco que rola) e T1 (a háptica), desenha a implementação com a medição
antes e depois, e **só implementa depois de ele aprovar** — arte pela
`/arte`, uma entrega por conversa.

## O que se aprendeu a medir

- **A primeira corrida da sonda não atracava**, e o barco atracado não
  aparecia entre o que mexe: quase se escreveu que ele está parado. Com os
  barcos atracados antes da janela, ele balança 5 px em 1,7 s e a
  empilhadeira anda. É «percurso responde pelo que se vê» (`gerais.md`): a
  sonda só mede o que o estado montado tem, e a pergunta é que estados ela
  NÃO monta.
- **A pergunta ao Bruno dizia que o atracar «não tem gesto», e tem um.**
  A janela parada da sonda não corre nenhuma troca de barco, e a leitura
  saiu daí; o `Dock.gd` faz o barco entrar pelo `RUMO_DO_MAR` desde a
  `078`. O que falta é o percurso do lugar ao largo até ao berço, que é o
  A1′ — e a escolha dele não dependia da frase. Corrigido no documento
  antes do commit.
- **O tiro de painel a 1080 reprova a prova das caras.** O boletim de
  `-- 12 … completo` a `--resolution 1080x1920` saiu com *«retrato_cida_seria
  não chegou à foto: 0 px mudam ao escondê-la (mínimo 4695)»*; o mesmo tiro
  a 720 é o `boletim` da bateria, verde na Captura do merge do #154. A causa
  não se apurou, e as fotos de jogo a 1080 (sem painel) saem limpas.

## Fora desta decisão

A luz 2D com normal map (L4) e a gente na vila (A5), pelo custo; a música
(S5), pela licença; o ritmo (R1), até ao A7. A hipótese do lote partido pelas
máscaras por instância (D1) fica escrita e por medir.
