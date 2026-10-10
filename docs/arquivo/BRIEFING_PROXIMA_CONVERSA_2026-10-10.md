# BR Port — briefing para a próxima conversa (10/10/2026)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR desta revisão foi fundido (branch
ccr-3ac04f71-52brr7: a revisão, a revisão do PR #110, o teste_design que
deriva o estado, o .gitattributes com LF e a guarda do número de decisão) e
se há PR aberto do Codex antes de editar. A última decisão é a 087; confira
o próximo número livre na main antes de usar.

Faça o PRIMEIRO item aberto da fila, e só ele. Hoje é o M1: o gravador de
partida (Registro.gd) passa a gravar a obra PRONTA (sinal obra_concluida)
além da paga, o cabeçalho grava turnos_por_semana, e o tools/ler_registros.py
mostra dia pago e dia pronto e tira as semanas do cabeçalho em vez de t <= 8
e t > 24. Registro antigo sem o campo: o leitor diz que não sabe, não supõe.
A prova está escrita no M1 (teste_registro com mutante; fixture de 84 dias).

Item com [decisão] na fila só começa depois da resposta do Bruno à pergunta
da §6.0 que o destrava.
```

⚠️ A guarda nova escolhe o defeito injetado e o vê reprovar antes de valer —
e o defeito tem de chegar a quem o vê (`CLAUDE.md`, regra 7 do fecho).

⚠️ Registro e leitor: `.get(chave, omissão)` transforma ausência em número
plausível; o campo novo lê-se direto ou recusa (`CLAUDE.md`, Estilo de código).

⚠️ Capturas e suítes partilham `user://ferramentas/`; não rode as duas juntas
(`CLAUDE.md`, «Como rodar»).

⚠️ Prova de que uma suíte não depende do disco pede saves da versão ATUAL, que
o jogo aceite: um save recusado testa nada (`REVISAO_GERAL_2026-10-09.md`, §4).

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
