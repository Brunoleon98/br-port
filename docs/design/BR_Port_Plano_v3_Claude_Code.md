# BR Port — Plano v3: o projeto refeito para ser tocado com Claude Code

**Versão 3.0 · 30/08/2026**
**Enxuto em 10/10/2026** (M5 da revisão de 09/10, `docs/decisoes/092`): o que
fechou desceu, título a título, para `docs/arquivo/PLANO_V3_FECHADOS.md`, e
aqui fica o que está aberto. A fila em vigor é a da §7.
**Substitui o cronograma do Roadmap v2.1 (Fases 4–7) e o Plano de Produção da
Fase 2 inteiro.**

> **O que continua valendo dos documentos antigos, e não se reabre aqui:** as
> nove decisões de design fechadas na Fase 1 do roadmap, o escopo do VS
> congelado no GDD 7 (telas IN, sistemas IN, assets), a lista do que fica FORA
> e os critérios de conclusão do VS.
>
> **O que este documento joga fora:** a conta de horas, o cronograma de 44
> semanas, a estrutura da semana de trabalho e a ordem dos cinco blocos. Foram
> escritos para um produtor que não é mais quem produz.
>
> **O GDD 7 continua congelado.** Este plano diz em que ordem construir o que
> ele já mandou construir — não acrescenta escopo de jogo.

---

## Índice

1. [Por que refazer](#1-por-que-refazer)
2. [A unidade de planejamento é a sessão](#2-a-unidade-de-planejamento-é-a-sessão)
3. [Os quatro gargalos humanos](#3-os-quatro-gargalos-humanos)
4. [As duas trilhas](#4-as-duas-trilhas)
5. [Trilha A — o jogo](#5-trilha-a--o-jogo)
6. [Trilha B — o projeto e o Claude](#6-trilha-b--o-projeto-e-o-claude)
7. [A fila](#7-a-fila)
8. [Critérios de avanço de fase](#8-critérios-de-avanço-de-fase)
9. [Riscos deste modo de trabalho](#9-riscos-deste-modo-de-trabalho)
10. [O que continua fora](#10-o-que-continua-fora)
11. [O que muda amanhã de manhã](#11-o-que-muda-amanhã-de-manhã)

---

## 1. Por que refazer

O plano antigo não estava mal escrito. Estava calibrado para uma premissa que
não existe mais: *"dev solo iniciante em Godot, 8h/semana, aprendendo no
caminho com apoio de IA"*. Vale a pena olhar a diferença de frente, porque ela
é o argumento inteiro deste documento.

| Bloco | O que o Plano da Fase 2 previa | O que aconteceu |
|---|---|---|
| 1 — setup + curva de Godot + frontload | 6 semanas · ~48h | Não existiu. Não há curva de aprendizado para quem já sabe Godot |
| 2 — loop core com placeholder | semanas 7–16 · ~80h | 24/08 — um dia |
| 3 — marco intermediário | semanas 17–19 · ~24h | 25–26/08, e com uma medição de 600 partidas por perfil que o plano nem imaginava existir |
| 4 — arte, áudio, integração | semanas 20–34 · ~120h | 27–30/08, quase todo |
| **Somado** | **28 semanas · 224h** | **sete dias de calendário** |

Três razões, e só uma delas é "IA escreve código depressa":

1. **A produção virou geração por script.** O mapa, os props, os ícones e os
   14 efeitos de som são saída de programa, não desenho feito à mão. O custo
   do primeiro prop foi alto; o do décimo é meia hora, e cai a cada peça de kit
   que entra. O plano velho orçava arte como quem encomenda arte.
2. **O Godot e o Blender rodam dentro da sessão.** O plano supunha ida e volta
   com uma máquina Windows — escrever aqui, testar lá. Hoje a suíte, o
   simulador e a captura de tela rodam no mesmo lugar onde o código é escrito.
   (Isto custou caro para se descobrir: **duas rodadas inteiras de trabalho
   visual foram feitas às cegas** antes de alguém tentar.)
3. **A "integração", que o plano previa que comeria o ganho, virou teste.**
   `run_tests.gd`, `teste_design.gd`, `teste_audio.gd` e `teste_fumaca.gd`
   pegam a regressão que
   antes se pagaria em horas de depuração no fim de semana.

### O erro na direção contrária — e é este que importa daqui em diante

O plano velho orçou **produção** e deu o **julgamento** de graça.

Hoje é o inverso. Gerar 14 efeitos de som custa segundos; **ouvi-los continua
exigindo uma pessoa com placa de som**, e não há nenhuma neste contêiner.
Densificar um prop é um laço em Python; dizer se ficou bonito é o Bruno abrindo
uma captura. Rodar 600 partidas por perfil leva dez segundos; saber se o jogo é
divertido continua sendo alguém jogando.

**O gargalo mudou de lado.** Um plano que continue orçando horas de produção
está medindo justamente a parte que ficou barata. Este plano orça a parte cara:
os momentos em que só uma pessoa resolve.

---

## 2. A unidade de planejamento é a sessão

Não é a semana, e não é a hora. É a **sessão**: uma conversa com o Claude Code
que abre com um estado conhecido e fecha com uma coisa provada.

**Abre com:** `CLAUDE.md` (carrega sozinho) + `docs/ESTADO_DO_PROJETO.md` +
o item da fila escolhido para a sessão.

**Fecha com:** commit, as suítes exigidas pelo CI verdes, e — se mexeu no visual — uma
captura que alguém olhou. É o ritual que já está escrito em `CLAUDE.md`, seção
"Antes de fechar qualquer mudança"; este plano só o adota como definição de
pronto.

### A regra de dimensionamento

> **Se o entregável não pode ser provado por teste, por simulação, por captura
> ou pelo Bruno em cinco minutos, a sessão está mal dimensionada.** Corte até
> caber.

"Melhorar o jogo" não é uma sessão. "A reputação passa a mexer no preço que o
cliente aceita, com o simulador mostrando o efeito nos três perfis" é.

### Três tamanhos, e vale saber qual se está abrindo

| Tamanho | O que entrega | Como termina |
|---|---|---|
| **Refino** | Uma coisa visível: um prop denso, uma tela, um som trocado | Captura ou folha de contato + suítes verdes |
| **Sistema** | Uma mecânica, com os testes que a defendem | Testes novos + simulador, se tocou em número |
| **Investigação** | Uma resposta escrita. **Não muda o jogo** | Um documento curto e uma recomendação |

A sessão de investigação é a que mais se esquece de abrir e a que mais paga:
metade dos erros caros deste projeto veio de construir antes de medir
(a dificuldade "fácil" que era faca de dois gumes, os dois lotes de sprites
encomendados no ângulo errado).

---

## 3. Os quatro gargalos humanos

O plano inteiro está desenhado em torno destes quatro. Tudo o que não está aqui,
a máquina faz.

1. **Julgar.** Jogar e sentir se é divertido. Ouvir — *o contêiner não tem
   placa de som e ninguém que fez os efeitos os ouviu*. Olhar uma captura e
   dizer se ficou bonito: teste verde não prova beleza.
2. **Contas e aparelhos que não vivem aqui.** Suno e ElevenLabs, a página do
   itch.io, o celular real, a chave de assinatura do Android.
3. **Decidir design.** O que a reputação faz mecanicamente. Se os valores sobem
   de escala. Se a Zona de Espera vira fila de verdade. Nenhuma destas tem
   resposta certa — têm resposta *do dono do jogo*.
4. **Ser a memória entre sessões.** Hoje ainda é, em parte. A Trilha B existe
   para que deixe de ser.

### As duas regras que saem daqui

> **Nunca gastar um gate humano no que a máquina podia ter medido.** Playtest
> não serve para achar bug de estado — isso é teste, e já apanhou o save que
> duplicava os píeres. Playtest serve para o que só uma pessoa sente.

> **Nunca deixar a máquina decidir por omissão o que é decisão de design.**
> Quando uma pergunta da lista 3 fica sem resposta, a sessão seguinte escolhe
> sozinha — e o jogo deriva sem ninguém ter decidido nada. Uma pergunta de
> design em aberto **bloqueia** o item da fila que depende dela; não se
> contorna.

---

## 4. As duas trilhas

| | **Trilha A — o jogo** | **Trilha B — o projeto e o Claude** |
|---|---|---|
| Entrega | O que o jogador vê | O que a próxima sessão consegue fazer |
| Mede-se por | Captura, playtest, simulador | Uma dor que deixou de doer |
| Risco de não fazer | O VS não sai | Cada sessão redescobre o que a anterior já sabia |

**Regra de alternância:** nenhuma sequência de três sessões de Trilha A sem uma
de Trilha B; e **nenhum item de Trilha B sem uma dor medida que ele pague.**

A segunda metade dessa regra é do próprio projeto: o `docs/design/BR_Port_Plano_Arte_Blender.md`
§5 já tinha considerado criar uma skill de arte e **recusou** — *"uma skill
compensa quando o fluxo repete muitas vezes na mesma sessão, e hoje o
`CLAUDE.md` chega"*. Estava certo então. O que mudou é que agora há seis etapas
de arte enfileiradas, e o fluxo passou a repetir. Ferramenta constrói-se quando
a dor aparece duas vezes, não quando a ideia aparece uma.

---

## 5. Trilha A — o jogo

Ordenada por **destrava-o-resto ÷ custo**, não por vontade. Cada item diz quem
faz o quê, porque essa é a informação que o plano velho não tinha.

---

**A1, A2 e A3 fecharam** — a build no telefone (a máquina e as duas jogadas,
02/09 e 06/09; a passagem seguinte é do A7), os números com fonte única
(`BR_Port_Numeros_Fase_1.md`, gerada do código) e a reputação pela negociação
(`003`). O texto de cada um desceu inteiro para
`docs/arquivo/PLANO_V3_FECHADOS.md` (`092`).

---

### A4 — As seis telas narrativas que faltam do escopo do VS  🔨 CONSTRUÍDO (01/09), à espera do gate

**Entrega:** Boletim do dia, Dona Cida (3 tons), Boletim Financeiro semanal,
cena de parcela com o Sr. Ribeiro, Diário do Porto (1 página), cena de fim de
Fase 1.

**Por que:** são metade das doze telas IN do GDD, e as seis que faltam são
justamente as que carregam a Fase 1 como *história*. Hoje o jogo tem o loop
inteiro e nenhum NPC: **`Dona Cida` não aparece uma única vez no código**, e o
Sr. Ribeiro existe como uma linha de texto num painel. O VS foi definido como
*"uma sessão jogável da Fase 1 do JOGO"* — sem estas telas, é o protótipo com
arte melhor, que é exatamente o que o playtest de 26/08 já tinha apontado.

O texto não precisa de ser escrito do zero: `BR_Port_Frontload_Escrita_VS.md`
existe para isto.

**Cuidado que esta é a etapa com maior risco de estragar o que já está medido:**
uma tela que interrompe o turno muda o ritmo do jogo, e o ritmo é o que a
economia mede. Regra para esta etapa: **nenhuma tela nova pode alterar o número
de decisões por semana.** Se alterar, o simulador roda antes do commit.

| Quem | O quê |
|---|---|
| Máquina | As cenas, os retratos (gerador de imagem é legítimo em painel — o que não pode é prop no mapa), a ligação aos sinais que já existem |
| Bruno | Ler o texto em voz alta uma vez. Se soar a manual de instruções, volta |

**Mede-se por:** uma partida do início ao fim em que a Fase 1 tem começo, meio
e fim narrativos — e o balanceamento não se mexeu.

**O que ficou (01/09).** Sete telas, não seis: o Bruno decidiu que a entrada dos
dois nomes merece tela própria, e ela é a primeira coisa que o jogador vê.

| Tela | Onde | Abre em |
|---|---|---|
| Nomes do cais e do jogador | `TelaNomes.gd` | Partida nova, antes de tudo |
| Diário do Porto, 1ª página | `PainelDiario.gd` | Encadeado à anterior |
| Boletim Financeiro (3 tons) | `PainelBoletim.gd` | Fecho de cada semana |
| Falas da Dona Cida (8) | `NarradoraDaCida.gd` + `Narrativa.gd` | Faixa de mensagem, por evento |
| Falas do Arlindo | `CounterOfferPanel.gd` | Durante a negociação |
| Cena da parcela | `DebtPaymentPanel.gd` | Vencimento, semana 4 |
| Fim de Fase 1 | `EndGame.gd` | Fim de jogo, só na vitória |

Todo o texto vive em `scripts/Narrativa.gd`, e os dois nomes saem por
`GameState.texto()` — um ponto de substituição só, como o `moeda()`.

**O balanceamento não se mexeu, e é medido em 600 partidas por perfil** (não
nas 30 de fumaça, que têm ±18 pontos de margem): **100% / 47,8% / 0%** na
escala de então, com a mediana do mediano em R$7.960 contra a parcela de
R$8.000. *(Estes números são de 01/09; a economia foi reescalada e o alvo
mudou para tranquilo em 02/09 — ver `docs/decisoes/005`.)* Os números da reputação do A3 também estão intactos — 23,3% / 0,4% /
0% de ofertas no teto, apostas ganhas 87,3% / 49,5% / 39,0%. O modelo das
Parcelas recalibra com erros de 1,3% / 0,1% / 1,4%, e nenhuma das 1.800
partidas travou.

A razão é estrutural — nenhuma tela é fase do `GameState`, e o simulador nunca
abre cena.

**A armadilha que este item destapou, e que valia por si só:** uma fase nova
que bloqueasse o turno faria **24 de 30 partidas não terminarem** no simulador,
e o CI passaria na mesma, porque só procurava a linha `=== Leitura ===`. Está
medido, está consertado (o CI reprova `possível travamento`) e está escrito no
`CLAUDE.md`.

🔧 **CINCO CORREÇÕES DE TEXTO EM 12/09, e o gate continua de pé.** Ao montar o
roteiro de leitura apareceram coisas que não eram gosto — e por isso não
esperavam pelo ouvido dele:

1. **Duas das oito falas da Dona Cida nunca tocavam.** `perdeu_para_arlindo` e
   `bom_contrato` estavam na tabela desde 01/09 e nenhuma linha do projeto as
   disparava — um quarto da voz dela em jogo. O fumaça não podia apanhar: lia a
   tabela dos dois lados. Hoje a primeira sai de `negociacao_resolvida` e a
   segunda de um sinal novo, `contrato_fechado`, com o limiar derivado da faixa
   da própria classe (o quarto de cima) em vez de um número em reais.
2. **A Dona Cida comparava com uma semana que não existe.** *"A semana anterior
   foi melhor"* no PRIMEIRO boletim. Medido: 0 de 60 partidas para quem aloca,
   **60 de 60 para quem não aloca ninguém** — o principiante. Entrou um quarto
   tom só para esse caso.
3. **Uma fala inventava um número.** *"Dois contratos recusados essa semana"*
   num gatilho que é a queda de FAIXA da reputação.
4. **A narração de fim de fase saía em dígitos** — *"4 semanas", "32 turnos de
   decisão"*. A derivação por `%d` consertou o número que envelhecia e estragou
   a prosa, e a guarda que comparava o dígito era o que a mantinha assim.
5. **"A Parcela vence hoje"** — rótulo de interface dentro de fala.
6. **E o Bruno decidiu o que o desvio 1 deixara em aberto:** a narração diz
   agora que esta é **a primeira de três parcelas**, e que faltam duas — "é bom
   um começo". O três sai de `parcelas_na_fase()`, não da prosa: é o arco do GDD
   (três parcelas em doze semanas) contra o VS, que joga o primeiro terço.
7. **E ao crescer o texto viu-se que ele nunca coubera.** O painel dava 430 px
   a uma peça que pede 847 — **metade dela, o remate incluído, vivia debaixo da
   dobra desde 01/09**, com o botão a convidar a sair antes. O diário levou a
   mesma mordida em 11/09 e foi remedido; o irmão não. A altura passa a sair do
   texto (`altura_do_texto()`), e o **D22** tranca-a.

**E rendeu a asserção que faltava**, no F4: *toda fala escrita chega ao jogo?* A
segunda fonte é o `Main.gd`, e ela apanhou um terceiro caso na estreia (o
`reputacao_caiu`, que vive dentro de um ternário e o varredor não via). Dois
defeitos injetados, e a economia medida **idêntica ao dígito** — as taxas do
`CLAUDE.md`, que é onde elas vivem.

📖 **A PRIMEIRA LEITURA EM VOZ ALTA ACONTECEU (13/09), e devolveu sete coisas.**
Seis eram texto e estão feitas; a sétima é item de fila:

1. *"semana 1"* virou **"primeira semana"**, no cabeçalho do diário e no corpo.
2. Três linhas da Dona Cida reescritas: a tautologia que eu tinha posto no
   primeiro boletim (*"sair mais do que entra é sair mais do que entra"*), o
   jogo de palavras do tom mau (*"comparativo de ruim"*) e o elogio contido.
3. ⚠️ **UM ERRO DE MUNDO:** *"porto que fecha no azul é porto que abre
   segunda-feira"* — **o porto opera 24/7 e não abre na segunda.** Nenhuma
   suíte podia apanhar: a frase é verdadeira em português e falsa neste mundo.
4. ⚠️ **E UM ERRO DE ARITMÉTICA QUE EU TINHA ACABADO DE INTRODUZIR:** a
   narração dizia *"Quatro semanas. / Trinta e dois dias."*, e quatro semanas
   dão **vinte e oito**. Até 12/09 a linha dizia "turnos", que não prometia
   nada; trocá-la por "dias" — uma melhoria de prosa — destapou a conta. A
   linha saiu.
   **E o que ela destapou é maior, e é decisão do Bruno:** `TURNS_PER_WEEK` é
   8, e a interface inteira chama turno de DIA (o botão "Avançar dia", o
   "Vence no dia 32"). Ou a semana deste jogo tem oito dias de propósito, ou
   "dia" é o rótulo errado em todo lado. Nada no código está inconsistente
   consigo; o que colide é o vocabulário com o calendário.
5. **"Sobrinho" fica, e ganha companhia.** A pergunta foi *"como assim
   sobrinho?"* — e o GDD sustenta a palavra (`gdd/sistemas/voz_personagens.md`:
   *"chama todo mundo de sobrinho ou querido, independente da idade"*). O
   defeito não era a palavra, era a DOSE: no GDD ele fala assim o tempo todo,
   no VS diz sete linhas e usa o maneirismo UMA vez, na última. Entrou
   "querido" na abertura; duas ocorrências fazem padrão, uma faz tropeço.

**A semana de sete dias fechou** — `TURNS_PER_WEEK` é 7 desde a `085`, com a
Fase 1 em doze semanas. O item, com a F1 e a F3 medidas em 13/09, desceu para
`docs/arquivo/PLANO_V3_FECHADOS.md`.


### 🎭 ITEM NOVO — retrato do personagem com REAÇÃO, junto da fala  🔨 (a) e (b) FEITAS, (c) nos PAINÉIS (13/09)

✅ **`docs/decisoes/020`.** Os três têm cara: nove bustos no estúdio partilhado
(`brp_porto.py`, `retratos_de_fala`), três expressões cada, e uma tabela
(`Narrativa.EXPRESSOES`) que **percorre as falas** — 24 delas — e diz qual cara
cada uma pede. Aparecem no Boletim, na cena da parcela e na contra-oferta.

Rendeu o bloco **F7** do fumaça, com quatro perguntas contra quatro fontes
diferentes (a mais nova é *"toda cara desenhada é usada por alguma fala?"*, que
é o `barco_medio` do lado da arte), e apanhou um defeito de verdade a caminho:
**`ARLINDO_VENCEU` e `ARLINDO_PERDEU` estavam MUDAS desde 01/09** — a
negociação fechava calada, ganhasse quem ganhasse. Hoje a contra-oferta tem
segundo tempo, como a cena da parcela.

⏳ **FALTA A FAIXA DE MENSAGEM DO RODAPÉ, e ela está MEDIDA.** Ela não pousa
sobre o mapa (vive no rodapé, entre os trabalhadores e o cartão da meta), tem
52px de altura e o rodapé acaba em 1251 de 1280 — **29px de folga**. Logo: cabe
um retrato de ~44px de graça, onde a expressão já não se lê, ou um de 76px que
gasta 24 da folga. **Escolher entre os dois é do Bruno**, porque o rodapé cheio
é decisão dele em aberto desde o primeiro playtest. Feita a escolha, é um nó no
`Main.tscn` e três linhas no `Main.gd`; a tabela já cobre as oito linhas de
loop da Dona Cida.

O que segue é o item como foi escrito em 13/09.

Pedido na primeira leitura (13/09): *"seria legal aparecer o sprite dos
personagens, poderia ser o sprite com a reação do personagem mais a mensagem"*.

**Medido antes de estimar.** A metade do estúdio já existe: o
`trabalhador_retrato` sai de `blender/brp_porto.py` com `tipo="retrato"` e
âncora própria, e o `asset_validator` já sabe conferir esse tipo — é o único
prop do jogo que olha para a frente. **O que não existe:** retrato nenhum da
Dona Cida, do Arlindo ou do Sr. Ribeiro, e nenhuma noção de EXPRESSÃO.

**O que o item é, em três partes:** (a) retratos dos três no estúdio partilhado,
cada um com um punhado de expressões; (b) uma tabela que ligue cada fala à
expressão que ela pede — e ela tem de percorrer as falas, senão volta o buraco
das duas linhas mudas; (c) a faixa de mensagem passa a cartão com retrato, o
que mexe no `_on_message` e no tema.

⚠️ **E a alínea (c) esbarra numa regra deste arquivo:** *nada de interface
pousa sobre o mapa*. Um cartão com retrato é maior do que a faixa de hoje, e
onde ele cabe sem tapar o porto é a primeira pergunta a medir — não a última.
É sessão própria, e da trilha de ARTE.

⏳ **Falta o gate:** ler o texto em voz alta. Três desvios do rascunho de
escrita precisam do julgamento do Bruno — a narração de fim de fase teve de
passar de doze semanas para as `semanas_da_fase()` que o VS tem, as falas com
vocativo ganharam variante para quem não escreve o nome, e o "Boletim do dia"
foi lido como os comentários da Dona Cida (o arquivo de escrita não tem texto
para uma tela diária, e 32 modais por partida mudariam o ritmo que a economia
mede).

---

### A5 — A arte, pelas etapas que já estão medidas

**Entrega:** as seis etapas do `docs/design/BR_Port_Plano_Arte_Blender.md`, nesta ordem, que
é a ordem por ganho ÷ custo que aquele documento já mediu:

1. Paleta e enquadramento (muda tudo, e é barato)
2. A cauda dos props — contentor, caixote, boia, marcador, mais caminhão,
   empilhadeira, poste, cabeço, pilha de caixotes
3. Contorno: compositor **e** Freestyle já testados e rejeitados; não é etapa
   pendente (ver a medição no plano de arte)
4. Materiais dirigidos
5. O rosto do trabalhador (folha de rostos por gerador, aplicada num plano)
6. Interface encorpada — e esta não é Blender

Junta-se a estas o **retrato ilustrado do trabalhador no cartão**, que é de
outra leva e de outra linguagem visual e destoa de tudo o resto.

**Por que só agora:** porque arte é a coisa mais cara de refazer, e A1, A3 e A4
podem todos mudar o que precisa de ser desenhado.

| Quem | O quê |
|---|---|
| Máquina | Gerar, conferir a projeção, pôr na cena, capturar |
| Bruno | Olhar cada captura antes/depois e dizer "melhorou" ou "não" |

**Mede-se por:** captura antes/depois lado a lado, e a folha de contato dos
props. Teto realista, já medido: **~80% da leitura da referência** — o resto
pede textura pintada, e isso está honestamente registrado.

**A metade de máquina do A5 fechou** — a trilha de arte (14/09), a folha de
contato dos props e a folha C (16/09), e a página refeita até ao #75 (23/09),
com o link dela e a coleção `veredito` onde ficam os vereditos. Desceu para
`docs/arquivo/PLANO_V3_FECHADOS.md`.

#### Os vereditos de 23/09 — 31 de 31 julgados, e os 31 «Não»

Lidos da coleção `veredito`. **Nenhum «Não» aponta uma regressão**: onde a nota
compara, diz que melhorou — docas «ficou bom», meio «ficou melhor», pesca «o
detalhamento melhorou» — e pede mais. O «Não» quer dizer «ainda não chega»: a
trilha foi na direção certa, e o que falta é trabalho NOVO. Triados em seis
frentes, e **a ordem é do Bruno**:

1. **Três defeitos concretos, conferidos na foto e no código.** (a) A legenda
   do calendário mostra dois ÍCONES que a grelha não usa — os dias levam `•` e
   `!`. (b) O título «Fim da Fase 1» está por cima de «A primeira de três
   parcelas», que o contradiz. (c) «Sobrinho» no Arlindo continua a tropeçar
   depois do «querido» plantado em 13/09; a palavra é do GDD, e trocá-la é
   escolha dele. A nota do `contraoferta_fim` diz «Ribeiro», e a tela é do
   Arlindo. Pequeno.
2. **Os três retratos de fala** — boletim, `ribeiro` ×3, `contraoferta` ×2:
   Dona Cida, Sr. Ribeiro e Arlindo «bem ruins», e pedem-se mais bonitos e
   expressivos. Retrato de painel é o único sítio em que gerador de imagem é
   permitido, logo esta frente cruza com a auditoria do plano de assets que o
   Bruno faz com o ChatGPT. Médio.
3. **A interface inteira** — quinze painéis com «melhore o design», «está bem
   simples»: é a Etapa 6 do plano de arte. Pedidos concretos: diário com cara
   de diário e imagens do porto antigo; menu mais parecido com um celular;
   mensagens e pausa inspiradas em jogos de referência, a pausa com salvar e
   sair para uma tela inicial que ainda não existe; painel das docas com renda
   esperada e tipo de trabalho; caixa com recordes; reputação organizada para
   os componentes que virão; nomes como a tela depois de «Nova partida». Pede
   as referências dele. Grande.
4. **Mapa, frota e animação** — pesca mais realista mesmo simples; cascos e
   camiões melhores e com VARIAÇÕES (cargueiro de carros e de combustível,
   transportadoras diferentes), na proporção de carros e pessoas que virão; a
   ruína com mais desgaste; ícones integrados; o trabalhador animado (andar,
   pallets, empilhadeira) e uma transição suave entre turnos. Blender. Grande.
5. **O rumo além do VS** — o jogo não acaba na 1.ª parcela: as três da Fase 1,
   com desbloqueios e um tutorial que se liga e desliga; segunda chance com
   empréstimo caro; cancelar trabalho a custo de reputação; guindaste por fase
   — nenhum ou de madeira na Fase 1, intermediário na 2, o de hoje da 3 em
   diante —, obras que levam turnos, e o porto completo só na Fase 3. E **mais
   de um trabalhador por píer**, pedido do Bruno a 02/10 (`075`), com as
   animações de cada degrau a contarem com ele. **O GDD
   já diz metade disto**: a Fase 1 é «píer de madeira… consertos e pequenas
   melhorias», os «guindastes novos» são da Fase 2, e o Sr. Ribeiro tem linhas
   de empréstimo. O VS adiantou o guindaste de treliça (`nivel_guindaste()` 2,
   com duas estruturas quaisquer). Mexe no `GameState`, no balanceamento e no
   `SAVE_VERSION`: decisão de rumo, várias sessões. **Entrega financeira retomada em 07/10**
   (`084`): escala monetária ×0,1, primeira parcela R$30.000 e save versão 11,
   a pedido do Bruno. **Continuação em 07–08/10 (`085`):** escala anterior
   recuperada por nova escolha do Bruno, caixa R$400 mil como crédito inicial.
   Depois escolheu três parcelas menores e iguais, capital mais juros:
   R$140 mil cada, R$420 mil no total. Serviços reequilibrados; custos dos
   reparos restaurados. Método e referências no guia de economia.
   Doze semanas de sete
   dias, cobranças nos dias 28/56/84 e reparos básicos até dois píeres: píer 2
   no início, armazém na semana 2 e pátio na semana 5 após a primeira quitação.
   Save 12; economia medida nas três cobranças reais. Obras, crédito opcional,
   cancelamento de trabalho, tutorial e mais trabalhadores por píer seguem
   pendentes. **Continuação em 08/10 (`086`):** guindaste de madeira durante
   toda a Fase 1, sem promoção por reparos; intermediário reservado à Fase 2
   e disponível só nas bancadas de arte. Conjunto n1 aprovado na tela, até
   dois píeres; medição refeita nas três cobranças, preços intactos. Save 13,
   autorizado pelo Bruno, recusa a 12 antes de aplicar campos, sem migração. Fases
   futuras ainda não implementadas. Pátio liberado no dia 29 dobra a renda do
   píer; apenas seu adicional de contêiner espera os clientes futuros.
   **Continuação em 09/10 (`087`):** obras dos reparos básicos: dois dias para
   píer 2/armazém, três para pátio, uma de cada vez e pagamento ao iniciar;
   benefícios após concluir. Save 14 autorizado, retoma a obra e recusa a 13
   sem migração. Arte, preços, madeira e cobranças preservados; medição refeita.
   Crédito opcional, cancelamento, tutorial, trabalhadores extras e fases
   futuras continuam pendentes. Carros e imóveis aguardam novo escopo.
   **Continuação em 11–12/10 (`100`, `101`):** o tutorial curto, que o
   Toninho guia com rosto novo — atracar e avançar só no dia 1, por cima do
   jogo e sem save. Crédito opcional, cancelamento, trabalhadores extras e
   fases futuras continuam pendentes.
   **Continuação em 12/10 (`102`):** o crédito opcional, na forma da
   **segunda chance** do Sr. Ribeiro — no vencimento, a quem falta o boleto,
   o que falta mais uma semana de custos, +12% fixo na cobrança seguinte, uma
   vez por fase e não na última. Save 15 com o primeiro degrau. Na Fase 1
   todo serviço acaba no dia, logo cancelamento e trabalhadores extras só
   ganham sentido com a Fase 2; a linha voluntária, também (o calendário trava
   a obra, não o dinheiro). Pendentes: progressão, cancelamento, trabalhadores
   extras e a linha voluntária.
   **Escolha em 12/10 (`103`):** a progressão para a Fase 2, em quatro
   etapas — a passagem e o save 16 com o M9; a treliça e o cargueiro; a meta
   de três barras, a regressão e o fim no diário; a medição. Sem dívida e
   sem prazo, por escolha do Bruno. Os outros três esperam-na. **A etapa 1
   fechou em 12/10 (`104`):** a Fase 2 joga-se no mesmo save, sem meta.
   **A etapa 2 fechou em 14/10 (`105`):** a treliça compra-se por R$80 mil,
   com dois dias de obra, e abre o cargueiro no porto de nível 2.
   **A etapa 3 (`106`) trouxe meta, regressão e diário; a 4 (`108`) mediu
   os quatro perfis e manteve os preços e patamares.** Ritmo humano no A7.
6. **A folha de contato dos props** (props1–3): mais útil para a IA iterar,
   com referências profissionais. Só ferramenta; pequeno a médio, e barateia
   a 4.

Falta a metade dele, que é olhar — e está feita; falta escolher a ordem.

**A frente 1 fechou (23/09)** — o calendário, o título do fim de fase e o
Arlindo —, e com ela o material do ChatGPT passou a viver em `art_lab/`.
Desceu para `docs/arquivo/PLANO_V3_FECHADOS.md`.

#### ↩️ A FRENTE 2 ABRIU E VOLTOU AO BLENDER (23/09)

O Bruno escolheu os **retratos de fala**. A sessão julgou que o kit de caixas
não chegava e desenhou, sem perguntar, **nove retratos vetoriais** (SVG gerado
por script), fotografados numa CÓPIA do jogo nas seis telas com cara — só a
caixa de 112×152 mudava. A resposta: **«não deveriam ter sido criados»**. Nada
entrou no repositório; a lição foi para o `CLAUDE.md` (Arte).

**A frente continua no Blender**, e a próxima conversa **pesquisa** as boas
práticas para lá gerar estes personagens e os outros assets com visual melhor —
antes de modelar o que for. O que o script alcança está no §3 do
`BR_Port_Plano_Arte_Blender.md`; a pesquisa acrescenta-se ali.

**✅ A pesquisa fez-se no mesmo dia — é o §7 do plano de arte**, com fontes e
com o que dependia de "roda aqui?" rodado. Achou duas coisas: o pipeline
renderiza pelo **AgX** sem o declarar (nenhum prop passa de ~190 no p99; em
Standard, 231–236 sem estourar), e o rosto redondo alcança-se por script —
metaball, olho em esfera, boca em curva, contorno por casco invertido — a
5–6 s por render. Também mediu que arredondar o kit de hoje NÃO é um
modificador. **O que experimentar primeiro é escolha do Bruno** (§7.4).

**E ele escolheu: um retrato novo completo.** A v1
(`art_lab/retratos/cida_seria/v1/`, a Dona Cida séria de cabeça redonda) foi
**rejeitada** com quatro defeitos — nariz e boca, tronco, gola, cabelo e
lápis — e o pedido de «melhorar o modelo como um todo». A candidata é a
**v2** (`art_lab/retratos/cida_seria/v2/`), fotografada no jogo numa cópia:
muda só a caixa do retrato do boletim. A pedido dele há também a
**quadrada melhorada** (`art_lab/retratos/cida_seria/quadrada_v1/`), no kit de
caixas, para escolher QUAL modelo melhorar. **Ele escolheu a quadrada** e
pediu ajustes duas vezes (cabelo, óculos, tronco, rosto; depois cores e
corpo, com **Standard nos retratos**), e **aceitou a `quadrada_v3/` na foto
do jogo** (`055`): a Dona Cida está no jogo nas três expressões, pelo kit
afinado de `blender/brp_retratos.py`. **E os outros dois seguiram-na** (`056`):
a contente dela passou a sorrir de boca fechada, e o Sr. Ribeiro (retangular
e alto, quatro voltas) e o Arlindo (de ângulos, seis voltas) estão no jogo no
mesmo kit, cada um com a sua cabeça e aceites na foto do jogo. **E o
trabalhador do rodapé também** (`058`): em BUSTO, no mesmo kit e em Standard,
com o capacete e o colete que o identificam — aceite na v6, depois de seis
voltas (`art_lab/retratos/trabalhador/`).

**E as VARIAÇÕES dele estão no jogo** (`059`): 2 sexos × 3 idades × as 5
cores do IBGE, **30 retratos**, sem caricatura, aceites na v3
(`art_lab/retratos/trabalhador_variacoes/`). Cada trabalhador nasce com o seu
ROSTO — um campo no save, por um sorteio próprio que não mexe no da partida;
pelo `id` só se veriam três, porque o porto tem no máximo três trabalhadores.
Falta o **sistema de RH** (futuro), que põe cada rosto no currículo e na
negociação de salário, e o **adesivo** do capacete, que será o emblema que o
jogador escolhe para a empresa.

**E as nove caras de fala têm foto na bateria** (`060`): a preocupada e a
contente da Dona Cida e a pressão do Arlindo ganharam tiro, e a cobertura das
capturas passou a perguntar por CARA — o que o A5 olha de cada personagem já
não depende de alguém lembrar-se de montar o estado à mão.

**A frente 3 fechou nas quatro famílias (25–27/09)** — os painéis de decisão,
os do HUD, o sistema (tela inicial, espaços, pausa e celular) e as telas de
texto —, **e a 6 também (27/09)**, a prancha e a escala. Desceram para
`docs/arquivo/PLANO_V3_FECHADOS.md`.

#### A FRENTE 4 ABRIU (27/09) — a régua da pessoa e as transportadoras

Escolha do Bruno depois da 6, partida em famílias como a 3 — escala e
camiões, frota, ruína e obras, animação —, e começada pela **escala e
camiões** (`069`):

- **A régua do mundo**, medida no contêiner e na cabine do camião: 5,2 m por
  unidade no chão, 5,6 px por metro na altura. O trabalhador media **5,4 m**;
  a régua das pessoas é **1,5× o real** (`REGUA_DA_PESSOA` 0,48). A primeira
  conta deu 0,65 por ler a cabine antes do `ESCALA_CAMINHAO` — corrigida na
  prancha, com as duas lado a lado.
- **A fauna fica como estava**, escolha dele: encolhida, ia a 6–8 px. O D25
  passou a «nenhum bicho abaixo da pessoa nem chega ao barco».
- **O carro e o pedestre** entram só na página de escala, de
  `brport_vs/tools/referencia/`.
- **Duas transportadoras por serviço**, pela cor da cabine, a faixa e o
  modelo (bicudo nos três médios, cara-chata na carreta), com retrovisores,
  para-sol, para-choque, faróis, tanque, para-lamas, defletor, bisel, escape
  e carreta articulada. **Aceites na quarta candidata** (`069`), e **os 32
  entraram no jogo** (`070`): a vez de cada transportadora é um contador por
  serviço, sem sorteio, e o D35 exige que as 32 cheguem à rua.
- **A frota, pelos 3 de pesca** (`071`): escopo respondido antes do desenho —
  detalhe nos 9 cascos, a começar pela pesca, com as quatro marcas (defensas e
  amarração, nome e bandeira, equipamento, desgaste). **Aceites na quinta
  candidata**: pneus em anel, nome na proa, bandeira num pau na popa (saiu
  na `073`), o escorrido no material da faixa; a traineira com janelas, rede cinzenta em
  malha e cortiças; o arrasteiro com portas de arrasto, a rede no tambor e o
  saco de losangos pendurado do pórtico.
- **Os 6 cargueiros** (`072`, `073`): **aceites na sexta candidata** e no
  jogo, com os três de pesca. A superestrutura tem dois níveis, e a baleeira
  fica no convés de embarcações, ao lado de uma parede cega. Nenhum dos nove
  navios leva bandeira. A posição da baleeira foi perguntada ANTES do render,
  depois de seis recusadas a olho na `072`. **A família frota fechou.**
- **A ruína** (`074`): o galpão e o escritório refeitos como o MESMO prédio
  com menos prédio. O galpão tem doca partida, chapa e zinco com ferrugem,
  lona azul com pneus, portão caído e esqueleto de aço no lado do cais (a
  leitura V3 do ChatGPT, refeita daqui). O escritório é o canto com toldo
  rasgado, placa caída, telha laranja no chão e uma árvore lá dentro. O
  desgaste é reboco caído, quina lascada (o C3 do plano de arte) e umidade.
  Escopo e composição foram perguntados antes do render; **aceite na
  segunda candidata** e no jogo. As **obras** ficaram fora (mecânica, item
  5).
- **A animação, degrau 1** (`075`, `076`): a família sobe por DEGRAU do
  porto, escolha do Bruno depois de ver o GIF — no 2 o guindaste tira a carga
  do barco e ele desengata, no 3 vêm os pallets e a **empilhadeira**. O
  degrau 1 teve duas passagens no mesmo dia: o trabalhador andava do costado
  a uma pilha com a caixa de peixe ao ombro, e o Bruno pediu o que um porto
  faz — *«é ele [o guindaste] que sempre fará isso»*. No jogo, **o
  pau-de-carga descarrega**: gira do porão à pilha com caixas de peixe numa
  cinta, e o trabalhador opera o guincho, uma figura por sexo. Trabalha assim
  que é alocado — o pesqueiro parte no avanço em que o `progress` chegaria a
  1. O papelão e o saco ficaram no gerador, e entraram com o degrau 2.
- **A animação, degrau 2** (`077`): no píer de nível 2, no primeiro turno do
  serviço, **o guindaste de treliça descarrega** — gira do porão a uma pilha
  no tabuado com a carga do serviço (peixe, caixas de papelão, sacos de
  ráfia ou um contêiner), e o trabalhador desengata-a ao lado dela. Nos
  turnos seguintes o guindaste pára, e com o camião do serviço no berço ele
  leva a carga **às portas de trás**, ao ombro; o contêiner fica na pilha. **O
  camião passou a encostar de ré**, a pedido do Bruno: *«como se estivesse
  colocando a carga lá»*. Na segunda vista ele viu o trabalhador por cima do
  armazém na doca 2: as docas desenham-se depois do cenário, e o **D40 §6**
  passou a perguntá-lo.
- **A animação, degrau 3** (`079`): no nível 3 **o pórtico** gira do porão
  para terra com o carro a recolher, e pousa a carga num pallet a meio do
  cais; o trabalhador leva-o de **empilhadeira** à pilha da raiz, ou às
  portas do camião encostado — os dois ao mesmo tempo, o serviço inteiro. A
  empilhadeira e o pallet, do cais e do pátio, ficaram na régua da pessoa (a
  do pátio tinha a altura de um camião). O contêiner pousa no cais, como no
  n2: a máquina dele ficou para outra passagem, escolha do Bruno.
- **A virada do dia** (`078`): a transição entre turnos, que o pedido nunca
  detalhou. O Bruno escolheu duas de quatro: **o barco servido parte** (sai
  pela faixa do berço, de proa, e o seguinte entra de ré) e **o dinheiro
  conta**, com o que cada doca rendeu a subir do barco como «+R$». Um toque a
  meio acaba-a. O `GameState` não mudou: é a tela a alcançar o estado. A
  medição achou a chegada deslizante, escrita desde o início, a nunca correr
  (0 de 21), e o rumo dela a atravessar o píer. **D41**.

---

### A6 — O áudio de verdade

**Entrega:** música-tema da Fase 1, ambiente em loop, e os efeitos de rascunho
substituídos ou promovidos após escuta. O inventário atual é o de
`tools/gerar_sons.py`, do registro do áudio e dos WAVs; R9 (§7.1) acrescenta
análise técnica, sem confundi-la com aprovação auditiva ou trocar os assets.

**Por que depois:** o encanamento já está feito e testado; o que falta é
material sonoro, e material sonoro **só pode ser aprovado por quem ouve**.

| Quem | O quê |
|---|---|
| Bruno | Gerar no Suno/ElevenLabs. Ouvir. Aprovar ou repetir. Timebox de um dia para a música, como o GDD manda — se não render, cai sem culpa para só ambiente |
| Máquina | Trocar arquivo por arquivo, forçar PCM (o Godot importa WAV como QOA por omissão, que é compressão com perdas), manter `teste_audio.gd` verde |

**Mede-se por:** o teste de áudio, e o ouvido do Bruno. **Nenhum commit deste
projeto pode dizer "o som ficou bom"** — diz "toca no evento X, dura Y ms,
roteado no bus Z", que é o que se consegue provar daqui.

---

### A7 — O playtest instrumentado

**Entrega:** três partidas do Bruno e duas de pessoas que não conhecem o jogo,
com registro de partida que a máquina consegue ler.

**Por que instrumentado:** o roadmap já diz *"grave a tela — comportamento
importa mais que opinião"*, e está certo. Só que ver gravação é caro e não se
soma. Um registro em `.jsonl` por turno — o que estava em caixa, que barco
chegou, o que o jogador escolheu, quanto tempo demorou a escolher — dá-se ao
Claude no fim e sai um resumo com padrões que cinco partidas não mostram a olho.

Isto é a metade humana do item **B7**; nasceram juntos de propósito.

| Quem | O quê |
|---|---|
| Máquina | O registro, o leitor, e o resumo |
| Bruno | Jogar. Entregar a duas pessoas sem explicar nada. Observar |

**Mede-se por:** os três critérios de conclusão do VS que o GDD já fixou.

**Desde 11/10 (`099`):** o jogo a mandar é o link do Pages, que publica a
`main` verde, e cada partida real vai para `playtest/` — o `README.md` de lá
diz como se cola, como se nomeia sem o nome de quem jogou e como se lê. O FPS
no telefone mede-se pelo mesmo link, e a régua do contêiner que lhe fica ao
lado é o `medir_desempenho.gd`.

---

### A8 — Publicar

**Entrega:** o VS no itch.io, Android + WebGL, com página, capturas e um GIF.

Fecha a Fase 4 do roadmap. Depende de A1 estar feito há muito tempo — se A1 for
adiado para aqui, esta etapa deixa de ser publicação e volta a ser
descobrimento.

---

### A9 — A pergunta da Fase 6, com uma pergunta nova ao lado

O roadmap fixou a pergunta certa e ela não muda: **"você ainda quer jogar esse
jogo depois de ter feito o VS?"**

O que este plano acrescenta é uma segunda pergunta, que só faz sentido agora que
se sabe a que velocidade este projeto anda: **"o que precisa de estar
automatizado antes de escalar de uma fase para cinco?"** Um porto que muda de
cara cinco vezes é cinco vezes o mapa, cinco níveis de vila, cinco estados de
cada estrutura. Sem a Trilha B madura, a Fase 2 do jogo custa o que custou a
Fase 1 — e não devia.

---

## 6. Trilha B — o projeto e o Claude

Cada item diz **a dor medida que paga**. Item sem dor medida não entra.

---

**B1 a B8 fecharam (31/08–02/09)** — o hook de arranque, as skills, o CI com
evidência, os testes onde só havia olho, a documentação em camadas, o GDD
legível, o registro de partida e o orçamento de sessão. O texto de cada um,
com a dor que pagou, desceu para `docs/arquivo/PLANO_V3_FECHADOS.md` (`092`).

---

## 7. A fila

**Prioridade em vigor desde 10/10, escolha do Bruno: a FILA DE MELHORIAS da
revisão de 09/10, da mais crítica à mais tranquila, antes de voltar aos
gráficos e ao jogo.** A fila, o critério e a prova de cada item estão na §6 de
`docs/REVISAO_GERAL_2026-10-09.md` (M1 a M12); cada conversa assume o primeiro
item aberto, um por sessão, e as decisões D1–D8 dessa página são dele. A
frente 5 (o próximo recorte, em `BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
a melhoria de design abaixo esperam por ela, salvo pedido dele.

**A fila parou em 11/10, com o M11 (`099`):** o M9 espera o D1b e o M12 o
A8. Volta a frente 5, pelo **tutorial curto** que o Bruno escolheu em 11/10.
**Quem guia é o Toninho, com rosto novo** (`100`), e eram dois itens: o rosto
fechou em 12/10 (aceite na v6), e o **tutorial** também, no recorte que ele
escolheu — atracar e avançar, só no dia 1, overlay e sem save (`101`). As três
falas são rascunho e esperam a leitura do A4. Em 12/10 o Bruno escolheu o
**crédito opcional**, e ele entrou como a **segunda chance** do Sr. Ribeiro
(`102`), com as duas falas dele também à espera do A4. Ainda em 12/10 ele
escolheu a **progressão para a Fase 2** (`103`): as três quitações abrem-na
no dia 85, sem dívida e sem prazo, com o píer 3, o escritório e a treliça, e
uma meta de três barras (reputação, infra, o primeiro cargueiro) que fecha
a fase no diário e deixa o jogo seguir livre; save 16 com o M9. São quatro
etapas, uma por sessão. **A etapa 1 fechou em 12/10 (`104`)**: as três
quitações passam à Fase 2 no dia 85, o diário da Fase 1 segue para ela, o
save 16 guarda a fase e levou o M9, e a Fase 2 joga-se sem meta; o
simulador mede a Fase 1 com paridade à main. **A etapa 2 fechou em 14/10
(`105`)** — a treliça comprável, o porto de nível 2 e o cargueiro de dois dias,
com a arte das bancadas e uma partida fotografada até lá. Preço e prazo
provisórios, com varredura deste recorte; a etapa 4 mede a meta completa.
**A etapa 3 fechou em 14/10 (`106`)** — as três barras, o piso dos
cargueiros, o save 17 com migração e a página do diário que segue em jogo
livre. **A etapa 4 fecha na `108`**: medição completa por perfil, com
conquistas, dias condicionados à conquista, quebras e censuras numa janela
de observação, sem criar prazo. Preços e patamares atuais foram mantidos
após a varredura; dados e limites na decisão e na `economia.md`.
**Próxima conversa, escolha do Bruno em 14/10: melhorias gerais da frente
5, além do fechamento da Fase 1 e separadas da progressão da Fase 2.**
**O recorte escolhido é cancelar um serviço contratado em andamento.**
A análise está na proposta `109`, ainda **sem aceite e sem implementação**:
saída definitiva, equipe livre no mesmo dia, perda da receita, −5 de reputação
e multa de 10% do valor acordado, com confirmação e save 18 com migração
propostos. A medição autorizada está na `110`: 600 partidas por perfil,
políticas de troca e varredura separada de multa/reputação; recomenda manter
o candidato, ainda sem aceite para implementar ou migrar o save.
Não se trata de cancelar obras. Mais trabalhadores por píer e crédito
voluntário ficam para depois.
São funcionalidades gerais que podem usar os serviços mais longos e o porto
ampliado; não são novas etapas da progressão nem requisitos adicionais para
o vertical slice. Tutorial e segunda chance já estão no jogo. Carros e
imóveis continuam futuros, sem escopo novo. O A4 segue pendente: o caderno
reescrito está só na conversa, ainda sem aprovação.

**Prioridade de 03/10 a 09/10, escolha do Bruno: a MELHORIA DE DESIGN.**
As conversas seguintes começavam por ela, à frente da máquina do contêiner e da
frente 5. O pedido não diz o que corrigir — é o caso «diagnosticar uma queixa»
do `CLAUDE.md`, que é Opus —, e por isso cada conversa abre com a pergunta do
ESCOPO: que parte (o mapa e os props, a interface do HUD e dos painéis, as
telas narrativas, ou o design de jogo), com opções e a recomendada primeiro
(`/arte`, §8). Não se escolhe por ele.

**A primeira parte foi o HUD e os painéis (04/10, `081`)**: o rodapé escuro,
com o «AVANÇAR DIA» como único destaque; os trabalhadores nas colunas das
docas, em cartão escuro com a vaga; e o Construir com o cabeçalho das
famílias. **Aceite do Bruno em 04/10.** O achado que ficou — a cobertura do
`teste_design` dependia do save no disco — fechou em 09/10; o plano de
execução da revisão desse dia está em `docs/REVISAO_GERAL_2026-10-09.md`.

**A segunda parte foram as telas narrativas (04/10, `082`)**: as conversas do
Sr. Ribeiro, do Arlindo e da Dona Cida falam como no celular — o balão e a
placa de quem fala, os balões seguidos, a fala em letra regular —, e o fim da
Fase 1 é uma entrada do diário em duas páginas, com a virada da folha e o
recibo da parcela colado. **Aceite do Bruno em 04/10.**

**A terceira parte foi o design de jogo (04–05/10, `083`)**: medido, o
«Alocar todos» acertava sempre, e o verbo do dia não pedia escolha. Hoje os
barcos esperam numa **fila no fundeadouro** — três lugares, dois dias de
paciência —, e o jogador escolhe quem atraca; o que não é chamado vai embora e
custa reputação, e a oferta do Arlindo cai no barco que chega. A fila
facilitava (o controle deu 100 / 100 / 55,8), e o alvo da `005` voltou pelos
contratos a 0,72: **100 / 78,7 / 41,5**, com a parcela em R$530.000 por
escolha dele. A tela levou quatro passagens. **Aceite do Bruno em 05/10.** Ficou
para depois o barco a deslizar do largo ao berço. A conversa seguinte abre pela
pergunta do escopo do que falta: o mapa e os props (o mar aberto à direita, a
máquina do contêiner do nível 3 e os três guindastes sobrepostos), ou outra
parte do design de jogo.

**Ordem operacional de 17/09 (fechada: R1–R9 feitos): a §7.1 abaixo entrava
antes de novas melhorias e da publicação.** Os marcos A/B e o histórico de playtest continuam
valendo. Esta fila de correções não reabre o GDD, economia, projeção ou arte.
Cada R é uma entrega própria; a próxima conversa assume apenas **R1**.

Não é um calendário, e de propósito. **O calendário deste projeto depende quase
inteiramente de quando o Bruno se senta para julgar** — e prometer datas para
isso seria repetir o erro do plano velho ao contrário.

| # | Trilha | Entrega | Gate humano |
|---|---|---|---|
| 1 | B1 | Arranque de sessão automático | — |
| 2 | ✅ **A1** | **Build no telefone** ✅ máquina · **jogado 02/09 e 06/09** — as análises estão em `docs/arquivo/PLAYTEST_01_ANALISE.md` e `PLAYTEST_02_ANALISE.md` | ✅ feito (a passagem seguinte é do A7) |
| 3 | A2 | Números com fonte única + Parcelas 2/3 verificadas | Só se a conta não fechar |
| 4 | ✅ B2 | `/balancear`, `/fechar-sessao` e `/arte` | — |
| 5 | **A3** | **Reputação com efeito** | **Escolher o caminho — bloqueia** |
| 6 | ✅ B4 | Fumaça de cena, ícones, migração de save | — |
| 7 | A4 | As seis telas narrativas **+ a de nomes** | Ler o texto em voz alta ⏳ |
| 8 | ✅ B3 | CI com captura, antes/depois e build como artefato | — |
| 9 | A5 | Arte, etapas 1–6 | Olhar cada antes/depois |
| 10 | ✅ B5 + B6 + B8 | Documentação em camadas, GDD legível e orçamento de sessão | — |
| 11 | **A6** | **Áudio de verdade** | **Ouvir — só o Bruno consegue** |
| 12 | ✅ B7 | Registro de partida + leitor que resume N partidas | — |
| 13 | **A7** | **Playtest** | **Jogar, e ver duas pessoas jogarem** |
| 14 | A8 | Publicar no itch.io | Conta, página, capturas |
| 15 | **A9** | **A decisão da Fase 6** | **Só o Bruno** |

A tabela acima conserva a estrutura original dos marcos. A1 já teve as duas
jogadas registradas; não reabrir sua primeira instalação. A posição atual e os
gates ainda abertos são os do `docs/ESTADO_DO_PROJETO.md`. A fila operacional
de correções é a seguinte, antes de retomar os itens de expansão abaixo.

### 7.1 Revisão de 17/09 — fechada

R1 a R9 fecharam (`030`–`037` e `040`). A §7.1 inteira desceu para
`docs/arquivo/PLANO_V3_FECHADOS.md` (`092`), e com ela a segunda jogada no
telefone (06/09, triada em `docs/arquivo/PLAYTEST_02_ANALISE.md`) e os itens
✅ que a seguiam: as telas do fim em fila, o balanço e o chanfro, a mão da
rua, o painel que não é tela, a troca pela cor, a rua em 1,8, o item 12, as
duas fatias do 8, e as alavancas A e B da resolução com o raster da água. O
que a resolução ainda pede está logo abaixo.

### 🆕 A RESOLUÇÃO DOS ASSETS, E O DETALHE QUE ELA DESTRAVA — proposto em 14/09

**Item novo, e a ORDEM é do Bruno** — ele não entra na fila numerada até ele o
pôr lá. Nasceu da pergunta dele: *"valia a pena aumentar a resolução do jogo
para que o mapa e outras coisas tivessem mais pixels para poder detalhar
melhor"*, com o pedido de o emparelhar com uma melhoria do desenho.

#### O que a pesquisa devolveu, e o que ela muda na pergunta

Em pixels FÍSICOS, **1080 de largura é o padrão de facto** num telefone de hoje
(360×800 de viewport CSS a DPR 3 é 1080×2400; o iPhone fica em 1170–1290).
Praticamente ninguém tem 720 de largura física. As tabelas que dizem "360×800 é
a resolução mais usada" medem viewport de browser, não pixel — e para um jogo,
que desenha em pixel, a tabela útil é a traduzida.

#### São TRÊS alavancas, e a pergunta mistura duas delas

| | O que muda | Custo | Ganho de pixel |
|---|---|---|---|
| **A — o mapa** ✅ | `svg/scale` 1.0 → 1.5 nos quatro SVG de mapa | **medido: +412 KB no `.pck`, +9,89 MB de VRAM** (`025`) | **+52,6% de pico na fronteira** |
| **B — os props** ✅ | `RESOLUCAO` 512 → 768 em `gerar_props_iso.py` | **medido: +1.867 KB no `.pck`, +79,95 MB de VRAM** (`029`) | **+31,5% de pico nos props** |
| **C — o viewport** | 720×1280 → 1080×1920 | todo `offset` de toda `.tscn`, o `MEIA_LARG`, as âncoras, o teste de design | **NENHUM** |

⚠️ **A ALAVANCA C NÃO DÁ UM PIXEL, e é a que parece a óbvia.** O
`project.godot` usa `stretch/mode="canvas_items"`, o que quer dizer que num
1080×2400 **o jogo já desenha a 1080 de largura**: o 720 é sistema de
coordenadas, não resolução de render. Subir o viewport reescreveria o projeto
inteiro para não acrescentar informação nenhuma. É o pior custo-benefício dos
três, e é aí que a pergunta costuma ir parar.

⚠️ **E O MAPA JÁ CARREGA A PRECISÃO QUE FALTA.** Os quatro SVG de mapa —
`porto_mapa_iso`, `_patio` e as duas espumas — declaram `width="720"` sobre
`viewBox="0 0 1080 1080"`: **a geometria está desenhada a 1080** e o importador
rasteriza a 720, depois de o que o `canvas_items` volta a ampliar 1,5× no
aparelho. Ou seja, hoje o mapa passa por uma REDUÇÃO seguida de uma AMPLIAÇÃO.
A alavanca A não pede um traço novo — pede que se pare de deitar fora o que já
está no arquivo. **Os 23 ícones já estão certos** (declaram 48 sobre `viewBox`
de 24 e desenham-se a 19 px), então o HUD fica de fora.

#### ⚠️ E RESOLUÇÃO SOZINHA COMPRA NITIDEZ, NÃO DETALHE

Esta é a metade que o pedido do Bruno já traz e que o item não pode perder. Um
mapa a 1,5× é o MESMO desenho com menos serrilhado. O que a resolução compra de
verdade é **um orçamento de detalhe maior** — e este projeto sabe exactamente
onde esse orçamento está apertado, porque recusou coisas por medição e escreveu
o número ao lado de cada recusa. **É essa lista que a alavanca A e a B
destravam, e ela é o verdadeiro conteúdo deste item:**

| O que ficou de fora POR TAMANHO | hoje | a 1,5× |
|---|---|---|
| "comércios variados" na vila (`022`): lote 51 px, parede 12–15, toldo 20, vitrine 4 | não distingue de casa | lote **77**, parede 18–22, toldo 30, vitrine 6 |
| o corrugado do contêiner: 14 peças numa face de 31 px dão 2,5 px cada (a "lixa" do `DESGASTE`) | virou diferença de VALOR | face **46**, 3,7 px por peça |
| o filete de um prop: entra na imagem a 3 px de raio, lê a 6 (`024`) | 0,15 / 0,30 de mundo | **0,10 / 0,20** |
| os oito caminhões: 35–49 px de diagonal, abaixo do portão do filete (`024`) | fora da pergunta | **52–73 px, dentro** |
| "relevo de 0,9 px não sobrevive ao antisserrilhado" | some | 1,35 px |
| a régua da forma não separa caixa de redondo abaixo de 24 px de diagonal (`024`) | 9 props fora | o corte passa a valer **16 px** do desenho de hoje |

**E o que NÃO se destrava, medido — para o item não prometer o que não paga:**

- **as estacas do píer** passam de 9×32 para 13×48 e continuam esbeltas; a `024`
  mediu que é a ESBELTEZA que as faz medir alto, não a quadratura, e a estaca
  cilíndrica mede o mesmo em qualquer escala;
- **a fauna** quase não chega: a gaivota vai de 15 para 22,5 px e o corte é 24.
  Só a capivara (17 → 25,5) atravessa, e rente;
- **o tosado do casco** vai de 1,2 para 1,8 px de tela — continua abaixo dos 3
  em que a régua começa sequer a ver uma curva. Continua a não se desenhar.

#### A F1, quando ele puser isto na fila

1. **Medir o ganho do mapa antes de mexer nele.** Rasterizar `porto_mapa_iso` a
   720 e a 1080 com o MESMO ThorVG do jogo e comparar — não a olho: a energia de
   gradiente acima do piso do antisserrilhado diz quantas fronteiras de valor
   sobrevivem, e é a métrica que o `medir_silhueta_props.py` já usa por dentro.
   ⚠️ **E a armadilha é que nem todo traço do SVG foi desenhado para 1080.** A
   largura de cada traço, o passo do tabuado e as fiadas foram ESCOLHIDOS
   olhando o render a 720; a 1,5× um traço de 1 px passa a 1,5, e um vinco que
   foi calibrado para quase desaparecer pode reaparecer. É a família do
   "constante em PIXEL envelhece quando o `ZOOM` muda", que já custou cinco
   números em 05/09. A prova é a captura ampliada, não a contagem.
2. **Medir o custo, que ninguém mediu ainda.** O mapa a 1080² são 2,25× os
   pixels, e 31 props a 768² são 2,25× de VRAM. Sair com o tamanho do `.ctex`,
   do APK e do `brport-web` antes e depois, e com o tempo de arranque no
   aparelho — é o único item desta lista que pode reprovar por motivo que não é
   visual.
3. **O portão, e é o do bote da `024`:** se a captura a 1,5× não mostrar
   diferença que se veja **no telefone**, pare e registe a medição. Nitidez que
   só aparece a 6× de ampliação num monitor não é nitidez que o jogador vê.

#### Tamanho honesto

**Não é uma sessão.** A alavanca A é uma sessão pequena (import, três nós,
bateria, antes/depois). A alavanca B é uma sessão inteira só para a mecânica —
releva de 25 props, manifest, o pivô da lança que sai em pixels do PNG, o
`asset_validator`, e a releva do `brp_*` ao lado. E cada linha da tabela de
detalhe destravado é **uma sessão própria**, com a sua F1: são cinco ou seis.

**E não resolve a tela alta.** O jogo é 9:16 num mundo 9:20, e com
`stretch/aspect="keep"` sobram ~240 px de barra em cima e outros 240 em baixo
num 1080×2400 — **um quinto da tela**, medido e escrito no `project.godot`, com
as duas alternativas já testadas e piores. Isso é um item SEPARADO, é trabalho
de arte (um mapa mais alto) e não de configuração, e não se resolve às
escondidas dentro deste.

Os outros itens ✅ de 06/09 a 13/09 — os dois defeitos vistos em 13/09, a
fauna em terra, os itens 5, 24 e 17, o motivo da escala e a frota por
serviço — desceram também para `docs/arquivo/PLANO_V3_FECHADOS.md`.

---

## 8. Critérios de avanço de fase

Substituem os do Roadmap v2.1 nas Fases 4 a 7. A intenção é a mesma; muda o que
conta como prova.

**Fase 4 — Produção do VS.** Fecha quando: as doze telas IN existem com arte
final, o áudio está integrado, o jogo roda num telefone real, e há uma URL
pública no itch.io. *(Novo em relação ao v2.1: "roda num telefone real" passa a
ser critério de fase, não uma linha perdida no primeiro bloco.)*

**Fase 5 — Testes e correções.** Fecha quando: nenhum bug impede completar o VS,
e o registro de partida de cinco sessões está lido e resumido. Bug e feedback de
design continuam separados — bug corrige-se já; feedback vai para a lista da
Fase 6.

**Fase 6 — Decisão.** Fecha com a resposta às duas perguntas do A9, escrita.

**Fase 7 — Produção completa.** Uma fase de jogo de cada vez, cada uma publicada
como atualização. **Condição nova para entrar:** as seis etapas de arte
automatizadas ao ponto de uma Fase nova ser configuração e não reconstrução.
Sem isso, multiplica-se o custo da Fase 1 por cinco.

---

## 9. Riscos deste modo de trabalho

A tabela de riscos do plano velho está quase toda morta — "subestimação do tempo
de Godot", "perda de motivação ao longo de 14 meses", "IA não responder bem em
código Godot". Estes são os riscos reais de quem produz assim:

| Risco | Prob. | Mitigação |
|---|---|---|
| **Trabalhar às cegas** — mexer no visual sem olhar, no som sem ouvir | Alta | Já aconteceu duas vezes. `CLAUDE.md` manda capturar; B3 põe a imagem no PR |
| **Regressão silenciosa no que não tem teste** | Alta | B4. O que não tem teste é onde os bugs se escondem — foi assim com o save |
| **Decisão de design tomada por omissão** | Alta | A regra da §3: pergunta em aberto **bloqueia** o item. É o risco mais grave da lista, porque não dá erro — dá um jogo que ninguém escolheu |
| **Documento que ninguém lê** | Alta | B5. Quatro camadas, e só uma carrega sozinha |
| **Contexto perdido entre sessões** | Média | `CLAUDE.md` + `ESTADO` em dia + `docs/decisoes/`. É a razão de o `/fechar-sessao` existir |
| **Arte bonita na folha de contato e feia no jogo** | Média | Medir sempre no jogo rodando, na resolução do jogo. Já está escrito no Bloco 7 |
| **Velocidade a confundir-se com progresso** | Média | Sete dias produziram quatro blocos e **zero** builds em telefone. Volume não é avanço; a fila é ordenada por destrave, não por facilidade |
| **Escopo a crescer porque agora é barato produzir** | Média | O GDD continua congelado. Ideia nova vai para "ideias pós-VS", como sempre foi |

---

## 10. O que continua fora

Inalterado em relação ao GDD 7 e ao Plano da Fase 2. Repetido aqui só para não
ser preciso abrir outro documento:

Reputação Comunitária e de Imprensa · Bela e sistema de imprensa · Rivalômetro
completo · mapa regional e outras regiões · hobbies, pesca, bar, vida pessoal ·
estruturas além das cinco da Fase 1 · save em slots e na nuvem ·
acessibilidade além do tamanho de fonte em três níveis · cinemática polida ·
localização (o VS sai só em PT-BR) · Steam, App Store e Google Play (o VS sai só
no itch.io) · marketing, devlog público, Discord.

Continua tudo cortado de propósito. Não é descuido.

**Uma ideia nova entrou nesta lista em 03/09, e entrou por decisão do Bruno:**
um **serviço de compra para os navios** — o jogador encomenda o que um barco
precisa e a entrega chega por estrada. Ela ficou registada porque a travessia
do caminhão, feita nesse dia como cenário, é a peça de que ela precisaria; o
cabeçalho dos camiões no `TrafegoDeCamioes.gd` (`095`) diz isso, para que
quem lá mexer saiba que aquilo tem um dono futuro. Mas é **economia**, e economia da
Fase 2 não se coda sem perguntar antes — por isso está aqui e não na fila.

---

## 11. O que muda amanhã de manhã

1. A conversa nova abre com este documento ao lado do `ESTADO_DO_PROJETO.md`, e
   escolhe **um** item da fila.
2. A fila em vigor está na §7: desde 10/10, a fila de melhorias da revisão de
   09/10, um item por sessão. Os R da §7.1 fecharam todos, e o A1 e o A3
   também; não voltar ao ponto de partida histórico desta seção.
3. Leitura, julgamento visual e escuta continuam gates do Bruno. A atualização
   do planejamento não os fecha e não implementa os R seguintes.

E fica escrita a regra que este plano existe para instalar:

> **A máquina produz. A pessoa julga. Um plano que confunda os dois orça a parte
> errada.**

---

*BR Port · Plano v3 · Substitui o cronograma do Roadmap v2.1 (Fases 4–7) e o
Plano de Produção da Fase 2. Não reabre o GDD 7.*
