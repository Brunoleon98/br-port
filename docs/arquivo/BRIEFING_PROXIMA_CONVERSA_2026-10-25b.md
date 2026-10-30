# BR Port — os carros da viela (`141`) aceites; o item seguinte é do Bruno

**25/10/2026.** Branch `claude/funny-carson-kmhjht`, a partir da `main`
`3de1526` (PR #152, a `140`, com o CI do merge verde e o Web publicado no
Pages). Esta branch não tem PR: ele não o pediu.

**Decisão `141` — os carros da viela**, o item que a `140` deixou de fora,
escolhido pelo Bruno entre os da §7. **Aceite à quarta passagem.** Medido
antes do escopo: na rua do porto um carro não cabe (sobram 0,18 entre o
camião e o meio-fio, e um carro tem ~0,32). Ele escolheu a viela de terra
entre as duas fileiras de casas, a rua principal como rodovia e o número a
crescer com a fase e as obras do porto. O que ficou:

- catorze veículos na viela, onde ela se vê (acima de 90%, medido a cada
  0,1): fuscas, kombi, picape e hatch velhos; hatch redondos e picape nova;
  quatro motos, duas com carga no bagageiro;
- no dia 1, quatro; cada reparo da Fase 1 traz os seus; a Fase 2 traz os
  novos sem contar os reparos da Fase 1; com tudo pronto, catorze;
- a régua dos camiões mais 25%, a pedido; velho e novo separados pelo
  acabamento e pela forma; a máscara da vila onde um lote os tapa.

**A prova:** o D50 do `teste_design` (a cópia, o sítio na viela, à vista e a
máscara, quem aparece estado a estado), o D15 a isentá-los pelo nome, e os 9
mutantes da secção `141` do catálogo, cada um com a asserção que o reprova.

⚠️ O `round()` do Python e o `roundi()` do Godot arredondam o meio de
maneiras diferentes; a máscara de um carro com o pé em 168,5 px saiu um
pixel ao lado, e o gerador arredonda hoje como o Godot
(`.claude/rules/projecao.md`).

⚠️ Uma moto a 13 px lê como ponto, e velho e novo de um veículo separam-se
pelo acabamento e pela forma, não pela cor (`.claude/rules/arte.md`).

⚠️ Prop que sai do catálogo do Blender não sai do manifest: o
`escrever_manifest` junta as fichas (`.claude/rules/arte.md`).

⚠️ O «Outro» desfez uma correção que ele tinha marcado na passagem anterior
(as motos), e quatro reinícios do worker caíram entre a prancha e a
pergunta (`/arte`, o veredito na conversa).

**Pendente:** o PR desta branch, que é decisão do Bruno — com ele o catálogo
passa a 221 mutantes nas três fatias do CI, e a folha dos props a 15
páginas. Fora deste item: a vila a crescer de nível (os carros ganham a
chave dela quando ela crescer), os carros a chegar e a partir, e as
travessas entre quarteirões.

**A próxima conversa:** o item seguinte é do Bruno. Ela abre a
perguntar-lho, com opções e a recomendada primeiro, sem escolher por ele.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 141 (os carros da viela, aceite). Confira a main remota, os PRs
abertos e o CI do último merge, e rode python3 tools/conferir_colaboracao.py
com o trabalho commitado (ele lê o HEAD). Se o trabalho da 141 (branch
claude/funny-carson-kmhjht) ainda não estiver na main, pergunte ao Bruno se
abre o PR dele; se ele disser que sim, conduza-o até verde antes de começar:
o catálogo passou de 212 para 221 mutantes e a folha dos props de 14 para 15
páginas — leia o tempo de cada fatia de mutantes e registe-o na 141.

O item seguinte é do Bruno. Abra a conversa com a pergunta do que vem a
seguir, com opções e a recomendada primeiro, e não escolha por ele. O que
está nomeado e por fazer: as quinze lacunas médias que a 138 deixou de fora
(treze visuais, uma de texto, uma fora do headless); animar as marolas e o
fio diagonal da ponta norte do cais (124); o galpão recuperado V3;
trabalhadores e crédito; e os gates A4 e A7, que são dele. Se ele escolher
arte, use /arte e comece pela foto do jogo e pela pergunta do escopo.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
