# 111 — O cancelamento de serviço no jogo

**15/10/2026.** Bruno respondeu **«Aprovar e autorizar a implementação desse
recorte»** à pergunta que enumerava as regras da `109` recomendadas pela
`110`, incluindo saldo negativo até ao fecho e save 18 com migração 17→18.
Esse é o aceite da implementação; as autorizações anteriores eram de medir
e publicar a entrega experimental. Não estende a autorização de publicação
daquela entrega a um PR novo nem à branch de nomes.

## Base e limites

Main remota confirmada em `b142b80`, merge do PR #132, com o último commit
`7fc6990` incluído. O PR #131 está fundido em `82a9df0`. Nenhum PR aberto
no arranque; decisões na main até a `110`, com a `107` reservada na branch
local `codex/corrigir-nomes-web` (`0a0ab5c`). A `111` era o próximo número
livre. Trabalho em `codex/implementar-cancelamento-servico`, da main remota.

Cancela-se serviço **contratado e iniciado**, nunca obra. Tutorial, segunda
chance e progressão da Fase 2 já existem; trabalhadores extras, crédito
voluntário e A4 continuam fora. O caderno reescrito não foi aplicado.

## Regras aceites e integração

Antes de operar, continua a devolução gratuita ao largo, sujeita ao espaço
na fila. Depois de iniciar e antes de terminar, a confirmação mostra
serviço, dias operados, receita integral abandonada, multa, reputação antes
e depois, caixa atual e resultante. Continuar é a ação com foco inicial;
Voltar e fechar não cancelam. Cartão e cenário abrem o mesmo painel.

Confirmar retira definitivamente o barco e libera doca e trabalhador no
mesmo dia. Não avança calendário, gera chegada, remunera dias parciais nem
cumpre missão. Perde cinco pontos, com limite de zero, e paga multa de 10%
do valor efetivamente acordado, sem adicionais, arredondada para cima.
Conta uma perda e um cancelamento, sem acrescentar a penalidade da fila.
Marcos já conquistados permanecem.

O orçamento inteiro e a identidade do barco são revalidados. Confirmação
repetida, painel dispensado ou serviço/custos alterados não cobram de novo.
O overlay bloqueia os toques e o avanço pelo Main, sem criar estado de turno.

Saldo insuficiente não bloqueia: a multa sai agora e a derrota continua
sendo avaliada no fecho real. A despesa entra no dia e na semana, nas
leituras financeiras e recordes. A projeção inclui o lançamento já pago e
explica que não o cobrará novamente. Não há receita negativa nem reembolso.

Registro **5**, com evento próprio por cancelamento: dia, doca, identidade
do contrato, classe, motivo, progresso, valor acordado, receita abandonada,
multa, caixa e reputação antes/depois, sem nome pessoal. O leitor distingue
versões anteriores, que não observavam cancelamento, de zero ações na 5.

Save **18**: a migração 17→18 acrescenta apenas as despesas de cancelamento
e os acumuladores de quantidade/multas a zero. Conserva a partida e a cadeia
desde a 14. Os exemplos 14–17 permanecem intactos. O novo exemplo é jogado
até ter conquista, contrato cancelado e multa reais; a retomada preserva
inclusive caixa negativo antes do fecho.

## Verificação

O T24 exercita ação, contabilidade, retomada/migração, as duas portas da
interface e o evento do Registro; roda dentro da suíte de lógica. A bancada
da `110` permanece independente; um adaptador usa a ação real com o mesmo
percurso e formato de eventos para conferir paridade. As capturas novas
jogam desde o dia 1 até um cargueiro iniciado, incluindo confirmação,
aviso de saldo negativo e contas depois da multa. Resultados finais e
limitações ficam em
`docs/arquivo/VERIFICACAO_CANCELAMENTO_2026-10-15/README.md`.

A comparação integral deu paridade com a bancada atual **e** os dados selados
da `110`: cinco políticas de custos aprovados, 600 partidas por perfil,
semente 20260825, 365 fechos — **12.000 partidas de produção**. Não se
compararam só médias: todos os campos, eventos, perdas, censuras e percursos
dos JSON coincidiram. As oito partidas com/sem autosave e seus 16 eventos
também coincidiram. A Fase 1 medida permaneceu integralmente igual à referência.
Isso prova a integração desse comportamento; não transforma as trocas em
promessa de lucro nem amplia os denominadores e conclusões da `110`.

O T24 recusou oito defeitos semânticos: multa, reputação, trabalhador,
conta semanal, migração, identidade, orçamento e evento de registro. Cada
controle restaurou os bytes e voltou a passar antes do próximo defeito.
O comparador recusou campo/partida removidos, perfil/evento alterados e
booleano trocado por número; a cópia idêntica deu igualdade integral.
As três capturas foram olhadas: custos e saldo visíveis, aviso negativo e
contas sem nova cobrança. O erro de formatação que havia ocultado a multa
foi corrigido e ganhou verificação do texto real; a armadilha está comentada
em `PainelCancelarServico.gd`.

As seis suítes passaram novamente após os últimos ajustes, com código zero,
marcador final e sem `SCRIPT ERROR` ou `push_error`: lógica, design, áudio,
fumaça, registro e assets. Leitor, tabela, calibração e sentinela passaram;
os arquivos do jogador ficaram intactos. Os exemplos 14–17 e o commit da
branch de nomes também permaneceram intactos.

A importação continua com `Safe save failed`, sem causa/arquivo isolados
(`110`); não se declara limpa. As provas locais não substituem CI de um PR
novo nem o teste no telefone. O último CI remoto verde conferido é o do
PR #132 (`7fc6990`) e do seu merge (`b142b80`); ambos voltaram a ser conferidos
no fecho, com nenhum PR aberto. A próxima decisão livre é `112`, mantendo
a `107` reservada e separada.

Bruno também pediu, **depois deste recorte**, uma revisão de recursos básicos
que possam ter faltado, citando tela inicial e como salvar. É inspeção da
experiência atual, sem autorização implícita para outra frente de alterações.
