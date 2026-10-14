---
paths:
  - "brport_vs/autoload/GameState.gd"
  - "brport_vs/tools/simular_balanceamento.gd"
  - "brport_vs/tools/leitura_do_simulador.gd"
  - "brport_vs/tools/estado_simulado.gd"
  - "brport_vs/tools/despejar_constantes.gd"
  - "tools/projetar_parcelas.py"
  - "tools/gerar_tabela_numeros.py"
  - "docs/design/BR_Port_Numeros_Fase_1.md"
  - "docs/design/BR_Port_Metodo_Balanceamento_Economia.md"
  - "brport_vs/scripts/Dock.gd"
  - "brport_vs/scripts/UpgradePanel.gd"
  - ".github/workflows/balanceamento.yml"
---

# Regras — economia e as regras da Fase 1

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## A tabela dos números (do «Antes de fechar», item 3)

O passo — regerar a tabela a cada mudança no `GameState.gd` — está no
item 3 do núcleo. A armadilha:

   ⚠️ **E ELA ENVELHECE SEM CONSTANTE NENHUMA MUDAR.** A coluna «Onde» cita a
   LINHA de cada uma (`GameState.gd:107`), e em 26/09 um comentário de sete
   linhas no sinal `message`, acima delas, reprovou o PR #91 com os 48
   valores intactos. Esta linha dizia «mexeu numa `const`», e o fecho
   seguiu-a à letra (`067`).
   ⚠️ **E A COLUNA DA ORIGEM SAI DE UMA PALAVRA DO COMENTÁRIO.** Basta
   «GDD» no comentário de uma constante para a tabela a dar como «GDD 7»:
   o piso do save citava a promessa do GDD e saiu assim (`098`). Leia a
   linha nova da tabela, não só o `TABELA OK`.

## O balanceamento (do «Antes de fechar», item 4)

Este é o endereço da medição em vigor: o `tools/conferir_docs.py` lê daqui
o triplo do balanceamento e reprova quem o repetir noutro sítio.

4. Mexeu em preço ou constante `# TUNING:`? `tools/simular_balanceamento.gd`.
   Para planejar crédito, expansões e futuros carros/imóveis, use
   `docs/design/BR_Port_Metodo_Balanceamento_Economia.md`: uma moeda comum,
   caixa livre, custos de posse, retorno incremental e distribuições por perfil.
   Crédito não é lucro, patrimônio não é caixa e receita do porto não é renda pessoal.
   O balanceamento medido é **100% / 100,0% / 100,0%** (Ótimo / Mediano /
   Descuidado), e **100% no Antecipado**
   (`087`): 600 partidas por perfil, semente 20260825, três cobranças reais em
   12 semanas de 7 dias, com fila e desbloqueios básicos. Todos pagaram as
   três; caixa mediano do Mediano antes da primeira: R$298.032, depois: R$158.032.
   Quantis P10/P50/P90, n, desbloqueios, início e conclusão das obras:
   `docs/arquivo/MEDICOES_OBRAS_FASE_1_2026-10-09.json`.
   Crédito inicial R$400.000, três parcelas iguais de R$140.000, R$20.000 de
   juros totais. Antecipação abate só juros da janela, nunca o capital.
   Serviços foram reequilibrados após restaurar a moeda; preços e amortização
   vivem no código/tabela, comparação externa e limites no guia de economia.
   Mexer sem medir quebra isso. Bots não validam compreensão nem preços de mercado.
   **O alvo é TRANQUILO, e é decisão registrada** (`docs/decisoes/005`): a
   dívida deixou de ser o motor. Os 100% / 47% / 0% que este arquivo afirmou
   até 02/09 eram a fantasia de sobrevivência que essa decisão substituiu — são
   história, não meta. Quem discrimina os jogadores agora é **o porto que
   conseguem levantar** — e desde a trava de 06/09 quem mede isso é a MARGEM
   em regime (cerca de R$111.975 contra R$12.339), não a contagem de barcos: o porto
   pobre só recebe pesqueiro, que descarrega num turno. Contar barcos esconde
   o valor e o custo de cada operação; a margem distingue os portos. `docs/decisoes/009`.
   ⚠️ **E DESDE A `083` O ATRACAR É ESCOLHA, e o simulador tem de a fazer.**
   Os perfis escolhem o barco ao largo (o Ótimo pelo que rende por dia, o
   Mediano pelo mais caro, o Descuidado por quem chegou primeiro), e quem
   escolhe bem atraca acima da média de quem chega: o `projetar_parcelas.py`
   multiplica a margem pelo prêmio MEDIDO, e sem ele reprovou o
   Mediano por 5,5%.
   Desde `085`, usa `premio_em_regime`: comparar a última semana com a mistura
   da partida inteira reprovava o Antecipado por 5,8%. Pagamentos de todas as
   cobranças, inclusive antecipados, saem da margem operacional. A tolerância
   do projetor continua a mesma; suas hipóteses futuras não validam as três
   cobranças jogáveis da Fase 1.
   ⚠️ **A parcela só move quem está perto do limiar.** A calibração de 06/09
   (`008`) e da fila (`083`) usava outra escala e outra distribuição de caixa.
   Reescala e primeira cobrança menor (`084`) são passos separados; meça entre
   eles e não extrapole uma sensibilidade por R$10.000 da moeda antiga.
   ⚠️ **E o jogo perfeito voltou aos 100%** com a trava do nível: a exceção
   medida em 06/09 — o Ótimo a levantar as sete estruturas num sorteio mau e a
   chegar curto — desapareceu, porque o porto que constrói tudo também passou a
   receber navio melhor.
   **Medir é com `-- 600`, e é o que o CI roda desde 05/09.** ⚠️ Esta linha
   anunciava uma amostra de fumaça no CI e ficou a descrever um comando que
   deixou de existir no dia em que o portão das Parcelas passou a precisar de
   uma MEDIÇÃO — no arquivo que carrega sozinho, portanto lido em toda sessão
   (`docs/decisoes/032`). Uma rodada CURTA continua a ser teste de fumaça
   (prova que a ferramenta não quebrou junto com o `GameState`) e tem margem
   de dezenas de pontos: comparar aquele número com estes é comparar sorteio.
   O próprio simulador avisa quando a rodada é curta demais para medir.
   ⚠️ **E PORTÃO ALIMENTADO COM FUMAÇA REPROVA POR SORTEIO.** O CI passava ao
   portão de calibração do `projetar_parcelas.py` a medição de 30 partidas — a
   mesma que o simulador imprime rotulada de TESTE DE FUMAÇA — e comparava-a
   com uma tolerância de 5%. Em 06/09 ele reprovou o Mediano por 5,4% **com o
   modelo certo**: medido com cinco sementes, a margem em regime de 30 partidas
   oscila ±6% a ±9% sozinha, e a semente do CI calhava dar o valor mais baixo.
   Quando um portão compara contra um número MEDIDO, pergunte quanto esse
   número se mexe sozinho antes de escolher a tolerância — e se ele se mexer
   mais do que ela, o defeito é do portão, não do que ele reprova. Hoje o CI
   mede com 600 e o projetor recusa-se a calibrar abaixo de 100 partidas.
   ⚠️ **E RESULTADO MEDIDO NUMA CONSTANTE NÃO SE PREVÊ NOUTRA — nem quando as
   duas entram na mesma razão.** A `/balancear` regista que encarecer as
   ESTRUTURAS inverte a dificuldade (o cauteloso não constrói, acumula e paga a
   parcela). Em 11/09 a F1 leu isso como uma propriedade da razão
   `caixa / custo`, previu a mesma inversão baixando o `START_CASH` e desenhou
   uma varredura inteira para a apanhar: ela **não veio em nenhum dos sete
   pontos**. Encarecer a estrutura mexe só em QUEM CONSTRÓI; baixar o caixa
   mexe nisso e no NÍVEL ABSOLUTO contra a parcela, e o segundo domina — o
   acumulador só ganha se tiver o que acumular. Antes de prever com uma
   medição antiga, confira que ela mexeu na MESMA constante (`018`).
   ⚠️ **E CONTA QUE RESPONDE PELO PRIMEIRO TURNO NÃO DESCREVE 32 DELES.** Na
   mesma F1, `caixa >= custo × folga` pôs um penhasco em 320.000 — abaixo disso
   o Descuidado "não abre com compra nenhuma". Medido, ele levanta o escritório
   em 100% das partidas até aos 200.000 e em 86% a 150.000, porque acumula
   receita e compra no turno 9. Um limiar só vira penhasco quando a partida
   acaba antes de o perfil poupar a diferença.
   ⚠️ **E UMA MUDANÇA DE CADÊNCIA NÃO MOVE O JOGADOR CONTRA A LINHA — MOVE A
   LINHA CONTRA ELE.** Medido em 13/09 ao varrer `TURNS_PER_WEEK` para 7: o
   plano previa que "o porto pobre sente primeiro", e quem sofreu 2,4× mais foi
   o **Mediano** (−37,4 pontos contra −15,8). A regra da `008` — botão só move
   quem está em cima da linha — continua de pé; o que faltava é a outra metade,
   que é **quem está em cima dela pode MUDAR**. A mediana do Mediano atravessou
   a parcela de cima para baixo, e o Descuidado, já do lado errado, tinha menos
   a perder. Antes de prever quem sente uma mudança, pergunte onde ela põe cada
   mediana — e não onde elas estão hoje.
   ⚠️ **E COMPENSAR PROPORCIONALMENTE SOBRECOMPENSA, quando a constante entra
   num LAÇO.** Na mesma medição: encolher a semana 12,5% tirou 12,3% ao Ótimo —
   exactamente a proporção, porque com folga 1,0 ele compra assim que dá e chega
   ao mesmo porto — e **23,9% ao Mediano**, porque a folga de 2,0 deixa de ser
   atingida e *menos receita → porto menor → menos receita*. Daí que devolver os
   mesmos 12,5% no custo das estruturas devolva MAIS do que 12,5% de porto: o
   ponto "coerente" de tudo × 7/8 mediu 100 / 90,5 / 51,5, muito acima do alvo.
   **Constante que alimenta o que GERA a receita não se compensa por regra de
   três** — compensa-se varrendo, e o ponto sai onde a medição o puser.

### Guindastes na Fase 1

Os reparos básicos não promovem o aparelho de madeira (`086`); a treliça é
compra da Fase 2 (`105`), após o píer 2: R$80 mil e dois dias de obra,
provisórios até à etapa 4 da `103`. O nível 2 só entra na conclusão.
A base da máquina está no PNG do píer: `Dock.gd` seleciona
o conjunto n1 aprovado com madeira, preservando capacidade e assets. O nível
intermediário das bancadas é efêmero e restrito a `--script`; não deve entrar
no save nem atravessar partida nova ou carregamento. Madeira limita as classes
a pesca: o pátio continua dobrando a renda do píer, enquanto o adicional de
contêiner aguarda a treliça e o cargueiro na Fase 2. A varredura do recorte
está em `docs/arquivo/MEDICOES_TRELICA_2026-10-14.json`; não substitui a
medição da meta completa na etapa 4. Medir de novo antes de mudar preços.

### Obras da Fase 1

Píer 2 e armazém levam dois dias jogados; pátio, três (`087`, aprovado pelo
Bruno). Uma obra por vez, paga ao iniciar, sem retirar trabalhadores.
`estruturas` guarda só as prontas; `obra_em_andamento` guarda id/início/conclusão.
Dia 1 + dois dias fica pronto no dia 3. Serviços e fechamento semanal usam
o porto antigo; depois a conclusão libera capacidade/renda para o novo dia,
inclusive se a cobrança suspender a abertura. Pagamento de parcela e load
não passam dias. A reação de pronto vem de `obra_concluida`, não da compra.
O simulador soma investimento no início e mede desbloqueio, pagamento e
conclusão separadamente; supor `tem_estrutura` na compra ocultava a despesa.
Obra que ultrapassa o fim da fase é recusada sem cobrança. Arte preservada.
A que só acaba no fecho do dia 84 é aceita e AVISA, no Construir e na
mensagem, que não será usada nesta fase — resposta do Bruno ao D8, «por
enquanto»: com anos de 365 dias ela passa ao dia seguinte (`090`). O prazo que
o jogador lê sai do `prazo_da_obra()`, nunca do `conclusao` cru.

### A segunda chance (`102`)

No vencimento, a quem não tem o boleto, o Sr. Ribeiro empresta o que falta
mais uma semana de custos (salários e manutenção, pelo `_custos_da_semana()`),
devolvido com +12% fixo (`SEGUNDA_CHANCE_ACRESCIMO`) junto da cobrança
seguinte — escolhas do Bruno. Uma vez por fase e nunca na última cobrança. O
`principal_da_parcela()` soma a dívida, e a antecipação não a abate. Crédito
não é lucro: o empréstimo entra no caixa e na linha `emprestimo` da semana,
nunca na receita nem no resultado; o simulador desconta-o da margem.
Nenhum perfil chega a pedi-la (P10 na decisão ≥ R$175.244 na `087`); quem a
valida é o playtest, e o leitor dos registros conta-a.

### Os números de cada fase

Desde a `094` a duração, as parcelas (semana, valor, juros), os reparos
(semana, quitadas, dias de obra), o nível máximo, os berços e a reputação
inicial vivem na tabela `FASES`, e o jogo lê-os por funções — nunca por
`FASES[0]`. Desde a `104` são duas linhas: a Fase 2 abre no dia 85, sem
parcelas e SEM PRAZO (`semanas` em `null`, que rebenta a quem a pedir sem o
`fase_tem_prazo()`), e quem lê a parcela corrente pergunta antes pelo
`tem_cobranca()`. As semanas de parcelas e reparos contam-se do início da
fase; o calendário e o boletim não recomeçam. O simulador mede a Fase 1 e
pára na passagem (`FASE_MEDIDA`); os preços, os dias de obra e a reputação
de partida da Fase 2 são provisórios até à etapa 4 da `103`. Quem mexer no
`valor` de uma parcela da Fase 1 mexe nos `juros` com ele: o F20 exige que o capital das três feche o `START_CASH`, que é o
crédito da `085`. E o `nivel_maximo` não trava nada — é afirmação, e o F20
reprova-a quando um reparo novo leva o porto acima dela.
