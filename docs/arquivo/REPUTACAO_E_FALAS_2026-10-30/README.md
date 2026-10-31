# Reputação baixa e falas — implementação local

Iniciada em 30/10/2026, decisão `147`, branch `codex/revisor-de-mensagens`.
Bruno reformulou o apontamento do revisor: Cida comenta quando a reputação
fica baixa, com alerta vermelho no indicador. Aceitou o elogio ao contrato
sem previsão financeira e a aproximação de Mané sem entrega fixa/conta mensal.

## O que foi aplicado

- Cida avisa ao entrar no patamar baixo ou abrir já baixo, uma vez enquanto
  permanece assim. Recuperar e cair de novo permite outro aviso. Queda ainda
  em Confiável não dispara o alerta; elogio por subida continua.
- «A fama do cais tá por baixo, chefia. Vamos caprichar nos próximos serviços.»
  não atribui a queda a uma causa que o gatilho não conhece. O elogio vira
  «Esse valeu a conversa. Anota aí.»
- A cena `mesa` passa a «Mais uma cadeira»: Mané pede lugar para sentar com o
  pessoal; Toninho pede a cadeira que não balança. Id salvo e condições
  permanecem. Não se acrescenta entrega recorrente ou cobrança mensal.
- `AvisoDeReputacao` consulta a classificação real do GameState, abaixo de
  Confiável (hoje menos de 41); o HUD troca o estilo em cada atualização.
  Número e nome continuam visíveis além da cor.

Sem alteração de preço, economia, versão do save ou campos persistidos.
Chave e almoço aceitos continuam no jogo; outras propostas e retorno das
lojas permanecem no documento de revisão.

## Espera do gráfico e integração

A primeira etapa preservou o Main enquanto o PR gráfico #156 estava aberto.
Bruno escolheu **aguardar o PR gráfico**; a prévia usava o atualizador somente
na ferramenta. Depois informou **«PR mesclado»**. Confirmado o merge em
`53b923b`, incorporou-se a main (`6fd918c`) e aplicou-se a chamada em
`Main._refresh_hud()`. O diff do Main nesta etapa contém uma linha apenas.
O patch preparado em `integrar_indicador.patch` está aplicado.

Os registros do Claude foram preservados. A história local passou a decisão
146; o revisor é 145 e esta entrega, 147. A decisão gráfica continua 144.

## Provas visuais

Imagens a 720×1280, Godot 4.6.3 e passo fixo de 60, com tema real e dados de
ferramenta isolados. Todas as imagens finais selecionadas foram olhadas.

| Arquivos | O que mostram |
|---|---|
| `reputacao_65_padrao`, `reputacao_35_padrao`, `reputacao_41_padrao` | HUD integrado em Respeitado, Questionável e na recuperação para Confiável |
| `reputacao_35_maior` | Alerta no tamanho Maior |
| `aviso_padrao`, `aviso_maior` | A fala real da Cida apresentada pela fila normal, junto do indicador baixo |
| `mesa_padrao_1`, `mesa_padrao_4`, `mesa_maior_1`, `mesa_maior_4` | Entrada e encerramento da cena do Mané, nos dois tamanhos |
| `previa_reputacao_*` | Prévia anterior ao merge gráfico; integração ainda só na ferramenta, preservada como histórico |

Cada imagem tem seu log ao lado. `capturar-hud-integrado.gd.txt` guarda a
ferramenta final: monta o valor da reputação e chama o refresh real do Main,
sem chamar o atualizador diretamente. Isso prova apresentação, não frequência
natural de reputação baixa em partidas. Nos tiros `aviso_*`, espera a fala
real chegar à tela pela fila; no Maior, rola até ela pelo ScrollContainer
existente. A cor vermelha mede **6,63:1** no fundo composto
`(0.09, 0.16, 0.24)`; o âmbar mede **8,37:1**.

`capturar-mesa.gd.txt` joga a partir de uma partida nova até o dia 57 e duas
parcelas pagas, depois abre o painel real e avança pelas falas. Os logs
confirmam dia 57, duas parcelas, R$359.225. A primeira tentativa do wrapper
parava antes de resolver a segunda cobrança e recusou a captura; corrigiu-se
o laço da ferramenta para terminar também o pagamento pendente. Os tiros
finais derivam o estado pelas ações, sem forjar a parcela.

`previa-reputacao.gd.txt` preserva a ferramenta antiga de prévia. Ela não é a
receita usada pelas capturas finais. Telefone e export não foram verificados.

## Verificação

O T33, em arquivo próprio, cobre fronteiras, queda ainda saudável, entrada,
permanência, recuperação/reincidência, abertura já baixa, elogio por subida,
troca/restauração do estilo e atualização do **HUD real** pelo GameState.
Na primeira execução, o Label de teste estava fora da árvore e a leitura do
tema falhou. Montou-se o Label e esperaram-se dois frames; a cor do produto
não foi alterada para esconder a falha.

Os sete defeitos novos foram explorados antes de declarar sua guarda no
catálogo: seis de regra/estilo e um que remove a linha do Main. Todos
reprovaram pela guarda específica, com base verde antes/depois. Logs e
relatórios: `exploracao-gatilhos.*` e `exploracao-hud.*`.

A primeira execução integral, na base anterior ao #156, foi interrompida
intencionalmente após 67 de 245 defeitos detectados para incorporar o gráfico.
Código 130, sem conclusão integral; log `mutantes-parcial-interrompido.log`.
O original nunca é mutado: os trabalhadores usam cópias isoladas.

Seis suítes aprovadas na base do #156: `SUITES OK`, 179 s, cada uma com
`user://` isolado. Logs em `suites-base-53b923b/` e resumo em
`suites-base-53b923b.log`: lógica 67 s, design 178 s, áudio 2 s, fumaça 36 s,
registro 3 s, assets 52 s. Critérios do executor: código, marcador e ausência
de `SCRIPT ERROR`/`push_error`. Os logs brutos preservam também mensagens
do motor sobre recursos no encerramento e funções de TextoDaInterface
retomadas após seus objetos serem removidos, emitidas por outros blocos e
pelo encerramento do fixture novo. Não se afirma ausência de todo `ERROR`.

Execução integral na base `53b923b`, após incorporar #156: **MUTANTES OK —
259 defeitos**, em quatro cópias, todos detectados pela guarda declarada.
Conferidos o marcador final, os IDs do relatório contra o catálogo e cada
resultado `aprovado`. Provas preservadas em `mutantes-base-53b923b.log` e
`mutantes-base-53b923b.json`. A espera no chat foi interrompida com 136
detectados; a execução em segundo plano continuou e terminou normalmente.

Na retomada de 31/10, o fetch trouxe o PR #157, já mesclado em `9c36e97`:
bandeiras de conclusão nos testes de design e quatro mutantes novos.
Incorporado localmente em `abd44db`, sem conflito. Não houve alteração de
scripts de jogo, cenas ou tema nessa atualização; as capturas acima continuam
representando o código do jogo. As seis suítes e o catálogo completo de
**263 defeitos** acompanham essa base antes do commit final.

As seis suítes passaram novamente em **65 s**, com a versão reforçada dos
testes de design: lógica 33 s, design 65 s, áudio 2 s, fumaça 27 s,
registro 1 s, assets 32 s. Resumo em `suites-final.log`, marcadores em
`suites/*.txt`. Os tempos das duas bases não são comparação de desempenho.

A primeira cópia para a bateria nova foi recusada antes de iniciar os
trabalhadores: a importação ainda modificava o cache do editor. Log
`copia-157-recusada.log`; nenhum mutante foi injetado nessa tentativa.
A importação inicial também tentou pastas do perfil sem acesso de escrita;
foi refeita com XDG_DATA_HOME, XDG_CONFIG_HOME e XDG_CACHE_HOME isolados em
`/tmp`. Concluída sem erro de script, só então se reiniciou a bateria em nova
pasta (`importacao-157-isolada.log`). O catálogo integral de 263 está em
andamento; atualizar o resultado antes do commit.

Preparador contextual inclui agora o predicado do alerta e seu consumidor no
HUD. Seis testes Python do preparador passaram (`testes-preparador.log`). O pacote
preparado contém 32 fontes, incluindo predicado, refresh do Main e chamada
integrada, conferidos; `manifesto-contexto.json` registra os hashes. Preparar
contexto não é uma segunda revisão editorial. Escopo UI aprovado, sem cores
pintadas à mão; tabela conferida contra o despejo real, 56 constantes, sem
diferença.

## Publicação para revisão

Em 31/10, Bruno perguntou «Vai abrir um novo PR?». A entrega segue para um
PR em rascunho, com a pendência dos 263 explícita e acompanhamento do CI.
O diff contra a main inclui também a história, Mercado/Delivery, migração
18→19 e revisor ainda locais (`146`, `145`); o PR descreve esse recorte
completo. Não altera a frente gráfica incorporada. Rascunho não é aprovação
para merge nem publicação do jogo.
