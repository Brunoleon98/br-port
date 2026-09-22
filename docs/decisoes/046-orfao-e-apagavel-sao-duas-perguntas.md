# 046 — «Órfão» e «apagável» são duas perguntas, e o relatório só faz uma

**22/09/2026 · triagem dos onze órfãos de arte do `tools/arte_orfa.py` ·
opção (d) do briefing de 23/09b, escolhida pelo Bruno**

## O que saiu

**Dois arquivos:** `art/pier_construido.svg` e `art/pier_vazio.svg`, mais os
dois `.import`. O relatório passou de **11 de 109** para **9 de 107**.

**Os outros nove FICAM**, e é decisão e não adiamento.

## A razão: o relatório não pergunta o que parece

O `arte_orfa.py` responde *"que arte não é referida por cena nem por script?"*
— e exclui `brport_vs/scenes/tests/` **de propósito**, porque teste não põe
arte no jogo. Isso está certo e é o que o torna útil.

Só que a pergunta que se quer fazer ao ler o relatório é outra — *"o que dá
para apagar?"* —, e as duas respostas divergem em **nove dos onze**:

| grupo | arquivos | na bancada `AssetPlacementTest`? | no manifest? | disco | `.pck` |
|---|---:|---|---|---:|---:|
| `art/brp/` | 8 | **sim, os 8** (diorama, linhas 64–70) | sim | 638 KB | — |
| `doca_concreto.png` | 1 | **sim** (linha 121) | sim | 46 KB | — |
| **os nove juntos** | | | | 684 KB | **279 KB** |
| `pier_*.svg` | 2 | **não — nada os referia** | não | 2,2 KB | **3,5 KB** |

E o `art/brp/README.md` já respondia pelos oito, por escrito desde que existe:

> *"Nada que permaneceu aqui entra em `Main.tscn`. (...) Existem para
> `scenes/tests/AssetPlacementTest.tscn`, que é onde o critério de aprovação
> do prompt se verifica. (...) Quem quiser puxar o restante para o jogo ainda
> tem de reabrir a decisão 001."*

Eles não são entulho esquecido: são a saída documentada de uma bancada viva,
com a condição de regresso escrita. **Apagá-los seria fechar a porta que a
`001` deixou aberta**, e isso é decisão de design — não de arrumação.

## ⚠️ O que a triagem achou e o briefing não dizia

**1. Apagar um dos nove REPROVA o `asset_validator`.** Os nove estão no
`BRP_EXPORT_MANIFEST.json`, e o validador diz *"no manifest e não no disco"*.
Medido com o defeito posto — arquivos fora, manifest intacto: **código 1 e
nove problemas**, um por arquivo. Com as nove entradas removidas junto, as dez
verificações ficam verdes. Logo o verde da versão completa **não era de
graça**, e a edição do manifest é sustentadora.

**2. `blender/brp_cidade.py` ainda corre** no `gerar_brp.py` (estúdio
`cidade`). Apagar os PNGs sem aposentar o estúdio significa que a próxima
sessão de arte os recria — a cadeia é maior do que a lista de arquivos.

**3. DISCO NÃO É PACOTE.** Os onze mediam **687 KB em disco** e **282 KB no
`.pck`** (4,49% de 6.290.364 bytes), porque o que embarca é o `.ctex`
comprimido. O briefing citava 696 KB, que é a medida errada de qualquer
maneira: nem bate com o disco, nem é o que o jogador baixa.

**4. E ELES EMBARCAM MESMO SEM SEREM REFERIDOS.** O preset é
`export_filter="all_resources"`, e o Godot não faz tree-shaking: o
`exclude_filter` tira a CENA de teste (`scenes/tests/*`) e **não tira a ARTE
que ela usa**. Era fácil supor o contrário e concluir que não custavam nada.

## O que os dois que saíram valiam

**3.516 bytes no `.pck`** — 0,06%. Medido por export próprio, não estimado.

Isto foi **arrumação e não tamanho**, e vale a pena dizê-lo: o tamanho todo
(279 KB, 4,43%) está nos nove que ficaram, e ele não se cobra sem pagar a
bancada e a `001`.

Eles saíram porque estão **superados por props do mesmo nome**:
`art/props/pier_vazio.png` e `pier_n1/n2/n3.png`. Toda referência viva do
repositório é ao PNG — o `Dock.gd:29` faz
`preload("res://art/props/pier_vazio.png")`, o `gerar_props_iso.py` escreve
`grupos["pier_vazio"]`, o `brp_porto.py` fala de `pier_construido.png`. Nenhuma
linha apontava para o `.svg`, e nenhum documento o cita por caminho.

## A prova

- As **dez verificações verdes** com os dois fora, e o relatório a passar de
  11/109 para 9/107.
- O **contra-teste do manifest** acima: a versão que apagava os nove só fica
  verde com as nove entradas removidas, e reprova com nove problemas sem elas.
- O **`.pck` medido três vezes**: base 6.290.364, sem os dois 6.286.848, sem
  os onze 6.007.904.

## O que fica de fora, dito

- **Os nove ficam**, com o porquê agora escrito no cabeçalho do
  `arte_orfa.py` — até ali só se lia «relatório, não portão», e quem contasse
  apagáveis contaria onze.
- **O estúdio `cidade` continua no `gerar_brp.py`**, e é ele que os recria.
  Aposentá-lo é a mesma decisão da `001`, vista do outro lado.
- **O `--reprovar` continua desligado.** Ele existe para quando o destino de
  todos estiver decidido; hoje nove têm destino («ficam») e por isso ele
  passaria — mas ligá-lo é uma decisão à parte, e não se tomou aqui.
