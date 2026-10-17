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

Implementação na branch `codex/meu-porto-agora`, PR #140 em rascunho,
publicado cedo para tornar esta reserva visível. Casos próprios T27 e
defeitos `retomada-*` persistem no catálogo oficial. O pacote
`docs/arquivo/VERIFICACAO_MEU_PORTO_2026-10-17/README.md` reúne a verificação,
as capturas, as limitações e o prompt de retomada. Sem merge automático.

## Colisão posterior com o PR #141

O PR visual do Claude foi publicado depois da reserva e também criou uma
decisão 125. O pré-PR contra ele apontou colisão no catálogo e nos documentos
de fecho; terminou com traceback ao tentar ler TOML com marcadores de
conflito. Isso não é `COLABORACAO OK`. A checagem separada contra a main
passou, mas não substitui a comparação com o #141.

Perguntado sobre renumerar esta decisão e ajustar apenas nossas linhas nos
arquivos compartilhados, Bruno respondeu **“Deixe como está”**. A numeração
e esses arquivos ficam preservados nesta entrega; a integração entre os
dois PRs permanece pendente. Não se funde o trabalho visual nem se corrige
o conferidor nesta frente. O fecho e o prompt ficam no pacote próprio já
indexado, sem novo briefing que exija alterar o índice compartilhado.

Leitura por pessoa nova, telefone, A4 e caderno continuam pendentes. A
decisão 107 permanece local e separada; o `Safe save failed` histórico
continua sem causa isolada. As evidências anteriores são preservadas.
