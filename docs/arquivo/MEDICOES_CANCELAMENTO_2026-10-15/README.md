# Medição experimental do cancelamento — 15/10/2026

Autorização: medir a proposta `109`; desenho, resultados e limites na
decisão `110`. Base `82a9df0`, Godot **4.6.3**, semente **20260825**,
600 partidas por perfil e 365 fechos de observação na Fase 2.

São 31.200 partidas na amostra principal: referência main e doze cenários
experimentais, cada um com quatro perfis. A janela limita a observação,
não o jogo. Sem meta e vivo ao final é censura, não derrota. O tempo até
a meta é condicionado às conquistas; confira sempre o denominador.

## Conteúdo

| Arquivo | Conteúdo |
|---|---|
| `resumo.json` | Resumos recalculados, quantis, oportunidades, custos e diferenças emparelhadas |
| `partidas.zip` | JSONs integrais por partida, eventos e amostras de paridade |
| `manifesto.json` | Tamanhos e SHA-256 dos arquivos dentro dos ZIPs |
| `verificacoes.zip` | Logs das corridas, controles, mutantes e seis suítes |
| `verificacao.json` | Paridades, controles, proteção do jogador e versão da ferramenta |

Os scripts reprodutíveis estão em `brport_vs/tools/medir_cancelamento.gd`,
`estado_cancelamento_experimental.gd`, `testar_cancelamento_experimental.gd`
e em `tools/{medir,conferir,analisar}_cancelamento.py` e
`tools/testar_bancada_cancelamento.py`.

## Reproduzir

```sh
python3 tools/medir_cancelamento.py --godot /caminho/godot --saida /tmp/cancelamento
python3 tools/analisar_cancelamento.py /tmp/cancelamento
python3 tools/testar_bancada_cancelamento.py --godot /caminho/godot --saida /tmp/controles
```

Exigir código zero, marcador final e ausência de `SCRIPT ERROR` ou
`at: push_error (`. Executar Godot em série: suas ferramentas compartilham
dados locais. Para paridade, rodar uma amostra com e sem `--com-save`,
mantendo cenário, semente, tamanho e janela iguais, e comparar os JSONs
inteiros. Não é prova de retomada do cancelamento num save novo.

O conferidor independente recalcula os resumos e verifica cada multa,
reputação, saldo, nota da alternativa, população e quantil. Deve recusar
adulterações de multa, população, nota e quantil. Os controles de estado
devem reprovar com multa ausente, reputação ausente, trabalhador preso e
perda duplicada; a fonte restaurada deve passar entre cada mutante.

O experimento não está ligado à interface ou ao autoload. Não alterou
preços, patamares, save, registro, arte ou narrativa do jogo. O boletim de
multas e a migração são parte da implementação futura, ainda sem aceite.
Os dados experimentais não certificam a compreensão humana nem o equilíbrio
de todas as estratégias possíveis. A `107` móvel permanece separada.

**Limitação registrada:** a importação do Godot retornou zero, mas avisou
`Safe save failed` mesmo com o helper seriado do CI e em modo detalhado.
Não foi considerada limpa; o arquivo afetado e a causa não foram isolados.
Os logs estão no ZIP e a nota está na `110`. As seis suítes, as medições
e os controles passaram; são verificações diferentes.
