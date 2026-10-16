# 114 — O aceite do recorte de Como jogar e glossário

**15/10/2026.** Bruno respondeu **«Aprovar o recorte com esse ajuste
(recomendado)»** à pergunta que apresentava o recorte completo da `113` e
substituía a frase do autosave por **«O jogo faz gravações automáticas
durante a partida»**. A pergunta delimitava expressamente: este aceite
fecha apenas a definição; implementação e publicação de outro PR dependem
de autorização própria. Nenhum código do jogo foi alterado.

**Continuação:** após o fecho deste aceite, Bruno autorizou implementar o
recorte ao responder «Sim» à pergunta específica. A implementação local está
na `115`; publicar outro PR continua sem autorização. O texto abaixo conserva
o limite do aceite de definição que antecedeu essa nova autorização.

## Base reconferida antes de editar

`git fetch origin main` confirmou `f03302d`, merge do PR #133, também
confirmado no GitHub. Não havia PR aberto. Testes `38773108323`, Captura
`38773108305` e Pages `38773106178` do merge seguem concluídos com sucesso.
A main contém decisões até a `112`; a `113` estava no commit local
`71613f6`, posterior ao merge, na branch
`codex/implementar-cancelamento-servico`. Esse commit foi preservado, sem
reapontar a branch. A `107` permanece separada em
`codex/corrigir-nomes-web`, commit `0a0ab5c`. A `114` era o próximo número
livre conferido; depois deste registro, a próxima é `115`, sujeita a nova
conferência remota e das branches em trabalho.

## O conjunto aprovado

`docs/RECORTE_COMO_JOGAR_GLOSSARIO_2026-10-15.md` passa a guardar a definição
aprovada: Como jogar na tela inicial e na pausa, conteúdo compartilhado,
seis assuntos de jogo e glossário, textos e critérios de aceite. Artigo
volta ao índice; índice volta à origem e conserva a pausa. A consulta não
altera partida, RNG, save ou registro. Números devem vir das regras reais.

O único ajuste ao conteúdo proposto foi a frase sobre gravações automáticas,
para não sugerir que toda ação de consulta gera uma escrita. Salvar e sair
continua descrito como pedido de gravação; não se promete escrita verificada,
exportação nem recuperação. As falhas da revisão e o `Safe save failed` da
importação, sem causa isolada, continuam pendentes.

## O que este aceite não fecha

Implementação, publicação, provas de máquina, leitura e teste no telefone
continuam por fazer ou autorizar, conforme o documento. Não é aceite humano
de uma interface que ainda não existe. Não se repete o tutorial, cria resumo
de retomada ou acrescenta função de salvamento. Resumo de retomada continua
a sugestão seguinte da pesquisa `112`, sem escolha de implementação.

O cancelamento da `111` já está na main. Seus pacotes selados, a pesquisa e
a revisão de recursos básicos foram preservados. Obras, mais trabalhadores,
crédito voluntário, A4 e o caderno reescrito ficam nas pendências anteriores.
A correção de nomes da `107` continua sem autorização de publicação e sem
teste de digitação no telefone. Este fecho fica local, sem push ou PR novo.
