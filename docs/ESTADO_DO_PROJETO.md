# BR Port — Estado do Projeto

> **Como o jogo está hoje.** É a segunda das quatro camadas de documentação
> deste projeto, e a única que nenhum teste protege — se envelhecer, envelhece
> calada.
>
> **Última atualização:** 07/09/2026
>
> | Precisa saber | Leia |
> |---|---|
> | O que nunca se faz aqui, e como rodar Godot e Blender | `CLAUDE.md`, na raiz — **carrega sozinho, não precisa abrir** |
> | Como o jogo está hoje | este arquivo |
> | O que fazer a seguir, e quais itens só o Bruno fecha | `docs/design/BR_Port_Plano_v3_Claude_Code.md` |
> | Por que se decidiu assim | `docs/decisoes/NNN-*.md`, uma por arquivo |
>
> São **dois** documentos para retomar o trabalho: este e o plano — até 02/09
> eram cinco em cadeia. O caminho percorrido está em
> `docs/arquivo/HISTORICO.md`; o que aconteceu em cada sessão, em
> `docs/arquivo/`.

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador, R$400.000 e **sete
estruturas** — píeres 2 e 3, armazém, pátio, escritório e os dois UPGRADES
(guindaste de pórtico e cais reforçado). Comprar cada uma muda o mapa: o pátio
sai de terra batida para asfalto, os prédios saem de ruína, e os upgrades
trocam a torre e a laje do píer.

**A barra de ação tem DOIS botões e uma hierarquia** — "Avançar dia" é âmbar
cheio com rótulo navy, e "Alocar todos" é navy com borda e rótulo âmbar
(`BotaoDestaque`, 07/09): âmbar nos dois seria nenhum em destaque.

**A câmera mostra um DISTRITO e não três berços.** O `MEIA_LARG` efetivo é 20,
e ela centra-se no centroide dos berços. O mundo cresceu para isso (`my` de −14
a 42, fundo da terra em −16), senão o jogador via o mapa ACABAR por três lados.

**A água é tropical e o porto tem PRAIA nas duas pontas.** A areia vai **onde o
porto não está** — para além do primeiro e do último berço. Ali o porto PARA
(sem avental, asfalto, junta nem enrocamento) e a terra desce numa rampa de
areia até a água, com restinga e pedras.

**O jogo é TRANQUILO, e os valores são realistas.** Medido em 600 partidas por
perfil: ótimo 100% · mediano 80,2% · descuidado 37,3%, com a mediana do mediano
em R$716.179 contra uma parcela de R$530.000. Um contrato vale R$12.000–88.000 e
a manutenção custa R$40.000/semana — números de porto, não de banca de feira.

A dívida deixou de ser o motor (`docs/decisoes/005`): quem separa os jogadores
agora é **o porto que conseguem levantar**, e desde a trava de 06/09 quem mede
isso é a MARGEM em regime — R$674.019 contra R$103.290 — e não a contagem de
barcos, que passou a favorecer o porto pobre (ele só recebe pesqueiro, que
descarrega num turno). Mexer em preço sem rodar `simular_balanceamento.gd`
quebra isto.

**E o navio que atraca depende do porto que existe** (`docs/decisoes/009`). São
três classes travadas pelo NÍVEL DO PORTO, que é o menor entre o do píer e o do
guindaste: pesqueiro no nível 1, cargueiro no 2, navio de longo curso no 3 — que
exige o cais reforçado. O porto em ruínas recebe **só pesqueiro**, e o perfil
Descuidado nunca vê um navio de longo curso em 600 partidas. O painel Construir
abre a dizer o nível e o que falta; o `CAIS_CHANCE_GRANDE` saiu, porque o cais
deixou de multiplicar uma chance invisível e passou a DESTRAVAR uma classe.

**E o navio vem ao porto POR ALGUMA COISA.** Cada barco nasce com um MOTIVO —
Pescado, Armazenagem, Contêiner ou Granel —, que se lê na linha do cartão da
doca. O efeito é sempre o da ESTRUTURA a que o motivo está preso, nunca do
motivo sozinho: o armazém deixou de ser +20% em tudo e paga +50% em quem vem
deixar carga, o pátio paga +30% no contêiner, e o granel ocupa o berço um turno
a mais até o pórtico existir. **Reparo e reabastecimento ficaram de fora de
propósito** — o GDD põe a oficina e o posto na Fase 2 (`docs/decisoes/008`).

**A partida grava-se.** Uma linha JSON por acontecimento, com o tempo em cada
turno (A7); o nome de quem jogou NÃO entra (`docs/decisoes/006`). Sai pelo menu
de pausa, e `tools/ler_registros.py` resume.

**O jogo tem som.** Dez efeitos sintetizados por `tools/gerar_sons.py`, um
autoload `Audio.gd` com dois buses e sliders no menu de pausa. São de RASCUNHO,
e **ninguém que os fez os ouviu** (`docs/design/BR_Port_Plano_Audio.md` §2).

**Nada de interface pousa sobre o mapa, e desde 05/09 nem os nomes.** A doca
tem duas metades: a vaga no mapa e o cartão na barra abaixo. O número de cada
doca está pintado no cais, e as placas com mastro saíram — quem distingue os
prédios do porto das casas da vila são os próprios prédios.

**O ARMAZÉM é um armazém dos dois lados do par** (telhado de zinco, chapa
corrugada, portão de enrolar, plataforma de carga) e **o porto abre em RUÍNAS
de verdade** — parede desabada, meio telhado com a armação à vista, portão fora
do trilho. Como se lá chegou está em `docs/arquivo/HISTORICO.md`.

**O porto tem uma CIDADE atrás dele.** Rua de **mão dupla** (1,8 de largura,
com linha central e passadeiras na altura de cada prédio do pátio), calçada,
acesso a cada berço, **duas fileiras de casas em quarteirões** e uma **viela de
terra entre elas**, que é o único acesso da fileira de trás; a de trás é mais
rala, para a vila DESFIAR contra a mata. Ela tem nível (`--nivel-vila=N`): térrea,
sobrado, prédio — é assim que cresce a cada Fase, sem o jogo saber.

**E a mata atrás dela é desenhada onde se vê**, pela receita `com_saia()`.

---

## Onde estamos na fila

**A fila em vigor é a §7 do plano** — ela é que diz o que vem a seguir e quais
itens param à espera do Bruno. Aqui fica só a posição.

**Fechados**, dos quinze itens: B1 a B8 e A2, A3, A4 (construídas), mais a
metade de máquina do A1 (APK e build Web a cada push). O que cada um era está
em `docs/arquivo/HISTORICO.md`.

**Abertos e esperando o Bruno** — nenhum deles precisa de uma sessão ligada:

| Item | O que falta | Por que só ele |
|---|---|---|
| **A1** | ~~Jogar~~ — 02/09 e 06/09, e os 25 itens já triados. Fica **a ordem do resto** | Ver abaixo |
| **A4** | Ler as falas em voz alta | Três desvios do rascunho de escrita esperam esse julgamento, listados no A4 do plano. Não há como julgar fala sem a dizer |
| **A5** | Olhar cada antes/depois da arte | **AS SEIS ETAPAS ESTÃO FECHADAS** — 1, 2, 4, 5 e 6 feitas; a **3 construída, medida e REJEITADA**. Mais o que ficou fora delas: a frota, os camiões nos berços e a rua de mão dupla de 07/09. É a trilha inteira à espera do olho dele |
| **A6** | Ouvir | Este contêiner não tem placa de som. Ninguém que fez os efeitos os ouviu |

### O que a SEGUNDA jogada devolveu (06/09) — 25 itens, triados

**Tudo em `docs/arquivo/PLAYTEST_02_ANALISE.md`**, e o resumo na §7 do plano.

**Três blocos fechados em 07/09**, todos escolhidos por ele, e o detalhe de
cada um está onde ele vive:

| Bloco | Itens | Onde |
|---|---|---|
| Defeitos medidos + interface | 14, 10, 1, 22, 25 | a análise, e o PR #34 |
| O camião entra na doca | 3 | `docs/decisoes/011` |
| A estrada | 2, 4a, 11 e um terço do 4b | `docs/decisoes/012` |

⚠️ **Duas coisas ficaram medidas e por fazer.** O **4b** está a um terço: a face
de cada cotovelo tem 4,00 unidades e a boca da viela cobre 1,36 — 34%, igual
nos quatro; achatar o resto é chanfrar a esquina. E a rua parou em **1,8** de
largura porque a janela entre o acesso ao berço e o cotovelo fecha a 1,99; ir
além disso obriga a empurrar o `RUA_RECUO`, e isso mexe no enquadramento.

O resto continua por começar, e **a ordem é dele**.

### O que a primeira jogada devolveu (02–03/09)

**Triada em `docs/arquivo/PLAYTEST_01_ANALISE.md`**, e fechou-se tudo o que não
dependia do Bruno. Ficam o layout do rodapé (gosto, gate A5), três itens de
economia (só via `/balancear`, e ele amarrou-os ao pacote de Fase 2) e a fala da
madeira podre (espera o A4). **Livre, sem gate: A8.**

### A pergunta da Fase 2 — adiada de propósito (03/09)

**Decisão do Bruno: responde-se quando a Fase 2 for feita, e não antes.** Ela
não é pendência aberta nem trava sessão nenhuma — é uma nota presa ao trabalho
da Fase 2, para quem o abrir a ler antes de codar a economia. O que continua a
valer é a regra: **codar a economia da Fase 2 sem a responder é construir em
cima de uma pergunta**, e por isso o item começa por aqui.

O contrato cresce ×2,9 e depois ×2,5 por fase; a parcela cresce ×2,0 e ×1,5 —
**a receita corre mais depressa do que a dívida**, e a tensão da Fase 1
desaparece a partir da semana 5. Subir as parcelas, assumir que é de propósito,
ou trocar o que pressiona: **não está decidido**. É projeção e não medição — a
conta e o modo de a refazer estão em
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.

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
| `brport_vs/tests/teste_design.gd` | **Teste de design** — se os props caem em cima do que o mapa desenhou, se a ordem dos nós respeita a profundidade e se a interface cabe na tela. O bloco **D14** (04/09) guarda a vila; o **D15** (04/09) guarda as duas pontas de areia; o **D18** (06/09) mede o PIOR CASO de texto do cartão de doca contra os 200px de interior dele; o **D19** (06/09) mede a WCAG de cada rótulo do painel Construir contra o branco do cartão |
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
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo — inclui a malha viária, a vila (`--nivel-vila=N`) e os números de doca pintados no cais. **Desenha a `MEIA_LARG = 30` e entrega a 20 pelo `viewBox`**: a câmera é o `ZOOM`, e a câmera centra-se sozinha nos berços |
| `tools/medir_enquadramento.py` + `brport_vs/tools/medir_enquadramento.gd` | **A régua do enquadramento** — gera o mapa em várias larguras e mede quanto do quadro é porto, quanto é distrito, quanto é mar, e sobretudo **quantos pixels da FRONTEIRA DO MUNDO entram na janela**, que é a pergunta que decide a etapa. Rasteriza com o ThorVG, que é o mesmo importador do jogo |
| `tools/gerar_props_iso.py` | Gera os props isométricos (píer, barcos, guindaste, coqueiro, galpão, cenário) em Blender por script, na projeção do mapa. Confere a própria projeção ao fim |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade. Desde 06/09 imprime a **mistura de classes e de motivos** que o jogo sorteou, e exporta a que NÍVEL cada perfil chegou — é dele que o projetor tira quais navios cada porto recebe |
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
| `docs/design/` | GDD 7, guias, Validation Guide, e o Roadmap v2.1 + Plano da Fase 2 (superados, mantidos como registro) |
| `index.html` (raiz) | O protótipo HTML original, já validado |
| `tools/capturar_evidencia.sh` | **As oito fotografias que provam o que ficou** — seis de jogo (o nível 2 do porto, e o porto A OPERAR com os camiões nos berços) e duas folhas de contato. Semente e passo de tempo fixos, painéis conferidos, tela chapada reprovada. É o que o CI roda a cada PR |
| `brport_vs/tools/folha_frota.gd` | **A folha de contato da frota** — os seis cascos e os oito camiões percorrendo as tabelas do jogo, cada um sobre o chão dele. Existe porque as fotos de JOGO mostram só o que o sorteio escolheu |
| `.github/workflows/testes.yml` | A suíte, a tabela dos números, os sons, as âncoras, e o export do APK e do Web |
| `.github/workflows/captura.yml` | As oito imagens anexadas a cada PR, e o antes/depois contra a base |
| `.github/workflows/balanceamento.yml` | As 600 partidas por perfil, às segundas e sob demanda |
| `tools/conferir_docs.py` | Confere que as quatro camadas existem e que nenhuma referência de documento aponta para arquivo que não há |
| `docs/arquivo/` | O que aconteceu em cada sessão que já fechou. **Nada se apaga** — o índice está no `docs/arquivo/README.md` |
| `docs/gdd/` | **O GDD 7 legível**, 80 páginas GERADAS do `.jsx` — uma seção por arquivo. Não editar. Descreve as Fases 1 a 5 e está congelado antes da reescala: onde divergir do jogo, quem manda é o código |
| `tools/gerar_gdd_md.py` | Gera as 80 acima. Recusa-se a adivinhar: forma de dado que ele não conheça **reprova**, em vez de sumir do markdown |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Alocação de trabalhador por toque, por "Alocar todos" ou por arrasto
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas) — e ela **decide a contra-oferta**:
  reputação alta faz o cliente aceitar pagar cheio com mais frequência
  (`docs/decisoes/003`)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- **Motivo de escala por barco** — quatro motivos de carga e descarga, cada um
  preso a uma estrutura que já existe. Ele nasce com o barco, entra no save e
  aparece no cartão da doca (`docs/decisoes/008`)
- **Três classes de navio, travadas pelo nível do porto** — pesqueiro,
  cargueiro e navio de longo curso, cada uma com a sua faixa de valor, os seus
  turnos e a sua mistura de motivos. A classe decide o casco desenhado no píer
  (`docs/decisoes/009`)
- Parcela única de **R$530.000** ao Sr. Ribeiro, vencendo ao fim da semana 4
  (8 turnos por semana, 4 semanas — 32 dias de partida)
- **Sete estruturas** — píer 2, píer 3, armazém, pátio, escritório e os dois
  upgrades (guindaste, cais) —, cada uma mudando o mapa. O porto abre em ruínas
  com 1 doca. Os upgrades trancam-se pela cadeia `requer`, não por fase
  (`docs/decisoes/007`): o guindaste corta o turno do navio grande, e o cais
  DESTRAVA a classe dele (`009` — a chance invisível saiu)
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

A interface **não é montada por código**: cenas `.tscn` com um tema.

**O mapa não carrega interface em cima.** O texto e o alvo de toque de cada
doca vivem em `scenes/dock/DocaCartao.tscn`, abaixo do mapa; o píer continua
alvo de arrasto e ACENDE quando aceita o trabalhador. O número de cada doca é
**tinta de piso**, em estêncil, porque o importador de SVG do Godot não desenha
`<text>`.

**Os ícones do HUD já são arte de verdade**: 20 SVGs conferidos a 19px sobre
os três fundos da interface com `tools/folha_icones.gd`. Cada um foi colorido
para o fundo onde cai — o cabeçalho de `Icones.gd` diz quais não se
reaproveitam e por quê.

As **estruturas trocam de textura, não de nó** — mesmo quadro nos dois estados,
então o prédio não salta ao ser consertado. Mas as PEÇAS não se partilham, e
cada estado tem vocabulário próprio: as duas lições estão no `CLAUDE.md`.

**A cauda dos props tem corpo** (Etapa 2): contêiner corrugado, carga empilhada,
boia e marcador, e as catorze peças pequenas do pátio em `blender/brp_porto.py`.

O cenário usa os props: **coqueiros** que oscilam em rajada, **guindaste** nas
docas construídas, **carga no convés** e **boias + marcador** na Zona de Espera. **Três caminhões atravessam o mapa pela estrada**, cada um com
a carga da doca do mesmo índice e em duas silhuetas porque a rua vira 90° em
cada cotovelo — e **entram na doca** quando ela tem barco e trabalhador,
saindo quando o barco sai (`011`); a **espuma lava a costa** em
duas camadas em contrafase; o **enrocamento para nas duas pontas**, onde o cais
deu lugar a praia. Os coqueiros chapados saíram do SVG — `--sem-coqueiros` —
pela mesma razão que os píeres: o que se mexe não pode estar assado no fundo.

**E as chapas lisas acabaram**: tabuado com junta no n2, junta atravessada no
n3, ferrugem nos cargueiros — padrões DIRIGIDOS, peça a peça, nunca pela paleta.

**O píer, a lança, a TORRE e o casco têm TRÊS NÍVEIS.** O píer vai de ripas a
laje de concreto sobre estacas de aço; a lança, de pau-de-carga a lança longa
com spreader; a torre, de poste de madeira a pórtico com casa de máquinas. Quem
escolhe são `nivel_pier()` e `nivel_guindaste()`, cada um preso ao seu upgrade
(`docs/decisoes/007`) — e desde 06/09 são elas que decidem também **que navio
atraca** (`009`), o que faz a trava ser visível em vez de estatística.

**O CASCO DIZ O QUE O NAVIO TRAZ, e o camião o que sai pela estrada**
(`docs/decisoes/010`). São seis cascos, um por par (classe, motivo): o costado é
o mesmo e o CONVÉS é que muda — pilha alinhada com guias, tampas de porão sobre
braçola, paletes com pau-de-carga aberto. O pesqueiro tem um casco só, e isso é
afirmação: pescado e armazenagem são o mesmo peixe indo para sítios diferentes.
Os camiões são quatro, um por motivo. O **trabalhador aparece de pé no
tabuado** quando alocado, e mexe-se enquanto a operação corre.

O **retrato do trabalhador** sai do mesmo estúdio Blender e é o único prop que
olha para a frente; o boneco do PÍER continua com as cinco caixas dele, porque
22px e 70px não são o mesmo orçamento de pixel (`docs/arquivo/`).

A **Zona de Espera é só visual**, e torná-la mecânica muda o balanceamento
medido (`docs/arquivo/BLOCO4_BRIEFING_VISUAL.md`).

Continuam para depois: a MÚSICA (os efeitos já existem, de rascunho), o Diário
do Porto e a lista "VS — OUT" do GDD. **A cena de fim de Fase 1 saiu desta
lista em 07/09**: ela existe desde o A4, em dois tempos, e desde a segunda
jogada FECHA — o balanço tem botão de fechar e o menu de pausa reabre-o.

---
---

## Como retomar numa conversa nova

Aponte este arquivo e diga o que quer fazer:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md` e a fila na §7 do
> plano. Quero trabalhar em X."

O `CLAUDE.md` carrega sozinho e traz as regras, a receita de rodar tudo e as
armadilhas. **Numa sessão remota não é preciso montar nada** — o hook de
arranque deixa o Godot pronto e diz numa linha que o fez; se essa linha não
aparecer, a receita manual está lá.

Para fechar, a skill **`/fechar-sessao`**. Para mexer em preço ou constante
`# TUNING:`, **`/balancear`** — e medir é com 600 partidas por perfil, nunca com
as 30 que o CI roda como teste de fumaça.
