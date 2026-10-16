# BR Port — novos recursos básicos que podem ser adicionados

**15/10/2026 — pesquisa e proposta, decisão `112`.** Bruno esclareceu que
queria novos recursos, além da inspeção do que já existe. Depois autorizou
publicar um PR reunindo o cancelamento aprovado e esta pesquisa para integração
na main. A autorização publica as propostas; não implementa esta lista inteira.

## O que esta pesquisa acrescenta

A `REVISAO_RECURSOS_BASICOS_2026-10-15.md` continua preservada: inventário,
falhas de gravação, recuperação e outros achados úteis. A resposta anterior
ficou concentrada nesse inventário; este documento responde à pergunta mais
ampla: **o que um jogador pode ganhar que ainda não encontra no BR Port?**

Método: páginas públicas dos próprios autores das recomendações, consultadas
em 15/10/2026, cruzadas com os menus e painéis do código desta branch. Não é
levantamento estatístico de jogos concorrentes, pesquisa com jogadores ou
certificação de acessibilidade. As prioridades e os recortes abaixo são
inferências para este jogo; esforço é julgamento relativo, sem prazo medido.
As referências Xbox/Steam informam o design, sem criar alvo de lançamento
nessas plataformas ou substituir os testes no telefone.

## As adições recomendadas

| Recurso novo | O que entregaria ao jogador | Primeiro recorte proposto | Prioridade / esforço relativo |
|---|---|---|---|
| **RB1 — Como jogar e glossário** | Consultar uma dúvida a qualquer momento | Entrada na pausa e no início; assuntos curtos: atracar, avançar, dinheiro/semana, salvar/retomar, devolução versus cancelamento e metas. Explicar termos como acordo, multa e reputação | Alta / baixo a médio |
| **RB2 — Meu porto agora** | Lembrar onde parou depois de dias sem jogar | Resumo opcional ao Continuar: fase/dia, obra e operação em curso, próxima cobrança quando existir, meta e atalhos para detalhes. Em jogo livre, dizer isso | Alta / médio |
| **RB3 — Salvar agora e estado do salvamento** | Guardar sem sair e ter certeza de qual partida foi gravada | Ação explícita na pausa, resultado real da escrita e indicação de espaço/última gravação bem-sucedida. Autosave continua. Não anunciar sucesso só por tocar | Alta / médio; depende da correção da gravação |
| **RB4 — Cópia da partida e recuperação** | Levar o porto a outro aparelho ou recuperar uma cópia válida | Exportar/importar um espaço com confirmação e validação; cópia anterior e proteção do ilegível. Começar por arquivo manual, sem conta obrigatória ou nuvem | Alta para proteção, seguinte para transporte / médio a alto |
| **RB5 — Tamanho de texto ajustável** | Ler HUD, conversas e contas com conforto | Ajuste persistente no início e na pausa; ampliar texto e reorganizar painéis, com rolagem quando necessária. Definir faixas depois de protótipo no aparelho | Alta / médio a alto |
| **RB6 — Reduzir movimento** | Manter a informação com menos distração visual | Preferência para reduzir animação decorativa e transições; preservar sinais de operação, resultados e ações. Não mudar duração dos serviços nem a economia | Média / médio |
| **RB7 — Ajuda contextual opcional** | Descobrir o que pode tocar e entender por que uma ação está indisponível | Modo de ajuda acionável pelo jogador: explicar HUD e custos/requisitos a partir do estado real; desligável, sem interromper cada turno | Média / médio |
| **RB8 — Sobre o jogo e relatar problema** | Identificar a versão e comunicar uma falha sem adivinhar o que enviar | Tela com versão/build, créditos e licenças verificadas; copiar diagnóstico mínimo, com prévia e opção de incluir o registro já existente. Nenhum envio automático | Média, útil antes de ampliar playtests / baixo a médio |

### Por que esses recursos, e não apenas mais telas

**RB1 e RB7:** as Game Accessibility Guidelines recomendam consulta posterior
de controles e mecânicas e orientação contextual. No BR Port, tutorial do
Toninho já existe, mas não há uma central de ajuda. Texto consultável é um
primeiro recorte próprio; não se deve chamá-lo de tutorial interativo completo.
Repetir a prática do tutorial em ambiente separado é expansão possível, com
proteção da partida, a decidir depois.
[Consulta de controles e mecânicas](https://gameaccessibilityguidelines.com/indicate-allow-reminder-of-controls-during-gameplay/),
[orientação contextual e indicação de interação](https://gameaccessibilityguidelines.com/full-list/).

**RB2:** a XAG 109 recomenda objetivos revisáveis e resumos que apoiem a
retomada. Aplicação proposta: reunir os fatos do porto e apontar para painéis
existentes. Não é criar outras missões ou um algoritmo que prometa a melhor
decisão. A meta da Fase 2 já tem barras e critérios; falta uma visão de retomada
que atravesse as duas fases.
[Microsoft — clareza de objetivos](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/109).

**RB3 e RB4:** GAG e Steamworks recomendam gravação manual além da automática;
Steamworks também recomenda separar os pontos manuais dos automáticos. Nossa
proposta acrescenta controle e retorno explícitos. Se houver **ponto manual
protegido**, o autosave não poderá sobrescrevê-lo; isso é uma extensão a desenhar,
não uma propriedade dos três espaços atuais. Exportação e recuperação são
inferências para a distribuição Web/telefone deste projeto, não uma exigência
dessas fontes. Copiar o registro de acontecimentos não transporta o save.
[GAG — gravação manual](https://gameaccessibilityguidelines.com/provide-a-manual-save-feature/),
[Steamworks — Save Anytime](https://partner.steamgames.com/doc/accessibility_features#Save%20Anytime).

**RB5:** a XAG 101 recomenda ampliar texto preservando conteúdo e funções.
Aplicação: a pessoa escolhe tamanho e continua conseguindo ler custos e confirmar
ações. As dimensões em pixels de uma plataforma não serão copiadas para o
viewport lógico do Godot: densidade e tamanho físico exigem ensaio no telefone.
É uma preferência de apresentação, sem reabrir enquadramento ou projeção.
[Microsoft — apresentação de texto](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101).

**RB6:** GAG recomenda opção de ocultar movimento de fundo. O BR Port tem água,
trânsito e animações que podem ser tratados como decoração ou informação;
essa distinção precisa ser mapeada antes de desligar qualquer um deles. Não
se promete melhora de desempenho sem medição.
[GAG — opções para movimento e distrações](https://gameaccessibilityguidelines.com/full-list/).

**RB8** é inferência de produto para o A7: o projeto já permite copiar o
registro, mas isso não é uma tela de versão, créditos e diagnóstico guiado.
Licenças serão conferidas nos materiais admitidos; ausência de uma tela não
prova ausência de atribuições nos pacotes. Não se coletam nomes ou saves por
omissão. Uma saída local para o jogador decidir o que compartilhar basta.

## Conferência com o jogo atual

| Já existe | Onde foi conferido | O acréscimo que faz sentido |
|---|---|---|
| Início, Continuar, Carregar e três espaços | `TelaInicial.gd`, `PainelEspacos.gd` | RB2 e RB3 complementam esses fluxos |
| Autosave e Salvar e sair | `GameState.save_game()`, `Main._sair_para_inicio()`, `PauseMenu.gd` | RB3 e RB4; falhas técnicas preservadas na revisão anterior |
| Tutorial curto do primeiro dia | `TutorialDoToninho.gd`, `101` | RB1 consultável e RB7 opcional, sem refazer a entrega aceita |
| Caixa projetado, calendário, reputação e metas | `PainelCaixa.gd`, `PainelCalendario.gd`, `PainelReputacao.gd`, `PainelMeta.gd` | RB2 reúne atalhos; não duplicar os cálculos |
| Requisitos de obras e regras do cargueiro | `UpgradePanel.gd` | RB7 explica no contexto; não tratar requisitos como recurso ausente |
| Diário e mensagens | `PainelDiario.gd`, `PainelMensagens.gd` | Referenciar no resumo; não construir outro histórico paralelo |
| Volume de música/efeitos e cópia de registro | `PainelAjustes.gd` | RB5, RB6 e RB8 são novas opções; som separado já está feito |

Não se encontrou entrada para ajuda/glossário, resumo próprio de retomada,
ajuste de texto, reduzir movimento ou transporte de save nos menus examinados.
Essa é constatação do código; não se testou instalação limpa em todos os alvos
nesta pesquisa. As quatro portas fechadas do celular não viram apps funcionais
por causa desta lista.

## Ordem sugerida e como escolher o primeiro recorte

Para **recurso novo visível**, começar por **RB1 — Como jogar + glossário**.
Ajuda a pessoa sem adicionar regras econômicas ou um novo objetivo. Em seguida,
**RB2 — Meu porto agora**, usando os mesmos dados que os painéis atuais.

Em paralelo na priorização, manter **confiabilidade do save** como pendência
técnica séria da revisão anterior: RB3 não pode exibir uma confirmação falsa,
e RB4 depende de leitura/gravação seguras. Isso não transforma a resposta sobre
novidades em uma fila apenas de correções. RB5 merece protótipo cedo no A7;
o tamanho real do esforço depende de quanto os painéis precisarem reorganizar.

São prioridades propostas, **não ordem já aceita para implementar**. O próximo
passo é Bruno escolher o recorte, ajustar o conteúdo e então definir a aceitação.
Publicar esta pesquisa na entrega do projeto não é aceitar seus novos botões,
textos ou migrações. A4 e o caderno reescrito permanecem sem aceite.

## Provas mínimas quando um recurso for escolhido

| Recurso | O que precisa demonstrar antes de entrar |
|---|---|
| RB1/RB7 | Dúvidas resolvidas por quem não conhece o projeto; consulta sem passar dia, gastar, sortear ou alterar missão; conteúdo fiel ao estado e às regras |
| RB2 | Retomar em Fase 1, Fase 2, obra, serviço iniciado e jogo livre; nenhum efeito em RNG, caixa ou turno; sem sugerir dívida já quitada |
| RB3/RB4 | Falha de abertura/escrita, interrupção, arquivo truncado, restauração e ida/volta entre alvos; preservar o anterior e não esconder erro; sem enfraquecer a cadeia de migração |
| RB5/RB6 | Preferência lembrada após reiniciar, acessível antes de jogar; texto sem corte e ações alcançáveis no telefone; informação de operação preservada |
| RB8 | Versão corresponde ao build; diagnóstico com prévia, mínimo necessário e nenhum envio sem ação explícita |

Modo de prática, dificuldade ajustável, nuvem, idiomas, conquistas e análises
avançadas podem ser estudados depois. Não são o primeiro pacote básico proposto:
alguns exigem conteúdo, infraestrutura ou novo balanceamento. Crédito voluntário,
mais trabalhadores e etapas novas da Fase 2 continuam fora deste recorte.
