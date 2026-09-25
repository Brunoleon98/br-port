# 062 — A promessa do painel: a consequência antes da escolha, conferida contra o jogo

**25/09/2026 · terceira passagem da primeira família da frente 3 do A5**
(boletim, contra-oferta, cobrança, balanço). O Bruno julgou a segunda passagem
«melhor, mas pode melhorar ainda mais», e pediu uma iteração pequena e
coerente, conferindo se preços e probabilidades exibidos correspondem à lógica
real. **Aceite do Bruno em 25/09, sobre a quinta passagem (`064`): «ficou bom».**

## O que se leu nas capturas e na lógica

- **A contra-oferta escondia o preço de falhar.** Se o cliente recusa uma
  aposta na primeira rodada, ele fica, mas igualar passa de −15% a −28%
  (`RIVAL_DISCOUNT_AFTER_FAIL`); na última, o barco vai para o Porto Farol. A
  tela dizia «Cliente ouvindo a proposta. (2 tentativas)», e o −28% só
  aparecia depois de se ter falhado. É o princípio que a segunda passagem já
  tinha tirado da crítica de *Port Royale 4* — não esconder o efeito de um
  botão (`docs/design/BR_Port_Referencias_Interface_Gestao.md`).
- **O balanço afirmava «Ofertas do rival igualadas».** `rival_matched` sobe no
  `_fechar_negocio()`, por onde passam o igualar E as apostas aceitas: quem
  segurou o preço seis vezes lia «6 igualadas».
- **A cobrança espalhava a conta por três sítios**: a falta na tarja, o
  dinheiro numa linha cinzenta por baixo, a parcela dentro da fala.

## O que se decidiu

1. **A tarja ganha uma linha de APOIO** (`PainelNarrativo.tarja(texto,
   detalhe)`, e `tarja_solta()` para a contra-oferta, que não herda do
   andaime): menor, na cor `RotuloApoio`, dentro da tarja — o contexto do
   número destacado, nunca um segundo destaque. Vazia, esconde-se.
   - **Cobrança:** «Você tem R$… · a parcela é R$…» por baixo da falta ou do
     saldo; a linha cinzenta solta saiu. Depois da escolha, «Você fica com
     R$…» (lido do jogo depois do `pay_debt()`) ou «Faltaram R$…».
   - **Boletim:** a comparação com a semana anterior entra na tarja do
     resultado, em vez de um parágrafo solto com o peso do «Semana 1 de 4».
   - **Contra-oferta, no fim:** «Fechado por R$…», lido do `matched_value`.
2. **A contra-oferta diz o que acontece se ele recusar, antes da aposta**, com
   os números das mesmas constantes: «Se recusar uma aposta, você fica com 1
   tentativa e igualar passa a −28%»; na última, «se recusar esta aposta, o
   barco vai para o Porto Farol».
3. **Os três botões alinham o texto à esquerda, com a segunda linha paralela**
   — `R$… · fecha na hora` / `R$… · 70% de chance`: os preços ficam em coluna
   e comparam-se de cima para baixo. Os nomes dos presets são os do GDD.
4. **O balanço diz «Disputas com o rival: N ganhas · M perdidas»**
   (`rival_matched` e `rival_refused`, que o jogo já contava).

Nada disto mexe em economia, progressão, `# TUNING:`, retrato ou sequência de
decisões; nenhuma cor nova (a de apoio mede **5,27:1** sobre a tarja).

## A guarda: F14 do `teste_fumaca`

A passagem anterior deu a chance por certa «pelo uso da mesma função»: isso
prova que a chamada é a mesma, não que o sorteio a aplica. O F14 lê a
PREVISÃO no texto da tela e o RESULTADO no jogo, cada um da sua fonte:
«Depois de pagar» contra o dinheiro que o `pay_debt()` deixa; o preço de cada
botão contra o `matched_value`; a promessa da recusa contra as tentativas, o
desconto de igualar e o barco depois de recusas semeadas; e a chance contra
a frequência do próprio sorteio, 4.000 apostas por opção em reputação 100 e 20
(±4 pontos, ~5 desvios-padrão no pior caso).

- **Seis defeitos injetados, seis reprovações pela guarda certa**, com a base
  limpa entre cada um: a chance da constante de base (22 a 29 pontos fora), o
  desconto prometido errado, o igualar sem o encarecimento, o saldo sem a
  subtração, o limiar da última rodada, e o «Fechado por» a ler o valor
  original.
- **A primeira versão usava 800 apostas e ±7**, e passou com 4,4 pontos de
  desvio num caso. Com 20.000 as quatro chances bateram a ±0,2 ponto: o painel
  estava certo, a sequência da semente calhava alta, e as duas reputações
  partilhavam a mesma sequência. Cada caso leva hoje a sua semente.

## Evidência e limites

- A bateria inteira antes e depois, no mesmo contêiner: **mudaram 8 das 36**,
  exatamente as que têm linha nova (três do Sr. Ribeiro, três da
  contra-oferta, o boletim com semana anterior, o balanço); as que não a têm
  (boletim da semana 1, despedida em que o Arlindo ganha) saíram idênticas.
- A foto «pagou» mostra «Você fica com R$0» porque a bateria monta o dinheiro
  exato da parcela; é verdade daquele estado, e o F14 prova o caso com sobra.
- A régua de contraste mede a linha de apoio na cobrança; o boletim com semana
  anterior e o «Fechado por» usam o mesmo estilo sobre o mesmo fundo, mas o
  percurso dela não monta esses dois estados.
- As fontes de *Into the Breach* (postmortem da GDC 2019) foram procuradas
  para sustentar «mostrar a consequência antes da ação» e o proxy bloqueou-as;
  não entram como evidência.
