<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📰 Consistência dos Gatilhos — Bela

> Quando ela avisa, quando publica, quando investiga

*A Bela não é previsível. Mas tem regras. Você descobre as regras antes de ela te pegar de surpresa.*

**📢 Quando ela avisa antes de publicar** — Condição: reputação com Bela acima de 65. O aviso chega como diálogo 48h de jogo antes da publicação. O conteúdo é vago ('tem uma matéria sobre o cais saindo na sexta'). Acima de 80: o aviso é mais específico ('é sobre a carga de outubro — você quer comentar?'). Abaixo de 65: o jogador descobre junto com a cidade.

**🔍 Quando ela investiga o próprio jogador** — Gatilho: reputação com Bela abaixo de 40 E pelo menos um dos seguintes: carga sem nota aceita mais de duas vezes, traição de aliança testemunhada por NPC, corrupção com prefeitura aceita. A investigação dura 2 semanas antes de publicar. Durante esse período ela faz uma pergunta direta — resposta honesta interrompe a investigação mas custa 10 pontos de reputação. Resposta evasiva: matéria sai com 20% mais impacto.

**📅 Frequência e timing das matérias** — Publicação toda semana de jogo, sempre na sexta. Ato 1: maioria das matérias são sobre a cidade — o porto só aparece se algo notável ocorreu. Ato 2: porto aparece toda semana, positivo ou negativo. Ato 3: as três investigações independentes convergem. Sem matéria em semana de evento especial (Carnaval, Festa de São Pedro) — a cobertura do evento substitui.

**💡 Informação antecipada sobre rivais** — Condição: reputação com Bela acima de 70. Ela avisa sobre bloqueio de fornecedor do Grupo Atlântico em 60% das ocorrências (não 100% — ela não é onisciente). Avisa sobre lobby de Arlindo na prefeitura em 40% das vezes. O aviso chega como nota no jornal ou diálogo direto. Abaixo de 70: o jogador descobre o bloqueio quando o fornecedor já fechou com o Atlântico.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
