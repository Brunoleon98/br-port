# Próxima conversa — revisão contextual após validar a entrega

Atualização na continuação: o PR documental #159 terminou com CI verde e foi
marcado pronto para revisão, sem merge. Bruno pediu evitar PRs pequenos.
Na revisão pelo chat, aceitou o envelope («Ficou bom»); a versão de
`docs/REVISAO_FALAS_LOJAS_FASE_1.md` foi aplicada localmente em `Narrativa.gd`,
sem mudar gatilhos. Retorno das lojas continua proposta; é o próximo recorte
possível. O histórico abaixo preserva o handoff anterior; o prompt foi atualizado.

Envelope: seis suítes aprovadas em 51 s; seis falas olhadas em Padrão/Maior
no painel real. Provas locais em `/tmp/brport-envelope-verificacao/`; aceite
e resultados na decisão `146`. O commit local do envelope não foi enviado.

31/10/2026. Branch `codex/revisor-de-mensagens`, sobre a main `d11311b`.
Ler AGENTS.md, estado, §7 do plano e decisões 145–147.

## O que foi conferido

O #158 já estava incorporado no início desta retomada, com head `926eb0b`.
Esta sessão não fez merge. Seus workflows Testes #424 e Captura #376 passaram:
seis suítes, APK/Web, capturas e 263 mutantes (88 + 88 + 87), com agregador
aprovado. Marcadores e links em `REPUTACAO_E_FALAS_2026-10-30/README.md`.
Não se repetiu a execução concluída.

Os dois caminhos locais de `/tmp` e o commit documental `7af5e6d` citados
no pedido não existem neste ambiente novo nem, no caso do commit, no GitHub.
O fecho foi reconstruído com fontes verificáveis; não se atribuiu resultado
à execução local perdida. O complemento documental usa a mesma branch e
um PR próprio, porque o #158 já foi encerrado. Consultar seu head e CI no
GitHub para o resultado final. Sem force, push para main/Claude ou merge.

## Continuação

Bruno prioriza vínculo com os personagens. Chave, almoço e Mané estão
aceitos e aplicados. Envelope e retorno das lojas são propostas.
A próxima rodada do revisor deve ler texto, gatilhos e apresentação em
conjunto, pelo chat, sem reescrever automaticamente. É recomendável agora:
a decisão 147 mudou a fala/gatilho da Cida e a cena do Mané desde o primeiro
parecer. A skill `.claude/skills/revisar-mensagens/SKILL.md` e a decisão 145
definem esse fluxo. Preparar fontes não equivale a uma leitura editorial.
O teste no telefone continua pendente; a parte gráfica segue com Claude.

## Prompt para colar

```text
Retome /workspace/br-port na branch codex/revisor-de-mensagens.
Leia AGENTS.md, docs/ESTADO_DO_PROJETO.md, a §7 do plano e as decisões 145–147.
Leia docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-10-31b.md.
O PR #158 já está incorporado; seu CI passou nas seis suítes e nos 263 mutantes.
O PR documental #159 está pronto para revisão, com CI verde no head fb481d1. Não faça merge.
O envelope foi aceito e aplicado em commit local posterior, ainda não enviado: seis suítes passaram e as falas foram conferidas em Padrão/Maior.
Vamos retomar a revisão contextual pelo chat, com prioridade no vínculo com os personagens.
Chave, almoço, Mané e envelope estão aceitos; retorno das lojas ainda é proposta.
Use a skill revisar-mensagens; leia texto, gatilhos e contexto, apresente sugestões sem aplicar automaticamente.
Evite PRs de coisas menores; reúna o commit local com uma entrega relevante antes de publicar.
A parte gráfica segue com Claude; teste no telefone pendente.
```
