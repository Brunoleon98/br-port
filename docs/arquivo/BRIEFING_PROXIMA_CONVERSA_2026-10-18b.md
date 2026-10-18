# BR Port — a vegetação aceite; a próxima conversa é a das estradas

**18/10/2026.** Branch `ccr-d445dbad-nogxh2`, recomeçada da main depois de o
PR #141 (o terreno da `127`) ser fundido, e com a main de novo junta depois
do PR #142 (versão e diagnóstico, `128`). **Sem PR aberto desta branch** — o
Bruno não o pediu nesta conversa. Aberto do Codex: o PR #143 (movimento
reduzido, a decisão `129` dele).

**Decisão `130` — a vegetação de folhas, o morro com clareiras e os
destaques à vista**, a segunda conversa do item 1 da fila da `126`. Sete
passagens, quatro «Ajustar», **aceite** à sétima. A mata respeita só o que
lhe fica À FRENTE na vila (o contorno por lote); a copa do Blender é de
FOLHAS, com a normal da copa inteira; o morro tem duas clareiras de granito,
o relvado trilhas e hortas; ipê, juçara e embaúba só nascem com a copa à
vista — fora do HUD e sem árvore à frente a tapá-la —, e as jovens das duas
palmeiras entraram no relvado. O **D47** ganhou o §3c e o §8 ao §12, cada
um com o seu mutante.

⚠️ O topo do mapa está debaixo do HUD: quem tem de ser visto pergunta onde
fica a copa, não o pé (`.claude/rules/mapa.md`).

⚠️ Num empacotamento sorteado, cada aperto desaba em cascata; conte por
espécie a cada aperto e meça nos pixels (`.claude/rules/mapa.md`).

⚠️ A copa do Blender é de folhas com a normal da copa; a face da folha vira-se
para a câmara, e a fruta pousa na pele das folhas (`.claude/rules/arte.md`).

⚠️ Mutante que troca arte confere que a nova existe onde é lida — o `<use>`
de uma espécie fora das `<defs>` não desenha nada
(`.claude/rules/testes-e-guardas.md`).

⚠️ Uma técnica nova prova-se numa árvore, no JOGO, antes de ir a todas, e a
pergunta traz «aplicar a todas» (`.claude/skills/arte/SKILL.md`).

⚠️ O executor de mutantes morto a meio restaura o arquivo mas não o cache do
importador: `--import` antes de outra coisa, e o catálogo inteiro corre com
o teto de tempo dado à mão (`.claude/rules/testes-e-guardas.md`).

**O que fica, visto e registado na `130`:** o ipê amarelo da borda do morro
com 63% da copa debaixo da embaúba à frente (a guarda corta a 76%); a juçara
jovem e a embaúba jovem pequenas e parecidas uma com a outra; os destaques
do morro encostados à borda esquerda, meio fora da tela; e a escura grande
(`mata_a`) sem lugar no morro, só embutida fora da tela.

**Depois do aceite**, as provas do fecho apertaram a implantação: a regra da
copa tapada passou a somar as árvores da frente e a contar os destaques, e
toda forma da massa entra ao menos uma vez — a mata ficou com 62 árvores e
os mesmos 11 destaques, com uma embaúba trocada de sítio e a escura alta de
volta. As seis suítes, os 103 mutantes e a bateria de capturas passam sobre
o estado final.

**Para a conversa das estradas** (anotados nas fotos desta, não
investigados): um fio azul de 1 px na borda do pátio de terra da ponta norte,
contra a restinga; e uma linha fina diagonal no asfalto junto do coqueiro
sul.

**Pendente do Bruno**: pedir o PR desta branch quando quiser — o CI só corre
no PR (`CLAUDE.md`, «Como rodar»).

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 126 (a fila) e 130 (a vegetação aceite). Confira a main remota,
os PRs abertos e o CI do último merge, e rode
python3 tools/conferir_colaboracao.py.

A vegetação (127 e 130) foi ACEITE e vive na branch ccr-d445dbad-nogxh2, sem
PR. Se ela ainda não estiver na main, pergunte ao Bruno se abre o PR dela e
conduza-o até verde antes de começar; as estradas partem da main com ela.

O item desta conversa é o 2 da fila da 126: as ESTRADAS. Use /arte:
fotografe o JOGO (dia 1 e porto completo, e ampliados a rua de mão dupla,
os cotovelos, os acessos aos berços, o pátio e as duas pontas), mostre o
estado e pergunte ao Bruno o escopo, com opções e a recomendada primeiro —
junte à pergunta, como opções, o que a 130 anotou nas fotos (o fio azul na
borda do pátio da ponta norte e a linha fina diagonal no asfalto junto do
coqueiro sul; estão no briefing 2026-10-18b) e o que você mesmo encontrar a
olhar ampliado. Medir antes de mexer; passagens com prancha antes/depois
contra a main e veredito no fim, com a lista de defeitos que você vê.
Mantenha o que ele já aceitou: a vegetação da 130, a vila da 123, o mar da
124, e os camiões de mão dupla que encostam de ré nos berços (a ROTA_ESTRADA
e o D20 guardam a pista).

Não avance para os sprites de detalhes (item 3): anote o que aparecer deles.
Fora desta fila, para depois: animar as marolas como a espuma e o fio
diagonal na ponta norte do cais (124), os gates do Bruno (A4 leitura, A7
playtest pelo Pages), o recuperado V3, e o que a 130 deixou registado (o ipê
amarelo da borda 63% tapado, as palmeiras jovens pequenas).

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável — os sprites de detalhes, se ele aceitar as estradas; senão, mais
uma volta nelas.
```
