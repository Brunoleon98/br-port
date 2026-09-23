# Auditoria do pacote de arte do ChatGPT — 23/09

O Bruno trouxe `BR_PORT_AUDITORIA_ARTE_2026-09-23.zip` (sha256 `d3a97d40622d49ce…`)
e o relatório que o acompanha. O pacote tem duas linhas de vegetação da F1 — o
arbusto **13A** (V4/V5, remendos ao `gerar_mapa_iso.py`) e o **grupo F1**
(V1/V2/V3, sprites SVG/PNG soltos) —, o plano de produção V3 dele e três
decisões do checkout local. **Nada entrou em `brport_vs/`.** Tudo o que se
mediu correu numa cópia fora do repositório.

## 1. Proveniência — o pacote foi feito sobre um jogo que já não é este

- **A base é o merge do PR #58** (`398b8b3`, 18/09). A `main` desta auditoria é o
  #76: 71 commits depois, três deles no `gerar_mapa_iso.py` (rua a 1,8, mão
  dupla, chanfro do cotovelo — `047`, `052`, `053`).
- **O HEAD do checkout dele (`cc36166`, branch `art/f01-galpao`) não existe no
  GitHub.** Nem o commit nem a branch foram empurrados.
- ⚠️ **As decisões `034`–`036` do pacote colidem em NÚMERO com as `034`–`036`
  deste repositório**, que tratam de outra coisa (fila de mensagens, contraste,
  cor da UI). Se entrarem, entram a partir da **`055`**.
- ⚠️ **Há trabalho APROVADO que só existe nesse checkout**: o galpão F1 V3 (a
  `036` dele diz «aprovado» nos dois estados), a casa focal no gerador (`035`),
  o `BRP_PRODUCTION_MANIFEST.json` e o `tools/conferir_manifesto_producao.py`
  (`034`). Nenhum está na `main`. Se o ambiente do ChatGPT se perder, perde-se
  com ele.
- O «MAPA ATUAL» das pranchas é o mapa DELE — já traz o arbusto 13A V3 do
  trabalho por commitar —, rasterizado pelo Inkscape. O Godot importa o SVG pelo
  ThorVG a `svg/scale` 1,5 (`025`); prancha estática não é a imagem do jogo.

## 2. O que se mediu aqui

| Pergunta | Resultado |
|---|---|
| O manifesto do pacote confere? | **Sim**: 111 arquivos por tamanho e SHA-256 |
| Alfa verdadeiro (`conferir_lote_de_arte.py`)? | **Sim nos seis PNG**, nenhum xadrez pintado |
| Ângulo da base contra 26,57°? | **Não se aplica**: vegetação não tem apoio plano (4 «sem apoio», 2 fora). Não é veredito |
| O trabalho por commitar aplica na `main`? | **Sim**, limpo (`git apply --check`) — mas mapa não se aplica por remendo: regera-se |
| A V5 aplica na `main`? | **Só por cima do trabalho por commitar**; sozinha reprova |
| Com trabalho por commitar + V5, os mapas regeram? | **Sim**: +265 linhas em cada mapa, tabela de âncoras intacta |
| O teste de design passa com eles? | **`DESIGN OK`** — e isso não prova nada sobre os arbustos: nenhuma guarda pergunta por eles |
| Em runtime (Godot, semente e passo fixos), o que muda? | **801 px** (551 acima de 8/255), todos no canto superior esquerdo da vila |
| Onde caem os cinco? | **Dois ficam meio tapados por prédios** (a casa de telhado laranja e a obra da vila). A ordem de profundidade está certa; a máscara dele não pergunta por prédios |
| As cinco instâncias variam? | **Não**: a forma só varia um sorteio de ±0,25 px na ponta de uma folha. São cinco cópias |
| Que tamanho têm na tela? | **~20×12 px**, com folhas de ~2 px de largura |

As fotos estão na conversa de 23/09 (recorte 3× e 6× da `main` contra a V5).

## 3. A tabela por asset

| Asset | Destino | Conceito ou arquivo | Substitui | Medição | Veredito | Porquê |
|---|---|---|---|---|---|---|
| Conceito 13 (prancha de vegetação) | referência | conceito, gerador de imagem | — | — | **só referência** | Prop no mapa nunca sai de gerador de imagem (`CLAUDE.md`, Arte) |
| Conceito mangue/água/pedras V8 | referência | conceito | — | não medido | **só referência** | O próprio pacote adia; mangue não tem consumidor na `main` (§4, item 2) |
| 13A V3 (o trabalho por commitar) | vegetação do mapa, via gerador | código | nada (acrescenta) | aplica limpo | **fora** | Substituído pela V5, e o sorteio partilhado movia âncoras (falha dele, bem apanhada) |
| 13A V4 | idem | código + PNG 256² | nada | alfa ok | **fora** | O Bruno leu «aglomerado» |
| 13A V5 | idem | código (remendo) | nada | ver §2 | **refazer** | Sementes por identidade e canal estão CERTAS (é a lição do `andar_costa`); a forma não: rosetas de folha fina numa gramática que o mapa não usa, a 20 px, com cinco cópias iguais e dois lugares tapados por prédios |
| Grupo F1 V1 | vegetação do mapa | SVG/PNG 600×380, **sem consumidor** | nada | alfa ok, sem apoio plano | **só referência para o gerador** | É um segundo estúdio ao lado do gerador; a própria `035` dele escolheu o gerador pela ordem de profundidade |
| Grupo F1 V2 | idem | idem | nada | alfa ok, 7,75° | **fora** | Achatou os arbustos em pastilhas iguais em fila — perdeu a hierarquia (duas copas altas sobre massa baixa escura) |
| Grupo F1 V3 | idem | idem | nada | alfa ok, sem apoio plano | **só referência** | Mesma silhueta da V1 com os verdes mexidos e as pontas laterais cortadas: não é ganho substancial. As copas saem maiores do que as árvores vizinhas e o tronco claro e grosso é outra linguagem |
| `imagegen_halo_nao_usar.png` | — | descartado | — | alfa 253 longe do sujeito (dele) | **fora** | Descartado pelo próprio pacote |

## 4. O que o plano V3 do ChatGPT afirma e o repositório desmente

1. **A paleta do mundo** (`#2B7FBF`, `#3A9E52`, `#E8C97A`…) não existe em arquivo
   nenhum do jogo nem da documentação. O mapa tem a paleta própria, medida, no
   dicionário `C` do `gerar_mapa_iso.py`. E o navy do HUD é `#1C3454` (tema),
   não `#1A3A5C`.
2. **«Mangues norte/sul têm consumidores observados»**: na `main` não há mangue
   em cena; a faixa de mangue que o gerador tinha saiu por cair fora do quadro,
   e por ali ser miolo de terra (docstring de `vegetacao_do_solo`).
3. **«Imagens geradas são referências ATÉ passarem por preparação»**: a regra do
   projeto é mais dura — prop no mapa nunca sai de gerador de imagem, preparado
   ou não. Só retrato de painel pode.
4. **Os sprites de grupo não têm consumidor** e contradizem a `035` do próprio
   plano: vegetação que tem de passar por trás das casas nasce no gerador.
5. **Os QA contam existência como prova**: cinco dos 14 PASS da V5 são hashes
   registrados; o do grupo confere quatro cantos, `getbbox() is not None` e que o
   SVG existe. A prova que vale é a das âncoras sob forma mutada — essa está
   certa. A máscara protege lotes, vias, acessos e píeres, e não a altura
   projetada dos prédios, as árvores nem as rotas.
6. **Escala**: um arbusto de 20 px tem lugar para UMA silhueta; folhas de 2 px e
   faceta de reflexo não chegam ao olho (o chanfro só entra na imagem a 3 px, e
   «peça pequena sem aresta» pede `com_saia()`).
7. **«Godot não disponível»** — aqui está, com a bateria de 31 fotos
   (`tools/capturar_evidencia.sh`). A comparação honesta é runtime com semente e
   passo fixos, nunca Inkscape.
8. **A vegetação não está em nenhum dos 31 vereditos do Bruno.** O plano segue o
   «Lote 1 F1 ambiente» dele; as frentes triadas pedem desgaste e obras,
   guindaste por fase, estruturas, frota com variações e os retratos.

O que o plano acerta, conferido: o contrato espacial (§3 — 2:1, `MEIA_LARG`
30/15, `ZOOM` 2/3, quadro 512 de coordenada e 768 de pixel, 720×660 de janela),
a recusa de contorno e o «estado sem mecânica não vira arte».

## 5. A menor próxima iteração, se a vegetação entrar na fila

Não uma V4 do sprite. Se o Bruno a quiser, a moita nasce **no gerador**, com a
gramática do mapa (`com_saia()`, copas facetadas), na escala das árvores
vizinhas, e o que a V1 tinha de bom — duas copas altas sobre uma massa baixa e
escura, tronco à vista — passa a ser uma função que COMPÕE as peças que o mapa
já desenha. O gate: foto de runtime na bateria, uma guarda no teste de design
que prove a peça pela cor ou forma exclusiva dela (a regra do D24), e o olho do
Bruno na foto. A costa V8 só depois.

## 6. Pendente do Bruno

- **Publicar a branch `art/f01-galpao`** do checkout do ChatGPT no GitHub, para o
  galpão V3 aprovado e a casa focal não morrerem com o ambiente dele — e
  renumerar as decisões a partir da `055` antes de qualquer merge.
- Dizer se a vegetação entra na fila, e em que lugar contra as seis frentes.
- A auditoria não traz retratos: a frente 2 continua sem material de fora.
