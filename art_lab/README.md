# `art_lab/` — o laboratório de arte partilhado

**O material daqui veio do ChatGPT** (o plano de produção, os conceitos e as
candidatas, até 23/09), **e quem trabalha a partir dele são o Claude Code e o
Codex**: o Claude Code é por onde o Bruno conduz o projeto, e o Codex contribui
com tarefas que o Bruno lhe entrega (`AGENTS.md`, na raiz). O Bruno escolhe e
aprova. Esta pasta é o sítio onde as frentes se encontram — o plano, os
conceitos e as candidatas vivem aqui, versionados, em vez de viverem em
conversas. O ChatGPT deixou de ser uma frente ativa; o que ele produziu fica.

**Nada desta pasta é o jogo.** O jogo é `brport_vs/`, e o que está fora dele não
entra no pacote exportado. Uma candidata passa daqui para lá pelo caminho da
§3, e só com o Bruno a escolher.

---

## 1. O que há aqui

| Pasta | O que é | De quem |
|---|---|---|
| `plano/` | O plano de produção de assets F1–F5 (**V3**), a ficha F1 da vegetação e da costa, o prompt V16, o relatório de auditoria V3 e o relatório de 23/09 com as lições | ChatGPT |
| `plano/decisoes_da_frente/` | As decisões `034`–`036` do checkout do ChatGPT (Lote 0, casa costeira, galpão F1) — ver a §5 | ChatGPT |
| `conceitos/` | Conceitos aprovados como DIREÇÃO: a prancha de vegetação (13), a de mangue, água e pedras (V8) e as referências do arbusto 13A | ChatGPT, gerador de imagem |
| `f01/13a/v4`, `v5` | O arbusto baixo como função do gerador do mapa: remendos, fonte, pranchas, QA | ChatGPT |
| `f01/vegetacao_grupo/v1`–`v3` | O grupo inteiro do conceito (duas árvores e arbustos) como SVG/PNG solto | ChatGPT |
| `pacotes/2026-09-23/` | O manifesto SHA-256 do pacote, o estado do checkout dele e o trabalho por commitar que lá havia | ChatGPT |
| `retratos/cida_seria/v1/`, `v2/`, `quadrada_v1/`–`v3/` | A Dona Cida séria (frente 2): a REDONDA v1, rejeitada, e a v2 que a refaz; a QUADRADA v1, no kit de caixas, que o Bruno escolheu contra a v2; e as quadradas v2 e v3, com os ajustes que ele pediu (a v3 em Standard) — o script do Blender, o PNG, a prancha e a foto do jogo de cada uma | Claude Code, 23–24/09 |
| `retratos/cida_contente/v1/` | A Dona Cida CONTENTE com um sorriso mais claro: três candidatas no estúdio (fechado, fechado com os olhos a sorrir, de lado), fotografadas no boletim ótimo; o Bruno escolheu a B | Claude Code, 24/09 |
| `retratos/ribeiro/v1/`–`v4/` | O Sr. Ribeiro no kit afinado, retangular e alto: quatro voltas até à v4, que o Bruno aceitou na foto do jogo — o script de cada volta e as pranchas | Claude Code, 24/09 |
| `retratos/arlindo/v1/`–`v6/` | O Capitão Arlindo no kit afinado, de ângulos: seis voltas até à v6, que o Bruno aceitou na foto do jogo — o script de cada volta e as pranchas | Claude Code, 24/09 |

O pacote de 23/09 trazia 111 arquivos; **103 estão aqui, byte a byte** (confira
com `manifest_sha256.json`). Ficaram de fora oito, de propósito:

| Arquivo do pacote | Por que ficou de fora |
|---|---|
| `art_lab/f01/13a/v{4,5}/porto_mapa_iso{,_patio}_v{4,5}.svg` (4, ~8 MB) | Fotografias do mapa de 18/09. Mapa não se entrega inteiro: regera-se do gerador (receita na §4) |
| `art_lab/f01/13a/v{4,5}/gerar_mapa_iso_13a_v{4,5}.py` (2) | Cópias inteiras do gerador; saem da `main` + os remendos |
| `referencias/BR_PORT_QA_ASSETS_V3.zip` | Os 14 arquivos dele estão em `f01/13a/v4/qa_v3/`, iguais por hash |
| `experimentos_descartados/imagegen_halo_nao_usar.png` | Descartado pelo próprio ChatGPT (alfa 253 longe do sujeito) |

---

## 2. Quem faz o quê

É a divisão que o próprio plano V3 propõe (§4), com o que o repositório
acrescenta. A primeira coluna é um PAPEL e não um agente: foi do ChatGPT até
23/09, e hoje é de quem o Bruno puser na tarefa — o Codex ou o próprio Claude
Code, numa sessão de arte.

| Quem produz a peça | Quem a integra no jogo | Bruno |
|---|---|---|
| Lê a referência, escolhe o componente, escreve o brief e a ficha | Confere a base, aplica numa cópia, regera mapas e props | Escolhe a frente e a ordem |
| Produz conceitos (gerador de imagem) e candidatas (SVG, script, prancha) | Corre as seis suítes e a bateria de fotos do **Godot**, com semente e passo fixos | Aprova olhando a foto **do jogo**, e não a prancha |
| Entrega cada revisão numa pasta própria (§3) com README, fonte, hashes e prancha | Escreve a guarda que prova que a peça chega à tela, com defeito injetado | Decide o que se reabre |
| Revê o plano de produção quando a peça o pedir (V3 → V4) | Mantém `CLAUDE.md`, o estado, o plano do projeto e as decisões | — |

---

## 3. O caminho de uma peça, daqui até ao jogo

1. **A base.** Toda revisão declara o commit da `main` de onde partiu, e ele
   tem de existir no GitHub. ⚠️ O pacote de 23/09 partiu do PR #58 (18/09) num
   checkout que o GitHub não conhece; a `main` estava no #76.
2. **A pasta.** `art_lab/f01/<asset>/<vN>/`, com `README.md` (peça, estado,
   limitações), a fonte reproduzível, as saídas, a prancha e os hashes. Nunca
   um mapa inteiro nem uma cópia do gerador: um **remendo pequeno** contra a
   `main`.
3. **A entrega.** Por PR ou pelo GitHub web para uma branch — ou, se o Bruno
   trouxer um zip, o Claude Code põe-no aqui com o manifesto.
4. **A prova no jogo.** O Claude Code aplica numa cópia, regera, importa e
   fotografa o JOGO (`tools/capturar_evidencia.sh`); se a peça for nova, entra
   uma guarda no teste de design que a procure pela cor ou forma que só ela tem.
5. **O aceite.** O Bruno olha a foto de runtime. Só então a peça passa para
   `brport_vs/`, com a decisão escrita em `docs/decisoes/` — **a próxima livre
   é a `056`** (a `055` é a da Dona Cida quadrada, a primeira peça a fazer
   este caminho inteiro).

---

## 4. As regras do repositório que decidem arte

Estão no `CLAUDE.md` (secções «Projeção isométrica» e «Arte»), que manda sobre
qualquer plano. As que mais pesam aqui:

- **Prop do MAPA nunca sai de gerador de imagem** — nem preparado. O gerador não
  erra o desenho, erra o ÂNGULO. O conceito entra como referência e a peça é
  modelada no kit (`tools/gerar_props_iso.py`, `blender/gerar_brp.py`).
  **Retrato de painel pode.**
- **Vegetação e vila nascem no gerador do mapa** (`tools/gerar_mapa_iso.py`),
  porque passam por trás das casas e o CI compara os mapas byte a byte. É também
  o que a `035` do próprio ChatGPT escolheu para a casa costeira.
- **A escala manda na gramática.** Na foto de runtime a copa de uma árvore do
  mapa tem pouco mais de 20 px (a olho, não medido); um arbusto de 20 px tem
  lugar para UMA silhueta. Volume pequeno faz-se com
  `com_saia()` (copa facetada com saia), a receita que o mapa já usa.
- **Arte que chega de fora passa por `tools/conferir_lote_de_arte.py`** (alfa
  verdadeiro, ângulo da base contra 26,57°, tamanho). Em vegetação o ângulo não
  se mede — não há apoio plano.
- **Retrato mede-se no tamanho do widget** e enche o quadro (§6, frente 2).
- **O estado ANTES não partilha peças do DEPOIS**, e estado sem mecânica não
  vira arte — regra que o plano V3 também tem.
- **Custo:** o delta do `.pck` é o delta do APK (`029`); a VRAM mede-se com
  `brport_vs/tools/medir_vram.gd`.

Para provar uma candidata de mapa no jogo, numa cópia:

```sh
mkdir -p /tmp/copia && git archive HEAD | tar -x -C /tmp/copia && cd /tmp/copia
git init -q && git add -A && git commit -qm base
git apply art_lab/pacotes/2026-09-23/repo_wip_preexistente.patch   # o 13A V3 dele
git apply art_lab/f01/13a/v5/13a_v5_proposta.patch                  # por cima
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  --sem-pavimento brport_vs/art/porto_mapa_iso.svg
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  brport_vs/art/porto_mapa_iso_patio.svg
$G --headless --path brport_vs --import          # duas vezes, pelo atlas
$G --headless --path brport_vs --script res://tests/teste_design.gd
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --fixed-fps 60 --script res://tools/capturar_tela.gd -- 1 foto.png limpo
```

Em 23/09 isto deu: os dois remendos aplicam, `DESIGN OK` (nenhuma guarda
pergunta pelos arbustos), 801 px mudados na foto.

---

## 5. Onde o plano V3 e o repositório divergem — o que vale hoje

Para quem rever o plano absorver na V4. O resto do V3 foi conferido e bate: o contrato
espacial da §3 (2:1, `MEIA_LARG` 30/15, `ZOOM` 2/3, quadro 512 de coordenada e
768 de pixel, janela 720×660), a recusa de contorno, a máquina de estados
visual, o RNG por identidade e canal e os gates com o Bruno a fechar.

1. **A paleta do mundo** da §2 (`#2B7FBF`, `#3A9E52`, `#E8C97A`…) não está no
   jogo. O mapa tem a paleta dele, medida, no dicionário `C` do gerador; o navy
   do HUD é `#1C3454` (tema), não `#1A3A5C`.
2. **«Mangues norte/sul têm consumidores observados»** (§5.3, §9.1): na `main`
   não há mangue em cena; a faixa que o gerador tinha saiu por cair fora do
   quadro (docstring de `vegetacao_do_solo`).
3. **«Imagens geradas são referências ATÉ passarem por preparação»** (§2.7): no
   mapa, nunca. Em painel, sim.
4. **As decisões `034`–`036` do checkout dele colidem em NÚMERO** com as
   `034`–`036` daqui, que tratam de outra coisa. As dele vivem em
   `plano/decisoes_da_frente/` e ganham número a partir da `056` quando o
   trabalho que descrevem entrar.
5. **O trabalho que essas decisões descrevem não está no GitHub**: o galpão F1
   V3 (aprovado pelo Bruno), a casa focal no gerador, o
   `BRP_PRODUCTION_MANIFEST.json` e o `tools/conferir_manifesto_producao.py` só
   existem no checkout dele (`art/f01-galpao`, HEAD `cc36166`). Publicar essa
   branch é o primeiro passo para não se perderem.
6. **As provas contam existência como PASS** — hashes registados, `bbox is not
   None`, o SVG existe. A que vale é a das âncoras sob forma mutada, e essa
   está certa. A máscara protege lotes, vias, acessos e píeres; não protege a
   altura projetada dos prédios, as árvores nem as rotas.
7. **O Godot existe** do lado da integração, com a bateria de fotos. A prancha
   Inkscape serve para iterar; o aceite é na foto de runtime.

---

## 6. Onde este material ajuda as frentes do A5

As seis frentes estão no §A5 do plano do projeto (`docs/design/BR_Port_Plano_v3_Claude_Code.md`, «Os
vereditos de 23/09»); a ordem é do Bruno.

| Frente | O que este material já traz, ou o que a frente pode produzir | O que fica do lado do repositório |
|---|---|---|
| **2 — retratos de fala** (Dona Cida, Sr. Ribeiro, Arlindo) | ⚠️ **Em 23/09 o Bruno pôs a frente no BLENDER**: um protótipo vetorial (SVG por script) foi rejeitado — «não deveriam ter sido criados». A pesquisa de boas práticas está no §7 do plano de arte, e ele escolheu ver UM retrato novo: a v1 redonda (`retratos/cida_seria/v1/`) foi rejeitada com quatro defeitos, e entre a redonda v2 e a quadrada melhorada ele escolheu a QUADRADA (24/09); aceitou a `quadrada_v3/` na foto do jogo, e ela está no jogo (`055`). A regra permitiria gerador de imagem aqui; a escolha dele é outra. Hoje são nove PNG 768×768 do Blender (três expressões por personagem, `Retratos.gd`), mostrados numa caixa de **112×152** em `COVERED`, com o busto a ocupar 62% × 90% do quadro — é a esse tamanho que a expressão tem de ler | Alfa verdadeiro, busto que enche o quadro, as mesmas três expressões por personagem, e a decisão de ABANDONAR o estúdio partilhado: o comentário de `Retratos.gd` diz que o gerador não foi usado para os três combinarem com o trabalhador do rodapé — trocar só três retratos faria o trabalhador destoar |
| **3 — interface** | Conceitos de painel (diário, celular, mensagens, pausa) como referência | O plano V3 (§2.13) já diz que redesenho de HUD é tarefa própria; a implementação é no tema, com as guardas de contraste (D33) |
| **4 — mapa, frota, animação** | O catálogo F1 (§9.1), a máquina de estados visual (§10.2), o rig do trabalhador (§10.5), os estados por tipo (§11), os lotes 2–5 (§16); a linha da vegetação (13A, grupo) e a costa V8 | Props do mapa modelados no kit a partir do conceito; vegetação no gerador |
| **5 — rumo além do VS** | A `034` dele já responde a parte: guindaste e píer evoluem no mesmo sítio, oficina N1 na F2, três berços, pescadores como sistema à parte. E a regra «obra só com consumidor» casa com o pedido do Bruno de obras que levam turnos: a arte de obra nasce DEPOIS dessa decisão | Mexe no `GameState`, no balanceamento e no `SAVE_VERSION`: decisão escrita antes de código |
| **6 — folha de contato** | O formato das pranchas dele (conceito com a região marcada, 1:1, 3×, três posições incluindo um caso de oclusão — §14 D) é o modelo que o Bruno pediu «para a IA iterar» | A folha é `brport_vs/tools/folha_props.gd`, e mede-se no Godot |

---

## 7. Estado das candidatas

| Candidata | Linha | Estado | O que falta para avançar |
|---|---|---|---|
| Conceito 13 (vegetação) | referência | direção aprovada (conceito) | — |
| Conceito V8 (mangue, água, pedras) | referência | direção aprovada; adiada pelo próprio plano até a vegetação estabilizar | Mangue não tem consumidor na `main` |
| 13A V3 | gerador do mapa | substituída pela V4/V5; está em `pacotes/2026-09-23/repo_wip_preexistente.patch` | — |
| 13A V4 | gerador do mapa | o Bruno leu «aglomerado» | — |
| 13A V5 | gerador do mapa | tecnicamente estável; sem aceite | Forma a variar DE VERDADE por instância (hoje ±0,25 px numa folha); a gramática do mapa (`com_saia()`) em vez de folhas de 2 px; e sair de trás dos prédios — na foto de runtime, dois dos cinco ficam meio tapados pela casa de telhado laranja e pela obra da vila |
| Grupo F1 V1 | sprite solto | a preferida do Bruno entre V1 e V2 (antes disse que destoava do mapa) | Virar uma função do gerador que componha as peças do mapa, guardando o que a V1 tem: duas copas altas sobre massa baixa e escura, tronco à vista |
| Grupo F1 V2 | sprite solto | o Bruno preferiu a V1 | — |
| Grupo F1 V3 | sprite solto | **sem opinião do Bruno** | Mesma silhueta da V1 com os verdes mexidos; as copas saem maiores do que as árvores vizinhas |
| Dona Cida séria v1 (cabeça redonda) | estúdio Blender (`retratos/cida_seria/v1/`) | **rejeitada** pelo Bruno: nariz e boca (bigode), tronco (balão), gola (discos), cabelo (capacete) e lápis (a flutuar) — «melhore o modelo como um todo» | Refeita na v2 |
| Dona Cida séria v2 (cabeça redonda) | estúdio Blender (`retratos/cida_seria/v2/`) | **não escolhida**: o Bruno escolheu a quadrada | — |
| Dona Cida séria quadrada v1 (kit de caixas) | estúdio Blender (`retratos/cida_seria/quadrada_v1/`) | **escolhida como modelo**, com ajustes pedidos: cabelo, óculos, tronco e rosto | Feitos na quadrada v2 |
| Dona Cida séria quadrada v2 (kit de caixas) | estúdio Blender (`retratos/cida_seria/quadrada_v2/`) | **mais ajustes pedidos**: cabelo, cores, rosto e corpo; Standard nos retratos | Feitos na quadrada v3 |
| Dona Cida séria quadrada v3 (kit de caixas, Standard) | estúdio Blender (`retratos/cida_seria/quadrada_v3/`) → `blender/brp_retratos.py` | ✅ **aceita na foto do jogo e no jogo** (`055`), nas três expressões | O Sr. Ribeiro, o Arlindo e o trabalhador no mesmo kit |
| Galpão F1 V3, casa focal, manifesto de produção | fora deste repositório | aprovados/decididos no checkout do ChatGPT | Só existem lá. Sem a branch `art/f01-galpao` publicada, o que resta deles é o texto das decisões em `plano/decisoes_da_frente/`, e o galpão V3 teria de ser refeito |

⚠️ **A vegetação não aparece em nenhum dos 31 vereditos do Bruno** — ela vem do
Lote 1 do plano V3. Em que lugar entra contra as seis frentes é escolha dele.

A leitura completa de 23/09, com as medições, está em
`docs/arquivo/AUDITORIA_ARTE_CHATGPT_2026-09-23.md`.
