# BR Port — a pesquisa de melhorias (`143`); a seguir, aprofundar a animação e o toque

**29/10/2026.** Branch `ccr-83914c2f-kuj4zq`, a partir de `5e8b983`, a
cabeça de `claude/br-port-continuacao-72yq7v`: os dois commits só de
documento dela (os tempos das fatias do #154 na `142` e o registo do bloco
na §7) vão no PR da pesquisa, resposta do Bruno. A `main` estava em
`d310922` (#154), com os três workflows verdes, e sem PR aberto.

**Decisão `143` — o primeiro tempo do bloco de 29/10.** Nenhuma linha de
jogo mudou. O estudo é `docs/PESQUISA_MELHORIAS_2026-10-29.md`: por tema
(iluminação, animação, som, toque, clareza, ritmo, interface, desempenho,
acessibilidade), o jogo de hoje medido, as técnicas com a fonte como pista
de padrão (nenhuma página foi lida), o custo aqui e o ganho. A sonda de
animação e os registos dela ficaram em
`docs/arquivo/MEDICOES_PESQUISA_MELHORIAS_2026-10-29/`.

**O que ele escolheu:** aprofundar **a animação e o toque** (a
recomendada), na ordem animação → luz → som → resto. Só essa conversa
abriu; a luz, o som e o resto abrem-se quando ele os pedir.

⚠️ A sonda só mede o que o estado montado tem: sem `atracar`, o barco
atracado não aparece no que mexe, e a primeira corrida quase o deu por
parado (`gerais.md`, «percurso responde pelo que se vê»; `143`).

**Pendente:** o PR da pesquisa e o CI dele; o tiro de painel a 1080 que
reprova a prova das caras, por apurar (`143`); a hipótese de que as
máscaras por instância partem o lote de desenho (D1 da pesquisa), por
medir; o `ESTADO_DO_PROJETO.md` a menos de cem bytes do teto. Do 25c
continuam: as fatias lentas dos mutantes (`142`) e o `1687ce5` na branch
`claude/upbeat-meitner-fkfkne`, que nunca chegou à `main`.

**A próxima conversa:** o segundo tempo do bloco para o tema escolhido —
aprofundar a animação e o toque, desenhar, perguntar-lhe, e só implementar
depois de ele aprovar.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3,
a decisão 143 e docs/PESQUISA_MELHORIAS_2026-10-29.md (§2 Animação, §4.1
Toque e §5, como os temas se cruzam). Confira a main remota, os PRs abertos e
o CI do último merge, e rode python3 tools/conferir_colaboracao.py com o
trabalho commitado (ele lê o HEAD). A pesquisa está no PR da branch
ccr-83914c2f-kuj4zq; se ainda não estiver na main, parta da cabeça dele.

Esta conversa é o segundo tempo do bloco de 29/10 para UM tema, o que o Bruno
escolheu: a animação e o toque. Aprofunde e desenhe; só implemente depois de
ele aprovar o desenho.

1. Meça antes, com o que existe: a sonda do arquivo
   (docs/arquivo/MEDICOES_PESQUISA_MELHORIAS_2026-10-29/sonda_animacao.gd,
   com `completo atracar`), a foto do jogo a 1080 e o medir_desempenho.gd.
   Leia as decisões 078 (a virada do dia; o rumo antigo da chegada
   atravessava o píer) e 083 (a fila no fundeadouro; o barco a deslizar do
   largo ao berço ficou para depois) e a troca de barco no Dock.gd: hoje o
   barco entra pelo RUMO_DO_MAR, não do lugar ao largo onde se tocou.
2. Aprofunde os quatro itens do tema: A1 (o retorno ao toque — atracar, o
   «Avançar dia», a obra que acaba), A1′ (o barco que desliza do largo ao
   berço), A3 (o casco que rola) e T1 (a háptica: Input.vibrate_handheld, a
   permissão VIBRATE no preset Android, uma opção nos Ajustes). Para cada
   um: o que mexe (cena, ordem de nó, o MovimentoDeFundo do reduzir
   movimento, a captura byte a byte, o «+R$» que nasce do casco), como se
   prova (uma sonda ao longo dos frames, gdscript.md; a foto do instante; o
   defeito injetado de cada guarda nova, no catálogo de mutantes) e quanto
   custa no desenho (medir_desempenho).
3. Pergunte ao Bruno, com opções e a recomendada primeiro, o desenho de cada
   item e por que ordem implementar; para o que é visual use a /arte e
   mostre em vídeo ou em quadros (na 142 o GIF não animou no app). Não
   escolha por ele.
4. Depois de ele aprovar, implemente nesta conversa só o primeiro item
   aprovado; os outros ficam na §7, um por conversa, com o desenho
   registado numa decisão.

A luz, o som e o resto abrem-se quando ele os pedir (143). Ao encerrar,
aplique /fechar-sessao e entregue o prompt completo da próxima conversa em
bloco copiável.
```
