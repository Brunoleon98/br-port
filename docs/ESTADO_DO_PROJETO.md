# BR Port — Estado do Projeto

> **Como o jogo está hoje.** É a segunda das quatro camadas de documentação
> deste projeto, e a única que nenhum teste protege — se envelhecer, envelhece
> calada.
>
> **Última atualização:** 03/09/2026
>
> | Precisa saber | Leia |
> |---|---|
> | O que nunca se faz aqui, e como rodar Godot e Blender | `CLAUDE.md`, na raiz — **carrega sozinho, não precisa abrir** |
> | Como o jogo está hoje | este arquivo |
> | O que fazer a seguir, e quais itens só o Bruno fecha | `docs/design/BR_Port_Plano_v3_Claude_Code.md` |
> | Por que se decidiu assim | `docs/decisoes/NNN-*.md`, uma por arquivo |
>
> São **dois** documentos para retomar o trabalho: este e o plano. Até 02/09
> eram cinco em cadeia — este mandava começar por um briefing de 29/08, que
> mandava ler outro, e a tabela abaixo apontava para um terceiro. O caminho
> percorrido está em `docs/arquivo/HISTORICO.md`; o que aconteceu em cada
> sessão, em `docs/arquivo/`.

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador, R$400.000 e cinco estruturas
para consertar — píeres 2 e 3, armazém, pátio e escritório. Comprar cada uma
muda o mapa: o pátio sai de terra batida para asfalto com carga, os prédios
saem de ruína para telhado novo.

**O botão que move o jogo tem cor própria desde 02/09** — "Avançar dia" passou a
âmbar com rótulo navy (medido: branco sobre âmbar reprova a WCAG, navy passa), e
os cartões claros ganharam sombra deslocada e borda de 2px. Antes eram dois
botões navy iguais na barra inferior. **Os cartões escuros ficaram como estavam,
de propósito:** a sombra do tema é mais clara que o fundo deles, e desenharia um
halo.

**A água é tropical desde 02/09.** O mapa era de mar frio (`#4a96b4`) num jogo
cujo cenário é o litoral brasileiro; a paleta passou a turquesa com os valores
amostrados das imagens de referência — primeira metade da Etapa 1 do plano de
arte. O enquadramento (`MEIA_LARG`) e a faixa de areia continuam por fazer, e o
plano de arte diz por quê.

**O jogo é TRANQUILO, e os valores são realistas** (02/09). Medido em 600
partidas por perfil: ótimo 100% · mediano 79,5% · descuidado 35,7%, com a
mediana do mediano em R$685.271 contra uma parcela de R$550.000. Um contrato
vale R$8.000–70.000, a manutenção custa R$40.000/semana e reconstruir um píer
custa R$150.000 — números de porto, não de banca de feira.

A dívida deixou de ser o motor (`docs/decisoes/005`): quem separa os jogadores
agora é **o porto que conseguem levantar** — 46,3 barcos atendidos contra 12,5.
Mexer em preço sem rodar `simular_balanceamento.gd` quebra isto.

**A partida grava-se desde 02/09.** Uma linha JSON por turno, por semana, por
obra e por contra-oferta, num `.jsonl` por partida — com quanto tempo o jogador
ficou em cada turno, que é a pergunta do A7 que nenhuma outra medida responde.
O nome de quem jogou NÃO entra no arquivo (`docs/decisoes/006`). O menu de pausa
tem "Copiar registro da partida", que é a única porta que ele tem para sair de
um telefone; `tools/ler_registros.py` lê vários de uma vez e resume.

**O jogo tem som.** Dez efeitos sintetizados por `tools/gerar_sons.py`, um
autoload `Audio.gd` com dois buses (Música e SFX), sliders de volume no menu de
pausa e todo o disparo ligado aos sinais do `GameState`. Os efeitos são de
RASCUNHO — a música e os sons finais do Suno/ElevenLabs entram trocando arquivo
por arquivo, sem mexer em código. **Ninguém que os fez os ouviu:** o contêiner
não tem placa de som (ver `docs/design/BR_Port_Plano_Audio.md` §2).

**Não se arrasta trabalhador a cada turno:** há "Alocar todos" e
toque-para-alocar, com o arrasto ainda funcionando.

**Nada de interface pousa sobre o mapa.** A doca tem duas metades: a vaga no
mapa (píer, barco, guindaste, trabalhador) e o cartão na barra logo abaixo
dele (valor, turnos, trabalhador). Os nomes dos lugares são placas com mastro,
e o número de cada doca está pintado no cais.

**O porto tem uma cidade atrás dele.** Rua paralela ao cais, calçada, acesso a
cada berço, e uma fileira de casas. A vila tem nível (`--nivel-vila=N` no
gerador do mapa): 1 é casa térrea, 2 sobrado, 3 prédio — é assim que ela cresce
a cada Fase, sem o jogo precisar saber.
---

## Onde estamos na fila

**A fila em vigor é a §7 do plano** — ela é que diz o que vem a seguir e quais
itens param à espera do Bruno. Aqui fica só a posição.

**Fechados**, dos quinze itens: B1 (arranque de sessão), A2 (números com fonte
única), A3 (reputação com efeito), A4 (as sete telas narrativas — construídas),
B4 (fumaça de cena), B3 (o CI publica captura e antes/depois), B5 e B8
(documentação em camadas e orçamento de sessão), B6 (o GDD legível), B2 (as
três skills: `/balancear`, `/fechar-sessao` e `/arte`), B7 (o registro de
partida), e a metade de máquina do A1 (APK e build Web a cada push).

**A trilha do projeto acabou** — B1 a B6 e B8 estão todos fechados.

**Abertos e esperando o Bruno** — nenhum deles precisa de uma sessão ligada:

| Item | O que falta | Por que só ele |
|---|---|---|
| **A1** | ~~Jogar dez minutos no APK~~ — **a primeira passagem aconteceu em 02/09**, e o que ela achou está em `docs/arquivo/PLAYTEST_01_ANALISE.md`. O que fica aberto é a passagem SEGUINTE, depois de a fila abaixo andar | Ver leitura abaixo |
| **A4** | Ler as falas em voz alta | Três desvios do rascunho de escrita esperam esse julgamento, listados no A4 do plano. Não há como julgar fala sem a dizer |
| **A5** | Olhar cada antes/depois da arte | **Três etapas feitas** — a 1 (paleta tropical do mapa), a 6 (o botão âmbar e a sombra nos cartões claros) e a 2 (a cauda dos props: contêiner, caixote, boia e marcador). Faltam a 3, a 4 e a 5, e a metade cara da 1 (`MEIA_LARG`) |
| **A6** | Ouvir | Este contêiner não tem placa de som. Ninguém que fez os efeitos os ouviu |

### O que a primeira jogada no telefone devolveu (02/09)

O A1 pagou-se logo: um **bug que trava o jogo** que nenhuma das cinco suítes
podia ver. `_spawn_boats()` abre contra-oferta em 30% dos jogos novos, isso
corre no autoload antes de o `Main` existir para ouvir o sinal, e o `Main`
saltava a recuperação de fase quando tinha de pedir os nomes — **30% das
instalações novas ficavam presas no dia 1**, sem uma linha de erro.
Corrigido em `Main.gd` e trancado pelo bloco F6 do `teste_fumaca.gd`.

O segundo defeito relatado — **o escritório em cima da rua** — também está
corrigido, e não era um prop mal posto: o pátio tinha 1,68 unidades de largura
e o armazém ocupa 3,76. Os dois prédios transbordavam para o asfalto. O pátio
passou a 4,18 (`RUA_RECUO` 4,3 → 6,8, com a vila a recuar junto), e o bloco D2
do `teste_design` — que olhava um prop e um ponto — passou a varrer o cenário
inteiro e a medir a **pegada** contra as faixas. Custo medido: dois lotes da
vila saíram do quadro, de 11 para 9.

O resto da análise está triado em `docs/arquivo/PLAYTEST_01_ANALISE.md`, em
cinco gavetas, **nenhuma delas um bug**: **arte** (pedras, vegetação,
animações, sprite do trabalhador = Etapa 5), **interface** (cinco itens novos, sem
gate — **um feito em 03/09**: o aviso de trabalhador parado, que agora tem
cartão próprio e conta quantos são), **economia** (três itens que só passam pelo `/balancear`),
**desenho de sistema** (escopo de Fase 2 em diante) e **escrita** (dois, um
deles à espera do A4).

**Livres, sem gate:** A8. O **B7 fechou em 02/09** — o registro de partida e o
leitor que o resume. Ele destrava o A1: os dez minutos no APK passam a produzir
um arquivo em vez de só uma impressão.

Da arte, **três das seis etapas estão feitas** — a 1 (paleta), a 6 (o chrome da
interface) e a 2 (a cauda dos props, 02/09). Faltam a 3 (contorno pelo
compositor), a 4 (materiais dirigidos) e a 5 (rosto do trabalhador), todas com
`bpy`, mais a metade cara da 1 — o enquadramento.

**O enquadramento deixou de estar bloqueado em 03/09:** o Bruno escolheu
`MEIA_LARG = 20` olhando o mapa gerado em três larguras, e a leitura de
composição das cinco referências está escrita em
`docs/design/referencias/README.md` (inclusive onde vai a areia: nas pontas da
costa, não entre a água e o cais). Só que **medido, em 20 o mundo acaba dentro
do quadro** — então a ordem é estender a costa primeiro e mexer na projeção
depois. O plano de arte tem a tabela.

### A pergunta da Fase 2 — adiada de propósito (03/09)

**Decisão do Bruno: responde-se quando a Fase 2 for feita, e não antes.** Ela
não é pendência aberta nem trava sessão nenhuma — é uma nota presa ao trabalho
da Fase 2, para quem o abrir a ler antes de codar a economia. O que continua a
valer é a regra: **codar a economia da Fase 2 sem a responder é construir em
cima de uma pergunta**, e por isso o item começa por aqui.

O valor de contrato cresce ×2,9 e depois ×2,5 por fase; a parcela cresce ×2,0 e
×1,5. **A receita corre mais depressa do que a dívida**, então a tensão que faz
a Fase 1 medir o que mede desaparece a partir da semana 5. Subir as parcelas,
assumir que é de propósito, ou trocar o que pressiona — **não está decidido**, e
codar a economia da Fase 2 sem resolver isto é construir em cima de uma
pergunta — resolver, quando chegar a altura. Os números e o modo de refazer a conta estão em
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.

É **projeção, não medição**: a Fase 1 é medida no jogo que existe, as outras
duas são a mesma conta com os números que o GDD dá para elas.

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `brport_vs/tests/run_tests.gd` | ~72 asserções de regressão (a lógica), incluindo `T5f` — a reputação a mexer na contra-oferta |
| `brport_vs/autoload/Audio.gd` | **O ponto único que toca som** — prioridade por frame, espera mínima por som, volume por bus |
| `tools/gerar_sons.py` | Gera os 10 efeitos de rascunho. Sem dependência: só biblioteca padrão |
| `brport_vs/tests/teste_audio.gd` | **Teste de áudio** — cobre o que dá para provar sem ouvir |
| `brport_vs/autoload/Registro.gd` | **O gravador de partida** — uma linha JSON por acontecimento. Nasce DESARMADO: quem arma é o `Main._ready()`, senão o simulador de balanceamento gravaria 1.800 arquivos |
| `tools/ler_registros.py` | **O leitor** — resume N partidas de uma vez, e põe o jogador MEDIDO ao lado dos perfis que o simulador supõe |
| `brport_vs/tools/gravar_partidas.gd` | Joga N partidas com o gravador armado. Existe para o CI pôr gravador e leitor a encontrar-se — são dois arquivos em duas linguagens que nada obriga a concordar |
| `brport_vs/tests/teste_registro.gd` | **Teste do registro** — o `WRITE` que trunca, o teto, o relógio, e sobretudo que o gravador NÃO grava quando não foi armado. Espera `REGISTRO OK` |
| `brport_vs/tests/teste_design.gd` | **Teste de design** — se os props caem em cima do que o mapa desenhou, se a ordem dos nós respeita a profundidade e se a interface cabe na tela |
| `brport_vs/tests/teste_fumaca.gd` | **Teste de fumaça** — toda `.tscn` do projeto instancia (achadas por varredura, não por lista), todo ícone de `Icones.gd` tem arquivo, o save de outra versão é descartado sem tocar no estado vivo, e nenhum `{token}` de texto chega cru à tela |
| `brport_vs/scripts/Narrativa.gd` | **Todo o texto de fala, num lugar só** — diário, os 3 tons da Dona Cida, as 8 falas de loop, o Arlindo, o Sr. Ribeiro e o fim de fase. Os números da narração saem das constantes, nunca escritos à mão |
| `brport_vs/scripts/PainelNarrativo.gd` | O andaime das telas narrativas — escurecer, cartão, título, parágrafo, botão. `montar(largura, 0)` ajusta o cartão ao conteúdo |
| `brport_vs/scripts/TelaNomes.gd` | A tela de abertura: o jogador batiza o cais e diz o nome. Escolha irrevogável (GDD 7) |
| `brport_vs/scripts/PainelDiario.gd` | A primeira página do diário do avô, encadeada à tela de nomes |
| `brport_vs/scripts/PainelBoletim.gd` | O Boletim Financeiro da Dona Cida, no fecho de cada semana — receita e despesa por fonte, e o tom dela conforme o resultado |
| `brport_vs/tools/recortar_captura.gd` | Recorta e amplia um pedaço de captura, sem suavizar. A 19px um ícone não se julga a olho |
| `docs/design/referencias/` | As imagens que definem o alvo de arte + a leitura escrita delas |
| `docs/design/BR_Port_Plano_Arte_Blender.md` | **O caminho medido** até o nível da referência: o que o Blender alcança, o que não alcança, e em que ordem atacar |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta do protótipo HTML, cantos, botões, cartão de doca, cartão de trabalhador e letreiro. Os tokens de cor de mapa saíram daqui em 30/08: quem os define é o gerador do SVG |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem o mapa, os letreiros e a barra de docas |
| `brport_vs/scenes/dock/Dock.tscn` | A metade de CENÁRIO de uma doca: píer, barco, guindaste, trabalhador |
| `brport_vs/scenes/dock/DocaCartao.tscn` | A metade de INTERFACE da mesma doca: valor, turnos, trabalhador, alvo de toque |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/art/sprites/` | Sprites prontos (trabalhador, cargueiro, barco de pesca, caminhão, guindaste) |
| `brport_vs/art/icones/` | **Os 20 ícones da interface**, em SVG chapado |
| `brport_vs/scripts/Icones.gd` | Registro dos ícones + helpers de rótulo e botão — o único lugar que sabe qual arquivo é qual ícone |
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs gerados por IA e redimensiona — rodar a cada leva nova |
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo — inclui a malha viária, a vila (`--nivel-vila=N`) e os números de doca pintados no cais |
| `tools/gerar_props_iso.py` | Gera os props isométricos (píer, barcos, guindaste, coqueiro, galpão, cenário) em Blender por script, na projeção do mapa. Confere a própria projeção ao fim |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor |
| `brport_vs/tools/folha_icones.gd` | Folha de contato dos ícones nos 3 fundos da interface, a 19px e ampliado — **rodar a cada ícone novo** |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows) |
| `tools/conferir_lote_de_arte.py` | Confere lote de arte vindo de fora: alfa de verdade, tamanho e **ângulo da base contra o contrato de 26,57°**. Rodar antes de qualquer PNG externo entrar |
| `docs/BRP_SPATIAL_CONTRACT.md` | **O contrato da projeção por escrito** — as constantes, os quatro participantes e a regra que faltava no guia do pacote de arte: `ROT_X = 60°` |
| `blender/brp_studio.py` | O estúdio compartilhado — importa a câmera de `gerar_props_iso.py` em vez de a duplicar. Âncora, volume de seleção, nomenclatura e manifest |
| `blender/gerar_brp.py` | Roda um estúdio (`terreno`, `porto`, `cidade`, `fauna`), exporta os PNGs e junta o manifest. Um estúdio por processo — `preparar_cena()` apaga a cena inteira |
| `blender/validate_brp_assets.py` | Validador do lado do Blender: âncora, apoio ao solo, escala, coleção. **Não roda no CI** — precisa de ~1 GB de `bpy` |
| `brport_vs/scripts/validation/asset_validator.gd` | Validador do lado do Godot: quadro, alfa, recorte e **a projeção do manifest contra as âncoras do mapa**. Roda no CI, espera `ASSET OK` |
| `.claude/skills/fechar-sessao/SKILL.md` | **O ritual de fecho** — o que rodar conforme o que mudou, a captura, a varredura do que se aprendeu e o commit |
| `.claude/skills/arte/SKILL.md` | **O ritual da arte** — qual etapa precisa de Blender, a armadilha de trocar matiz sem olhar o valor, o recorte ampliado, e o rasto que a mudança envelhece |
| `.claude/skills/balancear/SKILL.md` | **O ritual da economia** — medir antes e depois com a mesma semente, separar escala de ratio, e arrastar atrás os oito lugares que afirmam o balanceamento |
| `.claude/hooks/session-start.sh` | **O arranque da sessão** — baixa o Godot, importa o projeto, deixa o `$G` pronto. Nunca derruba a sessão: todo caminho de erro devolve a receita manual |
| `.godot-version` | A versão do Godot, num lugar só. Lida pelo hook e pelo CI |
| `docs/design/BR_Port_Numeros_Fase_1.md` | **A tabela dos números, GERADA** do `GameState.gd`. Não editar à mão — o CI reprova se envelhecer |
| `tools/gerar_tabela_numeros.py` | Gera a tabela acima e cruza a leitura de texto com o que o Godot avalia |
| `brport_vs/tools/despejar_constantes.gd` | Despeja as constantes que o Godot avalia de verdade, em JSON. Espera `CONSTANTES OK` |
| `tools/projetar_parcelas.py` | Projeta as Parcelas 2 e 3 a partir da Fase 1 MEDIDA. Recusa-se a projetar se o modelo não reconstruir a Fase 1 |
| `docs/design/` | GDD 7, guias, Validation Guide, e o Roadmap v2.1 + Plano da Fase 2 (superados no cronograma, mantidos como registro das decisões) |
| `index.html` (raiz) | O protótipo HTML original, já validado |

| `tools/capturar_evidencia.sh` | **As cinco fotografias que provam o que ficou** — semente e passo de tempo fixos, painéis conferidos, tela chapada reprovada. É o que o CI roda a cada PR |
| `.github/workflows/testes.yml` | A suíte, a tabela dos números, os sons, as âncoras, e o export do APK e do Web |
| `.github/workflows/captura.yml` | As cinco imagens anexadas a cada PR, e o antes/depois contra a base |
| `.github/workflows/balanceamento.yml` | As 600 partidas por perfil, às segundas e sob demanda |
| `tools/conferir_docs.py` | Confere que as quatro camadas existem e que nenhuma referência de documento aponta para arquivo que não há |
| `docs/arquivo/` | O que aconteceu em cada sessão que já fechou. **Nada se apaga** — o índice está no `docs/arquivo/README.md` |
| `docs/gdd/` | **O GDD 7 legível**, 80 páginas GERADAS do `.jsx` — uma seção por arquivo. Não editar. Descreve as Fases 1 a 5 e está congelado antes da reescala: onde divergir do jogo, quem manda é o código |
| `tools/gerar_gdd_md.py` | Gera as 80 acima. Recusa-se a adivinhar: forma de dado que ele não conheça **reprova**, em vez de sumir do markdown |
### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Drag-and-drop de trabalhadores para as docas
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas) — e ela **decide a contra-oferta**:
  reputação alta faz o cliente aceitar pagar cheio com mais frequência
  (`docs/decisoes/003`)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- Parcela única de **R$550.000** ao Sr. Ribeiro, vencendo ao fim da semana 4
  (8 turnos por semana, 4 semanas — 32 dias de partida)
- **Cinco estruturas para reconstruir** — píer 2, píer 3, armazém, pátio e
  escritório —, cada uma mudando o mapa. O porto abre em ruínas com 1 doca
- Autosave local a cada turno
- **Sete telas narrativas**: nomes do cais e do jogador (abertura), primeira
  página do diário, Boletim Financeiro semanal com os 3 tons da Dona Cida, as 8
  falas de loop dela, as falas do Arlindo na negociação, a cena da parcela com
  o Sr. Ribeiro em dois tempos, e a narração de fim de Fase 1
- **Registro de partida em `.jsonl`**, um arquivo por partida, com o tempo de
  deliberação de cada turno. Sai pelo botão do menu de pausa
- Contabilidade semanal por fonte (docagens, armazém, píer, salários,
  manutenção, parcela) — **só observa**, não entra em conta nenhuma do jogo

### O que já é arte de verdade, e o que ainda é placeholder
**O mapa do porto é a tela do jogo** (`Main.tscn`): água, cais, armazém, pátio
de contêineres, caminhões estacionados e coqueiros, tudo em vetor chapado visto
de cima. As docas são **3 vagas fixas sobre os píeres** — quantas
existem vem de `GameState.docks`, e "Ampliar píer" acende a terceira, que até
lá mostra as estacas velhas sob contorno tracejado.

A interface **não é montada por código**: vive em cenas `.tscn` com um tema
(`ui/tema_brport.tres`). Trocar arte é editar cena e tema, não reescrever
script.

**O mapa não carrega interface em cima** (30/08). As chips que mostravam valor
e turnos pousavam no tabuado e tapavam justamente o barco, o guindaste e o
trabalhador; hoje isso vive em `scenes/dock/DocaCartao.tscn`, numa fileira de
três cartões alinhados abaixo do mapa — onde o polegar sabe onde estão. O píer
continua sendo alvo de arrasto e ACENDE quando aceita o trabalhador escolhido.
Os nomes (escritório, armazém, zona de espera) deixaram de ser rótulos brancos
de 27px flutuando e viraram **placas com mastro**, apoiadas no prédio ou numa
estaca na água; o número de cada doca é **tinta de piso no cais**, gerada em
estêncil pelo `gerar_mapa_iso.py` porque o importador de SVG do Godot não
desenha `<text>`.

**Os ícones do HUD já são arte de verdade** (29/08): 20 SVGs em `art/icones/`,
todos conferidos a 19px sobre os três fundos que a interface tem (pílula
escura, cartão branco, botão navy) com `tools/folha_icones.gd`. Cada um foi
colorido para o fundo onde cai — dois não são reaproveitáveis em qualquer
lugar, e o cabeçalho de `Icones.gd` diz quais e por quê.

As **estruturas trocam de textura, não de nó** — o prop ocupa o mesmo quadro
nos dois estados, então o prédio não salta ao ser consertado. Mesma razão que
fez o píer partilhar geometria entre vazio e construído.

**A cauda dos props tem corpo desde 02/09** (Etapa 2). O contêiner do convés
passou de 2 peças a 13 — corrugado, cantoneiras de metal nos cantos e portas
azuis —, o caixote virou carga empilhada em duas madeiras diferentes, a boia
ganhou faixa refletiva e o marcador duas faixas mais lanterna. Os números do
plano de arte para esta etapa (~14 peças no contêiner) foram escritos para um
prop de 2,4 unidades que saiu do projeto em 31/08; o que existe hoje tem 46px
na tela, e o plano de arte explica a conta. **As peças pequenas do pátio —
caminhão, empilhadeira, pilha de caixotes, cabeço, poste e mais oito — já
existiam desde 31/08**, em `blender/brp_porto.py`.

O cenário usa os props: **coqueiros low-poly** (que oscilam, copa e tronco em
peças separadas), **guindaste** nas docas construídas (a lança varre), **carga
no convés** e **boias + marcador** na Zona de Espera. Os coqueiros chapados
saíram do SVG do mapa — `gerar_mapa_iso.py --sem-coqueiros` — pela mesma razão
que os píeres: o que se mexe não pode estar assado no fundo.

Continuam **sem uso** `galpao` e `galpao_velho` (os prédios do mapa já fazem
esse papel). As versões avulsas de `caixote`/`conteiner` não existem: saíram em
31/08 e a carga vive assada no píer, que é onde ela foi engordada.

Os **3 barcos do GDD** existem (pesqueiro, cargueiro médio e grande), e o
pesqueiro tem casco próprio — não é o mesmo casco com carga trocada. O
**trabalhador aparece de pé no tabuado** quando alocado, e mexe-se enquanto a
operação corre.

Ainda é placeholder o **retrato ilustrado do trabalhador** no cartão da
fileira, que é de outra leva e de outra linguagem visual.

A **Zona de Espera é só visual**: os barcos ancorados são decorativos e não
representam fila de verdade — barcos continuam nascendo direto nas docas.
Torná-la mecânica muda o balanceamento medido (ver o aviso em
`docs/arquivo/BLOCO4_BRIEFING_VISUAL.md`).

Continuam para depois: a MÚSICA (os efeitos já existem, de rascunho), o Diário
do Porto, a cena narrativa de fim de Fase 1 e a lista "VS — OUT" do GDD.

---
---

## Como retomar numa conversa nova

Aponte este arquivo e diga o que quer fazer:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md` e a fila na §7 do
> plano. Quero trabalhar em X."

O `CLAUDE.md` não precisa de ser apontado: ele carrega sozinho, e traz as
regras, a receita de rodar tudo e as armadilhas que já custaram trabalho.

**Numa sessão remota não é preciso montar nada.** O hook de arranque já baixou o
Godot, já rodou o `--import` e diz numa linha que o fez. Se essa linha não
apareceu na primeira mensagem, o hook não correu — a receita manual está no
`CLAUDE.md`, e lê a versão de `.godot-version`, que é onde ela vive.

Para fechar o trabalho, a skill **`/fechar-sessao`** conduz o que a mudança
exige. Para mexer em preço ou em constante `# TUNING:`, **`/balancear`** — e
medir é com 600 partidas por perfil, nunca com as 30 que o CI roda como teste de
fumaça.
