# Dona Cida, séria — v1 da cabeça REDONDA

**Estado: REJEITADA pelo Bruno (23/09), refeita na `v2/`.** Ele marcou os
quatro defeitos que a leitura apontava — nariz e boca, tronco, gola, cabelo e
lápis, os mesmos da secção «Limitações» abaixo e mais — e pediu para
«melhorar o modelo como um todo». Fica aqui como registo.

Escolhida por ele em 23/09 (opção B do §7.5 do plano de arte: *«um retrato
novo completo, a Dona Cida séria»*).
Nada daqui está no jogo: o PNG de `brport_vs/art/props/retrato_cida_seria.png`
continua a ser o de `blender/brp_porto.py`.

**Base:** `main` em `dfa8319` (o merge do #78), mais os dois commits de
documentos da branch `claude/peaceful-dijkstra-aosw6d`, que não tocam em
`brport_vs/` nem em `blender/`.

## O que é

Um busto 768×768 com alfa verdadeiro, do MESMO estúdio dos retratos de hoje:
o script importa o `Estudio` de `blender/brp_studio.py`, que tira a câmera, o
rig de três pontos, a paleta, a resolução e o render de
`tools/gerar_props_iso.py`. Muda só a geometria — e o render usa a mesma
transformada de cor de hoje (AgX), para a comparação ser do MODELO e não da
cor.

| Prática (plano de arte) | Nesta peça |
|---|---|
| P1 — malha-base redonda | cabeça, pescoço e tronco de METABALL, com `Subdivision` e `shade smooth` |
| P2 — forma por personagem | a dela é o CÍRCULO: ovo, bochechas cheias à frente, queixo largo, óculos redondos, coque redondo |
| P3 — olho em esfera | esclera, íris e pupila em esfera; BRILHO de emissão (força 4, por causa do AgX); PÁLPEBRA em casca, em descanso |
| P4 — curvas | sobrancelhas e boca em Bézier com espessura, pousadas por `ray_cast` |
| mechas | massa de cabelo + três sulcos RASOS penteados para o coque |
| identidade de hoje | coque atrás e acima, óculos, lápis atrás da orelha, gola clara, blusa verde, `pele_escura` |

## Como se refaz

```sh
pip install "bpy==4.5.0"          # Python 3.11
python3.11 art_lab/retratos/cida_seria/v1/gerar_retrato_cida_v1.py art_lab/retratos/cida_seria/v1
PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar a forma
```

~29 s ao todo, **21,4 s de render** (o retrato de hoje leva ~13 s). ⚠️ O PNG
não é byte-reprodutível — o denoiser varia ±2/255 e o Blender carimba a data
(`CLAUDE.md`, Arte); quem pergunta "mudou?" é `tools/comparar_props.py`.

## Medido

- **Enquadramento:** o busto ocupa x 153..614 do PNG, dentro da janela que a
  caixa do retrato mostra (101..667 — `COVERED` de 768 em 168×228); a cabeça
  vale 60% da altura, como hoje; o topo do cabelo está a 16 px, como hoje. O
  tronco sai pela borda de baixo, como numa fotografia.
- **Brilho no olho:** chega a **234/255** (o AgX segura-o abaixo do branco).
- **Alfa:** 99,2% dos pixels a 0 ou 255, o mesmo do retrato de hoje.

## Seis tentativas, e o que cada uma ensinou

Tudo está em comentário no script, junto da linha que corrige:

1. a primeira cabeça saiu em **PERA** — bochechas a inchar para os lados e
   queixo em bico, que é o triângulo do Arlindo; redondo é um ovo com as
   bochechas a encher para a FRENTE;
2. as mechas eram tubos inteiros pousados na cabeça e **penduraram-se na testa
   como dreadlocks**; cabelo penteado são sulcos meio enterrados na MASSA;
3. a gola era um anel e saiu uma **boia**; gola de blusa são duas pontas
   pousadas no peito, a partir da base do pescoço MEDIDA;
4. **a cabeça flutuou**: o pescoço de metaball sai fino e, com a câmera de
   cima, o queixo tapa-o; o trapézio tem de subir ao encontro dele;
5. **a boca colou à sombra do nariz e leu-se como BIGODE**, e depois caiu na
   linha do queixo; a câmera de cima encurta a distância nariz–queixo, e a cara
   precisou de um queixo mais comprido para a boca ter onde ficar;
6. **a sombra dos óculos desenhou um segundo aro** na cara; os aros não
   projetam sombra.

E duas armadilhas da câmera que já estavam medidas e voltaram: o raio vindo de
cima passa ao lado da testa (recua para o meio e para trás), e `ray_cast` só
funciona no objeto ORIGINAL com o `depsgraph`.

## Limitações — o que esta versão NÃO resolve

- **A sombra do nariz** faz uma mancha pequena à direita dele. A chave é dura
  (1,6°) e o nariz é parte da malha da cabeça; não se desliga sozinho.
- **O tronco ainda é macio demais** — lê como camisola larga, sem ombro
  marcado.
- **É uma expressão só.** As outras duas (preocupada, contente) e a pose de
  cada uma ficam para depois de o Bruno aprovar a direção.
- ⚠️ **E ela deixa de ser da oficina dos outros.** O `Retratos.gd` diz que os
  retratos têm de combinar com o `trabalhador_retrato` do rodapé, que é de
  caixas; e o Sr. Ribeiro e o Arlindo continuam de caixas. Se a Dona Cida
  passar a redonda, os outros dois e o trabalhador têm de seguir — ou o jogo
  fica com duas oficinas no mesmo painel.

## Arquivos

| Arquivo | SHA-256 |
|---|---|
| `gerar_retrato_cida_v1.py` | ver `sha256.txt` |
| `retrato_cida_seria.png` | ver `sha256.txt` |
| `prancha_hoje_vs_v1.png` | a de hoje e a candidata, na caixa do telefone (168×228) e a 50% |
| `jogo_boletim_v1.png` | a foto do JOGO com a candidata (tiro `boletim` da bateria, 720×1280) |
| `jogo_boletim_hoje_vs_v1.png` | o cartão do boletim, hoje e com a candidata, lado a lado |

## A prova no jogo

Numa cópia da árvore (`git archive HEAD`) com SÓ este PNG trocado, `--import`
e a bateria inteira (`tools/capturar_evidencia.sh`, semente e passo fixos),
contra a bateria da árvore de hoje, comparadas em RGB:

- **mudou 1 foto em 31** — o `boletim`, o único tiro onde a Dona Cida aparece
  com a cara `seria`;
- **e só dentro de uma caixa de 100×149 px** (x 158..258, y 755..904 da
  captura), que é a caixa do retrato; o resto do cartão e do jogo, byte a byte;
- as outras 30 saíram iguais nas duas corridas, logo a bateria não tem ruído
  próprio neste par; e ela VÊ o retrato, porque o `boletim` mudou.

⚠️ **E a mesma foto mostra a limitação da oficina**: o cartão do trabalhador,
no rodapé, continua a ser o boneco de caixas.
