# BR Port — cancelamento medido, implementação aguardando aceite

**15/10/2026.** Branch local `codex/medir-cancelamento-servico`, a partir
da proposta `109` (`8cdcddd`) sobre a main `82a9df0`. PR #131 fundido e
nenhum PR aberto no início da medição. A `110` usa o próximo número livre
depois da `109` local e da `107` reservada em outra branch.

Bruno respondeu **«pode seguir com a medição»**. Foram medidas as regras
candidatas, sem interpretar isso como aceite da implementação ou migração.
O jogo continua sem cancelamento disponível. Não houve push, PR novo ou
publicação desta entrega.

São 31.200 partidas na amostra principal: referência main e doze cenários,
600 por perfil, semente 20260825 e janela de 365 fechos na Fase 2. A bancada
herda o motor e o percurso de `medir_fase_2.gd`; a main sem cancelamento
foi reproduzida em 60.000 campos de 2.400 partidas e todos os resumos.
Os arquivos completos, resumos e verificações estão em
`MEDICOES_CANCELAMENTO_2026-10-15/`.

A `110` recomenda manter **cinco pontos de reputação e multa de 10% do
valor acordado, sem bônus**, como candidato para o aceite. Com troca por
taxa, as medianas até a meta foram 17/43/50 dias nos perfis Ótimo, Mediano
e Antecipado, contra 15/36/41 no controle. As medianas das diferenças de
caixa final emparelhadas foram +R$28.881 / +R$47.005 / +R$44.156, mas o
P10 de cada uma é negativo: não há promessa de ganho por cancelar.
O Descuidado conquistou em 6/600, com 594 vivas sem meta; só 122 cancelaram.
Não houve quebra na amostra principal, o que não prova risco nulo.

As políticas de uma troca, valor e impulsiva e as variações de reputação
e multa estão na decisão. Retirar a multa provocou mais trocas e mais
penalidades de reputação, atrasando o Mediano. A lição está na
`.claude/rules/economia.md`: contar ações junto com custos e resultados.

O estado experimental implementa apenas o necessário para medir caixa,
reputação, saída do barco e liberação da equipe. Não implementa boletim,
interface, registro novo, save 18 ou migração; não deve ser ligado ao jogo
como se estivesse pronto. A futura implementação precisa de paridade com
a bancada e dos testes de interface, contabilidade e persistência da `109`.
Os controles de saldo negativo exercitam o fecho real, tanto com recuperação
por novo serviço quanto com quebra sem recuperação.

O fecho pela `.claude/skills/fechar-sessao/SKILL.md` inclui as verificações
do pacote, as seis suítes e o `DOCS OK`; resultado em `verificacao.json`.
A importação avisou `Safe save failed`, inclusive pelo helper seriado do
CI e com `--verbose`; não foi considerada limpa. O motor retornou zero,
mas o arquivo e a causa não foram identificados. A limitação e os logs
estão na `110` e no pacote; as suítes e medições passaram.

A `107` permanece em `codex/corrigir-nomes-web`, commit local `0a0ab5c`.
Falta autorização de publicação e confirmação da digitação no telefone.
A4/caderno sem aceite; tutorial e segunda chance prontos. Obras, mais
trabalhadores e crédito voluntário ficaram fora deste recorte.

Prompt para colar:

```text
Continuando o BR Port. Leia AGENTS.md, ESTADO_DO_PROJETO.md,
§7 do plano v3 e as decisões 109 e 110; use 103 e 108 como contexto.
Confira a main remota, os PRs abertos e o próximo número livre.
O PR #131 foi fundido em 82a9df0; confirme a situação atual.

A branch local codex/medir-cancelamento-servico contém a proposta 109
e a medição 110, sem push nem PR. Bruno autorizou seguir com a medição;
isso ainda não foi aceite para implementar ou migrar o save.
Foram 600 partidas por perfil e 31.200 na amostra principal, semente
20260825, com 365 fechos de observação na Fase 2. Dados e controles:
docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/.
A recomendação é manter −5 de reputação e multa de 10% do valor acordado,
sem bônus. As trocas podem melhorar caixa e atrasar a meta; confira
dispersões, censuras e os denominadores na 110 antes de tirar conclusões.

Retome pelo meu aceite ou ajustes das regras antes de implementar:
saída definitiva do barco iniciado, doca e equipe livres no mesmo dia,
sem pagamento parcial, confirmação com custos e saldo resultante.
Saldo negativo permitido com derrota avaliada no fecho, e save 18 com
migração 17→18, continuam propostas. A bancada não é implementação pronta:
faltam interface, contabilidade, registro e persistência; exigir paridade.

É cancelamento de serviço contratado, não de obras nem continuação
da progressão da Fase 2. Mais trabalhadores e crédito voluntário ficam
para depois. Tutorial e segunda chance já estão feitos.
A4 segue pendente; não aplicar o caderno reescrito sem meu aceite.
Preserve codex/corrigir-nomes-web (107, commit local 0a0ab5c) separada;
publicação exige autorização e a digitação precisa de teste no telefone.
Ao encerrar, aplique /fechar-sessao e entregue o prompt completo
da próxima conversa em bloco copiável, como exige AGENTS.md.
```
