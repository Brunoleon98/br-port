# Retorno e reencontros nas lojas — verificação local

31/10/2026, decisão `146`, branch `codex/revisor-de-mensagens`, sobre o
envelope local `3cdba77`. Bruno aceitou os retornos e as quatro falas de
reencontro («Pode ser»). Entrega local, ainda não enviada ou publicada.

## O que aparece no jogo

Depois de concluir ou interromper, a conversa volta à mesma loja ou ao
arquivo de histórias. Pelo boletim, preserva-se a volta já existente.
Botões indicam o destino. Compra continua visível na loja, sem nova cobrança;
interromper na última fala ainda deixa a cena por ler. Concluir marca uma
vez e libera releitura gratuita.

Depois de concluir Café no cais ou A mesa do cais, a visita da respectiva
loja recebe as falas aprovadas de Biu/Mané. Só comprar não basta. Uma loja
não comenta a cena da outra. A memória usa as leituras que o save já guarda.
Não se mudou versão do save, preço, condição de capítulo, Main ou arte.

## Provas

- T34: botões reais desde o celular, visitas, compras, interrupção na última
  fala, conclusão, releitura, arquivo, boletim e reencontro após retomar.
  Cada percurso tem bandeira própria de término.
- A primeira execução chegou ao vigia de 2.000 frames durante o T34: o
  helper esperava dois frames antes e dois depois de cada toque. Eliminada
  a espera repetida antes do toque; o vigia ficou intacto. A lógica passou
  em 14 s. As outras cinco suítes haviam passado (design 50 s, áudio 1 s,
  fumaça 20 s, registro 2 s, assets 17 s). O catálogo integral verifica as
  bases das seis suítes novamente nas cópias.
- Nove defeitos explorados e detectados pelas guardas do T34, com base
  verde antes/depois: origem errada em compra, releitura, arquivo, visita e
  boletim; conclusão ausente; interrupção que consome; reencontro antecipado
  pela compra; cenas cruzadas entre lojas. `exploracao.json` e `.log`.
- Doze capturas a 720×1280, passo fixo de 60 e perfis isolados: compra e
  leitura feitas pelos botões, retorno ao catálogo e duas falas de cada
  reencontro, em Padrão/Maior. Folhas de leitura e retornos em Maior aqui;
  originais/logs em `/tmp/brport-retorno-lojas/`. Texto e botões conferidos.
  Não prova uso no telefone nem frequência natural das visitas.

`fontes.json` identifica os arquivos de código/testes/catálogo verificados.
A execução integral de 272 foi interrompida com **48 defeitos detectados**,
sem resultado integral, porque a main recebeu o PR gráfico #160 em `28c2f2d`.
`catalogo-parcial.log` e `.json` preservam o ponto de parada. O primeiro sinal
SIGINT encerrou o pai com KeyboardInterrupt; os quatro trabalhadores foram
identificados por PID e receberam SIGTERM, o sinal tratado pelo executor,
restaurando suas cópias. O original permaneceu intacto, conferido pelos hashes.
Código de saída 130; não se declara catálogo completo aprovado dessa corrida.
As nove regressões novas também foram detectadas com suas guardas declaradas.

O conjunto será integrado à main #160 e reunido no PR #159 existente; a
verificação integral da junção final fica no CI, sem repetir a base antiga.
Nenhum PR novo foi aberto para este complemento.
