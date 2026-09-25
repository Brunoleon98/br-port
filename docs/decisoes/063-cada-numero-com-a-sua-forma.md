# 063 — Cada número com a sua forma: a quarta passagem da frente 3

**25/09/2026 · pedido do Bruno sobre a terceira passagem (`062`):** «consegue
melhorar essas interfaces? Veja o que é feito em outros jogos para deixar a
interface mais bonita e útil, e aplique». Mesmos quatro painéis — boletim,
contra-oferta, cobrança do Sr. Ribeiro, balanço —, mesma regra: nada de
economia, `# TUNING:`, retrato, sistema novo ou dashboard. **Candidata: o
aceite visual é dele.**

## Referências (por busca; o proxy bloqueou as páginas)

- ***Two Point Hospital*** — as finanças mostram de onde vem e para onde vai o
  dinheiro, com uma caixa do lucro ou prejuízo do período.
- ***Papers, Please*** — o fim do dia é um resumo visual das finanças, e a
  coluna do meio, a das contas, é a mais importante da tela.
- ***Reigns*** — antes de a carta cair, um ponto sob cada recurso diz o
  TAMANHO da mudança (não a direção).
- ***Moonlighter*** — o preço responde-se com a cara do cliente.

Fontes e o que ficou de fora em
`docs/design/BR_Port_Referencias_Interface_Gestao.md`.

## O que se decidiu

1. **Boletim: o total sobe para a linha do bloco.** «Entrou R$630.779» e
   «Saiu R$49.000» encabeçam as parcelas, que descem de tom (`RotuloApoio`) e
   recuam 14 px. Saíram as duas linhas «Total» e os dois fios: ~90 px a menos
   e os dois números que a Dona Cida comenta à primeira vista. **Sem sinal e
   sem cor**: «Saiu −R$49.000» dizia a mesma coisa duas vezes (a regra do
   `lucro_ou_prejuizo()`), e verde contra vermelho não se lê sem distinguir as
   duas.
2. **Cobrança: a barra do HUD.** O jogador passa a partida a olhar para a
   barra da parcela no rodapé — «R$981.779 de R$530.000». A cobrança é o dia
   em que ela chega ao fim: a mesma barra, a mesma legenda («Você tem R$… de
   R$…»), no estilo base do tema. Uma barra nova seria outra coisa para
   aprender.
3. **Contra-oferta: a chance como barra, dentro de cada botão.** O preço já
   estava em coluna; agora a certeza também — o igualar cheio (fecha sempre),
   as apostas à medida da chance que o `_negociar()` sorteia. Variação nova
   `BarraChance`: o trilho claro do tema acendia sobre o navy (1,9:1 contra o
   âmbar); o trilho navy mais claro mede 4,6:1. A percentagem continua
   escrita, e a barra não recebe toque. Botões a 72 px.
4. **Balanço: os números da partida em quadros** (`BlocoNumero` +
   `NumeroGrande`, 24 px): barcos atendidos e perdidos, disputas ganhas e
   perdidas. O dinheiro continua em linhas, porque é soma e compara-se em
   coluna. O rótulo é a CATEGORIA e vai em cima, invariável com o número —
   não precisa do `concordar()`.

Ficaram de fora: **ícone por linha no boletim** (o jogo tem ícone para três das
sete fontes; desenhar os outros é arte, e a técnica é escolha do Bruno);
**gráfico** e **cor de seguro/aposta** (já recusados na `062`).

## As guardas (F14 do `teste_fumaca`)

- **O boletim fecha as contas que mostra:** o total de cada bloco é a soma das
  linhas por baixo, e a tarja é um menos o outro. A semana é montada com TODAS
  as chaves do `SEMANA_ZERADA` diferentes de zero, lidas da tabela do jogo —
  numa semana jogada a parcela é zero em três de quatro e linha com zero não
  entra, e o painel que a esquecesse passaria.
- **As barras:** a da cobrança contra o dinheiro sobre a parcela; a do igualar
  cheia; as das apostas contra a MESMA frequência medida que confere o texto.
- **Cinco defeitos injetados, cinco reprovações** pela guarda certa, com a
  base limpa entre cada um: o pátio fora do boletim, a parcela fora do
  boletim, a barra do «Manter» na constante de base, a barra da cobrança a
  mostrar a falta, e o igualar a meio.

## Medido

Da terceira para a quarta passagem mudaram **9 das 36 fotos**: as três do
boletim, as três do Sr. Ribeiro, as duas da contra-oferta com botões e o
balanço; as duas despedidas do Arlindo, já sem botões, saíram idênticas.

As seis suítes, `ESCOPO UI OK`, `GUARDAS OK`, `COBERTURA OK` e a sentinela
intacta; contraste: 369 textos em 25 estados, nenhum abaixo do AA — o rótulo
do quadro a 5,03:1, o número grande a 11,59:1, as parcelas do boletim a 5,46:1.
