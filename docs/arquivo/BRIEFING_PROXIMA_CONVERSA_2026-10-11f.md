# BR Port — briefing para a próxima conversa (11/10/2026, f)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md e a §7 do plano v3.

Confira na main pelo GitHub se o PR do M11 foi fundido (branch
claude/brave-brahmagupta-puciam: o Web no Pages, o medir_desempenho.gd, a
pasta playtest/ e a decisão 099) e se há PR aberto do Codex antes de editar.
A última decisão é a 099; confira o próximo número livre na main antes de
usar. Se o PR foi fundido, olhe o job «Publicar no Pages» da corrida da main:
verde quer dizer que o Bruno trocou a fonte do Pages para «GitHub Actions»;
vermelho, que falta — diga-lho.

A fila de melhorias parou: o M9 espera o D1b e o M12 o A8. Volta a frente 5,
pelo tutorial curto que o Bruno escolheu em 11/10. Comece pela pergunta de
quem guia — o GDD pede o Toninho, que o jogo não tem, e a Dona Cida já tem
rosto —, com opções e a recomendada primeiro, e desenhe o recorte antes de
codar. Faça um item só.
```

O M11 fechou na parte de máquina (`099`): o `testes.yml` publica no Pages o
Web da `main` com as suítes e o export verdes, com o protótipo em
`/prototipo/`; a régua `brport_vs/tools/medir_desempenho.gd` mediu 273
chamadas de desenho no dia 1 e 469 no exemplo do dia 30, com 0,014 ms de
script por quadro; e as partidas reais do A7 vão para `playtest/`. Falta o
FPS do Bruno no telefone, pelo link do Pages.

⚠️ O tempo de quadro do motor não se lê neste contêiner — sob `xvfb-run`
inclui o desenho por software, em `--headless` o laço dorme —, e a régua
cronometra a chamada direta (`.claude/rules/plataforma.md`, `099`).

⚠️ O build Web prova-se aqui sem telefone: só os `web_*` dos templates,
servido sem cabeçalho nenhum e aberto no Chromium do contêiner
(`.claude/rules/plataforma.md`).

⚠️ Ferramenta que chame um virtual do motor em qualquer nó chama-o direto num
destipado: por string, o F19 reprova e a declaração não o sabe dizer (`099`,
o comentário de `_custo_us` em `brport_vs/tools/medir_desempenho.gd`).
