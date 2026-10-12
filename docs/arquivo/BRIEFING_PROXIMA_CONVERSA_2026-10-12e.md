# BR Port — briefing para a próxima conversa (12/10/2026, e)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e as
decisões 103 e 104.

Confira na main pelo GitHub se o PR #128, da decisão 104, foi fundido
(branch claude/eager-gates-86k750: a passagem para a Fase 2, o save 16 com o
M9, o T20 e o F23) e se há PR aberto do Codex antes de editar. A última decisão é
a 104; confira o próximo número livre na main.

A frente 5 segue pela progressão para a Fase 2 (103), etapa 2: a treliça e o
cargueiro. A compra da treliça na Fase 2 (o nível 2 do guindaste, que hoje só
a bancada monta, 086), o nivel_maximo da Fase 2 a subir para 2 junto com ela
(o F20 confere o declarado contra o alcançado), o porto de nível 2 e o
cargueiro de dois dias no jogo, com a arte das bancadas e a captura de uma
partida jogada até lá. Preços e dias de obra provisórios até à etapa 4. Pede
Opus para o preço provisório e a abertura da treliça; o resto é receita. Se
o Bruno já tiver lido as falas do A4 (três do Toninho, duas do Sr. Ribeiro),
aplique as notas dele primeiro. Um item só.
```

A etapa 1 fechou (`104`): as três quitações passam à Fase 2 no dia 85, no
mesmo save; a página do diário da Fase 1 abre por cima e sai por «Seguir
para a Fase 2»; a Fase 2 joga-se livre, sem meta, com o píer 3 e o escritório
abertos desde o primeiro dia dela. O simulador mede a Fase 1 e pára na
passagem.

⚠️ A fase sem prazo rebenta a quem lhe pedir a duração: pergunta-se antes
pelo `fase_tem_prazo()`, e a parcela corrente pelo `tem_cobranca()`
(`economia.md`, «Os números de cada fase»).

⚠️ Um erro numa função tipada devolve o zero do tipo e não reprova asserção
nenhuma — só o `SCRIPT ERROR` na saída o denuncia, e o CI reprova-o
(`gdscript.md`).

⚠️ O sinal `fase_concluida` sai antes de a fase mudar; quem o ouve lê a Fase
1 que fecha (`104`).

O cargueiro paga o adicional de contêiner do pátio (`103`), e a treliça é o
que o destrava: o simulador continua cego a isso até à etapa 4.

Ficou anotado na `104` um achado anterior a ela: a faixa abre com «Um píer de
pé e o resto por levantar» também numa partida retomada com dois píeres.
