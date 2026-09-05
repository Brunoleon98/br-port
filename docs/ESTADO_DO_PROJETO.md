# BR Port — Estado do Projeto

> **Como o jogo está hoje.** É a segunda das quatro camadas de documentação
> deste projeto, e a única que nenhum teste protege — se envelhecer, envelhece
> calada.
>
> **Última atualização:** 05/09/2026
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

**O botão que move o jogo tem cor própria** — "Avançar dia" é âmbar com rótulo
navy (medido: branco sobre âmbar reprova a WCAG, navy passa), e os cartões
claros têm sombra e borda de 2px. Os escuros não, de propósito: a sombra do
tema é mais clara que o fundo deles e faria halo.

**A câmera mostra um DISTRITO e não três berços.** O `MEIA_LARG` efetivo é 20,
e ela centra-se no centroide dos berços. O mundo cresceu para isso — um degrau
de costa em cada ponta (`my` de −14 a 42) e o fundo da terra em −16 —, senão o
jogador via o mapa ACABAR por três lados. O porto mantém ~47,5% do quadro.

**A água é tropical e o porto tem PRAIA nas duas pontas.** A areia não vai
entre a água e o cais: vai **onde o porto não está** — para além do primeiro e
do último berço. Nos dois trechos o porto PARA (sem avental, asfalto, junta nem
enrocamento) e a terra desce numa rampa de areia até a água, com restinga e
pedras. Com o enquadramento novo elas emolduram o porto nos dois cantos.

**O jogo é TRANQUILO, e os valores são realistas.** Medido em 600 partidas por
perfil: ótimo 100% · mediano 79,5% · descuidado 31,0%, com a mediana do mediano
em R$796.970 contra uma parcela de R$550.000. Um contrato vale R$8.000–70.000 e
a manutenção custa R$40.000/semana — números de porto, não de banca de feira.

A dívida deixou de ser o motor (`docs/decisoes/005`): quem separa os jogadores
agora é **o porto que conseguem levantar** — 56,2 barcos atendidos contra 12,6.
Mexer em preço sem rodar `simular_balanceamento.gd` quebra isto.

**A partida grava-se.** Uma linha JSON por acontecimento, com o tempo que o
jogador ficou em cada turno — a pergunta do A7. O nome de quem jogou NÃO entra
no arquivo (`docs/decisoes/006`). Sai pelo menu de pausa;
`tools/ler_registros.py` resume.

**O jogo tem som.** Dez efeitos sintetizados por `tools/gerar_sons.py`, um
autoload `Audio.gd` com dois buses e sliders no menu de pausa. São de RASCUNHO,
e **ninguém que os fez os ouviu** — o contêiner não tem placa de som
(`docs/design/BR_Port_Plano_Audio.md` §2).

**Nada de interface pousa sobre o mapa, e desde 05/09 nem os nomes.** A doca
tem duas metades: a vaga no mapa (píer, barco, guindaste, trabalhador) e o
cartão na barra logo abaixo (valor, turnos, trabalhador). O número de cada doca
está pintado no cais. **As três placas com mastro saíram** — o mapa não carrega
mais texto nenhum; quem distingue os prédios do porto das casas da vila são os
próprios prédios.

**E o ARMAZÉM é um armazém dos dois lados do par.** O acabado lia como a maior
casa do bairro — parede lisa, telha, três janelas de moldura. Hoje é telhado de
zinco com nervura no sentido da água, chapa corrugada, fita de vidro rente ao
beiral, portão de enrolar laranja e **plataforma de carga** com defensas e
degraus. A cumeeira não subiu um pixel: a doca come parte da parede.

**E o porto abre em RUÍNAS de verdade.** Paredes sujas com um terço desabado,
meio telhado com a armação à vista, o portão fora do trilho; a ruína do
escritório é um CANTO de pé com porta e janela vazias. Como se lá chegou está
em `docs/arquivo/HISTORICO.md`.

**O porto tem uma CIDADE atrás dele.** Rua paralela ao cais, calçada, acesso a
cada berço e **duas fileiras de casas em quarteirões** — 3 a 5 lotes quase
colados, um par em cada três geminado, cortados por travessas. Era uma fileira
só com o vão sempre igual, e aquilo lia como cerca; a de trás é mais rala e
arborizada, para a vila DESFIAR contra a mata. Ela tem nível (`--nivel-vila=N`):
térrea, sobrado, prédio — é assim que cresce a cada Fase, sem o jogo saber.

**E a mata atrás dela é desenhada onde se vê** — copas com sombra projetada,
tronco e lobos com aresta, pela receita `com_saia()`. Como se lá chegou está em
`docs/arquivo/HISTORICO.md`.
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
| **A1** | ~~Jogar dez minutos no APK~~ — **a primeira passagem aconteceu em 02/09**, e o que ela achou está em `docs/arquivo/PLAYTEST_01_ANALISE.md`. O que fica aberto é a passagem SEGUINTE, depois de a fila abaixo andar | Ver leitura abaixo |
| **A4** | Ler as falas em voz alta | Três desvios do rascunho de escrita esperam esse julgamento, listados no A4 do plano. Não há como julgar fala sem a dizer |
| **A5** | Olhar cada antes/depois da arte | **AS SEIS ETAPAS ESTÃO FECHADAS** — 1, 2, 4, 5 e 6 feitas; a **3 construída, medida e REJEITADA** (o traço redesenha o que o corrugado já diz). Da 4, a cal descascada também caiu por medição. É a trilha inteira à espera do olho dele |
| **A6** | Ouvir | Este contêiner não tem placa de som. Ninguém que fez os efeitos os ouviu |

### O que a primeira jogada no telefone devolveu (02–03/09)

**A análise inteira está triada em `docs/arquivo/PLAYTEST_01_ANALISE.md`**, e
em 02–05/09 fechou-se **tudo o que não depende do Bruno**. O que sobra, e por
quê — a análise tem a medida de cada um:

| Fica | Porque não se fecha aqui |
|---|---|
| Layout do rodapé · espaço reservado no HUD | São o mesmo problema: sete faixas e 29px de folga. Dar lugar a conteúdo de Fase 2 é TIRAR o que já é usado — gosto, e o gate A5 é dele |
| Economia (3 itens) | Só via `/balancear`, e ele mesmo amarrou-a ao pacote de Fase 2 ("para fazer tudo isso") |
| Fala da madeira podre | Espera o A4 |

~~Vegetação pobre · casas mal distribuídas~~ — **fechado em 04/09**. A análise
está fechada por inteiro no que não depende do Bruno.

**Livres, sem gate:** A8. O **B7 fechou em 02/09** — o registro de partida e o
leitor que o resume.

Da arte, **quatro das seis etapas estão feitas, a 1 está fechada por inteiro e
a 4 está a meio** — a 1 (paleta, areia das duas pontas e enquadramento), a 2 (a
cauda dos props), a 5 (o trabalhador do cartão, 03/09) e a 6 (o chrome da
interface). A **3 fechou por rejeição**: num estilo que desenha o detalhe com fronteiras de
valor, um filtro de borda redesenha o desenho — a parede do galpão perde 14% de
desvio local e a treliça 21% de saturação. Quem separa a silhueta é o contraluz
do rig, e já separava. A **4 fechou com uma baixa**: corrugado, ripa e ferrugem
entraram; a cal descascada nas quinas não se faz nesta geometria, e o porquê
está medido no plano de arte.

**Como o enquadramento se fez** está em `docs/arquivo/HISTORICO.md`; o que
fica a valer é `docs/BRP_SPATIAL_CONTRACT.md` §1.1.

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
| `brport_vs/tests/teste_design.gd` | **Teste de design** — se os props caem em cima do que o mapa desenhou, se a ordem dos nós respeita a profundidade e se a interface cabe na tela. O bloco **D14** (04/09) guarda a vila; o **D15** (04/09) guarda as duas pontas de areia: ninguém pisa a areia, só coqueiro fica no `my` de uma praia, e cada ponta tem de ter mais de 100 px de costa dentro da janela |
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

| `tools/capturar_evidencia.sh` | **As seis fotografias que provam o que ficou** — e uma delas é o nível 2 do porto, que os dois extremos não mostram — semente e passo de tempo fixos, painéis conferidos, tela chapada reprovada. É o que o CI roda a cada PR |
| `.github/workflows/testes.yml` | A suíte, a tabela dos números, os sons, as âncoras, e o export do APK e do Web |
| `.github/workflows/captura.yml` | As seis imagens anexadas a cada PR, e o antes/depois contra a base |
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
(`ui/tema_brport.tres`).

**O mapa não carrega interface em cima.** O texto e o alvo de toque de cada
doca vivem em `scenes/dock/DocaCartao.tscn`, numa fileira de três cartões
abaixo do mapa; o píer continua alvo de arrasto e ACENDE quando aceita o
trabalhador. Os nomes são **placas com mastro** apoiadas no prédio ou numa
estaca, e o número de cada doca é **tinta de piso**, em estêncil, porque o
importador de SVG do Godot não desenha `<text>`.

**Os ícones do HUD já são arte de verdade**: 20 SVGs conferidos a 19px sobre
os três fundos da interface com `tools/folha_icones.gd`. Cada um foi colorido
para o fundo onde cai — o cabeçalho de `Icones.gd` diz quais não se
reaproveitam e por quê.

As **estruturas trocam de textura, não de nó** — o prop ocupa o mesmo quadro
nos dois estados, então o prédio não salta ao ser consertado. Mas as PEÇAS não
se partilham entre os dois: foi isso que fez o galpão em ruína ter paredes
novas até 05/09. **E cada estado precisa do seu vocabulário** — o mesmo defeito
com o sinal trocado: consertada a ruína, o armazém ACABADO ficou o único prédio
do porto desenhado só com repertório doméstico, e lia-se como casa.

**A cauda dos props tem corpo** (Etapa 2): contêiner corrugado, carga
empilhada, boia e marcador com faixa refletiva, e as catorze peças pequenas do
pátio em `blender/brp_porto.py`.

O cenário usa os props: **coqueiros low-poly** que oscilam em rajada,
**guindaste** nas docas construídas (a lança varre), **carga no convés** e
**boias + marcador** na Zona de Espera. O **caminhão atravessa o mapa inteiro
pela estrada**, de fora do quadro a fora do quadro, com duas silhuetas porque a
rua vira 90° em cada cotovelo; a **espuma lava a costa** em duas camadas em
contrafase; as **pedras do enrocamento** são sólidos facetados e ele **para nas
duas pontas**, onde o cais deu lugar a praia. A **mata atrás da vila tem
árvores de verdade** e há árvore no quintal das casas. Os coqueiros chapados
saíram do SVG do mapa — `--sem-coqueiros` — pela mesma razão que os píeres: o
que se mexe não pode estar assado no fundo.

**E as chapas lisas acabaram.** O convés do n2 é tabuado com junta e tom por
tábua, a laje do n3 tem junta atravessada e os dois cargueiros têm ferrugem que
escorre — padrões DIRIGIDOS, atribuídos peça a peça e nunca pela paleta. O n2
era a maior superfície do jogo sem desenho, e o píer melhor lia mais liso que o
provisório.

**O píer, a lança e o casco têm TRÊS NÍVEIS desde 05/09** — é a evolução do
porto ficando visível. O píer vai de ripas de madeira com fresta a laje de
concreto sobre estacas de aço, com defensas de pneu e contêiner empilhado; a
lança, de um pau-de-carga sem contrapeso a uma lança longa com spreader. Quem
escolhe é `GameState.nivel_porto()`, que só LÊ quantas estruturas estão de pé —
a mecânica de upgrade que o GDD 7 prevê é da Fase 2 e continua por fazer, como
a vila, que já cresce por `--nivel-vila=N` sem o jogo saber. **A torre é a mesma
nos três**, porque o `pivot_offset` da lança é um só.

Os **3 barcos do GDD** existem (pesqueiro, cargueiro médio e grande) e desde
05/09 os TRÊS atracam, escolhidos pelo valor do contrato — o médio era gerado,
validado e nunca entrava em doca. O pesqueiro tem casco próprio, não é o mesmo
casco com carga trocada. O
**trabalhador aparece de pé no tabuado** quando alocado, e mexe-se enquanto a
operação corre.

O **retrato do trabalhador** sai do mesmo estúdio Blender de tudo o resto
(`trabalhador_retrato`) e é o único prop que olha para a frente — rodado 45°
em Z, porque um retrato de 3/4 num cartão de 108px mostra sobretudo o
capacete. O boneco do PÍER continua com as cinco caixas dele: 22px e 70px não
são o mesmo orçamento de pixel.

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
