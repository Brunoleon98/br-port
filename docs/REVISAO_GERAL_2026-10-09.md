# Revisão geral — 09/10/2026: o que se manteve, o que mudou e como pôr em prática

> **O que é.** A segunda revisão geral do repositório, depois da de 17/09
> (`REVISAO_GERAL_2026-09-17.md`). Começou como uma análise em conversa,
> pedida pelo Bruno — «o que pode ser melhorado e corrigido, mais eficiente,
> bonito e preparado para as próximas expansões, e com a coleta do que se
> aprende e se pesquisa». Depois foi revista item a item, contra o código e
> contra medição, e virou plano de execução.
>
> **Base:** `main` em `0d6705e` (PR #108), em 09/10. **Atualizada em 10/10**,
> depois de fundidos o #109 (guindastes de madeira, save 13, `086`) e o #110
> (obras dos reparos, save 14, `087`): a §7 revisa o #110, e a §6 passou a ser
> a fila de melhorias da mais crítica à mais tranquila, por escolha do Bruno.
>
> **O que não é.** Não reabre decisão registada, não mexe em `# TUNING:`,
> `SAVE_VERSION`, projeção ou arte aprovada. O que precisa do Bruno está
> marcado **[decisão]** e listado na §6.0 com a opção recomendada; o resto é
> **[execução]**.

---

## 1. Como se verificou

- As seis suítes do Godot 4.6.3 no contêiner, uma a uma, com a linha final e
  a varredura de `SCRIPT ERROR`: verdes, ~67 s ao todo (`teste_design` 30 s,
  `teste_fumaca` 17 s, `asset_validator` 11 s, `run_tests` 8 s).
- O CI dos últimos commits (verde; ~7,7 min o `Testes` na `main`) e os
  artefatos da corrida do #108: `brport-apk` 41,7 MB e `brport-web` 23,6 MB
  (zip).
- Os arquivos que o #109 mexe, para não o atropelar.
- A documentação oficial do Claude Code sobre memória
  (<https://code.claude.com/docs/en/memory>), lida na página.
- O GDD 7 nas seções de fases, mapa, save e acessibilidade (`docs/gdd/`).
- Três medições novas: o `teste_design` em três discos diferentes, uma sonda
  de custo por quadro com o `Main` aberto e um clone com `core.autocrlf=true`,
  que é o checkout do Windows.

**Limites:** o clone desta sessão é raso (história desde 20/09), então o
tamanho do `.git` local não mede o repositório inteiro, e o número certo é o
da API do GitHub (107 MB). Não há telefone nem placa de som aqui.

---

## 2. A primeira análise, revista item a item

| # | Sugestão de antes | Veredito | Por quê |
|---|---|---|---|
| 1 | O `teste_design` herda o save do disco | **Confirmado e corrigido** (§4) | Medido: 1114 asserções e 68 casas no D14 com o disco limpo ou em ruínas; 1148 e 102 com um porto completo no disco. Verde nos três |
| 2 | Tirar `upgrade_purchased` e `buy_upgrade()` | **Mantém, e mudou de ocasião** | O campo só existe «para a suíte antiga» e vai no save; `buy_upgrade()` só é chamada por testes e tenta o `pier_3`, bloqueado na Fase 1. O save 13 e o 14 passaram sem a limpeza; ela espera a próxima subida (M9, D1b) |
| 3 | PR #109 parado | **Resolvido** | Autorizado e fundido em 09/10, com o save 13 (`086`) |
| 4 | Arte órfã | **Mantém [decisão]** | 9 de 331 arquivos; a `046` já separou órfão de apagável |
| 5 | `CLAUDE.md` grande demais | **Reforçado** | A doc oficial pede **menos de 200 linhas** por `CLAUDE.md` e manda o que só vale para parte do código para regras com `paths:`. O nosso tem **3021 linhas** (219.790 bytes), 279 avisos ⚠️, e mudou em 61 dos 196 commits desde 01/09. E o #109 mostra o custo: reescreve no `CLAUDE.md` números que mudam a cada PR de economia (R$295.522 → R$312.709). Import com `@` **não** poupa nada: carrega no arranque |
| 6 | Planos com itens fechados | **Mantém, e a janela abriu** | Plano v3 com 173.987 bytes, plano de arte com 128.973. Com o #109 e o #110 fundidos não há PR aberto a mexer neles (M5) |
| 7 | Medir desempenho | **Revisto: prioridade cai** | Medido: o `_process` do `Main` mais os nove bichos e os 20 tweens custam **0,033 ms por quadro**. Script não é gargalo. O que falta é a GPU no telefone: ~411 chamadas de desenho por quadro, 263 nós e 64 MB de VRAM (`049`). Isso é medição do Bruno no aparelho, antes do A8 |
| 8 | Partir `teste_design` e `teste_fumaca` | **Rebaixado** | 30 s e 17 s, e o `conferir_guardas_ci.py` deriva os passos do workflow: partir mexe no contrato do CI em troca de conforto. Fica para quando doer |
| 9 | Tabela de dados por fase | **Mantém, e cresce** | Além das constantes de Fase 1 cravadas (`PARCELA_2_AMOUNT`, `JUROS_PARCELA_1..3`, `WEEKS_TOTAL`), o GDD gradua as fases por reputação de **0 a 3000+**, e o jogo usa **0–100** em cinco faixas. A tabela precisa decidir como a reputação atravessa a fase **[decisão]** |
| 10 | Partir `Main.gd` e `GameState.gd` | **Mantém, com uma pré-condição nova** | Testes e ferramentas leem **38 membros privados por string**, 29 deles do `Main` e 7 do `Dock` (`get("_camiao")`, `call("_visita_da_doca")`…). E `get()` de propriedade que não existe devolve `null` **calado**: mover código sem antes guardar esses nomes faz guardas passarem sem ver nada |
| 11 | `phase` como String livre | **Mantém, junto do legado** | 89 literais; o nome confunde-se com «Fase 1..5» da campanha (M9) |
| 12 | Três berços fixos contra a grade do GDD | **Mantém [decisão]** | GDD: grade 8×6 → 24×14 com encaixe; Fase 2 «oficina + 2 docas»; as imagens-alvo vão a 4–5 docas. Recomendação mantida: vagas curadas por fase, em dados |
| 13 | Save sem migração | **Reforçado [decisão]** | O GDD promete «Você nunca precisa se preocupar em perder o porto» e exportação `.brport-save`; a regra de hoje descarta todo save de outra versão. Serve no protótipo, não serve depois do A8 |
| 14 | Acessibilidade e tradução | **Mantém, futuro** | Zero `tr()` no projeto; as falas estão juntas no `Narrativa.gd`, o resto é literal nas cenas |
| 15 | Git LFS | **Retirado** | O repositório é público e o LFS gratuito tem cota de banda que o CI gastaria a cada checkout. São 107 MB no GitHub, e o maior blob tem 1,9 MB (os mapas SVG). Basta monitorar |
| 16–20 | Pendências visuais e de som | **Mantém** | Máquina do contêiner (`079`), guindastes sobrepostos e mar à direita (§7 do plano); barco a deslizar até ao berço (`083`); faixa dos retratos; música inexistente e escuta A6; leitura A4 (`067`, `082`) |
| 21 | Imagens-alvo fora do repositório | **Mantém, e não é a única** (§3, N8) | `docs/design/referencias/` ainda só tem o README |
| 22 | Índice das pesquisas | **Feito aqui** (§5) | — |
| 23 | Lições incham o `CLAUDE.md` | **Ver item 5** | A saída é a mesma |
| 24 | Pasta para playtests reais | **Mantém** | O gravador `.jsonl` existe (`006`); falta onde acumular as partidas do A7 |

---

## 3. O que a primeira análise não viu

**N1 — O repositório é público, e o GitHub Pages publica o protótipo
VELHO.** A cada push na `main` corre «pages build and deployment», que serve
o `index.html` da raiz: o protótipo HTML «BR Port — v3.0», não o jogo. O
export Web já é de fio único (`variant/thread_support=false` no
`export_presets.cfg`), então o `brport-web` cabe no Pages sem cabeçalho
especial nenhum, e um link jogável no navegador do telefone serve
diretamente ao A7 («ver duas pessoas jogarem»). **[decisão]**: publicar o
build atual torna-o jogável por qualquer pessoa. O repositório, aliás, já é
público. Tornar o repositório privado tem preço: hoje o CI fatura 0 minutos
(repositório público), e privado passaria a gastar a cota de Actions; o
Pages privado pede plano pago.

**N2 — Não havia `.gitattributes`, e o CRLF já mordeu duas vezes.** A
primeira foi em 12/09 (o teto do estado medido com um byte a mais por linha,
remediado no `conferir_docs.py`). A segunda está no #109: o literal
`\n\n—\n\n` do `Narrativa.gd` deixou de dividir o caderno, com cinco falhas de
design, e a lição que ele propõe é manual («conferir o blob e normalizar as
quebras locais»). **Corrigido na raiz** (§4).

**N3 — A numeração das decisões não tinha guarda.** O `AGENTS.md` regista que
dois agentes «já deram números repetidos», e a regra era só escrita.
**Corrigido** (§4).

**N4 — Os números do balanceamento vivem no `CLAUDE.md`.** O
arquivo que carrega em toda sessão é reescrito em todo PR de economia, e os
dois agentes disputam as mesmas linhas. Eles têm casa gerada: a tabela dos
números e os JSON de medição do arquivo. Vai com o M4 (§6).

**N5 — Os testes estão presos ao `Main` por string.** Ver o item 10 acima;
é a primeira coisa a fazer antes de qualquer refatoração.

**N6 — A escala da reputação diverge do GDD** (item 9).

**N7 — O GDD promete o save** (item 13).

**N8 — Há informação de que o jogo depende e que vive fora do
repositório:** as cinco imagens-alvo (só num anexo de conversa), o galpão
recuperado V3 (só no checkout do ChatGPT, `ESTADO_DO_PROJETO.md`) e a
**resposta** da pesquisa externa de 17/09. Desta só o prompt está aqui
(`REVISAO_GERAL_2026-09-17_PESQUISA_EXTERNA.md`); o que ela devolveu chegou ao
projeto já destilado na fila R1–R9 do plano, e o texto original não o
encontrei em lado nenhum.

**N9 — Medir custo por quadro aqui tem duas armadilhas**, e foram as duas
primeiras tentativas desta sessão:
- sob `xvfb-run`, o `Performance.TIME_PROCESS` inclui o desenho, que neste
  contêiner é por software, e deu 86 ms;
- em `--headless`, o laço dorme até 6,9 ms por quadro (o sono do modo de
  baixo consumo), com e sem o `Main` aberto, e devolve o mesmo número nos
  dois casos.

O que mede o script é cronometrar a chamada direta dos `_process`. Uma futura
`medir_desempenho.gd` leva isto no cabeçalho.

---

## 4. Feito nesta sessão, com prova

**4.1 O `teste_design` deriva o estado (fecha o achado da `081`).**
- O `_rodar()` faz `clear_save()`, fixa a semente e chama `new_game()` antes
  de montar o `_main`.
- O D14 monta ele próprio os dois estados em que os prédios do pátio existem
  (ruína e porto completo), confere a vila contra cada um e devolve o estado
  da partida no fim.
- Resultado: **os três discos dão as mesmas 1218 linhas**, com 68 casas
  conferidas na ruína e 102 no porto completo.
- **Conferido de novo em 10/10, depois de fundidos o #109 e o #110**, com
  saves da versão 14 que o jogo aceita (os de 09/10 eram da 12 e seriam
  recusados, o que testaria nada): 1223 linhas iguais nos três discos. O
  controle positivo também se repetiu: a versão da `main`, sem a correção,
  dá 1119 ou 1153 conforme o disco.
- Guarda nova, pela regra da `043`: «o porto completo põe mais prédio grande
  sobre a vila do que a ruína».
- Mutantes:
  - **Mutante B** (a montagem sem o refresh do cenário) reprova por ela, com «2
    prédios em ruína e 2 com o porto completo».
  - **Mutante A** (sem a derivação, com um porto completo no disco) mantém a
    contagem, mas o D6 passa a medir OUTRO HUD: o botão do Construir com 171
    px em vez de 233, e os cartões com 104 px de altura em vez de 84. É isso
    que a derivação segura hoje, e o comentário no código diz exatamente
    isso.

**4.2 `.gitattributes` com `* text=auto eol=lf`.**
- O índice já era todo LF (1270 arquivos de texto, nenhum CRLF), e o
  `git add --renormalize .` não muda nada.
- Num clone com `autocrlf=true`: sem o arquivo, o `Narrativa.gd` sai com CRLF
  (a condição da `086`); com ele, sai com LF e sem arquivo fantasma
  modificado.
- ⚠️ Uma cópia de trabalho Windows **já existente** só troca as quebras
  quando os arquivos voltam a sair do índice. Com tudo commitado ou guardado
  em `stash`: `git rm -r --cached -q . && git reset --hard`.

**4.3 O `conferir_docs.py` reprova número de decisão repetido.**
- O mutante (uma segunda `085-*.md`) dá código 1 com a mensagem certa, e a
  base volta a `DOCS OK`.
- O CI de PR corre sobre a junção com a `main`, logo a colisão aparece antes
  do merge.

---

## 5. Inventário das pesquisas, e onde cada uma vive

| Pesquisa | Data | Pergunta | Onde vive | Observação |
|---|---|---|---|---|
| Prototipar jogo de gestão mobile premium com IA | antes do VS | Como prototipar e com que motor | `docs/design/Prototyping_Premium_Mobile_Management_Games_with_AI.md` | 21 links |
| A resolução dos assets | 14/09 | Que alavanca compra nitidez e qual compra detalhe | §7 do plano v3 («O que a pesquisa devolveu») | Fechada nas `025`, `026`, `029` |
| Prompt de pesquisa profunda da revisão de 17/09 | 17/09 | Atacar os consertos propostos | `REVISAO_GERAL_2026-09-17_PESQUISA_EXTERNA.md` | **A resposta não está arquivada** (N8) |
| Boas práticas de Blender estilizado | 23/09 | O que o Blender por script alcança nos retratos | §7 do `BR_Port_Plano_Arte_Blender.md` | «Pesquisadas e MEDIDAS» |
| Interface de jogos de gestão | 25/09 | Como mostrar a consequência antes da escolha | `BR_Port_Referencias_Interface_Gestao.md`, `063` | Lida por resumo de busca, porque o proxy bloqueia as páginas (`063`) |
| Método de balanceamento da economia | 08/10 | Escala que comporte expansões, carros e imóveis | `BR_Port_Metodo_Balanceamento_Economia.md`, `085` | Tarifas de Paranaguá e BNDES como referência, não como preço |
| Leitura das cinco imagens-alvo | 03/09 | O arco de crescimento do porto | `docs/design/referencias/README.md` | **As imagens não estão no repositório** |
| Áudio: geração e escuta | — | Suno/ElevenLabs; o que se prova sem ouvir | `BR_Port_Guia_Audio_Suno_ElevenLabs.md`, `BR_Port_Plano_Audio.md`, `PROTOCOLO_DE_ESCUTA.md`, `040` | A escuta é do Bruno |
| Material do ChatGPT | 23/09 → | Produção de assets e auditorias | `art_lab/README.md` e `art_lab/plano/` | Entra com a base conferida |

**A regra que falta, proposta [decisão]:** pesquisa ou anexo que embasa uma
decisão entra no repositório na mesma sessão: a imagem, a resposta da
ferramenta externa, ou pelo menos a lista de fontes. Se não puder entrar, a
decisão diz que falta. Este índice fica aqui até o Bruno escolher a casa
definitiva dele; candidata natural é um documento de trabalho ao lado do
`BR_Port_Referencias_Interface_Gestao.md`, que o `conferir_docs.py` pode
cobrar como cobra o índice do arquivo.

---

## 6. A fila, da mais crítica à mais tranquila

> **Escolha do Bruno em 10/10:** as próximas conversas fazem esta fila por
> ordem, uma entrega por sessão, antes de voltar aos gráficos e ao jogo. A §7
> do plano aponta para aqui. O modelo segue a `016`: decidir e escrever guarda
> é Opus; executar o que já está decidido é Sonnet.

**O critério**, na ordem:
1. o que hoje já publica dado errado ou arma uma armadilha para o jogador;
2. o que deixa toda sessão seguinte mais cara ou menos confiável;
3. o que tem de existir antes da próxima fase ou do primeiro build público;
4. o que é conforto.

É o critério da §7.1 do plano (R1–R9) em mais um andar: primeiro impedir que
a automação publique evidência falsa ou induza a próxima sessão a errar.

### 6.0 As decisões do Bruno

| # | Pergunta | Recomendação | Destrava |
|---|---|---|---|
| D1 | Autorizar o save 13 do #109 | **Resolvida.** Fundido em 09/10, e o #110 subiu a 14 (`087`) | — |
| D1b | Uma subida de save para tirar o legado (M9)? | Só junto da próxima subida que outro recorte precise; nunca sozinha | M9 |
| D2 | Reorganizar o `CLAUDE.md` num núcleo curto e regras por tema em `.claude/rules/`? | Sim | M4 |
| D3 | Expansão do mapa: vagas curadas por fase ou grade livre do GDD? | Vagas curadas por fase, em dados | M7 |
| D4 | Reputação entre fases: a escala 0–3000 do GDD ou 0–100 por fase? | Decidir antes de desenhar a tabela de fases | M7 |
| D5 | Política de save a partir do primeiro build público | Migração encadeada v(n)→v(n+1), com um save de exemplo por versão | M10 |
| D6 | Publicar o build Web atual no Pages, no lugar do protótipo? | Sim, se aceitar o jogo atual jogável em público; senão, desligar o Pages | M11 |
| D7 | Destino da arte órfã e de `art/sprites/` | Seguir a triagem da `046` | — |
| D8 | A obra que só fica pronta no fecho do dia 84 (aceita pela `087`): avisar ou recusar? | Avisar no Construir e na mensagem que ela não será usada nesta fase | M3 |

**Só o Bruno pode fazer:**
- subir as imagens-alvo, o galpão V3 e, se a tiver, a resposta da pesquisa
  de 17/09;
- medir FPS e aquecimento no telefone;
- a escuta A6 e a leitura A4.

### 6.1 Já feito (09–10/10)

As três higienes da §4: o `teste_design` que deriva o estado, o
`.gitattributes` com LF e a guarda do número de decisão. **Prova:** as seis
suítes, o `conferir_docs.py` e os mutantes registados, conferidos de novo
depois de fundidos o #109 e o #110.

**M1, em 10/10 (`088`):** o gravador na versão 2 grava a obra pronta e o
calendário; o leitor publica dia pago → dia pronto e as semanas do cabeçalho,
com «não sei» onde o registro não diz. **Prova:** o R7 do `teste_registro` e o
autoteste do leitor, que corre antes de toda leitura; treze mutantes, todos a
reprovar.

**M2, em 10/10 (`089`):** a `abertura_do_reparo()` diz em que dia cada reparo
abre, e o botão e o save leem dela; a obra lida sai com inteiros. **Prova:** o
T17 do `run_tests`, relacional, andando o calendário; nove mutantes, cada um
num sítio só. ⚠️ O mutante previsto abaixo («hoje passaria») reprovava seis
asserções no código de antes: a ponta desguardada era o save, e um save com o
armazém no dia 9 passava as seis suítes. O primeiro item aberto passa a ser o
**M3**, que espera o D8.

### M1 — O gravador de partida conta a obra pronta e o calendário de hoje

**[feito em 10/10 — `088`]** ~~[execução · curta · critério 1]~~ A ferramenta
do A7 publicava dois dados errados (§7, O2 e O3).
- **O que muda:**
  - o `Registro.gd` passa a ouvir também o `obra_concluida` e grava
    `{"e": "obra_pronta", "id", "t"}`;
  - o cabeçalho passa a gravar `turnos_por_semana`, ao lado do
    `turnos_totais` que já grava;
  - o `tools/ler_registros.py` mostra, por estrutura, o dia pago e o dia
    pronto, e tira a primeira e a última semana do cabeçalho, no lugar de
    `t <= 8` e `t > 24`.
- **Registro antigo sem o campo:** o leitor diz que não sabe a semana, em vez
  de supor 7 ou 8. É a regra do `.get(chave, omissão)` no `CLAUDE.md`.
- **Prova:**
  - o `teste_registro` grava uma partida que conclui uma obra, e o mutante
    sem o ouvinte novo reprova;
  - o leitor, com uma fixture de 84 dias e 7 por semana, devolve a última
    semana certa, e o mutante com o 8 cravado reprova.
- **Modelo:** Sonnet; a guarda em Opus.

### M2 — A regra de abertura num lugar só

**[feito em 10/10 — `089`]** ~~[execução · curta · critério 2]~~ O `_save_aceite()` repete à mão o que o
`desbloqueio_da_estrutura()` calcula (§7, O1).
- **O que muda:** uma função só diz em que dia cada reparo abre (armazém em
  `TURNS_PER_WEEK + 1`; pátio em `PARCELA_DUE_TURN + 1`, com uma cobrança
  quitada), e as duas pontas leem dela. Na mesma passada, a obra lida do save
  sai com inteiros (O6).
- **Prova (relacional, não espelho):**
  - para cada reparo, achar andando o calendário o primeiro dia em que o
    `desbloqueio_da_estrutura()` abre;
  - exigir que um save com a obra começada na véspera seja recusado e um
    com a obra começada no próprio dia seja aceito;
  - mutante: mudar a regra num lugar só (o armazém na semana 3, só no
    desbloqueio) tem de reprovar. Hoje passaria.
- **Save:** não muda a forma do save, logo não sobe a versão.

### M3 — A obra que o jogador lê

**[D8 · curta · critério 1]**
- «`%d dias de obra`» (`UpgradePanel.gd`) e «`%d dias; pronto no dia %d`»
  (`comprar_estrutura()`) passam pelo `Narrativa.concordar` (`037`). Os
  prazos hoje são 2 e 3, e o texto sai certo; um prazo de 1 dia sairia
  «1 dias» sem guarda nenhuma, porque o F9 procura `(s)` e ternários, não
  `%d dias`.
- A obra pronta só no fecho do dia 84 segue a resposta do D8.
- **Prova:** o F9 passa a reprovar a forma «`%d` + plural fixo» em texto do
  jogador; o mutante com um prazo de 1 dia reprova.

### M4 — O `CLAUDE.md` enxuto

**[D2 · média · critério 2]**
- **Núcleo do `CLAUDE.md`** (meta: poucas centenas de linhas):
  - as quatro camadas;
  - como rodar e a proteção do save do jogador;
  - «o CI não corre ao empurrar»;
  - o fecho;
  - o que cabe numa sessão e as fases F1–F7;
  - o estilo de código essencial.
- **Regras por tema**, carregadas só quando a sessão toca os arquivos:

| Regra | `paths:` (resumo) |
|---|---|
| `.claude/rules/projecao` | `tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py`, `blender/**`, `docs/BRP_SPATIAL_CONTRACT.md` |
| `.claude/rules/arte` | `blender/**`, `art_lab/**`, `brport_vs/art/**`, `tools/gerar_props_iso.py` |
| `.claude/rules/testes-e-guardas` | `brport_vs/tests/**`, `brport_vs/scripts/validation/**`, `tools/conferir_*.py` |
| `.claude/rules/economia` | `brport_vs/autoload/GameState.gd`, `brport_vs/tools/simular_balanceamento.gd`, `tools/projetar_parcelas.py` |
| `.claude/rules/save` | `brport_vs/autoload/GameState.gd`, `brport_vs/scripts/ArmazemLocal.gd` |
| `.claude/rules/interface` | `brport_vs/scenes/**`, `brport_vs/ui/**`, `brport_vs/scripts/Painel*.gd` |
| `.claude/rules/narrativa` | `brport_vs/scripts/Narrativa.gd`, `brport_vs/scripts/Retratos.gd` |
| `.claude/rules/audio` | `brport_vs/autoload/Audio.gd`, `tools/gerar_sons.py`, `tools/medir_audio.py` |
| `.claude/rules/captura` | `brport_vs/tools/capturar_*.gd`, `tools/capturar_evidencia.sh`, `brport_vs/tools/folha_*.gd` |

  (Os nomes levam `.md` no disco.)
- **Codex:** ele não carrega `.claude/rules`, então o `AGENTS.md` passa a
  listar as regras por tema e diz quais ler conforme os arquivos da tarefa.
- **Números voláteis:** saem do `CLAUDE.md` e ficam só na tabela gerada e nos
  JSON de medição; o `conferir_docs.py` passa a procurar a «fonte
  operacional» lá. O #109 e o #110 reescreveram essas linhas a cada PR.
- **Prova:**
  - nada se apaga: a contagem de avisos ⚠️ e de títulos de regra é a mesma
    antes e depois, somando todos os arquivos (279 hoje);
  - `DOCS OK`;
  - uma sessão de teste a abrir um arquivo de cada tema confirma que a regra
    carrega.
- **Atenção:** uma regra com `paths:` só entra quando a sessão LÊ um arquivo
  que casa. Uma pergunta sem arquivo aberto não a vê, e é para isso que as
  skills `/arte` e `/balancear` continuam a existir.
- **Modelo:** Opus no desenho, Sonnet no transporte.

### M5 — Os planos enxutos

**[execução · média · critério 2]**
- **O que muda:** os itens ✅ do plano v3 (173.987 bytes) e do plano de arte
  (128.973) descem para o `docs/arquivo/`, e cada plano fica com o que está
  aberto.
- **Janela:** não há PR aberto mexendo neles hoje.
- **Prova:**
  - `DOCS OK`;
  - nada se apaga: o arquivo ganha, título a título, o que o plano perde.

### M6 — A guarda dos nomes lidos por string

**[execução · curta · critério 2]**
- **O que muda:** todo nome que testes e ferramentas leem do `Main` e do
  `Dock` por string (38 hoje) tem de existir no alvo. A lista sai do texto
  das suítes, como o F9 lê as chamadas.
- **Prova:** o mutante que renomeia um membro privado reprova.
- **Para que serve:** é a pré-condição do M8, e protege também qualquer
  recorte da frente 5 que mexa no `Main`.

### M7 — Preparar a Fase 2 sem mudar a Fase 1

**[D3, D4 · média · critério 3]**
- **O que muda:** uma tabela `FASES` em dados (duração, cobranças com capital
  e juros, desbloqueios, prazos de obra, classes de navio, nível máximo e
  vagas do mapa). O `GameState` passa a lê-la no lugar das constantes da
  Fase 1, e o M2 já deixa a abertura num lugar só.
- **Prova de refatoração pura:**
  - a tabela dos números regerada sem diferença nos valores;
  - o JSON do simulador (600 por perfil, semente 20260825) idêntico ao de
    antes;
  - as seis suítes;
  - o `teste_fumaca` exigindo que toda fase da tabela tenha os campos todos.
- **Modelo:** Opus.

### M8 — Partir o `Main.gd`

**[execução · longa, três PRs · critério 3]**
- **O que muda:** extrações, uma por PR: o tráfego dos camiões (o maior
  bloco), a narradora da Dona Cida e a fila de painéis (`_na_vez`, que a `087`
  acabou de alargar).
- **Prova:** a bateria de capturas byte a byte contra a anterior (ela é
  determinística, `031`), as seis suítes, o simulador idêntico e o M6 de pé.
- **Modelo:** Sonnet, com as guardas em Opus.

### M9 — O legado do save

**[D1b · curta · critério 4]**
- **O que muda:** saem `upgrade_purchased` e `buy_upgrade()` (que ainda tenta
  o `pier_3`, bloqueado na Fase 1); os estados de turno (`"playing"`,
  `"rival_offer"`, `"debt_payment"`, `"game_over"`) viram constantes.
- **Quando:** só junto da próxima subida de save que outro recorte precise.
  Recomeçar a partida do jogador por limpeza não paga.
- **Prova:** as seis suítes, o simulador idêntico e a recusa da versão
  anterior no `teste_fumaca`.

### M10 — O save que não se perde

**[D5 · média · critério 3 · antes de qualquer build pública]**
- **O que muda:** migrações encadeadas, um save de exemplo por versão no
  `teste_fumaca` e a recusa só para o que a migração não souber ler.
- **Continua:** «tudo o que recusa vem antes de tudo o que escreve».
- **Modelo:** Opus.

### M11 — Playtest e desempenho no aparelho

**[D6 · curta · critério 3]**
- Se D6 for sim, o CI publica o `brport-web` da `main` no Pages.
- O Bruno mede FPS no telefone com o build atual.
- Uma `medir_desempenho.gd` conta chamadas de desenho, nós e o custo dos
  `_process`, com o cabeçalho de N9.
- As partidas reais do A7 ganham uma pasta, anónimas pela `006`.

### M12 — Acessibilidade e tradução

**[critério 4 · depois do A8]**
- O tamanho de fonte pelo tema (há um só, `ui/tema_brport.tres`) é barato.
- O `tr()` entra gradual, começando pelo `Narrativa.gd`, que já junta as
  falas.

### Depois da fila — gráficos e jogo

Voltam, por escolha do Bruno:
- o próximo recorte da frente 5
  (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`: crédito opcional,
  cancelamento, guindastes e obras das fases futuras, tutorial, mais
  trabalhadores por píer);
- as pendências visuais da §2 (16–20).

---

## 7. A revisão do PR #110 (`087`, obras dos reparos)

Fundido em 10/10 (`c56e538`), com o CI verde. A junção desta branch com ele
passou nas seis suítes neste contêiner. O que ele faz bem fica dito primeiro,
porque é o que não se deve desfazer:
- a obra é validada no `_save_aceite()` antes de qualquer campo ser aplicado;
- o T15 percorre pagamento único, dias, retomada, fecho de semana e
  vencimento, e compara o arquivo inteiro antes e depois da recusa;
- o T16 prende a ordem resposta → boletim → oferta;
- o simulador mede início e conclusão separados.

Os achados, do mais grave ao mais leve. Nenhum quebra o jogo hoje.

| # | Achado | Gravidade | Vai para |
|---|---|---|---|
| O1 | **[feito — `089`]** O `_save_aceite()` escrevia à mão os dias em que cada reparo abre — `8 if armazem else 29 if patio else 1` e, à parte, «pátio exige uma cobrança quitada» —, enquanto o `desbloqueio_da_estrutura()` os calcula pela semana (`current_week() < 2`) e pelo vencimento (`PARCELA_DUE_TURN`). Hoje coincidem. Mudar o `TURNS_PER_WEEK` ou o prazo da cobrança faria o jogo recusar saves válidos, ou aceitar uma obra começada num dia em que não podia, sem erro nenhum. É a «regra que existe em dois sítios» do `CLAUDE.md` | média, latente | M2 |
| O2 | O `Registro.gd` só ouve o `estrutura_comprada`, que desde a `087` dispara no PAGAMENTO. O `tools/ler_registros.py` publica esse dia como «O porto que se levanta» e conta como construída a obra que ainda não acabou. O sinal da conclusão (`obra_concluida`) não tem ouvinte no gravador. É a «sonda presa a um ponto de passagem» do `CLAUDE.md` | média, dado errado hoje | M1 |
| O3 | Anterior ao #110, da `085`: o leitor ainda tira a «semana 1» de `t <= 8` e a «semana 4» de `t > 24`, que eram semanas de 8 dias numa fase de 4. Com 12 semanas de 7 dias, a «semana 4» publicada cobre da 4 à 12 | baixa-média, dado errado hoje | M1 |
| O4 | «`%d dias de obra`» e «`%d dias; pronto no dia %d`» não passam pelo `Narrativa.concordar` (`037`). Com 2 e 3 dias o texto sai certo, e com um prazo de 1 dia sairia «1 dias» sem guarda | baixa, latente | M3 |
| O5 | A obra começada no dia 83 fica pronta no fecho do 84, e é aceita: está na `087` e no T15 («pode terminar no fechamento do dia 84»). A mensagem diz «pronto no dia 85» numa fase de 84 dias, e o jogador paga por algo que esta fase não deixa usar | pergunta ao Bruno | D8, M3 |
| O6 | **[feito — `089`]** O `load_game()` guardava a obra com os números do JSON (`float`). Funciona porque toda leitura passa por `int()`; normalizar na leitura evita que um uso futuro tropece num `8.0` onde se esperava `8` (como chave de dicionário, por exemplo) | baixa | M2 |

---

## 8. Números desta revisão, para não se medirem outra vez

| O quê | Valor |
|---|---|
| `CLAUDE.md` | 3021 linhas e 219.790 bytes em 09/10; 3068 e 222.829 em 10/10, depois do #109 e do #110; 279 ⚠️; mudou em 61 de 196 commits desde 01/09 |
| `teste_design` | 1114 ou 1148 asserções conforme o disco (09/10); 1218 em qualquer disco com a correção; depois do #110, 1119/1153 sem ela e 1223 com ela |
| Custo de script por quadro com o `Main` aberto | 0,033 ms (`_process` do `Main` e dos nove bichos); 20 tweens |
| Desenho | ~411 chamadas por quadro sob `xvfb`/opengl3; 263 nós |
| Pacotes (zip dos artefatos do #108) | APK 41,7 MB; Web 23,6 MB |
| Repositório no GitHub | 107 MB; maior blob 1,9 MB (mapas SVG) |
| Membros privados lidos por string em testes e ferramentas | 38 (29 do `Main`, 7 do `Dock`, 2 de painéis) |
