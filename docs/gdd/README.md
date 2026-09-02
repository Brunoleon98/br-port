<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# GDD 7 — a leitura por partes

O GDD 7 é a fonte da verdade do design e **está congelado**. Ele vive em `docs/design/BR_Port_GDD_V7.jsx`, que é uma aplicação React de 5.658 linhas: boa para apresentar, péssima para citar.

Estas páginas são **geradas** dele por `tools/gerar_gdd_md.py`, uma seção por arquivo. Não as edite — o CI regenera e reprova a divergência. Para mudar o texto, mude o `.jsx`.

⚠️ **O GDD descreve o jogo INTEIRO, das Fases 1 a 5.** O que está implementado é o Vertical Slice da Fase 1 — para isso, `docs/ESTADO_DO_PROJETO.md`. E a economia das Fases 2 e 3 tem uma errata que corrige o GDD: `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.

---

## Sistemas — como o jogo funciona

Inclui as decisões de design fechadas, resolvidas em cada seção.

- [🎮 Sistema de Contratos & Tempo](sistemas/gameplay.md) — Gameplay
- [🏗️ Progressão & Desbloqueio](sistemas/phases.md) — Fases
- [⚔️ Sistema de Rivalidade](sistemas/rivals.md) — Rivais
- [💰 Modelo de Negócio](sistemas/monetization.md) — Monetização
- [🔄 Core Loop de Sessão](sistemas/loop.md) — Loop
- [🗺️ Mapa & Espaço](sistemas/mapa.md) — Mapa
- [🎓 Tutorial & Onboarding](sistemas/tutorial.md) — Tutorial
- [👥 Elenco & Fichas de Personagens](sistemas/npcs.md) — NPCs
- [⭐ Sistema de Reputação](sistemas/reputacao.md) — Reputação
- [🏁 Condições de Final & Desfechos](sistemas/finais.md) — Finais
- [📊 Tabela de Referência Econômica](sistemas/economia.md) — Economia
- [✨ Feedback & Game Feel](sistemas/gamefeel.md) — Game Feel
- [💾 Save, Sincronização e Múltiplos Perfis](sistemas/save.md) — Save & Nuvem
- [📚 Camadas Avançadas — Quando e Como Cada Sistema é Introduzido](sistemas/onboarding_avancado.md) — Onboarding Avançado
- [♿ Acessibilidade & Localização](sistemas/acessibilidade.md) — Acessibilidade
- [📊 Métricas de Sucesso, Plano de QA e Compliance](sistemas/kpis.md) — KPIs & QA
- [🚀 Comunidade, DLCs e Roadmap de Conteúdo](sistemas/pos_lancamento.md) — Pós-Lançamento
- [🎭 Guia de Estilo — Como Cada NPC Fala](sistemas/voz_personagens.md) — Voz dos Personagens

## Conceitos — mundo, gente e economia

- [⚓ BR Port](conceitos/identity.md) — Conceito central
- [🌴 Porto Mirim](conceitos/setting.md) — A cidade
- [🧑‍✈️ O/A Herdeiro(a)](conceitos/protagonist.md) — Personagem principal
- [👥 Elenco Principal](conceitos/npcs.md) — Personagens fixos com personalidade e diálogos
- [🧩 Toninho, Seu Biu e Kinha](conceitos/novos_npcs.md) — Fichas narrativas completas
- [🎨 Nome & Aparência do Protagonista](conceitos/protagonista_custom.md) — Identidade visual e o nome que a cidade vai conhecer
- [🏚️ Casa do Protagonista](conceitos/casa_protagonista.md) — O espaço pessoal — o que o avô deixou junto com as dívidas
- [📚 Desenvolvimento Pessoal](conceitos/hobbies_estudos.md) — O que o protagonista é, fora do papel de gestor do porto
- [🎣 O Loop Central](conceitos/hook.md) — Por que o jogador volta todos os dias
- [🎓 Tutorial e Onboarding](conceitos/tutorial.md) — Os primeiros 15 minutos — a impressão que não se repete
- [💰 Fontes de Renda — Early Game](conceitos/economia.md) — As três fontes iniciais do porto
- [⚔️ Como os Rivais Agem](conceitos/rivais_acao.md) — Pressão indireta, nunca confronto direto
- [📊 Variação Dinâmica de Preços](conceitos/precos.md) — O mercado de Porto Mirim é pessoal, não abstrato
- [🏠 Carros, Imóveis e Arte](conceitos/gastos_prestigio.md) — O que fazer com o dinheiro além de expandir o porto
- [📊 Relatórios Financeiros](conceitos/relatorios_financeiros.md) — Dona Cida organiza — o jogador decide o que fazer com o que aprendeu
- [🏦 Sistema de Dívidas](conceitos/dividas.md) — O banco tem um rosto
- [🏦 Banco de Porto Mirim — Além da Dívida](conceitos/banco_investimentos.md) — Sr. Ribeiro como hub financeiro completo: empréstimos e investimentos
- [🤲 Vaquinha da Crise](conceitos/vaquinha.md) — A cidade salva o porto — mas tem condições
- [🫶 Doações e Causas Locais](conceitos/filantropia.md) — A versão proativa da vaquinha — agir antes de precisar
- [🚢 Tipos de Carga](conceitos/cargas.md) — 8 categorias com risco, lucro e narrativa
- [📅 Ciclo Anual de Porto Mirim](conceitos/sazonalidade.md) — Calendário fixo — uma campanha cobre uma janela específica
- [👷 Sistema de Funcionários](conceitos/funcionarios.md) — Moral e lealdade — dois medidores independentes
- [📋 Sistema de Contratação](conceitos/contratacao.md) — Candidatos chegam — o jogador escolhe quando e quem
- [💼 Negociação de Salário](conceitos/negociacao_salario.md) — Cada trabalhador tem um preço — e uma opinião sobre o que vale
- [📖 Arco Narrativo Central](conceitos/arco.md) — Campanha com alma de sandbox
- [📔 Diário do Porto](conceitos/diario_porto.md) — Centro emocional — onde o porto ganha memória
- [📷 Sistema de Fotografias — Polaroid](conceitos/fotografias.md) — O porto que você lembra é o porto que você fotografou
- [🎬 Estrutura Detalhada — Os 3 Atos](conceitos/atos.md) — Duração, gatilhos e critérios de transição
- [🏁 Finais Possíveis](conceitos/finais.md) — 5 desfechos — nenhum é o canônico
- [⏳ Missões e Escolhas Irrevogáveis](conceitos/missoes.md) — O jogador sabe que é importante — não sabe a consequência
- [📰 Bela e o Sistema de Reputação](conceitos/imprensa.md) — Um espelho que o jogador não controla completamente
- [📰 Consistência dos Gatilhos — Bela](conceitos/bela_gatilhos.md) — Quando ela avisa, quando publica, quando investiga
- [⭐ Sistema de Reputação](conceitos/reputacao.md) — Três eixos independentes — uma leitura integrada
- [❤️ Vínculos com NPCs](conceitos/vinculos.md) — Não chama de romance — chama de vínculo
- [🐈 Os Bichos do Cais](conceitos/pets_porto.md) — Os habitantes que estavam aqui antes de você
- [🔒 Segredos de Porto Mirim](conceitos/segredos.md) — Quatro fios que o jogador pode — ou não — puxar
- [🕯️ Memorial do Seu Maneco](conceitos/memorial_avo.md) — Reconstruir a figura do avô através da memória dos outros
- [🎯 Arlindo vs Abutre — Agendas Independentes](conceitos/agendas.md) — Aliados provisórios, rivais latentes
- [🤝 Alianças e Traições](conceitos/aliancas.md) — Três tipos de aliança, cada uma com custo diferente
- [🏢 Rostos do Grupo Atlântico](conceitos/atlantico.md) — Três personagens além do Abutre
- [⚙️ Ações Ativas dos Rivais](conceitos/mecanicas_rivais.md) — Escalam com o tamanho do porto do jogador
- [🕐 Unidade de Tempo — Turnos Diários](conceitos/tempo.md) — Sem idle. Sem obrigação de abrir todo dia.
- [📋 Interface de Negociação](conceitos/contratos_ux.md) — Tela inteira em modo retrato sem scroll — requisito de design
- [🗺️ Mapa Regional](conceitos/mapa.md) — Desbloqueado por progressão, não disponível desde o início
- [🗺️ Regiões — Desbloqueios e Condições](conceitos/regioes.md) — Cinco destinos com critérios de acesso definidos
- [⚡ Eventos Aleatórios](conceitos/eventos.md) — Cenário mantém o jogo imprevisível. Narrativa cria memórias.
- [🏗️ Progressão de Construção](conceitos/construcao.md) — Cinco fases visíveis — não uma árvore de tecnologia
- [🤫 Corrupção Local](conceitos/corrupcao.md) — Banal, não dramatizada
- [🎵 Identidade Sonora](conceitos/som.md) — Forró de pé de serra com baião — não o eletrônico
- [💬 Voz e Humor Regional](conceitos/dialogo.md) — O jogador ri porque reconhece o tipo humano
- [🎊 Festividades Locais](conceitos/festividades.md) — Quatro eventos com impacto mecânico real
- [🍻 Bar do Mané — Vida Noturna](conceitos/bar_mane.md) — Onde os NPCs param de ser funcionários
- [✉️ Caixa de Correspondência](conceitos/correspondencia.md) — O fluxo lento de cartas — o que chega entre os turnos
- [✈️ Eventos do Setor Portuário](conceitos/eventos_setor.md) — O mundo além de Porto Mirim — conexões que não chegam até você
- [📇 Rede de Networking](conceitos/agenda_contatos.md) — Cada aperto de mão num evento vira uma linha persistente na sua agenda
- [🎣 Mini-game de Pesca](conceitos/pesca_minigame.md) — Pausa do porto — ritmo diferente, recompensa real
- [🏆 Concurso de Pesca da Semana do Mar](conceitos/concurso_pesca.md) — Anual, organizado por Seu Biu — o evento que prova que pesca é arte
- [🔗 Onde os Sistemas se Tocam](conceitos/conexoes_cruzadas.md) — As amarrações invisíveis que fazem o jogo parecer vivo
- [🌿 Desigualdade, Pobreza e Meio Ambiente](conceitos/temas.md) — Contexto vivido, não missão temática
- [💳 Modelo de Negócio](conceitos/monetizacao.md) — Premium puro — sem anúncios, sem energia, sem IAP de progressão

## As perguntas

- [As perguntas de design, e o que se respondeu](perguntas.md)


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
