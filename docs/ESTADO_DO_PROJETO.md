# BR Port — Estado do Projeto

> **Como o jogo está hoje.** É a segunda das quatro camadas de documentação
> deste projeto, e a única que nenhum teste protege — se envelhecer, envelhece
> calada.
>
> **Atualização:** 16/10/2026 — ajuda fundida (#134); defeitos e agentes (`117`–`120`)
>
> Regras no `CLAUDE.md`; rumo na §7 do plano v3; razões em `docs/decisoes/`.
>
> Retome por este estado e pelo plano. Histórico: `docs/arquivo/HISTORICO.md`;
> sessões fechadas: `docs/arquivo/`.

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador e R$400.000. A Fase 1 libera
reparar o píer 2 desde o início, o armazém na semana 2 e o pátio a partir da
semana 5, depois da primeira cobrança quitada (`085`). Na Fase 1 são até dois
píeres; a Fase 2 abre o píer 3 e o escritório (`104`).
Uma obra por vez, paga ao iniciar: píer/armazém em dois dias, pátio em três;
benefícios só ao concluir (`087`); a que só acaba no fecho do dia 84 avisa
que não será usada nesta fase (`090`).

**O rodapé é escuro, e só o "Avançar dia" é âmbar cheio** (`081`): o
desligado, a faixa, a parcela e os cartões recuam abaixo dele (**D43**).
**As conversas falam como no celular, e o fim de fase é uma página do diário**
(`082`, **D44**, **D22**). **Atracar é a escolha do dia** (`083`): até três
barcos esperam ao largo, dois dias cada; tocar num atraca-o com o trabalhador
do píer, e quem não for chamado vai embora e custa reputação.

**A câmera mostra um DISTRITO e não três berços.** O `MEIA_LARG` efetivo é 20 e
ela centra-se no centroide dos berços; o mundo cresceu para isso (`my` de −14 a
42, fundo da terra em −16), senão o mapa ACABAVA à vista por três lados.

**A água é tropical e lê como profundidade, não como fitas** — campo de cor
contínuo pela distância à costa, com meandro longo de duas senóides, e a areia
em rampas.

**As duas pontas são costa desenhada** (`023`), com o cais reto. Água, baixio,
espuma, pedras e rampa saem de `ponto_costeiro()`, sem costuras. **D28** tranca
a forma; D20/D21/D24/D27 conferem o raster.

**A RESOLUÇÃO SUBIU NAS DUAS ALAVANCAS QUE PAGAM** — mapa a 1080 (`025`) e
props a 768 px num quadro de 512 COORDENADAS (`029`), com `expand_mode` em 31
nós e o `PropIso` a traduzir; o **D31** tranca. ⚠️ **E A MOLDURA (89,6% do
quadro) SAIU DA VRAM** sem mexer no quadro: o importador `texture_atlas` apara-a
e a margem repõe os 768 — **235,68 → 64,04 MB** em jogo, `.pck` −17,4%
(`049`). O campo da água fica a 720 (`026`); o viewport (C) não dá um pixel.

**E OS CASCOS TÊM CURVA** (`024`, **D29**): quem lia quadrado era o casco,
tapado pelo contêiner; as construções ficam quadradas, e é decisão.

**A fauna tem seis espécies em nove pontos**, três na costa e três em terra,
com toque de **44 px** (D25–D27); a pessoa, a 1,5× o real, é o menor ser vivo
do mapa (`069`).

**A moeda foi restaurada (`085`); preços intactos na `086`/`087`.** Valores atuais
na tabela gerada, taxas e medição na `economia.md`. Expansão e margem distinguem
os perfis (`005`, `009`); não se certificaram preços de mercado.
Save **18** na main (`111`, PR #133), com migração desde a 14
(`098`) e um exemplo por versão;
13 e anteriores recusadas. A Fase 1 dura
12 semanas de 7 dias, com cobranças nos dias 28, 56 e 84 e vitória somente
após as três quitações (`085`). Crédito inicial R$400 mil; três parcelas
iguais de R$140 mil, R$20 mil de juros totais. **Quem não tem o boleto ganha
uma segunda chance** do Sr. Ribeiro, uma vez por fase (`102`). **As três
quitações passam à Fase 2 no dia 85**, no mesmo save, sem dívida nem prazo.
**Meta de três barras** (`106`): reputação ≥80 em três fechos seguidos,
píer 3 e treliça prontos, primeiro cargueiro atendido. Fecha a Fase 2 no
diário e segue em jogo livre. Abaixo de 40, só novos cargueiros somem.
Preços e patamares mantidos pela medição da `108`; ritmo humano no A7.

**Madeira e pesca na Fase 1** (`086`). Na Fase 2 a **treliça custa R$80 mil
e leva dois dias** (`108`): com o píer 2 pronto, sua conclusão abre o
porto de nível 2 e o cargueiro (dois dias; granel, três). O Construir explica
a compra; pórtico e cais continuam para a Fase 3 (`105`).

**E o navio vem ao porto POR ALGUMA COISA:** cada barco nasce com um MOTIVO —
Pescado, Armazenagem, Contêiner ou Granel —, lido no cartão da doca. O efeito é
o da ESTRUTURA a que o motivo está preso; oficina e posto são Fase 2 (`008`).

**A partida grava-se** — uma linha JSON por acontecimento, com o tempo de cada
turno, sem o nome de quem jogou (`006`). Sai pelo menu de pausa.

**O jogo tem som:** 14 efeitos de `tools/gerar_sons.py`, num autoload com
prioridade, dois buses e sliders. São de RASCUNHO e esperam o Bruno ouvir.

**E O HUD INFERIOR TEM UM MENU, QUE É UM CELULAR** (`021`, `066`): aparelho de
400×680 (460×782 na conversa), com o **diário**, as **mensagens** (a conversa do porto, `067`) e
quatro portas FECHADAS — cidade, lojas, missões, análise (itens 18 a 21).

**O ARMAZÉM é um armazém dos dois lados do par** e **o porto abre em RUÍNAS de
verdade** — parede desabada, meio telhado, portão fora do trilho.

**O porto tem uma CIDADE atrás dele.** Rua de **mão dupla** (1,8, com linha
central e passadeiras) — **três camiões descem e dois sobem, pela DIREITA, e os dois sentidos encostam nos berços** (`047`, `052`) —, calçada, acesso a cada berço, **duas fileiras de casas**
e uma **viela de terra entre elas** — a de trás mais rala, para a vila DESFIAR
contra a mata. Tem nível (`--nivel-vila=N`): térrea, sobrado, prédio.

**E TRÊS LOTES DA VILA NÃO SÃO CASA** (`022`): uma **igreja** com torre, uma
**praça** com coreto e **duas obras**, dos lotes VISÍVEIS — a 51 px quem
distingue é a silhueta, e por isso "comércios variados" ficou de fora.

---

## Onde estamos na fila

**A fila em vigor é a §7 do plano.** Aqui fica só a posição.

**R1–R9 e M1–M11 fecharam** (revisão de 09/10, §6); M12 espera A8.
A frente 5 entregou tutorial (`100`, `101`), segunda chance (`102`) e
progressão (`103`–`106`, `108`); medição na `economia.md`.
**Cancelamento na main (`111`, PR #133):** equipe livre no dia, −5, multa de
10%, contas, registro 5 e migração 17→18. Medição na `110`; CI verde no merge.
Pesquisa `112`: `PESQUISA_RECURSOS_BASICOS_2026-10-15.md`; revisão preservada.
**Como jogar/glossário na main (`114`–`116`, PR #134):** inicial e pausa, consulta
compartilhada que preserva a partida. Recorte em
`RECORTE_COMO_JOGAR_GLOSSARIO_2026-10-15.md`. Leitura e telefone pendentes.
Mais trabalhadores e crédito voluntário ficam para depois. **A4 e caderno
sem aceite.** Importação com `Safe save failed`, causa não isolada (`110`).
A `107` permanece local e separada, sem autorização de publicação nem teste
no telefone.

**Construídos:** B1–B8, A2–A4 e export APK/Web do A1. Gates humanos abaixo;
histórico em `HISTORICO.md`.

**Abertos e esperando o Bruno** — nenhum deles precisa de uma sessão ligada:

| Item | O que falta | Por que só ele |
|---|---|---|
| **A1** | Jogado e triado; fica **a ordem do resto** | Ver abaixo |
| **A4** | ⚠️ **Três leituras (13, 19 e 23/09)**, notas aplicadas (`048`): resta ler em voz alta as falas reescritas, o caderno, Toninho, Sr. Ribeiro e a página da Fase 2 com o aviso da Cida (`067`, `082`, `101`, `102`, `106`) |
| **A5** | Frentes 1, 3 e 6 fechadas; retratos e animações no jogo. Recortes e aceite no plano de arte e em `art_lab/` | Falta a máquina do contêiner (`079`); obras futuras e trabalhadores extras pertencem ao item 5. O galpão recuperado V3 só existe no checkout do ChatGPT |
| **A7** | **Jogar pelo link do Pages** e ver duas pessoas jogarem; o FPS no telefone; as partidas em `playtest/` (`099`) | Só ele joga |
| **A6** | **Ouvir** — a metade de máquina fechou (`040`) | Este contêiner não tem placa de som. O protocolo está em `docs/PROTOCOLO_DE_ESCUTA.md`: telefone-alvo, volume fixo anotado, isolado E em contexto, três perguntas acionáveis. ⚠️ Comece pela §4 — **o aviso tem 99% da energia abaixo de 500 Hz** |

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo; o que é de cada fase na tabela `FASES`, lida por funções (`094`) |
| `brport_vs/tests/run_tests.gd` | Regressões da lógica; Fase 2: T20–T23; cancelamento T24; ajuda T25; **o jogador ao acaso** T26, invariantes a cada passo (`118`) |
| `brport_vs/autoload/Audio.gd` | **O ponto único que toca som** — prioridade por frame, espera mínima por som, volume por bus |
| `tools/gerar_sons.py` | Gera os 14 efeitos de rascunho, inclusive mar e fauna. Só biblioteca padrão |
| `brport_vs/tests/teste_audio.gd` | **Teste de áudio** — cobre o que dá para provar sem ouvir |
| `brport_vs/autoload/Registro.gd` | Gravador `.jsonl`; nasce desarmado, e quem o arma é o jogo |
| `tools/ler_registros.py` | **O leitor** — resume N partidas e põe o jogador MEDIDO ao lado dos perfis supostos; dia pago → pronto e semanas do cabeçalho (`088`) |
| `brport_vs/tools/gravar_partidas.gd` | Joga N partidas com o gravador armado. Existe para o CI pôr gravador e leitor a encontrar-se |
| `brport_vs/tests/teste_registro.gd` | **Teste do registro** — o `WRITE` que trunca, o teto, o relógio, a obra pronta (R7), e que o gravador não grava desarmado. Espera `REGISTRO OK` |
| `brport_vs/tests/teste_design.gd` | **Teste de design** — encaixe, profundidade, limites da interface, leitura raster do mapa e pixel contra coordenada nos nós de prop (`025`, `028`, `029`). O **D34** pergunta de ONDE vem um stylebox (`045`); espera `DESIGN OK` |
| `brport_vs/tests/teste_fumaca.gd` | **Fumaça** — cenas, ícones, save, tokens e falas; prazo prometido (F18), nomes lidos por string (F19), fases declaradas contra o alcançado (F20), exemplos de save (F21), tutorial (F22), Fase 2 e M9 (F23) |
| `brport_vs/scripts/Narrativa.gd` | **Todo o texto de fala, num lugar só**, **e a expressão que cada fala pede**. Número sai de constante e vai por EXTENSO; o F4 reprova dígito na narração e fala que o jogo não dispare. Traz também o `concordar()`, a concordância de plural num lugar só (`037`) |
| `brport_vs/tools/gravar_save_de_exemplo.gd` | Grava o save de exemplo da versão corrente em `tests/saves/` (`098`) |
| `brport_vs/scripts/ArmazemLocal.gd` | **Onde o jogo guarda o que é do jogador** — com `--script`, em `user://ferramentas/`. `tools/sentinela_do_jogador.py` prova-o no CI (`061`) |
| `brport_vs/scripts/Retratos.gd` | **O registro dos rostos** — qual PNG é qual personagem em qual expressão, como o `Icones.gd` para o ícone. Doze bustos (`020`, `101`) |
| `brport_vs/scripts/FilaDeMensagens.gd` | **A fila da faixa de mensagem** — FIFO, tempo mínimo por frase, fusão só por duplicata, histórico da sessão. Objeto do `Main` e nunca autoload (`034`) |
| `brport_vs/scripts/PainelMensagens.gd` | O histórico da faixa como **conversa no celular** (`PainelCelular.gd`, o aparelho partilhado com o menu). Em memória, sem migrar save (`067`) |
| `brport_vs/tools/medir_fila_mensagens.gd` | **A régua da faixa** — conta o que entra e o que chega à tela, por AÇÃO do jogador, nas duas fontes |
| `brport_vs/scripts/validation/contraste_ui.gd` | **A régua do contraste** — cor final contra fundo real, com herança, override e modulação. Dois consumidores: a ferramenta e o D33 (`035`) |
| `brport_vs/tools/medir_contraste_ui.gd` | A tabela de cada texto em cada estado do percurso (`CONTRASTE MEDIDO`). ⚠️ O percurso não monta dia passado; como ele alcança cada estado, e prova que chegou ao nó, está na `042`–`044` |
| `tools/conferir_escopo_ui.py` + `tools/excecoes_cor_ui.json` | **O portão do ESCOPO** — cor de UI pintada fora do tema sem exceção declarada reprova. Lê `.gd` e `.tscn` (`036`). **Zero chamadas e zero exceções** desde a 5ª leva; ele também denuncia exceção MORTA (`045`) |
| `brport_vs/scripts/PainelNarrativo.gd` | O andaime das telas narrativas — escurecer, cartão, título, parágrafo, botão. `montar(largura, 0)` ajusta o cartão ao conteúdo; e as peças de número das famílias (bloco de contas, quadro, barra do HUD) |
| `brport_vs/scripts/TelaNomes.gd` + `PainelDiario.gd` | A folha de rosto do caderno — o nome do cais, irrevogável (GDD 7), e o do jogador — e a primeira página do diário, por baixo dela. O caderno desenha-se em `FolhaDoCaderno.gd` (`067`) |
| `brport_vs/scripts/PainelBoletim.gd` | O Boletim Financeiro da Dona Cida, no fecho de cada semana — receita e despesa por fonte, e o tom dela conforme o resultado |
| `brport_vs/tools/recortar_captura.gd` | Recorta e amplia um pedaço de captura, sem suavizar |
| `tools/trilha_de_arte.{sh,py}` | **A trilha de arte, para o gate A5** — a bateria em cada ponto que tocou em arte, e o antes/depois de cada foto contra a primeira; o que mudou sai do hash do PNG |
| `docs/design/referencias/` | As imagens que definem o alvo de arte + a leitura escrita delas |
| `docs/design/BR_Port_Plano_Arte_Blender.md` | **O caminho medido** até o nível da referência: o que o Blender alcança, o que não alcança, e o que está aberto (`092`) |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta, cantos, botões e cartões. A cor de MAPA não vive aqui: quem a define é o gerador do SVG |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem o mapa e a barra de docas |
| `brport_vs/scenes/dock/Dock.tscn` | A metade de CENÁRIO de uma doca: píer, barco, guindaste, trabalhador |
| `brport_vs/scenes/dock/DocaCartao.tscn` | A metade de INTERFACE da mesma doca: valor, turnos, trabalhador, alvo de toque |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/art/icones/` | **Os ícones da interface**, em SVG chapado |
| `brport_vs/scripts/Icones.gd` | Registro dos ícones + helpers de rótulo e botão — o único lugar que sabe qual arquivo é qual ícone |
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs de IA e redimensiona |
| `tools/gerar_mapa_iso.py` | Gera mapa, vila, vias e o campo costeiro contínuo; raster determinístico, acumulado com `math.fsum`. **Desenha a `MEIA_LARG = 30` e entrega a 20 pelo `viewBox`** |
| `tools/medir_enquadramento.py` + `brport_vs/tools/medir_enquadramento.gd` | Régua do mapa e da fronteira visível; rasteriza com o mesmo ThorVG do jogo |
| `brport_vs/tools/medir_resolucao_mapa.gd` | **A régua da resolução do MAPA** — quanta fronteira sobrevive ao antisserrilhado, no ThorVG do jogo (`025`, `026`) |
| `tools/medir_nitidez_captura.py` | **A régua da resolução dos PROPS** — a mesma métrica em duas capturas a 1080×1920, com a máscara tirada da diferença (`029`) |
| `brport_vs/tools/medir_vram.gd` | **A régua da VRAM**, com o jogo aberto e calibrada; `xvfb-run`, `VRAM MEDIDA` (`049`) |
| `brport_vs/tools/medir_desempenho.gd` | **A régua do custo por quadro** — desenho, nós e o `_process` pela chamada direta, calibrada; `xvfb-run`, `DESEMPENHO MEDIDO` (`099`) |
| `playtest/` | As partidas reais do A7, uma por `.jsonl`, sem o nome de quem jogou (`006`, `099`) |
| `brport_vs/scripts/TrafegoDeCamioes.gd` | **Os camiões da rua** — rotas, cedência, visita ao berço; objeto do `Main`, lido pelo `trafego` (`095`) |
| `brport_vs/scripts/NarradoraDaCida.gd` | **A Dona Cida na faixa** — gatilhos, variantes e memórias; objeto do `Main` (`096`) |
| `brport_vs/scripts/TutorialDoToninho.gd` | **O tutorial do dia 1** — atracar e avançar, por cima do jogo e sem save; objeto do `Main` (`101`) |
| `brport_vs/scripts/VezDasTelas.gd` | **A vez das telas que abrem sozinhas**, uma de cada vez; objeto do `Main` (`054`, `097`) |
| `brport_vs/scripts/PropIso.gd` | **O quadro de um prop, num lugar só** — 512 de coordenada para 768 de pixel, e a conta que traduz um no outro (`029`); `imagem()` repõe o quadro de um prop em atlas (`049`) |
| `tools/medir_silhueta_props.py` | **A régua da forma** — a fração da silhueta nas três direções de uma caixa, contra formas ideais da MESMA caixa; diz "não sei" onde a peça é pequena ou esbelta demais (`024`) |
| `tools/arte_orfa.py` | **Que arte NÃO chega à tela** — relatório, não portão. «Órfão» não é «apagável» (`046`); hoje **9 de 334**, o atlas não conta (`049`) |
| `brport_vs/tools/medir_boletim.gd` | **A régua do boletim** — herda o simulador e confere cada afirmação da Dona Cida contra o estado, no instante em que ela fala. CI, `BOLETIM OK` (`048`) |
| `tools/comparar_props.py` | "Este prop mudou?", com os dois a 16×16 — cego à resolução; achou a gravata coplanar (`029`) |
| `tools/gerar_props_iso.py` | Gera os props isométricos em Blender por script, na projeção do mapa, a **768 px num quadro de 512 coordenadas** (`029`). Confere a própria projeção ao fim |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — N partidas em **quatro perfis**: Ótimo, Mediano, Descuidado e Antecipado (`018`). Mede a Fase 1 e pára na passagem (`104`) |
| `brport_vs/tools/leitura_do_simulador.gd` | A conclusão dele, fora do `SceneTree` para se provar com fixture (T7). Identidade ausente ou dupla: código 1 (`030`) |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor. Avança por TURNO efetivo, pelo botão do jogo, e pára diante de modal (`031`) |
| `brport_vs/tools/medir_trelica.gd` + `capturar_fase_2.gd` | Preços do recorte 2 e foto da partida jogada desde o dia 1 até ao cargueiro (`105`) |
| `brport_vs/tools/folha_props.gd` | **A folha dos props de mapa, a 1:1**, cada um sobre o chão que o mapa pinta sob a âncora dele (`027`). Reprova ao transbordar; o catálogo e o chão vivem em `catalogo_props.gd` |
| `brport_vs/tools/prancha_prop.gd` | **Para iterar UM prop**: a versão do jogo contra a candidata, na foto do jogo, a 1:1, ampliada, em silhueta e valor e na escala, com os números. Sem candidata exige Δ zero (`068`) |
| `brport_vs/tools/escala_props.gd` | **Os props a 1:1 com o pé na mesma linha**, o trabalhador de régua (`068`) |
| `brport_vs/tools/folha_icones.gd` | Folha dos ícones nos 3 fundos, a 19px e ampliado — a cada ícone novo. **Reprova ao transbordar** |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows), e o link do Pages. O protótipo HTML original é o `index.html` da raiz, publicado em `/prototipo/` |
| `tools/conferir_lote_de_arte.py` | Confere lote vindo de fora: alfa, tamanho e **ângulo da base contra os 26,57°**. Antes de qualquer PNG externo entrar |
| `docs/BRP_SPATIAL_CONTRACT.md` | **O contrato da projeção por escrito** — as constantes, os quatro participantes e o `ROT_X = 60°` |
| `blender/brp_studio.py` | O estúdio compartilhado — importa a câmera de `gerar_props_iso.py` em vez de a duplicar |
| `blender/gerar_brp.py` | Roda os quatro estúdios, exporta PNGs, salva `.blend` e junta o manifest |
| `brport_vs/scripts/Fauna.gd` + `AmbienteCosteiro.gd` | Ciclos de seis espécies em nove pontos; habitats, toque, mar e gaivota |
| `blender/validate_brp_assets.py` | Validador do lado do Blender: âncora, apoio ao solo, escala, coleção. **Não roda no CI** — precisa de ~1 GB de `bpy` |
| `brport_vs/scripts/validation/asset_validator.gd` | Validador do lado do Godot: quadro, alfa, recorte e **a projeção do manifest contra as âncoras do mapa**; e o atlas dos 69 props (`049`). Espera `ASSET OK` |
| `.claude/rules/` | **As regras por tema** (`091`): o núcleo do `CLAUDE.md` e `gerais.md` carregam sempre; as de tema, ao abrir um arquivo delas. O índice está no núcleo |
| `.claude/skills/` | **Os rituais**: `/fechar-sessao` (o fecho), `/arte` e `/balancear` (a medição e o rasto de cada frente) |
| `.claude/hooks/session-start.sh` | **O arranque da sessão** — baixa o Godot, importa o projeto, deixa o `$G` pronto |
| `.godot-version` | A versão do Godot, num lugar só. Lida pelo hook e pelo CI |
| `docs/design/BR_Port_Numeros_Fase_1.md` | **A tabela dos números, GERADA** do `GameState.gd`. Não editar à mão — o CI reprova se envelhecer |
| `tools/gerar_tabela_numeros.py` | Gera a tabela acima e cruza a leitura de texto com o que o Godot avalia |
| `brport_vs/tools/despejar_constantes.gd` | Despeja as constantes que o Godot avalia de verdade, em JSON. Espera `CONSTANTES OK` |
| `tools/projetar_parcelas.py` | Projeta as Parcelas 2 e 3 a partir da Fase 1 MEDIDA. Recusa-se a projetar se o modelo não reconstruir a Fase 1 |
| `docs/design/` | GDD 7, guias, e o Roadmap v2.1 + Plano da Fase 2 (superados, mantidos como registro) |
| `tools/capturar_evidencia.sh` | Fotografias determinísticas de jogo, painéis e folhas de contato; é a evidência visual do CI |
| `brport_vs/tools/folha_frota.gd` | **A folha da frota** — cascos e camiões percorrendo as tabelas: foto de jogo só mostra o que o sorteio escolheu. Os cascos e uma folha por transportadora (`070`) |
| `brport_vs/tools/folha_trabalhadores.gd` | **Os 30 rostos em cartões de verdade**, pelo `Retratos.TRABALHADORES`: reprova o cartão com outro arquivo ou sem desenho (`059`) |
| `.github/workflows/testes.yml` | A suíte, a tabela dos números, os sons, as âncoras, o export do APK e do Web, e o Web no Pages (`099`) |
| `.github/workflows/captura.yml` | As imagens anexadas a cada PR, e o antes/depois contra a base |
| `.github/workflows/balanceamento.yml` | As 600 partidas por perfil, às segundas e sob demanda |
| `tools/conferir_docs.py` | Confere as quatro camadas, referências, o teto do estado e o destino de cada aviso do briefing (`057`) |
| `tools/conferir_mutantes.py` + `mutantes.toml`; `conferir_colaboracao.py`; `renumerar_decisao.py` | **Os defeitos já provados, dos dois agentes**, reinjetados a cada PR (`117`, `120`); **o pré-PR entre agentes** e a renumeração que só toca as próprias linhas (`119`) |
| `tools/conferir_guardas_ci.py` | Deriva do workflow quem roda `--script` e exige saída preservada, marcador e varredura de erro. Espera `GUARDAS OK` |
| `tools/conferir_cobertura_paineis.py` | **Todo painel que o jogo abre tem foto?** Lê os logs da bateria contra o `_abrir_painel` do `Main`. Espera `COBERTURA OK` (`039`). Desce ao TEMPO (`051`) e à CARA (`060`), sem lacuna declarada |
| `brport_vs/art/sprites/` | ⚠️ Referidos só por `scenes/proto/`, que o export exclui — destino do Bruno (revisão §2.9) |
| `docs/REVISAO_GERAL_*.md` | Revisões gerais (17/09; 09/10 com plano de execução), com evidência |
| `docs/arquivo/` | O que aconteceu em cada sessão que já fechou, e o que fechou nos dois planos (`092`). **Nada se apaga** — o índice está no `docs/arquivo/README.md` |
| `docs/gdd/` | **O GDD 7 legível**, 80 páginas GERADAS do `.jsx`, uma seção por arquivo. Não editar. Congelado antes da reescala: onde divergir do jogo, manda o código |
| `tools/gerar_gdd_md.py` | Gera as acima. Recusa-se a adivinhar: forma de dado que não conheça **reprova**, em vez de sumir do markdown |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real); a tela anima a
  virada, e um toque a meio acaba-a (`078`)
- **A fila no fundeadouro** (`083`): três barcos ao largo, cada um com valor,
  carga e dois dias de paciência; tocar num atraca-o no berço livre com o
  trabalhador do píer, e o que não for chamado desiste e custa reputação
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas) — e ela **decide a contra-oferta**:
  reputação alta faz o cliente pagar cheio com mais frequência (`003`)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- **Motivo de escala por barco** — quatro motivos, cada um preso a uma estrutura
  que já existe. Nasce com o barco, entra no save e aparece no cartão (`008`)
- **Três classes de navio, travadas pelo nível do porto** — pesqueiro,
  cargueiro e longo curso, cada uma com a sua faixa de valor, os seus turnos e a
  sua mistura de motivos. A classe decide o casco no píer (`009`)
- **Três cobranças na Fase 1**, ao fim das semanas 4, 8 e 12. A semana só
  fecha depois da decisão; as duas primeiras retomam a partida, a terceira
passa à Fase 2 (`104`).
  **Quitar antes abate só juros da janela** (`085`) e mantém o recibo até o fecho
  do período, sem abrir a próxima cobrança antes dele (`085`). Sem o boleto
  nas duas primeiras, a segunda chance (`102`).
- **Três reparos disponíveis por progressão na Fase 1**, no catálogo de estruturas:
  píer 2, armazém e pátio. A terceira doca e os upgrades continuam na bancada
  de arte e testes, mas não podem ser comprados nesta Fase 1 (`085`). O guindaste
  fica em madeira; o conjunto visual n1 conserva a base correta (`086`). O
  pátio dobra a renda do píer; o bônus de contêiner espera o cargueiro (`103`).
- **A faixa de mensagem tem FILA** — as duas fontes (sistema e Dona Cida) uma
  de cada vez, por ordem, com tempo mínimo na tela; tocar nela abre o histórico
  da sessão (`034`)
- Autosave local a cada turno
- **Sete telas narrativas**: o caderno (os nomes na folha de rosto e a
  primeira página do diário), Boletim Financeiro semanal com os tons da Dona Cida, as 8
  falas de loop dela, as falas do Arlindo na negociação, a cena da parcela com
  o Sr. Ribeiro em dois tempos, e a narração de fim de Fase 1, entrada do
  diário em duas páginas (`082`) que segue para a Fase 2 (`104`)
- **E OS TRÊS NPCs TÊM ROSTO** (`020`): nove bustos com pose própria, ao lado
  da fala no boletim, na parcela e na contra-oferta. A cara sai da FALA, por
  tabela. Falta a faixa do rodapé: medida, à espera de layout. O **Toninho**
  guia o tutorial do dia 1, com três caras (`100`, `101`)
- Contabilidade semanal por fonte (docagens, armazém, píer, salários,
  manutenção, parcela) — **só observa**, não entra em conta nenhuma do jogo
- Fauna costeira tocável, com aparecimento, comportamento e saída por habitat

### O que já é arte de verdade, e o que ainda é placeholder
**O mapa do porto é a tela do jogo** (`Main.tscn`): costa, cais, cidade, props
e fauna vistos de cima. As docas são **3 vagas fixas sobre os píeres**; quantas
existem vem de `GameState.docks`; a terceira fica em ruínas nesta Fase 1.

A interface **não é montada por código**: cenas `.tscn` com um tema.

**O mapa não carrega interface em cima.** O texto e o alvo de toque de cada
doca vivem em `scenes/dock/DocaCartao.tscn`, abaixo do mapa; o píer ACENDE
quando é o berço que o toque num barco ao largo enche. O número de cada doca é
**tinta de piso**, em estêncil, porque o importador de SVG do Godot não desenha
`<text>`.

**Os ícones do HUD já são arte de verdade**: SVGs conferidos a 19px sobre os
três fundos da interface com `tools/folha_icones.gd`. Cada um foi colorido para
o fundo onde cai — o cabeçalho de `Icones.gd` diz quais não se reaproveitam.

As **estruturas trocam de textura, não de nó** — mesmo quadro nos dois estados,
então o prédio não salta ao ser consertado; as peças, essas, não se partilham
(`CLAUDE.md`).

**A cauda dos props tem corpo** (Etapa 2): contêiner, carga, boia, marcador e as
catorze peças do pátio, em `blender/brp_porto.py`; os nove retratos de fala e
os trinta do trabalhador saem de `blender/brp_retratos.py` (`056`, `059`).

O cenário usa os props: **coqueiros de tronco ARQUEADO** (`028`) que oscilam em
rajada, **guindaste** nas docas construídas, **carga no convés** e **boias +
marcador** na Zona de Espera. **Os camiões levam a carga do porto** e
**encostam de ré na doca** que tem barco e trabalhador (`011`, `077`); a
**espuma lava a costa** no mesmo campo contínuo da água; o **enrocamento para
nas duas pontas**.

**E as chapas lisas acabaram**: tabuado com junta no n2, junta atravessada no
n3, ferrugem nos cargueiros — padrões DIRIGIDOS, peça a peça, nunca pela paleta.

**O píer, a lança, a TORRE e o casco têm TRÊS NÍVEIS.** O píer vai de ripas a
laje de concreto sobre estacas de aço; a lança, de um pau só com amantilho
(`015`) a lança longa com spreader; a torre, de mastro de madeira a pórtico.
Quem escolhe são `nivel_pier()` e `nivel_guindaste()`, cada um preso ao seu
upgrade (`docs/decisoes/007`) — e desde 06/09 são elas que decidem também **que
navio atraca** (`009`), o que faz a trava ser visível em vez de estatística.

**O CASCO DIZ O QUE O NAVIO TRAZ, e o camião o que sai pela estrada** (`010`).
Seis cascos, um por par (classe, motivo): o costado é o mesmo e o CONVÉS é que
muda. O pesqueiro tem um casco só, e isso é afirmação: pescado e armazenagem são
o mesmo peixe indo para sítios diferentes. Os camiões são um por motivo e por
transportadora — duas, que se revezam (`070`).
O **trabalhador aparece no tabuado** quando alocado — no nível 3, na empilhadeira.

**E O BARCO DE PESCA DIZ QUANTO VALE A ESCALA:** bote, traineira e arrasteiro,
cada um com gramática própria; a faixa de valor da classe escolhe qual atraca.

Os **retratos** saem do mesmo estúdio Blender e são os únicos props que olham
para a frente; o boneco do PÍER é outro.

A **Zona de Espera mostra a fila mecânica** (`083`): o jogador escolhe quem
atraca. Ela fundeia **ao largo**, fora do gradiente costeiro (`017`).

Para depois: a MÚSICA (há os efeitos de rascunho) e a lista "VS — OUT" do GDD.

---

## Como retomar numa conversa nova

Por este arquivo e pela §7 do plano, com o que se quer fazer. Para fechar,
**`/fechar-sessao`**; para preço ou `# TUNING:`, **`/balancear`**.
