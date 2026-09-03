# BR Port — Plano v3: o projeto refeito para ser tocado com Claude Code

**Versão 3.0 · 30/08/2026**
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
   dez efeitos de som são saída de programa, não desenho feito à mão. O custo
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

Hoje é o inverso. Gerar dez efeitos de som custa segundos; **ouvi-los continua
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

**Fecha com:** commit, as três suítes verdes, e — se mexeu no visual — uma
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

### A1 — A build no celular. Primeira, não última.

**Entrega:** um APK instalado num telefone real e uma partida jogada nele.

**Por que agora, e não perto do fim:** este é o único item do plano antigo que
estava marcado para a **semana 6** e nunca foi feito — *"configurar export pra
Android + WebGL, testar build vazia em device real desde já"*. Passaram-se
quatro blocos de trabalho, 58 commits, e o jogo nunca correu fora de um
contêiner. `export_presets.cfg` está no `.gitignore`, `COMO_RODAR.md` não
menciona export nenhuma vez, e o CI não exporta nada.

Tudo o que se sabe sobre como este jogo se comporta num telefone é dedução: o
projeto está em `gl_compatibility`, 720×1280, retrato travado — escolhas
corretas, e por isso mesmo nunca postas à prova. O que um telefone real pode
mostrar e nenhum teste daqui mostra: o alvo de toque de 44px com um polegar
verdadeiro em vez de um rato, o custo de desenhar SVG grande em GLES3 num
aparelho de entrada, o peso do APK, o retrato quando o sistema mete uma barra
de navegação por cima.

Descobrir isso agora custa uma sessão. Descobrir depois da arte final custa
refazer arte.

| Quem | O quê | Estado |
|---|---|---|
| Máquina | Preset de export versionável (sem chaves), build headless, o APK e o `.zip` web como artefatos do CI, `COMO_RODAR.md` com a receita | ✅ 02/09 |
| Bruno | Instalar no telefone. Jogar dez minutos. Dizer o que estranhou | ✅ 02/09 |

**A metade de máquina está feita e verificada** (02/09). O APK sai a cada push,
29 MB, `arm64-v8a`, assinado em debug com chave gerada na hora; o Web sai ao
lado. Os dois ficam na aba **Actions** da corrida, em **Artifacts**.

**E o item já se pagou.** A PRIMEIRA instalação num telefone real achou três
defeitos que nenhum teste daqui podia ver — o jogo abria DEITADO (a orientação
era a string do Godot 3, que o exportador lê como `0` = paisagem), o botão
Voltar do Android FECHAVA A APLICAÇÃO, e o ícone na gaveta era o robô do Godot.
Os três estão corrigidos e trancados por teste. É a justificação deste item,
medida em vez de argumentada: dez minutos num aparelho contra quatro blocos de
CI verde.

**E pagou-se outra vez, na jogada.** A partida de dez minutos achou um QUARTO
defeito da mesma família — invisível daqui, e a travar o jogo: em 30% dos jogos
novos, `_spawn_boats()` abre a contra-oferta no autoload antes de o `Main`
existir para a ouvir, e o `Main` saltava a recuperação de fase quando tinha de
pedir os nomes. O turno ficava preso no dia 1, sem uma linha de erro. Corrigido
e trancado pelo bloco F6 do `teste_fumaca.gd`. O resto do que ela devolveu está
triado em `docs/arquivo/PLAYTEST_01_ANALISE.md`, item a item — **e nenhum outro
era bug**. Em 02 e 03/09 fechou-se tudo o que não depende do Bruno: a interface
inteira, a escrita que dava para mexer, e a arte (caminhão, prédios, pedras,
espuma, trabalhador). Ficam a composição do mapa — vegetação e distribuição das
casas —, o layout do rodapé, a economia (só via `/balancear`), o desenho de
sistema (Fase 2) e a fala da madeira podre, que espera o A4.

⚠️ **O export Android falhou primeiro, e com a lista de erros VAZIA.** De uns
vinte testes de configuração do Godot, só o do ETC2/ASTC reprova sem escrever
mensagem nenhuma — e ele depende do SISTEMA em que se exporta, passando num Mac
e reprovando em Linux. Foi preciso ler o código do motor para o descobrir. O
`project.godot` ganhou `import_etc2_astc=true` e o bloco F5 do `teste_fumaca.gd`
tranca-o, na suíte rápida, para a próxima resposta chegar em segundos.

⚠️ **O APK não se constrói no contêiner do Claude:** o `dl.google.com` responde
403 por política da organização, o SDK do Android é inalcançável, e o CI é o
único juiz desse export.

**Mede-se por:** uma partida completa no telefone, e uma lista escrita do que
apareceu.

---

### A2 — Os números do jogo passam a ter uma fonte só

**Entrega:** uma tabela versionada dos números da Fase 1, gerada a partir do
`GameState.gd`, com o CI a conferir que está em dia.

**Por que:** os números vivem hoje em dois sítios — o GDD e as constantes
`# TUNING:` — e **já divergiram uma vez**, com registro:
`BR_Port_GDD_V7_ERRATA_ECONOMIA.md` documenta um erro de aritmética no próprio
GDD, cujo modelo da Fase 1 acumulava R$ 1.480 contra uma parcela de R$ 8.000.
Ficou corrigido para a Fase 1, e ficou escrito que **as Parcelas 2 e 3 seguem
não verificadas**.

O projeto já sabe resolver isto: é o padrão que ele usa para os sons (*"os WAV
versionados batem com o gerador"*) e para as âncoras do mapa. Aplicar o mesmo
padrão aos números fecha a última fonte de verdade dupla que resta.

| Quem | O quê |
|---|---|
| Máquina | Extrair os `# TUNING:` para uma tabela; passo de CI que falha se o doc envelhecer; rodar o simulador contra as Parcelas 2 e 3 do GDD e escrever o que dá |
| Bruno | Só se a conta das Parcelas 2/3 não fechar: decidir se muda o número ou muda o modelo |

**Mede-se por:** mexer num `# TUNING:` sem regerar a tabela quebra o CI.

---

### A3 — A reputação passa a fazer alguma coisa

**Entrega:** a Reputação Comercial com efeito mecânico, medido nos três perfis.

**Por que:** está no GDD como sistema IN do VS, e hoje é **rótulo na HUD e mais
nada**. Está anotado como pendência em três documentos diferentes desde o Bloco
3, o que costuma ser sinal de item que ninguém quer abrir.

**Isto é bloqueado por uma decisão do Bruno.** Três caminhos, e são diferentes:

| Caminho | O que muda | Efeito no balanceamento medido |
|---|---|---|
| Preço | Reputação alta → barco vale mais | Direto e forte. Mexe nos 100/47/0 imediatamente |
| Frequência | Reputação alta → chega mais barco | Mais suave, e recompensa jogar bem sem inflar valor |
| Negociação | Reputação alta → o cliente do Arlindo aceita pagar cheio com mais frequência | Liga a reputação ao sistema que já é decisão de verdade |

A recomendação da casa é a **negociação**: é a única que faz a reputação
aparecer no momento em que o jogador está decidindo, e é a que menos ameaça a
economia medida. Mas a decisão é do dono do jogo.

| Quem | O quê |
|---|---|
| Bruno | Escolher o caminho |
| Máquina | Implementar, medir com o simulador em 600 partidas, e reportar 100/47/0 antes e depois |

**Mede-se por:** os três perfis continuam separados. Se o perfil descuidado
passar a ganhar, ou o mediano a perder sempre, a alavanca está grosseira demais.

**Feito em 01/09.** O Bruno escolheu a negociação; o registro e todos os números
estão em `docs/decisoes/003-a-reputacao-passa-pela-negociacao.md`. Mede: 100% /
47,8% / 0%, contra os 100% / 47,3% / 0% da base — mesma medida dentro da margem.

O que este item ensinou, e que não estava previsto aqui: **medir antes de codar
mudou a forma do trabalho.** A primeira medição foi a reputação no momento da
contra-oferta, e ela mostrou a barra SATURADA — 79,8% das ofertas do jogador
Ótimo e 53,8% das do Mediano aconteciam já no teto de 100. Pendurar a mecânica
ali teria produzido um bónus fixo para toda a gente e passado por sistema. A
curva teve de ser retunada primeiro (ganhos divididos por cinco), e só depois é
que havia onde pendurar seja o que for.

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
| Falas da Dona Cida (8) | `Main.gd` + `Narrativa.gd` | Faixa de mensagem, por evento |
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

⏳ **Falta o gate:** ler o texto em voz alta. Três desvios do rascunho de
escrita precisam do julgamento do Bruno — a narração de fim de fase teve de
passar de doze semanas para as `WEEKS_TOTAL` que o VS tem, as falas com
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
3. Contorno pelo compositor (**não** Freestyle — foi testado e rejeitado, fecha
   o vazado da treliça)
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

---

### A6 — O áudio de verdade

**Entrega:** música-tema da Fase 1, ambiente em loop, e os dez rascunhos
substituídos ou promovidos.

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

### B1 — Hook de arranque de sessão

**A dor:** toda sessão nova gasta os primeiros minutos a descarregar o Godot e a
rodar o `--import`, e a receita está escrita em `CLAUDE.md` precisamente porque
já foi esquecida. Pior: **duas rodadas inteiras de trabalho visual foram feitas
às cegas** por ninguém saber que o Godot corria aqui dentro.

**O que se constrói:** um `SessionStart` em `.claude/` que descarrega o Godot,
importa o projeto e diz numa linha o que está disponível. O `bpy` (~1 GB) fica
sob demanda, não no arranque.

**Sabe-se que funcionou quando:** a primeira mensagem de uma sessão nova já pode
rodar a suíte.

**Feito em 01/09:** `.claude/hooks/session-start.sh`, registrado em
`.claude/settings.json`. Doze segundos a frio, seis a quente, e o `bpy` ficou
de fora como planejado.

Três coisas apareceram na construção que não estavam previstas aqui. A
primeira: **a versão do Godot já tinha divergido.** O `CLAUDE.md` mandava baixar
a 4.6.1 e o CI rodava a 4.6.3 — a sessão testava numa versão e o PR era barrado
noutra. Escrever a versão no hook criaria um terceiro lugar, então ela passou a
viver em `.godot-version`, lido pelo hook e pelo CI. É o mesmo remédio do A2,
aplicado antes dele.

A segunda: **o hook nunca derruba a sessão.** Todo caminho de erro sai com 0 e
devolve a receita manual. Uma sessão sem Godot ainda serve para ler código e
escrever documento; uma sessão que não abre não serve para nada.

A terceira é a regra do `CLAUDE.md` sobre validadores, e ela pagou outra vez:
os cinco caminhos foram exercitados com defeito injetado, e **três defeitos
reais saíram daí** — o `curl` sem `-f` gravava a página de erro 404 do GitHub e
chamava isso de download bem-sucedido; o `unzip` despejava vinte linhas de erro
dentro do contexto da sessão; e o `.godot-version` ausente vazava mensagem do
shell. O caminho feliz tinha passado de primeira nos três casos.

---

### B2 — Skills para os fluxos que repetem

**A dor:** o fluxo de arte tem seis passos (gerar → folha de contato → conferir
projeção → pôr na cena → capturar → olhar) e vai repetir-se seis vezes em A5. O
fluxo de fecho tem quatro (três suítes, captura, ESTADO, commit) e repete-se
*todas* as sessões.

**O que se constrói:** `/arte`, `/balancear` e `/fechar-sessao` em
`.claude/skills/`.

O `/fechar-sessao` é o que mais paga, e por um motivo pouco óbvio: **o
`ESTADO_DO_PROJETO.md` é o único artefato crítico que nenhum teste protege.**
Ele envelhece em silêncio, e quando envelhece a sessão seguinte trabalha com
uma fotografia errada do projeto.

O `/fechar-sessao` tem um QUARTO passo, que não estava nesta lista e devia:
**varrer a conversa atrás do que se aprendeu e ver o que ficou só nela.**

Medido em 31/08, no fim de uma sessão longa: das doze lições daquela conversa,
dez já tinham ficado em comentário de código ou em `docs/decisoes/`, escritas à
medida que o trabalho andava. Duas existiam só no diálogo — o deslocamento de
62px do `MapaWrap`, que mandou três recortes de captura para o lugar errado, e
a regra de injetar defeito num validador antes de confiar nele. Dez em doze é
uma boa proporção, e ainda assim duas escaparam. Por isso o passo é de
VERIFICAÇÃO e não de escrita: quase tudo já está registrado quando se chega ao
fim, e o que se procura é o resto.

**Onde cada coisa se registra**, para o passo não virar mais um documento:

| O que se aprendeu | Onde vive |
|---|---|
| Regra que vale sempre e para todos | `CLAUDE.md` — o único que carrega sozinho |
| Por que se decidiu assim | `docs/decisoes/NNN-*.md` |
| Armadilha de uma função | Comentário nela, contando o que se tentou antes |
| Onde o projeto está | `docs/ESTADO_DO_PROJETO.md` |

**Feito em 31/08:** `/fechar-sessao` existe em
`.claude/skills/fechar-sessao/SKILL.md`.

**Feito em 02/09:** `/balancear`, escrito no dia seguinte a fazer o fluxo à mão
— seis rodadas de 600 partidas para reescalar a economia. Escrever a skill logo
a seguir ao trabalho é a diferença entre registar o processo e recordá-lo: ela
carrega as três armadilhas que só apareceram por se ter feito à mão (a escala
uniforme ser cosmética e ter de se PROVAR isso; a ordem dos perfis inverter
quando a primeira estrutura fica cara face ao caixa inicial; e o rasto de prosa
em oito arquivos que o CI cobra).

**Feito em 02/09: `/arte`**, e a razão de deixar de a adiar é a mesma que
mandava adiá-la. Esta seção dizia "serve o A5, que está dois itens à frente na
fila" — o A5 passou a ser AGORA, e o fluxo tinha acabado de ser corrido à mão
na Etapa 1. É o precedente da `/balancear` outra vez: escrever a seguir ao
trabalho é a diferença entre registar o processo e recordá-lo.

O que ela carrega e que não estava escrito em lado nenhum: a armadilha de
trocar o MATIZ e esquecer o VALOR (com os números que a mediram), o recorte
ampliado como o que denuncia o que a captura inteira deixa passar, e a ordem
medir → aplicar → recortar → medir outra vez.

⚠️ **E a suposição do custo estava errada num terceiro caso.** Esta seção dizia
que a skill "precisa de 1 GB de `bpy` para ser testada". Metade não precisa: a
Etapa 1 (paleta) e a Etapa 6 (interface) rodam sem Blender nenhum, e foi assim
que a Etapa 1 saiu. E `tools/conferir_lote_de_arte.py`, que parecia estar do
lado caro, precisa só de `numpy` e `pillow` — **medido, 8 segundos**. Quem
visse o `ModuleNotFoundError` e concluísse "isto é Blender" adiaria uma
ferramenta que não custa nada. As receitas da skill foram todas corridas; duas
estavam erradas e foram corrigidas por isso.

Duas coisas mudaram na construção em relação ao que se planejou aqui. A
primeira: o passo dos testes não é uma lista fixa. Os quatro do Godot
(`run_tests`, `teste_design`, `teste_audio`, `teste_fumaca`,
`asset_validator`) são segundos
cada e o CI roda todos em todo push — não há mudança barata o bastante para os
pular, e por isso são base, não decisão. O que a skill decide é o caro e o
condicional: as 600 partidas do simulador, a regeração dos mapas e dos sons, o
validador do Blender (que precisa de ~1 GB de `bpy`), e a captura.

A segunda: a skill exige a LINHA de sucesso, não o código de saída. Um erro de
compilação do GDScript sai com 0 sem rodar teste nenhum — o CI já se protegia
disso com `grep`, e um fecho que só olhasse o `$?` fecharia em cima de uma suíte
que nunca correu.

**Sabe-se que funcionou quando:** ninguém precisa de lembrar a próxima sessão de
rodar o teste de design — e uma lição da sessão anterior não é redescoberta na
seguinte.

---

### B3 — CI que produz evidência, não só um visto verde  ✅ FEITO (02/09)

**A dor:** o CI prova que nada quebrou. Não mostra o que ficou. Para ver o
porto, hoje é preciso abrir uma sessão e rodar a captura na mão.

**O que se constrói:**
- A captura de tela e a folha de ícones publicadas como artefato do workflow —
  cada PR passa a ter uma **imagem** do porto anexada.
- O simulador longo (600 partidas) num agendamento semanal, e não a cada PR. O
  de 30 partidas continua onde está, como teste de fumaça — e continua a ter a
  margem de ±18 pontos que já está documentada, que é a razão de não servir para
  medir.
- A build web como artefato, assim que A1 existir.

**Sabe-se que funcionou quando:** dá para julgar uma mudança visual pelo PR, sem
abrir sessão nenhuma.

**O que ficou (02/09):** dois workflows novos.
`.github/workflows/captura.yml` anexa a cada PR o artefato `brport-captura` com
cinco imagens — a tela inicial, o porto reconstruído, o Boletim Financeiro, o
menu de pausa e a folha de contato dos ícones. `.github/workflows/balanceamento.yml`
roda as 600 partidas por perfil às segundas e sob demanda. A build web como
artefato já tinha saído junto com o A1.

**E a entrega passou a ser mais do que uma foto: é um ANTES/DEPOIS.** Em pull
request o job fotografa também o commit-base, com a mesma semente, e escreve na
página da corrida qual das cinco imagens mudou. Isso responde "mudou alguma
coisa?" sem ninguém baixar nada — que é o atrito real de um artefato — e serve
direto o gate do A5, que é literalmente *olhar cada antes/depois*.

Só foi possível porque a captura passou a ser **função apenas do código**, e
isso exigiu duas coisas, não uma. A semente (`--semente=`, com padrão fixo,
semeada ANTES do `new_game()` — a mesma armadilha que o simulador já
documentava) fixa o mundo sorteado. Não chegou: medido, duas corridas do mesmo
código com a mesma semente ainda davam **1.030 pixels diferentes**, porque os
tweens em laço — o balanço do barco, a lança do guindaste, o pulso do cartão —
andam por *delta* e não por frame, e cada corrida fotografava outra fase da
animação. Com `--fixed-fps 60`, **dois clones independentes do repositório
produzem PNGs byte a byte idênticos**, e aí a pergunta "a imagem mudou?" passa
a ter resposta.

Três coisas apareceram na construção e não estavam previstas aqui:

- **A foto do porto saía com o Boletim Financeiro tapando o mapa inteiro.** Com
  a semente fixa, doze turnos calham num fim de semana e o painel abre. A
  imagem chamava-se "porto" e mostrava uma tabela — a fotografia mentirosa do
  `CLAUDE.md` outra vez, e desta vez sem um `push_error` sequer a denunciá-la.
  A ferramenta passou a IMPRIMIR quantos painéis estão por cima, e o script
  exige zero nos tiros do mapa e um no do menu de pausa: se um dia uma
  constante deslocar a fronteira da semana, o CI diz o que aconteceu em vez de
  anexar a imagem errada. O boletim virou o quinto tiro, de propósito.
- **Uma tela chapada também é um PNG.** Se o contexto gráfico falhar em
  silêncio no runner, a ferramenta salva um retângulo de uma cor só e diz
  "Tela salva". Medido: um PNG 720×1280 de cor única pesa 2,7–4,5 KB e as
  imagens de verdade pesam 87–517 KB, então o corte ficou em 20 KB. Os dois
  defeitos foram injetados e os dois reprovaram.
- **A comparação recusa-se a comparar contra ruído.** Uma base anterior a este
  item não conhece `--semente=`: cada corrida dela daria outro porto, e o
  antes/depois diria "mudou" nas cinco imagens, sempre. O job confere se a base
  sabe tirar a mesma foto e, quando não sabe, diz porquê em vez de mentir.

**Por que o simulador longo é semanal, e a razão NÃO é o custo:** medido, as 600
partidas levam 26 segundos. É o ruído — um número com ±4 pontos de margem
anexado a todo PR convida a ler sorteio como regressão, que é exatamente o erro
que a ferramenta existe para evitar. O que o workflow semanal REPROVA é só o
que não depende de julgamento: o simulador chegar ao fim, nenhuma partida
travar, e o modelo das Parcelas reconstruir a semana medida. As taxas ele
publica e não julga — cravar o alvo no workflow dar-lhe-ia um terceiro endereço
para envelhecer.

---

### B4 — Testes onde hoje só existe olho  ✅ FEITO (01/09)

**A dor:** três suítes cobrem lógica, encaixe e som. Ninguém cobre "a cena
abre". `MapaConceito.tscn` e `MapaIso.tscn` estão em `scenes/proto/` sem
ninguém a garantir que ainda instanciam.

**O que se constrói:**
- Fumaça de cena: instanciar **todas** as `.tscn` e falhar se alguma não abrir.
- Conferir que todo id registrado em `Icones.gd` tem arquivo no disco.
- Migração de save: um save da versão anterior carrega ou é descartado — nunca
  adaptado a meio. Foi este bug que deu **um porto com 4 docas num mapa que
  desenha 3**.

**Sabe-se que funcionou quando:** apagar um ícone do disco fica vermelho no CI.

**O que ficou:** `brport_vs/tests/teste_fumaca.gd`, quinto passo do CI, espera
`FUMACA OK`. As doze cenas são achadas por **varredura**, não por lista escrita
à mão — uma lista envelhece calada, e a cena que ficaria de fora seria
justamente a nova, que é a que ninguém testou ainda. De cada uma se confere o
cabeçalho (as dependências existem no disco), a instanciação, a entrada na
árvore e — o caso que mais escondia — que os scripts que a `.tscn` declara
**compilaram**: um script que não compila não impede a cena de abrir, deixa o
nó sem script e o jogo roda mudo.

**Os quatro defeitos foram injetados e os quatro reprovaram**, que é a regra do
`CLAUDE.md`: apagar um SVG, apontar uma cena para um recurso inexistente,
quebrar um script de cena e deixar um SVG por registrar.

**E o teste achou um bug de verdade — na migração de save, que é onde ele mais
custa.** Um save da versão CORRENTE mas com o roster vazio era recusado
*depois* de o `load_game()` já ter escrito `turn`, `cash` e o resto por cima do
estado vivo, e o arquivo impossível ficava no disco para ser tentado outra vez
no arranque seguinte. O jogo sobrevivia por acidente: o `new_game()` que vem a
seguir por acaso reescreve todos os campos. Um campo novo no save que o
`new_game()` não zerasse e o estado impossível atravessaria para a partida
seguinte — o bug das 4 docas outra vez, com outra roupa. O `load_game()` passou
a recusar **antes** de escrever qualquer coisa.

Descoberta lateral que vale registro: com o cache de import quente, apagar um
SVG do disco **não derruba cena nenhuma** — o Godot serve a cópia já importada
de `.godot/`. O defeito só aparece num clone novo. É a razão de o ícone ter
passo próprio em vez de se confiar no `preload` do `Icones.gd`.

---

### B5 — Documentação em camadas  ✅ FEITO (02/09)

**A dor, contada:** são **12 documentos na raiz de `docs/`** e mais 10 em
`docs/design/`. Três deles se chamam, literalmente, "Briefing para continuar". O `ESTADO_DO_PROJETO.md`
tem 20 KB e diz, ele próprio, para começar por outro documento — que por sua vez
aponta para um terceiro. Um documento só é lido por quem o abre; **o único que
carrega sozinho é o `CLAUDE.md`.**

**O que se constrói — quatro camadas, e mais nenhuma:**

| Camada | Ficheiro | Responde |
|---|---|---|
| Regras | `CLAUDE.md` | O que nunca se faz aqui |
| Estado | `docs/ESTADO_DO_PROJETO.md` | Onde estamos hoje |
| Rumo | este documento | O que vem a seguir, e quem faz |
| Decisões | `docs/decisoes/NNN-titulo.md` | Por que se decidiu assim, um por arquivo |

Os `BLOCO*` passam para `docs/arquivo/` com os links mantidos. Não se apagam —
metade das armadilhas caras deste projeto está registrada lá, e é por estarem
registradas que não se repetiram.

**Sabe-se que funcionou quando:** uma sessão nova precisa de ler dois
documentos, não cinco.

**O que ficou (02/09).** As quatro camadas estão de pé, `docs/arquivo/` recebeu
os treze registros de sessão com um índice que diz o que cada um é, e os dois
documentos que NÃO eram registro — o briefing de áudio e o plano de arte em
Blender — foram para `docs/design/` sem o prefixo do bloco, porque são o plano
operativo do A6 e do A5 e ainda não aconteceram. **A regra ficou por função e
não por nome:** um documento vai para o arquivo quando conta o que aconteceu.

**A dor era pior do que esta seção media, e de outro tipo.** Ela dizia "o ESTADO
tem 20 KB". Tinha **42.707 bytes** — dobrou entre a escrita deste plano e a
execução dele, sem ninguém decidir. E o tamanho era o sintoma menor: dentro do
mesmo arquivo conviviam **duas parcelas do Sr. Ribeiro**, R$8.000 e R$550.000,
e **três leituras do balanceamento**, todas lidas como atuais — porque o
histórico morava ao lado do estado, e prosa velha não se anuncia como velha.
Havia também **três respostas diferentes para "por onde começo"**: o cabeçalho
mandava a um briefing de 29/08, a tabela de inventário a outro de 28/08, e o
rodapé dizia para apontar o próprio arquivo.

O corte foi 42.707 → **18.375 bytes**, e o histórico desceu **verbatim** para
`docs/arquivo/HISTORICO.md` — texto movido, não reescrito, de modo que o
`git diff` mostra linhas a mudar de casa e ninguém teve de re-julgar escrita
antiga. As três linhas do "Sistemas que funcionam" que descreviam o jogo de
antes da reescala foram corrigidas contra o `GameState.gd`.

**E o item não se entrega sem uma guarda, porque o estado anterior também tinha
nascido arrumado.** `tools/conferir_docs.py` (passo do CI, espera `DOCS OK`)
tranca cinco coisas: as quatro camadas existem; toda referência de documento
tem destino; registro de sessão vive em `docs/arquivo/`; tudo o que está lá
consta do índice — é isso que faz "nada se apaga" ser verificável em vez de
promessa; e o ESTADO não voltou a inchar. **O teto é alarme de fumaça, não
regra de estilo**: subi-lo é legítimo, o que não é legítimo é o documento
dobrar sem ninguém reparar.

Os cinco defeitos foram injetados e os cinco reprovaram — na segunda tentativa.
Na primeira, o `git checkout` que devolvia o arquivo entre um defeito e outro
restaurou a versão ANTERIOR ao trabalho todo, e os três últimos testes
relataram, contentes, a mesma falha herdada. É a regra do `CLAUDE.md` outra
vez, num terceiro disfarce: **confira que a base está limpa ANTES de injetar**,
senão o que reprova pode ser o defeito de trás.

---

### B6 — O GDD legível por partes  ✅ FEITO (02/09)

**A dor:** o GDD 7 são **5.658 linhas de JSX** numa aplicação React. Para citar
uma regra é preciso varrer o arquivo; para o carregar inteiro gasta-se o contexto
que faz falta para o trabalho. Foi assim que um erro de aritmética sobreviveu
até ao Bloco 3 — ninguém lê 5.658 linhas de JSX à procura de uma soma.

**O que se constrói:** extração para `docs/gdd/*.md`, uma seção por arquivo,
gerada a partir do `.jsx` e conferida pelo CI — o mesmo padrão dos sons e das
âncoras. **O `.jsx` continua a ser a apresentação e a fonte; o markdown é a
leitura.** Nada de conteúdo muda: o GDD está congelado.

**Sabe-se que funcionou quando:** uma sessão cita a regra da Fase 2 sem abrir o
`.jsx`.

**O que ficou (02/09):** `tools/gerar_gdd_md.py` e **80 páginas** em
`docs/gdd/` — 60 de conceitos, 18 de sistemas, as perguntas de design com o
porquê de cada uma, e um índice. Passo do CI que regenera e exige o `git diff`
limpo, como os sons e os mapas.

O `.jsx` acabou por ser mais tratável do que as 5.658 linhas sugerem: por
dentro são **quatro literais de dados puros** — os dois `const sections`, o
`questionGroups` e o `DECISIONS` —, sem JSX nem função dentro deles. O Node
avalia-os e o Python desenha o markdown. Duas coisas que a leitura à mão não
teria antecipado: os ids dos dois GDDs **colidem** (`mapa`, `tutorial`,
`npcs`, `reputacao`, `finais`, `economia` existem nos dois), daí
`conceitos/` e `sistemas/` serem pastas separadas; e o campo `decisions` de
uma subseção é uma **referência** para o `DECISIONS`, que o gerador resolve —
a leitura traz a decisão inteira em vez de mandar caçá-la.

**O gerador recusa-se a adivinhar.** Toda forma de dado está declarada em
`FORMAS`, e uma chave que não esteja lá **reprova** em vez de sumir do
markdown. É a lição do A2 noutro documento: um gerador que ignora o que não
entende produz uma leitura incompleta com cara de completa, e ninguém
descobre até precisar da parte que falta. Os quatro defeitos foram injetados e
os quatro reprovaram — um deles com traceback cru na primeira tentativa, que é
mensagem sem endereço num log de CI, e foi corrigido.

⚠️ **E gerar a leitura destapou o que ela ia espalhar.** A página
`docs/gdd/sistemas/economia.md` traz as parcelas de R$8.000 / 16.000 / 24.000 e um card
"RISCO CRÍTICO — Parcela 3 não fecha" que a errata **já tinha matado** — o GDD
está congelado antes da reescala de 02/09, e o jogo roda com R$550.000. Sem
cuidado, este item teria criado **um segundo endereço onde dois números do jogo
convivem lidos como atuais**, que é exatamente o defeito que o B5 acabou de
tirar do `ESTADO_DO_PROJETO.md`. Por isso **toda** página leva o mesmo rodapé,
e não só as de economia: um aviso posto onde alguém achou que fazia falta é um
aviso que falta na página seguinte.

---

### B7 — O playtest que vira dado  ✅ FEITO (02/09)

A metade de máquina do **A7**: o registro `.jsonl` por turno, e um leitor que o
resume. Escrever arquivo num telefone tem particularidade própria — é sessão de
sistema, com teste.

**Sabe-se que funcionou quando:** cinco partidas produzem uma leitura que
nenhuma delas mostrava sozinha.

**O que ficou (02/09):** o autoload `Registro.gd` grava uma linha JSON por
turno, semana, obra e contra-oferta; `tools/ler_registros.py` lê N partidas de
uma vez; `tests/teste_registro.gd` tranca sete blocos e o CI corre-o mais um
passo que faz o gravador e o leitor encontrarem-se.

**A particularidade do telefone eram QUATRO, e nenhuma era a que se esperava.**
Não é escrever — é o resto:

1. `FileAccess.WRITE` **trunca**, e não há modo "append" no Godot 4. A versão
   ingénua dá um arquivo de uma linha só — a última — que passa em qualquer
   teste que só pergunte "é JSON válido?".
2. **Fechar é o que grava.** O Android mata a aplicação sem aviso e o buffer
   morre com ela. Uma partida de 32 turnos perdida porque alguém atendeu uma
   chamada é exatamente o dado que este item existe para não perder: o arquivo
   abre e fecha a cada linha.
3. **`user://` no Android é privado da aplicação.** Sem cabo e sem `adb` não há
   como lá chegar — um gravador cujo arquivo não sai do aparelho não gravou
   nada. Daí o botão "Copiar registro da partida" no menu de pausa: copiar,
   colar numa conversa, ler aqui. É a única porta que ele tem.
4. **O carimbo de hora só tem resolução de um segundo**, e duas partidas
   começadas dentro do mesmo segundo davam o mesmo nome de arquivo. Dois toques
   em "Novo jogo" chegavam lá.

**E o gravador nasce DESARMADO**, o que é a decisão de desenho que mais importa
aqui. Um autoload carrega também em `--script`, então ele estaria de pé durante
as 600 partidas × 3 perfis do simulador: a gravar por omissão, medir o
balanceamento escreveria 1.800 arquivos e o custo de os escrever entraria na
medida. Quem arma é o `Main._ready()`, e mais ninguém. Medido depois de tudo
montado: **100% / 79,5% / 35,7%**, idêntico ao de antes.

**O que o leitor responde e nenhuma partida responde:** o `simular_balanceamento.gd`
mede a dificuldade com perfis cujos números — `chance_esquecer_doca`,
`chance_igualar_rival` — são um MODELO de como alguém erra, estimado e nunca
medido, e o balanceamento inteiro assenta neles. A última seção do relatório
imprime o valor **medido** de cada um ao lado do que o simulador supõe. É onde
os perfis encontram gente.

**O nome de quem jogou não entra no arquivo** — `docs/decisoes/006`.

---

### B8 — Orçamento de sessão  ✅ FEITO (02/09)

**A dor:** uma sessão que tenta fazer tudo entrega tudo pela metade, e a
seguinte não sabe o que ficou por acabar.

**O que se constrói:** meia página em `CLAUDE.md` — quando abrir um subagente de
varredura em vez de ler à mão, o que uma sessão pode prometer, e a regra de que
**uma sessão fecha com o `ESTADO` em dia ou não fecha**.

**O que ficou (02/09):** a seção "O que cabe numa sessão", no `CLAUDE.md`, com
cinco regras. Saiu junto do B5 de propósito — as duas tratam da mesma matéria,
o que uma sessão lê e o que promete. A regra que ganhou número foi a de medir
antes de codar: **duas vezes em dois dias a suposição estava errada e nas duas
para o lado caro** — a barra de reputação que se ia afinar já estava saturada
no teto, e as 600 partidas que se evitavam por "demorarem minutos" levam 26
segundos.

---

## 7. A fila

Não é um calendário, e de propósito. **O calendário deste projeto depende quase
inteiramente de quando o Bruno se senta para julgar** — e prometer datas para
isso seria repetir o erro do plano velho ao contrário.

| # | Trilha | Entrega | Gate humano |
|---|---|---|---|
| 1 | B1 | Arranque de sessão automático | — |
| 2 | ✅ **A1** | **Build no telefone** ✅ máquina · instalado 02/09 · **jogado 02/09** — a análise está em `docs/arquivo/PLAYTEST_01_ANALISE.md` | ✅ feito (a passagem seguinte é do A7) |
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

Seis gates humanos em quinze itens. É essa a conta que este plano orça — e a
razão de A1 estar em segundo lugar é que ele é o gate que está há mais tempo
adiado.

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
do caminhão, feita nesse dia como cenário, é a peça de que ela precisaria; a
`_animar_caminhao()` do `Main.gd` diz isso no comentário, para que quem lá
mexer saiba que aquilo tem um dono futuro. Mas é **economia**, e economia da
Fase 2 não se coda sem perguntar antes — por isso está aqui e não na fila.

---

## 11. O que muda amanhã de manhã

1. A conversa nova abre com este documento ao lado do `ESTADO_DO_PROJETO.md`, e
   escolhe **um** item da fila.
2. O primeiro item que não é do Claude é o **A1** — o telefone. Enquanto o jogo
   não rodar num, tudo o que se sabe sobre ele rodando num telefone é palpite.
3. A decisão do **A3** pode ser dada em duas linhas e destrava a fila a partir do
   quinto item.

E fica escrita a regra que este plano existe para instalar:

> **A máquina produz. A pessoa julga. Um plano que confunda os dois orça a parte
> errada.**

---

*BR Port · Plano v3 · Substitui o cronograma do Roadmap v2.1 (Fases 4–7) e o
Plano de Produção da Fase 2. Não reabre o GDD 7.*
