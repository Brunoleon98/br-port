# 109 — Proposta: cancelar um serviço contratado em andamento

**14/10/2026. Status: proposta, aguardando o aceite do Bruno.** O pedido
foi analisar o funcionamento e propor as regras antes de implementar.
Nenhuma regra abaixo está aprovada ou implementada por este documento.

**Continuação em 15/10:** Bruno autorizou medir. A bancada e os resultados
estão na `110`, que recomenda manter o candidato; implementação e migração
continuam sem aceite. O desenho abaixo registra a proposta anterior à rodada.

Base: main remota `82a9df0`, merge do PR #131 confirmado no GitHub. O
último commit da branch `codex/medir-fase-2`, `7ba2ef7`, é ancestral dessa
main. Não havia PR aberto. Decisões na main até a `108`; a `107` continua
reservada em `codex/corrigir-nomes-web`, no commit local `0a0ab5c`, sem
publicação nesta sessão. Próximo número livre conferido: **109**.

## O que existe e o que o GDD pede

- `GameState.atracar()` tira o barco do largo e aloca um trabalhador junto.
  Antes do primeiro fecho, `desatracar()` devolve-o ao largo, conservando a
  paciência; se a fila estiver cheia, recusa. Não há multa nem queda de
  reputação por desfazer esse toque.
- Depois de `progress > 0`, `desatracar()` recusa: «A operação já começou —
  o barco não sai agora.» Tanto o cartão (`DocaCartao.gd`) quanto o cenário
  (`Dock.gd`) chamam essa função. Não existe cancelamento do serviço.
- O dia só passa em `advance_turn()`. Receita, bônus da estrutura,
  reputação por atendimento, recorde e missão do primeiro cargueiro só
  entram quando o barco termina. Não existe adiantamento a devolver nem
  pagamento por dias parciais. `busy_turns` mantém o trabalhador ocupado
  entre os fechos; limpar apenas a doca não o libera.
- Na Fase 1 os serviços duram um dia. A Fase 2 trouxe cargueiro de dois
  dias e granel de três (`105`), justificando a ordem escolhida na `103`.
  A progressão e sua medição já fecharam (`108`).
- O GDD, `docs/gdd/sistemas/gameplay.md`, pede queda de reputação **e multa**
  por contrato não cumprido. `docs/gdd/sistemas/reputacao.md` dá faixas de
  falha nos três eixos do jogo completo; o VS tem uma só reputação. A frente
  5 do plano menciona cancelar trabalho a custo de reputação. Nenhuma dessas
  fontes fixa a multa ou a perda para este cancelamento voluntário.

O GDD fala também em cancelamento de construção, em outro contexto. Esse
sistema está fora deste recorte. Não se alteram seus arquivos gerados.

## Regras propostas

| Situação | Resultado proposto |
|---|---|
| Barco ao largo | Mantém a escolha atual; não ganha uma ação de cancelamento |
| Atracado, sem dia operado (`progress == 0`) | Mantém a devolução gratuita atual e seu limite de fila |
| Atracado, com serviço iniciado (`0 < progress < op_turns`) | Pode cancelar, depois de confirmar |
| Serviço concluído ou doca vazia | Não há contrato ativo para cancelar |
| Negociação ou cobrança pendente, fim de jogo | Cancelamento indisponível; só ocorre no estado jogando |

1. **Saída definitiva.** O barco cancelado deixa o porto, sem voltar ao
   fundeadouro. Não consome vaga da fila nem espera outro fecho para sair.
   Fila cheia não impede esse cancelamento. Não se transfere trabalho para
   outro píer nem se guarda carga/progresso para retomada.
2. **Liberação imediata.** A doca perde o barco e a alocação; o trabalhador
   correspondente fica com `busy_turns = 0`. Pode-se atracar outro barco no
   mesmo dia, pelas regras normais. O cancelamento não avança o calendário,
   não conclui obras e não provoca nova chegada ao largo.
3. **Sem receita pelo serviço interrompido.** Perdem-se o valor contratado
   inteiro e qualquer adicional da estrutura. Dias já operados não são
   remunerados, e salários/manutenção não são reembolsados. Não conta como
   atendimento, maior negócio ou primeiro cargueiro; não emite
   `contrato_fechado`. Um marco conquistado anteriormente permanece.
4. **Custo candidato: −5 de reputação e multa de 10%.** Aplica uma única
   perda de reputação, limitada ao intervalo atual de 0–100. A multa usa o
   preço efetivamente acordado do barco (`_valor_do_barco()`), incluindo
   eventual desconto negociado com Arlindo, **sem** bônus de estruturas.
   Arredonda para cima ao real inteiro. Exemplo: contrato de R$10.000,
   multa de R$1.000; se o acordo fechou em R$8.500, multa de R$850.
5. **Cobrança imediata, sem exigir saldo suficiente.** A confirmação mostra
   caixa atual, multa e saldo resultante; se ficar negativo, avisa que será
   preciso recuperar o caixa até o fecho. Não cria dívida nem segunda chance.
   Segue a derrota por caixa negativo no fecho já existente: o jogador
   ainda pode operar outro serviço antes dele. Proibir o cancelamento por
   falta de dinheiro retiraria a saída justamente de quem mais precisa
   reorganizar a doca.
6. **Consequências existentes, sem punição adicional.** A reputação nova
   afeta a negociação e o piso de novas chegadas de cargueiros. Os barcos
   já contratados continuam. A sequência da meta continua sendo avaliada
   no fecho; a conquista já obtida permanece. Não se acrescentam bloqueio
   permanente de cliente, rival, prazo ou regra de reincidência.

Os **5 pontos e os 10% são proposta de desenho, não resultado medido**.
Hoje perder um barco sem atendimento custa 2,5 e recusar o rival custa 8;
cinco situa a quebra de um compromisso entre essas consequências. Cada
atendimento rende 0,8, mas isso não permite prometer um prazo de recuperação:
outros acontecimentos também mudam a reputação. A multa proporcional
acompanha o tamanho do compromisso sem importar a moeda antiga do GDD.

A recomendação é reputação **mais** multa, pela regra expressa do GDD.
Uma alternativa de só reputação reduz a pressão no caixa e segue a descrição
curta da frente 5, mas seria um desvio deliberado dessa regra. Cabe ao Bruno
escolher; não se presume essa exceção.

## Como o jogador faria

O cartão de uma doca com serviço iniciado indica **«toque p/ gerenciar»**;
o toque abre um overlay com doca, classe/motivo, dias operados/restantes,
receita total que deixará de receber, multa, reputação antes/depois e saldo
após a multa. Não se espalha um botão destrutivo permanente sobre o mapa.
O toque no cenário abre o mesmo fluxo. Antes da operação, continua valendo
o toque para devolver ao largo.

Exemplo de confirmação, ainda rascunho de interface:

> Cancelar serviço da Doca 2?
>
> Cargueiro · Contêiner · 1 de 2 dias operado.
> Você não receberá os R$10.000 previstos para este serviço.
> Multa: R$1.000 · Reputação: 65 → 60.
> Caixa após a multa: R$19.000.
> O barco vai embora; a doca e o trabalhador ficam livres agora.

Botões: **«Continuar serviço»** e **«Cancelar serviço»**, com o primeiro
como ação padrão. Voltar/fechar não altera nada. O overlay bloqueia avanço
de dia e toques no jogo enquanto aberto, sem criar estado novo do turno.
A confirmação revalida a identidade (`id`) do barco e sua doca: um painel
antigo nunca pode cancelar outro contrato nem cobrar duas vezes.

O exemplo supõe receita total prevista de R$10.000 e não tem bônus. Na tela
real, a receita perdida vem de `receita_da_doca()`, e a base da multa vem
do valor acordado; são números diferentes quando existe adicional.

## Contas, save e prova que a implementação precisará entregar

- A multa entra como **despesa de cancelamento** no dia e na semana, no
  resultado, nas leituras financeiras e nos recordes pertinentes. Não é
  receita negativa nem desconto de uma receita que nunca entrou. A projeção
  e a virada devem evitar cobrar de novo o valor já descontado do caixa.
- O barco conta uma vez nos perdidos totais, com contador próprio de
  cancelados para distinguir desistência da fila e decisão do jogador.
  Isso não chama a penalidade genérica de 2,5 além da perda de cinco.
- Um evento específico de cancelamento registra doca, `uid`, classe,
  motivo, progresso, valor acordado, receita perdida, multa e reputação;
  sem nome do jogador. O leitor distingue registros anteriores, que não
  observavam a ação, dos novos sem cancelamento. Proposta: registro 5.
- Proposta para o aceite: **save 18 e migração 17→18**; os novos
  acumuladores/contadores começam a zero, preservando caixa, fase, barcos,
  trabalhadores, obras e marcos anteriores. Novo exemplo jogado com multa
  real, v17 intacto e cadeia desde a 14. Não se pede reinício da partida.
  Nenhuma versão foi alterada nesta análise.
- Regressões devem cobrir devolução gratuita, fila cheia, duas docas,
  liberação/reuso do trabalhador, acordo do rival, granel a meio, falta de
  saldo, clamp da reputação, não atendimento da missão, persistência,
  contador e multa únicos, confirmação abandonada/repetida/desatualizada,
  piso dos cargueiros e efeitos no resultado de dia/semana. Novas guardas
  precisam reprovar com o defeito injetado e passar após restauração.
- Antes de fixar os novos valores, aplicar `/balancear`: comparar com a
  main a política sem cancelamento e exercitar políticas que cancelam,
  inclusive troca por um contrato melhor. Medir multas, receita perdida,
  caixa/quebras, reputação/piso e dias até a meta com seus denominadores;
  não usar os perfis atuais, que nunca cancelam, para declarar o custo
  equilibrado. Capturar e olhar o fluxo num serviço realmente iniciado.

## Encaminhamento

O próximo passo é o **aceite ou ajuste dessas regras pelo Bruno**, incluindo
custos, saldo negativo e migração. Depois, implementar apenas este recorte.
Não é continuação da progressão da Fase 2 nem requisito novo do vertical
slice. Trabalhadores extras e crédito voluntário ficam para depois.
Tutorial e segunda chance já existem. A4 e caderno reescrito continuam sem
aceite; a `107` fica separada, aguardando autorização de publicação e a
confirmação de digitação no telefone.

## Verificação desta sessão de análise

As seis suítes da main passaram localmente no Godot **4.6.3**, com código
zero, seus marcadores finais e sem `SCRIPT ERROR` ou `at: push_error (`:
`TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`,
`REGISTRO OK` e `ASSET OK`. A sentinela do perfil isolado permaneceu intacta
nos cinco arquivos. `tools/conferir_docs.py`: `DOCS OK`; diff sem erros
de espaços. Não se criaram testes novos para regras ainda não aprovadas.

Testes e Captura do merge `82a9df0` também terminaram com sucesso no GitHub,
assim como o deployment do Pages. As verificações locais comprovam a base
preservada e a documentação; **não** validam os custos ou uma implementação
de cancelamento, que ainda não existe. O fecho segue `/fechar-sessao`, com
estado, plano e briefing atualizados; nenhuma fonte do jogo foi alterada.
