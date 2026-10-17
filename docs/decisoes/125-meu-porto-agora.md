# 125 — Meu porto agora, antes de entrar no porto

**17/10/2026.** Bruno escolheu RB2 e autorizou implementar o recorte
apresentado: Continuar e Carregar mostram uma consulta antes de criar o
porto. O Claude trabalha no visual. Esta frente evita `Main.gd`,
`Main.tscn` e `GameState.gd` e concentra conteúdo, painel e casos de teste
em arquivos próprios, com integração na tela inicial.

## Recorte autorizado

- Nome, fase/dia/semana, caixa, obra com prazo real e serviços contratados
  com progresso, duração guardada e receita das consultas existentes.
- Cobrança só onde existir: recibo antecipado não vira dívida em aberto;
  parcela seguinte é futura. Fase 2 sem dívida e sem prazo, meta existente
  de três critérios. Meta concluída é jogo livre, sem objetivo novo.
- Ir ao porto segue ao fluxo existente, inclusive decisões pendentes e
  desfecho. Voltar ao início e Voltar do aparelho dispensam a consulta.
  Nova partida conserva sua abertura. Sem atalhos diretos neste recorte.
- A consulta depois da carga não altera estado, RNG, dinheiro, progresso,
  missão, save ou registro. Sem recomendações, histórico ou preferências.

`usar_espaco()` não retorna sucesso e pode criar partida nova na falha.
A integração precisa distinguir a carga bem-sucedida para não apresentar
partida nova como retomada; isso não autoriza ampliar as funções de save.

## Verificação e entrega

Implementação em andamento na branch `codex/meu-porto-agora`, publicada
cedo em PR rascunho para tornar esta reserva visível. Casos novos próprios,
defeitos persistentes em `tools/mutantes.toml`, suítes, evidência visual e
pré-PR serão conferidos antes da entrega. Sem merge automático.

Leitura por pessoa nova, telefone, A4 e caderno continuam pendentes. A
decisão 107 permanece local e separada; o `Safe save failed` histórico
continua sem causa isolada. As evidências anteriores são preservadas.
