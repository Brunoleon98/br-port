# BR Port — aceite do recorte de Como jogar/glossário

**15/10/2026.** Bruno aprovou o recorte completo da `113` com o ajuste
**«O jogo faz gravações automáticas durante a partida»**. A resposta e seus
limites estão na `114`: aceite da definição, sem autorização de implementar
ou publicar outro PR. Documento do recorte, estado e §7 foram alinhados.
Nenhum código do jogo mudou.

`git fetch origin main` confirmou `f03302d`. O GitHub reconfirmou o merge
do PR #133 e os dos PRs #131 (`82a9df0`) e #132 (`b142b80`). Testes e
Captura do head `9dc0732` (`38770869326`, `38770869216`) e do merge
(`38773108323`, `38773108305`) seguem verdes; Pages `38773106178` também.
Não havia PR aberto no arranque nem na reconferência do fecho. Main até a
`112`, `113` local; a `114`
era livre. Depois deste aceite, a próxima decisão é `115`, a reconferir.

A branch `codex/implementar-cancelamento-servico` foi mantida, preservando
o commit local `71613f6`, posterior ao merge. Este fecho fica em novo commit
local, sem push ou PR. A branch de nomes segue em `0a0ab5c`, separada.
Pesquisa, revisão e pacotes selados de cancelamento permaneceram byte a byte
iguais à main. A pasta `.evidencias/` não rastreada foi preservada.

O fecho aplica `.claude/skills/fechar-sessao/SKILL.md`. A verificação local
usa Godot 4.6.3, as seis suítes derivadas do workflow e execução em série,
com perfil isolado em `.evidencias/aceite-como-jogar/`. O lançador exige
código zero, marcador final e ausência de `SCRIPT ERROR` e
`at: push_error (`, como o CI. As seis passaram, com os marcadores
`TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`,
`REGISTRO OK` e `ASSET OK`; os cinco arquivos da sentinela ficaram intactos.
`conferir_docs.py`: `DOCS OK`, estado com 29.949 bytes, sem aumentar teto;
diff sem erros de espaços. Não houve captura ou medição econômica nova,
pois a mudança se limitou aos documentos.

Os logs locais preservam avisos de objetos/recursos no encerramento. A
fumaça também tem o JSON inválido intencional e duas queixas
`Parameter "t" is null` do renderizador dummy, já descritos no fecho anterior.
Não se declara a rodada sem avisos. Usou-se a importação já existente;
não houve nova importação nem diagnóstico do `Safe save failed` da `110`/`111`.
Este commit local não tem CI novo: não foi publicado. As provas verdes acima
são do PR #133 e de seu merge, não de uma implementação da ajuda.

Prompt para colar:

```text
Continuando o BR Port no repositório br-port/. Leia AGENTS.md,
docs/ESTADO_DO_PROJETO.md, §7 de
docs/design/BR_Port_Plano_v3_Claude_Code.md, decisões 109–114 e
docs/RECORTE_COMO_JOGAR_GLOSSARIO_2026-10-15.md; use 103 e 108 como contexto.
Confira a main remota, PRs abertos e o próximo número livre antes de editar.

O PR #133, da branch codex/implementar-cancelamento-servico, está fundido
em f03302d, última main reconferida. O head 9dc0732 e o merge passaram
em Testes e Captura; o Pages do merge passou. #131 foi fundido em 82a9df0
e #132 em b142b80. Não havia PR aberto na última conferência.
A main contém decisões até a 112; 113 e 114 estão locais.
O próximo número livre depois da 114 era 115; confira novamente.

Bruno APROVOU o recorte de Como jogar/glossário com um ajuste na frase
do autosave: “O jogo faz gravações automáticas durante a partida.”
A resposta está na 114 e o documento do recorte guarda o conteúdo aprovado.
O aceite fecha a DEFINIÇÃO; não autorizou implementar nem publicar outro PR.
Não reabra o aceite do recorte. O próximo passo é a autorização específica
de implementação pelo Bruno; não comece a codar sem ela. Publicação exige
autorização própria. Nenhum código do jogo mudou neste fecho.

Recorte aprovado: Como jogar na tela inicial e na pausa; conteúdo
compartilhado, seis assuntos (atracar, avançar dia, dinheiro/semana,
salvar/retomar, devolver/cancelar e fases/metas) mais glossário. Artigo
volta ao índice; índice volta à origem, mantendo a pausa. Consulta não
altera partida, RNG, save ou registro. Números vêm das regras reais.
Não repete o tutorial, não cria resumo de retomada nem funções novas de
salvamento. Textos e critérios de máquina, leitura e telefone estão no
documento. Aceite da definição não comprova uma interface ainda inexistente.

O commit local 71613f6, posterior ao merge, foi preservado na branch
codex/implementar-cancelamento-servico; o fecho do aceite vem depois dele,
também local, sem push ou novo PR. Confira git status/log e os commits
fora da main antes de reapontar. Preserve a pasta .evidencias/ não rastreada.
O briefing docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-10-15e.md registra
as verificações locais desta sessão em .evidencias/aceite-como-jogar/.

Cancelamento de serviço já está na main (111, implementação 5353644):
barco iniciado sai definitivamente, doca e trabalhador livres no mesmo dia,
sem pagamento parcial, −5 de reputação e multa de 10% do acordo sem bônus,
arredondada para cima. Confirmação mostra custos e saldo. Saldo negativo
permitido até o fecho; save 18 migra 17→18, registro 5 e contas integrados.
Preserve docs/arquivo/VERIFICACAO_CANCELAMENTO_2026-10-15/ e
docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/. A importação tem
Safe save failed, sem causa isolada; não a declare limpa. O briefing
2026-10-15d registra os avisos locais da fumaça e o critério do CI.

Preserve docs/PESQUISA_RECURSOS_BASICOS_2026-10-15.md e
docs/REVISAO_RECURSOS_BASICOS_2026-10-15.md: propostas, fontes, inventário
e falhas de save continuam úteis. Publicá-los não autorizou implementar
a lista. Resumo de retomada continua a sugestão seguinte, sem aceite
de implementação. Tela inicial, autosave, três espaços, pausa e Salvar
e sair já existem; a ajuda não promete escrita verificada, exportação
ou recuperação que o jogo ainda não oferece.

Não é cancelamento de obras nem nova etapa da Fase 2. Mais trabalhadores
e crédito voluntário ficam para depois; tutorial e segunda chance já feitos.
A4 e caderno reescrito seguem sem aceite. Preserve codex/corrigir-nomes-web
(107, commit local 0a0ab5c) separada: sem autorização de publicação e sem
teste de digitação no telefone. Ao encerrar, aplique /fechar-sessao e entregue
o prompt completo da próxima conversa em bloco copiável, como exige AGENTS.md.
```
