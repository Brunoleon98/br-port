# 034 — O Lote 0 separa EXPORTAÇÃO de PRODUÇÃO, e estado sem mecânica não vira arte

**19/09/2026.** Início do plano de produção dos assets F1–F5, sobre a `main`
no commit `398b8b316ec5a033463dad74d182cc74657a3ba9`. A primeira entrega não modela
nada: fecha consumidor, estado, evidência e propriedade de arquivo antes de
produzir o Kit F1.

---

## 1. O repositório já respondia a quase todas as decisões abertas

O plano chegou com sete perguntas. Lidas contra o jogo e não apenas contra o
GDD congelado, elas ficam assim:

| Pergunta | Decisão canônica do Lote 0 |
|---|---|
| Oficina naval | **F2 recebe a oficina N1; F3 amplia para manutenção N2.** A F1 não produz oficina, porque reparo ainda não é sistema do Vertical Slice. |
| Docas da F1 | **Três berços comerciais no mapa: um ativo no início e dois reconstruíveis.** A arte não altera `DOCKS_BASE = 1` nem `BERCOS_NO_MAPA = 3`. |
| Seis vagas de pescadores | São **um sistema separado** das docas comerciais. Continuam especificação até aluguel/relação com pescadores ter consumidor; não viram seis docas funcionais nem seis alvos falsos no mapa atual. |
| Cidade costeira | A cidade de produção continua **assada no SVG do gerador**, porque muda entre fases e não por turno. `art/brp/casa_costeira.png` e `mercado.png` permanecem em `review`, na cena de teste, até existir interação ou decisão de substituir módulos do mapa. |
| Upgrades N1–N3 | **Píer e guindaste evoluem in-place**, por leituras independentes. Galpão e escritório têm somente ruína/recuperado no jogo atual. |
| F2–F5 | Tudo permanece `concept`/bloqueado até o sistema consumidor existir. Catálogo não é autorização para integrar. |
| Dia/noite e clima | Ficam **depois do Kit F1**. Nenhum dos dois entra no Vertical Slice visual inicial. |

⚠️ **As seis vagas de pescadores não são os três berços comerciais.** O GDD
descreve as duas famílias; transformá-las numa só mudaria capacidade,
economia e leitura do mapa dentro de uma entrega de arte.

---

## 2. O estado “em obra” do galpão fica de fora, e isto é uma correção do plano

O jogo compra estruturas instantaneamente: `comprar_estrutura()` desconta o
caixa, registra a estrutura e emite `estrutura_comprada` no mesmo passo. Não há
duração de obra para o galpão. Portanto os estados consumidos são:

- `ruin` — `galpao_velho.png`;
- `recovered` — `galpao.png`.

Produzir `construction` agora daria uma imagem que nenhuma partida monta. A
arte só ganha esse estado quando uma decisão de gameplay criar duração,
entrada, saída e retomada de construção. Isso exige balanceamento próprio e
não entra escondido no Kit F1.

A mesma regra vale para qualquer “danificado”, “disabled” ou upgrade que não
tenha causa e efeito no jogo: o manifest registra o que é consumido, não tudo
o que seria possível desenhar.

---

## 3. Consumidor e estado do Kit F1

| Família | Consumidor real | Estados atuais | Lacuna aceita |
|---|---|---|---|
| Galpão | `Main.tscn` + `Main.gd` | ruína, recuperado | material e aprovação humana |
| Grua N1 | `Dock.tscn` + `Dock.gd` | idle, working | hoje a varrida é ambiente; o Lote 4 deve ligá-la à operação |
| Píer/doca | `Dock.tscn` + `Dock.gd` | por construir, N1, N2, N3 | polimento e custo mobile |
| Trabalhador | `Dock.tscn` + `Dock.gd` | idle, work_load | hoje é PNG + Tween; Skeleton2D pertence ao Lote 4 |
| Casa costeira | `AssetPlacementTest.tscn` | review | não é exportada nem consumida pelo jogo principal |
| Costa | `Main.tscn` + `Main.gd` | terra, pátio | polimento e custo mobile |
| Espuma | `Main.tscn` + `Main.gd` | ambiente em duas camadas | formalizar RNG/pausa no Lote 4 |
| Mangue | nenhum | concept | escolher posição e consumidor no Lote 1 |

---

## 4. Existem dois manifests porque eles respondem a perguntas diferentes

`BRP_EXPORT_MANIFEST.json` continua **gerado pelo pipeline Blender**. Ele
responde por câmera, quadro, animações declaradas no estúdio, base, alfa e
seleção. Regenerar um estúdio precisa poder atualizá-lo sem conhecer gameplay.

`BRP_PRODUCTION_MANIFEST.json` é a nova fonte para **função, consumidor,
estados reais, evento, teste, custo e gate**. Ele começa somente com o Kit F1.
O schema ao lado fixa os campos, e `tools/conferir_manifesto_producao.py`
reprova:

- ID duplicado ou fora de F1–F5;
- `production` sem saída, consumidor, controlador ou evidência;
- arquivo citado que não existe;
- PNG/SVG de produção que consumidor e controlador não citam;
- status, método, classe ou gate desconhecidos.

Isto não duplica a fonte do render. Um arquivo responde **como foi exportado**;
o outro responde **por que entra no jogo**. Juntá-los faria o próximo render
apagar decisões manuais ou obrigaria o Blender a conhecer cenas e eventos.

---

## 5. Propriedade de arquivos no primeiro ciclo

Enquanto o Lote 0 estiver aberto, esta branch possui:

- `brport_vs/data/assets/BRP_PRODUCTION_MANIFEST*`;
- `tools/conferir_manifesto_producao.py`;
- `.github/workflows/testes.yml`, somente para ligar a nova guarda;
- esta decisão e a posição correspondente no estado do projeto.

Não possui e não altera:

- `Main.tscn`, `Main.gd`, `Dock.tscn` ou `Dock.gd`;
- `gerar_mapa_iso.py` ou `gerar_props_iso.py`;
- economia, save, projeção, viewport ou qualquer PNG/SVG;
- a fila R5–R9 do plano de código.

Se outra sessão tocar nos quatro primeiros arquivos de alto conflito, a
integração continua segura porque este lote apenas os lê e os registra.

---

## 6. Baseline e gate que continuam abertos

A base desta decisão é o mesmo commit em que o plano foi auditado. A medição
local e as seis suítes formam o “antes” reproduzível; números de pacote e VRAM
já medidos na decisão `029` continuam válidos enquanto nenhum asset mudar.

O retrato gravado em `BRP_BASELINE_F1.json`, medido antes de qualquer mudança
de arte, deu:

| Medida | Base F1 |
|---|---:|
| PNGs de props | 61 arquivos · 7.987.081 B no Git |
| RGBA bruto dos props | 143.917.056 B |
| PNGs `art/brp` | 8 arquivos · 638.464 B no Git |
| RGBA bruto de `art/brp` | 18.874.368 B |
| árvore `art/` no disco | 13.605.863 B |
| `.pck` Android local | 6.295.340 B |

As seis suítes passaram. Seus tempos headless ficaram registrados apenas como
referência de regressão local; não são tratados como FPS ou tempo de frame.
`tools/medir_baseline_assets.py --pck CAMINHO` reproduz os tamanhos sem Blender
nem dependência externa.

O gate mobile **não fecha com emulador nem com desktop headless**. Samsung A23
3 GB continua sendo o aparelho de entrada escolhido, mas FPS, pior frame,
memória residente e tempo de abertura nele ficam marcados como **não medidos**.
Nenhum asset novo sobe a `production` alegando G5 antes dessa execução física.

---

## 7. O próximo passo concreto

Com G0 agora fechado para o que já tem consumidor, o Lote 1 pode começar pelo
ambiente F1 sem tocar em economia:

1. capturar o antes;
2. escolher e provar uma posição para o remate de mangue;
3. fazer blockout na projeção oficial;
4. testar costa, rotas, oclusão e toque no tamanho real;
5. só então mudar `f01_mangue` de `concept` para `blockout`.

Galpão, grua e trabalhador não começam a ser refeitos em paralelo com essa
decisão. Eles pertencem aos Lotes 2 e 4 e preservam seus consumidores atuais.
