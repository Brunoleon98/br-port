# Verificação de Como jogar e glossário — 15/10/2026

Implementação local da decisão `115`, após definição `114` e autorização
específica do Bruno. Base remota `f03302d`; branch
`codex/implementar-como-jogar`. Sem publicação autorizada.

## Resultado de máquina

Godot **4.6.3**, perfis locais isolados. As seis suítes terminaram com código
zero, seus marcadores finais e sem `SCRIPT ERROR` ou `at: push_error (`:

| Suíte | Marcador |
|---|---|
| Lógica, incluindo T25 | `TODOS OS TESTES PASSARAM` |
| Design | `DESIGN OK` |
| Áudio | `AUDIO OK` |
| Fumaça | `FUMACA OK` |
| Registro | `REGISTRO OK` |
| Assets | `ASSET OK` |

O T25 final também passou isoladamente, com 352 verificações aprovadas.
Exercita inicial com/sem save e pausa na Fase 1, Fase 2 com serviço iniciado,
saldo negativo, jogo livre e fim da partida. Compara variáveis do estado,
RNG, conteúdo e datas dos arquivos, e registro antes/depois. Uma guarda de
fonte adicional rejeita escrita idêntica de save no mesmo segundo. Toques
por coordenada atingem um botão de controle antes/depois e são bloqueados
sob a ajuda. Navegação, reabertura, duplicação, rolagem e retorno visível
também foram conferidos, inclusive em três tamanhos de quadro.

O contraste mediu **713 textos em 39 estados**: 710 aprovados, três inativos
isentos, **zero reprovações e zero pendências**. Escopo de interface,
guardas do CI e documentos passaram com `ESCOPO UI OK`, `GUARDAS OK` e
`DOCS OK`. A sentinela ficou intacta nos cinco arquivos, novamente conferida
depois de todas as capturas. `finais.json` guarda os resultados e os logs
completos ficam ao lado dele neste pacote.

## Capacidade de reprovar

Seis defeitos semânticos foram injetados e rejeitados por asserções, sem
erro de compilação ou script. A fonte foi restaurada byte a byte e o T25
voltou a passar entre os controles: 13 rodadas, incluindo a base.

| Defeito | O que o T25 rejeitou |
|---|---|
| Voltar fecha diretamente o artigo | Perda do índice/painel na navegação |
| Abrir a consulta consome RNG | Mudança no estado do sorteador |
| Abrir a consulta chama save | Porta de escrita indevida e alteração de arquivos |
| Multa mostrada multiplicada por dois | Texto divergente dos custos reais |
| Pedido repetido abre outra ajuda | Contagem de painéis e retorno à pausa |
| Fundo e raiz deixam o toque passar | Botão de baixo recebe durante a consulta |

`controles.json`, logs de cada mutante/restauração e `fontes-restauradas.json`
registram essa rodada. Depois, o filtro do sorteador no teste passou de nome
privado por string para identificação pelo tipo, atendendo ao F19; o T25
final voltou a passar. A primeira fumaça reprovou as antigas listas de botões
do F16 e esse literal do F19. O F16 agora exige as listas exatas aprovadas,
inclusive a posição de Como jogar, e o sinal da pausa. A fumaça foi repetida
e passou. Nenhuma isenção nova foi aberta no inventário de nomes.

## Capturas olhadas

A bateria canônica produziu **85 PNGs**, com código zero, sem erro de script
ou backtrace. `COBERTURA OK`: todos os 21 painéis e os 16 tempos declarados
foram fotografados; nenhuma lacuna. A pausa das imagens abaixo é de partida
jogada, no dia 9, com dois painéis: pausa e ajuda. Os seis PNGs são 720×1280.

| Porta | Índice | Maior artigo | Glossário |
|---|---|---|---|
| Inicial | [índice](ajuda_inicio_indice.png) | [devolver/cancelar](ajuda_inicio_artigo.png) | [glossário](ajuda_inicio_glossario.png) |
| Pausa | [índice](ajuda_pausa_indice.png) | [devolver/cancelar](ajuda_pausa_artigo.png) | [glossário](ajuda_pausa_glossario.png) |

Foram vistos os assuntos completos, custos de 5 pontos e 10%, fonte,
contraste, barra de rolagem e botão de retorno. A janela nativa no Windows
usa o ajuste local descrito em `.claude/rules/captura.md`, sem alterar a
configuração do jogo. Uma tentativa de pedir janela mais alta continuou
produzindo PNG 720×1280; não foi tomada como prova de outra proporção.

Os extras abaixo renderizam as cenas reais em **SubViewports de prova**,
como o teste de geometria, sem modificar `project.godot`. Não simulam o
aparelho físico. Os dez PNGs deste pacote foram olhados.

| Quadro | Prova |
|---|---|
| 720×1600 | [artigo pela inicial](inicio-artigo-9x20.png) |
| 720×1600 | [fim do glossário pela pausa](pausa-glossario-fim-9x20.png) |
| 720×1152 | [índice pela inicial](inicio-indice-10x16.png) |
| 720×1152 | [fim do glossário pela inicial](inicio-glossario-fim-10x16.png) |

A definição de Treliça e o botão Assuntos aparecem inteiros nos dois fins
de leitura. A posição chegou a 384/384, registrada nos logs. Índice e
retorno ficaram dentro dos quadros, sem texto cortado ou botão inacessível.

## Reprodução, tentativas e limites

`receitas-locais/` conserva os lançadores usados no Windows; a bateria em
vigor continua em `tools/capturar_evidencia.sh`. Logs de capturas e todos os
PNGs da bateria permanecem também em `.evidencias/implementar-como-jogar/`.
Os textos do pacote usam LF e não têm espaços finais; os logs originais
permanecem intactos na evidência local. `fontes-finais.json` registra as
fontes após normalização LF e o comentário sobre saída da árvore.
`manifesto_sha256.json` registra os hashes dos arquivos do pacote.

As tentativas preservadas em `tentativas/` não são a versão final: contraste
reprovou o primeiro título fora do cabeçalho e a restauração de leitura após
remoção da árvore; ambos foram corrigidos. A fumaça identificou o contrato
antigo do F16 e o literal do F19. A primeira bateria usou saída relativa e
parou ao gravar o primeiro PNG; o caminho absoluto corrigiu o lançamento.

Os logs finais ainda têm avisos de recursos/objetos no encerramento; a fumaça
imprime o JSON inválido intencional e queixas do renderizador dummy já
registradas anteriormente. Não se declara a rodada sem avisos. A importação
histórica com `Safe save failed` da `110`/`111` continua sem causa isolada:
esta entrega não a diagnostica nem a declara resolvida.

Leitura por pessoa nova e teste no telefone continuam pendentes. O aceite
do recorte não é aceite de uma interface testada por humanos. Não houve push
ou PR novo; este head não tem CI remoto. O CI verde reconferido pertence ao
PR #133 e ao merge `f03302d`. Não se recomenda merge deste trabalho local.
