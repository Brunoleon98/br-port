# Próxima conversa — revisor de mensagens

30/10/2026. Branch `codex/revisor-de-mensagens`, baseada nos commits locais
de história e atualizada com `origin/main` em `0a2e16f`. Bruno pediu um bot
para avaliar se as mensagens são agradáveis e se encaixam no jogo.

## Entrega

Skill canônica `.claude/skills/revisar-mensagens/SKILL.md` e entrada para
Codex em `.agents/skills/revisar-mensagens/SKILL.md`. Prepara-se o contexto com
`python3 tools/preparar_revisao_mensagens.py --saida /tmp/brport-revisao`.
O assistente da conversa faz a leitura e escreve o parecer. Não é serviço
automático nem uma chamada a outra API. Pergunta opcional sobre chat/checagem
a cada alteração sem resposta nesta rodada; foi seguido o padrão pelo chat.

Primeiro parecer em `REVISAO_MENSAGENS_2026-10-30/README.md`, com 15 unidades
editoriais analisadas e seis recomendações. Manifesto registra 31 fontes e
70 trechos preparados, sem afirmar que foram todos revisados. Achados novos:
a fala da reputação pode atribuir recusa a outra causa de perda; «fecha a
semana» pode ser lido como previsão que o gatilho não garante. Mesa do Mané,
envelope e descrições das compras reconfirmam pontos da revisão anterior.
Caneca, café, chave e almoço são referências a manter.

## Base preservada e números

A história, antes decisão 141, passou a 144 porque a main recebeu carros da
viela como 141. O briefing nosso de 25/10 passou de `b` para `d`; ambos os
registros do Claude foram preservados. Logs brutos antigos mantêm a numeração
original. Decisão do revisor: 145. A branch anterior de história não foi
reapontada: continua preservada; a nova branch contém os commits dela como
dependência local. Nenhum PR foi criado com as duas entregas misturadas.

As falas aceitas da chave/almoço continuam no jogo local. Nenhuma fala,
gatilho, preço ou save foi alterado pelo revisor. O restante da escrita e o
retorno das lojas seguem propostas.

## Verificação

Seis testes Python do preparador: catálogo integral e texto local, condições
do chamador, fonte ausente, repetibilidade/hash, modo de arquivo e falha de
substituição sem truncar o anterior. Seis suítes Godot verdes, 58 s; tabela
conferida após renumerar comentários, sem diferença. Detalhes em
`REVISAO_MENSAGENS_2026-10-30/VERIFICACAO.md`.

Sem nova captura ou playtest, pois o revisor não mudou a interface. Sem push,
PR, CI remoto desta entrega ou publicação. O parecer distingue fato estático,
risco e opinião; não conclui frequência de ocorrência ou teste no telefone.

## Prompt para colar

```text
Retome /workspace/br-port na branch codex/revisor-de-mensagens.
Leia AGENTS.md, docs/ESTADO_DO_PROJETO.md e as decisões 144 (história) e 145 (revisor).
Use a skill .claude/skills/revisar-mensagens/SKILL.md.
Leia o primeiro parecer em docs/arquivo/REVISAO_MENSAGENS_2026-10-30/README.md.
O revisor funciona pelo chat; nenhuma sugestão foi aplicada às falas.
Chave e almoço já estão aceitos e integrados. A parte gráfica continua com Claude.
Vamos tratar os apontamentos ou continuar a revisão das famílias que faltam.
```
