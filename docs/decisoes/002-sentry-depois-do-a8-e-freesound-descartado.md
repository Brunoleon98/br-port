# 002 — O Sentry fica para depois do A8, e o Freesound está descartado

**Data:** 01/09/2026 · **Decisão de:** Bruno · **Estado:** fechadas as duas

> Duas decisões sobre ferramenta externa que existiam só numa conversa. É
> exatamente o caso que o passo de varredura do `/fechar-sessao` procura: o que
> se decidiu e não ficou escrito em lugar nenhum.

---

## 1. O Sentry — aprovado, mas só depois do A8

**Decisão:** o Sentry entra no projeto **depois do A8** (publicar no itch.io),
e não antes. Quando entrar, é pelo caminho oficial: o MCP em `mcp.sentry.dev`
e o SDK oficial para Godot. Nada de integração caseira.

**Por quê depois.** O Sentry serve para saber o que quebra na mão de quem
joga. Antes do A8 não há ninguém jogando fora daqui: o jogo não está publicado,
o único playtest é o do Bruno, e um relatório de erro de uma máquina só é uma
coisa que já se vê no terminal. Instalá-lo agora seria pagar integração,
configuração e uma dependência nova para observar uma população de um.

Depois do A8 a conta inverte-se — aí há partidas que ninguém aqui vê, e é
precisamente o que a Fase 5 ("Testes e correções") precisa de medir.

**Medido em 01/09, e vale registrar porque muda o plano de instalação:**
`mcp.sentry.dev` **não é alcançável deste contêiner** — a política de rede do
ambiente responde 403 ao CONNECT, o mesmo que o Freesound leva abaixo. Ou seja,
quando chegar a hora, ligar o MCP do Sentry vai exigir mexer na política de
rede do ambiente, não só criar conta. Não é bloqueio para a decisão (que é
sobre *quando*), mas é trabalho que ninguém tinha contado.

## 2. O Freesound — descartado

**Decisão:** o Freesound **não** é fonte de áudio para este projeto.

**Por quê, e isto é medição e não suposição:** a política de rede deste
ambiente bloqueia `freesound.org`. O proxy responde **403 ao CONNECT**, e o
próprio proxy regista a recusa:

```
$ curl -sS -o /dev/null -w "%{http_code}\n" https://freesound.org/
curl: (56) CONNECT tunnel failed, response 403

$ curl -sS "$HTTPS_PROXY/__agentproxy/status"
  "recentRelayFailures": [
    { "kind": "connect_rejected",
      "detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)",
      "host": "freesound.org:443" } ]
```

Confirmado de novo em 01/09/2026. Não é intermitência de rede: é política, e
uma sessão que dependesse disso descobriria o bloqueio no meio do trabalho de
áudio, que é o pior momento.

**O que fica no lugar dele.** Nada muda: o caminho de áudio do projeto já
estava decidido e não passava pelo Freesound. Os dez efeitos de rascunho saem
de `tools/gerar_sons.py` (sem dependência nenhuma, só biblioteca padrão) e o
áudio final vem do Suno/ElevenLabs, trocando arquivo por arquivo sem tocar em
código — ver `docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md` e
`docs/BLOCO6_BRIEFING_AUDIO.md`.

**O que este registro protege:** que alguém volte a propor o Freesound daqui a
um mês e gaste meia sessão a descobrir sozinho o mesmo 403.

---

*BR Port · decisão 002 · registrada na sessão que fechou o B1 e o A2.*
