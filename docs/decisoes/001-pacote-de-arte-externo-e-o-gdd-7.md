# 001 — O pacote de arte externo, e o que dele entra

**Data:** 31/08/2026 · **Decisão de:** Bruno · **Estado:** fechada

> Primeira entrada de `docs/decisoes/`, a camada que o
> `docs/design/BR_Port_Plano_v3_Claude_Code.md` (B5) propôs: uma decisão por
> arquivo, curta, para não voltar a discutir o que já foi decidido.

---

## O que chegou

Um pacote de arte em seis partes (~118 MB, 43 arquivos, 27 PNGs e 12 guias em
Markdown), com telas de gameplay dos cinco níveis, pranchas de conceito,
sprites avulsos, fauna, vegetação, cidade, uma auditoria do repositório e um
prompt mestre de pipeline Blender → Godot.

As seis partes chegaram íntegras. Não veio o `00_INDICE.md` que o próprio
prompt manda ler (o índice consolidado faz o papel) nem o arquivo de checksums
(conferiu-se com `unzip -t`).

## A decisão

**O GDD 7 continua valendo.** O pacote entra como **referência de arte** — e
nada mais.

As telas do pacote descrevem um jogo diferente do que está congelado: tempo
real com controle de velocidade (`07:00 · Dia 18`, `VELOCIDADE 1x`,
`TEMPO RESTANTE: 10 MIN`), formato quadrado com trilhos laterais em vez de
retrato, dinheiro em `$` na casa dos milhões, e uma barra com Missões,
Pesquisa, Loja, Mapa e Navios. Turnos, retrato, R$ e o escopo do VS ficam como
estão.

Isso não é crítica ao pacote: a direção de arte dele é melhor do que qualquer
coisa que o projeto tem escrita, e é mais próxima do alvo do
`docs/design/BR_Port_Plano_Arte_Blender.md`. É só que **arte e design chegaram no mesmo
envelope, e só a arte foi aceita.**

O que a decisão protege: as 600 partidas por perfil que mediram a economia
(o turno é a unidade de tudo o que foi medido — relógio real invalida a
medição inteira), o playtest de 26/08 e o escopo travado do VS.

## O que foi medido antes de decidir

**Projeção.** O lote não é homogêneo consigo mesmo:

| Origem | Objeto | Ângulo da base |
|---|---|---|
| Parte 04 — sprites avulsos | **guindaste** | **34,64°** — fora |
| Parte 01 — prancha de progressão | **prédio sobre laje** | **28,20°** — no contrato |
| **Contrato do projeto** | | **26,57°** |

> **Estes são os dois únicos números que sobrevivem à régua estrita**, e a
> régua ficou estrita depois de a primeira versão ter dado 45° para o
> trabalhador e 42° para o barco pequeno — props que estão perfeitamente certos.
> A medida só vale quando as DUAS arestas do apoio concordam e o apoio tem pelo
> menos meia célula de largura; fora disso `conferir_lote_de_arte.py` diz
> "sem apoio plano para medir" em vez de inventar. O caminhão do pacote e os
> guindastes da prancha caem nesse caso — a primeira leitura deles (36,2° e
> 25,6°) era média de duas arestas que discordavam, e foi retirada.
>
> O que continua de pé é a direção do achado: o sprite avulso está fora, a
> prancha de progressão está dentro, e as duas coisas vieram no mesmo pacote.

A causa está no guia da Parte 01, que fixa a câmera assim: *"Vista 3/4 de cima,
com rotação em torno de 45° no eixo Z"*. **Especifica o Z e não especifica a
inclinação em X** — que é justamente o número que decide entre 26,57° e 34,6°.
O projeto tem esse número: `ROT_X, ROT_Z = 60.0, 45.0`, em
`tools/gerar_props_iso.py`. Um `.blend` montado com ele cai no mapa sem ajuste.

**Alfa.** 27 de 27 PNGs sem canal alfa, com o xadrez de transparência pintado
nos pixels — o mesmo defeito de `docs/arquivo/BLOCO4_PACOTE_SPRITES.md`.
`tools/preparar_sprites.py` conserta.

## O que entra, e como

| Balde | O quê |
|---|---|
| **Referência de produção** | A prancha `06_progressao_assets` (básico/intermediário/avançado de navio, prédio e guindaste) — está na projeção certa e é o melhor material do pacote. Os guias de modelagem casam com o kit de detalhe que `gerar_props_iso.py` já tem |
| **Regra nova** | *"Nada flutua: todo prop tem ponto de contato com o chão."* Vira caso no `teste_design.gd`, que hoje confere profundidade e encaixe mas não confere apoio |
| **Referência de estilo** | As telas de gameplay, para paleta, densidade de peça e luz |
| **Não entra** | Os 27 PNGs como sprites de produção. E o `TileMapLayer` do guia da Parte 04, escrito contra um estado do projeto anterior ao mapa atual — ele lista como pendentes tiles de água, costa, rua e calçada que o jogo já gera |

## Correções que a auditoria do pacote precisa

Ela acertou o essencial — não migrar para `TileMapLayer` sem decisão, reusar
`porto_mapa_ancoras.json`, preservar a API do `Worker`, ampliar e não
substituir os testes. Três reparos:

1. `preparar_sprites.py`, `gerar_mapa_iso.py` e `gerar_props_iso.py` estão em
   `tools/` na raiz, não em `brport_vs/tools/` (lá vivem os `.gd`).
2. O commit citado (`72654c0`) era o HEAD em 30/08; a branch avançou.
3. O contrato espacial proposto — 128×128 ortogonal, X para a direita, Y para
   baixo — conflita com o contrato isométrico que o projeto já tem e que o
   `teste_design.gd` verifica. O próprio prompt prevê a exceção ("salvo se o
   projeto já tiver uma grade definida"); o projeto tem.

## Consequência para a fila

Nenhuma reordenação. O plano v3 segue como está, com **A1 (a build no
telefone)** na frente. O pacote alimenta o **A5** quando ele chegar, e a regra
de apoio entra junto do **B4**.

Fica registrado o que NÃO fazer: encomendar o pipeline inteiro do prompt mestre
(cidade em três estágios, doze espécies de fauna, nove variações de vegetação,
`CityView.tscn`) durante a Fase 4. É conteúdo de Fase 7 e está na lista
**VS — OUT** do GDD.
