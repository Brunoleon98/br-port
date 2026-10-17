# BR Port — o terreno e a vegetação, não aceites; a próxima conversa continua-os

**17/10/2026.** Branch `claude/terreno-vegetacao-m22sp1`, a partir da main
`01ba125` (PR #139, o mar da `124`, fundido pelo Bruno). **PR #141 aberto a
pedido dele**, por fundir. Nenhum PR aberto do Codex nem de outro agente.

**Decisão `126` — a fila nova do Bruno**, um item por conversa: (1) terreno e
vegetação, (2) estradas, (3) sprites de detalhes. Fora dela: animar as
marolas e o fio diagonal da ponta norte do cais (`124`), os gates A4 e A7, o
galpão recuperado V3.

**Decisão `127` — o morro, o chão, a mata do Blender e a restinga**, o item
1. O chão de trás é raster com textura e sobe num morro de mata; as árvores
são do Blender e balançam (escolha dele), no morro acima do contorno da vila
e na restinga das pontas com o pé fora da areia; entre as casas vão
embutidas no SVG, paradas. A guarda nova é o **D47**
(`casos_mata_do_morro.gd`), com nove defeitos no catálogo.

**Não aceite.** Vistas as fotos, o Bruno pediu outra conversa no mesmo item:
*«focando na melhoria de detalhes e correção de erros para que a vegetação
fique boa; além disso, o terreno pode ser melhorado também»*. As estradas
esperam pelo aceite deste.

⚠️ Um prop por cima do mapa só erra sobre o que está à frente e é mais alto;
chão plano à frente nunca o tapa (`.claude/rules/mapa.md`).

⚠️ O que se mede da costa não sabe da rua: quem pousa a partir da crista
confere a rua do degrau e os cotovelos (`.claude/rules/mapa.md`).

⚠️ A rotação `X` da luz no Blender é o ângulo ao zénite — 82° deu sol
rasante (`.claude/rules/arte.md`).

⚠️ Contorno por coluna é o mínimo da coluna: a guarda que pergunta se ele vê
uma casa só aperta onde a casa é o mais alto (`.claude/rules/testes-e-guardas.md`).

⚠️ Régua que lê pixel de prop ou de bicho passa pelo `PropIso`: o sprite da
fauna também é atlas (`.claude/rules/testes-e-guardas.md`).

**Candidatos que a sessão viu na foto, sem medir** — para a lista do
veredito, não para corrigir sem perguntar: duas aroeiras ainda quase na mesma
coluna na restinga norte; a embaúba pequena só existe cortada na borda
esquerda do morro; o guriri pode ler como agave; a restinga sul com areia a
mais; na folha dos props a juçara pequena «pousa» num telhado (a âncora é uma
embutida atrás de uma casa); e um fio azul de 1 px na borda do pátio da ponta
norte, que é das estradas.

**O PR #140 do Codex (o resumo «Meu porto agora», `125`) foi fundido** a
meio do fecho. As duas branches tinham criado a decisão 125; o Bruno disse ao
Codex que mantivesse a dele, e esta renumerou as suas para `126` e `127`.
Esta branch juntou a `main` depois: dois conflitos de texto — o fim do
`tools/mutantes.toml`, onde as duas acrescentam, e duas linhas do estado —,
ficaram os dois lados. Uma junção de teste antes do merge já tinha passado
nas seis suítes, no `DOCS OK` e nos 22 mutantes novos das duas.

**Pendente do Bruno**: fundir o PR #141 quando quiser — ou depois do aceite,
com as passagens novas na mesma branch.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 126 (a fila nova) e 127 (o terreno e a vegetação). Confira a
main remota, os PRs abertos e o CI do último merge, e rode
python3 tools/conferir_colaboracao.py.

O terreno e a vegetação (127) estão no PR #141, branch
claude/terreno-vegetacao-m22sp1, e NÃO foram aceites. Se o PR ainda estiver
aberto, continue nessa branch (traga a main antes, se ela andou) e conduza o
CI até verde; se já tiver sido fundido, recomece a branch designada a partir
da main.

O item desta conversa continua a ser o 1 da fila da 126, com o pedido do
Bruno: melhorar os DETALHES e CORRIGIR OS ERROS da vegetação até ela ficar
boa, e melhorar também o TERRENO. Use /arte: fotografe o JOGO (dia 1 e porto
completo, e as duas pontas e o morro ampliados), mostre o estado e pergunte
ao Bruno, com opções e a recomendada primeiro, o que ele vê de errado e o
que melhorar no terreno — junte à pergunta, como opções, os candidatos que a
127 viu na foto (estão no briefing 2026-10-17d) e o que você mesmo encontrar
a olhar ampliado. Medir antes de mexer; passagens com prancha antes/depois
contra a main e veredito no fim, com a lista de defeitos que você vê.
Mantenha o que ele já escolheu: árvores do Blender que balançam, os três
coqueiros, a encosta de mata, as espécies da 127.

Não avance para as estradas nem para os sprites de detalhes: anote o que
aparecer deles (o fio azul na borda do pátio da ponta norte é das estradas).
Fora desta fila, para depois: animar as marolas como a espuma e o fio
diagonal na ponta norte do cais (124), os gates do Bruno (A4 leitura, A7
playtest pelo Pages) e o recuperado V3.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável — as estradas, se ele aceitar a vegetação; senão, mais uma volta
nela.
```
