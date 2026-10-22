# Próxima conversa — início, Configurações e fundo, 20/10/2026

Continuando o BR Port em `br-port/`, branch local `codex/inicio-configuracoes`,
base remota `f70b45c32db8d9c9556d81797e42a2471ccbefd9`. Conferir o HEAD real
e o recibo local de fecho antes de prosseguir. Sem novo PR ou publicação.
Não pedir outra escolha geral nem iniciar outra frente.

Leia AGENTS.md, CLAUDE.md, `.claude/rules/gerais.md`, o estado, a §7 do plano
v3 e as regras dos arquivos envolvidos. Leia a decisão `132`,
`docs/arquivo/VERIFICACAO_INICIO_CONFIGURACOES_2026-10-20/README.md`, o recorte
de texto de 19/10 e a `131`.

Bruno pediu quatro entradas na inicial — Continuar, Nova partida, Saves e
Configurações —, os extras dentro de Configurações, corrigir Reduzir movimento
que ficava branco, trocar o fundo e entender a ausência do tamanho de fonte.
Autorizou dividir as atividades entre conversas. Menu e contraste estão
implementados localmente; a pausa usa suas consultas anteriores. Voltar de
uma consulta devolve o mesmo menu. Saves abre o painel dos três espaços.
Sem partida, Continuar fica inativo com explicação. Não se muda o save.

O estado que falhava era `hover_pressed` do CheckButton: estilo transparente
do motor com letra branca sobre cartão branco. O tema agora o define; a
guarda T30 mede os quatro estados e a foto registra o controle ligado sob
o ponteiro. A regra aprendida está em `.claude/rules/interface.md`.

A ilustração v1 teve o estilo elogiado. Bruno pediu: “ao invés do porto ficar
na lateral, pode ficar na parte de trás que nem no jogo”. A v2, em
`art_lab/tela_inicial/v2/fundo.png`, preserva o estilo e põe cais e vila ao
fundo, com píeres em direção ao mar. Sua foto real está em
`.evidencias/inicio-configuracoes/2026-10-20/inicial-candidata-v2.png`.
O aceite dessa versão ainda não chegou; seleção predefinida não é aceite.
O fundo de produção continua o degradê. `art_lab/README.md`, §3.5, exige
aceite na foto de runtime antes da passagem a `brport_vs/`; a skill `/arte`
orienta o veredito. Se Bruno aceitar, integrar só na inicial, preservando
`TelaInicial.FUNDO`, que já é usado pelo celular. Não mudar o papel de parede
ou o logotipo sem incluir isso no recorte. Fonte nativa 941×1672 RGB, original
sem retoque; a diferença para os 1080 px do briefing antigo está registrada.

Tamanho de fonte global ainda não existe. O #145 entregou só a bancada RB5
por `--script`, excluída dos exports. A pergunta específica de referência de
leitura continua sem resposta. Tamanho, acomodação e telefone pendentes;
não implementar preferência global/persistente nem redesenhar o HUD sem
recorte específico. A bancada achou sobreposição em +25% e corte em +50%.
Texto e movimento terão de coexistir no disco: o setter atual de movimento
cria ConfigFile novo e grava só sua chave; não o ampliar silenciosamente.

Validação local final aprovada: `MUTANTES OK`, 130 ids e todos os 130 pares
suíte/rótulo confirmados nas reprovações reais; seis suítes com marcadores
antes/depois, sem erros nas bases. Sentinela dos seis arquivos intacta e
1.645 arquivos selados idênticos antes/depois e na conferência final.
As explorações detectaram os seis defeitos novos. Dos 124 anteriores, 123 entradas são
idênticas e `movimento-duplica-ajustes` conserva defeito/guarda T29 contra a
porta nova. Catálogo total: 130 ids/pares. Bateria de 107 imagens aprovada,
mais duas fotos complementares da inicial vazia e ajuda atualizada, com
marcadores e sem erros; imagens relevantes inspecionadas. A candidata foi
fotografada à parte, não integra essas 109 fotos de produção.

O #145 foi mesclado pelo Bruno, sem merge do Codex. Seu CI final aprovou
a junção `bd804725d5e553153670a638f8628d0b6cdcbde0`, de árvore igual ao head
`bd3083716fd6582236c44f8a3b34392cd11244f6` e à main resultante. Marcadores,
124 pares e identidade exportada Web foram conferidos nos logs oficiais.
Testes `39361815077` e Captura `39361815094` success; a main também concluiu
Testes `39367409196` e Captura `39367409279`/success. Nada disso aprova o
commit local novo, que ainda não tem CI próprio.

Antes de editar/publicar, conferir status/log, commits fora da main, todas
as refs remotas, PRs e CI pelo conector GitHub. A consulta final manteve 270
refs/125 heads idênticas, main em `f70b45c` e nenhum PR aberto; `132`, T30 e briefing de 20/10 estavam
livres. Não são reservas: repetir o pré-PR e conferir colisões antes de nova
publicação autorizada. Shell não alcançou o proxy; não repetir nem contornar.
Main foi importada integralmente pelo conector e reproduzida por SHA;
`origin/main` atualizado localmente por CAS, branch `work` preservada.

Preserve `.evidencias/` inteira, `refs/codex-backup/`, outros trabalhos e
registros de worktrees. O novo acervo está em
`.evidencias/inicio-configuracoes/2026-10-20/`; a consulta do CI anterior em
`.evidencias/texto-ajustavel/consulta-ci-2026-10-20/`. O acervo original da
bancada não estava montado; não o chamar de recuperado ou apagado. Não prometer
montagem ou persistência em outra sessão. Não reenviar sem alteração os
recibos antigos recusados pela revisão automática por caminho local.

Claude segue no visual. Vegetação `130`/#144 e RB6 #143 já mesclados;
telefone e aceite visual RB6 pendentes. Não editar MataNoMapa, seus testes,
arte ou geradores em paralelo. Não reutilizar/resetar as branches antigas
de movimento ou diagnóstico. RB2, diagnóstico e Como jogar já existem;
não reabrir aceites 114–116. Sem merge, force ou push para main/Claude.
Sem alteração de save/SAVE_VERSION/migração, economia, RNG, duração, dia,
missão ou meta; sem Engine.time_scale, autoload novo, novos trabalhadores,
crédito voluntário, cancelamento de obras ou outra etapa da Fase 2.
Não apagar dados do navegador.

As capturas usaram Xorg virtual sem TCP, encerrado pelo PID conferido.
Permissões e ferramentas locais precisam ser conferidas de novo; não
presumir sua montagem. Ao encerrar, aplicar `/fechar-sessao`, conferir o CI
do HEAD final e entregar o prompt completo copiável apenas na última parte.
