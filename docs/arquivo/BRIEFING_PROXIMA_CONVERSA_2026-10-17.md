# BR Port — o maquinário da obra, aceite; a seguir, as estruturas da cidade

**16–17/10/2026.** Branch `ccr-f1f610da-seqo9v`, a partir da main `bbc5099`
(PR #136, a obra no mapa da `121`, fundido pelo Bruno com o CI verde).
Nenhum PR aberto do Codex nem de outro agente.

**Decisão `122` — o maquinário da obra**, o item 1 da fila do Bruno. Ele
abriu o escopo às três obras, sem pessoas: no píer, uma balsa com guindaste
de esteiras e a torre do bate-estaca na ponta (dia 1) e o fardo de ripas
suspenso (dia 2); no armazém, um caminhão munck no avental, com a lança no
deck (dia 1) e sobre o telhado que falta (dia 2); no pátio, o rolo de um
tambor com o tambor escuro de perfil e a brita em cone liso. O veredito foi
«Ajustar» só pela linha amarela solta na balsa, que saiu; o resto ficou
como mostrado. Ferramenta nova: `brport_vs/tools/capturar_obra.gd`, a foto
de um dia de obra no jogo.

⚠️ A peça que nomeia a máquina vai à face que se vê, sem nada da mesma cor
por cima; barra fina solta sobre fundo liso lê como risco
(`.claude/rules/arte.md`).

⚠️ Monte de material é mais íngreme do que o real, ou a câmera achata-o num
disco (`.claude/rules/arte.md`).

⚠️ Veículo mede-se pela régua dos camiões, não pela da pessoa
(`.claude/rules/arte.md`).

⚠️ A prancha não alcança um dia de obra (`.claude/rules/captura.md`).

⚠️ O «Outro» do veredito pode trazer o defeito e o fim da passagem; o que ele
não marca não se faz (`/arte`, §8).

**A fila que o Bruno deu, a seguir** (plano v3, §7): (2) as estruturas da
cidade — «na próxima sessão pode seguir para melhorar construções»; (3) o
mapa, com a sombra quadrada dos píeres e o mar que clareia ao fundo (as
pistas estão no briefing `2026-10-16c`; meça antes de mexer). Pista para o
(2), por medir e não conclusão: a vila — casas, sobrados, igreja, praça com
coreto, as duas obras dos lotes — é desenhada em SVG pelo
`tools/gerar_mapa_iso.py` (`vila()`, `casa()`, `predio()`, `--nivel-vila`),
não pelo Blender; mexer nela regera os quatro mapas e o raster que o CI
compara ao byte (`.claude/rules/mapa.md`), e a pergunta do escopo vem antes
(`/arte`).

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 122 (o maquinário da obra). Confira a main remota, os PRs abertos
e o CI do último merge, e rode python3 tools/conferir_colaboracao.py.

O maquinário da obra (122) está na branch ccr-f1f610da-seqo9v, aceite na
foto do jogo, sem PR aberto. Pergunte ao Bruno se quer o PR aberto; se ele
pedir, abra-o e conduza-o até verde.

Depois, o item seguinte da fila que o Bruno deu (§7 do plano), um item por
conversa: (2) melhorar as estruturas da cidade (a vila do mapa: casas,
sobrados, igreja, praça, os lotes em obra). Use /arte: pergunte o escopo e a
composição antes do render, com opções e a recomendada primeiro, e
fotografe o JOGO, não a prancha. A pista está no briefing 2026-10-17: a vila
é SVG do tools/gerar_mapa_iso.py, não Blender — leia .claude/rules/mapa.md
antes de mexer, e regere os quatro mapas. O item (3), o mapa, fica para a
conversa seguinte.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
