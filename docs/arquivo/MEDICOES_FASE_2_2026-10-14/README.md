# Medição da Fase 2 — 14/10/2026 (`108`)

Base `92862ef7640081c4707377422a99ee91d6115f74`, main com PR #130 fundido.
Godot 4.6.3, quatro perfis herdados do simulador, 600 partidas por perfil,
semente 20260825. Baseline e dez variações: **26.400 partidas** completas
desde o dia 1, cada uma observada por até 365 fechos na Fase 2.

A janela termina a observação, não o jogo. Sem meta e ainda vivo significa
censura. Dias até a meta são quantis empíricos condicionados às conquistas,
com índices `int(n × 0,1)`, `int(n / 2)` e `int(n × 0,9)` após ordenar.
As mesmas sementes emparelham partidas entre cenários; não são uma amostra
da população humana. Escolhas e motivos estão na decisão `108`.

| Arquivo | Conteúdo |
|---|---|
| `resumo.json` | Configuração da base, resumo por perfil e parâmetros/resultados das dez variações |
| `partidas.zip` | JSONs completos, incluindo cada partida, paridade de autosave, Fase 1, constantes e controle de quebra |
| `manifesto.json` | Tamanho e SHA-256 de cada JSON dentro do ZIP |
| `conferir_medicao.py` | Leitura independente em Python; recalcula resumos e confere dias, marcos e contabilidade |
| `paridades.json` | Comparação integral de JSON com/sem autosave e da Fase 1 com a medição anterior |
| `mutantes.json` | Defeitos semânticos recusados pelo T23 e fonte restaurada aprovada |
| `forcar_quebra.gd` | Controle que injeta caixa negativo na bancada e usa o fecho real; não é cenário de balanceamento |
| `verificacoes.zip` | Logs, importação, suítes, projetor, guardas e scripts da bancada Windows |
| `verificacao.json` | Conferência final dos ZIPs, marcadores das seis suítes, sentinela e paridades |

## Reproduzir

```sh
godot --headless --path brport_vs --script res://tools/medir_fase_2.gd \
  -- 600 20260825 /tmp/fase-2.json 365 --sem-save
python3 docs/arquivo/MEDICOES_FASE_2_2026-10-14/conferir_medicao.py /tmp/fase-2.json
```

Exigir `FASE 2 MEDIDA`, saída zero e ausência de `SCRIPT ERROR` e
`at: push_error (`. O conferidor também se testa: um resumo adulterado e um
dia de conquista adulterado, separadamente, precisam reprovar. Para o
autosave, rodar novamente sem `--sem-save`, com as mesmas sementes.

Nas seis suítes também se exige o marcador de cada uma e ausência de erro
de script/`push_error`. Avisos de recursos ainda vivos na saída e os erros
de JSON propositalmente inválido da fumaça são os já conhecidos do projeto;
não foram usados para dispensar os marcadores ou a varredura de erros.

Os scripts da bancada registram caminhos locais e o ambiente utilizado;
para repetir a varredura em outra máquina, ajustar o executável e usar um
perfil de ferramentas isolado. Cada cenário muda só sua família de
parâmetros, roda os quatro perfis e restaura o GameState em `finally`. Os
hashes da fonte de cada variante estão no resumo. Os três preços variam
juntos: não atribuir seu efeito a uma estrutura isolada.

Os controles `quebra-forcada.json` e `quebra-apos-meta.json` injetam caixa
negativo na bancada, antes da meta ou apenas depois dela (`--apos-meta`).
Exercitam o desfecho real e a classificação, sem estimar risco financeiro.
O Descuidado da amostra curta não conquista e continua censurado no segundo
controle. A injeção não é receita/despesa de jogo e não deve ser usada em
comparações de margem operacional.

## Leitura da base

| Perfil | Meta / entradas | Dias P10 / P50 / P90 entre conquistas | Censuradas |
|---|---:|---:|---:|
| Ótimo | 600 / 600 | 12 / 15 / 20 | 0 |
| Mediano | 600 / 600 | 22 / 36 / 54 | 0 |
| Descuidado | 12 / 600 | 335 / 345 / 362 | 588 |
| Antecipado | 600 / 600 | 29 / 41 / 57 | 0 |

Todos entraram no dia 85. Zero quebras antes ou depois da meta na janela;
zero travamentos. O Descuidado não alcançou uma mediana de tempo até a meta
na população inteira; 345 descreve apenas as 12 conquistas. Seu mínimo de
caixa mediano foi R$136.856 e passou uma mediana de 342 fechos abaixo do
piso. A baixa pressão financeira observada não prova risco nulo nem
dispensa playtest no telefone. Preços e patamares atuais foram mantidos.

Não houve mudança visual, de texto do jogo, de save ou de valores numéricos.

## Varredura

Medianas abaixo usam somente conquistas. Nos três outros perfis, cada cenário
teve 600/600 conquistas; no Descuidado, conferir o denominador da coluna.
Não houve quebra nem travamento em nenhum dos dez cenários.

| Cenário | Metas do Descuidado / 600 | Ótimo | Mediano | Descuidado, só conquistas | Antecipado |
|---|---:|---:|---:|---:|---:|
| precos-metade | 228 | 15 | 23 | 330 | 23 |
| precos-mais-50 | 0 | 15 | 68 | — | 71 |
| meta-70 | 29 | 8 | 24 | 352 | 29 |
| meta-90 | 6 | 22 | 47 | 356 | 52 |
| piso-20 | 3 | 15 | 36 | 344 | 41 |
| piso-60 | 31 | 15 | 35 | 352 | 39 |
| inicio-55 | 38 | 22 | 47 | 357 | 52 |
| inicio-75 | 2 | 8 | 24 | 357 | 29 |
| obras-curtas | 17 | 14 | 36 | 356 | 41 |
| obras-longas | 10 | 16 | 35 | 355 | 41 |
