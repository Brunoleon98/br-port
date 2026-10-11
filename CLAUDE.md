# BR Port — instruções do projeto

Jogo mobile de gestão de porto. Godot 4.6 + GDScript, retrato 720×1280, em
português do Brasil. O código, os comentários, os documentos e os nomes de nó
são em português — commits e PRs em inglês.

> **A documentação tem quatro camadas, e mais nenhuma.** A primeira são as
> regras: este núcleo, que carrega sozinho, e as de `.claude/rules/`, cada
> uma na sessão que precisa dela.
>
> | Camada | Onde | Responde |
> |---|---|---|
> | Regras | este arquivo e `.claude/rules/` | O que nunca se faz aqui |
> | Estado | `docs/ESTADO_DO_PROJETO.md` | Como o jogo está hoje |
> | Rumo | `docs/design/BR_Port_Plano_v3_Claude_Code.md` | O que vem a seguir, e quem faz o quê |
> | Decisões | `docs/decisoes/NNN-*.md` | Por que se decidiu assim, uma por arquivo |
>
> Para retomar o trabalho são **dois** documentos: o estado e o plano. Até
> 02/09 eram cinco em cadeia, e esta linha apontava para o terceiro elo.
> O que aconteceu em cada sessão que fechou vive em `docs/arquivo/`, com
> índice — **nada se apaga**, e nada de lá descreve o jogo de hoje.
>
> Os documentos de trabalho não são camada e continuam onde a mão os
> alcança: `docs/BRP_SPATIAL_CONTRACT.md` (o contrato da projeção),
> `docs/design/BR_Port_Plano_Arte_Blender.md` (o caminho medido da arte),
> `docs/PROTOCOLO_DE_ESCUTA.md` (o gate do A6, que só o Bruno passa) e
> `art_lab/README.md` (o laboratório de arte partilhado com o ChatGPT: o plano
> de produção dele, os conceitos e as candidatas, e o caminho de uma peça até
> ao jogo).
>
> **O Codex também contribui neste repositório**, por branches `codex/*` e PR,
> com tarefas que o Bruno lhe entrega. Ele lê `AGENTS.md`, que aponta para
> este arquivo e para as regras por tema e diz como os dois agentes não se
> atropelam — as regras daqui
> valem para ele. Antes de mexer num arquivo de alto conflito, veja os PRs
> abertos dele.
> `tools/conferir_docs.py` tranca isto no CI, e espera `DOCS OK`.
>
> **O GDD 7 lê-se em `docs/gdd/`**, uma seção por arquivo, GERADAS do
> `BR_Port_GDD_V7.jsx` — não as edite. Ele descreve o jogo das Fases 1 a 5 e
> está **congelado antes da reescala de 02/09**: onde os números dele
> divergirem do jogo, quem manda é `docs/design/BR_Port_Numeros_Fase_1.md`,
> que sai do `GameState.gd`.

---

## Como rodar, aqui dentro

**O Godot e o Blender rodam neste contêiner.** Duas rodadas de trabalho visual
já foram feitas às cegas por não se saber disto. Não trabalhe no escuro.

**Ferramenta e suíte gravam em `user://ferramentas/`, e só por isso não
apagam o que é do jogador** (`docs/decisoes/061`). Em 25/09/2026 uma captura
(`clear_save()` + `new_game()`) substituiu o save real do Bruno no desktop, e
o save era um de três: o `teste_registro` e o `gravar_partidas` apagavam as
gravações de playtest, e o `teste_audio` gravava o volume a zero. Hoje todo
processo com `--script`/`-s` pede o caminho ao `scripts/ArmazemLocal.gd`; o F13
do `teste_fumaca` prova a origem, e o CI planta uma sentinela no lugar do
jogador (`tools/sentinela_do_jogador.py`) e exige-a intacta.
⚠️ **E AS FERRAMENTAS PARTILHAM ESSA PASTA ENTRE SI:** não corra a bateria em
paralelo com as suítes. Em 27/09 o tiro `escala` leu, no `_ready` do
`GameState`, o save inválido que o `teste_fumaca` planta de propósito, e
saiu com backtrace; sozinho, saiu limpo (`069`).
⚠️ **E ESPERAR COM `pgrep -f <padrão>` NÃO ACABA** quando o padrão está na
linha de comando de quem espera: `while pgrep -f simular_balanceamento` casa o
próprio shell do laço (04/10). Espere pelo PID, ou corra em fundo e deixe o
aviso de fim chegar.
⚠️ **Só vale nos commits que o trazem.** Uma branch anterior à `061`, ou uma
cópia velha do projeto, ainda apaga o save — e jogar pelo editor usa o save
do jogador, que é o jogo a funcionar. Arquivo novo que o JOGO guarde em
`user://` passa pelo `ArmazemLocal`, ou volta a ser partilhado com as
ferramentas; o F13 reprova o caminho literal.

**Numa sessão remota o Godot já está pronto quando a conversa abre**, e o `$G`
já aponta para ele: quem faz isso é `.claude/hooks/session-start.sh`, que baixa
o binário, roda o `--import` e diz numa linha o que ficou disponível. Se a
primeira mensagem da sessão não trouxer essa linha, o hook não correu — aí vale
a receita manual abaixo.

**O hook só vale a partir da MAIN.** Uma sessão nova arranca do branch padrão,
então uma alteração ao hook que esteja só numa branch de trabalho não corre —
nem na sessão que a escreveu, nem em nenhuma outra, até o PR ser fundido. Quem
mexer no hook e não vir efeito na sessão seguinte deve olhar para isto antes de
o ir depurar.

```sh
# Godot (~70 MB, ~12 s) — só se o hook de arranque não tiver corrido
V=$(tr -d '[:space:]' < .godot-version)   # a versão vive num arquivo só
curl -fsSL -o /tmp/g.zip https://github.com/godotengine/godot/releases/download/$V-stable/Godot_v$V-stable_linux.x86_64.zip
mkdir -p ~/godot-bin && unzip -q -o /tmp/g.zip -d ~/godot-bin
chmod +x ~/godot-bin/Godot_v$V-stable_linux.x86_64
G=~/godot-bin/Godot_v$V-stable_linux.x86_64

$G --headless --path brport_vs --import                       # UMA VEZ por clone
$G --headless --path brport_vs --script res://tests/run_tests.gd
$G --headless --path brport_vs --script res://tests/teste_design.gd
$G --headless --path brport_vs --script res://tests/teste_audio.gd
$G --headless --path brport_vs --script res://tests/teste_fumaca.gd
$G --headless --path brport_vs --script res://tests/teste_registro.gd
$G --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_tela.gd -- 12 foto.png completo

tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"   # todas de uma vez

# Blender como biblioteca Python (~1 GB, minutos)
pip install "bpy==4.5.0"                                      # precisa de Python 3.11
# os avisos do bpy (download, stdout em bloco, view_layer) estão em .claude/rules/arte.md
python3 tools/gerar_props_iso.py brport_vs/art/props [prop ...]
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  --sem-pavimento brport_vs/art/porto_mapa_iso.svg

# Efeitos sonoros — sem dependência, biblioteca padrão só
python3 tools/gerar_sons.py brport_vs/audio/sfx
```

**`--import` não é opcional.** Num clone novo não existe `.godot/`, e sem ela
a suíte falha com uma pilha de `referenced non-existent resource` que não tem
nada a ver com o que se está testando. O hook de arranque já a roda; a regra
continua escrita aqui porque ela vale mesmo quando o hook não correu.

**A versão do Godot vive em `.godot-version`, e num lugar só.** O hook e o CI
leem esse arquivo. Antes dele, este documento mandava baixar a 4.6.1 e o CI
rodava a 4.6.3 — a sessão testava numa versão e o PR era barrado noutra.

**O APK NÃO se constrói aqui, e o Web sim.** O `dl.google.com` responde 403 por
política da organização, então o SDK do Android é inalcançável e o CI é o único
lugar onde o export do APK se verifica — ele corre a cada push na `main` e a
cada PR, e deixa o `brport-apk` e o `brport-web` em Artifacts. O Web só
precisa dos templates (~1,2 GB), que o CI cacheia; a receita completa, pelos
dois caminhos, está em `brport_vs/COMO_RODAR.md`.

⚠️ **E O CI NÃO CORRE AO EMPURRAR A BRANCH.** O `testes.yml` e o `captura.yml`
disparam em `push` só na `main` e em `pull_request`; o `balanceamento.yml` é
semanal ou à mão. Até o PR abrir, «verde» quer dizer «verde neste contêiner»,
e o APK — o que este contêiner não mede — ainda não foi exportado por ninguém.
A lição viveu em trinta briefings (18/09 → 24/09) com esta linha a dizer «a
cada push», e caiu do seguinte sem uma palavra (`057`).

O resto do que esta seção dizia — o `.pck`, a VRAM e as chaves do Godot, o
Windows, o byte a byte dos mapas — está em `.claude/rules/plataforma.md`,
`gerais.md`, `captura.md` e `mapa.md`.

---

## Antes de fechar qualquer mudança

> A skill **`/fechar-sessao`** conduz esta lista inteira — mais a varredura do
> que se aprendeu e o `ESTADO_DO_PROJETO.md`. Esta seção continua aqui porque é
> o que carrega sozinho; a skill é para quando se chega ao fim de um bloco.

1. `tests/run_tests.gd` — a lógica. Espera `TODOS OS TESTES PASSARAM`.
2. `tests/teste_design.gd` — o encaixe e o layout. Espera `DESIGN OK`.
   `tests/teste_audio.gd` — o encanamento de som. Espera `AUDIO OK`.
   `tests/teste_fumaca.gd` — a cena abre, o ícone existe, o save não migra.
   Espera `FUMACA OK`.
   `tests/teste_registro.gd` — o gravador de partida. Espera `REGISTRO OK`.
   `scripts/validation/asset_validator.gd` — o contrato dos assets. Espera
   `ASSET OK`.
   ⚠️ **SÃO SEIS, e esta lista dizia quatro.** O `teste_registro` entrou no CI
   em 02/09 e não era citado em documento nenhum dos seis que o repetiam —
   nem aqui, nem no hook, nem nas três skills, nem no `COMO_RODAR`. Quem
   manda hoje é o `testes.yml`, e `tools/conferir_docs.py` reprova quem
   divergir dele (`docs/decisoes/032`).
3. Mexeu no `GameState.gd`, em QUALQUER linha? Regere a tabela dos números —
   `despejar_constantes.gd` + `tools/gerar_tabela_numeros.py --contra-godot`,
   espera `TABELA OK`. Ela é gerada do código, e o CI reprova se envelhecer:
   os números já viveram no GDD e nas constantes ao mesmo tempo, e divergiram.
   A armadilha da coluna «Onde» está em `.claude/rules/economia.md`.
4. Mexeu em preço ou constante `# TUNING:`? A skill **`/balancear`** conduz a
   medição. O alvo, a medição em vigor e as lições do simulador estão em
   `.claude/rules/economia.md`, que carrega ao abrir o `GameState.gd` ou o
   simulador.
5. Mexeu no visual? **Tire uma captura e olhe.** Teste verde não prova que
   ficou bonito. O CI já anexa TODAS a cada PR (artefato `brport-captura`) e
   diz na página da corrida qual mudou — mas dizer que mudou não é dizer que
   ficou bom, e essa parte continua a ser de quem olha. **Cinco delas mostram
   uma PARTIDA SORTEADA**, e o que varia com o sorteio não se prova ali: para
   isso são as duas folhas de contato, a dos ícones e a da frota.
   As armadilhas — semente, passo fixo, o `MapaWrap` — estão em
   `.claude/rules/captura.md`.
6. **Captura de painel** pede o tema, o `setup()` e uma partida JOGADA; as
   razões e a cobertura por painel, tempo e cara estão em
   `.claude/rules/captura.md`.
7. Escreveu um validador e ele **passou de primeira**? Desconfie. Injete o
   defeito que ele deveria pegar e veja-o reprovar antes de confiar nele. Um
   validador que nunca reprovou nada não é um validador — e, na primeira vez
   que se fez isto aqui, quem estava furado era o teste, não o validador.
   As maneiras como isto já falhou estão em `.claude/rules/gerais.md` (as
   que valem para qualquer régua, e carregam sempre) e em
   `.claude/rules/testes-e-guardas.md` (as de suíte e de guarda).

---

## As regras que já custaram trabalho

Vivem em `.claude/rules/`, uma por tema (`docs/decisoes/091`). **Este núcleo e
as regras gerais carregam em toda sessão**; cada regra de tema carrega quando a
sessão LÊ ou EDITA um arquivo que casa com o `paths:` dela — pelo Read, Edit ou
Write, ou por um `cat`, `head`, `sed -n` ou `grep` de um arquivo só; um `grep`
pela árvore não carrega nada (`092`). Uma pergunta sem arquivo aberto
não as vê: abra a regra do tema antes de responder, ou use `/arte` e
`/balancear`, que existem para isso. O Codex não as carrega sozinho; o
`AGENTS.md` lista-as para ele. Lição nova vai para a regra do tema dela; regra
nova, ou `paths:` novo, passa no `tools/conferir_docs.py`, que exige a forma
`paths:` + `  - "glob"`, globs que casem com algum arquivo e a linha da regra
nas tabelas deste núcleo e do `AGENTS.md` — e um teto para o que carrega sempre.

| Regra | Carrega sozinha ao abrir | O que traz |
|---|---|---|
| `.claude/rules/gerais.md` | **sempre** | como uma régua mente e um defeito injetado deixa de provar; edição que apaga arquivo; git e briefing no arranque |
| `.claude/rules/projecao.md` | os dois geradores, `blender/`, `Main.tscn`, `Dock.tscn`, `PropIso.gd`, `TrafegoDeCamioes.gd`, as âncoras | o contrato da projeção: os dois espaços, a altura, o quadro de 512, a ordem de nó |
| `.claude/rules/mapa.md` | `tools/gerar_mapa_iso.py`, os mapas, as réguas do enquadramento, `TrafegoDeCamioes.gd` | costa, água, vila, rua, o raster que o CI compara byte a byte |
| `.claude/rules/arte.md` | `blender/`, `art_lab/`, `brport_vs/art/`, as ferramentas de prop | props, Blender, retratos, cor e forma de um prop |
| `.claude/rules/testes-e-guardas.md` | `brport_vs/tests/`, as validações, `tools/conferir_*`, as réguas, os workflows | escrever a guarda e escolher o defeito injetado |
| `.claude/rules/economia.md` | `GameState.gd`, o simulador, o projetor, a tabela dos números | **o balanceamento medido em vigor**, guindastes e obras da Fase 1 |
| `.claude/rules/save.md` | `GameState.gd`, `ArmazemLocal.gd`, `teste_fumaca.gd` | a versão, a recusa e os três espaços |
| `.claude/rules/interface.md` | as cenas, o tema, os painéis, `Main.gd` | tela, cor, contraste, rótulo |
| `.claude/rules/narrativa.md` | `Narrativa.gd`, `Retratos.gd`, os painéis de fala | fala, nome, número e concordância |
| `.claude/rules/audio.md` | `Audio.gd`, `gerar_sons.py`, `medir_audio.py` | o som que ninguém aqui ouve |
| `.claude/rules/captura.md` | as ferramentas de captura e as folhas de contato | a foto que prova, e a que mente |
| `.claude/rules/plataforma.md` | `project.godot`, o export, os workflows, o hook | APK, Web, `.pck`, VRAM, chaves do Godot |
| `.claude/rules/gdscript.md` | qualquer `.gd` | as armadilhas do GDScript |

**Onde foi parar cada seção antiga.** O código e os documentos citam «`CLAUDE.md`,
Arte» e afins, de antes de 10/10; as citações continuam a valer por esta
tabela, e cada regra guarda o título da seção de onde veio. Um «a regra acima»
ou «irmã de» pode apontar hoje para outro arquivo: o `CLAUDE.md` inteiro, como
era, está no commit `9961742`.

| Seção citada | Hoje |
|---|---|
| «Como rodar» | aqui; o pacote, a VRAM e as chaves do Godot em `plataforma.md`, o byte a byte em `mapa.md`, o Windows em `gerais.md` e `captura.md` |
| «Antes de fechar», itens 1 a 7 | aqui, o passo de cada item; as lições do 3 e do 4 em `economia.md`, do 5 e do 6 em `captura.md`, do 7 em `gerais.md` e `testes-e-guardas.md` |
| Projeção isométrica | `projecao.md` |
| Tudo o que vive em terra | `mapa.md` |
| Guindastes e Obras da Fase 1 | `economia.md` |
| Save | `save.md` |
| Arte | `arte.md`; o desenho do mapa em `mapa.md`, as provas em `testes-e-guardas.md`, a cor de interface em `interface.md`, a prova visual em `captura.md`, os irmãos em `gerais.md` |
| Áudio, Narrativa, Interface | `audio.md`, `narrativa.md`, `interface.md` |
| O que cabe numa sessão | aqui; o briefing e o git em `gerais.md` |
| Estilo de código | aqui, o essencial; o GDScript em `gdscript.md`, a edição e o relatório em `gerais.md`, a suíte em `testes-e-guardas.md` |

---

## O que cabe numa sessão

Uma sessão que tenta fazer tudo entrega tudo pela metade, e a seguinte não sabe
o que ficou por acabar. Meia página para evitar isso.

⚠️ **E O TETO DO ESTADO RECUSA DEPOIS DE O COMMIT ESTAR ESCRITO, que é o
momento em que menos apetece parar.** Em 14/09 o fecho encadeou
`conferir_docs.py && git commit` sem olhar: o conferidor reprovou por 202 bytes,
o `&&` não segurou nada porque o commit vinha de um comando à parte, e a sessão
empurrou com o CI vermelho. Comprimir custou três minutos e não dependia de
pensar em nada — **o custo era só a vontade de ter acabado**. Num fecho, rode
TODAS as verificações e leia o código de saída de cada uma **antes** de escrever
a mensagem de commit, e nunca no mesmo comando que ela.

**Uma sessão fecha com o `ESTADO_DO_PROJETO.md` em dia, ou não fecha.** É o
único artefato crítico que nenhum teste protege — e quando envelhece, a sessão
seguinte trabalha com uma fotografia errada. Em 02/09 ele tinha dobrado de
tamanho sem ninguém decidir, e carregava dentro DUAS parcelas do Sr. Ribeiro
(R$8.000 e R$550.000) e três respostas diferentes para "por onde começo", todas
lidas como atuais. Hoje `tools/conferir_docs.py` toca o alarme antes de dobrar
outra vez, mas o alarme não escreve o documento.

**Prometa UM item da fila, não três.** A fila da §7 do plano é ordenada, e os
itens têm tamanhos honestos: um item por sessão é o ritmo que os últimos blocos
mediram. Sobrou tempo? Comece o seguinte e diga onde parou — melhor do que três
metades.

**Meça antes de codar, e o custo de medir quase nunca é o que se supõe.** Três
vezes em dois dias a suposição estava errada e nas três para o lado caro: a
barra de reputação que se ia afinar já estava saturada no teto; as 600 partidas
que se evitavam por "demorarem minutos" levam 26 segundos; e a `/arte` foi
adiada por "precisar de 1 GB de `bpy`" quando metade das etapas não precisa de
Blender nenhum e o conferidor de lote precisa de `numpy` + `pillow`, que
instalam em 8. Rodar a ferramenta antes de decidir é mais barato do que
discutir o que ela diria.

### Qual MODELO faz o quê — Sonnet por omissão, Opus para decidir

`docs/decisoes/016`. **Sonnet 5 custa 2,5× menos do que Opus 5 nas duas
pontas**, e este projeto usava Opus em tudo. O eixo que divide NÃO é "difícil
contra fácil" — escrever um script de medição parece mais difícil do que olhar
para um render, e é o contrário. **O eixo é quem ESCOLHE.**

**A omissão é Sonnet.** Ele faz o que já foi decidido, e o projeto tem a receita
escrita: rodar as suítes e ler o código de saída de cada uma; regerar mapas,
props, sons e a tabela dos números; `--import`, capturas, recortes, folhas de
contato e o antes/depois; aplicar uma alteração de cor, ângulo ou proporção JÁ
escolhida e medir o que foi pedido; arrastar o rasto de prosa a partir de uma
decisão já escrita; comprimir o `ESTADO_DO_PROJETO.md` para caber no teto;
`grep`, inventário e `conferir_docs.py`; consertar vermelho de causa óbvia
(import a faltar, caminho errado, `.import` por commitar); commit e push.

**Sobe para Opus quando a sessão tem de DECIDIR:**

- diagnosticar uma queixa que não diz o que corrigir — *"o design pode ser
  melhorado"*, *"está sem graça"*, *"parece avançado demais"*;
- escolher a gramática de um prop, ou o que substitui uma peça que não lê;
- **escrever asserção nova e escolher o defeito injetado** (ver abaixo);
- ler uma medição que contrariou a previsão e decidir o que ela quer dizer;
- qualquer `# TUNING:`, e a leitura das 600 partidas;
- reabrir decisão registada, ou mexer em contrato entre arquivos — projeção,
  `MEIA_LARG`, `RUA_RECUO`, enquadramento, `SAVE_VERSION`;
- triar playtest e ordenar a fila;
- escrever `docs/decisoes/NNN` e a varredura de lições do `/fechar-sessao`.

⚠️ **O DEFEITO INJETADO NUNCA DESCE, e é por medição.** A regra 7 acima tem doze
parágrafos de maneiras de um defeito injetado não provar nada, e cada um é um
caso real em que se acreditou num validador que nunca tinha visto defeito
nenhum. É o sítio do projeto onde poupar sai mais caro.

### As SETE FASES de uma sessão, numeradas — diga o número, e o modelo sai daí

Esta é a tabela a citar em conversa: **"estou na F3"**, **"pare na F4"**. Ela
vale para qualquer item da fila; as três skills trazem a versão delas, com os
mesmos números.

| # | Fase | O que é | Modelo |
|---|---|---|---|
| **F1** | **Escolher e desenhar** | ler a fila, escolher o item, e desenhar a MEDIÇÃO — que constante varrer, em que intervalo, contra o quê, e o que conta por bom | **Opus** |
| **F2** | **Medir o ANTES** | rodar o que a F1 desenhou: 600 partidas por perfil, ou a bateria de capturas, ou a varredura. É receita e não tem escolha nenhuma dentro | **Sonnet** |
| **F3** | **Ler a medição** | dizer o que o número quer dizer, e decidir se contraria a previsão | **Opus** |
| **F4** | **Decidir a mudança** | qual `# TUNING:`, qual cor, qual ângulo, qual gramática — e quanto | **Opus** |
| **F5** | **Aplicar e remedir** | escrever a alteração já escolhida e correr a mesma medição da F2 | **Sonnet** |
| **F6** | **Asserção nova** | escrever a guarda que faltava e escolher o DEFEITO INJETADO. ⚠️ Nunca desce, por medição — ver o aviso acima | **Opus** |
| **F7** | **Fechar** | as suítes, o rasto de prosa pelos documentos, o `ESTADO_DO_PROJETO.md` no teto, o commit e o push | **Sonnet** |

**A F6 não acontece em toda sessão** — só quando a mudança descobre uma
pergunta que nenhuma guarda fazia. Quando acontece, ela volta a subir e o resto
da F7 desce outra vez.

⚠️ **A F3 é a que se perde com mais facilidade, e é a mais cara de errar.** É
tentador deixar a F2 correr direto para a F5 porque "o número está ali" — mas o
número não diz o que fazer com ele, e a taxa de vitória é o valor mais fácil de
ler errado deste projeto. Entre medir e mexer há sempre uma leitura.

**A regra de paragem, que é o que torna isto seguro: a sessão barata NÃO
decide.** Ao encontrar uma cor, um ângulo ou uma proporção por escolher; uma
asserção nova, ou um defeito injetado que não reprovou; um `# TUNING:`; uma
medição que contraria o que estava escrito; ou um teste vermelho cuja causa não
é óbvia numa leitura — **pare e devolva**, em vez de escolher. E o contrário
vale igual: assim que a decisão estiver escrita na `docs/decisoes/`, o resto da
sessão desce para Sonnet, que costuma ser a maior parte dela.

⚠️ **E O QUE CUSTA NUMA SESSÃO LONGA NÃO É O MODELO, É A CONVERSA.** A premissa
da `016` é a razão de preço entre os dois, e ela está certa — mas medido nesta
sessão ao fim de nove dias e cinco itens: **672 mil tokens de contexto, 65
MILHÕES de tokens de leitura de cache**, e a maior parte do gasto não é produzir
trabalho novo, é reprocessar o histórico a cada turno. Daí três coisas:

- **trocar de modelo a meio** continua a carregar o contexto todo, só que a
  preço mais baixo — ajuda menos do que parece;
- **sessão NOVA no modelo certo**, apontada ao documento que descreve o ponto
  de partida, arranca perto de zero e corta muito mais;
- por isso é que o desenho de uma medição vive num DOCUMENTO e não só na
  conversa: é o que torna a sessão descartável sem perder o trabalho.

Os avisos de briefing e de git que viviam aqui — a fonte de um buraco
previsto, o `diff --stat`, o `fetch` de dois refs, o PR fundido — estão em
`.claude/rules/gerais.md`, que carrega sempre.

⚠️ **Nenhum modelo troca o próprio modelo — quem troca é o Bruno**, com
`/model`. O que a sessão faz é ANUNCIAR numa linha qual modelo o próximo bloco
pede, antes de o começar, e parar quando for para cima. Sob pedido dele, um
bloco fechado de execução pode ir para um subagente com `model` próprio.

**Quando abrir um subagente de varredura, e quando não.** Vale quando a
pergunta é "onde está X" numa área que não se conhece e a resposta cabe em
linhas — ele lê muito e devolve pouco. Não vale para ler um arquivo que já se
sabe qual é, para uma edição, nem para nada que precise do julgamento de quem
está na conversa: ele arranca frio e re-deriva o contexto que esta sessão já
tem. Na dúvida, `grep` primeiro.

**O que se aprendeu vai para onde se lê, antes de a conversa fechar.** A
varredura do `/fechar-sessao` mediu dez de doze lições já registradas à medida
que o trabalho andava — a skill existe para as outras duas. Regra que vale
sempre entra neste arquivo; por que se decidiu assim, em `docs/decisoes/`;
armadilha de uma função, no comentário dela.
⚠️ **E O BRIEFING NÃO É DESTINO — é a saída da varredura.** Ele lê-se uma vez
e morre: todo aviso que ele cita nomeia onde a lição vive, e o
`tools/conferir_docs.py` reprova o do briefing mais recente que não nomear.
Medido em 24/09: 249 dos 306 avisos do arquivo não apontavam para lugar
nenhum (`057`).

---

## Estilo de código

- **`GS` é destipado, e `var x := GS.qualquer_coisa` NÃO compila.** As
  ferramentas e os testes pegam o autoload por `root.get_node("GameState")`,
  que devolve um `Node` sem tipo, e o Godot recusa-se a inferir a partir dele:
  *"Cannot infer the type of X because the value doesn't have a set type"*.
  Escreva o tipo à mão — `var x: float = GS.RIVAL_KEEP_CHANCE`. Isto mordeu
  três vezes num dia só, em três arquivos diferentes, e cada vez custou uma
  corrida: **o Godot encerra com código 0** nesse erro, então quem olha só o
  `$?` conclui que passou.
- Comentário explica **por que**, e de preferência conta o que se tentou antes
  e não funcionou. O repositório inteiro é escrito assim; siga.
- Nada de emoji na interface — os ícones vivem em `art/icones/` e são
  registrados em `scripts/Icones.gd`.
- `.gd.uid` e `.import` **entram no Git** (o `.gitignore` explica por quê).

O resto do estilo está nas regras: o GDScript em `.claude/rules/gdscript.md`,
a edição e o relatório em `gerais.md`, a suíte em `testes-e-guardas.md`.
