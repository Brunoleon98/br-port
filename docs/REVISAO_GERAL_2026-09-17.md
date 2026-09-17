# Revisão geral do repositório — 17/09/2026

> **O que é.** Uma varredura de todas as frentes — lógica, arte, som,
> interface, narrativa, testes, ferramentas, CI, documentação, skills e
> organização — feita a pedido do Bruno, **sem consertar nada**. Cada achado
> traz a evidência (arquivo e linha, número medido, ou captura olhada), quem
> devia tê-lo apanhado e por que não apanhou, o tamanho honesto do conserto e
> de quem é a decisão. É documento de trabalho como o `BRP_SPATIAL_CONTRACT.md`:
> quando os achados estiverem triados, desce para `docs/arquivo/`.
>
> **Duas listas, de propósito.** A §2 são DEFEITOS — coisas erradas hoje — e vem
> ordenada, com o critério escrito. A §3 são MELHORIAS — coisas certas que
> podiam ser melhores — e **não vem ordenada**: a ordem dessa é do Bruno.
>
> **O que passou verde está na §4**, para não voltar como suspeita. **O que o
> briefing afirmou e o repositório desmentiu está na §5.**

---

## 1. Como se procurou

Tudo o que já existe correu antes de se inventar régua nova:

| Corrida | Resultado |
|---|---|
| `run_tests`, `teste_design`, `teste_audio`, `teste_fumaca`, `teste_registro`, `asset_validator` | as seis linhas de sucesso; **0** `SCRIPT ERROR` em todas |
| `tools/conferir_docs.py` | `DOCS OK` — 152 documentos, estado a **25.893 / 26.000** bytes |
| `tools/arte_orfa.py` | 11 de 109 sem referência (os mesmos de 16/09) |
| `tools/medir_silhueta_props.py --tabela` | 61 props, 2 min 13 s; coerente com a `024` (§4) |
| `simular_balanceamento.gd -- 600 20260825` | **100,0% / 80,2% / 37,3%**, medianas e margens iguais ao `CLAUDE.md`; 26 s |
| `projetar_parcelas.py` | calibrado nos três perfis |
| `gerar_sons.py`, `gerar_mapa_iso.py` (os QUATRO mapas), `gerar_tabela_numeros.py --conferir`, `gerar_gdd_md.py` | `git diff` vazio nos quatro, em Python 3.11 |
| `tools/capturar_evidencia.sh` | 16 imagens, todas olhadas uma a uma (§2 e §3 dizem o que se viu) |

**Réguas novas, e como se calibraram** (regra 7 do `CLAUDE.md`):

- **Contraste amostrado das capturas** (fundo = cor mais frequente da janela;
  texto = a mais distante em luminância entre as que aparecem ≥20 vezes).
  Calibrada contra dois números já publicados: deu **5,04:1** no rodapé do
  menu-celular, onde o D23 publica 5,05:1, e **2,93:1** para o neutro sobre
  branco, que é o número do `CLAUDE.md`. Só depois disso os números da §2.4
  valem.
- **Medidor dos WAV** (duração, pico, RMS, amostra inicial e final, DC,
  amostras saturadas) — biblioteca padrão. Não tem ruído próprio: lê o arquivo.
- **Prova de fala VISTA** — um `--script` descartável que instancia `Main.tscn`,
  compra uma estrutura e lê a faixa de mensagem (§2.2). Foi apagado depois de
  correr; a saída está transcrita.
- **Varredura de condições constantes** nos dois geradores (AST: todo `if`
  cujos nomes sejam só constantes de módulo, avaliado). Achou **um** caso,
  e é falso positivo (`_QUINAS is None`, um cache, `gerar_mapa_iso.py:627`).
  A condição que o Bruno diz ter achado no gerador **não é deste tipo** —
  fica por localizar, e a régua regista o que não vê: condição que depende de
  argumento.

---

## 2. DEFEITOS — o que está errado hoje

**Critério da ordem: quem é enganado, e quantas vezes.** Primeiro o que o
jogador lê errado em toda partida; depois o que uma ferramenta imprime errado
e alguém vai ler como medida em toda corrida do CI; depois o que a
documentação e as skills afirmam errado e a próxima sessão herda; por fim a
higiene que ainda não enganou ninguém.

### 2.1 A "Leitura" do simulador lê o Antecipado como "jogar mal" — em toda corrida do CI

- **O que está errado.** O bloco `=== Leitura ===` imprime *"Jogar mal ganha
  80% — o ERRO NÃO CUSTA. É este o sintoma de 'fácil demais'"* e *"Vão entre
  jogar bem e jogar mal: 20 pontos"*. O Descuidado ganha **37,3%** e o vão é
  **63**.
- **Evidência.** `brport_vs/tools/simular_balanceamento.gd:778` —
  `var descuidado: Dictionary = resultados[resultados.size() - 1]`. Desde
  12/09 (`41b0d5a`, item 24) o último perfil é o **Antecipado** (80,2%),
  acrescentado depois do Descuidado (`:101` e `:120`). Saída desta sessão com
  600 partidas: as duas linhas acima, com a tabela certa dez linhas antes.
- **Quem devia ter pego, e por que não.** O `testes.yml` e o
  `balanceamento.yml` só procuram `=== Leitura ===` e `possível travamento`;
  o resumo do `balanceamento.yml` publica este texto na página da corrida
  todas as segundas. Nenhuma asserção lê a Leitura, e a `/balancear` §6 manda
  "ler o resultado" sem dizer de que linha. É a F3 — a fase que o `CLAUDE.md`
  diz ser a mais fácil de perder — a ler do perfil errado, por posição.
- **Tamanho.** Uma linha (procurar o perfil pelo NOME). A guarda: a Leitura
  cita o nome do perfil de que fala, e uma asserção exige que ele seja
  "Descuidado". **Execução**; a asserção e o defeito injetado sobem (F6).

### 2.2 "Zezão terminou. Demorou o dobro do previsto" — disparada, nunca vista, e falsa neste mundo

- **O que está errado.** A fala `upgrade_pronto` está ligada a
  `estrutura_comprada` (`Main.gd:1022`), que o `GameState` emite em `:1427` —
  **uma linha antes** do `message.emit("%s — pronto...")` em `:1428`. Os dois
  escrevem no mesmo `Label` (`_on_message`, `Main.gd:1253`), e o segundo tapa
  o primeiro na mesma chamada.
- **Evidência, medida.** `--script` descartável: instanciar `Main.tscn`,
  `comprar_estrutura("pier_2")`, ler a faixa. Antes: *"O porto é seu…"*.
  Logo a seguir e no frame seguinte: *"Reconstruir o Píer 2 — pronto. +1 doca
  e +1 trabalhador"*. A Dona Cida não aparece.
- **A mesma família, três vezes mais.** `caixa_baixo` está ligada a
  `cash_changed`, e em três dos quatro sítios onde o caixa muda vem um
  `message.emit` logo a seguir: `:1094→1095` (fecho da semana), `:1323→1324`
  (parcela paga), `:1425→1428` (compra). O comentário de `Main.gd:1265` afirma
  o contrário — *"quem chama isto chama-o depois do evento"* — e é verdade só
  para os gatilhos que o `Main` chama à mão.
- **E a frase é falsa no mundo.** A obra é instantânea: `comprar_estrutura()`
  emite "pronto" na mesma chamada. Nada "demorou o dobro do previsto". É a
  frase verdadeira em português e falsa neste mundo (`CLAUDE.md`, Narrativa).
- **Quem devia ter pego.** O F4 pergunta *"toda fala DISPARA?"*, e dispara.
  Ninguém pergunta *"toda fala é VISTA?"* — a terceira cara do `barco_medio`,
  depois de "gerado e nunca em cena" e "escrita e nunca disparada".
- **Tamanho.** Código pequeno (ordem dos emits, ou a Cida a escrever DEPOIS
  da mensagem do sistema). A frase nova é **decisão do Bruno** — escrita. A
  guarda "fala vista" é F6.

### 2.3 "Semana nova. Barcos na fila, caixa no limite" — em toda semana, com qualquer caixa

- **Evidência.** `Narrativa.gd:142`; o gatilho `_cida_semana`
  (`Main.gd:1347-1356`) dispara em toda semana ≥ 2 sem olhar o caixa.
  `porto.png` (semente fixa, dia 9): a frase, com **R$981.779** no HUD.
- **Quem devia ter pego.** A varredura de 12/09 corrigiu o tom do boletim
  (*"A semana anterior foi melhor"*) e *"Dois contratos recusados"* — os dois
  da mesma família — e não varreu os irmãos, que é a lição "AO CORRIGIR UM,
  VARRA OS IRMÃOS" com a Narrativa no lugar do prop. Nenhuma suíte pergunta
  verdade; só a leitura em voz alta (A4), que fica por fazer desde 13/09.
- **Tamanho.** Uma condição (caixa abaixo de X) é execução; qual frase dizer
  quando o caixa está folgado é **do Bruno**.

### 2.4 O neutro de 2,93:1 sobre cartão branco — pela quarta vez, e agora pelo tema

- **O que está errado.** `RotuloSecao/colors/font_color = (0,51, 0,6, 0,706)`
  em `ui/tema_brport.tres:504` — a cor que o `CLAUDE.md` diz ter "mordido
  TRÊS vezes" sobre branco. `RotuloSecao` é usado em cartões brancos em
  `DebtPaymentPanel.gd:67` (*"Caixa: R$400.000"*), `CounterOfferPanel.gd:87`
  (*"Valor original"*), `PainelNarrativo.gd:179` (`secao()`: *RECEITAS* /
  *DESPESAS* do boletim) e `TelaNomes.gd:69,78`.
- **Medido nas capturas.** `ribeiro.png` 2,93:1 · `contraoferta.png` 2,93:1 ·
  `boletim.png` (RECEITAS) 2,93:1. O corte de texto GRANDE é 3,0; estes têm
  13–14 px.
- **Mais um, do mesmo cartão branco.** *"toque para quitar agora"* sai em
  `COR_AVISO` (âmbar #d97706) a **13 px** (`Main.gd:1128`, `Main.tscn:701`):
  **3,19:1** em `porto.png`. AA para 13 px é 4,5.
- **Quem devia ter pego.** O D19 só percorre `UpgradePanel.tscn`
  (`teste_design.gd:1967`); o D23, o menu-celular. Os painéis narrativos não
  têm guarda de contraste — e é neles que o `RotuloSecao` vive.
- **O outro lado.** `CLAUDE.md:1512` chama o `RotuloSecao` de *"o rótulo que
  guia e sai da frente"*: pode ser intenção. Mas o mesmo arquivo diz *"sobre
  branco use 0,35/0,42/0,50, que mede 5,46:1"*, e o `UpgradePanel.gd:21` e o
  `PainelCalendario.gd:30` já usam essa. **Decisão do Bruno** (aceitar
  "sai da frente" abaixo da WCAG, ou trocar a variação); o D19 a percorrer
  todos os painéis é execução.
- **E há uma regra a mais quebrada aqui.** *"O tema é o ponto único de estilo.
  Script não pinta cor na mão"* (`CLAUDE.md`, Interface): há **22**
  `add_theme_color_override` em cinco scripts (Main 8, DocaCartao 6,
  UpgradePanel 4, PainelCalendario 2, PainelReputacao 1) e dez `const COR_*`
  fora do tema. Foi assim que o âmbar de 3,19:1 escapou: não há variação de
  tema para o D19 medir.

### 2.5 O painel da parcela conta os dias de um jeito e o desconto de outro

- **Evidência.** `parcela.png` (turno 8): *"Vence no dia 32 — 25 dia(s)
  daqui"* e *"Antecipar abate R$31.800"*. Os 25 saem de
  `PARCELA_DUE_TURN - turn + 1` (`PainelParcela.gd:39`); os R$31.800 são
  530.000 × 0,25% × **24**, de `PARCELA_DUE_TURN - turn`
  (`GameState.gd:1276`). O mesmo painel diz 25 e cobra 24.
- **E a conta dos 25 vive em dois sítios**: `Main.gd:1115` (HUD) e
  `PainelParcela.gd:39` — a regra duplicada que o `CLAUDE.md` manda apagar.
- **Quem devia ter pego.** O T5k prova o desconto, não o texto; o D22 mede a
  altura. Nada compara os dois números do mesmo painel.
- **Tamanho.** Pequeno. Qual dos dois é o certo (o dia de hoje conta?) é
  **decisão** — de um lado o HUD já diz "32 restantes" no dia 1.

### 2.6 Três ferramentas IMPRIMEM números do balanceamento que já não são

- `simular_balanceamento.gd:359` — o aviso de amostra curta cita
  *"CLAUDE.md (100% / 79,5% / 31,0%)"*; o `CLAUDE.md` diz 100 / 80,2 / 37,3.
- `.github/workflows/balanceamento.yml:23,144` — *"O alvo registrado é 100% /
  79,5% / 35,7%"*, publicado no resumo de cada corrida semanal.
- `tests/teste_registro.gd:15` — *"(100% / 79,5% / 31,0%)"*.
- `tools/gerar_tabela_numeros.py:286` → `docs/design/BR_Port_Numeros_Fase_1.md:25`
  — *"as 30 partidas que o CI roda têm margem de ±18 pontos"*: o CI roda
  **600** desde 05/09 (`750f590`). A frase é GERADA para um documento que o CI
  compara, e envelheceu dentro do gerador.
- **Quem devia ter pego.** O grep do rasto (`/balancear` §5:237) procura só os
  números NOVOS (`80,2|37,3`) e não inclui `*.yml`. A `/fechar-sessao` §5
  manda *"grep pelo número velho E pelo novo"*, e a lista da irmã não o faz.
- **Tamanho.** Execução, meia hora. A régua que falta: o grep procura o
  PADRÃO (`\d+,\d% */ *\d+,\d%`) e reprova o que não bata com a medição.

### 2.7 As três skills, o hook e quatro documentos descrevem um CI e uma bateria que já não existem

Tudo verificado contra o `testes.yml`, o `capturar_evidencia.sh` e o `git log`:

| Onde | Diz | É |
|---|---|---|
| `fechar-sessao` §2 "os cinco do Godot"; `balancear` §4 "as cinco suítes"; `arte` §6 "os cinco"; hook (linha final); `CLAUDE.md` "Antes de fechar" e `COMO_RODAR.md` | cinco | **seis** — `teste_registro.gd` está no CI desde 02/09 (`416a2bd`) e **não é citado** em nenhum dos seis (grep = 0) |
| `fechar-sessao` §3; `balancear` (cabeçalho, §1, §4) | "as 30 partidas do CI" | 600 desde 05/09 |
| `fechar-sessao` §3; `arte` §4 | regerar "os dois mapas" | o CI regera **quatro** (espuma 0/1 desde 03/09, `3eff02b`) |
| `arte` §5 | "SEIS DAS OITO são partida sorteada"; o laço `cmp` percorre 7 nomes | 16 fotos, 5 de partida; 9 sem antes/depois no laço |
| `arte` §0 (tabela); plano v3 §A5 item 3 | "Etapa 3 — Contorno pelo compositor: sim" | ❌ **feita e rejeitada** em 05/09 (`Plano_Arte_Blender.md:994`; `CLAUDE.md`: "as DUAS técnicas foram testadas e rejeitadas") |
| plano v3 §A6 | "os dez rascunhos" | 14 |
| `COMO_RODAR.md:169` | "Para as cinco de uma vez" | 16 |
| `CLAUDE.md:1891` | "os 20 ícones" | 23 (`folha_icones.gd:30` regista o salto) |
| `ESTADO_DO_PROJETO.md:183` | "`Main.tscn` tem o mapa, os letreiros e a barra" | os letreiros saíram em 04/09 (`acd491e`); `grep Letreiro Main.tscn` = 0 |
| `ESTADO_DO_PROJETO.md:187` | `art/sprites/` "sprites prontos" | só `scenes/proto/*.tscn` os referenciam, e proto está fora do export (`export_presets.cfg:31`) — ver 2.9 |

- **Quem devia ter pego.** `conferir_docs.py` confere existência e referência,
  não afirmações. A lição *"contagem em prosa de lista que cresce tira-se"*
  está escrita na `/fechar-sessao` §5 — e não foi aplicada às skills.
- **Tamanho.** Execução (Sonnet), uma sessão curta; o item da Etapa 3 é só
  apagar da tabela. **Decisão** só onde o número informa: se o hook deve
  listar as seis ou dizer "as suítes de `tests/`".

### 2.8 `capturar_tela.gd -- N` conta a oferta do rival como turno, e a foto do boletim é um estado que o jogador nunca vê

- **Evidência.** `capturar_tela.gd:224-227`: `if phase == "rival_offer": …
  continue` gasta uma iteração sem avançar. `-- 10` fotografou o **turno 9**
  (log desta sessão: `Overlay: 0 painel(eis) [fase playing, turno 9, …]`;
  `porto.png`: "Dia 9/32"). `-- 12` deu "Dia 11/32" com o Boletim a dizer
  **"Semana 1 de 4"** por cima (`boletim.png`): o boletim abriu no turno 8 e a
  ferramenta avançou três turnos por baixo do modal. O jogador nunca vê isto.
- Os comentários do `capturar_evidencia.sh` ("dez turnos", "doze turnos calham
  num fim de semana") descrevem outro N.
- **E os logs morrem sem ninguém os ler**: `rm -f "$SAIDA"/*.log` no fim, sem
  um grep por `SCRIPT ERROR` — a guarda que o `testes.yml` tem em seis passos
  não existe na captura. Hoje: **0** erros nos 16 logs (medido antes de os
  apagar). Amanhã, uma captura de painel meio montado passa por boa, que é
  exatamente o caso de 12/09.
- **Tamanho.** Pequeno, execução.

### 2.9 `arte_orfa.py` conta `scenes/proto/` como consumidor — os órfãos são 16, não 11

- **Evidência.** `tools/arte_orfa.py:43` — `FORA = (scenes/tests, tools,
  tests)`. `art/sprites/` (5 PNG) é referido só por `scenes/proto/MapaIso.tscn`
  e `MapaConceito.tscn`, que nada no jogo carrega e o export exclui. Logo
  passam por "usados" cinco sprites que nunca chegam ao telefone — e as duas
  cenas proto só existem para o teste de fumaça as instanciar.
- **Tamanho.** Uma linha na ferramenta; o destino dos arquivos é **do Bruno**,
  como os outros 11.

### 2.10 Um slider de "Música" que controla um bus vazio

- **Evidência.** `PauseMenu.gd:61`; `audio/default_bus_layout.tres` diz por
  escrito *"`Musica` já existe sem nada roteado nele"*. `pausa.png`: o slider,
  a 100%. O jogador mexe e nada acontece.
- **Tamanho.** Esconder até ao A6 é uma linha; **decisão do Bruno**.

### 2.11 A guarda `SCRIPT ERROR` do CI não cobre quatro `--script`

- **Evidência.** `testes.yml`: os passos "Gravar partidas", "despejar
  constantes" e "simulador" não a têm; `captura.yml` também não (e 2.8 diz
  que os logs nem sobrevivem). São `--script` como os outros, e a lição de
  07/09 vale igual: saem com 0.
- **Tamanho.** Quatro blocos de cinco linhas; execução.

### 2.12 Higiene — ainda não enganou ninguém

- `.get("boats_served", 0)` / `.get("pier_income", 0)` em `Registro.gd:251,286`,
  `EndGame.gd:80`, `GameState.gd:1093`, num dicionário cujas chaves são TODAS
  escritas em `new_game()` (`GameState.gd:568`). É o padrão que o `CLAUDE.md`
  proíbe — e `Registro.gd:314` comenta a lição do `.get("preco", 0)` sessenta
  linhas abaixo de a repetir.
- `pyflakes`: `x0, x1` sem uso (`gerar_mapa_iso.py:2166`), `DECK_FRENTE`
  (`gerar_props_iso.py:2560` — o 2,08 está duplicado na caixa ao lado como
  1,84 + 0,48/2) e `ESC_R` (`:2828`).
- Um recurso vazado no fim de `run_tests`, `teste_audio`, `teste_fumaca` e do
  simulador: `sfx_ui_warn.wav` (`AudioStreamWAV` + playback) — o `Audio` não
  para as vozes ao sair. Só barulho no log.
- `teste_fumaca.gd:728` — `_confere("… está versionado", true)`: asserção que
  não pode reprovar (o ramo falso já retornou antes).
- Blocos D1–D8 e T1–T5f sem a bandeira "correu até ao fim" (só D9+ e T5g+ a
  têm). No CI o grep de `SCRIPT ERROR` cobre; numa corrida local, não.
- `Audio.gd:150` sorteia o pitch do clique com o `randf_range` global, fora do
  `_rng`. Não afeta foto nenhuma; é sorteio fora do sítio.

---

## 3. MELHORIAS — está certo, e podia ser melhor (ordem é do Bruno)

### Narrativa

- **Toninho e Zezão são prometidos e nunca aparecem.** O diário nomeia os dois
  (`Narrativa.gd:74`), a fala de obra diz "Zezão terminou" (`:143`), e o
  comentário `:31` diz que o Toninho trata o jogador por "chefia" — não há
  fala do Toninho, e os trabalhadores chamam-se **#1, #2, #3** (`inicio.png`).
  Dar-lhes os nomes ou tirar os nomes do diário; decisão de escrita.
- **Plural de muleta na interface**: "dia(s) restante(s)" (`Main.gd:1116`),
  "dia(s) daqui" (`PainelParcela.gd:44`), "tentativa(s)"
  (`CounterOfferPanel.gd:190`), e "toque p/ liberar" abreviado (`docas.png`).
  O projeto já tem `por_extenso()`; falta um `plural()` num sítio só.
- **O primeiro boletim é sempre "neutro"** (`tom_do_boletim`: sem histórico →
  neutro): *"Nada extraordinário"* para **+R$581.779** sobre R$400.000 de
  partida (`boletim.png`). Verdadeiro por construção, surdo ao número.

### Som — o que dá para provar aqui, e o que só o Bruno pode julgar

Medido nos 14 WAV versionados (32 kHz, mono):

| arquivo | ms | pico | RMS dB | bordas | DC | saturadas |
|---|---:|---:|---:|:---:|---:|---:|
| sfx_ui_click | 90 | 0,55 | −17,3 | 0 / 0 | ~0 | 0 |
| sfx_ui_success | 400 | 0,82 | −12,0 | 0 / 0 | ~0 | 0 |
| sfx_ui_warn | 310 | 0,72 | −12,9 | 0 / 0 | ~0 | 0 |
| sfx_ui_error | 340 | 0,70 | −15,0 | 0 / 0 | ~0 | 0 |
| sfx_moeda | 244 | 0,62 | −15,0 | 0 / 0 | ~0 | 0 |
| sfx_alerta | 370 | 0,72 | −12,9 | 0 / 0 | ~0 | 0 |
| sfx_navio_chega | 1100 | 0,68 | −15,0 | 0 / 0 | ~0 | 0 |
| sfx_construir | 300 | 0,78 | −12,3 | 0 / 0 | 0,0008 | 0 |
| sfx_vitoria | 685 | 0,82 | −12,1 | 0 / 0 | ~0 | 0 |
| sfx_derrota | 894 | 0,74 | −13,1 | 0 / 0 | ~0 | 0 |
| sfx_amb_mar | 3600 | 0,42 | −20,6 | 0 / 0 | 0,0009 | 0 |
| sfx_fauna_gaivota | 520 | 0,46 | −19,0 | 0 / 0 | ~0 | 0 |
| sfx_fauna_areia | 270 | 0,34 | −23,3 | 0 / 0 | ~0 | 0 |
| sfx_fauna_mergulho | 580 | 0,42 | −22,1 | 0 / 0 | ~0 | 0 |

- **O que se prova sem placa de som:** nenhum estalo de borda (todas começam e
  acabam em 0), nenhuma saturação, DC desprezível, o clique tem os 90 ms que a
  docstring promete, e os 14 batem com o gerador, com a tabela do `Audio.gd` e
  com o disco (14 = 14 = 14). A hierarquia de nível é nítida — interface a
  −12/−13 dB, ambiente a −19/−23 dB.
- **O que só ele julga:** timbre (se "moeda" soa a dinheiro), e se **8 dB** de
  diferença entre o clique de interface e o mar é hierarquia ou é interface
  aos gritos. Este é o A6, e continua onde estava.
- **Cobertura do `teste_audio`:** chama diretamente 5 dos 14 ids (click,
  aviso, moeda, alerta, vitoria); os outros 9 provam-se só pela tabela e por
  um `grep` dos gatilhos (todos existem). "Pedir não é tocar" está trancado só
  para os quatro do mesmo frame.

### Testes e guardas que faltam (as três que a §2 pede)

- **D19 a percorrer TODOS os painéis** com cartão branco, e o menu-celular
  (2.4). Defeito injetado: trocar uma variação para `RotuloSecao` num rótulo
  de 13 px.
- **"Toda fala é VISTA"** (2.2): instanciar `Main`, disparar cada gatilho da
  `CIDA_LINHAS` pelo caminho do jogo, ler a faixa depois do frame. Defeito
  injetado: já está no repositório — `upgrade_pronto`.
- **"A Leitura cita o perfil pelo nome"** (2.1). Defeito injetado: trocar a
  ordem dos perfis.

### Ferramentas e CI

- `capturar_evidencia.sh`: guardar os logs (ou grep antes de apagar) e
  imprimir o turno real de cada foto na página da corrida (2.8).
- O `balanceamento.yml` publica um resumo que hoje leva a 2.1 dentro; o
  `captura.yml` só compara em PR — e não há PR aberto, que é o "depois" do
  APK e do web que o briefing já sabe estar por ler.
- O `ESTADO_DO_PROJETO.md` estava a **107 bytes** do teto; a linha que aponta
  para este documento gastou 103 deles, e ficou a **4** (25.996 medidos pelo
  `conferir_docs.py`). A próxima sessão que
  o tocar bate no teto; comprimir antes de precisar (o §6 da `/fechar-sessao`
  diz como).
- A régua de silhueta leva 2 min 13 s nos 61 props; se entrar no CI um dia,
  entra como relatório e não como portão (24 e 028 já dizem que o índice não
  responde em peça pequena ou esbelta).

### Arte

- **Silhueta hoje, contra a `024`:** `galpao` 0,567 (era 0,563), `pier_vazio`
  0,961, `doca_concreto` 1,042 (órfão). O casco mais quadrado que sobrou é o
  `barco_grande_conteiner` a **0,539** — abaixo do galpão, como a decisão
  quer. `pier_n2/n3` e `lanca_n2/n3` só têm 53–63% do contorno medível
  (cabos): a régua diz "não sei" em metade da peça.
- **Um bote em cima da calçada?** Na folha (`props1.png`) o `bote` pousa sobre
  `#b3bcc2`, que é a calçada (`#aeb8bf` + antisserrilhado). Na cena
  (`Main.tscn:340`, `offset 93, 7`) ele cai à beira do cais junto ao píer 1
  (`inicio.png`, ~350×320). Barco puxado para o cais é plausível; barco no
  passeio, não. É de olhar, não de medir.
- **Os 11 órfãos (+5 de 2.9)** continuam à espera de decisão: `art/brp/`
  inteira, dois SVG de píer, `doca_concreto`, `art/sprites/`.
- **Capturas olhadas, sem achado novo de arte:** `inicio`, `meio`, `porto`,
  `docas`, `pesca` (os três níveis, os camiões nos berços, a frota de pesca),
  `frota` (9 cascos, 8 camiões), `icones` (23 × 4 fundos; `doca` continua a
  ser traço creme que só vive em fundo escuro, e é assim de propósito —
  `Icones.gd:21`), `props1/2` (51, dois a dois chãos). O vão sob o queixo do
  Arlindo está onde a nota o deixou (`contraoferta.png`).

### Organização do repositório

- 569 arquivos versionados; `.git` 31 MB; `art/` 14 MB, dos quais os nove
  retratos a ~400 KB cada (a moldura vazia da `029`, já contada).
- `docs/img/` (4 PNG, 1,5 MB) só é referido por um documento do arquivo.
- `docs/design/` guarda dois documentos "superados" e um `.xlsx` binário —
  por decisão (`ESTADO`), não por esquecimento.
- `docs/design/referencias/` só tem o `README.md`: as imagens de referência
  continuam fora do repositório, como a `/arte` §2 avisa.

---

## 4. O que se mediu e ficou VERDE — para não voltar como suspeita

- As seis suítes e o validador (44 assets), sem `SCRIPT ERROR`.
- `DOCS OK`; toda referência resolve; o arquivo está indexado.
- Sons, os quatro mapas, a tabela dos números (46 constantes) e as 80 páginas
  do GDD regeram **byte a byte iguais** aqui (Python 3.11).
- 600 partidas: **100,0 / 80,2 / 37,3**, medianas R$1.309.646 / 716.179 /
  503.039, margens em regime R$674.019 / 502.571 / 103.290 — ao dígito com o
  `CLAUDE.md` e a `018`. O projetor calibra.
- O emoji da contra-oferta **não é emoji**: é o ícone `cliente_calmo`
  (`icones.png`). A regra "nada de emoji" está cumprida.
- `arte_orfa`: 11 (o mesmo de 16/09).
- Nenhum comentário novo do tipo "lido de X" que não leia X — os dois que
  existem são a própria lição.
- Nenhuma fala escrita que não dispare (F4 verde) — o que existe é 2.2, que é
  outra pergunta.
- Nenhum `randf` fora de `_rng`/`_sorteio` nos scripts de jogo, fora o pitch
  do clique (2.12).

---

## 5. O briefing conferido contra o repositório

| O briefing dizia | O repositório diz |
|---|---|
| "achei uma condição que nunca é verdade no gerador" | A régua de constantes de módulo não a encontra (um falso positivo, cache). Ela não é deste tipo, ou depende de argumento — fica por localizar, e o Bruno sabe onde está |
| "14 efeitos de rascunho" | 14, e conferem nos três lados (gerador, tabela, disco) |
| "as três skills" | são três, e as três envelheceram (2.7) |
| "alavanca B fechou em 16/09" | confere; o `PropIso` e o D31 estão lá, o validador vê os 44 |
| "não há PR aberto" | confere: o `captura.yml` não tem antes/depois desde o merge |
| "o vão sob o queixo do Arlindo, anotado" | está lá (`contraoferta.png`) |
| "ESTADO a 25.893" | 25.893 medido pelo próprio `conferir_docs.py` |
| "que arte é gerada e nunca chega à tela?" | 11 + 5 (2.9); a pergunta inversa está verde |
| "que fala está escrita e nunca dispara?" | nenhuma — mas uma dispara e nunca é vista (2.2), e duas são falsas no mundo (2.2, 2.3) |
| "onde um `.get(chave, 0)` vira número plausível?" | quatro sítios (2.12), nenhum a mentir hoje |
| "o CI mede o que importa?" | mede — e imprime uma leitura errada em cada corrida (2.1), com quatro `--script` fora da guarda (2.11) |

---

## 6. O que eu faria primeiro

1. **2.1** — uma linha, e uma asserção com o defeito injetado: é o número que
   o CI publica errado toda semana, e o mais fácil de alguém ler como medida.
2. **2.2 + 2.3** — a família das falas: primeiro a ordem dos emits (execução),
   e a leitura das oito linhas da Cida em voz alta, que é o A4 e é do Bruno.
3. **2.7** — as skills, porque são o que a próxima sessão lê ANTES de ler o
   código, e hoje mandam regerar dois mapas de quatro e rodar cinco suítes de
   seis.
4. **2.4** — decidir o `RotuloSecao` (é uma decisão de uma linha) e pôr o D19
   a percorrer todos os painéis, para não haver quinta vez.
5. **2.6 + 2.8 + 2.11** — o rasto de números e as guardas do CI, numa sessão
   de Sonnet só.
