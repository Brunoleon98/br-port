# Dona Cida, contente — v1: um sorriso mais claro

**Estado: ✅ B ESCOLHIDA pelo Bruno na foto do jogo (24/09), e já no jogo.**
A linha `("cida", "contente")` da `_CARAS` (`blender/brp_porto.py`) passou a
`sorriso_fechado` + `suave` + `sorrindo`, e o PNG em `brport_vs/` saiu do
estúdio igual à candidata (`tools/comparar_props.py` dá 0,0000).

**Base:** `main` em `5276efa` (o merge do #80).

## De onde vem

Com as três caras da `055` na foto do jogo, o Bruno aceitou a séria e a
preocupada e pediu para a contente um **«sorriso mais claro»**: os cantos da
boca para cima e as sobrancelhas menos altas. A de hoje lia como ESPANTO: a
boca aberta com os dentes numa fita clara entre duas linhas escuras, os
cantos só 3 px acima da linha e a sobrancelha `erguida`.

| | a de hoje | A | **B (escolhida)** | C |
|---|---|---|---|---|
| boca | `sorriso` (aberta, dentes) | `sorriso_fechado`: U de três troços, os de fora a 25° | igual à A | `sorriso_lado`: só o canto direito da imagem sobe |
| sobrancelha | `erguida` | `suave` (a meio caminho da neutra) | `suave` | `suave` |
| olho | `aberto` | `aberto` | **`sorrindo`**: a pálpebra de baixo sobe 7 px de desenho | `aberto` |
| pose | (6, −3, 0) | igual | igual | igual |

As alavancas novas vivem no estúdio (`blender/brp_retratos.py`); este script
só troca a linha da tabela e exporta aquele grupo.

## Como se refaz

```sh
python3.11 art_lab/retratos/cida_contente/v1/gerar_candidatas.py            # as quatro
python3.11 art_lab/retratos/cida_contente/v1/gerar_candidatas.py b_fechado_olhos
```

~18 s por candidata (13 s de render). A candidata `hoje` sai igual ao PNG
que estava no jogo (0,0000), o que prova que o script É o estúdio.

## A prova no jogo

Numa cópia da árvore (`git archive 5276efa`), com SÓ o PNG trocado e o
`--import`, o `PainelBoletim` fotografado pela `capturar_cena.gd` com um
resumo de semana ótima (lucro de R$210.000 contra R$90.000 de média). A
ferramenta de cena da cópia aceitava o resumo em JSON, o que a da `main` não
faz; é a mesma receita das fotos de aceite da `055`.

- Contra a foto com a contente de hoje, cada candidata muda **só entre a
  sobrancelha e a boca** (x 185..233, y 780..842), e fora disso há 18 pixels a
  ±1 (ruído do denoiser).
- ⚠️ **A contente continua sem tiro na bateria**: nenhum tiro monta o boletim
  ótimo. É o terceiro item da `055`.

## Arquivos

| Arquivo | O que é |
|---|---|
| `gerar_candidatas.py` | o script das candidatas |
| `contente_a_fechado.png`, `contente_b_fechado_olhos.png`, `contente_c_de_lado.png` | os PNG 768×768 |
| `prancha_jogo_contente_v1.png` | a de hoje e as três, no cartão do boletim em tamanho de jogo e o retrato a 3× |
| `jogo_boletim_otimo_b.png` | a foto do jogo com a escolhida (720×1280) |
