# BR Port — continuação depois da medição da Fase 2

Leia `ESTADO_DO_PROJETO.md`, §7 do plano v3 e a decisão `108`. Base desta
sessão: `92862ef`, merge confirmado do PR #130, main até a `106`, nenhum
PR aberto no início. A entrega foi publicada no **PR #131**, branch
`codex/medir-fase-2`, commit `0913aa5`. Confirme seu estado no remoto antes
de editar ou integrar; não presumir merge.

A etapa 4 da `103` foi medida: 600 partidas por perfil, semente 20260825,
365 fechos de observação na Fase 2. Preços e patamares atuais mantidos.
Os resultados completos e verificações estão em
`MEDICOES_FASE_2_2026-10-14/`. Não se acrescentou pressão, dívida ou rival.

⚠️ A `economia.md`, a decisão `108` e `leitura_fase_2.gd` distinguem censura
de derrota. O Descuidado conquistou em 12/600 partidas; sua mediana de 345
dias é só dessas 12, nunca das 600. A janela de observação não cria prazo.

Bruno voltou ao A4 e depois autorizou avançar o que dispensasse sua revisão:
daí a medição. **Depois de abrir o PR #131, mudou o foco da próxima conversa
para melhorias gerais além da Fase 1, separadas da progressão da Fase 2.**
Ele não lembrava quais eram; a fila do plano e a decisão `103` recuperam:

- **Cancelamento de trabalho:** poder interromper um serviço em andamento;
  não confundir com cancelamento/reembolso de obra, excluído da `087`.
- **Mais trabalhadores por píer:** ampliar a alocação e a contratação, que
  hoje acompanham o píer; consultar o GDD antes de fixar limites e efeitos.
- **Linha voluntária de crédito:** pedir empréstimo para antecipar
  investimento; é diferente da segunda chance oferecida no vencimento.

Essas funcionalidades ficaram esperando a progressão para ter serviços de
mais de um dia e mais investimentos onde agir. Não são novas etapas da
Fase 2. O tutorial e a segunda chance já fecharam (`101`, `102`); carros e
imóveis continuam futuros, sem novo escopo. Retomar um recorte por vez,
conferindo o que já foi decidido antes de implementar.

**Recorte escolhido pelo Bruno: cancelamento de trabalho**, para analisar
na próxima conversa. Trata-se de interromper um serviço contratado em
andamento. Ler o GDD e conferir o funcionamento atual antes de propor as
regras; custos, consequências e interface ainda não foram definidos nesta
conversa. Trabalhadores extras e crédito voluntário ficam para depois.

O caderno reescrito foi apresentado só na conversa e ainda não teve aceite.
A fonte narrativa ficou intacta. A frase «Contei três vezes» foi
questionada; rever o caderno como um todo, sem apenas trocar essa frase.
O A4 também espera as falas recentes de Toninho, Sr. Ribeiro, Cida e Fase 2.

A `107` e o briefing `14c` estão reservados na branch local
`codex/corrigir-nomes-web`, commit `0a0ab5c`, separada desta. A correção
habilita o teclado virtual experimental no export Web e testa o preset.
O relato real foi: no celular o teclado abre, mas não entra texto. A bancada
Web digitou e persistiu os nomes; a confirmação no telefone continua
pendente. A revisão automática de aprovação rejeitou o push anterior por
falta de autorização de publicação. Não houve push nem PR dessa correção;
não tentar contornar a rejeição com outro meio de publicação.

Faltas humanas do vertical slice: A4, arte A5, escuta A6, jogadas/FPS no
telefone A7 e publicação A8. A Fase 2 extra não substitui esses gates.

Prompt para colar:

```text
Continuando o BR Port. Leia ESTADO_DO_PROJETO.md, §7 do plano v3
e decisão 108. Confira a main, os PRs abertos e o próximo número livre.
Confira o PR #131 (codex/medir-fase-2) e seu merge antes de começar.
Item escolhido pelo Bruno: analisar o cancelamento de um serviço
contratado em andamento. Leia a 103 e o GDD, confira o funcionamento
atual e proponha as regras antes de implementar. Não é cancelamento
de obras nem continuação da progressão da Fase 2. Trabalhadores extras
e crédito voluntário ficam para depois.
Tutorial e segunda chance já estão feitos. A4 continua pendente;
não aplicar o caderno reescrito sem seu aceite.
Preserve a correção móvel separada em codex/corrigir-nomes-web (107);
ainda falta publicar com autorização e confirmar a digitação no telefone.
```
