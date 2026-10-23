# 131 — Medir o texto maior antes de escolher o tamanho do RB5

**19/10/2026.** Depois do RB6, Bruno escolheu definir o recorte de
**RB5 — tamanho de texto ajustável** e autorizou seguir com a bancada
proposta. Os candidatos são Padrão, +25% e +50%, nos Ajustes do início e
pausa, artigo longo, HUD e cartão estreito de doca. A autorização não escolhe
o percentual final nem concede aceite ao leiaute ou à implementação global.
Cobertura funcional proposta e critérios da etapa posterior em
`docs/RECORTE_TEXTO_AJUSTAVEL_2026-10-19.md`.

A bancada existe apenas por `--script`, fora dos exports. Usa os tamanhos
efetivos dos nós, inclusive overrides, e amplia a partir da base original.
Não instala opção ou persistência no jogo. Movimento reduzido fica ligado
explicitamente em memória; não se escreve preferência para produzir fotos.

**O aumento sozinho não cabe na interface atual.** Em +25%, a fila cresce
sobre a mensagem em 11 unidades; no caso longo, a barra de docas passa de
692 para 736 de largura. Em +50%, a fila invade 27 unidades e seu valor
ultrapassa a janela em 54. As capturas confirmam texto coberto e cortado.
Os Ajustes e o artigo têm espaço nos casos fotografados, com o trecho final
do artigo alcançado por rolagem. Isso não aprova conforto ou toque no aparelho.

Antes da entrega funcional, Bruno precisa escolher o tamanho e aceitar sua
acomodação. Não reduzir mapa/viewport, esconder conteúdo ou diminuir a fonte
escolhida para contornar a falta de espaço. Não iniciar redesenho do HUD
por inferência. A cobertura global e a persistência independente do RB6
continuam para uma etapa posterior autorizada.

Reprodução, limites da régua, capturas e verificações em
`docs/arquivo/VERIFICACAO_TEXTO_AJUSTAVEL_2026-10-19/README.md`.
Nenhuma mudança em save, economia, RNG, serviço, arte, projeção ou MataNoMapa.
Claude continua na frente visual; telefone e aceite visual do RB6 pendentes.

O job oficial da main `117832180799` levou 58min18s para os 120 defeitos.
O teto desse job passa de 60 para 90 minutos para comportar as quatro provas
novas e a variação do runner. Nada foi removido; os tetos individuais continuam
derivados dos tempos medidos das bases pelo executor.
