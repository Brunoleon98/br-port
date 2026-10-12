# BR Port — briefing para a próxima conversa (12/10/2026, d)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
decisão 103.

Confira na main pelo GitHub se o PR da decisão 103 foi fundido (branch
claude/vigilant-allen-9tclo6: só documentos — a 103, a §5 e a §7 do plano, o
estado e a D1b da revisão de 09/10) e se há PR aberto do Codex antes de
editar. A última decisão é a 103; confira o próximo número livre na main.

A frente 5 segue pela progressão para a Fase 2 (103), etapa 1: a passagem e
o save. A segunda linha da FASES (sem parcelas, sem prazo, nivel_maximo 2,
os três berços, o píer 3 e o escritório; a treliça é a etapa 2), o número
da fase no save (16, com o degrau 15→16 que escreve 1, o v16.json jogado até
à Fase 2 e o v15.json intacto), o M9 na mesma subida (saem o
upgrade_purchased e o buy_upgrade(), os estados de turno viram constantes),
a página do diário da Fase 1 a seguir para a Fase 2 no dia 85, e a Fase 2
jogável sem meta. O simulador continua a medir a Fase 1 e pára na passagem:
a prova é a paridade com a main. Preços da Fase 2 provisórios até à etapa 4.
Pede Opus: mexe no SAVE_VERSION e traz asserção nova. Se o Bruno já tiver
lido as falas do A4 (três do Toninho, duas do Sr. Ribeiro), aplique as notas
dele primeiro. Um item só.
```

O Bruno escolheu a progressão para a Fase 2 (`103`): as três quitações
abrem-na no dia 85, sem dívida e sem prazo, com o píer 3, o escritório e a
treliça; a meta são três barras (reputação três dias acima de um patamar,
píer 3 e treliça de pé, o primeiro cargueiro atendido), e cumpri-la fecha a
fase no diário e deixa o jogo seguir livre. Perde-se só pelo caixa, e a
reputação abaixo de um piso faz os cargueiros deixarem de vir. São quatro
etapas, uma por sessão.

⚠️ A fase sem prazo é o grosso da etapa 1: a duração é lida em 74 sítios de
15 arquivos (`turnos_da_fase()`, `semanas_da_fase()`), e o F20 exige o campo
(`103`, «As etapas»).

⚠️ Subir o save pede, no mesmo commit, o degrau, o exemplo da versão nova
jogado até ter os campos dela cheios e o da anterior intacto
(`.claude/rules/save.md`).

A pressão sem dívida foi escolha do Bruno contra a recomendação (um crédito
novo em parcelas). Se a medição da etapa 4 mostrar todo perfil a cumprir a
meta sem risco, a pergunta volta a ele com o número.

As falas do A4 continuam por ler, e a progressão vai trazer mais: a
passagem, a missão e a página da Fase 2.
