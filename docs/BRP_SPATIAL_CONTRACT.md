# BRP — Contrato espacial

**FASE 1 do prompt mestre do pacote de arte.** É a fonte única de escala,
origem, grade e camadas para todo asset novo, de qualquer categoria.

> **O contrato não foi inventado aqui: ele já existia no código e está sendo
> escrito.** O prompt do pacote propõe célula de 128×128 px ortogonal, com X
> para a direita e Y para baixo, e prevê a exceção — *"salvo se o projeto já
> tiver uma grade definida; se existir outra escala, adapte todos os valores de
> forma centralizada, sem misturar convenções"*. O projeto tem, é isométrica, e
> é ela que vale. Misturar as duas é o erro que a auditoria do pacote chama de
> risco nº 1.

---

## 1. A projeção

| Grandeza | Valor | Onde vive |
|---|---|---|
| Meia-largura da célula | `MEIA_LARG = 30` px | `tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py` |
| Meia-altura da célula | `MEIA_ALT = 15` px | idem |
| Razão | **2:1** | consequência das duas acima |
| Ângulo da aresta do chão | **26,565°** = `atan(15/30)` | consequência |
| Câmera | ortográfica, `ROT_X = 60°`, `ROT_Z = 45°` | `gerar_props_iso.py` |
| `ortho_scale` | **12,0680** = `RESOLUCAO / (MEIA_LARG / cos 45°)` | derivada, nunca digitada |
| Quadro do prop | **512 × 512** px | `RESOLUCAO` |

Uma célula 1×1 do mundo projeta um losango de **60 × 30 px**.

**Os 60° não são escolha de gosto.** A razão vertical/horizontal de um passo no
chão é `sen(elevação)`; com 15/30 = 0,5 a elevação é 30°, logo a rotação X é
60°. Os 54,736° dos tutoriais são isométrico VERDADEIRO (1,732:1) e aqui dão
errado — é essa a diferença que fez o guindaste avulso do pacote sair a 34,6°
em vez de 26,57° (ver `docs/decisoes/001-pacote-de-arte-externo-e-o-gdd-7.md`).

O guia de Blender do pacote fixa `Z = 45°` e **não fixa o X**. Este documento
fixa: **X = 60°**. É o número que faltava.

## 2. Altura — o ponto onde os dois mundos quase não se falam

`gerar_mapa_iso.py` trata altura como **pixels livres**: `ALT_PIER = 15`,
`ALT_CAIS = 26`, um armazém com 44. É convenção de desenho.

O Blender faz projeção de verdade: **uma unidade de altura projeta 36,74 px**.

Por isso os props falam a língua do mapa — **altura em PIXELS DO MAPA** — e a
conversão está em `z()`, num lugar só. Ignorar isto põe um píer 2,4× mais alto
que o cais desenhado ao lado; já aconteceu.

```
z(altura_px) = altura_px / 36,74
z(15) = 0,4082 unidades de mundo
```

## 3. Origem

**Ponto (0,0) do quadro = origem do mundo, ao nível do chão.** A câmera mira a
origem do chão, não o meio do prop. Consequência prática: **posicionar um prop
na cena é subtrair meio quadro (256 px), não acertar no olho.**

Todo asset novo ganha um `ORIGIN_anchor` — um `Empty` no ponto de contato:

| Categoria | Onde fica o `ORIGIN_anchor` |
|---|---|
| Edifício, doca, guindaste, veículo, caixa | base, no ponto que toca o chão |
| Navio, boia | linha de água (`waterline`), não a quilha |
| Ave em voo | centro do corpo |
| Copa de árvore, lança de guindaste | ponto de encaixe na peça-mãe, não no chão |

## 4. `pos()` inverte o sinal de Y

No Blender a direita da tela é `(+X, +Y)`: os dois eixos do chão puxam para a
direita. No mapa, `tela_x = (mx - my) * MEIA_LARG` — o `+my` puxa para a
**ESQUERDA**. Logo `y_blender = -my`.

Um prop simétrico em Y não denuncia a diferença. O primeiro assimétrico saiu
**40 px fora**. Toda coordenada vinda do mapa passa por `pos()`.

## 5. Faces visíveis

Só **`+x` e `-y`** aparecem por esta câmera. Detalhar as outras é render que
ninguém vê — e é custo de peça que não se paga.

## 6. Profundidade

**Ordem de nó É profundidade.** Quem tem `mx + my` maior está mais perto da
câmera e tapa quem tem menor. Vale em `Dock.tscn` e em `MapaWrap/Cenario`.
Não se usa `z_index` para isto: o `teste_design.gd` confere a ordem dos nós, e
um `z_index` avulso passaria por baixo do teste.

## 7. A grade já publicada

`brport_vs/art/porto_mapa_ancoras.json` é a fonte de posicionamento e **não se
duplica**. Ele publica:

| Chave | O que dá |
|---|---|
| `projecao` | `meia_larg`, `meia_alt`, `alt_cais`, e o centro `cx`/`cy` |
| `pieres` | por doca: `raiz`, `centro` e a âncora do `barco`, em px |
| `faixas` | por degrau: `borda`, `avental`, `rua` e `vila`, em `my` |
| `lotes` | canto e `mx`/`my` de cada lote da vila |
| `mapa` | 720 × 720 |

Criar um segundo arquivo de âncoras sem rotina de sincronização é proibido.

**Tudo o que vive em terra é medido A PARTIR DA BEIRA DO CAIS.** O cais avança
4 unidades por degrau; `APRON`, `RUA_RECUO` e `VILA_RECUO` são recuos, não `mx`
absoluto. O que não avança com ele sai do enquadramento.

## 8. Regras que o pacote acrescenta, e que passam a valer

Estas são novas — vieram do pacote e são boas:

1. **Nada flutua.** Todo prédio, guindaste, caixa, veículo e doca tem base
   visual ou ponto de contato. Sem apoio, o prop lê como recorte colado.
2. **Texto nunca é assado na textura.** Placa e rótulo são objeto do Godot.
   (O projeto já chegou aqui por outro caminho: o importador de SVG é o ThorVG
   e não desenha `<text>`, então o número da doca é estêncil de polígono.)
3. **Seleção é separada da arte.** Quem é selecionável ganha `Area2D` própria,
   dimensionada pela base, não pela silhueta — colisão maior que o prédio
   rouba o toque do vizinho.
4. **Animação preserva célula, origem, escala e margem** em todos os frames.
   Frame que muda de enquadramento salta no loop.

## 9. Como mexer nisto

A projeção é um contrato entre três arquivos: `tools/gerar_mapa_iso.py`,
`tools/gerar_props_iso.py` e `brport_vs/scenes/Main.tscn`. Mexer num valor da
§1 **obriga** a regerar props e mapas e a rodar `tests/teste_design.gd`, que
existe exatamente para pegar essa divergência.

Arte que chega de fora passa antes por `tools/conferir_lote_de_arte.py`, que
mede o ângulo da base contra os 26,57° e o canal alfa.
