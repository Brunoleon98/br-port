# BR Port — Estado do Projeto

> **Como o jogo está hoje.** É a segunda das quatro camadas de documentação
> deste projeto, e a única que nenhum teste protege — se envelhecer, envelhece
> calada.
>
> **Última atualização:** 26/09/2026 — tela inicial, três espaços, pausa curta e o celular (`066`), 3.ª passagem à espera do veredito
>
> **A tabela das quatro camadas está no `CLAUDE.md`, que carrega sozinho** —
> não se repete aqui. Esta é a segunda; o que vem a seguir está na §7 de
> `docs/design/BR_Port_Plano_v3_Claude_Code.md`, e o porquê de cada escolha em
> `docs/decisoes/NNN-*.md`, uma por arquivo.
>
> Retome por este estado e pelo plano. Histórico: `docs/arquivo/HISTORICO.md`;
> sessões fechadas: `docs/arquivo/`.

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador, R$400.000 e **sete
estruturas** — píeres 2 e 3, armazém, pátio, escritório e os dois UPGRADES
(guindaste e cais reforçado). Comprar cada uma muda o mapa.

**A barra de ação tem DOIS botões e uma hierarquia** — "Avançar dia" é âmbar
cheio com rótulo navy e "Alocar todos" é navy com borda e rótulo âmbar
(`BotaoDestaque`): âmbar nos dois seria nenhum em destaque.

**A câmera mostra um DISTRITO e não três berços.** O `MEIA_LARG` efetivo é 20 e
ela centra-se no centroide dos berços; o mundo cresceu para isso (`my` de −14 a
42, fundo da terra em −16), senão o mapa ACABAVA à vista por três lados.

**A água é tropical e lê como profundidade, não como fitas** — campo de cor
contínuo pela distância à costa, com meandro longo de duas senóides, e a areia
em rampas. A paleta medida não mudou (amplitude 99,408; espuma 0,558 de Weber).

**E AS DUAS PONTAS SÃO COSTA DESENHADA** (`023`): a maior reta da linha de
água caiu de 224 px para 16 e as quinas de 126,9° para 14°. **O cais continua
reto**, que é o que ele é. Linha de água, baixio, espuma, pedras, rampa e o
campo da água saem de `ponto_costeiro()`, família concêntrica que não se cruza
— é isso que impede costura. **D28** tranca a forma; o raster, D20/D21/D24/D27.

**A RESOLUÇÃO SUBIU NAS DUAS ALAVANCAS QUE PAGAM** — mapa a 1080 (`025`) e
props a 768 px num quadro de 512 COORDENADAS (`029`), com `expand_mode` em 31
nós e o `PropIso` a traduzir; o **D31** tranca. ⚠️ **E A MOLDURA (89,6% do
quadro) SAIU DA VRAM** sem mexer no quadro: o importador `texture_atlas` apara-a
e a margem repõe os 768 — **235,68 → 64,04 MB** em jogo, `.pck` −17,4%
(`049`). O campo da água fica a 720 (`026`); o viewport (C) não dá um pixel.

**E OS CASCOS TÊM CURVA** (`024`): medida a silhueta, quem estava quadrado não
eram as construções — era o casco, com o contêiner a TAPÁ-LO. Os nove barcos
saem de `contorno_casco()`. Armazém, escritório, píer, treliça, pallet e
contêiner **ficam quadrados, e é decisão**: são caixas de verdade. **D29**.

**A fauna tem seis espécies em nove pontos**, três na costa e três em terra, à
escala de uma pessoa, com toque de **44 px** (D25–D27).

**O jogo é TRANQUILO, e os valores são realistas.** Medido em 600 partidas por
perfil: ótimo 100% · mediano 80,2% · descuidado 37,3%, com a mediana do mediano
em R$716.179 contra uma parcela de R$530.000. Um contrato vale R$12.000–88.000 e
a manutenção custa R$40.000/semana. A dívida deixou de ser o motor (`005`):
separa os jogadores **o porto que conseguem levantar**, medido pela MARGEM em
regime (R$674.019 contra R$103.290) e não pela contagem de barcos. O
`START_CASH` está TRANCADO em 400.000 (`018`) — e o diário diz de onde vem,
herança do avô. Mexer em preço sem rodar `simular_balanceamento.gd` quebra isto.

**E o navio que atraca depende do porto que existe** (`009`): três classes
travadas pelo NÍVEL DO PORTO, o menor entre píer e guindaste — pesqueiro no 1,
cargueiro no 2, longo curso no 3, que exige o cais reforçado. O Descuidado nunca
vê um longo curso em 600 partidas; o painel Construir diz o nível e o que falta.

**E A FROTA DE PESCA TEM TRÊS PORTES** (`014`) — bote, traineira e arrasteiro,
pelo VALOR do contrato. Importa porque o porto em ruínas **só recebe pesqueiro**.

**E o navio vem ao porto POR ALGUMA COISA:** cada barco nasce com um MOTIVO —
Pescado, Armazenagem, Contêiner ou Granel —, lido no cartão da doca. O efeito é
o da ESTRUTURA a que o motivo está preso; oficina e posto são Fase 2 (`008`).

**A partida grava-se** — uma linha JSON por acontecimento, com o tempo de cada
turno, sem o nome de quem jogou (`006`). Sai pelo menu de pausa.

**O jogo tem som:** 14 efeitos de `tools/gerar_sons.py`, num autoload com
prioridade, dois buses e sliders. São de RASCUNHO e esperam o Bruno ouvir.

**E O HUD INFERIOR TEM UM MENU, QUE É UM CELULAR** (`021`): aparelho de 400×680,
com o **diário** (que abre uma vez e não tinha como ser relido) e quatro portas
FECHADAS — cidade, lojas, missões, análise (itens 18 a 21). **É casca, e de
propósito.**

**O ARMAZÉM é um armazém dos dois lados do par** e **o porto abre em RUÍNAS de
verdade** — parede desabada, meio telhado, portão fora do trilho.

**O porto tem uma CIDADE atrás dele.** Rua de **mão dupla** (1,8, com linha
central e passadeiras) — **três camiões descem e dois sobem, pela DIREITA, e os dois sentidos encostam nos berços** (`047`, `052`) —, calçada, acesso a cada berço, **duas fileiras de casas**
e uma **viela de terra entre elas** — a de trás mais rala, para a vila DESFIAR
contra a mata. Tem nível (`--nivel-vila=N`): térrea, sobrado, prédio.

**E a rua VIRA em vez de acabar:** cada cotovelo leva chanfro nas duas quinas
salientes (`013`), do tamanho que deixa o maior camião virar no asfalto (`053`).

**E TRÊS LOTES DA VILA NÃO SÃO CASA** (`022`): uma **igreja** com torre, uma
**praça** com coreto e **duas obras**, dos lotes VISÍVEIS — a 51 px quem
distingue é a silhueta, e por isso "comércios variados" ficou de fora.

**E a mata atrás dela é desenhada onde se vê** (`com_saia()`).

---

## Onde estamos na fila

**A fila em vigor é a §7 do plano** — ela é que diz o que vem a seguir e quais
itens param à espera do Bruno. Aqui fica só a posição.

| Fechado | O que ficou, medido |
|---|---|
| **Frente 3 do A5, 1.ª e 2.ª famílias** (25/09, `062`–`065`) — aceites | Boletim, contra-oferta, Sr. Ribeiro e balanço (o total no topo, a chance como barra, o custo da recusa, a tarja no tom); os painéis do HUD com os **recordes da partida** (`SAVE_VERSION` 9), a renda de cada doca, a reputação Comercial e a barra do HUD onde um número anda para uma meta. O **F14** e o **F15** conferem cada promessa contra o jogo. Referências em `docs/design/BR_Port_Referencias_Interface_Gestao.md` |
| **Frente 3 do A5, 3.ª família — 3 passagens** (26/09, `066`) — a 3.ª à espera do veredito | A **tela inicial** é a cena principal, com **três espaços de save** — o 1 é o `savegame.json` de sempre, sem migração — e a **pausa curta** com a tela **Ajustes**; o «Continuar» a 19 px e o «Apagar» vermelho; o **celular** com moldura, hora do aparelho, papel de parede e um ícone com cor por app. O **F16** tranca os espaços. O fundo e o logotipo são do Bruno no ChatGPT (`art_lab/tela_inicial/BRIEFING.md`) |
| **O save do jogador isolado** (25/09, `061`) | toda ferramenta com `--script` grava em `user://ferramentas/` (`ArmazemLocal.gd`); o save, as gravações e o volume do jogador ficam de fora. **F13** e a sentinela do CI; só vale em commits com a `061` |

**A §7.1 fechou: R1–R9 todos feitos**, e o A6 tem protocolo escrito
(`docs/PROTOCOLO_DE_ESCUTA.md`). Sem fila ordenada, o que se faz é escolha do
Bruno.

**Construídos:** B1–B8, A2–A4 e export APK/Web do A1. Gates humanos abaixo;
histórico em `HISTORICO.md`.

**Abertos e esperando o Bruno** — nenhum deles precisa de uma sessão ligada:

| Item | O que falta | Por que só ele |
|---|---|---|
| **A1** | Jogado e triado; fica **a ordem do resto** | Ver abaixo |
| **A4** | ⚠️ **Três leituras (13, 19 e 23/09)**, notas aplicadas (`048`): resta ler em voz alta as falas reescritas |
| **A5** | Julgado (31 «Não»); **frente 1 feita**; na **2** (retratos) os três que falam estão no jogo no kit afinado, cada um com a sua cabeça, em Standard (`055`, `056`), e o trabalhador em busto com os seus trinta rostos (`058`, `059`). Na **frente 3**, as famílias do cartão e do HUD foram aceites; a do sistema tem três passagens (`066`); restam diário, mensagens e nomes. O material do ChatGPT vive em `art_lab/` (porta: o `README.md` de lá) | A ordem do resto da frente 3 e das frentes 4–6 é dele. O galpão V3 que ele aprovou só existe lá (`art/f01-galpao`): **recuperar ou refazer**. O Codex entra por `AGENTS.md` |
| **A6** | **Ouvir** — a metade de máquina fechou (`040`) | Este contêiner não tem placa de som. O protocolo está em `docs/PROTOCOLO_DE_ESCUTA.md`: telefone-alvo, volume fixo anotado, isolado E em contexto, três perguntas acionáveis. ⚠️ Comece pela §4 — **o aviso tem 99% da energia abaixo de 500 Hz** |

### Ainda por fazer, medido

Das jogadas de 02–06/09 sobram o rodapé (A5), economia de Fase 2 e a madeira
podre (A4) — em `HISTORICO.md`.

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `brport_vs/tests/run_tests.gd` | Regressões da lógica, inclusive parcela no vencimento e perdas para o rival |
| `brport_vs/autoload/Audio.gd` | **O ponto único que toca som** — prioridade por frame, espera mínima por som, volume por bus |
| `tools/gerar_sons.py` | Gera os 14 efeitos de rascunho, inclusive mar e fauna. Só biblioteca padrão |
| `brport_vs/tests/teste_audio.gd` | **Teste de áudio** — cobre o que dá para provar sem ouvir |
| `brport_vs/autoload/Registro.gd` | Gravador `.jsonl`; nasce desarmado, e quem o arma é o jogo |
| `tools/ler_registros.py` | **O leitor** — resume N partidas e põe o jogador MEDIDO ao lado dos perfis supostos |
| `brport_vs/tools/gravar_partidas.gd` | Joga N partidas com o gravador armado. Existe para o CI pôr gravador e leitor a encontrar-se |
| `brport_vs/tests/teste_registro.gd` | **Teste do registro** — o `WRITE` que trunca, o teto, o relógio, e que o gravador não grava desarmado. Espera `REGISTRO OK` |
| `brport_vs/tests/teste_design.gd` | **Teste de design** — encaixe, profundidade, limites da interface, leitura raster do mapa e pixel contra coordenada nos nós de prop (`025`, `028`, `029`). O **D34** pergunta de ONDE vem um stylebox, que é o que nenhuma régua de texto sabe fazer (`045`); espera `DESIGN OK` |
| `brport_vs/tests/teste_fumaca.gd` | **Teste de fumaça** — toda `.tscn` instancia, todo ícone tem arquivo, o save de outra versão é descartado sem tocar no estado vivo, nenhum `{token}` chega cru, e **toda fala escrita chega ao jogo** |
| `brport_vs/scripts/Narrativa.gd` | **Todo o texto de fala, num lugar só**, **e a expressão que cada fala pede**. Número sai de constante e vai por EXTENSO; o F4 reprova dígito na narração e fala que o jogo não dispare. Traz também o `concordar()`, a concordância de plural num lugar só (`037`) |
| `brport_vs/scripts/ArmazemLocal.gd` | **Onde o jogo guarda o que é do jogador** — com `--script`, em `user://ferramentas/`. `tools/sentinela_do_jogador.py` prova-o no CI (`061`) |
| `brport_vs/scripts/Retratos.gd` | **O registro dos rostos** — qual PNG é qual personagem em qual expressão, como o `Icones.gd` para o ícone. Nove bustos (`020`) |
| `brport_vs/scripts/FilaDeMensagens.gd` | **A fila da faixa de mensagem** — FIFO, tempo mínimo por frase, fusão só por duplicata, histórico da sessão. Objeto do `Main` e nunca autoload (`034`) |
| `brport_vs/scripts/PainelMensagens.gd` | O histórico da faixa, ao toque nela. Overlay, em memória, sem migrar save |
| `brport_vs/tools/medir_fila_mensagens.gd` | **A régua da faixa** — conta o que entra e o que chega à tela, por AÇÃO do jogador, nas duas fontes |
| `brport_vs/scripts/validation/contraste_ui.gd` | **A régua do contraste** — cor final contra fundo real, com herança, override e modulação. Dois consumidores: a ferramenta e o D33 (`035`) |
| `brport_vs/tools/medir_contraste_ui.gd` | A tabela de cada texto em cada estado do percurso. Marcador `CONTRASTE MEDIDO`. ⚠️ Percurso: não monta dia passado. O `acao_vista` age DEPOIS da cena e drena a fila (`042`) — e não serve a painel, que não tem fila; o `barco` e o `estruturas` agem ANTES, e **provam que o estado chegou ao nó** (`043`, `044`) |
| `tools/conferir_escopo_ui.py` + `tools/excecoes_cor_ui.json` | **O portão do ESCOPO** — cor de UI pintada fora do tema sem exceção declarada reprova. Lê `.gd` e `.tscn`, corta comentário, aceita multilinha e exige que a variação exista (`036`). **Zero chamadas e zero exceções** desde a 5ª leva; ele também denuncia exceção MORTA (`045`) |
| `brport_vs/scripts/PainelNarrativo.gd` | O andaime das telas narrativas — escurecer, cartão, título, parágrafo, botão. `montar(largura, 0)` ajusta o cartão ao conteúdo; e as peças de número das famílias (bloco de contas, quadro, barra do HUD) |
| `brport_vs/scripts/TelaNomes.gd` | A tela de abertura: o jogador batiza o cais e diz o nome. Escolha irrevogável (GDD 7) |
| `brport_vs/scripts/PainelDiario.gd` | A primeira página do diário do avô, encadeada à tela de nomes |
| `brport_vs/scripts/PainelBoletim.gd` | O Boletim Financeiro da Dona Cida, no fecho de cada semana — receita e despesa por fonte, e o tom dela conforme o resultado |
| `brport_vs/tools/recortar_captura.gd` | Recorta e amplia um pedaço de captura, sem suavizar |
| `tools/trilha_de_arte.{sh,py}` | **A trilha de arte, para o gate A5** — corre a bateria em cada ponto que tocou em arte e monta o antes/depois de cada foto contra a primeira vez que foi tirada. O que mudou sai do hash de cada PNG; os passos são lista, porque em imagem passam do teto de uma página |
| `docs/design/referencias/` | As imagens que definem o alvo de arte + a leitura escrita delas |
| `docs/design/BR_Port_Plano_Arte_Blender.md` | **O caminho medido** até o nível da referência: o que o Blender alcança, o que não alcança, e em que ordem atacar |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta, cantos, botões e cartões. A cor de MAPA não vive aqui: quem a define é o gerador do SVG |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem o mapa e a barra de docas |
| `brport_vs/scenes/dock/Dock.tscn` | A metade de CENÁRIO de uma doca: píer, barco, guindaste, trabalhador |
| `brport_vs/scenes/dock/DocaCartao.tscn` | A metade de INTERFACE da mesma doca: valor, turnos, trabalhador, alvo de toque |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/art/icones/` | **Os 23 ícones da interface**, em SVG chapado |
| `brport_vs/scripts/Icones.gd` | Registro dos ícones + helpers de rótulo e botão — o único lugar que sabe qual arquivo é qual ícone |
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs de IA e redimensiona |
| `tools/gerar_mapa_iso.py` | Gera mapa, vila, vias e o campo costeiro contínuo; raster determinístico, acumulado com `math.fsum`. **Desenha a `MEIA_LARG = 30` e entrega a 20 pelo `viewBox`** |
| `tools/medir_enquadramento.py` + `brport_vs/tools/medir_enquadramento.gd` | Régua do mapa e da fronteira visível; rasteriza com o mesmo ThorVG do jogo |
| `brport_vs/tools/medir_resolucao_mapa.gd` | **A régua da resolução do MAPA** — quanta fronteira sobrevive ao antisserrilhado, no ThorVG do jogo (`025`, `026`) |
| `tools/medir_nitidez_captura.py` | **A régua da resolução dos PROPS** — a mesma métrica em duas capturas a 1080×1920, com a máscara tirada da diferença (`029`) |
| `brport_vs/tools/medir_vram.gd` | **A régua da VRAM**, com o jogo aberto e calibrada; `xvfb-run`, `VRAM MEDIDA` (`049`) |
| `brport_vs/scripts/PropIso.gd` | **O quadro de um prop, num lugar só** — 512 de coordenada para 768 de pixel, e a conta que traduz um no outro (`029`); `imagem()` repõe o quadro de um prop em atlas (`049`) |
| `tools/medir_silhueta_props.py` | **A régua da forma** — a fração da silhueta nas três direções de uma caixa, contra formas ideais da MESMA caixa; diz "não sei" onde a peça é pequena ou esbelta demais (`024`) |
| `tools/arte_orfa.py` | **A pergunta que nada mais faz: que arte NÃO chega à tela.** Relatório, não portão. ⚠️ **«Órfão» e «apagável» são duas perguntas**: dos 11, nove tinham propósito escrito (a bancada `AssetPlacementTest`) e ficaram; saíram os 2 SVG de píer, superados por props PNG. Hoje **9 de 115**; o atlas não conta (`046`, `049`) |
| `brport_vs/tools/medir_boletim.gd` | **A régua do boletim** — herda o simulador e confere cada afirmação da Dona Cida contra o estado, no instante em que ela fala. CI, `BOLETIM OK` (`048`) |
| `tools/comparar_props.py` | Responde "este prop mudou?" reduzindo os dois a 16×16 — cego à resolução, e foi ele que achou a gravata coplanar (`029`) |
| `tools/gerar_props_iso.py` | Gera os props isométricos em Blender por script, na projeção do mapa, a **768 px num quadro de 512 coordenadas** (`029`). Confere a própria projeção ao fim |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — N partidas em **quatro perfis**: Ótimo, Mediano, Descuidado e Antecipado (`018`). Imprime classes, motivos e o NÍVEL |
| `brport_vs/tools/leitura_do_simulador.gd` | A conclusão dele, fora do `SceneTree` para se provar com fixture (T7). Identidade ausente ou dupla: código 1 (`030`) |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor. Avança por TURNO efetivo, pelo botão do jogo, e pára diante de modal (`031`) |
| `brport_vs/tools/folha_props.gd` | **A folha dos 51 props de mapa, a 1:1**, cada um sobre o chão que o mapa pinta sob a âncora dele (`027`). Duas páginas, e reprova ao transbordar |
| `brport_vs/tools/folha_icones.gd` | Folha dos ícones nos 3 fundos, a 19px e ampliado — a cada ícone novo. **Reprova ao transbordar** |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows). O protótipo HTML original é o `index.html` da raiz |
| `tools/conferir_lote_de_arte.py` | Confere lote vindo de fora: alfa, tamanho e **ângulo da base contra os 26,57°**. Antes de qualquer PNG externo entrar |
| `docs/BRP_SPATIAL_CONTRACT.md` | **O contrato da projeção por escrito** — as constantes, os quatro participantes e o `ROT_X = 60°` |
| `blender/brp_studio.py` | O estúdio compartilhado — importa a câmera de `gerar_props_iso.py` em vez de a duplicar |
| `blender/gerar_brp.py` | Roda os quatro estúdios, exporta PNGs, salva `.blend` e junta o manifest |
| `brport_vs/scripts/Fauna.gd` + `AmbienteCosteiro.gd` | Ciclos de seis espécies em nove pontos; habitats, toque, mar e gaivota |
| `blender/validate_brp_assets.py` | Validador do lado do Blender: âncora, apoio ao solo, escala, coleção. **Não roda no CI** — precisa de ~1 GB de `bpy` |
| `brport_vs/scripts/validation/asset_validator.gd` | Validador do lado do Godot: quadro, alfa, recorte e **a projeção do manifest contra as âncoras do mapa**; e o atlas dos 69 props (`049`). Espera `ASSET OK` |
| `.claude/skills/fechar-sessao/SKILL.md` | **O ritual de fecho** — o que rodar conforme o que mudou, a captura, a varredura do que se aprendeu e o commit |
| `.claude/skills/arte/SKILL.md` | **O ritual da arte** — qual etapa precisa de Blender, a armadilha de trocar matiz sem olhar o valor, o recorte ampliado, e o rasto que a mudança envelhece |
| `.claude/skills/balancear/SKILL.md` | **O ritual da economia** — medir antes e depois com a mesma semente, e o rasto que isso envelhece |
| `.claude/hooks/session-start.sh` | **O arranque da sessão** — baixa o Godot, importa o projeto, deixa o `$G` pronto |
| `.godot-version` | A versão do Godot, num lugar só. Lida pelo hook e pelo CI |
| `docs/design/BR_Port_Numeros_Fase_1.md` | **A tabela dos números, GERADA** do `GameState.gd`. Não editar à mão — o CI reprova se envelhecer |
| `tools/gerar_tabela_numeros.py` | Gera a tabela acima e cruza a leitura de texto com o que o Godot avalia |
| `brport_vs/tools/despejar_constantes.gd` | Despeja as constantes que o Godot avalia de verdade, em JSON. Espera `CONSTANTES OK` |
| `tools/projetar_parcelas.py` | Projeta as Parcelas 2 e 3 a partir da Fase 1 MEDIDA. Recusa-se a projetar se o modelo não reconstruir a Fase 1 |
| `docs/design/` | GDD 7, guias, e o Roadmap v2.1 + Plano da Fase 2 (superados, mantidos como registro) |
| `tools/capturar_evidencia.sh` | Fotografias determinísticas de jogo, painéis e folhas de contato; é a evidência visual do CI |
| `brport_vs/tools/folha_frota.gd` | **A folha da frota** — cascos e camiões percorrendo as tabelas: foto de jogo só mostra o que o sorteio escolheu. Duas folhas desde `047` |
| `brport_vs/tools/folha_trabalhadores.gd` | **Os 30 rostos em cartões de verdade**, pelo `Retratos.TRABALHADORES`: reprova o cartão com outro arquivo ou sem desenho (`059`) |
| `.github/workflows/testes.yml` | A suíte, a tabela dos números, os sons, as âncoras, e o export do APK e do Web |
| `.github/workflows/captura.yml` | As imagens anexadas a cada PR, e o antes/depois contra a base |
| `.github/workflows/balanceamento.yml` | As 600 partidas por perfil, às segundas e sob demanda |
| `tools/conferir_docs.py` | Confere as quatro camadas, referências, o teto do estado e o destino de cada aviso do briefing (`057`) |
| `tools/conferir_guardas_ci.py` | Deriva do workflow quem roda `--script` e exige saída preservada, marcador e varredura de erro. Espera `GUARDAS OK` |
| `tools/conferir_cobertura_paineis.py` | **Todo painel que o jogo abre tem foto?** Lê os logs da bateria contra o `_abrir_painel` do `Main`. Espera `COBERTURA OK` (`039`). Desce ao TEMPO (`051`) e à CARA (`060`), sem lacuna declarada |
| `brport_vs/art/sprites/` | ⚠️ Referidos só por `scenes/proto/`, que o export exclui — destino do Bruno (revisão §2.9) |
| `docs/REVISAO_GERAL_2026-09-17.md` | Revisão geral de 17/09: defeitos e melhorias, com evidência |
| `docs/arquivo/` | O que aconteceu em cada sessão que já fechou. **Nada se apaga** — o índice está no `docs/arquivo/README.md` |
| `docs/gdd/` | **O GDD 7 legível**, 80 páginas GERADAS do `.jsx`, uma seção por arquivo. Não editar. Congelado antes da reescala: onde divergir do jogo, manda o código |
| `tools/gerar_gdd_md.py` | Gera as acima. Recusa-se a adivinhar: forma de dado que não conheça **reprova**, em vez de sumir do markdown |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Alocação de trabalhador por toque, por "Alocar todos" ou por arrasto
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas) — e ela **decide a contra-oferta**:
  reputação alta faz o cliente pagar cheio com mais frequência (`003`)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- **Motivo de escala por barco** — quatro motivos, cada um preso a uma estrutura
  que já existe. Nasce com o barco, entra no save e aparece no cartão (`008`)
- **Três classes de navio, travadas pelo nível do porto** — pesqueiro,
  cargueiro e longo curso, cada uma com a sua faixa de valor, os seus turnos e a
  sua mistura de motivos. A classe decide o casco no píer (`009`)
- Parcela única de **R$530.000** no fim da semana 4; paga ou recusada, a semana
  só fecha depois da decisão. **Quitar antes abate 0,25% por turno** (`019`),
  numa conta genérica que serve ao empréstimo da Fase 2. ⚠️ **A semana tem 8
  turnos e a partida 32 "dias"; passar a 7 está MEDIDO** — 16 corridas na §7 do
  plano, e o ponto que fecha pede um SEGUNDO botão, que espera o Bruno
- **Sete estruturas** — píer 2, píer 3, armazém, pátio, escritório e os dois
  upgrades —, cada uma mudando o mapa. O porto abre em ruínas com 1 doca. Os
  upgrades trancam-se pela cadeia `requer`, não por fase (`007`): o guindaste
  corta o turno do navio grande, e o cais DESTRAVA a classe dele (`009`)
- **A faixa de mensagem tem FILA** — as duas fontes (sistema e Dona Cida) uma
  de cada vez, por ordem, com tempo mínimo na tela; tocar nela abre o histórico
  da sessão. Nada se apaga: 30,7% do que o jogo dizia não chegava ao jogador,
  hoje 5,7% (`034`)
- Autosave local a cada turno
- **Sete telas narrativas**: nomes do cais e do jogador (abertura), primeira
  página do diário, Boletim Financeiro semanal com os tons da Dona Cida, as 8
  falas de loop dela, as falas do Arlindo na negociação, a cena da parcela com
  o Sr. Ribeiro em dois tempos, e a narração de fim de Fase 1
- **E OS TRÊS NPCs TÊM ROSTO** (`020`): nove bustos com pose própria, ao lado
  da fala no boletim, na parcela e na contra-oferta — que ganhou segundo tempo
  porque a despedida do Arlindo nunca tinha sido dita. A cara sai da FALA, por
  tabela. Falta a faixa do rodapé: medida, à espera de layout
- **Registro de partida em `.jsonl`**, um por partida, com o tempo de cada
  turno. Sai pelo menu de pausa
- Contabilidade semanal por fonte (docagens, armazém, píer, salários,
  manutenção, parcela) — **só observa**, não entra em conta nenhuma do jogo
- Fauna costeira tocável, com aparecimento, comportamento e saída por habitat

### O que já é arte de verdade, e o que ainda é placeholder
**O mapa do porto é a tela do jogo** (`Main.tscn`): costa, cais, cidade, props
e fauna vistos de cima. As docas são **3 vagas fixas sobre os píeres**; quantas
existem vem de `GameState.docks`, e a terceira mostra ruína até ser ampliada.

A interface **não é montada por código**: cenas `.tscn` com um tema.

**O mapa não carrega interface em cima.** O texto e o alvo de toque de cada
doca vivem em `scenes/dock/DocaCartao.tscn`, abaixo do mapa; o píer continua
alvo de arrasto e ACENDE quando aceita o trabalhador. O número de cada doca é
**tinta de piso**, em estêncil, porque o importador de SVG do Godot não desenha
`<text>`.

**Os ícones do HUD já são arte de verdade**: 23 SVGs conferidos a 19px sobre os
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
marcador** na Zona de Espera. **Três caminhões atravessam o mapa pela estrada**,
cada um com a carga da doca do mesmo índice e em duas silhuetas porque a rua
vira 90° — e **entram na doca** quando ela tem barco e trabalhador (`011`); a
**espuma lava a costa** no mesmo campo contínuo da água; o **enrocamento para
nas duas pontas**. Os coqueiros chapados saíram do SVG — `--sem-coqueiros` —
pela mesma razão que os píeres: o que se mexe não pode estar assado no fundo.

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
o mesmo peixe indo para sítios diferentes. Os camiões são quatro, um por motivo.
O **trabalhador aparece de pé no tabuado** quando alocado.

**E O BARCO DE PESCA DIZ QUANTO VALE A ESCALA:** bote, traineira e arrasteiro,
cada um com gramática própria; a faixa de valor da classe escolhe qual atraca.

Os **retratos** saem do mesmo estúdio Blender e são os únicos props que olham
para a frente; o boneco do PÍER é outro.

A **Zona de Espera é só visual**, e torná-la mecânica muda o balanceamento
medido. Desde 11/09 ela fundeia **ao largo**, fora do gradiente costeiro
(`docs/decisoes/017`).

Continuam para depois: a MÚSICA (os efeitos já existem, de rascunho), o Diário
do Porto e a lista "VS — OUT" do GDD. A cena de fim de Fase 1 já não está aqui:
existe, em dois tempos, e o balanço FECHA — o menu de pausa reabre-o.

---

## Como retomar numa conversa nova

Aponte este arquivo e diga o que quer fazer:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md` e a fila na §7 do
> plano. Quero trabalhar em X."

Regras e receita manual no `CLAUDE.md`. Para fechar, **`/fechar-sessao`**;
para preço ou `# TUNING:`, **`/balancear`** (600 partidas por perfil).
