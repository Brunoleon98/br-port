# 115 — Como jogar e glossário compartilhados

**15/10/2026.** Depois de aprovar só a definição na `114`, Bruno perguntou
o que fazer a seguir. À pergunta específica **«Você autoriza começar essa
implementação?»**, respondeu **«Sim»**. Isso autoriza implementar o recorte
aprovado; não autoriza publicar outro PR.

## Base e preservação

`git fetch origin main` confirmou `f03302d`, sem PR aberto no GitHub. A main
tem decisões até a `112`; `113` e `114` estavam nos commits locais
`71613f6` e `3236d0a`. A `115` era livre. A branch
`codex/implementar-como-jogar` parte desse estado, descendente da main,
preservando os fechos e a branch anterior. A `107` permanece separada em
`codex/corrigir-nomes-web`, commit `0a0ab5c`, sem autorização de publicação
nem teste de digitação no telefone. Próxima decisão após esta: `116`, a
reconferir na main e nas branches em trabalho.

## A implementação

As entradas aprovadas aparecem entre Carregar e Ajustes na inicial, ou entre
Nova partida e Ajustes sem save, e entre Continuar e Ajustes na pausa.
Continuar conserva o destaque. Ambas abrem `PainelComoJogar.tscn`, da família
`PainelNarrativo`, com um único `ConteudoComoJogar.gd` para os seis assuntos
e o glossário. Não há dependência de ter uma partida salva.

Artigo volta ao índice; índice fecha para a origem. Botões e Voltar do
aparelho seguem o mesmo caminho, inclusive na pausa do fim da partida.
A pausa permanece aberta. Posição de leitura e foco são conservados dentro
da consulta; reabrir começa no índice, sem posição gravada no save. Pedidos
repetidos não duplicam o painel, e o escurecimento intercepta os toques.

O texto é o aprovado na `114`, inclusive a frase do autosave. Espaços,
cobranças e custos do cancelamento vêm das regras reais. A ajuda só lê:
não avança dia, altera estado, sorteia, grava ou registra eventos. Não muda
`GameState.gd`, constantes de economia, versão de save, viewport, sementes,
tutorial ou caderno. Não acrescenta resumo de retomada, cancelamento de
obras, trabalhadores extras, crédito ou promessa nova sobre salvamento.

## Provas e limites

O T25 integra a suíte de lógica: consulta pelas duas portas, com e sem save,
Fase 1, Fase 2, serviço iniciado, saldo negativo, jogo livre e fim da partida.
Compara estado, RNG, arquivos e registro antes/depois. Testa os dois caminhos
de volta, reabertura, posição de leitura, duplicação e toques com controles
positivos antes/depois. Três proporções verificam índice, fim da rolagem e
retorno alcançáveis. Contraste inclui índice, artigo e glossário; a bateria
fotografa esses três tempos pelas duas portas, usando a pausa de partida jogada.

Resultados, controles semânticos, capturas olhadas e limitações ficam em
`docs/arquivo/VERIFICACAO_COMO_JOGAR_2026-10-15/README.md`.
As seis suítes passaram; o T25 final aprovou 352 verificações. Seis defeitos
semânticos foram rejeitados com restauração e controle saudável entre eles.
Contraste sem reprovação/pendência em 713 textos e 39 estados; bateria com
85 imagens e cobertura completa dos 21 painéis e 16 tempos. Dez imagens da
ajuda foram olhadas, incluindo quadros de prova de proporção/fim da rolagem.
As provas de máquina não fecham a leitura por pessoa nova nem o telefone.
O A4 e o caderno reescrito continuam sem aceite. A limitação anterior de
importação `Safe save failed` segue sem causa isolada; não é declarada resolvida.
Pesquisa, revisão e pacotes selados do cancelamento foram preservados.

Esta entrega fica local, sem push ou novo PR. Antes de publicar, obter a
autorização específica; antes de recomendar merge, conferir CI do novo head.
