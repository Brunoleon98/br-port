# Chave e almoço — falas aceitas e integração

25/10/2026. Bruno aceitou as duas cenas com «Ficou bom», depois da leitura
da versão final da chave («E nunca precisou pedir duas vezes» / «Se precisar,
me chama») e do almoço com a brincadeira do prato. As falas foram aplicadas
em `brport_vs/scripts/Narrativa.gd`. Demais versões de
`docs/REVISAO_FALAS_LOJAS_FASE_1.md` e o retorno das lojas continuam propostas.

## Compatibilidade com a entrega gráfica

A branch `codex/historia-e-lojas-fase-1` incorporou `origin/main` em
`3de1526`, com a entrega do mobiliário da rua do PR #152. A decisão de história,
antes 140, passou a 141 pelo `tools/renumerar_decisao.py`; a decisão 140 da rua
foi preservada. O conflito do estado foi resolvido mantendo as duas frentes.

O T32 procurava «quem senta na cabeceira» para reconhecer a cena entregue após
a compra do almoço; agora procura «O Mané mandou a comida». Continua exigindo
o débito correto e o direito ao almoço. Não se introduziu teste de gosto da
escrita nem um segundo catálogo de textos.

## Provas desta integração

- Seis suítes com Godot 4.6.3, `--headless --fixed-fps 60`, em perfis
  separados: `SUITES OK`, 136 s nesta execução concorrente. Logs originais em
  `/tmp/brport-chave-almoco-suites`; resumo em `suites.txt`.
- A renumeração mudou comentários no `GameState`; o despejo e a tabela foram
  conferidos: `CONSTANTES OK` e `TABELA OK`, mesmas 56 constantes e tabela
  sem diferença.
- Catálogo completo de **221/221 defeitos detectados**, com quatro cópias
  isoladas, porque uma suíte mudou. Cada defeito reprovou pela guarda
  declarada, com base verde antes e depois: `MUTANTES OK`. Relatório bruto em
  `mutantes.json` e saída integral em `mutantes.txt`; os ids foram conferidos
  contra o catálogo atual. Não se herda o resultado dos 200 da entrega anterior.
- `DOCS OK`, `COLABORACAO OK` contra `origin/main` em `3de1526` e diff sem
  erro de espaços. O fetch do fecho confirmou a mesma base.

## Capturas

16 capturas concluídas: quatro falas de cada cena em Padrão/Maior, 720×1280, tema do
jogo, passo fixo e semente das ferramentas existentes. A chave usa o
`capturar_cena.gd` com `turn=15 chave`: é montagem para conferir a leitura,
não prova de uma partida jogada até ali. O almoço abre pelo catálogo e pela
confirmação de compra reais, com os argumentos `--tocar` da mesma ferramenta.
O tamanho Maior usa `capturar_lojas_texto_maior.gd`, só em memória.

Cada fala seguinte usa mais um `--tocar=Continuar a conversa`. Nenhum texto
foi sobreposto à imagem; o painel lê a `Narrativa.gd` alterada. Capturas e logs
originais em `/tmp/brport-chave-almoco-fotos`, com dados de ferramenta isolados
em `/tmp/brport-chave-almoco-captura`.

Todas têm marcador de imagem salva, dimensão correta e nenhum erro de script,
backtrace de GDScript ou shader. Hashes e resumo em `capturas.txt`. As aberturas
e os encerramentos foram olhados nos dois tamanhos: falas completas e botões
legíveis, sem corte. Oito imagens selecionadas ficam nesta pasta:

- Chave: [abertura Padrão](chave_padrao_1.png),
  [fim Padrão](chave_padrao_4.png), [abertura Maior](chave_maior_1.png),
  [fim Maior](chave_maior_4.png).
- Almoço: [abertura Padrão](almoco_padrao_1.png),
  [fim Padrão](almoco_padrao_4.png), [abertura Maior](almoco_maior_1.png),
  [fim Maior](almoco_maior_4.png).

## Limites

Aceite das duas cenas registrado. O telefone continua pendente. Preços,
gatilhos, ids, versão do save e retorno das lojas não mudaram. Entrega local,
sem push, PR ou publicação; não há CI remoto deste trabalho local.
