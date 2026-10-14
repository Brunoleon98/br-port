# 105 — A treliça e o cargueiro na Fase 2: a etapa 2 da `103`

**14/10/2026.** Base `d9848ed` — PR #128 (`104`), da branch
`claude/eager-gates-86k750`, fundido no GitHub em 12/10. Nenhum PR aberto,
105 livre na main. O Bruno ainda não leu as três falas do Toninho e as duas
do Sr. Ribeiro (A4); não havia notas a aplicar. Pediu um item: a etapa 2,
com os preços e prazos provisórios até à etapa 4. Ao conferir que não havia
preço próprio da treliça no projeto, pediu **criar e testar valores
balanceados**.

## A compra e a abertura

A **treliça** é uma estrutura nova (`trelica`), comprada no Construir:
**R$80.000 e dois dias de obra**, uma obra por vez, paga inteira ao iniciar.
Abre no primeiro dia da Fase 2, o dia 85; pede o **píer 2 pronto**. Essa
condição garante que sua conclusão também dá a segunda estrutura que o
`nivel_pier()` já exigia: píer e guindaste chegam a 2 juntos. Não se inventou
outro nível, nem se mudou a regra da madeira na Fase 1 (`086`).

Antes de concluir, o guindaste continua em madeira e o porto só recebe
pesca. Depois, `nivel_guindaste()` lê a estrutura pronta, e o
`nivel_do_porto()` abre o cargueiro. O `nivel_maximo` da Fase 2 sobe **com
a compra alcançável** de 1 para 2; o F20 confere os dois lados. Pórtico e
cais continuam bloqueados, para a Fase 3.

A treliça **não corta o tempo de operação**. O cargueiro com armazenagem
ou contêiner leva dois dias; o de granel, três, pelo adicional já existente
(`008`, `009`). O Construir explica ambos, lendo os prazos do motor. O
pátio passa a ter clientes para seu adicional de contêiner. Os PNGs e os
quadros de animação são os já aprovados das bancadas (`077`); nenhuma arte
foi repintada.

## Os valores provisórios, medidos

`tools/medir_trelica.gd` joga desde o dia 1, sem inventar saldo ou porto na
passagem. Reusa as escolhas, negociações e folgas dos quatro perfis do
simulador. Na Fase 2, a ordem é píer 2, pátio, armazém, treliça, píer 3,
escritório; a compra da treliça vem antes da expansão seguinte. A régua
observa **56 dias da Fase 2**, com **600 partidas por perfil em cada preço**,
semente 20260825. Os dias até a treliça são contados desde o dia 85;
quantis P10/P50/P90 e tamanho da amostra estão em
`docs/arquivo/MEDICOES_TRELICA_2026-10-14.json`.

| Preço testado | Ótimo / Mediano / Antecipado: treliça e cargueiro | Descuidado | Quebras, todos os perfis |
|---|---|---|---|
| R$40.000 | 600/600 em cada; treliça no dia 87 | 0/600 no intervalo | 0 |
| R$60.000 | 600/600 em cada; treliça no dia 87 | 0/600 no intervalo | 0 |
| **R$80.000** | **600/600 em cada; treliça no dia 87** | **0/600 no intervalo** | **0** |
| R$120.000 | 600/600 em cada; treliça no dia 87 | 0/600 no intervalo | 0 |

**A leitura não escolhe um preço único.** Dentro desse intervalo o acesso
dos três perfis que reconstruíram o porto não muda; o menor preço também
não resolve a demora do Descuidado. Escolheu-se **o maior preço testado
abaixo do pórtico de R$120 mil**, preservando a hierarquia provisória dos
dois equipamentos, sem atrasar a primeira operação dos demais perfis. Os
dois dias seguem os reparos pequenos; esse prazo, como o preço, volta à
etapa 4 com a meta completa.

No preço escolhido, o primeiro cargueiro atendido tem P10/P50/P90 de
**3/3/5 dias** desde a abertura da Fase 2 nos três perfis. O Mediano compra
com caixa restante **R$364.732 / R$445.162 / R$510.170**; seu menor caixa
durante a janela, incluindo os gastos imediatos de obra, é
**R$244.938 / R$268.653 / R$284.696**. O Descuidado termina a janela com
**R$189.855 / R$238.760 / R$283.255**, mas sua folga de 4× exige **R$600 mil
para o píer 2** antes da treliça: é o gargalo, não o preço deste equipamento.

**Não se certificou o balanceamento de toda a Fase 2.** A meta, seu piso
de reputação e o fim ainda não existem. A janela não mede o tempo até a
meta, nem garante acesso do Descuidado depois dela. A ausência de quebras
e a folga dos saldos são evidência da falta de pressão deste recorte,
não autorização para acrescentar dívida ou mexer nos preços da Fase 1.

### A régua viu uma diferença conhecida

Controle de **20 partidas por perfil**, com R$400 mil, semente igual à
rodada curta de partida: a treliça do Mediano deixa o dia 87 e passa a
esperar novas receitas (por exemplo, 38 dias desde a abertura na primeira
partida); no Ótimo continua no dia 87. É controle positivo da régua,
**não** amostra para escolher preço. Um preço do intervalo que não muda o
acesso já não se confunde com uma régua que nunca compra nada.

## Save, guardas e fotografia

A Fase 1 manteve paridade com a base: 600 partidas por perfil, semente
20260825, **zero diferenças em 704 valores**. O catálogo acrescenta oito
contagens de `trelica`, todas zero (duas por perfil); não são compras
liberadas na Fase 1. O projetor das parcelas continua calibrado. As seis
suítes, a tabela dos números, o escopo de UI e as guardas do CI passaram;
a sentinela dos cinco arquivos do jogador ficou intacta.

O save continua na **16**. Não há campo novo, nem nova interpretação de um
estado antigo: a lista de estruturas prontas e a obra já guardavam IDs;
os saves de exemplo 14–16 ficam intactos. O T21 prova a treliça em obra,
pronta e o cargueiro no segundo dia, com ida e volta pelo save.

O **T21** compra pela porta real e confere bloqueio na Fase 1, abertura,
pré-requisito, pagamento único, conclusão, nível, classes, arte do nó real,
cargueiro sorteado e sua operação. A bandeira no fim prova que o bloco
correu. Defeitos injetados isoladamente, com base verde entre eles:

| Defeito | Quem reprova |
|---|---|
| treliça sem promover o nível | T21: nível, classes, save e arte |
| nível 2 ainda em obra | T21: benefícios antes da conclusão |
| cargueiro reduzido a um dia | T21: duração e barco ainda no píer após um dia |
| treliça aberta na Fase 1 | T21: bloqueio por fase |
| treliça pronta perdida no load | T21: nível e classes após carregar |
| píer de madeira no nível 2 | T21: textura do nó real |
| `nivel_maximo` da Fase 2 ainda em 1 | F20: declarado 1, alcançado 2 |

O mutante da abertura passou à primeira: a compra era recusada pelo
pré-requisito do píer, mesmo com a fase liberada. A guarda passou a perguntar
também pelo **desbloqueio da fase**, e o mesmo defeito reprovou. Não se
afrouxou nenhuma guarda existente.

`capturar_fase_2.gd` joga desde o dia 1, com a semente 20260902, tocando os
painéis e avançando pelo botão do Main; não avança com modal por cima. No
**dia 91**, com três píeres, treliça pronta e **dois cargueiros atendidos**,
fotografa outro no segundo dia de operação. O caixa é **R$351.112**, sem
injeção. Confere a ausência da meta de bancada e os 720×1280 pixels. A
bateria do CI ganha a foto do porto e do Construir. Ambas foram olhadas;
o cartão inteiro cabe na tela. Evidência em
`docs/arquivo/EVIDENCIA_TRELICA_2026-10-14/`.

## O que fica para a próxima etapa

A **etapa 3 da `103`**: painel das três barras, reputação por três dias,
primeiro cargueiro como missão, piso de regressão e página do diário que
fecha a Fase 2. A etapa 4 fecha os preços e prazos com essa meta. A4
continua à espera do Bruno.
