# BRP — relatório de validação

**FASE 12 do prompt mestre do pacote de arte.** Gerado em 31/08/2026, contra o
commit desta branch. Todos os números abaixo foram obtidos rodando, não
estimados.

---

## 1. O que passou

| Verificação | Como se roda | Resultado |
|---|---|---|
| Lógica do jogo | `tests/run_tests.gd` | `TODOS OS TESTES PASSARAM` |
| Design e encaixe | `tests/teste_design.gd` | `DESIGN OK` (agora com o caso D8) |
| Áudio | `tests/teste_audio.gd` | `AUDIO OK` |
| Assets, lado Godot | `scripts/validation/asset_validator.gd` | `ASSET OK — 15 assets conferidos` |
| Assets, lado Blender | `blender/validate_brp_assets.py` | `BRP BLENDER OK` nos 4 estúdios |
| Simulador | `tools/simular_balanceamento.gd -- 30` | chegou ao fim |

A suíte existente **não foi alterada** — o D8 é um caso novo acrescentado ao
teste de design, como o prompt manda ("amplie os testes existentes; não os
substitua").

## 2. As duas validações, e por que são duas

| | `blender/validate_brp_assets.py` | `scripts/validation/asset_validator.gd` |
|---|---|---|
| Roda em | Blender (bpy) | Godot |
| Vê | a cena montada | o PNG que chegou ao jogo |
| Cobre | `ORIGIN_anchor`, apoio, `COL_select`, escala, coleção `EXPORT`, nome | quadro, canal alfa, recorte, cena declarada, **projeção contra o mapa** |
| No CI | não — precisa de ~1 GB de `bpy` | sim |

Âncora e apoio **desaparecem no PNG**: depois de renderizado, um prop que
flutua e um prop que assenta são o mesmo arquivo. Por isso a validação tem de
existir dos dois lados.

## 3. Os dois validadores foram provados com defeito injetado

Um validador que nunca reprovou nada não é um validador. Ambos foram testados
contra um defeito posto de propósito:

**Lado Blender** — caminhão levantado 0,5 unidade acima da própria âncora:

```
PEGOU  caminhao: flutua — a malha começa em z=0.500 e a âncora está em z=0.000
```

**Lado Godot** — manifest alterado para `rot_x = 54.736`, que é o isométrico
VERDADEIRO (razão 1,732:1) e o erro exato que produziu o guindaste a 34,6° no
lote externo:

```
FALHOU  rot_x da câmera é 60 (o número que o guia do pacote não fixava)
        — manifest diz 54.736
```

**E o primeiro teste de injeção falhou em injetar.** `CATALOGO` é uma tupla
montada no import: trocar o atributo do módulo não a altera, então o defeito
nunca chegou à cena e o validador "aprovou" um caminhão que estava no lugar
certo. Ficou registrado no código, porque a próxima pessoa vai tentar o mesmo.

## 4. Revisão visual

Teste verde não prova que ficou bonito. A captura da cena de encaixe está em
`docs/img/brp_cena_de_encaixe.png`, e foi olhada. O que ela mostrou, e o que se
fez:

| Achado ao olhar | O que se fez |
|---|---|
| A pilha de caixotes era uma massa marrom só — as seis peças fundiam-se | Três madeiras alternadas e cinta clara no topo de cada caixote. **O render anterior passava em todos os testes.** |
| O arbusto era um balde: o cone alargava para cima | Taper invertido e cinco moitas deslocadas em vez de três |
| As folhas do coqueiro saíam de um ponto, como uma estrela-do-mar | Folha em duas peças, com a ponta caída |
| Os rótulos do diorama sumiam debaixo dos props desenhados depois — inclusive os três caminhões, que são o critério de aprovação | Camada de rótulos acrescentada por último |
| O enquadramento cortava o diorama à esquerda e a bancada à direita | Origem das duas zonas calculada a partir da extensão real, não ajustada no olho |

## 5. O que NÃO passou

**A gaivota.** Três versões, nenhuma lê como ave a 40px — sai um planador
cinzento. Não é falta de iteração: é o mesmo teto que o
`BLOCO7_PLANO_ARTE_BLENDER.md` já mediu para o rosto do trabalhador. Primitiva
composta não resolve silhueta orgânica nessa escala, e a saída registrada é
textura pintada num plano, não mais geometria. Está anotado no cabeçalho de
`blender/brp_fauna.py`.

Ela passa nos validadores — âncora de voo correta, alfa, quadro, projeção — e
é isso mesmo: os validadores medem contrato, não beleza. Quem julga beleza é
quem olha a captura.

## 6. Critério de aprovação do prompt

> "O mesmo asset pode ser colocado em pelo menos três posições diferentes do
> mapa sem perder origem, escala ou ordem visual."

O caminhão está na cena de encaixe em **três posições** — rotuladas 1/3, 2/3 e
3/3 —, todas calculadas por `_tela()` a partir da projeção lida do manifest.
Nenhuma posição foi escrita à mão.

| Restante do critério | Estado |
|---|---|
| Doca recebe navio, trabalhador e guindaste sem flutuação | ✅ na cena |
| Rua liga sem invadir a água | ✅ os tiles encostam pela costa |
| Prédio selecionável abre sem selecionar o vizinho | ⚠️ a `Area2D` existe e é dimensionada pela base; **o toque não foi testado com o dedo** — falta rodar a cena num aparelho |
| Animação reinicia sem salto | ⚠️ **não implementado.** Os ciclos estão declarados no manifest (`wind_idle`, `fly`), e nenhum foi produzido |
| Janela panorâmica da cidade | ⚠️ **não implementada** — ver as notas de implementação |
