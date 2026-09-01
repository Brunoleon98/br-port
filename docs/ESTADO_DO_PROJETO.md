# BR Port — Estado do Projeto

> Resumo de onde o projeto está. Serve para retomar o trabalho numa conversa
> nova sem precisar reexplicar tudo.
>
> **Última atualização:** 01/09/2026 (o jogo ganhou NPCs: sete telas
> narrativas, o jogador batiza o cais, e a Dona Cida fala. Antes disto o loop
> estava inteiro e não havia história nenhuma)
>
> 👉 **Vai retomar o trabalho? Comece por `docs/BLOCO5_BRIEFING_CONTINUACAO.md`.**
> Para saber **o que fazer a seguir e quem faz o quê**, o plano é
> `docs/design/BR_Port_Plano_v3_Claude_Code.md` — ele tem a fila, e diz em quais
> itens a máquina para e só o Bruno resolve.
> As regras que já custaram trabalho estão em `CLAUDE.md`, na raiz — o Claude
> Code carrega esse arquivo sozinho em toda sessão.

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador, R$3.250 e cinco estruturas
para consertar — píeres 2 e 3, armazém, pátio e escritório. Comprar cada uma
muda o mapa: o pátio sai de terra batida para asfalto com carga, os prédios
saem de ruína para telhado novo.

**Economia medida em 600 partidas por perfil:** ótimo 100% · mediano 47% ·
descuidado 0%. A mediana do mediano fecha em R$7.945 contra uma parcela de
R$8.000. Mexer em preço sem rodar `simular_balanceamento.gd` quebra isto.

**O jogo tem som.** Dez efeitos sintetizados por `tools/gerar_sons.py`, um
autoload `Audio.gd` com dois buses (Música e SFX), sliders de volume no menu de
pausa e todo o disparo ligado aos sinais do `GameState`. Os efeitos são de
RASCUNHO — a música e os sons finais do Suno/ElevenLabs entram trocando arquivo
por arquivo, sem mexer em código. **Ninguém que os fez os ouviu:** o contêiner
não tem placa de som (ver `docs/BLOCO6_BRIEFING_AUDIO.md` §2).

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

## Onde estamos no roadmap

**A reputação passou a fazer alguma coisa** (01/09) — item A3, fechado, e era
ele que travava os itens 5 a 15 da fila. Reputação alta faz o cliente do Arlindo
aceitar pagar cheio com mais frequência; reputação baixa faz o contrário. Só nas
apostas ("cortar metade", "manter o preço") — igualar continua a fechar sempre,
porque é o recuo de emergência do jogador.

O caminho foi escolha do Bruno, entre três. O registro, com todos os números,
está em `docs/decisoes/003-a-reputacao-passa-pela-negociacao.md`.

⚠️ **A barra estava SATURADA, e medir antes de codar foi o que salvou o item.**
Com +4 de reputação por barco e um porto que atende ~13 barcos por semana, ela
batia no teto de 100 na primeira semana: 79,8% das contra-ofertas do jogador
Ótimo e 53,8% das do Mediano aconteciam já no teto. Os dois perfis cuja
separação é o que interessa chegavam à decisão com a mesma barra. Os ganhos
foram divididos por cinco, e as medianas na oferta passaram a 86,0 / 74,1 /
59,5. **Uma barra saturada não é um sistema — é um bónus fixo com mais código.**

Medido, com o efeito desligado e ligado: a aposta ganha sobe de 71,3% para
87,3% no jogador Ótimo, de 43,0% para 49,5% no Mediano, e CAI de 44,4% para
39,0% no Descuidado. O balanceamento aguentou: 100% / 47,8% / 0% contra os
100% / 47,3% / 0% da base, mesma medida dentro da margem de ±4,0.

**A sessão já abre com o Godot pronto** (01/09) — item B1 da fila, fechado,
**a partir do momento em que estiver na main**: sessão nova arranca do branch
padrão, e um hook que viva só numa branch de trabalho não corre.
`.claude/hooks/session-start.sh` baixa o binário, roda o `--import` e diz numa
linha o que ficou disponível; a primeira mensagem de uma conversa nova já pode
rodar a suíte. Doze segundos a frio, seis a quente. O `bpy` (~1 GB) ficou de
fora de propósito: só faz falta em sessão de arte.

Construir isso destapou uma divergência que já existia: **o `CLAUDE.md` mandava
baixar a 4.6.1 e o CI rodava a 4.6.3.** A sessão testava numa versão e o PR era
barrado noutra. A versão passou a viver em `.godot-version`, lido pelos dois.

**O jogo ganhou história** (01/09) — item A4, construído; falta o gate humano.
Até aqui o loop estava inteiro e **a Dona Cida não aparecia uma única vez no
código**; o Sr. Ribeiro era uma linha de texto num painel. Agora são sete telas,
não as seis do plano — a entrada dos dois nomes ganhou tela própria por decisão
do Bruno, e é a primeira coisa que o jogador vê.

O texto todo vive em `scripts/Narrativa.gd`, como o ícone vive no `Icones.gd`.
O nome do cais e o do jogador saem por `GameState.texto()`, um ponto só, e o
teste de fumaça reprova qualquer `{token}` que chegue cru à tela.

⚠️ **Nenhuma tela é fase do `GameState`, e isso não é detalhe.** Uma fase nova
que bloqueasse o turno faria **24 de 30 partidas não terminarem** no simulador —
e o CI passaria na mesma, porque só procurava a linha `=== Leitura ===`. Medido,
consertado (o CI agora reprova `possível travamento`) e escrito no `CLAUDE.md`.
Como overlay, o balanceamento medido fica intocado por construção: as margens
semanais continuam R$3.320 / R$3.005 / R$1.633.

⏳ **O gate é do Bruno: ler o texto em voz alta.** Três desvios do rascunho de
escrita esperam por esse julgamento, e estão listados no A4 do plano.

**A cena que abre passou a ter teste** (01/09) — item B4, fechado.
`brport_vs/tests/teste_fumaca.gd` é o quinto passo do CI e espera `FUMACA OK`.
Cobre as três coisas que até aqui só o olho cobria: **toda** `.tscn` do projeto
instancia (as doze são achadas por varredura, não por lista — uma lista
envelhece calada e deixaria de fora justamente a cena nova), todo ícone
registrado em `Icones.gd` tem arquivo no disco, e o save de outra versão é
descartado. Os quatro defeitos foram injetados e os quatro reprovaram.

⚠️ **E o teste achou um bug de verdade, na migração de save.** Um save da
versão CORRENTE mas com o roster vazio era recusado *depois* de o `load_game()`
já ter escrito `turn`, `cash` e o resto por cima do estado vivo — e o arquivo
impossível ficava no disco para ser tentado outra vez no arranque seguinte. O
jogo sobrevivia por acidente: o `new_game()` que vem a seguir por acaso
reescreve todos os campos. Bastava um campo novo que ele não zerasse para o
estado impossível atravessar para a partida seguinte, que é **o bug das 4 docas
com outra roupa**. Agora tudo o que recusa vem antes de tudo o que escreve.

**Os números do jogo têm fonte única** (01/09) — item A2, fechado.
`docs/design/BR_Port_Numeros_Fase_1.md` é GERADO do `GameState.gd` e o CI
reprova quem mexe numa constante sem regerar. São dois programas de propósito:
o Godot despeja o que ele avalia de verdade, o Python lê o texto (é de lá que
saem os comentários que dizem se o número veio do GDD ou é TUNING), e as duas
leituras são cruzadas nome a nome — uma constante que o parser não entenda
REPROVA, em vez de sumir da tabela em silêncio.

**As Parcelas 2 e 3 deixaram de ser desconhecidas** (01/09) — e a resposta é o
contrário do que o GDD temia. Elas fecham: 2,2× e 4,5× de folga no cenário
conservador, para o jogador que joga bem; 2,0× e 4,0× para o mediano. O card
"Risco crítico da Parcela 3", que mandava escolher entre pôr o armazém a render
desde a semana 2 ou baixar a Parcela 3 para R$18.000, **perdeu o motivo** — ele
nascia do mesmo cenário de 2 barcos/semana que a errata já tinha derrubado.

⚠️ **Fica uma pergunta de design em aberto, e ela é a que importa.** O valor de
contrato cresce ×2,9 e depois ×2,5 por fase; a parcela cresce ×2,0 e ×1,5. A
receita corre mais depressa do que a dívida, então **a tensão que faz a Fase 1
medir 47% desaparece a partir da semana 5.** Subir as parcelas, assumir que é
de propósito, ou trocar o que pressiona — não está decidido, e codar a economia
da Fase 2 sem resolver isto é construir em cima de uma pergunta. O registro,
com os números e o modo de refazer a conta, está em
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.

Isto é **projeção, não medição** — a Fase 1 é medida no jogo que existe, as
outras duas são a mesma conta com os números que o GDD dá para elas. Vira
medição quando as Fases 2 e 3 estiverem implementadas, e a errata continua a
dizer que isso não se faz antes de o VS sair.

**O mapa foi refeito a partir do que a captura mostrou** (31/08). O que estava
errado, e agora não está: 40% do quadro era uma laje de asfalto atrás da vila
(virou solo tropical com orla de mata, moita e capim); o escritório e o armazém
pousavam em cima de casas (a vila abre vão no `my` que a PROJEÇÃO diz, não no
`my` do prédio); a rua tinha o mesmo cinza do pátio e nenhuma borda (asfalto
mais escuro e meio-fio); a água eram três faixas chapadas com aresta dura e
oito ondas repetidas igual em todo degrau (gradiente radial de profundidade,
ondas variadas, espuma na linha de costa); e a baliza da Zona de Espera
projetava sombra de contato NA ÁGUA.

**O pipeline Blender -> Godot do pacote está implementado** (31/08):
`blender/` com quatro estúdios que partilham a câmera de `gerar_props_iso.py`,
15 assets novos, manifest, dois validadores (um de cada lado), a cena
`scenes/tests/AssetPlacementTest.tscn` e um passo novo no CI. O que foi e o que
NÃO foi feito está em `docs/BRP_IMPLEMENTATION_NOTES.md`; os resultados
medidos, em `docs/BRP_VALIDATION_REPORT.md`.

**Chegou um pacote de arte externo em 31/08, e ele NÃO reabre o design.** Seis
partes, 27 PNGs e 12 guias, com telas de gameplay dos cinco níveis e um prompt
de pipeline Blender → Godot. As telas descrevem outro jogo — tempo real com
controle de velocidade, formato paisagem, Pesquisa e Loja —, e ficou decidido
que **o GDD 7 continua valendo**: o pacote entra como referência de arte e nada
mais. O registro, com as medições que sustentam a decisão, está em
`docs/decisoes/001-pacote-de-arte-externo-e-o-gdd-7.md`. O conferidor de lote
que saiu daí é `tools/conferir_lote_de_arte.py` — **rodar em toda arte que
chegar de fora**: o lote de 31/08 tinha metade das peças em outra projeção
(34,6° contra os 26,57° do mapa) e nenhuma a olho denunciava isso.

**O planejamento das Fases 4 a 7 foi REFEITO em 30/08** —
`docs/design/BR_Port_Plano_v3_Claude_Code.md`. O cronograma antigo (44 semanas,
~490h com buffer, 10–14 meses) foi calibrado para *"dev solo iniciante em Godot,
8h/semana"*: os Blocos 2 a 4, orçados ali em 28 semanas, saíram em sete dias.
O plano novo troca a semana pela **sessão** como unidade, ordena o trabalho em
duas trilhas — o JOGO e o PROJETO/CLAUDE — e orça a parte que continua cara:
os seis momentos em que só uma pessoa resolve (jogar, ouvir, olhar, decidir).

**Fase 4 — Produção do Vertical Slice**. O **Bloco 2 (loop core)** está entregue
e o **Bloco 3 (marco intermediário) está FECHADO** — playtest humano feito,
decisão registrada, ajustes aplicados.

As Fases 1–3 já foram concluídas antes: o protótipo HTML de diagnóstico foi
jogado e aprovado (Playtest V3 ✅ GO) e o **GDD 7 está congelado** como fonte da
verdade (`docs/design/BR_Port_GDD_V7.jsx`).

**Decisão do Bloco 3 (26/08):** *ajustar antes de ir para a arte* — e os
ajustes já foram feitos, dentro de 1 semana. O registro completo, com as 5
partidas do playtest e o raciocínio, está em
`docs/BLOCO3_MARCO_INTERMEDIARIO.md`, Parte 3.

**Bloco 4 — arte final, áudio e integração — está EM ANDAMENTO.** Os dois
primeiros itens da ordem de trabalho (`docs/BLOCO4_BRIEFING_VISUAL.md`) saíram
em 27/08:

1. ✅ **Style guide de flat design** —
   `docs/design/BR_Port_Style_Guide_Flat_Design.md`. Paleta de UI (já
   validada) + paleta nova de mapa/cenário, peso de linha, espaçamento,
   proporções canônicas e convenção de cor por estado.
2. ✅ **Estrutura do mapa do porto com placeholder** — a antiga fileira
   "Docas" virou um mapa visto de cima (`Main.tscn`, seção "Porto"):
   Escritório (terreno) | Docas (dinâmico, 2–3 conforme upgrade) | Zona de
   Espera, sobre um fundo de água. Ainda formas simples — valida a leitura
   espacial antes de encomendar sprite.

3. ✅ **Pacote de sprites tratado** (28/08) — os PNGs vieram **sem canal alpha**
   (o quadriculado que parece transparência estava pintado nos pixels);
   `tools/preparar_sprites.py` conserta isso e é para ser reusado a cada leva
   nova. Análise do pacote em `docs/BLOCO4_PACOTE_SPRITES.md`.
   ⚠️ Desses 5 PNGs, **só `trabalhador.png` continua carregado pelo jogo** — o
   resto ficou para a migração isométrica, porque em cima de um mapa topo-down
   eles eram erro de perspetiva.
4. ✅ **Mapa virou a tela do jogo** (28/08) — docas são 3 vagas fixas sobre os
   píeres, e "Ampliar píer" acende a terceira.
5. ✅ **Camada de ícones fechada** (29/08) — os 20 ícones da interface são SVG
   em `art/icones/`, registrados em `scripts/Icones.gd`. **Nenhuma tela do jogo
   usa emoji.** São vetor chapado, não isométrico: ícone de HUD é interface e
   precisa se ler a 19px, o que o estilo isométrico não entrega nesse tamanho —
   então esta camada NÃO muda quando o mapa migrar.

Faltam os itens 6–7 do plano: áudio e integração progressiva.

🔄 **Direção de arte: ISOMÉTRICA (decidida 28/08) — decisão fechada.** Ela
oscilou três vezes na sessão (3/4 ilustrado → chapado topo-down → isométrico);
o histórico e o porquê estão na §2 do briefing de continuação, para não voltar
atrás de novo.

**O jogo em produção JÁ É isométrico** (29/08) e continua com a suíte inteira
passando. `Main.tscn` roda sobre `porto_mapa_iso.svg` com os props de
`tools/gerar_props_iso.py` — píer nos dois estados, barcos, cenário. O que
destravou foi gerar por script em vez de por prompt: num plano isométrico
nenhum eixo é horizontal (ambos a 26,57°), e o ângulo deixou de ser uma coisa
que alguém acerta para ser uma conta que não pode sair errada.

Continuam com gerador de imagem só os **retratos** (Arlindo, Sr. Ribeiro), onde
a perspectiva não importa porque vivem em painel.

👉 **Para retomar, o ponto de entrada é `docs/BLOCO4_BRIEFING_CONTINUACAO.md`**
— estado atual, decisões fechadas e os caminhos que restam (o dos ícones foi
fechado em 29/08).
`docs/BLOCO4_BRIEFING_VISUAL.md` continua válido como registro das decisões
sobre a imagem de referência original (turnos mantidos, R$ e não $, retrato).

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `CLAUDE.md` (raiz) | **As regras do projeto que carregam sozinhas** — projeção, save, arte, interface, e como rodar Godot e Blender aqui dentro |
| `brport_vs/tests/run_tests.gd` | ~72 asserções de regressão (a lógica), incluindo `T5f` — a reputação a mexer na contra-oferta |
| `brport_vs/autoload/Audio.gd` | **O ponto único que toca som** — prioridade por frame, espera mínima por som, volume por bus |
| `tools/gerar_sons.py` | Gera os 10 efeitos de rascunho. Sem dependência: só biblioteca padrão |
| `brport_vs/tests/teste_audio.gd` | **Teste de áudio** — cobre o que dá para provar sem ouvir |
| `brport_vs/tests/teste_design.gd` | **Teste de design** — se os props caem em cima do que o mapa desenhou, se a ordem dos nós respeita a profundidade e se a interface cabe na tela |
| `brport_vs/tests/teste_fumaca.gd` | **Teste de fumaça** — toda `.tscn` do projeto instancia (achadas por varredura, não por lista), todo ícone de `Icones.gd` tem arquivo, o save de outra versão é descartado sem tocar no estado vivo, e nenhum `{token}` de texto chega cru à tela |
| `brport_vs/scripts/Narrativa.gd` | **Todo o texto de fala, num lugar só** — diário, os 3 tons da Dona Cida, as 8 falas de loop, o Arlindo, o Sr. Ribeiro e o fim de fase. Os números da narração saem das constantes, nunca escritos à mão |
| `brport_vs/scripts/PainelNarrativo.gd` | O andaime das telas narrativas — escurecer, cartão, título, parágrafo, botão. `montar(largura, 0)` ajusta o cartão ao conteúdo |
| `brport_vs/scripts/TelaNomes.gd` | A tela de abertura: o jogador batiza o cais e diz o nome. Escolha irrevogável (GDD 7) |
| `brport_vs/scripts/PainelDiario.gd` | A primeira página do diário do avô, encadeada à tela de nomes |
| `brport_vs/scripts/PainelBoletim.gd` | O Boletim Financeiro da Dona Cida, no fecho de cada semana — receita e despesa por fonte, e o tom dela conforme o resultado |
| `brport_vs/tools/recortar_captura.gd` | Recorta e amplia um pedaço de captura, sem suavizar. A 19px um ícone não se julga a olho |
| `docs/design/referencias/` | As imagens que definem o alvo de arte + a leitura escrita delas |
| `docs/BLOCO7_PLANO_ARTE_BLENDER.md` | **O caminho medido** até o nível da referência: o que o Blender alcança, o que não alcança, e em que ordem atacar |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta do protótipo HTML, cantos, botões, cartão de doca, cartão de trabalhador e letreiro. Os tokens de cor de mapa saíram daqui em 30/08: quem os define é o gerador do SVG |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem o mapa, os letreiros e a barra de docas |
| `brport_vs/scenes/dock/Dock.tscn` | A metade de CENÁRIO de uma doca: píer, barco, guindaste, trabalhador |
| `brport_vs/scenes/dock/DocaCartao.tscn` | A metade de INTERFACE da mesma doca: valor, turnos, trabalhador, alvo de toque |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/art/sprites/` | Sprites prontos (trabalhador, cargueiro, barco de pesca, caminhão, guindaste) |
| `brport_vs/art/icones/` | **Os 20 ícones da interface**, em SVG chapado |
| `brport_vs/scripts/Icones.gd` | Registro dos ícones + helpers de rótulo e botão — o único lugar que sabe qual arquivo é qual ícone |
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs gerados por IA e redimensiona — rodar a cada leva nova |
| `docs/BLOCO4_GUIA_GERACAO_ASSETS.md` | Prompts de gerador (retratos) + o que o píer construível exige |
| `docs/BLOCO4_BRIEFING_CONTINUACAO.md` | **Ponto de entrada para retomar** — estado, decisões fechadas, 3 caminhos possíveis |
| `docs/BLOCO4_PROMPTS_ISOMETRICO.md` | **Prompts do visual escolhido** — isométrico, orientação obrigatória, animação e evolução por Fase |
| `docs/BLOCO4_PROMPTS_VISUAL_CHAPADO.md` | Superado — versão topo-down, mantida pelo registro |
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo — inclui a malha viária, a vila (`--nivel-vila=N`) e os números de doca pintados no cais |
| `tools/gerar_props_iso.py` | Gera os props isométricos (píer, barcos, guindaste, coqueiro, galpão, cenário) em Blender por script, na projeção do mapa. Confere a própria projeção ao fim |
| `docs/BLOCO4_PACOTE_SPRITES.md` | O que do pacote de sprites/mockups entrou, o que não entrou e por quê |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor |
| `brport_vs/tools/folha_icones.gd` | Folha de contato dos ícones nos 3 fundos da interface, a 19px e ampliado — **rodar a cada ícone novo** |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows) |
| `docs/BLOCO3_MARCO_INTERMEDIARIO.md` | Medição do balanceamento + roteiro do playtest + onde registrar a decisão |
| `docs/decisoes/` | **Uma decisão por arquivo** — por que se decidiu assim, para não rediscutir o que já foi fechado |
| `tools/conferir_lote_de_arte.py` | Confere lote de arte vindo de fora: alfa de verdade, tamanho e **ângulo da base contra o contrato de 26,57°**. Rodar antes de qualquer PNG externo entrar |
| `docs/BRP_SPATIAL_CONTRACT.md` | **O contrato da projeção por escrito** — as constantes, os quatro participantes e a regra que faltava no guia do pacote de arte: `ROT_X = 60°` |
| `blender/brp_studio.py` | O estúdio compartilhado — importa a câmera de `gerar_props_iso.py` em vez de a duplicar. Âncora, volume de seleção, nomenclatura e manifest |
| `blender/gerar_brp.py` | Roda um estúdio (`terreno`, `porto`, `cidade`, `fauna`), exporta os PNGs e junta o manifest. Um estúdio por processo — `preparar_cena()` apaga a cena inteira |
| `blender/validate_brp_assets.py` | Validador do lado do Blender: âncora, apoio ao solo, escala, coleção. **Não roda no CI** — precisa de ~1 GB de `bpy` |
| `brport_vs/scripts/validation/asset_validator.gd` | Validador do lado do Godot: quadro, alfa, recorte e **a projeção do manifest contra as âncoras do mapa**. Roda no CI, espera `ASSET OK` |
| `.claude/skills/fechar-sessao/SKILL.md` | **O ritual de fecho** — o que rodar conforme o que mudou, a captura, a varredura do que se aprendeu e o commit |
| `.claude/hooks/session-start.sh` | **O arranque da sessão** — baixa o Godot, importa o projeto, deixa o `$G` pronto. Nunca derruba a sessão: todo caminho de erro devolve a receita manual |
| `.godot-version` | A versão do Godot, num lugar só. Lida pelo hook e pelo CI |
| `docs/design/BR_Port_Numeros_Fase_1.md` | **A tabela dos números, GERADA** do `GameState.gd`. Não editar à mão — o CI reprova se envelhecer |
| `tools/gerar_tabela_numeros.py` | Gera a tabela acima e cruza a leitura de texto com o que o Godot avalia |
| `brport_vs/tools/despejar_constantes.gd` | Despeja as constantes que o Godot avalia de verdade, em JSON. Espera `CONSTANTES OK` |
| `tools/projetar_parcelas.py` | Projeta as Parcelas 2 e 3 a partir da Fase 1 MEDIDA. Recusa-se a projetar se o modelo não reconstruir a Fase 1 |
| `docs/decisoes/002-*.md` | Sentry só depois do A8; Freesound descartado (403 medido no proxy) |
| `docs/design/BR_Port_Plano_v3_Claude_Code.md` | **O plano em vigor** — a fila do que fazer, as duas trilhas (jogo e projeto/Claude) e os gates que só o Bruno fecha |
| `docs/design/` | GDD 7, guias, Validation Guide, e o Roadmap v2.1 + Plano da Fase 2 (superados no cronograma, mantidos como registro das decisões) |
| `index.html` (raiz) | O protótipo HTML original, já validado |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Drag-and-drop de trabalhadores para as docas
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas qualitativas)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- Parcela única de R$ 8.000 ao Sr. Ribeiro, vencendo na semana 4
- Upgrade único (ampliar píer: +1 doca, +1 trabalhador)
- Autosave local a cada turno
- **Sete telas narrativas**: nomes do cais e do jogador (abertura), primeira
  página do diário, Boletim Financeiro semanal com os 3 tons da Dona Cida, as 8
  falas de loop dela, as falas do Arlindo na negociação, a cena da parcela com
  o Sr. Ribeiro em dois tempos, e a narração de fim de Fase 1
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

O cenário usa os props: **coqueiros low-poly** (que oscilam, copa e tronco em
peças separadas), **guindaste** nas docas construídas (a lança varre), **carga
no convés** e **boias + marcador** na Zona de Espera. Os coqueiros chapados
saíram do SVG do mapa — `gerar_mapa_iso.py --sem-coqueiros` — pela mesma razão
que os píeres: o que se mexe não pode estar assado no fundo.

Continuam **sem uso** `galpao` e `galpao_velho` (os prédios do mapa já fazem
esse papel) e as versões avulsas de `caixote`/`conteiner` (foram assadas no
píer).

Os **3 barcos do GDD** existem (pesqueiro, cargueiro médio e grande), e o
pesqueiro tem casco próprio — não é o mesmo casco com carga trocada. O
**trabalhador aparece de pé no tabuado** quando alocado, e mexe-se enquanto a
operação corre.

Ainda é placeholder o **retrato ilustrado do trabalhador** no cartão da
fileira, que é de outra leva e de outra linguagem visual.

A **Zona de Espera é só visual**: os barcos ancorados são decorativos e não
representam fila de verdade — barcos continuam nascendo direto nas docas.
Torná-la mecânica muda o balanceamento medido (ver o aviso em
`BLOCO4_BRIEFING_VISUAL.md`).

Continuam para depois: a MÚSICA (os efeitos já existem, de rascunho), o Diário
do Porto, a cena narrativa de fim de Fase 1 e a lista "VS — OUT" do GDD.

---

## Balanceamento — resolvido no Bloco 3

O jogo **estava no fio da navalha**, não fácil como o handoff dizia. O playtest
humano confirmou: 5 partidas, 1 vitória, e uma delas perdida por **R$ 1**
(R$ 7.999 contra R$ 8.000) — jogando bem, sem perder barco.

A causa não era o valor do barco: era a **vazão**. Com 3 turnos por semana, a
parcela só cabia inflando o barco para R$ 240–760, fora da faixa do GDD.

**Correção aplicada:** 8 turnos por semana, barcos de volta a **R$ 80–300**
(a faixa que o GDD define para a Fase 1).

| Perfil | Antes | Depois |
|---|---|---|
| Joga perfeito | 58,5% | **99,7%** |
| Joga mediano | 7,2% | **63,8%** |
| Joga mal | 0,1% | **0,7%** |
| Folga no vencimento | 2% | **20%** |

A dívida técnica registrada antes — "valores de barco acima do GDD" — **não
existe mais**.

### Achados de design que vieram junto

- **A contra-oferta do Arlindo virou uma decisão de verdade.** O botão "Manter
  preço" não tinha chance nenhuma de dar certo — apertar duas vezes sempre
  perdia o barco. Agora os 3 presets são os do GDD ("Igualar −15%" / "Cortar
  metade −7%" / "Manter preço"), os dois últimos são apostas reais, e igualar
  depois de insistir custa 28% em vez de 15%.
- **A economia do GDD não fechava.** Erro de aritmética no próprio GDD: o
  modelo da Fase 1 acumulava R$ 1.480 em 4 semanas contra uma parcela de
  R$ 8.000. Corrigido, com registro em
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. As Parcelas 2 e 3 ficaram
  não verificadas até 01/09, quando foram projetadas — ver o roadmap acima:
  **fecham com folga grande, e o problema virou o oposto.**
- **Ninguém quebra por caixa.** O píer sozinho paga os custos, então a derrota
  por caixa negativo continua sendo código morto: a única forma de perder é o
  portão da parcela. Fica anotado, não foi mexido.
- ~~A reputação ainda não afeta nada mecanicamente~~ — **resolvido em 01/09**
  (item A3). Ela decide a contra-oferta. Ver o roadmap acima e
  `docs/decisoes/003`.

Para medir qualquer mudança: constantes marcadas `# TUNING:` no topo de
`brport_vs/autoload/GameState.gd`, e o simulador mede o efeito em segundos.

---

## Histórico de correções relevantes

O playtest de 30/08 encontrou um bug de estado e três defeitos de imagem:

1. **A compra dos píeres duplicava.** O jogador via as opções "Reconstruir o
   Píer 2" e "Píer 3" mesmo já tendo os píeres, e comprá-los levava o porto a
   **4 docas num mapa que só desenha 3** — a quarta recebia barco e nunca
   aparecia na tela. A causa não estava na compra: estava no SAVE. Ele não
   tinha versão, e um jogo gravado quando o porto ainda abria com 2 docas
   continuava a ser carregado depois de `DOCKS_BASE` cair para 1. Hoje há
   `SAVE_VERSION`, `BERCOS_NO_MAPA` é regra do jogo (não constante de tela) e
   `_reconciliar_roster()` deriva docas e trabalhadores do que está
   construído.
2. **O trabalhador parecia pendurado no guindaste.** Era o último filho de
   `Dock.tscn` e por isso desenhado por cima do cabo e do moitão, que estão à
   frente dele no mundo. Ordem de nó é profundidade num plano isométrico.
3. **O enrocamento aparecia como cascalho pintado no cais.** As pedras eram
   espalhadas degrau por degrau e nas quinas da escada caíam dentro do degrau
   seguinte, que é mais largo. Hoje a costa é um contorno explícito, com os
   espelhos dos degraus, e tudo o que a acompanha anda por ele.
4. **Os nomes flutuavam sobre o mapa** e as chips das docas tapavam a arte.
   Ver a seção anterior.
5. **O enrocamento cruzava a raiz de cada píer** e as pedras liam-se como se
   estivessem por cima do tabuado. Elas param onde o píer começa: ninguém
   joga pedra na frente da entrada de um píer.
6. **Faixas claras atravessavam o pátio até dar na água.** Não eram estrada —
   eram a margem de meia unidade que sobrava entre um degrau e o seguinte. O
   pátio passou a ocupar o degrau inteiro, e no lugar delas entrou uma malha
   viária desenhada de propósito.
7. **Os coqueiros nasciam no meio do asfalto e por cima do armazém.** Foram
   para o passeio e o cenário passou a ser desenhado por profundidade.
8. **A ferramenta de captura fotografava o porto errado sem avisar** — 30% das
   vezes `new_game()` abre oferta do rival, e com o jogo nesse estado toda
   compra é recusada, então a foto do porto "completo" saía do porto em
   ruínas. Resolve a oferta antes de comprar e grita se alguma falhar.

O primeiro playtest humano (25/08) encontrou dois bugs sérios, ambos corrigidos:

1. **Jogo travava** depois de aceitar a oferta do rival — o botão "Avançar dia"
   ficava desabilitado para sempre. Era ordem de emissão de sinais; hoje toda
   troca de fase passa por um ponto único que avisa a interface.
2. **O mesmo trabalhador podia ser alocado em várias docas** ao mesmo tempo,
   multiplicando receita de graça. Hoje é bloqueado, e tocar na doca libera o
   trabalhador (para desfazer arrasto errado).

Lição registrada: a verificação automatizada agora **instancia a cena real** e
checa o estado dos botões. A versão anterior só chamava a lógica direto, e por
isso não pegou nenhum dos dois.

Segunda lição, do dia 25/08: **um harness que joga perfeito não mede
dificuldade.** A taxa de vitória de ~63% que constava aqui vinha da suíte de
testes jogando sem errar uma vez sequer — o que descrevia o teto do jogo, não a
experiência de quem pega no controle pela primeira vez. Medir dificuldade exige
simular também o jogador que erra, e com amostra grande o bastante para a
margem de erro não engolir a conclusão. Daí o
`tools/simular_balanceamento.gd`.

---

## Como retomar numa conversa nova

Comece a conversa apontando este arquivo. Algo como:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md`. Quero trabalhar em X."

Para rodar os testes antes e depois de mexer no código:

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tests/run_tests.gd
```

Espera-se `TODOS OS TESTES PASSARAM` e código de saída 0. A suíte cobre, entre
outras coisas, o bug do save de outra versão (T5c), o teto de docas do mapa
(T5d) e o formato do dinheiro (T5e).

**Numa sessão remota não é preciso fazer nada disso**: o hook de arranque já
baixou o Godot e já rodou o `--import`, e diz numa linha que o fez. Se essa
linha não apareceu na primeira mensagem, o hook não correu — a receita manual
está no `CLAUDE.md`, e lê a versão de `.godot-version`.

**`--import` num clone novo não é opcional** — sem a pasta `.godot` a suíte
falha com uma pilha de `referenced non-existent resource` que não tem nada a
ver com o teste.

E para medir o efeito de qualquer mudança de balanceamento — **600 partidas por
perfil**, que é o número em que os 100% / 47% / 0% foram medidos e o que o
`CLAUDE.md` e o `/fechar-sessao` mandam usar. Este documento dizia 800, o que
dava três números a circular para a mesma coisa:

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tools/simular_balanceamento.gd -- 600
```
