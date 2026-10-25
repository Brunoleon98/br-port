# História e lojas — verificação local

24/10/2026, decisão `141`. Branch `codex/historia-e-lojas-fase-1`, base
`origin/main` em `06a1b63`. Entrega local; sem push, PR, merge ou alteração do
Pages. Bruno escolheu Mercado e Delivery e autorizou migração 18→19 preservando
o progresso. Recorte em `docs/RECORTE_HISTORIA_LOJAS_FASE_1.md`.

## O que conferir jogando

Menu → Lojas → Mercado/Delivery. Visitar e conversar é gratuito. O catálogo
explica que as primeiras compras liberam conversas: café por R$180, almoço
por R$240, uma vez cada. A confirmação mostra o saldo restante; voltar não
compra. O direito comprado e a despesa ficam no espaço da partida.

O boletim semanal oferece o próximo capítulo disponível. O arquivo em
Lojas → História do porto mostra os já disponíveis e distingue leitura nova
de releitura. «Ler depois» não marca como lida; só o último botão conclui.
O envelope exige o armazém concluído. Os recibos exigem mês encerrado e
parcela paga, mesmo se o jogador antecipou o pagamento.

## Provas

- Godot 4.6.3, versão de `.godot-version`; seis suítes com `--fixed-fps 60`.
  O T32 cobre a porta do celular e as ações reais das duas lojas, dinheiro,
  contas, retomada, cenas bloqueadas e isolamento de espaços. As seis passaram
  novamente após a ordem final dos botões; resumo em `suites.txt`.
- Os exemplos 14–18 permanecem intactos. A 19 foi gravada pelo jogo no dia 99,
  com compras e leituras preenchidas. A tabela dos números foi regenerada;
  as constantes de economia anteriores foram preservadas.
- Nove defeitos novos no catálogo, além dos anteriores. A execução integral
  detectou 199/200; `cancelamento-sem-conferir-o-orcamento` ultrapassou 115 s
  durante a carga concorrente, antes de terminar o T26. Repetido isoladamente,
  com base de 13 s e limite derivado de 60 s, foi detectado pela guarda
  «a confirmação aceitou um orçamento que não era o lido»; base verde antes
  e depois, `MUTANTES OK`. Resultado combinado: **200/200**, sem afrouxar
  teste nem aumentar limite. Primeira execução, repetição e resultado
  combinado estão nos JSONs desta pasta; log em `mutante_repetido.txt`.
- 115 capturas válidas. Uma foto do diário da Fase 2 excedeu o tempo durante
  a bateria concorrente e foi repetida isoladamente, com o mesmo limite de
  180 segundos, até salvar a imagem e conferir a sentinela intacta. Os logs
  das 115 capturas têm marcador e não têm `SCRIPT ERROR` nem backtrace de
  GDScript; o log extra de comparação de movimento imprimiu seu marcador.
  Cobertura: 25 painéis, 21 tempos e 12 caras; `COBERTURA OK` em `cobertura.txt`.

## Economia e limites

O catálogo custa no máximo R$420 por partida, sem bônus de receita nem custo
recorrente. Controle: 600 partidas por perfil, semente 20260825, sem compras.
Os quatro perfis pagaram as três parcelas em 600/600, sem travamentos. O
projetor continuou calibrado. A comparação compra os dois itens pelo método
real `comprar_na_loja()` antes do primeiro avanço operável, numa cópia isolada
do projeto. A instrumentação só insere no começo de `advance_turn()`, depois
da recusa por estado, uma tentativa de comprar cada produto ainda não possuído;
falha de compra escreve erro. Nenhum erro ocorreu. Mesma semente e 600 partidas
por perfil; fonte do jogo em trabalho ficou intacta.

| Perfil | Quitaram no controle / com compras | Caixa final mediano: controle | Com compras |
|---|---|---|---|
| Ótimo | 600 / 600 | R$732.290 | R$731.870 |
| Mediano | 600 / 600 | R$525.162 | R$523.977 |
| Descuidado | 600 / 600 | R$137.814 | R$137.394 |
| Antecipado | 600 / 600 | R$480.049 | R$479.629 |

Nenhum travamento nas duas condições. Distribuições de início/conclusão das
obras iguais nos quatro perfis. A diferença do Mediano passa dos R$420:
o gasto também pode mudar decisões de operação perto de um limiar, sem mudar
os percentis dos dias de obra. Não se presume equivalência de cada partida.
Dados completos: `controle.json` e `compras.json` nesta pasta.

## Capturas olhadas

As fotos são do Godot, com o tema real, semente fixa e `--fixed-fps 60`.
Padrão e Maior foram conferidos. A prova automatizada também mede contraste.

A primeira bateria revelou que o robô da Fase 2 escolhe a primeira ação do
boletim: com «Ler história» antes do fechamento, ele relia a mesma conversa
indefinidamente. A ação habitual «Fechar o boletim» foi preservada primeiro,
e o convite ficou depois. A bateria foi reiniciada com essa ordem. Não houve
mudança de estado de turno nem de economia para acomodar a ferramenta.

- [Lojas](lojas.png), [Mercado](mercado.png), [Delivery](delivery.png).
- [Confirmação](loja_confirmar.png).
- [Boletim da primeira semana com convite para ler](boletim.png).
- [A caneca que ficou](historia_caneca.png).
- [Mercado com texto Maior](mercado_maior.png) e
  [conversa com texto Maior](historia_caneca_maior.png).

O simulador mede operações e pagamentos; não mede se as conversas interessam
ou se o preço parece justo. Leitura da escrita e teste no telefone pendentes.
As lojas ainda não implementam status, estresse, imóveis ou carros. Seu Biu e
Mané têm texto e nome; retratos novos ficam com a frente de arte.
