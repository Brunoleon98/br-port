# 145 — Revisor de mensagens em contexto

30/10/2026. Bruno pediu um bot ou algo parecido para revisar se as mensagens
são agradáveis e se encaixam no jogo. A primeira versão é uma skill acionada
na conversa, disponível para Claude e Codex, com um preparador local de fontes.
Não há serviço em segundo plano, hook de commit ou API externa configurados.
A pergunta opcional sobre acionamento pelo chat versus a cada alteração ainda
não recebeu resposta; seguiu-se o padrão de revisão pelo chat, já informado.

## O revisor

A fonte dos critérios é `.claude/skills/revisar-mensagens/SKILL.md`; a entrada
do Codex em `.agents/skills/revisar-mensagens/SKILL.md` aponta para ela.
`tools/preparar_revisao_mensagens.py` prepara o catálogo narrativo integral,
inclusive modelos locais de funções, e o contexto das chamadas e mensagens
operacionais. Não pontua a qualidade por regex nem chama isso de revisão
semântica: essa leitura é feita pelo assistente que executa a skill.

O pacote tem fontes numeradas, hashes, commit, branch e indicação de árvore
suja. A extração por funções é uma ajuda de navegação; não prova que uma fala
foi vista nem cobre todo rótulo da interface. O relatório precisa declarar
quais cenas foram lidas, separar fato, risco de interpretação e gosto, citar
trecho/gatilho e propor uma redação sem alterar o jogo automaticamente.

O foco atual continua sendo vínculo. Chave e almoço aceitos são referências
a preservar, não novos pedidos de aceite. Uma fala do rival pode ser áspera
e cumprir sua função; o revisor não deve tornar todas as vozes simpáticas
iguais. «Agradável» não ganha nota global nem aprovação de CI. Leitura humana,
captura e testes de estado respondem a perguntas diferentes.

## Primeira aplicação e convivência

Primeiro parecer em `docs/arquivo/REVISAO_MENSAGENS_2026-10-30/README.md`;
contexto gerado em `/tmp/brport-revisao-mensagens`. Foram lidos história,
visitas, apresentação das compras e dois alertas da Cida; o restante do
catálogo está preparado, mas não foi declarado revisado.

Branch `codex/revisor-de-mensagens`, preservando os commits locais de história.
Incorporada a main `0a2e16f`, sem alterar a frente gráfica. A decisão de
história foi renumerada de 141 para 144: os carros da viela chegaram à main
como 141. Nosso briefing de 25/10 passou de `b` para `d`, preservando também
o briefing `b` do Claude. Os logs brutos antigos conservam a numeração que
tinham quando foram produzidos.

Nenhuma fala, preço, gatilho ou save foi reescrito por este revisor. A única
mudança nos scripts já existentes desta sessão é a referência de decisão em
comentários. Publicação/PR não foram pedidos.
