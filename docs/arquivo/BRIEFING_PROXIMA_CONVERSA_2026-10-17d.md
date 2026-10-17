# BR Port — o terreno e a vegetação, à espera do veredito; seguem as estradas

**17/10/2026.** Branch `claude/terreno-vegetacao-m22sp1`, a partir da main
`01ba125` (PR #139, o mar da `124`, fundido pelo Bruno). Nenhum PR aberto do
Codex nem de outro agente. **Sem PR aberto desta branch.**

**Decisão `125` — a fila nova do Bruno**, um item por conversa: (1) terreno e
vegetação, (2) estradas, (3) sprites de detalhes. Fora dela: animar as
marolas e o fio diagonal da ponta norte do cais (`124`), os gates A4 e A7, o
galpão recuperado V3.

**Decisão `126` — o morro, o chão, a mata do Blender e a restinga**, o item
1. O chão de trás é raster com textura e sobe num morro de mata; as árvores
são do Blender e balançam (escolha dele), no morro acima do contorno da vila
e na restinga das pontas com o pé fora da areia; entre as casas vão
embutidas no SVG, paradas. A mata andou quatro passagens («Ajustar» nas
três primeiras); **a quarta e a primeira da restinga foram entregues em foto
e esperam o veredito dele.** A guarda nova é o **D47**
(`casos_mata_do_morro.gd`), com nove defeitos no catálogo.

⚠️ Um prop por cima do mapa só erra sobre o que está à frente e é mais alto;
chão plano à frente nunca o tapa (`.claude/rules/mapa.md`).

⚠️ O que se mede da costa não sabe da rua: quem pousa a partir da crista
confere a rua do degrau e os cotovelos (`.claude/rules/mapa.md`).

⚠️ A rotação `X` da luz no Blender é o ângulo ao zénite — 82° deu sol
rasante (`.claude/rules/arte.md`).

⚠️ Contorno por coluna é o mínimo da coluna: a guarda que pergunta se ele vê
uma casa só aperta onde a casa é o mais alto (`.claude/rules/testes-e-guardas.md`).

**O que fica para as outras conversas** (na `126`): nas estradas, um fio azul
de 1 px ao longo da borda do pátio de terra na ponta norte, contra a
restinga — visto, não investigado; nos detalhes, o coqueiro menor, se o
Bruno o quiser (medido: 71 px, ≈3× a casa, a proporção real).

**Pendente do Bruno**: o veredito da quarta passagem da mata e da primeira da
restinga; abrir o PR desta branch e fundi-lo.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 125 (a fila nova) e 126 (o terreno e a vegetação). Confira a
main remota, os PRs abertos e o CI do último merge, e rode
python3 tools/conferir_colaboracao.py.

O terreno e a vegetação (126) estão na branch claude/terreno-vegetacao-m22sp1.
Se o PR ainda não estiver aberto ou fundido, pergunte ao Bruno se quer o PR
aberto; se ele pedir, abra-o e conduza-o até verde. Se ele ainda não deu o
veredito da quarta passagem da mata e da primeira da restinga, pergunte-lhe
primeiro, com a foto, e ajuste o que ele marcar antes de abrir a fila.

O item desta conversa é o 2 da fila da 125: as ESTRADAS. Use /arte:
fotografe o JOGO antes, mostre o estado das ruas (asfalto, calçada,
cotovelos, passadeiras, a viela de terra e os acessos aos berços) e pergunte
ao Bruno o escopo antes de mexer, com opções e a recomendada primeiro. Olhe
também o fio azul ao longo da borda do pátio de terra na ponta norte, que a
126 anotou para esta conversa. Não avance para os sprites de detalhes:
anote o que aparecer deles para a conversa seguinte.

Fora desta fila, para depois: animar as marolas como a espuma e o fio
diagonal na ponta norte do cais (124), os gates do Bruno (A4 leitura, A7
playtest pelo Pages) e o recuperado V3.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa (sprites de
detalhes) em bloco copiável.
```
