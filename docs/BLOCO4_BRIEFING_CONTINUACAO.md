# BR Port — Briefing para continuar o Bloco 4

> Documento de entrada para a próxima conversa. Escrito em 28/08/2026, ao fim
> da sessão que abriu o Bloco 4.
>
> **Leia este arquivo primeiro, depois `docs/ESTADO_DO_PROJETO.md`.**
> Existe para não repetir perguntas já respondidas nem refazer decisões já
> tomadas — em especial a de direção de arte, que oscilou três vezes e agora
> está fechada.

---

## 1. Onde o jogo está

**O mapa do porto é a tela do jogo.** `Main.tscn` roda com:

- Barra de HUD em pílulas: caixa, dia, reputação, docas construídas
- Mapa visto de cima ocupando a maior parte da tela
- **Três vagas fixas** sobre os píeres, alimentadas por `GameState.docks`
- Fileira de trabalhadores para arrastar até uma doca
- Painel de mensagem e barra da parcela do Sr. Ribeiro

A terceira vaga mostra **estacas velhas sob contorno tracejado** até o jogador
comprar "Ampliar píer" — o upgrade acontece no mapa, não numa lista.

**A economia não mudou**: 2 docas iniciais + 1 upgrade, como o Bloco 3 mediu.
33 asserções passando. PR: https://github.com/Brunoleon98/br-port/pull/5

---

## 2. A decisão de arte — fechada, não reabrir

Ela oscilou três vezes nesta sessão. O histórico importa para não voltar:

| Rodada | Decisão | Por que caiu |
|---|---|---|
| 1 | 3/4 ilustrado, para casar com os 5 PNGs recebidos | Sobre um mapa topo-down virou erro de perspetiva |
| 2 | Vetor chapado topo-down (volta ao GDD) | O Bruno escolheu o ângulo dos mockups |
| 3 | **Isométrico** ✅ | — |

**Decisão vigente: isométrico.** Divergindo do GDD, que congela "Flat Design
2D". A justificativa é que o Bruno escolheu explicitamente esse ângulo depois
de ver os dois protótipos lado a lado.

### Mas o jogo ainda NÃO é isométrico

O que roda é **vetor chapado topo-down**. O isométrico existe só em
`scenes/proto/MapaIso.tscn` — protótipo sem lógica, não carregado pelo jogo.

**O que bloqueia a migração:** os sprites existentes foram gerados deitados, e
num plano isométrico **nenhum eixo é horizontal** (ambos saem a 26,6°). Eles
ficam atravessados em cima de qualquer píer. Rotacionar em Godot é paliativo —
a perspetiva e a luz estão assadas dentro da imagem.

Ou seja: **migrar exige regerar os assets primeiro.** Não dá para integrar o
isométrico com o que existe hoje.

---

## 3. O que fazer a seguir — três caminhos

### A) Gerar os assets isométricos (o caminho da direção escolhida)

`docs/BLOCO4_PROMPTS_ISOMETRICO.md` é o documento corrente, com prompts prontos
e um checklist de cobertura no fim. A §0 trata só de **orientação**, que é o
erro que derrubou os sprites atuais.

Ordem sugerida no próprio documento: 3 barcos → píer nos dois estados →
Arlindo (3 expressões) → os 17 ícones → coqueiro → galpão.

Depois de gerar: `python3 tools/preparar_sprites.py <pasta> brport_vs/art/sprites`
e conferir que a coluna `fundo` diz **`sólido`**.

### B) Fechar a interface sem esperar arte nova

**17 ícones ainda são emoji.** São vetor chapado, não isométricos — e oito já
estão desenhados, esperando aprovação:
https://claude.ai/code/artifact/922a5018-28ff-432f-9d6d-011c7a93fe1f

Aprovar e gravar como `.svg` em `brport_vs/art/icones/` fecha a camada de UI
sem depender de gerador nenhum. É o maior ganho por esforço disponível hoje.

### C) Resolver o píer de 1 a 3 (mexe na economia)

Ideia do Bruno, adiada de propósito: começar com **1 doca** e construir até 3,
em vez de 2 + upgrade único.

O que exige em código:
- `upgrade_purchased` vira contador; limite passa a ser `docks.size() < 3`
- O mapa já tem as 3 vagas desenhadas — não precisa de arte nova
- O botão some ao chegar em 3

**O aviso:** começar com 1 doca corta a vazão inicial pela metade, contra uma
renda de píer que é fixa (R$240/semana). Os números do Bloco 3 (99,7% / 63,8%
/ 0,7%) **deixam de valer**. E há uma pergunta de design junto: com 1 doca, os
2 trabalhadores iniciais custam R$200/semana e só um trabalha.

Antes de codar, decidir: custo por píer e quantos trabalhadores iniciais.
Depois medir com `tools/simular_balanceamento.gd` — ele é determinístico por
semente, então dá para comparar antes/depois sem ruído.

---

## 4. Ferramentas que já existem (não refazer)

| Ferramenta | O que faz |
|---|---|
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs gerados por IA e redimensiona. Detecta sozinho fundo quadriculado ou magenta chapado. **Rodar a cada leva nova.** |
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo. Mudar o ângulo = mudar duas constantes e regerar. |
| `brport_vs/tools/simular_balanceamento.gd` | Roda N partidas com 3 perfis e mede a dificuldade. Determinístico por semente. |
| `brport_vs/tools/capturar_tela.gd` | Salva um PNG do jogo rodando, sem abrir o editor. **Usar a cada mudança visual** — teste verde não prova que ficou bonito. |

Para rodar o Godot nesta sessão foi usado o binário 4.6.3 em `~/godot-bin/`,
com `xvfb-run` para as capturas.

---

## 5. Armadilhas descobertas (medidas, não supostas)

1. **PNG gerado por IA não tem alpha.** Pedir "fundo transparente" faz o modelo
   *desenhar* um quadriculado cinza. Peça **magenta chapado `#FF00FF`**.

2. **A caixa de um plano isométrico é sempre 2:1.** Vale para qualquer formato
   de terreno. Em 720 de largura, o chão nunca passa de 360 de altura — por isso
   todo mockup isométrico de porto é quadrado. A saída é gerar o mundo maior que
   o ecrã e cortar.

3. **Costa reta empurra as docas para o lado.** Como `tela_x` depende de
   `(mx - my)`, docas espaçadas ao longo de uma costa reta saem do ecrã retrato.
   A costa precisa ser em degraus, com `Δmx > Δmy / 3`.

4. **Ícone de HUD não é isométrico.** É interface: silhueta chapada, legível a
   19px. Colar o bloco de estilo isométrico num prompt de ícone devolve borrão.

5. **Animação não se pede ao gerador.** Barco balançando, chegando, doca
   pulsando — tudo é `Tween` sobre sprite existente, zero arte nova. O que
   precisa de arte é **anatomia separada pelo eixo que se move** (copa e tronco
   do coqueiro em arquivos distintos, por exemplo).

---

## 6. Pendências herdadas (não são do Bloco 4)

- **Parcelas 2 e 3 (R$16.000 e R$24.000) nunca foram verificadas.** Ver
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. Checar antes de codar a
  economia da Fase 2.
- **A reputação não afeta nada** mecanicamente, só o rótulo na HUD.
- **A derrota por caixa negativo é código morto** — o píer sozinho paga os
  custos, então a única forma de perder é a parcela.
- **Zona de Espera é só visual.** Os barcos ancorados são decorativos. Torná-la
  mecânica muda o balanceamento medido.

---

## 7. Como abrir a conversa nova

Cole isto:

> Continuando o BR Port. Leia `docs/BLOCO4_BRIEFING_CONTINUACAO.md` e depois
> `docs/ESTADO_DO_PROJETO.md`. A direção de arte já está decidida (isométrico)
> e não precisa reabrir.

E diga qual dos três caminhos da §3 quer seguir.

---

*BR Port · Briefing de continuação do Bloco 4 · Fase 4*
