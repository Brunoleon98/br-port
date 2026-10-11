# 095 — O trânsito dos camiões sai do `Main`, e a bateria não vê diferença

**11/10/2026.** Main `ceba31b` (PR #118, o M7, fundido; nenhum PR aberto do
Codex); 095 livre conferida na main antes de escrever. É o **primeiro dos três
PRs do M8** da fila de `docs/REVISAO_GERAL_2026-10-09.md` (§6) — partir o
`Main.gd`, uma extração por PR, começando pelo maior bloco. Refatoração pura:
nada do que o jogador vê pode mudar, e a prova é a bateria de capturas byte a
byte. Por isso a sessão começou por ela.

## Antes de extrair: a folha que sorteava

A calibração da `094` deixou uma foto instável: duas corridas da MESMA árvore
davam 65 de 66 iguais, e a `trabalhadores.png` mudava. Enquanto fosse assim,
«as 66 fotos não mudaram» não se podia dizer de extração nenhuma.

**A causa eram duas, e a segunda não estava no briefing.** O cartão de cada
rosto leva um barco feito pelo `GS._make_boat()`, que sorteia o valor, a classe
e o motivo pelo `GS._rng` — e o `_ready()` do autoload faz-lhe `randomize()`.
Semear só isso não chegava: a CLASSE sai do nível do porto, e o autoload nasce
do save que a foto anterior da bateria deixou em `user://ferramentas/` — a foto
dependia do disco, que é a regra 6 do fecho (`captura.md`). A folha passou a
fazer o que o `capturar_tela.gd` faz: a semente da bateria (20260902) e depois
o `new_game()`, e só então o porto de trinta docas que ela monta.

Medido, num commit à parte: duas corridas da folha sem semente dão hashes
diferentes; com ela, iguais; outra semente muda a foto; e a semente de volta
devolve o mesmo hash. **Duas corridas da bateria inteira deram 66 de 66 hashes
iguais**, e é esse o ANTES de tudo o que segue.

## O que mudou

**`scripts/TrafegoDeCamioes.gd`** — as 1.378 linhas do tráfego, palavra por
palavra: as rotas e as origens, os quatro serviços com as duas
transportadoras, a cedência nas bocas e nas curvas, a visita ao berço, as
portas de trás, a ordem por profundidade. 51 funções. O `Main.gd` foi de 2.742
linhas e 113 funções para 1.373 e 62. O que mudou nas linhas movidas, e só
isto (conferido por `diff` contra o original):

- o `$MapaWrap.get_node_or_null("Cenario")` de quatro funções passou a ser o
  `_cenario` que o `Main` lhe dá, e o `_docks_container` o `_docas`;
- os três nomes que o `Main` chama ficaram públicos — `animar_caminhoes()`,
  `animar_retorno()` e `docas_mudaram()` —, com os comentários que os citavam.

**No `Main`:** o `preload` do script, o membro `trafego` (montado como
`@onready`, antes do primeiro `_refresh_all()`, que já chama o
`docas_mudaram()`), as três chamadas, e a `ESPUMA_AVANCO` a ler o `MEIA_LARG`
e o `MEIA_ALT` de lá.

**Nos leitores:** as suítes e as ferramentas que perguntavam ao `Main` pelo
trânsito perguntam ao `trafego` — o `teste_design` (os mapas de constantes de
nove funções, e 65 leituras), o `medir_transito`, a `folha_frota` e o
`catalogo_props`. As mensagens do D13 que nomeiam o arquivo da tabela dizem o
arquivo novo.

**No F19** (`093`): a declaração ganhou o alvo `Trafego`, que é um `.gd` e não
uma cena, e o receptor `trafego`; o `_f19_membros` aprendeu a refletir um
script direto, e o piso exige que o alvo novo tenha sido lido.

**O rasto:** os comentários do `Dock.gd`, do `gerar_mapa_iso.py`, do
`gerar_props_iso.py` e do `brp_porto.py` que diziam que é o `Main` quem
escolhe o camião, guarda a rota ou encosta no berço; a `projecao.md`, a
`mapa.md`, o contrato espacial e o plano. As duas regras passam a carregar ao
abrir o script novo — a mão da rua, o chanfro e o D20 são dele.

## Porquê assim

**Um objeto, e não um nó.** Ele não desenha nem tem `_process`: tudo o que
anda é um tween criado no nó de cada camião, e o D35 anda-os com
`custom_step()`. Como `RefCounted` do `Main` — a forma da `FilaDeMensagens` —,
a árvore da cena fica igual e os tweens nascem na mesma ordem, que é o que faz
a bateria sair igual ao byte. Um nó novo debaixo do `Main` teria sido mais um
filho para o D3, para a régua do contraste e para o F19 perguntarem por ele.

**Sem `class_name`.** Ele lê o `GameState` pelo nome, e num `class_name`
alcançado a partir de um `--script` isso não compila (`gdscript.md`). O `Main`
carrega-o por `preload`, como já carregava o `Dock.gd`; as ferramentas, por
`load()`.

**O `trafego` é público.** Quem o lê é a suíte: lido direto (`tela.trafego`),
um nome errado grita; um `tela.get("_trafego")` voltaria a ser o silêncio que o
F19 existe para apanhar. Os privados DELE continuam lidos por string, como os
do `Main` eram — e é para isso que o receptor `trafego` está declarado.

**O `MEIA_LARG` mudou-se com os camiões.** É a escala de tela em que eles
andam; o `Main` só a usa para o avanço da espuma, e lê-a de lá. Ficar nos dois
seria a fonte dupla que o D13 confere contra as âncoras uma vez só.

**Os outros privados ficaram privados.** As suítes leem-nos por string, como
liam; torná-los públicos para a suíte seria desenhar a interface pelo teste.

## A prova de refatoração pura

ANTES é o commit da semente, numa worktree; DEPOIS é a branch. Em sequência —
as duas árvores têm o mesmo nome de projeto, logo a mesma pasta de
ferramentas.

- **A bateria:** **66 de 66 fotos iguais ao byte** à calibração. O controle
  positivo — a `CAMINHAO_VELOCIDADE` ×1,1 no script novo — mudou **23 das
  66**, logo a bateria vê o trânsito, e vê-o onde ele vive agora.
- **As seis suítes** verdes. O `teste_design` dá 1.224 `PASS` dos dois lados,
  linha a linha iguais menos as duas mensagens que nomeiam o arquivo; o
  `teste_fumaca` dá 975, iguais menos a contagem do F19 e uma do F10 (78
  contra 79 frames até à segunda página) — que a árvore de ANTES também dá, em
  uma de três corridas: é ruído do motor, não da mudança.
- **O simulador**, 600 partidas por perfil, semente 20260825: o JSON igual ao
  byte.
- **O `medir_transito`** (que não corre em CI nenhum), 600 s de visitas,
  semente 7: a mesma saída dos dois lados.
- **O F19 de pé:** com a declaração VELHA, ele reprovou o que devia —
  «a declaração não diz que alvo é `trafego`» em 17 nomes, e o `_subir` e o
  `_entrar_no_mapa` pedidos a um `Main` que já não os tem. É o mutante que a
  `093` previa («o nome que muda de dono»), a acontecer de verdade. Com a
  declaração nova: 49 nomes — 16 do `Main`, 19 do `Trafego`, 12 do `Dock` e um
  de cada painel; eram 52, e os três que faltam são as chamadas que passaram a
  públicas, que gritam sozinhas.

## Os mutantes

O original guardado por `cp` e conferido por `cmp` depois de cada um; a suíte
verde exigida entre todos.

| # | Defeito | Reprova |
|---|---|---|
| X1 | uma leitura esquecida no `Main` (`tela.call("_visita_da_doca")`) | F19: o `Main` não tem o método |
| X2 | `_saindo_do_berco` renomeado em todo o script novo | F19: o `Trafego` não tem a variável (×5) |
| X3 | o caminho do alvo novo com um erro | F19: todo alvo tem um script com membros |
| X4 | o ramo `.gd` da reflexão partido | F19: idem |
| X5 | o receptor do `medir_transito` apontado ao `Main` | F19: o `Main` não tem o método |
| X6 | a janela da curva a zero, no script novo | D35: três sobreposições à vista em 5.400 s, e a previsão das curvas |

⚠️ **O primeiro X2 reprovou pelo motivo errado.** Renomear só a DECLARAÇÃO
parte a compilação do script inteiro, e a suíte caiu em cascata — o F19 entre
outras, por «alvo sem membros», e não pela leitura órfã que se queria provar.
Renomeado em todo o arquivo, o script compila e o F19 nomeia a leitura. É a
regra de conferir QUAL guarda reprovou (`testes-e-guardas.md`).

O X6 é o que diz que a suíte testa o código que mudou de casa, e não uma
cópia que tivesse ficado para trás.

## Os dois PRs que faltam

Pela ordem da revisão: **a narradora da Dona Cida** (os `_cida_*` e as
memórias de travessia e de semana) e **a fila de painéis** (`_na_vez`,
`_dar_a_vez_ao_proximo`, `_passar_a_vez`, que a `087` alargou e a
`interface.md` cita no `Main`). A prova é a mesma: a calibração já está feita,
e cada extração corre a bateria contra o hash do commit anterior, com um
controle positivo no script novo.
