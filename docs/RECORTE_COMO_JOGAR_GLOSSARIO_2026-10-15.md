# Como jogar e glossário — primeiro recorte aprovado

**15/10/2026, decisões `113` e `114`.** Bruno escolheu **definir o recorte de
Como jogar/glossário**, a primeira novidade sugerida pela pesquisa `112`, e
aprovou o conjunto abaixo com o ajuste de redação sobre o autosave (`114`).
O aceite fechou a definição. Depois, Bruno autorizou a implementação (`115`),
publicada a seu pedido no PR #134 em 16/10 (`116`). Leitura, telefone e
merge permanecem pendentes.

## O que a pessoa recebe

Uma ajuda curta, disponível **antes de começar e durante a partida**, para
consultar uma dúvida e voltar ao mesmo lugar. O título é **Como jogar**;
**Glossário** é um dos assuntos. Não abre sozinha nem substitui o tutorial
do Toninho. Não pede uma partida para funcionar.

Entradas aprovadas:

- **Tela inicial:** botão Como jogar entre Carregar (quando existir) e
  Ajustes. Sem partida salva, aparece entre Nova partida e Ajustes.
- **Pausa:** botão Como jogar entre Continuar e Ajustes. Continuar conserva
  o destaque principal.

As duas entradas abrem o mesmo conteúdo. Um índice tem sete linhas tocáveis:
**Atracar e atender**, **Avançar o dia**, **Dinheiro e semana**,
**Salvar e retomar**, **Devolver ou cancelar**, **Fases e metas**,
**Glossário**. Cada assunto abre uma página curta com rolagem se precisar.
Não há texto comprido inteiro no índice.

Na página, **Assuntos** e o Voltar do aparelho retornam ao índice. No índice,
**Fechar** e Voltar retornam à tela inicial ou à pausa que abriu a ajuda;
fechar a ajuda pela pausa não retoma a partida automaticamente. A navegação
preserva o índice e a página dentro da consulta; reabrir começa pelo índice.
Não há necessidade de guardar essa posição no save.

## Texto aprovado para o primeiro conteúdo

O texto abaixo é informativo, sem fala de personagem nem retrato novo.
Os números abaixo descrevem o jogo atual. Na implementação,
quantidade de espaços, cobranças, multa e reputação devem vir das constantes
ou dos dados da fase, com a mesma formatação dos painéis. Não manter uma
segunda tabela de regras ou de economia dentro da ajuda.

### Atracar e atender

Os barcos esperam ao largo. Toque em um deles para atracar numa doca livre
com trabalhador disponível. Veja a carga e o valor antes de escolher.

Avançar o dia faz o serviço andar. O pagamento entra quando o atendimento
termina. Alguns serviços precisam de mais de um dia. Os barcos ao largo
têm paciência limitada; quem vai embora sem atendimento custa reputação.

### Avançar o dia

O dia só muda quando você toca em Avançar dia. Você pode consultar o porto
e seus painéis antes de decidir. A animação da virada acompanha essa ação.

Na virada, os serviços e as obras progridem e o jogo calcula receitas,
despesas e acontecimentos. Leia as decisões que aparecerem para continuar.

### Dinheiro e semana

Toque no caixa para consultar as contas e a projeção do dia. O boletim da
Dona Cida reúne o resultado da semana. Receita é o que entra; despesa é o
que sai. Comprar uma obra usa dinheiro ao iniciar, e o benefício começa
quando ela fica pronta.

Na Fase 1, acompanhe as cobranças no calendário. Caixa negativo é avaliado
no fechamento do dia; consulte a projeção antes de avançar.

### Salvar e retomar

O jogo faz gravações automáticas durante a partida. Na pausa, Salvar e sair
pede uma gravação e volta à tela inicial.

Na tela inicial, Continuar abre a partida salva mais recente. Carregar
permite escolher entre os três espaços. Nova partida pode substituir um
espaço ocupado depois da confirmação.

As partidas ficam neste aparelho ou navegador. Copiar registro da partida,
nos Ajustes, copia os acontecimentos para análise; não é uma cópia do save
para levar a outro aparelho.

### Devolver ou cancelar

Antes de operar o primeiro dia, toque na doca para devolver o barco ao
largo. A devolução é gratuita e precisa de lugar na fila.

Depois que o serviço começou, toque na doca para gerenciar. O cancelamento
mostra os custos antes de confirmar: perde-se a receita inteira, sem
pagamento parcial, há perda de cinco pontos de reputação e multa de dez
por cento do valor acordado, sem bônus, arredondada para cima.

Se confirmar, o barco vai embora definitivamente. Doca e trabalhador
ficam livres no mesmo dia. A multa pode deixar o caixa negativo; a
verificação de derrota continua no fechamento. Isso cancela o serviço
do barco, não uma obra.

### Fases e metas

Na Fase 1, quite as três cobranças para seguir à Fase 2 na mesma partida.
Na Fase 2, consulte o painel da meta: ele mostra os requisitos de
reputação, infraestrutura e atendimento do primeiro cargueiro.

Não há nova dívida nem prazo na Fase 2. Reputação baixa pode suspender
novos cargueiros até se recuperar. Ao cumprir a meta, o diário fecha a
fase e você pode continuar em jogo livre.

### Glossário

| Termo | Explicação curta |
|---|---|
| Acordo | Valor combinado para atender aquele barco. A multa usa esse valor, sem os bônus de estruturas. |
| Ao largo / fundeadouro | A fila de barcos que ainda aguardam uma doca. |
| Atracar | Trazer um barco da fila para uma doca com trabalhador disponível. |
| Bônus | Receita adicional ligada às estruturas e à carga atendida. |
| Caixa | Dinheiro disponível no porto. |
| Cargueiro | Classe de barco liberada quando o porto alcança o nível necessário. |
| Doca | Vaga onde o barco recebe atendimento. |
| Fechamento | Cálculo e acontecimentos da virada de dia ou de semana, conforme a conta. |
| Jogo livre | Continuação da partida depois de cumprir a meta disponível. |
| Multa | Despesa cobrada ao confirmar o cancelamento de um serviço iniciado. |
| Píer | Estrutura do porto que oferece uma doca e sua equipe. |
| Reputação | Confiança comercial do porto; influencia negociações e acesso a clientes. |
| Treliça | Melhoria do guindaste disponível na Fase 2, necessária para o porto receber cargueiros junto do píer adequado. |

## Limites do primeiro recorte

Consulta por assunto, sem busca textual, links externos, simulação de
prática, repetição do tutorial, dicas automáticas ou atalhos que executem
ações do porto. O resumo de retomada da `112` permanece outro recurso.
Não abre nenhuma das portas fechadas do celular nem altera o caderno do A4.

A ajuda descreve os comandos de gravação existentes. Não oferece Salvar
agora, exportação/importação, recuperação ou indicador de escrita concluída.
A frase sobre Salvar e sair descreve o pedido de gravação; não promete que
a escrita foi verificada. As falhas e propostas técnicas permanecem em
`REVISAO_RECURSOS_BASICOS_2026-10-15.md`. A limitação de importação
`Safe save failed` da `110`/`111` continua aberta, sem causa isolada.

## Integração implementada (`115`), publicada no PR #134 (`116`)

Um painel compartilhado da família `PainelNarrativo`, com cena própria,
tema existente, índice e artigo rolável. A altura da área de leitura será
definida no layout e conferida no telefone; não se escolhe tamanho de fonte
novo nem se muda enquadramento neste desenho. Texto e índice ficam em uma
fonte compartilhada pelos dois acessos.

`TelaInicial.gd` e `PauseMenu.gd` fornecem as entradas; o `Main.gd` abre a
ajuda pedida pela pausa. A navegação é de interface, sem novo estado do
turno, autoload ou versão do save. O conteúdo não chama ações de jogo,
save, registro ou sorteador. O toque que abre ou fecha não atravessa para
os botões por baixo. Voltar trata o nível interno antes de fechar o painel.

Conferidos para esta proposta: `TelaInicial.gd`, `PauseMenu.gd`, o estado,
a §7 do plano, a revisão de recursos básicos, a pesquisa e as decisões
`103`, `108`–`112`. A organização segue `.claude/rules/interface.md`.
O conteúdo vive em `ConteudoComoJogar.gd`, usado pelo `PainelComoJogar.gd`.
São as duas portas da mesma cena, sem estado novo de turno ou save.

## O que precisa demonstrar para o aceite da implementação

- Abrir sem save, com espaços ocupados e pela pausa; mesmos artigos nas
  duas portas. Página → índice → origem por botões e Voltar. A pausa segue
  aberta ao sair da ajuda; não há painéis duplicados nem toque atravessado.
- Antes/depois de abrir, navegar e fechar: dia, caixa, reputação, obra,
  barco, progresso, trabalhador, meta e RNG preservados. Nenhuma escrita
  de save ou evento de partida provocado pela consulta.
- Conferir textos na Fase 1, Fase 2, serviço iniciado, saldo negativo e
  jogo livre. Números dos artigos vêm das regras reais; não
  anunciar cobrança nova na Fase 2 nem pagamento parcial no cancelamento.
- Capturas olhadas do índice, do artigo mais longo e do glossário pelas
  duas portas, com rolagem e botões alcançáveis nas proporções suportadas.
  Acrescentar o painel às verificações de cobertura e contraste existentes.
- Seis suítes com os marcadores finais e sem erros de script, guardas de
  interface e documentos, e sentinela do jogador intacta. Guardas novas
  recebem defeitos semânticos que comprovem sua capacidade de reprovar.
- No telefone, abrir, ler e voltar sem cortes ou ações acidentais. Uma
  pessoa que não conheça o projeto deve conseguir localizar como salvar,
  como retomar e a diferença entre devolver e cancelar. Esses resultados
  humanos não são substituídos por suíte verde.

**Próximo passo:** submeter a leitura e o teste no telefone ao Bruno; as provas
de máquina e capturas da `115` passaram. A publicação foi autorizada na
`116` e feita no PR #134; conferir seu último head antes de recomendar merge.
O aceite da definição não substitui as provas de máquina, leitura e telefone.
