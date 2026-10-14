# 106 — A meta, a regressão e o diário da Fase 2: etapa 3 da `103`

**14/10/2026.** Base `a95bf07`, merge do PR #129 (`105`) confirmado no
GitHub. Nenhum PR aberto; 106 livre conferida na main antes de editar.
Sem notas novas das falas do A4 no repositório ou na discussão do PR.
Bruno pediu só a etapa 3 e autorizou explicitamente o **save 17 com migração**.

## As três barras e o fecho

O cartão da meta no rodapé abre um painel com **reputação, infraestrutura e
missão**. A reputação pede **80 ou mais em três fechos de dia seguidos**;
um fecho abaixo recomeça a sequência. Comprar, negociar, pagar, consultar
ou carregar um save não contam dias. A infraestrutura conta o **píer 3 e
a treliça prontos**, sem contar uma obra em andamento ou o escritório.
A missão conta o **primeiro cargueiro descarregado e pago**, não sua chegada
ou atracação. Pode ser de qualquer motivo; o granel mantém seu dia adicional.

Os três requisitos são simultâneos. A quebra por dinheiro negativo tem
prioridade sobre a conquista no mesmo fecho. Cumpridos, o motor marca a
conquista antes de emitir `fase_concluida(2)`, para a chamada reentrante e os
fechos seguintes não abrirem outra página. Não passa à Fase 3: permanece na
2, sem dívida e sem prazo, em **jogo livre**. A conquista e a missão não
regridem; depois da conquista a barra dos dias conserva os três.

Uma página do mesmo caderno fecha a Fase 2, pela vez do `Main`. Sai por
**«Seguir em jogo livre»**, e pode ser relida pelo painel da meta depois de
retomar a partida. Oferta do Arlindo sorteada na mesma abertura espera a
página, como a oferta que já esperava a resposta do banco. O texto é
rascunho para o A4; não promete uma Fase 3 jogável.

## O piso dos cargueiros

**Abaixo de 40 de reputação, novos cargueiros deixam de chegar.** Com 40
ou mais voltam ao sorteio, se o porto tiver nível para eles. Pesca continua;
os barcos já ao largo e os já contratados não são apagados e terminam seus
serviços normalmente. O piso vale também no jogo livre após a conquista.
A regra aparece no painel da meta, na Reputação e no Construir: a fase
conquistada permanece, são os novos clientes que se suspendem.

**80 e 40 são patamares provisórios.** Conservam a ordem que a `103` exige
— piso abaixo do início 65, meta acima dele —, sem mudar preço, serviço,
reputação inicial ou prazo de obra. A etapa 4 mede dias até a meta e quebras
por perfil e fecha esses números junto dos preços. O percurso semeado das
capturas e o exemplo de save demonstram acesso; não certificam balanceamento.

Sem cobrança, o aviso de dinheiro curto compara o saldo com **uma semana de
salários e manutenção**, sem deduzir a renda futura. A Dona Cida tem uma
fala própria, sem parcela pendente; a fala de semana parada usa a variante
que não promete cobrança. A abertura de uma partida retomada também deixou
de afirmar que só há um píer de pé: esse texto fica só na partida nova em
ruínas. Ambos os rascunhos seguem para a leitura do A4.

## Save 17 e os exemplos antigos

Entram `dias_de_reputacao`, `primeiro_cargueiro` e `meta_concluida`. Partida
nova e passagem para a Fase 2 zeram os três; o load repõe-os sem contar dia.
Tipos, limites e conquista sem missão, dias ou infraestrutura são recusados
antes de escrever estado vivo. A conquista carregada continua válida com
reputação abaixo do piso, como o desenho pede.

O degrau **16→17** conserva dia, dinheiro, porto, obras e contratos e
começa o acompanhamento a zero. A 16 não guardava a classe dos barcos
servidos nem a reputação de cada fecho; usar o total de barcos para inventar
um primeiro cargueiro cumprido seria adivinhar. Não há replay da página na
migração. Os exemplos **14–16 permanecem intactos**. O novo `v17.json` é
uma partida jogada até o dia 102, com conquista, missão e três dias cheios,
além de obra viva, barco atracado, fila, recibo da Fase 1 e recordes.

## Verificação e evidência

O **T22** exercita os fechos, a interrupção da sequência, as três barras
montadas, o serviço em dois dias, piso e recuperação, contrato vivo abaixo
do piso, prioridade da quebra, conquista permanente, nova partida, migração
e recusa de progresso inválido. Abre pelo toque real do rodapé e confere a
página automática e a oferta sorteada que espera por ela. Sua bandeira
final prova que o caminho assíncrono correu. O F21 carrega e regrava o save
corrente inteiro; o F23 lê a nova porta da meta na Fase 2.

Os estados da meta em progresso, conquistada e suspensa e a página do diário
entraram no percurso de contraste do D33. As capturas da etapa 3 entram na
bateria do CI por `capturar_fase_2.gd`, que joga desde o dia 1, com compras
e saldo reais, e não avança sob modal. Evidência e controles em
`docs/arquivo/EVIDENCIA_META_2026-10-14/`.

As seis suítes passaram com seus marcadores e sem `SCRIPT ERROR`;
o nome mais largo foi medido também na faixa retomada e na nova página.
Oito defeitos injetados, cada um com base restaurada verde antes do seguinte:

| Defeito | Reprova |
|---|---|
| sem recomeçar os dias após fecho abaixo da meta | T22, sequência e dias seguintes |
| sem filtrar os cargueiros abaixo do piso | T22, classes disponíveis e barcos sorteados |
| conquistar novamente em cada fecho | T22, desfecho único e jogo livre |
| terminar cargueiro no primeiro dia | T22, missão antes da descarga completa |
| load sem repor a conquista | T22, conquista conservada com reputação baixa |
| migração inventando missão cumprida | T22, degrau 16→17 |
| barra de infraestrutura retirada do painel | T22, três barras e seus valores |
| saída do diário dizendo «Jogar de novo» | T22, botão único de jogo livre |

A primeira base do controle da sequência expôs um defeito do fixture: ele
igualava a oferta sorteada ANTES do fecho e somava reputação depois de preparar
79,99. O caso agora descarta a chegada aleatória para isolar o fecho, e semeia
a própria montagem; a oferta real continua no caminho separado do diário.

A Fase 1 manteve **zero diferenças em 712 valores**, com 600 partidas por
perfil e semente 20260825, comparadas com `a95bf07`. A régua deu zero com o
mesmo arquivo e uma diferença com uma folha alterada. Tabela dos números,
projetor das parcelas, escopo de UI e guardas do CI passaram; os cinco
arquivos da sentinela do jogador ficaram intactos. Na captura, a conquista
chegou ao **dia 100, reputação 84 e R$520.131**, com nove cargueiros atendidos;
a regressão foi jogada até **dia 104, reputação 35**, preservando os barcos
que já tinham chegado. Todos os painéis inteiros cabem em 720×1280.

A etapa 4, a medição completa da Fase 2, continua aberta na §7 do plano.

## Correção da verificação de captura do PR #130

A primeira corrida de Captura passou no HEAD, mas o import de Patrick Hand
na base `a95bf07` abortou com sinal 11 e `propagate_notification()` chamado
por um trabalhador. A repetição passou. O padrão coincide com o
[bug confirmado de importação paralela de fontes](https://github.com/godotengine/godot/issues/111039);
não era um erro de GDScript da meta nem da fotografia da base.

Os cinco imports dos workflows agora passam por `tools/importar_para_ci.py`.
O helper usa a [chave documentada no Godot 4.6](https://docs.godotengine.org/en/4.6/classes/class_projectsettings.html#class-projectsettings-property-editor-import-use-multiple-threads)
`editor/import/use_multiple_threads=false` em um `override.cfg` temporário,
exclusivo, removido antes dos testes, exports e fotos. Preserva a versão
4.6.3, o retorno de falha do motor e os scripts próprios da base.

Uma sonda com o Godot real lê a chave a falso, importa a fonte e prova a
limpeza. Os controles também exercitam saída 17, executável ausente e
override preexistente sem alteração. O mutante que escreve `true` reprova
na leitura real do motor; a base restaurada passa. Resultado guardado em
`docs/arquivo/EVIDENCIA_META_2026-10-14/importacao-ci.log`.
