# BR Port — proposta de cancelamento aguardando aceite

**14/10/2026.** Análise na branch local
`codex/analisar-cancelamento-servico`, a partir da main `82a9df0`.
PR #131 (`codex/medir-fase-2`) fundido, inclusive o último commit
`7ba2ef7`; nenhum PR aberto no início desta sessão. Testes e Captura do
commit de merge terminaram com sucesso, assim como o deployment do Pages:

- Testes: https://github.com/Brunoleon98/br-port/actions/runs/38663749384
- Captura: https://github.com/Brunoleon98/br-port/actions/runs/38663749485
- Pages: https://github.com/Brunoleon98/br-port/actions/runs/38663745952

Próximo número livre conferido na main: **109**, usado na
`docs/decisoes/109-proposta-de-cancelamento-de-servico.md`.
**É proposta, sem aceite do Bruno e sem implementação.** Só documentos
mudaram. Não houve push, PR novo, merge ou publicação nesta sessão.

O código atual devolve o barco ao largo gratuitamente antes de operar,
desde que haja vaga na fila; depois de `progress > 0`, recusa. O GDD pede
reputação e multa por contrato quebrado. A `109` registra as fontes, a
distinção entre devolução e cancelamento e os casos a provar depois.

Recomendação apresentada: cancelar apenas serviço iniciado, saída
definitiva, trabalhador e doca livres imediatamente, sem pagamento parcial.
Custo candidato: −5 de reputação e multa de 10% do preço acordado, sem
bônus de estrutura, arredondada para cima ao real. Não exige saldo suficiente:
confirmação mostra o saldo resultante e avisa se negativo; derrota continua
no fecho, com possibilidade de recuperação antes dele. Overlay com duas
escolhas, sem criar estado novo do turno e sem cobrar por confirmação
abandonada, repetida ou antiga. Propostos save 18 com migração 17→18 e
registro 5 para os novos acumuladores/eventos; nada disso foi aplicado.

Os valores não foram medidos. Primeiro obter o aceite ou ajuste do desenho,
incluindo custos, saldo negativo e migração. Depois medir as políticas que
cancelam e o controle sem cancelamento, conforme `/balancear`; os perfis
atuais sozinhos não avaliam uma ação que nunca tomam. Não tratar a proposta
como decisão aprovada nem começar código sem esse retorno.

Fecho pela skill `.claude/skills/fechar-sessao/SKILL.md`; verificações
locais registradas na `109`. Estado e §7 do plano atualizados. Não houve
mudança visual, de economia ou de save para exigir captura, tabela ou nova
simulação nesta sessão de análise.

A `107` permanece exclusivamente na branch local
`codex/corrigir-nomes-web`, commit `0a0ab5c`. A publicação ainda precisa de
autorização; falta confirmar a digitação no telefone. Nenhum arquivo dessa
correção entrou nesta branch. A4 segue pendente, caderno reescrito sem
aceite. Tutorial e segunda chance já feitos; trabalhadores extras e crédito
voluntário ficam para depois. Não reabrir a progressão da Fase 2 ou incluir
cancelamento de obras.

Prompt para colar:

```text
Continuando o BR Port. Leia AGENTS.md, ESTADO_DO_PROJETO.md,
§7 do plano v3 e as decisões 103, 108 e 109.
Confira a main remota, os PRs abertos e o próximo número livre.
O PR #131 (codex/medir-fase-2) foi fundido em 82a9df0;
confirme a situação atual antes de editar.

A análise de cancelamento está na branch local
codex/analisar-cancelamento-servico, decisão 109, sem push nem PR.
As regras são PROPOSTA, ainda sem meu aceite: saída definitiva do barco
após iniciar o serviço, doca e trabalhador livres no mesmo dia, sem receita
parcial, −5 de reputação e multa de 10% do valor acordado, sem bônus.
A multa seria imediata mesmo sem saldo; a confirmação avisaria do caixa
negativo e a derrota continuaria no fecho. Save 18 com migração 17→18
e registro 5 também são propostas, sem alteração aplicada.
Retome pelo meu aceite ou ajustes antes de implementar. Os custos ainda
precisam de medição com /balancear e políticas que exercitem cancelamento.

É cancelamento de serviço contratado em andamento, não de obras nem
continuação da progressão da Fase 2. Trabalhadores extras e crédito
voluntário ficam para depois. Tutorial e segunda chance já estão feitos.
A4 continua pendente; não aplicar o caderno reescrito sem meu aceite.
Preserve codex/corrigir-nomes-web (107, commit local 0a0ab5c) separada;
a publicação ainda precisa de autorização e a digitação, de teste no telefone.
Ao encerrar, aplique sempre a skill /fechar-sessao, como exige AGENTS.md,
e entregue o prompt completo da próxima conversa em bloco copiável.
```
