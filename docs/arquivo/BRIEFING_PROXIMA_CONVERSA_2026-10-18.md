# BR Port — Reduzir movimento, RB6

**18/10/2026.** Bruno escolheu a opção 2, RB6. Branch
`codex/reduzir-movimento`, PR #143 em rascunho, decisão `129`, base
`56b3983` após o merge do #142. Não foi feito merge desta entrega.

## Entrega e prova

Ajustes pelo início e pausa oferecem preferência persistente, independente
dos espaços da partida. Ausente/inválida mantém movimento padrão; falha ao
gravar é explícita e a escolha vale na sessão. O ArmazemLocal separa
jogador/ferramentas. Sem autoload novo, alteração do save ou time_scale.

O inventário da 129 separa fundo, transições e operação. Ciclos decorativos
ficam parados, fauna conserva pose/toque/som, tráfego sem visita é oculto;
visitas ao berço e operadores continuam. Realces fixos conservam a escolha.
Caixa é imediato, ganho continua legível com descarte independente, folha
conclui a navegação mesmo quando a preferência muda durante a transição.

T29 próprio, com bandeira final; 17 defeitos novos no catálogo oficial,
114 no total, preservadas as 97 entradas anteriores. Seis suítes locais
passaram; a exploração mediu as guardas e voltou à base verde. A prova de
reinício passou por processos de ferramenta e por aplicação sem --script,
com o mesmo singleton/leitor do jogo. Sentinela com seis arquivos intacta.
Resultados integrados e imagens do HEAD atual ficam no CI/PR #143; conferir
o HEAD antes de declarar aprovação. Reprodução e parâmetros em
`docs/arquivo/VERIFICACAO_REDUZIR_MOVIMENTO_2026-10-18/README.md`.

Os pares temporais usam seed 42, FPS fixo 60, frames 30/150, janela 720×1280
e mapa `[0,62,720,782]`. Manifestos conservam turno/caixa/RNG; a régua exige
controle normal com movimento e fundo reduzido estável. Também há Ajustes
pelas duas portas e resultado de serviço. Sem promessa de desempenho.
Artefato pequeno `brport-rb6` permite inspeção pelo conector.

## Colaboração e ambiente

Bruno confirmou nesta conversa: **o Claude segue no visual; manter a
divisão**. WIP `67b2641`, `ccr-d445dbad-nogxh2`, sem PR na consulta inicial.
Não se editaram MataNoMapa, seus testes, arte nem geradores. A integração
usa sua API pública. O WIP deixa órfãos `mata-copia-desalinhada` e
`mata-contorno-cego`; preservar as provas, a frente visual atualiza seus
alvos. A `127` continua sem aceite; item 1 da `126` continua, estradas e
sprites de detalhes esperam; marolas/fio diagonal norte ficam depois.

Main #142: Testes 39092953955 e Captura 39092953904 concluídos/success.
O log oficial 117573371694 confirmou 97 mutantes e cinco arquivos intactos.
Isso descreve a base, não aprova o HEAD novo. #140/#141 também mesclados;
Meu porto agora e diagnóstico não foram refeitos.

O shell não alcançou o proxy. Um pedido adicional de rede ficou pendente
e foi interrompido; não repetir sem necessidade. A sincronização e a
publicação usam o conector GitHub, objetos/fontes conferidos por SHA e
expected_sha sem force. Todas as refs precisam ser reconferidas antes do
pré-PR sem fetch. Não há xvfb instalado local: o CI desenha as capturas.
Não repetir o download grande do #142, que excedeu 32 MiB; isso não era
falha de CI. Evidências desta entrega em `.evidencias/reduzir-movimento/`.

Ferramentas derivam o padrão, sem herdar preferência de outra captura;
leitura de persistência e variante reduzida são explícitas. A razão e o
contrato vivem em `PreferenciasDeApresentacao.gd` e na decisão 129.
Suítes/capturas/mutantes não rodam juntos na mesma pasta de ferramentas;
a regra está no `CLAUDE.md`. Registros antigos e falhas iniciais foram
preservados, sem relaxar guardas antigas para a apresentação reduzida.

## Prompt completo para retomar

```text
Continuando o BR Port no repositório br-port/. Retome somente RB6 — Reduzir
movimento, decisão 129, branch codex/reduzir-movimento e PR #143. A opção 2
escolhida pelo Bruno é RB6; RB2/Meu porto agora já está implementado.
Não escolha outra frente nem peça de novo uma escolha geral.

Leia AGENTS.md, CLAUDE.md, .claude/rules/gerais.md, o estado e a §7 do plano
v3 na main atual. Leia pesquisa de recursos básicos (RB6), decisões 125–129,
este briefing e docs/arquivo/VERIFICACAO_REDUZIR_MOVIMENTO_2026-10-18/README.md.
Carregue regras de interface, save, GDScript, testes, captura, plataforma,
mapa/arte/projeção e demais temas conforme os arquivos envolvidos.

Confira git status/log, commits locais fora da main, todas as refs remotas,
PRs e CI do HEAD atual antes de editar. Preserve trabalho existente e os
backups em refs/codex-backup/. Não faça merge, force, push para main ou
claude/*, nem reset de branch encerrada. Se #143 já estiver mesclado, não
continue na branch encerrada. Número de decisão e nome de briefing contam
todos os ramos dos agentes; não reserve números futuros por suposição.
Repita o pré-PR imediatamente antes de publicar.

RB6 oferece Reduzir movimento nos Ajustes do início e pausa. Lembra a
preferência fora dos três espaços; ausente/inválida conserva padrão, falha
de escrita é explícita. Aplica aos nós abertos e aos criados depois.
PreferenciasDeApresentacao usa ArmazemLocal e distingue jogo/ferramentas;
ferramentas comuns começam no padrão, variante e leitura da sonda são
explícitas. Não acrescente autoload ou funções de salvamento da partida,
migração, SAVE_VERSION, alteração de duração, dia, economia, RNG, missão,
meta ou conteúdo do save. Não use Engine.time_scale. Não amplie para texto
ajustável, outros recursos básicos ou redesenho de arte/enquadramento.

Inventário da 129: fundo parado (espuma, vegetação, boias, luzes, balanço),
fauna estática com toque/som, tráfego sem visita oculto. Visitas operacionais
e ciclos de operadores/carga ficam. Pulsos viram realce fixo. Caixa final
imediato e ganho fixo pelo mesmo tempo de leitura, descarte fora do tween
pausado. Folha retorna um tween com intervalo zero e callback preservado;
mudar a meio completa a cadeia. Preserve informação, seleção, progresso,
resultados, ações, retorno e Voltar do aparelho. Sem promessa de desempenho.

T29 em casos_reduzir_movimento.gd, com bandeira final; 17 movimento-* no
catálogo oficial, 114 defeitos nesta entrega. Preserve as 97 provas antigas
e atualize alvos que modificar, sem apagar guardas. Seis suítes locais e
exploração tiveram base verde; confira resultado integrado e marcadores
finais do HEAD atual no CI, sem herdar verde anterior. Sonda Python prova
persistência em processos distintos, ferramentas e aplicação sem --script,
com seis arquivos de sentinela. Telefone e aceite visual dependem do Bruno.

Captura controlada em capturar_movimento.gd/comparar_movimento.py, integrada
à bateria. Semente 42, FPS fixo 60, frames 30/150, dois segundos, 720×1280, mapa
[0,62,720,782]; JSON registra turno/caixa/RNG. Mesma imagem deve dar zero,
normal tem movimento e fundo reduzido fica estável. Artefato brport-rb6 é
pequeno: baixar pelo conector, comparar pares e inspecionar telas. Imagem
estática sozinha não prova redução. Preserve cenários, parâmetros e logs.

Bruno confirmou: Claude ativo no visual; manter essa divisão. WIP conhecido
67b2641 em ccr-d445dbad-nogxh2, mas consulte informação/PRs atuais. Não editar
MataNoMapa.gd, seus testes, arte/geradores em paralelo. RB6 usa apenas sua
API pública nos()/rajadas(). O pré-PR da reserva avisou dois mutantes órfãos
no WIP visual: mata-copia-desalinhada e mata-contorno-cego; as provas foram
preservadas e a frente que mudou os alvos deve adequá-los. Decisões 125 e
126/127 continuam distintas. A 127 NÃO tem aceite; terreno/vegetação seguem
no item 1 da 126. Estradas/sprites esperam, marolas/fio norte ficam depois.

#140 Meu porto agora, #141 visual e #142 diagnóstico foram mesclados. Base
desta entrega 56b3983. CI pós-merge da base: Testes 39092953955 e Captura
39092953904 completos/success, job 117573371694 com MUTANTES OK 97 e sentinela 5.
Não use esse resultado para aprovar outro HEAD. Branch codex/versao-diagnostico
encerrada. Diagnóstico pelo início/pausa tem build real, prévia e cópia
explícita; não lê nomes/save/registro/partida nem envia dados. Registro fica
nos Ajustes. Gerador gerar_identificacao_build.py gera recurso ignorado antes
do export; editor diz local, árvore modificada leva marca; CI confere PCK.
Em PR o SHA identifica a junção testada; no Pages, o commit da main.

Continuar/Carregar já mostram Meu porto agora depois da carga válida e
antes de Main, sem efeitos após a carga. Recibo pago não vira dívida,
Fase 2 sem prazo, jogo livre sem nova meta, encerrada sem promessa futura;
nova partida direta. Não reimplemente RB2 nem trate o traceback antigo do
catálogo em conflito como bloqueio: foi corrigido no #141.

Bruno usa celular e aprovações podem não aparecer. Priorize conectores e
autorizações existentes; explique no chat uma aprovação obrigatória da
plataforma, sem prometer controlar a UI/persistência e sem contornar recusa.
Shell sem rede não alcança proxy; GitHub conector funciona. Git Data com
expected_sha sem force, fontes conferidas por SHA. --sem-fetch só com refs
e objetos necessários atuais, sem COLABORACAO global baseada no checkout.
Não repetir download grande #142 para pedir rede: exceder 32 MiB não falhou CI.

Preserve .evidencias/ inteira onde existe: ajuda/cancelamento, pesquisa,
revisão, implementar-como-jogar/, publicacao-pr-134.json, meu-porto-agora/,
versao-diagnostico/ e reduzir-movimento/. Preserve codex/implementar-cancelamento-servico, codex/implementar-como-jogar e codex/corrigir-nomes-web.
A última guarda decisão 107 e 0a0ab5c locais, sem publicação autorizada ou teste
no telefone. Clone abriu em work na 0ce0421; checkout Windows anterior 72039cb
em codex/meu-porto-agora não está montado: ausência aqui não é exclusão.

Como jogar está na main; não reabrir aceites 114–116. Leitura nova, telefone,
A4 e caderno reescrito pendentes. Safe save failed sem causa isolada. Não
adicionar trabalhadores, crédito voluntário, cancelamento de obras, novas
funções de save ou outra etapa da Fase 2. Não ampliar pacote básico.
Pages usa GitHub Actions (099/plataforma.md); protótipo em /prototipo/.
Se página errada reaparecer, conferir fonte, SHA e último workflow publicador;
pages build and deployment verde não prova Godot. Não apagar dados do
navegador que possam conter partidas.

Mantenha continuidade com decisões, restrições, branch/PR, arquivos,
resultados e pendências. Avise se conversa longa, sem prometer compactação
manual/contador exato. Ao encerrar aplique /fechar-sessao, confira CI do
HEAD final e entregue prompt completo copiável como última parte da resposta.
```
