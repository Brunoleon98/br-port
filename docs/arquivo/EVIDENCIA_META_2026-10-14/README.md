# Evidência da meta da Fase 2 — 14/10/2026

Etapa 3 da `103`, decisão `106`. Godot 4.6.3, 720×1280, passo fixo 60,
semente 20260902. `capturar_fase_2.gd` joga desde o dia 1, compra com receita
real, toca nos painéis e não avança sob modal. Nenhuma injeção de dinheiro,
reputação ou estruturas. As imagens foram olhadas.

| Imagem | Estado alcançado |
|---|---|
| `meta_fase_2.png` | Dia 91, reputação 70, infra pronta e dois cargueiros atendidos; falta reputação |
| `diario_fase_2.png` | Dia 100, reputação 84, conquista automática na página do caderno |
| `livre_fase_2.png` | Dia 100, página fechada, porto vivo, R$520.131, nove cargueiros atendidos |
| `suspenso_fase_2.png` | Dia 104, reputação 35 após deixar clientes desistirem; aviso do piso 40, barcos anteriores preservados |
| `construir_fase_2.png` | Dia 91, escritório em obra; regra do piso no Construir |

`controles.json` reúne marcadores das seis suítes, paridade da Fase 1 e oito
defeitos injetados. Cada mutante foi seguido de uma corrida verde com a cópia
da base restaurada, sem erro de compilação. `t22-final.log` e `f10-final.log`
mostram os caminhos de lógica/tela e a medição com o nome mais largo.
Os logs de captura registram cenas, dia, estruturas, saldo e imagem gravada.

A conquista desta semente não mede balanceamento: os patamares e o tempo até
a meta por perfil continuam para a etapa 4 da `103`.

`importacao-ci.log` registra a correção do import intermitente no PR #130:
leitura da chave de paralelismo pelo Godot real, fonte importada, limpeza
após sucesso/falha, preservação de override existente e mutante `true`
reprovado seguido de base verde. Os cinco imports do CI usam o helper.
