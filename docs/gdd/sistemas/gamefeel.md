<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# ✨ Feedback & Game Feel

Para cada ação do jogador: o que aparece na tela, o que toca, e o que o mundo faz. Sem isso, o jogo parece morto mesmo com arte boa.

## 🎯 Ações principais → resposta imediata

**Docagem concluída** — Moedas voam da doca até o contador de caixa no HUD (animação de arco, 0.6s). Número verde sobe e dissolve (+R$ valor). SFX: dois tons ascendentes em terça maior (sino + cavaquinho). Nenhuma dessas animações bloqueia input — o jogo continua.

**Contrato aceito** — O rosto do cliente pisca satisfeito por 1 frame. Um ícone de documento aparece no HUD com o prazo. SFX: clique de madeira seco. Sem fanfarra — contratos são rotina, não conquista.

**Construção iniciada** — Zezão aparece no tile com animação de trabalho (martelo ou serrote, 4 frames em loop). Partículas de poeira saem do tile. SFX: som de construção em loop suave enquanto Zezão estiver trabalhando.

**Construção concluída** — Faíscas/confete por 1.5s no tile. Banner flutuante '✔ Pronto!' dissolve em 2s. SFX: sino final + zabumba 1 acorde. Versão ampliada se for marco de fase (ver transição de fase).

**Ação bloqueada / erro** — Elemento que recebeu o tap faz shake de 3px por 0.3s. Borda vermelha flash 1 frame. SFX: tom descendente grave, madeira batendo, nunca agressivo. Nenhuma tela de erro — só o elemento sacudindo.

**Rival age (Arlindo)** — Ícone do Rivalômetro pulsa 3× no HUD. Linha discreta aparece no log do dia: '← Arlindo fechou o contrato da Praia Grande.' Sem animação dramática — a perda é notada, não dramatizada.

## 🔁 Feedback de estado (passivo, sem input)

**Estrutura com saúde baixa** — Overlay progressivo: >70% normal, 30–70% rachaduras + dessaturação, <30% fumaçinha + ícone vermelho piscando no tile. Funciona como leitura visual antes de qualquer alerta de texto.

**Funcionário ocioso** — Sprite do funcionário faz idle alternado (cocôco a cabeça, mexe os pés) com ciclo mais lento. Não há indicador de texto 'sem tarefa' — a leitura é visual. Um funcionário parado parece parado.

**Barco esperando fila** — Balanço suave ±3px + fumaça de motor em idle. Timer visual com contagem regressiva aparece após 30s de espera. Se app estava fechado, barco volta na posição de idle sem timer — sem punição visual.

**Caixa caindo (nível 2 em diante)** — Contador de caixa muda de verde → amarelo → laranja conforme a cascade de falência. Não pisca — muda de cor progressivamente. O jogador percebe a degradação gradual, não um alarme binário.

## 🎬 Transições que têm peso

**Virada de fase** — Flash branco 1 frame → porto ilumina da esquerda para a direita → 2–3 tiles novos aparecem → protagonista para e olha horizonte (idle especial 2s) → fade para tela estática 'Fase X — [nome]' com arte-chave. Duração total: 5–8s. Não pulável na primeira vez.

**Abertura do app após ausência** — Boletim do dia aparece sobre o porto com overlay semi-transparente. 3 itens máximo. O porto é visível ao fundo — o jogador está de volta ao espaço, não numa tela de menu.

**Diálogo de NPC importante** — Portrait box 96×96px aparece no canto inferior. Texto em fonte sans-serif (Inter ou Nunito OFL), 14px. Sem animação de entrada dramática — aparece rápido, como se o NPC simplesmente falasse. A pausa vem do conteúdo, não do efeito visual.

## 🔕 O que nunca acontece

**Sem números flutuando durante ações neutras** — Números só flutuam quando há ganho ou perda real. Ações de organização (mover trabalhador sem contrato ativo, rotacionar estrutura) são silenciosas.

**Sem tela de loading visível** — Transições entre seções do porto usam fade rápido (<0.3s). Se o carregamento demorar mais, a tela do porto aparece primeiro e os elementos carregam progressivamente — nunca um spinner bloqueando tudo.

**Sem confirmação dupla em ações reversíveis** — Aceitar contrato: sem 'tem certeza?'. Alocar trabalhador: sem 'confirmar'. Só construção e demolição têm confirmação — e só porque têm custo econômico real e a demolição de construção herdada do avô tem custo narrativo permanente.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
