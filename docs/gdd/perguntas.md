<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# As perguntas de design, e o que se respondeu

As perguntas que o GDD abriu e fechou, com o **porquê** de cada uma importar. É a camada que o resto do GDD pressupõe: as seções dizem *o que é*, isto diz *por que não é outra coisa*.

## 🎮 Gameplay

**Há limite de contratos ativos simultaneamente?**

*Por que importa:* Define se o jogador pode superagendar o porto ou se existe um cap. Impacta diretamente a tensão tática e a dificuldade da curva de aprendizado.

**Decidido:** Cap dinâmico por fase. Começa em 3 contratos simultâneos (Fase 1) e cresce até 8–10 na Fase 5. O limite desaparece naturalmente junto com o crescimento do porto.

**Trabalhadores têm especialidades fixas ou são intercambiáveis?**

*Por que importa:* Se cada trabalhador tem um papel (estivador, carpinteiro, guarda), a alocação fica muito mais estratégica. Se são genéricos, o sistema é mais simples, mas pode ser menos interessante.

**Decidido:** Especialidades com penalidade. Cada trabalhador tem função principal, mas pode exercer outra com 30–40% menos eficiência. Estratégico sem punir erros de forma irreversível.

**Existe cansaço, moral ou turno para os trabalhadores?**

*Por que importa:* Sem esse sistema eles operam a 100% sempre — mais simples, mas menos realista. Com ele, o jogador precisa gerir escala e descanso, o que adiciona profundidade.

**Decidido:** Só moral — sem barra de cansaço. Sobe com bônus e promessas cumpridas, cai com exploração. Moral baixa reduz rendimento e pode culminar em demissão.

**Como funciona o fluxo de caixa: por contrato ou periódico?**

*Por que importa:* Receber só ao cumprir contratos cria picos e vales financeiros. Fluxo diário (aluguel de doca, tarifas) é mais previsível. A escolha afeta toda a estratégia econômica.

**Decidido:** Híbrido. Renda passiva semanal (píer, aluguel de armazém) cobre custos fixos. Contratos entregam o lucro real de crescimento. O passivo é o chão; o ativo é o teto.

**O que acontece se o porto ficar sem dinheiro?**

*Por que importa:* Game over? Empréstimo forçado com juros? Um NPC que oferece ajuda com custo narrativo? Precisa ser definido para o designer saber onde está o 'chão' do jogo.

**Decidido:** Três camadas progressivas: Sr. Ribeiro avisa sem penalidade → vaga do píer é penhorada → Sr. Abutre faz oferta de compra como único 'final ruim'. Falência é arco narrativo, não tela de game over.

**Eventos climáticos (tempestades, neblina) existem no jogo?**

*Por que importa:* Clima adiciona imprevisibilidade e oportunidade para storytelling. Se existir, como o jogador é avisado? Navios atrasam, contratos vencem, como fica?

**Decidido:** Existem com aviso antecipado. Boletim do porto alerta 1 dia antes. Efeitos: navios atrasam, guindaste para, contratos de prazo curto em risco. Sem destruição de infraestrutura.

**Há ciclo de dia e noite com efeito mecânico?**

*Por que importa:* Se dia/noite existe só visualmente, é cosmético. Se navios chegam mais à noite ou trabalhadores custam mais em hora extra, vira uma camada de decisão importante.

**Decidido:** Custo e oportunidade. Noite custa mais (hora extra no salário) e fecha alguns clientes (turismo, aduana). Mas abre eventos exclusivos — certos navios e missões narrativas só aparecem à noite.

**Onde o jogador compra upgrades de infraestrutura (ex: grua mais rápida)?**

*Por que importa:* Isso define se existe uma 'loja de equipamentos' separada, se upgrades saem do mesmo menu de construção, ou se vêm como recompensa de contrato.

**Decidido:** Clicando no objeto no mapa. Clicar na grua abre o painel daquela grua. Construções novas ficam no menu de construção geral. Cada objeto gerencia a si mesmo.

## 🏗️ Fases

**A reputação pode regredir a ponto de o jogador 'descer' de fase?**

*Por que importa:* Regredir de fase pode ser frustrante ou dramático dependendo da execução. Definir isso impacta diretamente o design de risco e a tolerância a falhas do jogo.

**Decidido:** Regressão parcial com trava. A fase conquistada é permanente, mas se a reputação cair abaixo do mínimo, certos contratos e clientes somem até ela se recuperar. A estrutura permanece; o acesso, não.

**As 3 condições de avanço precisam ser cumpridas simultaneamente?**

*Por que importa:* Se sim, o jogador pode ficar travado com reputação alta mas sem a construção obrigatória. Há uma ordem recomendada? Existe dica clara sobre o que falta?

**Decidido:** Simultâneas com painel de progresso claro. As três condições precisam estar ativas ao mesmo tempo, e o jogador vê em tempo real o quanto falta de cada uma. Sem surpresa, sem travamento silencioso.

**Existe limite de tempo máximo por fase, ou o jogador avança no próprio ritmo?**

*Por que importa:* Sem limite o jogo é sandbox — mais relaxante. Com prazo, a pressão aumenta e a narrativa fica mais urgente. Precisa ser decidido antes de balancear a dificuldade.

**Decidido:** Pressão narrativa sem limite rígido. Não há timer, mas o Sr. Abutre intensifica a pressão conforme o tempo passa — criando urgência orgânica sem punição de relógio.

**Construções antigas podem ser demolidas para liberar espaço?**

*Por que importa:* Se o mapa do porto é limitado, o jogador vai precisar tomar decisões de layout. Demolir e recolocar tem custo? Isso pode ser uma camada estratégica relevante.

**Decidido:** Demolição com custo parcial. Recupera 50% dos recursos. Construções herdadas do avô custam mais para derrubar — o jogo reconhece o valor sentimental mecanicamente.

**Existe upgrade de construções existentes ou só construção nova?**

*Por que importa:* Upgrade (ex: cais básico → cais reforçado) é mais fluido e menos custoso visualmente. Construção nova exige espaço e planejamento. As duas abordagens têm trade-offs grandes.

**Decidido:** Ambos, com lógica clara. Estruturas principais (grua, cais, armazém) têm upgrade in-place de até 3 níveis. Estruturas de expansão (nova doca, novo galpão) exigem construção nova e espaço.

**Porto Mirim tem efeito mecânico ou é só narrativa/visual?**

*Por que importa:* Se a cidade ao redor afeta gameplay (ex: população alta = mais trabalhadores disponíveis, turistas = renda passiva), vira um sistema a mais. Se é só cenário, simplifica bastante.

**Decidido:** Mecânica leve e passiva. Quanto maior a cidade, mais trabalhadores disponíveis no mercado. Em alta temporada turística, renda passiva pequena entra automaticamente. Sem gestão ativa da cidade.

**Existem eventos sazonais dentro das fases (ex: festa de pesca, furacão)?**

*Por que importa:* Eventos sazonais dão ritmo e surpresa ao loop. Precisam de sistema de agenda e variação por fase. Se existirem, como são comunicados ao jogador com antecedência?

**Decidido:** Calendário fixo por fase com aviso prévio. Cada fase tem 2–3 eventos sazonais fixos — ex: Festa de São Pedro, alta temporada em janeiro, vento sul em agosto. O boletim avisa com antecedência.

**A missão narrativa de conclusão de fase pode ser revisitada?**

*Por que importa:* Se a cutscene é única e não pode ser rebobinada, o jogador perde se sair do jogo. Se pode revisitar (no diário, por exemplo), adiciona valor de replay e coleta.

**Decidido:** Diário do Porto com cápsula do tempo. Cada missão de fase vai para o Diário com artefatos extras: fotos do porto, cartas de NPCs, manchetes do jornal local. Revisitável a qualquer momento.

## ⚔️ Rivais

**O jogador recebe aviso antes de um rival agir, ou só descobre depois?**

*Por que importa:* Aviso prévio permite reação estratégica — mais fair, menos frustrante. Descobrir depois cria surpresa e urgência. A resposta define o tom de tensão do sistema.

**Decidido:** Aviso parcial por nível de ameaça. Rivalômetro baixo = sem aviso. Médio = sinal vago ('Arlindo está se movimentando...'). Crítico = aviso claro com janela de reação. A informação é proporcional ao risco acumulado pelo jogador.

**Rivais podem se aliar entre si e agir em conjunto?**

*Por que importa:* Aliança entre rivais aumenta muito a ameaça e cria situações de 'dois fronts'. Exige mais do jogador, mas pode ser muito frustrante se não for sinalizado adequadamente.

**Decidido:** Aliança como evento narrativo único. Na transição para a Fase 4, Arlindo e Abutre consideram uma aliança em cena exclusiva. O jogador pode intervir via missão com a Bela para impedir. Se não intervir, agem juntos por período limitado.

**É possível eliminar um rival permanentemente ou eles sempre retornam?**

*Por que importa:* Eliminação permanente dá sensação de conquista, mas reduz a pressão no late game. Retorno garante tensão contínua. Precisa estar alinhado com o arco narrativo de cada rival.

**Decidido:** Eliminação narrativa, não mecânica. Arlindo pode ser 'derrotado' — seu porto perde relevância e ele para de agir ativamente, podendo virar aliado. Abutre (Atlântico S.A.) nunca é eliminado; a corporação é grande demais e o final narrativo resolve isso.

**O Capitão Arlindo pode se tornar aliado permanente após ser derrotado?**

*Por que importa:* Um ex-rival aliado é uma das mecânicas narrativas mais satisfatórias em jogos de gestão. Define se o arco do Arlindo tem um final 'bom', além de criar escolha moralmente interessante.

**Decidido:** Aliado por escolha do jogador, com custo. Após enfraquecer Arlindo na Fase 3, o jogador recebe proposta de parceria. Aceitar dá bônus permanentes mas custa reputação com NPCs que desconfiam dele. Recusar mantém a rivalidade até a Fase 4.

**O Rivalômetro é visível o tempo todo na tela ou precisa de menu específico?**

*Por que importa:* Visível desde o início = jogador sempre ciente. Mas isso quebra o beat narrativo crucial onde o jogador descobre que 'não foi azar, foi Arlindo'. Em menu = jogador pode ignorar e ser pego de surpresa.

**Decidido:** Oculto no início, aparece após descoberta narrativa. Os primeiros ataques de Arlindo parecem azar — Conceitos define este como um beat narrativo importante. Quando o jogador percebe o padrão (gatilho narrativo, ~semana 3–4), Toninho ou Bela apresentam o sistema, e o ícone do Rivalômetro aparece pela primeira vez no HUD. A partir daí: ícone compacto que muda de cor (verde/amarelo/vermelho) e expande ao tocar. Sempre visível depois da descoberta. Esse design protege a surpresa do early game e mantém a transparência mecânica do mid/late game.

**Como a IA rival decide sua próxima ação?**

*Por que importa:* Script fixo por fase é mais previsível e fácil de balancear. IA reativa ao comportamento do jogador é mais sofisticada, mas exige muito mais testes. Qual é o escopo viável?

**Decidido:** Script por fase com gatilhos reativos. Sequência base predefinida (fácil de balancear), mas comportamentos do jogador disparam reações específicas — ex: dominar todos os leilões por 3 dias seguidos faz Arlindo iniciar campanha de boatos.

**Existe sistema de 'inteligência' para o jogador espionar rivais?**

*Por que importa:* Um personagem espião ou sistema de informação pago seria uma camada de meta-jogo rica. Sem isso, o jogador reage cegamente. Define quanto de assimetria de informação o jogo tem.

**Decidido:** Missões pagas com a Bela. A repórter pode ser contratada para investigar um rival por custo em reputação ou dinheiro. Retorna informações específicas e acionáveis. Disponível a partir da Fase 2.

**O que acontece se o Rivalômetro crítico for ignorado repetidamente?**

*Por que importa:* Precisa ter um teto claro: o rival conquista um contrato chave? Fecha uma rota? Desencadeia um evento narrativo? Sem isso, o sistema fica sem consequências reais.

**Decidido:** Escalada narrativa em três atos. 1º crítico ignorado → rival fecha o melhor contrato da semana. 2º → planta boato que derruba reputação por 5 dias. 3º → evento narrativo obrigatório com penalidade permanente até o fim da fase.

## 💰 Monetização

**O que exatamente a demo (Fase 1 completa) inclui e o que fica bloqueado?**

*Por que importa:* Precisa estar listado explicitamente: sistema de rivalidade está na demo? NPCs? Tutorial? Quanto mais rica a demo, maior a conversão — mas o jogo completo precisa justificar a compra.

**Decidido:** Fase 1 completa com rivais introdutórios. Inclui tudo da Fase 1 — contratos, NPCs, construção — mais a primeira aparição do Arlindo e um evento rival simplificado. O jogador sente o loop completo. Para avançar à Fase 2, compra o jogo.

**O unlock acontece dentro do app (IAP) ou redireciona para a loja?**

*Por que importa:* IAP in-app é mais fluido, mas Apple e Google ficam com 30%. Redirecionar para site próprio é mais trabalhoso, mas aumenta margem. Afeta o modelo de negócio diretamente.

**Decidido:** IAP in-app no iOS (obrigatório por política da Apple), loja própria no Android (permitido desde 2022). Os dois canais em paralelo maximizam margem onde é possível sem violar regras onde não é.

**Os DLCs serão IAPs ou produtos separados nas lojas?**

*Por que importa:* IAPs dentro do app são mais convenientes, mas exigem implementação técnica de conteúdo parcial. Produtos separados na loja são mais simples de gerenciar e descobrir por novos usuários.

**Decidido:** IAPs para DLC de história e cosméticos (compra rápida, sem sair do jogo). Produto separado nas lojas para DLC de cenário — tem página própria, atrai novos jogadores organicamente e justifica vitrine independente.

**Há plano de lançamento para PC (Steam) ou console além de mobile?**

*Por que importa:* A UI atual é desenhada para 480px (mobile). Uma versão Steam exige redesign de interface e precisa estar no roadmap desde o início para não ser um retrofit caro.

**Decidido:** Mobile primeiro, Steam 6–12 meses depois. Lança mobile, valida com dados reais, usa a receita para financiar o redesign de UI para PC. A versão Steam é uma segunda janela de lançamento — com novo público e possibilidade de Next Fest.

**O save na nuvem usa servidor próprio ou plataforma (Google Play / iCloud)?**

*Por que importa:* Servidor próprio dá controle total, mas exige backend. Google Play Games e iCloud são gratuitos e confiáveis, mas cada plataforma tem sua API. Afeta o escopo técnico do projeto.

**Decidido:** Google Play + iCloud nativos por padrão (gratuito, sem backend), com opção de exportar o save como arquivo para migração manual entre plataformas. Cobre 95% dos casos sem custo de infraestrutura.

**Suporte a múltiplos perfis de save por dispositivo?**

*Por que importa:* Importante para família compartilhando tablet — cada pessoa quer seu próprio progresso. Exige um sistema de seleção de perfil na tela de abertura, o que aumenta a complexidade de UX.

**Decidido:** Sim, acessível pelo menu de configurações. Um perfil ativo por padrão — quem não precisa nunca vê. Criar ou trocar de perfil fica nas configurações. Remove fricção do fluxo principal sem sacrificar a funcionalidade.

**O preço de R$ 19,90 é fixo ou varia por região/promoção?**

*Por que importa:* Preço regional (ex: preço menor na Índia ou em mercados emergentes) aumenta alcance global. Promoções de lançamento são estratégia de ranking. Precisa estar no plano de marketing.

**Decidido:** Preço padrão global de US$ 3,99. Ajuste regional em mercados-chave: Brasil (referência local já definida), Índia e Sudeste Asiático. Promoção de 30% nas primeiras 2 semanas para impulsionar ranking inicial.

**Updates pós-lançamento serão gratuitos ou pagos (além dos DLCs)?**

*Por que importa:* Bug fixes são sempre grátis, mas e o conteúdo novo? Definir isso protege a relação com o jogador e alinha expectativas desde o anúncio do jogo.

**Decidido:** Bug fixes e balanceamento sempre gratuitos. Conteúdo novo substancial vai para DLC pago. Conteúdo pequeno (eventos sazonais extras, diálogos de NPCs) vai gratuito como goodwill. Linha clara entre manutenção e expansão.

## 🔄 Loop

**O que acontece nos primeiros 30 segundos após abrir o app?**

*Por que importa:* A tela de entrada define o tom e a retomada de contexto. O jogador volta depois de horas ou dias — precisa entrar no estado mental certo rapidamente.

**Decidido:** Boletim do Porto automático. Ao abrir, o jogo exibe resumo do último turno em 3 itens: navio chegado, ação rival, prazo urgente. Máximo 5 segundos de leitura, depois o mapa para tomar as decisões do turno atual.

**Um 'dia de jogo' tem duração em tempo real definida?**

*Por que importa:* Se o jogo é turn-based, cada dia avança quando o jogador confirma. Não há relógio do mundo real correndo. Define o tom da sessão e o design de notificações.

**Decidido:** Avanço por turno, sem relógio. Cada sessão é uma sequência de dias completos confirmados pelo jogador. Sessão típica: 10–20 min para tomar as decisões de 1 a 3 dias e fechar. Sem 1×/2×/½× — a unidade é o dia, não o minuto.

**O loop de 'entrar → verificar → agir → sair' é suportado por notificações?**

*Por que importa:* Em jogo turn-based sem progressão offline, a notificação não pode criar urgência (nada está vencendo). Mas pode lembrar de voltar.

**Decidido:** Push opcional, sem urgência. Desativado por padrão. Quando ativado, serve apenas como lembrete suave ('Faz 4 dias que você não visita o porto') — nunca como alerta de crise, pois nada acontece com o app fechado. Silêncio automático 23h–8h horário local.

**O jogador pode ter perdas permanentes por desligar o app?**

*Por que importa:* Definir explicitamente: o jogo avança só quando o jogador joga. Sem isso, fica ambíguo se há ou não pressão temporal externa.

**Decidido:** Sem progresso offline. App fechado = jogo pausado. Navios não chegam, contratos não vencem, rivais não agem enquanto o jogador está fora. A campanha avança exclusivamente quando o jogador joga — o que torna o tom 'convidativo, não pressionado' do mundo coerente com a mecânica.

## 🗺️ Mapa

**O layout do porto usa grid ortogonal ou posicionamento livre?**

*Por que importa:* Grid é mais legível e simples de implementar — padrão em jogos mobile. Livre é mais orgânico, mas mais complexo de validar colisões. Define engine e tooling de level design.

**Decidido:** Grid com snapping automático. Células de 64×64px na resolução base. Estruturas ocupam 1×1, 2×1 ou 2×2 células. Grid snapping automático ao arrastar construção.

**Como funciona a expansão de área para a próxima fase?**

*Por que importa:* Expandir para a esquerda? Direita? Mar? Terra? A direção da expansão precisa ser consistente com a narrativa visual (porto crescendo) e com a câmera do jogo.

**Decidido:** Expansão em L — cresce para a direita (terra) e para o sul (mar). F1: 8×6. F2: 12×8. F3: 16×10. F4: 20×12. F5: 24×14 + área estaleiro separada. O cais original do avô fica sempre no canto noroeste.

**Existe altura (z-axis) no mapa ou é completamente 2D?**

*Por que importa:* Pixel art com perspectiva levemente isométrica permite z-ordering visual. Se há estruturas de múltiplos andares, o engine precisa suportar depth sorting.

**Decidido:** 2D com profundidade visual simulada por z-ordering — sem z-axis real. Godot 4 gerencia depth sorting via CanvasItem.z_index automaticamente: estruturas mais ao sul (perto do mar) renderizam na frente das mais ao norte (perto da cidade). Nenhuma estrutura tem múltiplos andares no MVP. A perspectiva é top-down leve (≈ 30°), não isométrica — elimina o custo de assets extras e garante legibilidade em telas de 4 a 7 polegadas.

**Existe limite de construções por tipo ou só de espaço?**

*Por que importa:* Limitar 'só 2 gruas por fase' adiciona decisão estratégica. Limitar só por espaço deixa o jogador livre mas pode criar layouts ineficientes. Precisa de uma regra clara.

**Decidido:** Limite por espaço para a maioria, com cap hard para estruturas que geram recursividade. Gruas, galpões, docas: limitadas só pelo espaço disponível. Exceções com cap hard por fase: Torre de Controle (1 total), Aduana (1 total), Estaleiro (1 total), Oficina Naval (máx. 2 por fase). A regra geral é liberdade de layout; as exceções evitam exploits de balanceamento sem necessidade de playtest extensivo.

## 🎓 Tutorial

**O tutorial é integrado à campanha ou é uma sequência separada?**

*Por que importa:* Tutorial integrado (à la Hades) é mais fluido e imersivo. Tutorial separado é mais didático mas quebra a imersão inicial.

**Decidido:** Tutorial integrado via Toninho nos primeiros 15 minutos de jogo. Toninho é o estivador-chefe veterano que estava no cais antes do protagonista nascer — apresenta os sistemas como se estivesse mostrando o porto para o herdeiro do amigo (Seu Maneco). 4 momentos curtos (~3–4 min cada), sem painel de instrução separado. Sr. Ribeiro entra como tutor financeiro depois da semana 4, junto da Parcela 1 — não no tutorial inicial.

**Quais sistemas ficam fora do tutorial inicial?**

*Por que importa:* Mostrar tudo de uma vez é o maior erro de onboarding em management games. Precisa de sequência de introdução definida.

**Decidido:** Tutorial inicial (Toninho, minutos 0–15) cobre o estritamente essencial: chegada e galpão (min 0–3), primeira decisão de custo com Zezão (min 3–7), aluguel de píer aos pescadores com Seu Biu (min 7–11), primeiro barco e apresentação da dívida (min 11–15). Tudo o mais (rivais, moral, leilões, espionagem via Bela, jornada noturna, hobbies) é introduzido progressivamente nas semanas seguintes — sempre dentro de evento narrativo. A primeira parcela ao Sr. Ribeiro na semana 4 é o gancho que apresenta o banco como sistema.

**Como o jogador aprende que pode avançar o turno e quando?**

*Por que importa:* Em jogo turn-based, o jogador precisa entender que o tempo só passa quando ele confirma. Sem isso, fica esperando algo acontecer.

**Decidido:** Coach mark forçado uma única vez, ativado por gatilho. No fim do minuto 15 (depois da apresentação da dívida por Dona Cida), o jogo destaca o botão 'Próximo dia' com seta pulsante + linha de Dona Cida: 'Chefia, quando o senhor terminar de decidir, é só avançar o dia.' O jogador toca, o dia avança e o tutorial some. Não se repete. Quem descobre antes (toca no botão por curiosidade) não vê o coach mark.

## ⭐ Reputação

**A reputação é uma barra única ou tem subcategorias?**

*Por que importa:* Uma barra única é mais simples de balancear. Subcategorias permitem estratégias especializadas e leitura mais expressiva.

**Decidido:** Três eixos visíveis e independentes — escala 0–100 cada. Reputação Comercial (clientes e contratos), Reputação Comunitária (cidade, pescadores, câmara), Reputação com a Imprensa (Bela). O jogador vê os três como medidores qualitativos: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. Setores internos não existem — a leitura é por eixo.

**Quanto cada ação ganha ou perde? Há tabela de referência?**

*Por que importa:* Sem essa tabela, o balanceamento fica ad hoc. O designer precisa saber: cumprir contrato vale X? Falhar tira Y?

**Decidido:** Tabela base por eixo, na escala 0–100. Cumprir contrato: +1 a +5 na Comercial (proporcional ao valor). Falhar: −3 a −8 na Comercial + −2 a −4 na Imprensa. Missão de NPC cumprida: +3 a +8 no eixo do NPC. Boato de rival ativo: −1 a −3/dia na Comercial. Demolir construção histórica: −5 fixo na Comunitária. Festa de São Pedro com presença: +3 a +6 na Comunitária. Mentira descoberta pela Bela: −15 a −30 na Imprensa de uma vez.

**A reputação tem decaimento natural ao longo do tempo?**

*Por que importa:* Se sim, o jogador precisa agir constantemente. Se não, uma vez que atingiu alta, para de se preocupar.

**Decidido:** Decaimento leve e contextual, por eixo. Sem atividade no eixo por 5 dias de jogo: −0,5/dia naquele eixo. Eventos negativos ativos (boato, contrato quebrado): −1/dia adicional enquanto vigentes. Teto de decaimento passivo: −10 pontos totais por eixo — nenhum eixo cai de 80 para 30 só por inatividade. A cidade não esquece, só começa a duvidar.

**Como a reputação é exibida ao jogador?**

*Por que importa:* Uma barra clássica é intuitiva. Um título narrativo é mais imersivo mas menos legível. O HUD precisa ser decidido antes de qualquer asset de UI ser produzido.

**Decidido:** Três medidores compactos no painel de status (acessível pelo HUD), cada um com título qualitativo + número 0–100. A mudança de faixa qualitativa é anunciada por linha de diálogo do NPC relevante (Dona Cida para Comercial, Seu Biu para Comunitária, Bela para Imprensa). Sem 'level up' visual — só uma linha de diálogo casual.

**Interação entre os eixos — eles se influenciam?**

*Por que importa:* Eixos totalmente independentes parecem mecânicos. Eixos que interagem criam tensão estratégica.

**Decidido:** Sim, com regras claras. Reputação com Bela alta + matéria positiva = +1 na Comercial por 2 semanas. Reputação Comunitária abaixo de 35 = Arlindo recruta funcionários com mais facilidade. Reputação Comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida. Mentira descoberta pela Bela = perda compartilhada (−10 na Imprensa, −5 na Comercial). Os eixos não somam — eles conversam.

## 🏁 Finais

**Quais são exatamente os finais e o que os desbloqueia?**

*Por que importa:* A decisão do ato 3 (sessão pública na câmara) precisa ter condições claras para cada final. Sem isso, o escritor e o programador não sabem o que checar.

**Decidido:** 5 finais com condições qualitativas. Final A (Porto Unificado): aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Final B (Porto da Cidade): mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Final C (Sobrevivência Pura): terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. Final D (Venda ao Grupo Atlântico): aceitar proposta do Abutre no Ato 3. Final E (O Custo do Conhecimento, secreto): seguir fio da carga sem nota até o fim + revelar o contato interno do Atlântico para o Abutre + reputação comunitária abaixo de 40.

**Existe um 'final ruim' além de vender ao Abutre?**

*Por que importa:* Final ruim por falência é diferente de vender por escolha. O primeiro é punição; o segundo é decisão narrativa. Os dois precisam ter cenas e sensações distintas.

**Decidido:** O Final D (Venda) é a decisão consciente — cutscene digna se voluntária. A falência forçada por dívida não paga é um caminho narrativo separado (cascade de crise → Abutre oferece resgate → aceitar fecha o jogo de forma mais pesada). Não é tecnicamente um final novo, é o Final D ativado em condição de desespero, com cena mais curta.

**O final é revelado somente ao terminar, ou o jogador tem previsão do que está construindo?**

*Por que importa:* Se o jogador não sabe que os finais alternativos existem, pode chegar à sessão sem as condições e ficar preso num final que não queria.

**Decidido:** Pistas progressivas, nenhuma explica as condições completas. O Diário do Porto sugere caminhos via fragmentos. NPCs específicos (Toninho sobre o avô, Bela sobre Arlindo, Sr. Ribeiro sobre unificação) deixam dicas conforme reputação cresce. O Final E (secreto) nunca é insinuado por NPC — só pelo fio da carga sem nota. O jogo NUNCA revela 'quantos finais existem' — o jogador descobre jogando.

**O Memorial do Avô é pré-requisito de qual final?**

*Por que importa:* Conceitos menciona que o Memorial completo é pré-requisito de um dos finais alternativos. Precisa estar amarrado.

**Decidido:** Memorial completo (todas as peças descobertas + construção física) desbloqueia variação especial do Final B (Porto da Cidade). Em vez do epílogo padrão (cidade cinco anos depois), o jogador tem uma cena final em frente ao Memorial: Toninho conta o que aconteceu nos últimos meses do avô e entrega um único objeto guardado por 20 anos. O ciclo se fecha. Não é um final separado — é uma camada emocional adicional ao Final B.

**Existe New Game Plus ou o jogo é single-playthrough?**

*Por que importa:* NG+ com conhecimento das escolhas é uma forma de recompra emocional. Pode ser simples (começa com recursos extras) ou complexo (novo arco). Decisão afeta o escopo.

**Decidido:** Sem NG+ formal. O Diário do Porto fica acessível após o final com todos os fragmentos desbloqueados. O jogador pode reler a campanha inteira. Replayability vem dos 5 finais distintos, não de NG+.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
