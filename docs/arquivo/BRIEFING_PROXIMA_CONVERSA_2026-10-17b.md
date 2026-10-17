# BR Port — a vila humilde, aceite; a seguir, o mapa

**17/10/2026.** Branch `ccr-6bd7aac7-da80m7`, a partir da main `7226802`
(PR #137, o maquinário da obra da `122`, fundido pelo Bruno). Nenhum PR
aberto do Codex nem de outro agente. **Sem PR aberto desta branch.**

**Decisão `123` — a vila humilde**, o item 2 da fila do Bruno. Cinco
passagens, todas pedidas por ele no veredito, e «Aceito» na quinta: no nível
1 a vila tem meia-água de fibrocimento, casinha de empena, térrea de quatro
águas, casa de varanda e casa em L, cada uma num terreno com muro baixo e
portão, com cor de acento (folhas da janela, porta, portão), barrado, fiadas
na telha de barro, moita florida e caixa-d'água assente na cumeeira; a
igreja tem torre no eixo da fachada, pirâmide de barro, cruz e adro com
bancos e poste; a praça da matriz fica numa esquina, com canteiros, coreto
octogonal, postes e bancos; as obras têm tijolo à mostra com argamassa e o
material à frente. Casario de platibanda e sobrado ficam para o nível 2 da
vila, como melhoria do mesmo lote (gerados, não fotografados).

⚠️ Defeito em arte importada só chega à suíte pelo `--import`; o executor de
mutantes reimporta quando o alvo tem `.import` ao lado
(`.claude/rules/testes-e-guardas.md`).

⚠️ O rótulo declarado de um mutante não leva o que o gerador renumera, como o
número do lote (`.claude/rules/testes-e-guardas.md`).

⚠️ Variedade num quadro estreito pede um saco, não um peso; e o sorteio novo
vem de um `Random` novo (`.claude/rules/mapa.md`).

⚠️ O que pousa noutra peça pergunta-lhe a altura naquele ponto; numa peça
quase quadrada, as quinas de cima e de baixo caem na coluna do meio
(`.claude/rules/mapa.md`).

⚠️ Na vila o rumo de cada passagem veio do «Outro», com todas as opções da
lista marcadas, e «mais variações» não era «mais riqueza» (`/arte`, §8).

**A fila que o Bruno deu, a seguir** (plano v3, §7): (3) o mapa — as
melhorias que a sessão achar e as que ele viu: a sombra QUADRADA nos píeres e
o mar que, em vez de escurecer ao largo, tem áreas ao fundo mais claras,
«como se fosse mais raso». Pistas por medir, não conclusões, no briefing
`2026-10-16c`: as manchas de corrente são gradientes radiais e o `mrasa` usa
a cor do BAIXIO; e no dicionário `C` a `agua_funda` (`#0f5a7d`) é mais clara
do que a `agua` (`#0d4d6b`). Abre pela pergunta do escopo (`/arte`) e o mar
pela medição antes de mexer (`.claude/rules/mapa.md`, a regra do matiz e do
valor).

**Pendente do Bruno**: abrir o PR da vila (`123`) e fundi-lo; o recuperado V3
continua só no checkout do ChatGPT.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 123 (a vila humilde). Confira a main remota, os PRs abertos e o
CI do último merge, e rode python3 tools/conferir_colaboracao.py.

A vila humilde (123) está na branch ccr-6bd7aac7-da80m7, aceite na foto do
jogo, sem PR aberto. Pergunte ao Bruno se quer o PR aberto; se ele pedir,
abra-o e conduza-o até verde.

Depois, o item seguinte da fila que o Bruno deu (§7 do plano), um item por
conversa: (3) o mapa — as melhorias que a sessão achar e as que ele viu: a
sombra QUADRADA nos píeres e o mar que, em vez de escurecer ao largo, tem
áreas ao fundo mais claras, como se fosse mais raso. Use /arte: pergunte o
escopo antes de mexer, com opções e a recomendada primeiro, meça o mar antes
de trocar cor (as pistas estão no briefing 2026-10-17b), e fotografe o JOGO.
Leia .claude/rules/mapa.md antes de mexer e regere os quatro mapas.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
