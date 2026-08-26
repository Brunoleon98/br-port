import { useState } from "react";

/* =================================================================
   ConceitosPrincipais  —  fonte: BR_Port_Conceitos_Principais_v5_5.jsx
   Conteúdo e lógica preservados integralmente; apenas isolado
   em escopo próprio para evitar colisão de identificadores.
   ================================================================= */
const ConceitosPrincipais = (() => {
const sections = [
  {
    id: "identity",
    icon: "⚓",
    label: "Identidade",
    color: "#1a6b8a",
    bg: "#e8f4f8",
    content: {
      title: "BR Port",
      subtitle: "Conceito central",
      tagline: '"From dock hand to harbor legend."',
      fields: [
        { label: "Gênero", value: "Management + Estratégia com Narrativa" },
        { label: "Arte", value: "Flat Design 2D — estética tropical brasileira" },
        { label: "Plataforma principal", value: "Mobile (Android / iOS)" },
        { label: "Expansão futura", value: "Versão PC (Steam / itch.io)" },
        { label: "Língua principal", value: "Inglês — mercado global" },
        { label: "Época", value: "Brasil contemporâneo — anos 2000+" },
      ],
    },
  },
  {
    id: "setting",
    icon: "🌴",
    label: "Cenário",
    color: "#2d7a3a",
    bg: "#eaf5ec",
    content: {
      title: "Porto Mirim",
      subtitle: "A cidade",
      tagline:
        '"Uma cidadezinha costeira fictícia no litoral brasileiro — sol forte, mar quente, política torta e gente boa demais."',
      fields: [
        { label: "Inspiração", value: "Litoral brasileiro — do Nordeste ao Sul" },
        { label: "Tamanho", value: "Pequena — ~12.000 habitantes no início" },
        { label: "Economia local", value: "Pesca artesanal, turismo incipiente, porto decadente" },
        { label: "Atmosfera visual", value: "Casas coloridas, mangue, coqueiros, barcos de madeira" },
        { label: "Tom da cidade", value: "Quente, caótico e cheio de personalidade" },
        { label: "Rivais regionais", value: "Porto da cidade vizinha, Grupo Atlântico S.A." },
      ],
    },
  },
  {
    id: "protagonist",
    icon: "🧑‍✈️",
    label: "Protagonista",
    color: "#7a4d1a",
    bg: "#f9f0e6",
    content: {
      title: "O/A Herdeiro(a)",
      subtitle: "Personagem principal",
      tagline: '"Você nunca quis o cais. Mas o cais sempre foi seu."',
      fields: [
        { label: "Nome", value: "Personalizável pelo jogador" },
        { label: "Gênero", value: "Masculino ou feminino (escolha do jogador)" },
        { label: "Idade", value: "24–28 anos" },
        { label: "Origem", value: "Neto(a) de Seu Maneco, fundador do Cais Mirim" },
        { label: "Conflito inicial", value: "Avô falece e deixa o cais cheio de dívidas" },
        { label: "Motivação", value: "Honrar o avô — e provar que consegue fazer maior que ele" },
        { label: "Personalidade", value: "Curioso, teimoso, bom humor, às vezes impulsivo" },
      ],
    },
  },
  {
    id: "npcs",
    icon: "👥",
    label: "NPCs",
    color: "#5a3480",
    bg: "#f0eafa",
    content: {
      title: "Elenco Principal",
      subtitle: "Personagens fixos com personalidade e diálogos",
      tagline: '"Cada NPC tem seu jeito, seu segredo e seu preço."',
      npcs: [
        {
          name: "Dona Cida",
          role: "Contadora do porto",
          personality: "Pragmática, brava, mas leal. Conhece cada centavo do negócio.",
          humor: '"O cais tá no vermelho, chefia. Mas que vermelho bonito..."',
        },
        {
          name: "Zezão",
          role: "Mestre de obras / Mecânico",
          personality: "Forte, preguiçoso quando quer, gênio quando precisa. Fala pouco.",
          humor: '"Conserto qualquer coisa. Menos gente."',
        },
        {
          name: "Capitão Arlindo",
          role: "Rival local — dono do Porto Farol",
          personality: "Simpático na superfície, competitivo por baixo. Tem contatos políticos.",
          humor: '"Que bom te ver crescer, sobrinho. É mais fácil de acompanhar."',
        },
        {
          name: "Bela",
          role: "Repórter / Aliada opcional",
          personality: "Investigativa, idealista. Expõe corrupção — e pode te ajudar ou te prejudicar.",
          humor: '"Não faz nada que não queira ver na manchete."',
        },
        {
          name: "Sr. Abutre",
          role: "Investidor / Antagonista principal",
          personality: "Grupo Atlântico S.A. quer comprar Porto Mirim. Educado, implacável.",
          humor: '"Tenho admiração pela sua teimosia. Ela tem prazo de validade."',
        },
        {
          name: "Sr. Ribeiro",
          role: "Gerente do Banco de Porto Mirim",
          personality: "Foi amigo do avô. Paciente no início, formal conforme os atrasos crescem. A dívida tem um rosto.",
          humor: '"O senhor tem até sexta. Isso não é ameaça — é matemática."',
        },
      ],
    },
  },
  {
    id: "novos_npcs",
    icon: "🧩",
    label: "NPCs Secundários",
    color: "#5a3480",
    bg: "#f0eafa",
    content: {
      title: "Toninho, Seu Biu e Kinha",
      subtitle: "Fichas narrativas completas",
      tagline: '"Três personagens que o cais sabia que existiam. Agora eles têm história."',
      npcs: [
        {
          name: "Toninho Barros",
          role: "Estivador-chefe / Memória viva do porto",
          personality: "Estava no cais antes de o protagonista nascer. Trabalhou para Seu Maneco vinte anos como estivador — hoje é o estivador-chefe, papel formal com salário de R$ 210/sem (ver Funcionários). Mas é mais do que função: a lealdade ao Seu Maneco foi transferida automaticamente para o herdeiro, e ele se tornou também a memória viva do porto. Sabe mais do que fala e nunca conta o que sabe antes de sentir que a hora é certa. Guarda a chave do galpão velho. Conhece cada parte podre do píer de cor. Guarda o segredo mais importante sobre os últimos meses do avô — e só conta se o jogador tiver paciência para ganhar a confiança certa.",
          humor: '"Seu Maneco me ensinou tudo sobre esse cais. Inclusive a não contar tudo que sei."',
        },
        {
          name: "Seu Biu",
          role: "Pescador veterano / Vigia noturno por hábito",
          personality: "O mais antigo dos pescadores do píer. Chegou antes do porto existir e intenciona ir embora depois que ele fechar. Observa tudo da ponta do seu barco com aparente desinteresse. Nunca oferece informação — mas quando o jogador pergunta do jeito certo, o que ele sabe muda o jogo. Especialista em dizer a verdade de um jeito que parece mentira. Vigia noturno por hábito, não por função — desde os tempos do avô fica acordado quase toda noite por costume. O jogador pode formalizar isso contratando-o como vigia (R$ 120/sem — ver Funcionários), o que muda nada no comportamento dele mas dobra a relação dele com o porto: pescador de dia, vigia formal de noite.",
          humor: '"Tive uma noite tranquila. Vi tudo. Não vi nada."',
        },
        {
          name: "Kinha Ferreira",
          role: "Técnica naval / Chefe de manutenção a partir da Fase 3",
          personality: "Cresceu consertando o barco do pai desde os oito anos. É a pessoa mais tecnicamente competente do porto — e a que ganha menos por isso. Pragmática e sem paciência para desculpa. Aparece como contratável a partir da Fase 2 (R$ 200/sem) inicialmente como mecânica. Na Fase 3, com a área de manutenção naval construída, é promovida a chefe de manutenção. Quando o jogador finalmente paga o que ela vale, ela não agradece. Diz 'era o que deveria ser' e volta ao trabalho. Lidera o arco narrativo central sobre desigualdade.",
          humor: '"Tô consertando o que o Zezão não quer admitir que quebrou."',
        },
      ],
    },
  },
  {
    id: "protagonista_custom",
    icon: "🎨",
    label: "Personalização",
    color: "#7a4d1a",
    bg: "#f9f0e6",
    content: {
      title: "Nome & Aparência do Protagonista",
      subtitle: "Identidade visual e o nome que a cidade vai conhecer",
      tagline: '"O nome do porto é o nome do seu legado. A roupa que você usa fala antes de você falar."',
      pillars: [
        {
          icon: "📛",
          name: "Nome do porto e do personagem",
          desc: "Na primeira tela do jogo, o jogador define dois nomes: o seu (exibido em diálogos e documentos) e o nome do Cais — que substitui 'Cais Mirim' em toda a interface. NPCs adotam o nome escolhido naturalmente. Toninho sempre chama de 'chefia'. Dona Cida usa o nome formal. Zezão raramente usa — e quando usa, é importante. O nome do porto aparece na placa do galpão, nos contratos impressos e na manchete do jornal de Bela quando o porto recebe reconhecimento.",
        },
        {
          icon: "📝",
          name: "Convenção do GDD: 'Cais Mirim' é placeholder",
          desc: "Em todo o GDD e nos diálogos pré-escritos, 'Cais Mirim' aparece como nome-padrão de referência. Na implementação, esse string é tratado como variável substituível pelo nome escolhido pelo jogador na primeira tela. Tecnicamente: usar um único token (ex.: {portName}) em todos os textos de UI e diálogo, com 'Cais Mirim' como fallback exibido apenas se o jogador deixar o campo em branco. Manchetes da Bela, contratos, placa do galpão, finais ('o [nome do cais] permanece independente') — todos usam o mesmo token. Nenhuma referência ao porto deve ficar hardcoded em texto.",
        },
        {
          icon: "👤",
          name: "Aparência — partes personalizáveis",
          desc: "Tom de pele (escala ampla representando a diversidade do litoral brasileiro), tipo e cor de cabelo, olhos, sobrancelhas, boca e formato de rosto. Gênero masculino ou feminino, como já definido. Todas as opções são geradas em Flat Design vetorial consistente com o estilo visual do jogo. A silhueta do protagonista é robusta — adequada para trabalho portuário, não estereotipada.",
        },
        {
          icon: "👕",
          name: "Roupas e impacto narrativo",
          desc: "Três registros de vestimenta com variações de cor: Trabalho (camiseta, bermuda, bota — o cotidiano do porto), Social (camisa, calça — para visitas à prefeitura, reuniões, eventos do setor) e Formal (terno, gravata — para negociações com o Grupo Atlântico e cerimônias de prestígio). O jogo detecta o contexto e NPCs comentam quando o protagonista aparece fora do registro esperado: Dona Cida: 'Chefia, o senhor vai assim mesmo pra reunião com a Dra. Patrícia?' O Grupo Atlântico responde diferente conforme a apresentação visual.",
        },
        {
          icon: "🔄",
          name: "Quando e como trocar",
          desc: "Roupas trocadas livremente entre turnos, sem custo. Mas roupas formais precisam ser adquiridas — aparecem como item narrativo, não como loja separada. O terno do avô é encontrado no galpão velho durante o tutorial. Usá-lo numa reunião importante gera uma linha de Toninho que é um dos momentos mais emotivos do early game.",
        },
        {
          icon: "🎭",
          name: "Impacto real nas interações",
          desc: "Terno numa reunião com o Abutre: ele observa que o protagonista 'se preparou' — resposta ligeiramente diferente. Camiseta: 'Conheço esse tipo — acredita que honestidade vale mais que aparência.' Arlindo comenta se o jogador aparece sempre no mesmo registro — a falta de adaptação social incomoda quem nasceu negociando. Bela nunca comenta a aparência diretamente. Ela escreve sobre o que a aparência revela sobre caráter.",
        },
      ],
    },
  },
  {
    id: "casa_protagonista",
    icon: "🏚️",
    label: "Casa",
    color: "#7a4d1a",
    bg: "#f9f0e6",
    content: {
      title: "Casa do Protagonista",
      subtitle: "O espaço pessoal — o que o avô deixou junto com as dívidas",
      tagline: '"Você dormiu aqui na primeira noite porque não tinha pra onde ir. Depois ficou."',
      pillars: [
        {
          icon: "🚪",
          name: "A casa herdada — estado inicial",
          desc: "Casa modesta a 4 minutos a pé do cais. Sala, cozinha, dois quartos, banheiro e quintal pequeno com mangueira velha. Pintura descascada, mobília básica do avô, móveis de madeira escura típicos do litoral. O jogador caminha pelos cômodos navegando — espaço jogável real, não abstrato. Cada cômodo tem objetos interativos descobertos ao longo do jogo: gaveta da escrivaninha com fotos do avô novo, prateleira com livros marcados, álbum de recortes no fundo do guarda-roupa.",
        },
        {
          icon: "🛋️",
          name: "Reforma e decoração",
          desc: "Cômodos reformáveis gradualmente — pintura nova, troca de móveis, ampliação do quintal. Decoração com itens narrativos: arte comprada, troféus de pesca, lembranças de eventos do setor, fotos do diário emolduradas. A casa registra o que o jogador conquistou de um jeito que nenhum painel de stats faz. Visitas dos NPCs reagem ao estado da casa — Dona Cida na primeira visita: 'Pelo menos a água quente funciona agora.'",
        },
        {
          icon: "👥",
          name: "Visitas dos NPCs",
          desc: "NPCs específicos visitam em gatilhos narrativos próprios. Toninho aparece sem avisar trazendo coisa do galpão do avô. Dona Cida vem quando precisa conversar sobre algo que não cabe no escritório. Bela visita uma vez no ato 2 — momento charneira da relação. A família visita no Natal. Vínculo alto desbloqueia jantares casuais que viram entradas próprias no diário.",
        },
        {
          icon: "🛌",
          name: "Descanso e moral",
          desc: "Dormir em casa entre turnos longos dá bônus pequeno de moral ao jogador (não aos funcionários). Funciona como pausa narrativa — uma noite em casa permite ao jogo introduzir sonhos curtos com o avô, lembranças de infância no porto, ou trechos da campanha vistos de outro ângulo. Não obrigatório. Quem nunca dorme em casa perde essas vinhetas.",
        },
        {
          icon: "🍳",
          name: "Cozinhar e comer em casa",
          desc: "Ligação direta com o hobby de culinária. O peixe pescado vira ingrediente. Pratos preparados em casa podem ser oferecidos em festividades, levados ao Bar do Mané ou compartilhados com visitas. Cozinhar exige tempo curto de jogo e gera moral pequena. NPCs com vínculo comentam pratos servidos: Zezão prefere comida pesada, Bela tem paladar refinado e isso aparece sutilmente em diálogos.",
        },
      ],
    },
  },
  {
    id: "hobbies_estudos",
    icon: "📚",
    label: "Hobbies & Estudos",
    color: "#4a1a6b",
    bg: "#f0e8f8",
    content: {
      title: "Desenvolvimento Pessoal",
      subtitle: "O que o protagonista é, fora do papel de gestor do porto",
      tagline: '"O porto cresce porque você cresce. O contrário também é verdade."',
      pillars: [
        {
          icon: "⚓",
          name: "Navegação",
          desc: "Estudar com Seu Biu ou frequentar curso na Capital Regional. 8 semanas de jogo, sessões curtas espalhadas. Libera: pilotagem de barco próprio para pesca em mar aberto sem custo de aluguel, possibilidade de cumprir uma rota de fretamento pessoalmente em emergência (com cena exclusiva), e diálogo desbloqueado com Seu Biu que muda a relação entre os dois. Não dá bônus mecânico em contratos — dá presença narrativa.",
        },
        {
          icon: "📊",
          name: "Gestão Financeira",
          desc: "Estudar com Dona Cida ou frequentar SENAC online (presença em casa, sem viagem). 6 semanas de jogo. Libera: relatórios financeiros com camada extra de análise (margem por cliente, projeção de fluxo, decomposição de despesas), ferramenta de simulação 'e se' antes de aceitar contrato grande, e nova fala recorrente de Dona Cida — ela passa a tratar o jogador como par, não como aprendiz.",
        },
        {
          icon: "🗣️",
          name: "Idioma estrangeiro",
          desc: "Língua estrangeira para o protagonista — independe da língua da UI (o jogo é jogável em inglês ou PT-BR, mas dentro da ficção do mundo, o protagonista é brasileiro e fala português como nativo). O hobby cobre estudo de inglês ou espanhol, com livros e mídias do avô (ele tinha curso antigo de inglês náutico inacabado). 12 semanas de jogo, sessões curtas. Libera: negociação direta com clientes internacionais que aparecem no late game (sem intérprete = margem maior), acesso a contratos exclusivos no porto da Capital Regional, e um arco discreto em que o protagonista termina o curso que o avô não terminou. Toninho sabe que era um sonho do Seu Maneco. Reage à conclusão.",
        },
        {
          icon: "🍳",
          name: "Culinária",
          desc: "Aprender com NPCs locais — Dona Edith do mercado, Seu Biu para preparo de peixe, livro de receitas da avó encontrado na casa. 6 semanas distribuídas. Libera: pratos cozinhados em casa viram itens com efeito narrativo (Zezão fica fiel por meses depois de uma feijoada bem feita), prato próprio servido na Festa de São Pedro vira ponto fixo do evento anual, possibilidade de competir num concurso culinário improvisado da Semana do Mar contra Arlindo.",
        },
        {
          icon: "⏱️",
          name: "Como o sistema funciona",
          desc: "Cada hobby é uma trilha paralela ao porto. O jogador dedica fragmentos de dia (não dias inteiros) — uma manhã em casa estudando, uma tarde com Seu Biu no píer aprendendo nó, uma noite cozinhando. O progresso aparece como barra discreta no diário, não no HUD principal. Concluir um hobby gera entrada própria no Diário com reflexão do protagonista. Múltiplos hobbies em paralelo são lentos mas possíveis — o jogo recompensa quem persegue mais de uma trilha sem otimizar uma.",
        },
        {
          icon: "🎯",
          name: "Conexão com sistemas existentes",
          desc: "Navegação ↔ pesca (mar aberto), Gestão ↔ relatórios financeiros e investimentos, Idioma ↔ eventos do setor internacionais + contratos premium, Culinária ↔ casa + festividades + Bar do Mané. Cada hobby reforça mecanicamente algo que o jogador já faz — não é progressão isolada. Quem estuda gestão e tem imóveis comerciais vê o retorno aumentar 8–12% (decisões melhores). Quem estuda culinária e cozinha para visitas vê os vínculos crescerem mais rápido.",
        },
      ],
    },
  },
  {
    id: "hook",
    icon: "🎣",
    label: "Loop Central",
    color: "#1a4e8a",
    bg: "#e6eef8",
    content: {
      title: "O Loop Central",
      subtitle: "Por que o jogador volta todos os dias",
      tagline: '"Cada contrato assinado abre uma porta. Cada rival provoca uma guerra."',
      pillars: [
        { icon: "📋", name: "Contratos", desc: "Negocie rotas, prazos e preços. Sua reputação define quem te procura. Os contratos disponíveis aparecem na Bolsa do Porto (ver abaixo)." },
        { icon: "📑", name: "Bolsa do Porto", desc: "Quadro central de contratos disponíveis — funciona como uma feira semanal: clientes deixam propostas, leiloeiros anunciam cargas premium, fornecedores postam pedidos urgentes. Acessível pelo menu principal, mostra entre 3 e 12 contratos simultaneamente (depende da fase). Não é local físico — é a representação UI da feira informal de negócios que acontece toda manhã no escritório do porto. Carol e Dona Cida operam a Bolsa quando contratadas; antes disso, o jogador opera diretamente." },
        { icon: "🏗️", name: "Construção", desc: "Expanda o porto fase a fase. Cada melhoria desbloqueia novos tipos de carga e cliente." },
        { icon: "⚔️", name: "Rivalidade", desc: "Concorrentes roubam contratos, derrubam preços e plantam boatos. Reaja." },
        { icon: "💬", name: "Narrativa", desc: "Diálogos com NPCs revelam segredos, missões e reviravoltas da cidade." },
      ],
    },
  },
  {
    id: "tutorial",
    icon: "🎓",
    label: "Tutorial",
    color: "#8a3a1a",
    bg: "#f8ede8",
    content: {
      title: "Tutorial e Onboarding",
      subtitle: "Os primeiros 15 minutos — a impressão que não se repete",
      tagline: '"O jogador aprende fazendo. Nunca lendo painéis de instrução."',
      pillars: [
        {
          icon: "📍",
          name: "Minuto 0–3 — A chegada",
          desc: "O jogador chega ao cais numa cena animada em Flat Design com Toninho esperando na entrada. Sem tela de tutorial pós-abertura — o jogador já está no porto. Toninho explica em duas linhas: 'Seu Maneco deixou tudo pra você. Inclusive as dívidas.' Primeira ação: clicar no galpão velho para inspecioná-lo. Nenhum tutorial explica o clique — o galpão pisca suavemente. Quem não clica em 10 segundos recebe um toque gentil de Toninho: 'O galpão tá chamando.'",
        },
        {
          icon: "🔨",
          name: "Minuto 3–7 — A primeira decisão real (Zezão)",
          desc: "Zezão aparece sem ser chamado. Inspeciona o galpão. Diz que precisa de limpeza antes de qualquer uso — vai custar R$ 400 e dois dias. O jogador tem R$ 600 na caixa. Aceitar ou esperar é a primeira decisão com custo real. Se aceitar: Zezão começa e o tutorial avança. Se esperar: Dona Cida aparece e pergunta gentilmente se o jogador sabe que o galpão parado não gera renda. Sem punição — só consequência natural apresentada por personagem.",
        },
        {
          icon: "🐟",
          name: "Minuto 7–11 — Os pescadores do píer",
          desc: "Seu Biu aparece com dois outros pescadores para 'renovar o trato com o novo dono.' O avô nunca cobrava. O jogador escolhe entre três valores de aluguel semanal: R$ 0 (como o avô), R$ 40 por vaga, R$ 80 por vaga. Cada opção tem uma reação de Seu Biu visível. Sem explicar que isso afeta a reputação comunitária — o jogador lê o rosto do pescador. Depois da escolha, Dona Cida comenta o impacto financeiro com ironia calibrada ao valor escolhido.",
        },
        {
          icon: "⚓",
          name: "Minuto 11–15 — O primeiro barco e a parcela",
          desc: "Um barco de passagem aparece como decisão do dia: aceitar ou recusar. Essa é a primeira mecânica com pressão — mas é baixa: o barco só traz R$ 150. Se aceitar: Toninho ajuda a docagem com uma linha de diálogo. Se recusar: 'Foi pro Porto Farol, esse' — sem punição além da renda perdida. Ao final, Dona Cida apresenta a planilha da dívida: três parcelas, 12 semanas. O botão 'Próximo dia' aparece em destaque pela primeira vez. A câmera abre o mapa do porto. O jogo começa.",
        },
        {
          icon: "🚫",
          name: "O que nunca entra no tutorial",
          desc: "Painel de 'bem-vindo ao tutorial'. Indicador de progresso (Passo 1 de 8). Ícone pulsando em cada botão disponível. Texto de instrução sobreposto. Recompensa ao completar o tutorial. O onboarding termina sem anúncio — o jogo simplesmente começa.",
        },
      ],
    },
  },
  {
    id: "economia",
    icon: "💰",
    label: "Economia",
    color: "#1a6b8a",
    bg: "#e8f4f8",
    content: {
      title: "Fontes de Renda — Early Game",
      subtitle: "As três fontes iniciais do porto",
      tagline: '"O cais decadente tem mais valor do que parece. Só precisa de alguém que saiba olhar."',
      pillars: [
        {
          icon: "🐟",
          name: "Aluguel do píer aos pescadores",
          desc: "Renda passiva desde o dia 1. 6 vagas no píer de pescadores (estrutura separada das docas comerciais) que o avô nunca cobrou. O píer é exclusivo para barcos de pesca artesanal pequenos — diferente das docas comerciais (4 docas pequenas iniciais para barcos de carga/passageiros, que entram na Fase 1 e expandem). O jogador define o valor do aluguel do píer — barato mantém a relação, caro gera tensão e risco de migração para o Porto Farol. Evolui para lota de peixe própria.",
        },
        {
          icon: "📦",
          name: "Armazém de carga avulsa",
          desc: "Galpão nos fundos que precisa de limpeza (missão tutorial com Zezão). Clientes locais pagam por armazenamento temporário. Primeiro dilema moral: uma carga sem nota aparece cedo com dinheiro bom. Evolui para terminal de carga regional.",
        },
        {
          icon: "⚓",
          name: "Docagem de barcos de passagem",
          desc: "Barcos chegam aleatoriamente com alerta e tempo limite para aceitar. Mais narrativa das três: cada barco pode trazer NPC, boato, missão ou espião do Grupo Atlântico. Evolui para rota regular contratada.",
        },
      ],
    },
  },
  {
    id: "rivais_acao",
    icon: "⚔️",
    label: "Rivais em Ação",
    color: "#8a1a1a",
    bg: "#f8e8e8",
    content: {
      title: "Como os Rivais Agem",
      subtitle: "Pressão indireta, nunca confronto direto",
      tagline: '"A sensação é de que as coisas estão dando errado por acaso — até o jogador perceber o padrão."',
      pillars: [
        {
          icon: "🎭",
          name: "Arlindo — age por dentro",
          desc: "Usa contatos políticos para criar atritos disfarçados de coincidência. Oferece preço menor ao cliente que o jogador está prestes a fechar. Atrasa licenças de construção via prefeitura sem explicação. Aborda funcionários com moral baixa com propostas de emprego — nunca ameaça, só oferece. Planta boatos sobre a qualidade do cais: a reputação cai silenciosamente e o jogador só percebe quando os contratos param de chegar.",
        },
        {
          icon: "🏢",
          name: "Grupo Atlântico / Abutre — age por cima",
          desc: "Pressão econômica, não pessoal. Oferece contratos exclusivos aos fornecedores do jogador para cortá-los da cadeia. Financia melhorias no Porto Farol para que Arlindo pressione o jogador por dois lados ao mesmo tempo. Em momentos de dívida alta, aparece com proposta de 'sociedade' que é na prática uma compra disfarçada.",
        },
        {
          icon: "💡",
          name: "Princípio de design",
          desc: "Rivais nunca atacam de frente no início. O momento em que o jogador percebe o padrão e entende que não foi azar — foi Arlindo — é um dos beats narrativos mais importantes do early game.",
        },
      ],
    },
  },
  {
    id: "precos",
    icon: "📊",
    label: "Preços",
    color: "#3a6b1a",
    bg: "#edf5e8",
    content: {
      title: "Variação Dinâmica de Preços",
      subtitle: "O mercado de Porto Mirim é pessoal, não abstrato",
      tagline: '"Os preços mudam por causa de pessoas e eventos, não de algoritmos invisíveis."',
      pillars: [
        {
          icon: "🐟",
          name: "Oferta e demanda local",
          desc: "Se muitos barcos chegam juntos trazendo peixe, o preço cai naquela semana. Se houve tempestade e a frota não saiu, o preço sobe. O jogador vê isso como uma tag simples ao lado da carga: 'mercado saturado' ou 'produto escasso'. Sem gráficos complexos.",
        },
        {
          icon: "📅",
          name: "Sazonalidade como base de preços",
          desc: "A variação de preço não é um sistema separado — é consequência da sazonalidade já definida. Em janeiro, equipamentos turísticos valem mais. Em maio, qualquer carga rende menos. Quem leu a sazonalidade já entende a lógica dos preços sem tutorial adicional.",
        },
        {
          icon: "📰",
          name: "Eventos que distorcem o mercado",
          desc: "Uma greve no porto de outra cidade faz contratos de frete regional chegarem em dobro com urgência. Um escândalo de produto adulterado derruba determinada carga por duas semanas. Esses eventos são anunciados pela Bela no jornal local antes de acontecerem — quem lê as matérias dela leva vantagem competitiva.",
        },
        {
          icon: "🚫",
          name: "O que não entra no sistema",
          desc: "Sem inflação contínua, moeda que deprecia ou gráficos de mercado complexos. Porto Mirim é uma cidade pequena — a economia dela é reativa e humana, não financeira.",
        },
      ],
    },
  },
  {
    id: "gastos_prestigio",
    icon: "🏠",
    label: "Prestígio & Ativos",
    color: "#1a4e8a",
    bg: "#e6eef8",
    content: {
      title: "Carros, Imóveis e Arte",
      subtitle: "O que fazer com o dinheiro além de expandir o porto",
      tagline: '"Porto Mirim não é só trabalho. Chega um ponto em que o que você tem diz o que você se tornou."',
      pillars: [
        {
          icon: "🚗",
          name: "Carros — status, mobilidade e manutenção",
          desc: "Quatro categorias condizentes com o contexto realista de um porto pequeno no Brasil contemporâneo: usados antigos (carro do avô recuperado, deslocamento básico — gera bônus afetivo, Toninho reage), populares (sedan ou hatch novo, status local respeitável), premium nacional (caminhonete ou SUV de marca brasileira/montadora local, sinaliza ascensão social na cidade) e clássicos restaurados (peças raras com história, prestígio cultural — não preço astronômico, mas reconhecimento entre quem sabe ler). Usar o carro em visitas à cidade e regiões gera bônus de status — NPCs e clientes reagem conforme o veículo. Cada viagem consome condição (0–100%) — em zero, o veículo precisa de reparo com Zezão ou oficina regional. Alternativas sem carro próprio: transporte público (gratuito, sem status) ou aplicativo de carona (custo por viagem, sem bônus de impressão). Arlindo nunca chega de ônibus — o jogador percebe isso.",
        },
        {
          icon: "🏡",
          name: "Imóveis residenciais — férias e recuperação",
          desc: "Compráveis nas regiões desbloqueadas do mapa: apartamento em Praia Grande, chalé na Foz do Tucunaré, villa na Ilha das Pedras Brancas, cobertura na Capital Regional. O jogador pode 'tirar férias' gastando dias de jogo sem gerenciar o porto — funcionários de alta lealdade mantêm a operação básica. Quanto melhor o imóvel e a localização, maior o bônus de retorno: reputação comercial sobe levemente (o protagonista voltou mais presente) e os trabalhadores comentam a diferença. Imóveis residenciais são colecionáveis com descrições únicas de Dona Cida na compra.",
        },
        {
          icon: "🏢",
          name: "Imóveis comerciais — renda passiva e riscos",
          desc: "Galpões, salas comerciais e pontos de comércio nas regiões do mapa. Geram renda passiva semanal independente do porto. Quanto mais valorizado o imóvel e a região, maior o retorno — ponto comercial na Capital Regional rende mais do que galpão em Praia Grande, mas custa três vezes mais. Riscos incluem: vacância (inquilino vai embora), manutenção eventual e possibilidade do Grupo Atlântico se tornar vizinho — o que ativa evento narrativo onde a pressão deles alcança também essa frente.",
        },
        {
          icon: "🎨",
          name: "Arte e colecionáveis — prestígio puro",
          desc: "Peças compráveis em eventos do setor, com artesão local de Porto Mirim ou em leilões esporádicos. Sem renda direta — puro prestígio. Exibidas no escritório do porto e na residência. Visitantes de alto nível (clientes corporativos, Dra. Patrícia) comentam quando reconhecem uma peça. Bela pode escrever sobre o acervo — positivo se for arte local, ambíguo se forem peças de origem duvidosa. Uma peça conecta ao segredo da carga ilegal: seu comprador original é alguém que o jogador já encontrou.",
        },
        {
          icon: "📦",
          name: "Coleção e patrimônio — sem grindfest",
          desc: "Não há lista de 'complete todos os itens' visível. O jogador descobre que colecionou quando Dona Cida comenta: 'Chefia, o senhor tem três carros e sempre usa o mesmo.' Os ativos aparecem no Diário do Porto como linha do tempo patrimonial. Há um final alternativo menor em que o protagonista vende tudo para cobrir dívida de emergência — o porto sobrevive mais enxuto que o necessário, e o jogo registra a escolha sem julgamento.",
        },
      ],
    },
  },
  {
    id: "relatorios_financeiros",
    icon: "📊",
    label: "Relatórios",
    color: "#1a6b3a",
    bg: "#e6f5ec",
    content: {
      title: "Relatórios Financeiros",
      subtitle: "Dona Cida organiza — o jogador decide o que fazer com o que aprendeu",
      tagline: '"Eu não sei por que a margem caiu. Mas sei onde procurar." — Dona Cida',
      pillars: [
        {
          icon: "📅",
          name: "Boletim semanal",
          desc: "Todo final de semana de jogo, Dona Cida apresenta o Boletim Financeiro: receita por fonte (docagens, armazém, aluguel de píer, investimentos, imóveis), despesas fixas (salários, manutenção, parcelas), resultado líquido e comparação com a semana anterior. Exibido como carta visual simples — não como painel de gráficos. O tom de Dona Cida muda conforme o resultado: ironia seca quando ruim, frieza calculista quando bom, rara comemoração quando excepcional.",
        },
        {
          icon: "📈",
          name: "Balanço de fase",
          desc: "Ao completar cada fase, o Diário do Porto recebe o Balanço da Fase: patrimônio total (porto + ativos externos), evolução de cada fonte de receita, maior contrato fechado, pior semana e melhor semana. Comparado automaticamente com a fase anterior. Único momento em que o jogador vê uma linha do tempo gráfica do patrimônio desde o início — clicável para detalhar qualquer período.",
        },
        {
          icon: "🔍",
          name: "Análise sob demanda",
          desc: "O jogador pode pedir a Dona Cida análises específicas: 'Quanto o imóvel de Praia Grande realmente rende?' ou 'Qual tipo de carga deu mais margem nas últimas 4 semanas?' Disponível como diálogo opcional, não como painel sempre visível. Cada análise custa 1 dia de jogo — Dona Cida precisa de tempo para organizar os dados. A resposta vem em linguagem de personagem, não em planilha fria.",
        },
        {
          icon: "⚠️",
          name: "Alertas proativos",
          desc: "Três gatilhos que fazem Dona Cida avisar sem ser solicitada: caixa abaixo de 20% do necessário para a próxima parcela, fonte de receita que caiu mais de 40% em relação à semana anterior, e investimento vencendo em menos de 2 semanas sem decisão do jogador. O alerta chega como diálogo curto — dois cliques e o jogador entende o problema. Sem push notification — só quem está jogando no momento recebe.",
        },
      ],
    },
  },
  {
    id: "dividas",
    icon: "🏦",
    label: "Dívidas",
    color: "#8a3a1a",
    bg: "#f8ede8",
    content: {
      title: "Sistema de Dívidas",
      subtitle: "O banco tem um rosto",
      tagline: '"A dívida não é um contador de game over. É um personagem."',
      fields: [
        { label: "Total herdado", value: "R$ 48.000 em 3 parcelas ao longo de 12 semanas" },
        { label: "Parcela 1 (sem. 4)", value: "R$ 8.000 — pequena, qualquer ritmo cobre. Tutorial de sobrevivência." },
        { label: "Parcela 2 (sem. 8)", value: "R$ 16.000 — exige contrato de frete ativo. Ponto dramático central." },
        { label: "Parcela 3 (sem. 12)", value: "R$ 24.000 — Sr. Abutre aparece antes como comprador. Ato simbólico." },
        { label: "Atraso 1 semana", value: "Juros de 5%/dia. Sr. Ribeiro visita — cena tensa, sem penalidade mecânica." },
        { label: "Atraso 2 semanas", value: "Vaga do píer penhorada. Relação com pescadores cai. Arlindo comenta." },
        { label: "Atraso 3 semanas", value: "Banco notifica execução. Abutre oferece resgate — aceitar = final ruim." },
        { label: "Válvulas de escape", value: "Renegociação única / Vaquinha da comunidade / Contrato de emergência / Venda de ativo" },
      ],
    },
  },
  {
    id: "banco_investimentos",
    icon: "🏦",
    label: "Banco",
    color: "#8a3a1a",
    bg: "#f8ede8",
    content: {
      title: "Banco de Porto Mirim — Além da Dívida",
      subtitle: "Sr. Ribeiro como hub financeiro completo: empréstimos e investimentos",
      tagline: '"Sr. Ribeiro foi amigo do seu avô. Isso não significa que ele vai te dar dinheiro de graça."',
      pillars: [
        {
          icon: "💳",
          name: "Empréstimos voluntários",
          desc: "Além da dívida herdada, o jogador pode solicitar empréstimos para antecipar investimentos. Três linhas por fase: Linha Porto (fases 1–2, até R$ 10.000, juros 3%/semana), Linha Crescimento (fases 2–3, até R$ 30.000, juros 2,5%/semana) e Linha Empresarial (fases 4–5, até R$ 80.000, juros 1,8%/semana). Sr. Ribeiro só libera empréstimo se o histórico de pagamento da dívida herdada foi limpo — atraso anterior aumenta a taxa em 0,5% por semana de atraso acumulado.",
        },
        {
          icon: "📈",
          name: "Investimentos disponíveis",
          desc: "Com saldo positivo, o jogador pode aplicar dinheiro em três produtos: Caderneta (rendimento baixo e seguro, 0,8%/semana, liquidez imediata), CDB Porto Mirim (rendimento médio, 1,4%/semana, resgate em 4 semanas) e Fundo Regional (rendimento variável, 0–3%/semana, afetado por eventos de mercado como greve portuária ou boom turístico). Dona Cida alerta quando o saldo parado em conta poderia estar rendendo.",
        },
        {
          icon: "🤝",
          name: "A evolução de Sr. Ribeiro",
          desc: "Conforme o relacionamento cresce — dívidas pagas em dia, empréstimos quitados com antecedência — Sr. Ribeiro passa de cobrador a aliado cauteloso. Em fase avançada, avisa discretamente quando o Grupo Atlântico movimenta crédito na região. Se o jogador sempre atrasa, ele se torna formal e distante: cumpre a função mas não dá mais que o contrato exige. A relação tem memória — ele menciona o número de atrasos em negociações futuras.",
        },
        {
          icon: "⚠️",
          name: "Limites e regras do sistema",
          desc: "O banco nunca empresta mais que 40% do patrimônio avaliado do porto — há garantia real implícita. Dois empréstimos simultâneos exigem aprovação especial com diálogo de 48h de jogo. Se o jogador usa empréstimo para comprar imóvel comercial, Sr. Ribeiro comenta: 'Interessante estratégia. Seu avô nunca diversificou assim.' É elogio ou crítica — o jogador decide o que quer ouvir.",
        },
      ],
    },
  },
  {
    id: "vaquinha",
    icon: "🤲",
    label: "Vaquinha",
    color: "#2d7a3a",
    bg: "#eaf5ec",
    content: {
      title: "Vaquinha da Crise",
      subtitle: "A cidade salva o porto — mas tem condições",
      tagline: '"Ninguém junta dinheiro pra salvar quem nunca foi generoso."',
      pillars: [
        {
          icon: "🔓",
          name: "Condições de desbloqueio",
          desc: "A vaquinha só está disponível se três condições forem simultâneas: (1) Reputação comunitária acima de 70. (2) Dívida em atraso de pelo menos 1 semana — existe uma crise real. (3) O jogador nunca aceitou proposta do Grupo Atlântico. A comunidade só salva quem claramente não quer vender. Se as três condições não forem atendidas, o diálogo de vaquinha nunca aparece. Uma única vaquinha por campanha.",
        },
        {
          icon: "💰",
          name: "Valores por faixa de reputação comunitária",
          desc: "Toninho menciona em diálogo que 'a cidade tá querendo ajudar.' O jogador pode iniciar ou ignorar. Arrecadação ao longo de 5 dias de jogo: reputação 70–79 = R$ 5.000–8.000. Reputação 80–89 = R$ 8.000–14.000. Reputação 90–100 = R$ 14.000–20.000 — cobre quase a segunda ou terceira parcela.",
        },
        {
          icon: "🤝",
          name: "Quem contribui e como aparece",
          desc: "Os pescadores do píer contribuem primeiro se o aluguel for justo — cena curta de Seu Biu entregando envelope. Dona Cida contribui da própria poupança se a lealdade dela for alta — sem anúncio, aparece no total no dia seguinte. A câmara municipal contribui se reputação > 85 e o mangue foi defendido. Arlindo não contribui. Isso não é mencionado por ninguém — mas o jogador pode notar a ausência.",
        },
        {
          icon: "⚡",
          name: "Custo invisível",
          desc: "Aceitar a vaquinha tem consequências não anunciadas. Reputação comercial cai 8 pontos — clientes externos ficam cautelosos por duas semanas. Dona Cida registra como 'doação da comunidade' — Bela pode descobrir e escrever sobre isso. A matéria pode ser positiva (porto que a cidade ama) ou negativa (porto que precisou ser salvo), dependendo da relação entre os dois.",
        },
      ],
    },
  },
  {
    id: "filantropia",
    icon: "🫶",
    label: "Filantropia",
    color: "#2d7a3a",
    bg: "#eaf5ec",
    content: {
      title: "Doações e Causas Locais",
      subtitle: "A versão proativa da vaquinha — agir antes de precisar",
      tagline: '"Ninguém vai atrás de quem nunca apareceu. A cidade não esquece quem ficou."',
      pillars: [
        {
          icon: "🏫",
          name: "Causas disponíveis em Porto Mirim",
          desc: "Escola de navegação para filhos de pescadores. Reforma do posto de saúde do bairro do mangue. Equipamento para o time de futebol local. Fundo de emergência para famílias de pescadores em temporada ruim. Cada causa aparece como evento narrativo espontâneo — alguém menciona em diálogo, Bela escreve no jornal — o jogador decide se age ou ignora. Sem notificação de missão. Quem não lê os diálogos não sabe que a causa estava disponível.",
        },
        {
          icon: "💰",
          name: "Mecânica de doação",
          desc: "O jogador escolhe o valor dentro de uma faixa (mínimo simbólico, máximo sem limite). Abaixo do mínimo: a comunidade não reage bem — Toninho comenta em tom neutro. No valor adequado: reputação comunitária sobe 5–12 pontos conforme a visibilidade da causa. Acima do esperado: Bela escreve — positivo ou ambíguo dependendo da relação. Doação anônima é opção: sem bônus imediato de reputação, mas Toninho sabe. E Toninho guarda.",
        },
        {
          icon: "📅",
          name: "Frequência e limite saudável",
          desc: "Máximo de duas doações por semana de jogo — na terceira tentativa, Dona Cida aparece: 'Chefia, a generosidade tem caixa junto.' Causas recorrentes (escola de navegação, fundo de pescadores) podem receber apoio mensal automatizado — valor fixo debitado toda semana sem interação adicional. Cancelar um apoio recorrente gera reação narrativa — a causa que dependia do porto volta a aparecer como problema.",
        },
        {
          icon: "🔗",
          name: "Conexão com a vaquinha de crise",
          desc: "Quem doou consistentemente ao longo do jogo recebe vaquinha de crise com valores 30–40% maiores do que a tabela padrão de reputação indicaria. A cidade retribui o que o porto deu antes de precisar pedir. Arlindo nunca doa para causas públicas — e Porto Mirim nota a ausência nos momentos em que ele mais quer apoio político.",
        },
      ],
    },
  },
  {
    id: "cargas",
    icon: "🚢",
    label: "Cargas",
    color: "#2d5a7a",
    bg: "#e8f0f8",
    content: {
      title: "Tipos de Carga",
      subtitle: "8 categorias com risco, lucro e narrativa",
      tagline: '"Nenhuma carga é neutra. Toda carga carrega um NPC, uma consequência ou uma escolha."',
      npcs: [
        {
          name: "🐟 Peixe fresco e frutos do mar",
          role: "Risco: Baixo · Lucro: R$ 80–200",
          personality: "Âncora do early game. Prazo de 24h — cada hora de atraso reduz valor em 10%. Vincula os pescadores do píer ao loop central.",
          humor: '"Peixe não espera. Dívida espera. Escolhe o que priorizar, chefia." — Dona Cida',
        },
        {
          name: "⛽ Combustível marítimo",
          role: "Risco: Médio · Lucro: R$ 300–700",
          personality: "Exige posto de abastecimento — primeiro upgrade de infraestrutura. Barcos que docam também abastecem: receita dupla. Enquanto o jogador não tiver, cada barco vai ao Porto Farol.",
          humor: '"A segunda decisão foi não deixar o Zezão perto de fósforo." — Protagonista',
        },
        {
          name: "🧳 Bagagem e equipamentos turísticos",
          role: "Risco: Baixo · Lucro: R$ 120–350",
          personality: "Sazonal (Jan, Jul, Dez). Sensível a dano — equipamento quebrado gera reclamação e reputação negativa. Turista satisfeito posta nas redes; insatisfeito também.",
          humor: '"Turista reclamando é o barulho mais caro que existe." — Dona Cida',
        },
        {
          name: "🍺 Bebidas e alimentos festivos",
          role: "Risco: Baixo · Lucro: R$ 200–500",
          personality: "Volume alto em período curto. Pico no Carnaval e Natal. Carga pode 'desaparecer' do armazém — introduz mecânica de vigilância. Zezão está envolvido. Provavelmente.",
          humor: '"A carga chegou certa. O que aconteceu depois é assunto interno." — Zezão',
        },
        {
          name: "🧱 Material de construção",
          role: "Risco: Baixo · Lucro: R$ 250–600",
          personality: "Ligado ao desenvolvimento urbano. Prefeitura oferece preferência em troca de favores não especificados. Pode ser redirecionado para obras do próprio porto com desconto.",
          humor: '"Cimento não tem cheiro de corrupção. Só de cimento mesmo." — Bela',
        },
        {
          name: "💊 Medicamentos e equipamentos hospitalares",
          role: "Risco: Médio · Lucro: R$ 500–1.200",
          personality: "Rara mas urgente. Exige câmara fria (upgrade). Atraso tem consequência humana real na cidade. Bem executado traz clientes institucionais.",
          humor: '"Tem cargas que você carrega no barco. Tem cargas que carrega na consciência." — Protagonista',
        },
        {
          name: "🎨 Arte, antiguidades e itens de valor",
          role: "Risco: Alto · Lucro: R$ 800–3.000",
          personality: "Cliente misterioso. Às vezes comprador e vendedor não querem ser identificados. Uma peça pode ser produto de roubo — Bela investiga se o jogador aceitar carga suspeita.",
          humor: '"Algumas perguntas têm preço de resposta. Você decide se vale." — Sr. Abutre',
        },
        {
          name: "📦 Carga sem nota fiscal",
          role: "Risco: Altíssimo · Lucro: R$ 1.500–5.000",
          personality: "Nunca aparece no quadro de contratos — alguém aparece pessoalmente. Aceitar abre canal que escala. Fiscalização da Receita é evento aleatório. Recusar pode irritar o contato, que vai ao Porto Farol e planta boato.",
          humor: '"Eu não pergunto o que tem dentro. Você também não devia." — Desconhecido, cais, 22h37',
        },
      ],
    },
  },
  {
    id: "sazonalidade",
    icon: "📅",
    label: "Sazonalidade",
    color: "#2d7a3a",
    bg: "#eaf5ec",
    content: {
      title: "Ciclo Anual de Porto Mirim",
      subtitle: "Calendário fixo — uma campanha cobre uma janela específica",
      tagline: '"A sazonalidade não é só um gráfico — é o ritmo de vida de Porto Mirim."',
      pillars: [
        { icon: "📆", name: "Mapeamento de tempo — campanha base", desc: "A campanha base cobre 12 semanas, equivalentes a ~3 meses corridos no calendário do jogo. O início é fixado em Abril: o protagonista chega a Porto Mirim numa segunda-feira da primeira semana de Abril. A campanha termina no fim de Junho — pegando o vale de Maio (vento sul, maré baixa de renda) e culminando na Festa de São Pedro de Junho, evento dramático central do Ato 3. Os outros picos sazonais (Jan turístico, Fev Carnaval, Ago vento sul, Dez fim de ano) ficam fora da campanha base e aparecem só em pós-campanha (continuação livre após o final) ou em DLCs sazonais futuros." },
        { icon: "🌧️", name: "Mai — O vale (semanas 5–8 da campanha)", desc: "Maio é o vale mais fundo — renda cobre custos fixos mal e mal. Sr. Abutre intensifica contatos sabendo que o caixa aperta. Coincide com o Ato 2 e a Parcela 2 (R$ 16.000), criando o ponto dramático central da campanha." },
        { icon: "⛵", name: "Jun — Festa de São Pedro (semanas 9–12)", desc: "Evento do ano. Procissão marítima, contratos de fretamento festivo, presença política obrigatória. Bela cobre o evento. Alta reputação aqui garante bônus nos meses finais. A festa acontece tipicamente na semana 11 (final do Ato 3), gatilho narrativo de aliança comunitária para o Final B." },
        { icon: "☀️", name: "Jan / Jul / Dez — Picos turísticos (pós-campanha)", desc: "Alta temporada e férias. Turismo náutico no máximo, docagens a 3x o volume. Arlindo concorre diretamente. Esses picos só aparecem em modo de continuação após o final ou em DLCs que estendem o calendário." },
        { icon: "🎭", name: "Fev — Carnaval (pós-campanha)", desc: "Porto opera pela metade. Oportunidade de ser o único porto aberto no feriado vale o dobro. Bloco do porto desfila — cena especial com todos os NPCs. Idem: pós-campanha ou DLC sazonal." },
        { icon: "💨", name: "Ago — Vento sul (pós-campanha)", desc: "Mar agitado e menos concorrência, mas mais risco. Pós-campanha." },
      ],
    },
  },
  {
    id: "funcionarios",
    icon: "👷",
    label: "Funcionários",
    color: "#5a3480",
    bg: "#f0eafa",
    content: {
      title: "Sistema de Funcionários",
      subtitle: "Moral e lealdade — dois medidores independentes",
      tagline: '"Moral é o dia a dia. Lealdade é construída ao longo de semanas."',
      npcs: [
        {
          name: "Marina Saraiva — Operadora de guindaste",
          role: "Moral: 78% · Lealdade: 62% · R$ 180/sem",
          personality: "Pontual, precisa, orgulhosa. Não gosta de hora extra não remunerada. Se lealdade > 70: avisa quando Arlindo a abordou com proposta.",
          humor: '"Guindaste é extensão do braço. Braço precisa de descanso." — Marina',
        },
        {
          name: "Toninho Barros — Estivador-chefe",
          role: "Moral: 45% · Lealdade: 80% · R$ 210/sem",
          personality: "Veterano de 20 anos com o avô. Leal por herança afetiva. Cobre erros do jogador em silêncio quando leal. Organiza pausa coletiva no pior momento quando moral cai demais.",
          humor: '"Trabalhei pra Seu Maneco vinte anos. Vou te dar seis meses de desconto." — Toninho',
        },
        {
          name: "Carol Viana — Administrativa / logística",
          role: "Moral: 85% · Lealdade: 40% · R$ 160/sem",
          personality: "Nova no porto, eficiente, ambiciosa. Ainda decidindo se fica. Se lealdade > 60: traz planilha que economiza 15% nos custos. Se lealdade < 35 em 3 meses: pede demissão e leva o conhecimento dos contratos.",
          humor: '"Eu tenho outras propostas. Só estou esperando ver o que isso aqui vira." — Carol',
        },
        {
          name: "Seu Biu — Vigia noturno",
          role: "Moral: 60% · Lealdade: 90% · R$ 120/sem",
          personality: "18 meses no porto. Conhece tudo, fala pouco. Lealdade além do que qualquer bônus explica. Se lealdade > 85: acorda o jogador quando suspeito entra no cais.",
          humor: '"Essa noite tava estranha. Mas eu só vigio. Não investigo." — Seu Biu',
        },
        {
          name: "Kinha Ferreira — Mecânica de embarcações (Fase 2) · Chefe de manutenção (Fase 3+)",
          role: "Moral: 70% · Lealdade: 55% · R$ 200/sem",
          personality: "Filha de pescador, autodidata. Competente demais pro salário. Sabe disso. Aparece como contratável na Fase 2 inicialmente como mecânica. Na Fase 3, com a área de manutenção naval construída, é promovida a chefe de manutenção. Se leal: conserta motor à meia-noite sem cobrar extra. Se desmotivada: faz só o mínimo e o barco quebra na hora errada.",
          humor: '"Eu sei o que esse motor vale. Só quero saber se você sabe também." — Kinha',
        },
      ],
    },
  },
  {
    id: "contratacao",
    icon: "📋",
    label: "Contratação",
    color: "#5a3480",
    bg: "#f0eafa",
    content: {
      title: "Sistema de Contratação",
      subtitle: "Candidatos chegam — o jogador escolhe quando e quem",
      tagline: '"Ninguém aparece com o emprego garantido. Até Kinha teve que ser descoberta."',
      pillars: [
        {
          icon: "📢",
          name: "Como candidatos aparecem",
          desc: "Três canais. (1) Indicação de NPC: Dona Cida, Toninho ou Seu Biu mencionam alguém em diálogo casual — o jogador pode ou não seguir o fio. (2) Evento espontâneo: a cada 2–3 semanas um candidato aparece no porto pedindo emprego, sem aviso. (3) Pós-crise: após evento de pressão de rival (funcionário recrutado por Arlindo, crise de moral), um substituto aparece mais rapidamente como resposta orgânica da cidade.",
        },
        {
          icon: "👤",
          name: "Ficha de candidato",
          desc: "Cada candidato tem nome, função, custo semanal e dois atributos visíveis (ex: 'Rápido com carga pesada · Mal com prazo curto'). Sem sistema de atributos numéricos escondidos — o que o jogador vê é o que existe. Um detalhe de diálogo ou contexto insinua a personalidade: quem vai dar problema futuro geralmente avisa sem perceber.",
        },
        {
          icon: "💼",
          name: "Vagas e teto por fase",
          desc: "Fase 1: máximo 3 funcionários além de Zezão. Fase 2: até 6 (Kinha entra como mecânica e Carol como administrativa). Fase 3: até 10 (Kinha promovida a chefe de manutenção). Fase 4: até 16, com a entrada do alojamento de tripulações e expansão administrativa. Fase 5: até 24, com o estaleiro completo demandando equipe dedicada. O teto não é explicado por regra — é limitado pela infraestrutura. Sem escritório administrativo (Fase 2), não há onde alocar mais de 3 pessoas operacionalmente. O espaço físico justifica o limite narrativamente.",
        },
        {
          icon: "⚠️",
          name: "Demissão e consequências",
          desc: "Demitir sem aviso prévio (menos de 3 dias): rescisão de 2 semanas de salário + queda de moral nos demais por uma semana — eles viram. Demitir com aviso: custo zero, mas o funcionário fica desmotivado nos dias finais e pode conversar com Arlindo. Funcionário recrutado pelo rival: cena de saída com diálogo — o jogo nunca deixa essa perda passar em silêncio.",
        },
      ],
    },
  },
  {
    id: "negociacao_salario",
    icon: "💼",
    label: "Salários",
    color: "#5a3480",
    bg: "#f0eafa",
    content: {
      title: "Negociação de Salário",
      subtitle: "Cada trabalhador tem um preço — e uma opinião sobre o que vale",
      tagline: '"Kinha sabe quanto ela vale. A questão é quando o jogador vai saber também."',
      pillars: [
        {
          icon: "💬",
          name: "Como funciona a negociação",
          desc: "A cada 4 semanas de jogo, cada funcionário pode solicitar revisão salarial — aparece como diálogo opcional, não como demanda agressiva. O jogador pode aumentar (qualquer valor), manter ou reduzir. Manter quando o salário já está abaixo do mercado: lealdade cai 5 pontos. Reduzir: cena de reação proporcional ao personagem — Marina faz uma pergunta calmamente; Kinha não faz pergunta nenhuma e o jogo registra o silêncio.",
        },
        {
          icon: "📊",
          name: "Referência de mercado",
          desc: "Dona Cida mantém uma tabela de mercado regional consultável sob demanda — nunca exibida automaticamente. Cada função tem uma faixa por fase (ex: operador de guindaste: R$ 160–220/semana na Fase 2). Pagar abaixo: risco de proposta de Arlindo. Pagar acima: lealdade sobe, moral sobe, e o funcionário para de atender os telefonemas do rival.",
        },
        {
          icon: "⚡",
          name: "Efeito no sistema de moral e lealdade",
          desc: "Salário é o fator de maior impacto estável sobre lealdade — supera elogios pontuais e eventos especiais. Um funcionário com salário justo absorve uma decisão ruim do jogador sem queda de lealdade. Um mal pago abandona o porto no momento mais inconveniente — durante um contrato de alto valor, geralmente. O jogo não avisa quando o abandono está próximo.",
        },
        {
          icon: "🎯",
          name: "Negociações que definem personagens",
          desc: "Kinha — quando o jogador finalmente paga o que ela vale, ela não agradece: 'Era o que deveria ser.' Se o jogador pagar mais do que ela pediu: ela olha os documentos e pergunta 'Tem um erro aqui?' Carol — se lealdade abaixo de 35 e revisão ignorada por 2 semanas, ela pede demissão levando o conhecimento dos contratos. Toninho — nunca pede aumento. Se o jogador oferecer espontaneamente, ele fica quieto um momento: 'Seu Maneco pagava assim também. No final.'",
        },
      ],
    },
  },
  {
    id: "arco",
    icon: "📖",
    label: "Arco Narrativo",
    color: "#4a1a6b",
    bg: "#f0e8f8",
    content: {
      title: "Arco Narrativo Central",
      subtitle: "Campanha com alma de sandbox",
      tagline: '"Estrutura narrativa definida. Sem cronômetro constante pressionando o jogador."',
      pillars: [
        {
          icon: "1️⃣",
          name: "Ato 1 — Sobreviver",
          desc: "O jogador herda o cais endividado, aprende os sistemas e paga as três parcelas ao banco. O conflito é doméstico. A cidade ainda não sabe se o herdeiro vai ou não conseguir.",
        },
        {
          icon: "2️⃣",
          name: "Ato 2 — Resistir",
          desc: "O porto cresce e o Grupo Atlântico intensifica a presença. Arlindo começa a perder contratos e se alia ao Abutre por interesse próprio. O conflito vira político. A Bela publica sua investigação mais importante aqui.",
        },
        {
          icon: "3️⃣",
          name: "Ato 3 — Decidir",
          desc: "O Abutre faz oferta formal de compra em sessão pública na câmara municipal. O jogador decide o destino do Cais Mirim — e a decisão é irrevogável.",
        },
        {
          icon: "🏁",
          name: "Cinco finais possíveis",
          desc: "Vender ao Grupo Atlântico e encerrar a história da família no mar (Final D). Manter o porto independente com apoio da comunidade — defesa do mangue e vínculos altos (Final B). Aliar-se a Arlindo e unificar os dois cais sob o nome do avô, quando ambos percebem que o Atlântico absorveria os dois (Final A — Porto Unificado). Sobreviver pagando a dívida mas sem deixar marca — cidade igual ao início (Final C). Ou o final secreto, que só o jogador que perseguir o segredo da carga sem nota até o fim pode encontrar (Final E)."
        },
        {
          icon: "⏱️",
          name: "Duração estimada",
          desc: "15 a 25 horas dependendo do envolvimento com conteúdo lateral. Fora do arco principal, o jogador explora Porto Mirim no próprio ritmo — missões secundárias, segredos, vínculos.",
        },
      ],
    },
  },
  {
    id: "diario_porto",
    icon: "📔",
    label: "Diário do Porto",
    color: "#4a1a6b",
    bg: "#f0e8f8",
    content: {
      title: "Diário do Porto",
      subtitle: "Centro emocional — onde o porto ganha memória",
      tagline: '"Não é tela de stats. É como o jogador vai lembrar deste jogo daqui a um ano."',
      pillars: [
        {
          icon: "📖",
          name: "Estrutura do diário",
          desc: "Organizado em três camadas: linha do tempo (entradas automáticas e manuais em ordem cronológica), capítulos (uma página por ato narrativo concluído) e arquivo (busca por NPC, por carga, por evento). A interface lembra um caderno de capa de couro envelhecido — não um app. Folheável página por página. Funciona offline integralmente — é o único sistema do jogo que pode ser revisitado sem progredir a campanha.",
        },
        {
          icon: "✍️",
          name: "Entradas automáticas",
          desc: "Geradas em marcos: primeiro contrato fechado, primeiro funcionário contratado, primeira parcela paga, conclusão de fase, eventos sazonais, conclusão de hobby, viagem a evento do setor, visita importante em casa, descoberta de segredo. Cada entrada tem data in-game, ícone temático, uma a três linhas de texto na voz do protagonista, e quando aplicável uma polaroid anexa.",
        },
        {
          icon: "📝",
          name: "Página de reflexão — texto livre opcional",
          desc: "Em momentos específicos (final de mês, conclusão de capítulo, evento marcante), o jogo abre uma página em branco e oferece ao jogador escrever uma reflexão livre. Sem limite mínimo. Pular não tem consequência. Quem escreve constrói um diário pessoal único que o próprio jogador relê meses depois. NPCs nunca leem o que o jogador escreveu — é privado mesmo dentro do jogo.",
        },
        {
          icon: "💬",
          name: "Frase da semana — citações de NPCs",
          desc: "Toda semana, uma fala real dita por algum NPC durante aquele período é destacada como 'frase da semana' no diário — selecionada pelo jogo conforme o impacto narrativo. Dona Cida em semana ruim, Toninho num momento de afeto, Zezão num raro instante reflexivo. Cria álbum de citações ao longo da campanha. Um dos prazeres do final do jogo é folhear isso de trás pra frente.",
        },
        {
          icon: "🎞️",
          name: "Cápsulas do tempo de cada fase",
          desc: "Ao completar cada fase, o Diário fecha um capítulo com cápsula: foto do porto no momento, lista dos NPCs ativos, estado financeiro resumido em duas linhas, contrato mais memorável, e a citação mais impactante. Comparar a cápsula da Fase 1 com a Fase 4 é um dos momentos mais emocionantes do final do jogo.",
        },
        {
          icon: "🔍",
          name: "Por que é o centro emocional",
          desc: "Em jogos de gestão, o jogador termina a campanha com nada além de números finais. Aqui termina com um livro — literalmente folheável — contando a história do porto dele, com a voz dele, as escolhas dele e as pessoas que ficaram. Isso é o que mantém o jogo lembrado depois de meses. Não é feature lateral — é o produto final invisível.",
        },
      ],
    },
  },
  {
    id: "fotografias",
    icon: "📷",
    label: "Fotografias",
    color: "#4a1a6b",
    bg: "#f0e8f8",
    content: {
      title: "Sistema de Fotografias — Polaroid",
      subtitle: "O porto que você lembra é o porto que você fotografou",
      tagline: '"Cada foto é uma carta para o jogador que vai folhear o diário daqui a seis meses."',
      pillars: [
        {
          icon: "📸",
          name: "Quando tirar foto",
          desc: "Botão de câmera disponível em qualquer momento entre turnos. Foto registra automaticamente: data in-game, local exato no mapa, NPCs presentes, roupa atual do protagonista, carro estacionado (se houver), clima e período do dia. Sem limite de fotos — Toninho comenta se o jogador 'só tira foto e não trabalha', mas é só piada.",
        },
        {
          icon: "🎁",
          name: "Polaroids automáticas",
          desc: "O jogo tira polaroids em marcos automáticos: primeiro barco docado, conclusão de fase, vitória em concurso de pesca, dia do aniversário do protagonista, casa após cada reforma, primeira viagem em cada região. Essas fotos não podem ser deletadas — são parte do registro narrativo.",
        },
        {
          icon: "📰",
          name: "Fotos para a Bela",
          desc: "Em arcos específicos, Bela pede uma foto para acompanhar matéria — da reforma do porto, do evento de filantropia, da chegada de carga importante. Foto bem composta (com NPCs e contexto certo) gera matéria mais positiva. Foto ruim ou genérica: matéria sai morna. Ela não explica — só publica o que recebeu.",
        },
        {
          icon: "🖼️",
          name: "Galeria na casa",
          desc: "Fotos podem ser emolduradas e penduradas na casa do protagonista. NPCs visitantes reagem ao que veem: 'Essa foto é da Festa de São Pedro de 2027? Eu tava lá.' Algumas fotos especiais geram diálogo extra com o NPC fotografado quando ele revisita a casa. A galeria visual evolui com a campanha sem necessidade de menu separado.",
        },
        {
          icon: "👤",
          name: "Você na roupa daquele momento",
          desc: "Cada foto preserva a aparência exata do protagonista no instante — roupa, cabelo, qualquer mudança visual. Folhear o álbum mostra a evolução estética junto com a do porto. Quem mudou de visual três vezes durante a campanha vê os três visuais documentados. A personalização ganha permanência mecânica via fotografia.",
        },
      ],
    },
  },
  {
    id: "atos",
    icon: "🎬",
    label: "3 Atos",
    color: "#1a3a6b",
    bg: "#e6eef8",
    content: {
      title: "Estrutura Detalhada — Os 3 Atos",
      subtitle: "Duração, gatilhos e critérios de transição",
      tagline: '"Cada ato tem uma pergunta central. O jogo termina quando as três são respondidas."',
      pillars: [
        {
          icon: "1️⃣",
          name: "Ato 1 — Semanas 1 a 4 · «Consegue sobreviver?»",
          desc: "O protagonista herda o cais sem querer. A dívida existe. Os rivais mal percebem. O objetivo é sobreviver até a primeira parcela sem perder o porto. O jogador conhece todos os NPCs principais, descobre as três fontes de renda e paga R$ 8.000 ao Sr. Ribeiro. Gatilho de fim: parcela paga + pelo menos uma estrutura nova construída. Arlindo faz o primeiro movimento silencioso ao final — o jogador não percebe ainda.",
        },
        {
          icon: "2️⃣",
          name: "Ato 2 — Semanas 5 a 9 · «Que porto você está construindo?»",
          desc: "O porto tem identidade própria. As escolhas do jogador começam a ter peso acumulado. Arlindo intensifica pressão. O Grupo Atlântico aparece pela primeira vez — Dra. Patrícia entrega documentos formais. A parcela do meio (R$ 16.000) é o ponto dramático central. Os quatro segredos estão disponíveis para descoberta — três deles (avô, Arlindo, mangue) por gatilho narrativo natural, e o quarto (carga sem nota) somente se o jogador aceitou pelo menos uma carga ilegal antes. Gatilho de fim: parcela paga + contato com pelo menos um dos segredos. O Abutre aparece pessoalmente na última semana.",
        },
        {
          icon: "3️⃣",
          name: "Ato 3 — Semanas 10 a 12 · «Que cidade você quer deixar?»",
          desc: "Todas as consequências chegam juntas. A última parcela (R$ 24.000) e a proposta de compra do Abutre chegam na mesma semana. As alianças construídas — ou destruídas — determinam quais finais estão disponíveis. Os quatro segredos chegam ao ponto de virada: o segredo do avô amarra a motivação do protagonista, o arco do mangue define a relação com a cidade, o segredo de Arlindo abre o Final A, o contato sem nome abre o Final E. Não há tempo para recuperar o que não foi construído.",
        },
        {
          icon: "🔑",
          name: "Transições — critérios duplos",
          desc: "Cada transição exige critério temporal (semana mínima atingida) E critério narrativo (evento específico ocorrido). Não é possível avançar pagando a parcela antes da semana mínima — o jogo estabiliza o ritmo. Também não é possível ficar preso no Ato 1: se a parcela continuar não paga após 3 semanas de atraso (sistema completo de Dívidas, ver seção própria), o Abutre intervém e o jogo entra numa versão acelerada do Ato 2 em modo de crise. Antes desse ponto, a pressão é apenas do Sr. Ribeiro e da penhora do píer."
        },
      ],
    },
  },
  {
    id: "finais",
    icon: "🏁",
    label: "Finais",
    color: "#2a4a1a",
    bg: "#eaf0e8",
    content: {
      title: "Finais Possíveis",
      subtitle: "5 desfechos — nenhum é o canônico",
      tagline: '"O jogo não revela quantos finais existem. O jogador descobre jogando."',
      pillars: [
        {
          icon: "🤝",
          name: "Final A — Porto Unificado",
          desc: "Condições: aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Arlindo, sabendo que o Abutre o absorveria depois, une o Porto Farol ao Cais Mirim numa operação conjunta. O Grupo Atlântico recua. Epílogo: cena de Seu Biu na ponta do cais ao amanhecer. Ele não diz nada. Não precisa.",
        },
        {
          icon: "🌿",
          name: "Final B — Porto da Cidade",
          desc: "Condições: mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Cais Mirim permanece independente. A câmara municipal vota contra o resort. Toninho conta o segredo do avô numa cena noturna no galpão. Epílogo: o jogador vê a cidade cinco anos depois — os pescadores do píer ainda estão lá.",
        },
        {
          icon: "💼",
          name: "Final C — Sobrevivência Pura",
          desc: "Condições: terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. O cais sobrevive. O protagonista honrou a dívida. Mas Porto Mirim ficou igual. Epílogo: sem cena especial. O jogo mostra o cais em dia normal de operação. Toninho varrendo o píer. Isso é tudo.",
        },
        {
          icon: "⚠️",
          name: "Final D — Venda ao Grupo Atlântico",
          desc: "Condições: aceitar a proposta do Abutre no Ato 3 (disponível quando dívida alta + sem aliança comunitária). O Cais Mirim vira terminal do Grupo Atlântico. Pescadores perdem as vagas. Toninho não aparece na cena final. Bela publica — o jogador lê a manchete como epílogo. Dona Cida deixa o porto no dia seguinte à venda.",
        },
        {
          icon: "🔒",
          name: "Final E — O Custo do Conhecimento (secreto)",
          desc: "Condições (todas obrigatórias): seguir o fio da carga sem nota até o fim + revelar o contato interno do Grupo Atlântico para o Abutre em pessoa + reputação comunitária abaixo de 40. O Abutre usa a informação para purgar o contato interno e faz oferta melhorada. O jogador ganhou poder de negociação mas perdeu a cidade. Sem música na cena final.",
        },
      ],
    },
  },
  {
    id: "missoes",
    icon: "⏳",
    label: "Missões",
    color: "#6b4a1a",
    bg: "#f8f0e8",
    content: {
      title: "Missões e Escolhas Irrevogáveis",
      subtitle: "O jogador sabe que é importante — não sabe a consequência",
      tagline: '"Chefia, essa decisão não tem volta." — Dona Cida, nos momentos certos',
      pillars: [
        {
          icon: "📋",
          name: "Três tipos de missão",
          desc: "Missões comuns: sem prazo rígido, o jogador faz quando quiser. Missões sazonais: têm janela de oportunidade — a Festa de São Pedro só acontece em junho. Missões críticas: raras, com prazo real e consequência permanente se ignoradas.",
        },
        {
          icon: "👩‍💼",
          name: "Carol e a proposta de Arlindo — semana 6",
          desc: "Arlindo aborda Carol com oferta de emprego. O jogador tem 3 dias para agir: aumentar o salário, conversar ou ignorar. Se ignorar, ela aceita e vai embora levando o conhecimento dos contratos. Não volta.",
        },
        {
          icon: "📦",
          name: "A carga noturna — semana 9",
          desc: "Um barco com carga suspeita pede docagem urgente na madrugada. Aceitar ou recusar define se o canal ilegal se estabelece. A janela fecha antes do amanhecer.",
        },
        {
          icon: "🏛️",
          name: "A sessão da câmara — ato 3",
          desc: "A decisão sobre a oferta do Abutre é feita em público. Não há como voltar atrás depois de falar na câmara. É o único momento em que toda a cidade assiste ao protagonista escolher.",
        },
      ],
    },
  },
  {
    id: "imprensa",
    icon: "📰",
    label: "Imprensa",
    color: "#1a5a6b",
    bg: "#e8f4f8",
    content: {
      title: "Bela e o Sistema de Reputação",
      subtitle: "Um espelho que o jogador não controla completamente",
      tagline: '"Ela nunca é comprada. A cena de rejeição é uma das mais bem escritas do jogo."',
      pillars: [
        {
          icon: "📝",
          name: "Como as matérias funcionam",
          desc: "Bela publica toda semana — uma matéria jornalística completa que sai na sexta. É diferente do Boletim do Porto (resumo automático de 3 itens que aparece na abertura de cada turno, mostrando o que aconteceu no dia anterior no porto). O Boletim cobre operação imediata (navio chegado, ação rival, prazo); a matéria da Bela cobre análise semanal e investigação. O tom da matéria depende do que o jogador fez, do que ela descobriu por conta própria e da relação pessoal entre os dois. Matéria positiva traz clientes novos. Matéria negativa reduz contratos por duas semanas e dá munição para Arlindo.",
        },
        {
          icon: "🤝",
          name: "Cultivar a relação",
          desc: "O jogador pode dar informações, ser transparente e ajudar nas investigações dela. Quando a relação é boa, ela avisa antes de publicar algo delicado. Quando é ruim ou neutra, o jogador descobre a matéria junto com a cidade.",
        },
        {
          icon: "🔍",
          name: "Três investigações independentes da Bela",
          desc: "Bela conduz três investigações próprias ao longo da campanha — três dos quatro segredos do jogo (a origem do dinheiro do Grupo Atlântico cruza com o segredo do avô e o de Arlindo; a ligação de Arlindo com a prefeitura é o próprio segredo de Arlindo; os rumores sobre as dívidas reais do avô conectam ao segredo do avô). O quarto segredo — a carga sem nota — está fora do alcance dela: requer envolvimento direto do jogador para ser revelado e ela nunca chega lá sozinha. Boa relação com Bela transforma as três investigações em armas narrativas. Relação ruim: ela pode investigar o porto do protagonista também.",
        },
        {
          icon: "🚫",
          name: "O que ela nunca faz",
          desc: "Ser comprada. O jogador pode tentar — ela rejeita. Essa cena existe e vale cada linha de diálogo.",
        },
      ],
    },
  },
  {
    id: "bela_gatilhos",
    icon: "📰",
    label: "Gatilhos da Bela",
    color: "#1a5a6b",
    bg: "#e8f4f8",
    content: {
      title: "Consistência dos Gatilhos — Bela",
      subtitle: "Quando ela avisa, quando publica, quando investiga",
      tagline: '"A Bela não é previsível. Mas tem regras. Você descobre as regras antes de ela te pegar de surpresa."',
      pillars: [
        {
          icon: "📢",
          name: "Quando ela avisa antes de publicar",
          desc: "Condição: reputação com Bela acima de 65. O aviso chega como diálogo 48h de jogo antes da publicação. O conteúdo é vago ('tem uma matéria sobre o cais saindo na sexta'). Acima de 80: o aviso é mais específico ('é sobre a carga de outubro — você quer comentar?'). Abaixo de 65: o jogador descobre junto com a cidade.",
        },
        {
          icon: "🔍",
          name: "Quando ela investiga o próprio jogador",
          desc: "Gatilho: reputação com Bela abaixo de 40 E pelo menos um dos seguintes: carga sem nota aceita mais de duas vezes, traição de aliança testemunhada por NPC, corrupção com prefeitura aceita. A investigação dura 2 semanas antes de publicar. Durante esse período ela faz uma pergunta direta — resposta honesta interrompe a investigação mas custa 10 pontos de reputação. Resposta evasiva: matéria sai com 20% mais impacto.",
        },
        {
          icon: "📅",
          name: "Frequência e timing das matérias",
          desc: "Publicação toda semana de jogo, sempre na sexta. Ato 1: maioria das matérias são sobre a cidade — o porto só aparece se algo notável ocorreu. Ato 2: porto aparece toda semana, positivo ou negativo. Ato 3: as três investigações independentes convergem. Sem matéria em semana de evento especial (Carnaval, Festa de São Pedro) — a cobertura do evento substitui.",
        },
        {
          icon: "💡",
          name: "Informação antecipada sobre rivais",
          desc: "Condição: reputação com Bela acima de 70. Ela avisa sobre bloqueio de fornecedor do Grupo Atlântico em 60% das ocorrências (não 100% — ela não é onisciente). Avisa sobre lobby de Arlindo na prefeitura em 40% das vezes. O aviso chega como nota no jornal ou diálogo direto. Abaixo de 70: o jogador descobre o bloqueio quando o fornecedor já fechou com o Atlântico.",
        },
      ],
    },
  },
  {
    id: "reputacao",
    icon: "⭐",
    label: "Reputação",
    color: "#6b5a1a",
    bg: "#f8f4e8",
    content: {
      title: "Sistema de Reputação",
      subtitle: "Três eixos independentes — uma leitura integrada",
      tagline: '"Reputação não é uma barra. É o que a cidade fala de você quando você não está na sala."',
      pillars: [
        {
          icon: "📊",
          name: "Escala e exibição ao jogador",
          desc: "Cada eixo vai de 0 a 100. Exibido como descrição qualitativa, não número: 0–20 = 'Desconhecido', 21–40 = 'Questionável', 41–60 = 'Confiável', 61–80 = 'Respeitado', 81–100 = 'Referência'. O número interno existe para cálculos — o jogador lê palavras, não pontos. A mudança de faixa é anunciada por uma linha de Dona Cida ou Seu Biu.",
        },
        {
          icon: "⚡",
          name: "Feedback visual imediato — decisão fechada na Fase 1 do roadmap",
          desc: "A barra de reputação em texto puro não foi intuitiva o suficiente para jogadores novos no V3. Decisão fechada para o VS: combinação de dois sinais. (1) Cor pulsante no indicador — animação curta ao mudar de faixa, sinal de baixa latência de que algo aconteceu. (2) Ícone de reação do NPC adjacente — micro-sprite expressivo (Dona Cida no VS) que ancora a mudança em quem reagiu, carregando a identidade narrativa do jogo. A linha de texto contextual fica deferida para a produção full, após o sistema base provar que comunica a intuição. O número interno não muda — só a camada de comunicação visual para o jogador.",
        },
        {
          icon: "⚓",
          name: "Eixo 1 — Reputação Comercial",
          desc: "Afeta quais contratos chegam e a que preço. Acima de 60: clientes de frete regional aparecem. Acima de 80: contratos exclusivos de longa duração disponíveis. Abaixo de 30: só contratos de baixo valor chegam, Arlindo intercepta os bons. Aumenta com: contratos cumpridos no prazo, estrutura bem mantida, zero reclamações. Diminui com: atrasos, reclamações públicas, carga avariada, boatos amplificados por Arlindo.",
        },
        {
          icon: "🏘️",
          name: "Eixo 2 — Reputação Comunitária",
          desc: "Afeta alianças, festividades e finais disponíveis. Acima de 70: vaquinha da crise possível, câmara municipal ouve o jogador no Ato 3. Acima de 85: pescadores defendem o porto ativamente. Abaixo de 40: Final E disponível, Final B bloqueado. Aumenta com: aluguel justo, presença na Festa de São Pedro, defesa do mangue. Diminui com: despejo de pescador, corrupção descoberta.",
        },
        {
          icon: "📰",
          name: "Eixo 3 — Reputação com a Imprensa (Bela)",
          desc: "Afeta cobertura semanal e acesso antecipado a informação. Acima de 65: Bela avisa antes de publicar algo delicado. Acima de 80: compartilha pistas das investigações independentes. Abaixo de 40: ela investiga o porto do protagonista. Abaixo de 20: matéria negativa garantida toda semana. Mentira descoberta reseta 30 pontos de uma vez.",
        },
        {
          icon: "⚡",
          name: "Interação entre os eixos",
          desc: "Reputação com Bela alta + matéria positiva = +5 na comercial por duas semanas. Reputação comunitária abaixo de 35 = Arlindo recruta funcionários com mais facilidade. Reputação comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida.",
        },
      ],
    },
  },
  {
    id: "vinculos",
    icon: "❤️",
    label: "Vínculos",
    color: "#6b1a3a",
    bg: "#f8e8f0",
    content: {
      title: "Vínculos com NPCs",
      subtitle: "Não chama de romance — chama de vínculo",
      tagline: '"NPCs com vínculo alto tomam decisões favoráveis ao jogador em momentos que ele não está presente."',
      pillars: [
        {
          icon: "📰",
          name: "Bela — vínculo de tensão",
          desc: "A relação oscila entre aliada e adversária. Se o jogador investir consistentemente, há uma cena no final do ato 2 em que ela escolhe proteger o porto mesmo contra o interesse jornalístico dela. É o momento mais emotivo do arco dela.",
        },
        {
          icon: "⚓",
          name: "Toninho — vínculo de herança",
          desc: "A lealdade ao avô transferida para o jogador tem peso afetivo genuíno. Há uma missão opcional em que Toninho conta o que realmente aconteceu nos últimos meses de vida do Seu Maneco — algo que ninguém mais sabe.",
        },
        {
          icon: "💡",
          name: "Como os vínculos agem mecanicamente",
          desc: "NPCs com vínculo alto tomam decisões favoráveis ao jogador em momentos que ele não está presente: uma negociação, uma informação retida, uma noite extra de vigilância. Nunca é exibido como bônus. Acontece como parte da narrativa.",
        },
        {
          icon: "🚫",
          name: "O que não entra",
          desc: "Sistema de pontos de afeição visível. Presentes com efeito mecânico direto. Qualquer estrutura que reduza o relacionamento a uma barra de progresso.",
        },
      ],
    },
  },
  {
    id: "pets_porto",
    icon: "🐈",
    label: "Pets do Porto",
    color: "#6b1a3a",
    bg: "#f8e8f0",
    content: {
      title: "Os Bichos do Cais",
      subtitle: "Os habitantes que estavam aqui antes de você",
      tagline: '"Esse gato é do Seu Maneco. Ele só não sabe que o velho morreu. Não me cabe contar." — Toninho',
      pillars: [
        {
          icon: "🐈",
          name: "Gato do Galpão (Manequinho)",
          desc: "Já estava no porto quando o jogador chega. Branco e cinza, uma orelha mordida. Toninho cuida dele em silêncio desde a morte do avô. Aparece nos cantos do porto em horários previsíveis, dorme em cima de pilhas de corda, ignora estranhos. Acostuma com o jogador lentamente — primeiro encontro: foge. Depois de 4 semanas vendo o jogador todo dia, deixa ser tocado. Depois de 8 semanas, dorme no escritório do protagonista. Toninho nota a transição em silêncio e isso é um dos momentos mais delicados do early game.",
        },
        {
          icon: "🐕",
          name: "Cachorro de rua (opcional)",
          desc: "Aparece em fase 2 — vira-lata que começa a frequentar o cais. O jogador escolhe se alimenta, ignora ou expulsa. Alimentar duas vezes fixa o cachorro como morador do porto — sem custo, sem missão. Em compensação, presença narrativa: pescadores acariciam, cargas de bebida ele guarda contra ladrão, Bela tira foto dele numa matéria sobre o cais. Nome dado pelos funcionários após acolhido. Zezão vai chamar de algum nome incompatível com a aparência do cachorro.",
        },
        {
          icon: "🐦",
          name: "Pelicano (Pelegrino)",
          desc: "Aparece quando há carga de peixe — gosta dos restos. Nunca interage, nunca é tocável. Tem nome dado pelos pescadores antes do jogador chegar. Some por meses e volta. Vira marcador visual de saudade quando reaparece após muito tempo. Seu Biu cumprimenta o pelicano em voz baixa quando o vê.",
        },
        {
          icon: "💔",
          name: "Eventos com pets",
          desc: "Pets podem adoecer — diálogo discreto pedindo veterinário (custo variável). O gato pode sumir por uma semana e voltar sozinho — geração de tensão sem aviso. O cachorro pode ter cria com uma cadela do bairro: filhotes aparecem no porto e o jogador decide se fica com algum. Morte de pet (eventualmente, no late game): cena curta sem música. Toninho aparece. Os dois ficam parados. O jogo não acrescenta nada — só registra a entrada no diário.",
        },
        {
          icon: "🏠",
          name: "Pets na casa do protagonista",
          desc: "Gato pode escolher acompanhar o jogador para casa após vínculo alto. Cachorro idem. A casa adquire vida — animação ambiente sutil, pet no sofá, comida na cozinha. NPCs visitantes reagem aos pets de forma característica: Bela passa mal com gato (alérgica), Marina ama, Dona Cida diz 'pelo menos esse aí come o que falta'. Ter pet em casa gera bônus pequeno e permanente de moral do jogador.",
        },
      ],
    },
  },
  {
    id: "segredos",
    icon: "🔒",
    label: "Segredos",
    color: "#2a4a1a",
    bg: "#eaf0e8",
    content: {
      title: "Segredos de Porto Mirim",
      subtitle: "Quatro fios que o jogador pode — ou não — puxar",
      tagline: '"Descobrir o primeiro segredo muda o peso emocional de toda a campanha."',
      pillars: [
        {
          icon: "👴",
          name: "O segredo do avô",
          desc: "Seu Maneco recusou uma oferta do Grupo Atlântico vinte anos atrás. As dívidas atuais do porto são consequência direta dessa recusa, não de má gestão. Os documentos estão no galpão. Toninho sabe onde procurar.",
        },
        {
          icon: "🎭",
          name: "O segredo de Arlindo",
          desc: "O Porto Farol foi construído com dinheiro de origem incerta. Arlindo tem uma dívida não financeira com o Grupo Atlântico — ele não é um rival livre, é um fantoche que ainda não sabe que é fantoche. Bela investiga isso.",
        },
        {
          icon: "🌿",
          name: "O mangue e o resort",
          desc: "A prefeitura quer lotear uma área do mangue próxima ao cais para um resort. O impacto ambiental destruiria a pesca artesanal. Os pescadores do píer sabem mas não falam por medo. Se o jogador descobrir e agir, vira um arco com Bela, a câmara municipal e uma decisão sobre que cidade ele quer construir.",
        },
        {
          icon: "📦",
          name: "O contato da carga sem nota",
          desc: "Se o jogador aceitou pelo menos uma carga ilegal e tiver paciência para seguir o fio ao longo de semanas, descobre que o contato noturno tem ligação com alguém dentro do Grupo Atlântico. O Abutre não sabe. Essa informação, usada no momento certo, pode mudar completamente a negociação do ato final.",
        },
      ],
    },
  },
  {
    id: "memorial_avo",
    icon: "🕯️",
    label: "Memorial do Avô",
    color: "#2a4a1a",
    bg: "#eaf0e8",
    content: {
      title: "Memorial do Seu Maneco",
      subtitle: "Reconstruir a figura do avô através da memória dos outros",
      tagline: '"Você herdou o cais. Mas o avô — esse, você precisa descobrir."',
      pillars: [
        {
          icon: "📜",
          name: "O arco invisível",
          desc: "Estende-se por toda a campanha. Não tem missão pop-up, não tem painel de progresso. Começa quando o jogador encontra a primeira carta do avô no galpão velho durante o tutorial. A partir dali, cada NPC com vínculo alto pode contribuir voluntariamente: uma história, um objeto, uma foto antiga, uma anedota. O arco se completa em ritmo próprio — alguns jogadores em uma campanha inteira só descobrem 60%.",
        },
        {
          icon: "🧓",
          name: "Quem contribui e o quê",
          desc: "Toninho — a história real dos últimos meses do avô (já mencionado em vínculos, agora ancorado aqui). Seu Biu — como o avô e ele criaram o trato do píer gratuito. Dona Cida — a única vez que o avô chorou no escritório. Sr. Ribeiro — o empréstimo que o avô tomou em 1998 e quitou em 2003 sem nenhum atraso. Bela — o que ela descobriu sobre a recusa de venda ao Grupo Atlântico há 20 anos. NPC surpresa — alguém que o jogador conheceu casualmente no Bar do Mané revela ter sido funcionário do avô.",
        },
        {
          icon: "🏗️",
          name: "Construção física do memorial",
          desc: "Em fase 3 ou 4, o jogador pode construir o Memorial no canto noroeste do porto — onde ficava o cais original do avô. Custa material reciclado do píer velho + decoração escolhida. Cada item descoberto vira parte do memorial: foto, lema do avô, objeto pessoal. Quanto mais peças descobertas antes da construção, mais rico o memorial. Construir adiciona +15 pontos permanentes de reputação comunitária — a cidade nota.",
        },
        {
          icon: "🎬",
          name: "Cenas curtas a cada descoberta",
          desc: "Cada peça nova do memorial gera cutscene de 10–20 segundos: flashback em Flat Design com paleta sépia/dessaturada, voz do NPC narrando, sem música ou com a versão lenta do leitmotif em viola caipira (já definido no sistema sonoro). Cada cutscene termina com entrada nova no Diário do Porto.",
        },
        {
          icon: "🔗",
          name: "Conexão com o Final B",
          desc: "Memorial completo (todas as peças descobertas + construção física) desbloqueia variação especial do Final B (Porto da Cidade). Em vez do epílogo padrão (cidade cinco anos depois), o jogador tem uma cena adicional em frente ao Memorial: conversa com Toninho, ele entrega um único objeto guardado por 20 anos, o ciclo se fecha. Sem revelação dramática — só uma conversa entre dois homens que amaram o mesmo velho. Não é um final separado: é uma camada emocional adicional ao Final B. O Memorial não afeta os Finais A, C, D ou E.",
        },
      ],
    },
  },
  {
    id: "agendas",
    icon: "🎯",
    label: "Agendas Rivais",
    color: "#6b1a1a",
    bg: "#f8eaea",
    content: {
      title: "Arlindo vs Abutre — Agendas Independentes",
      subtitle: "Aliados provisórios, rivais latentes",
      tagline: '"Arlindo acha que é uma aliança entre iguais. Não é."',
      pillars: [
        {
          icon: "🎭",
          name: "Objetivos distintos",
          desc: "Arlindo quer dominar Porto Mirim. O Abutre quer Porto Mirim inteira — incluindo o Porto Farol. Os dois têm interesses momentaneamente alinhados contra o jogador, mas são rivais latentes um do outro.",
        },
        {
          icon: "1️⃣",
          name: "Ato 1 — Indiferença",
          desc: "Os dois ignoram o jogador. Ele é pequeno demais para importar.",
        },
        {
          icon: "2️⃣",
          name: "Ato 2 — Falsa aliança",
          desc: "Arlindo percebe que está perdendo contratos e aceita apoio financeiro do Grupo Atlântico para pressionar o protagonista. Ele acha que é uma parceria entre iguais. O Abutre sabe que não é.",
        },
        {
          icon: "3️⃣",
          name: "Ato 3 — A revelação possível",
          desc: "Se o jogador descobriu o segredo de Arlindo, pode mostrar a ele que o Abutre planeja absorver o Porto Farol depois de eliminar o Cais Mirim. Arlindo pode virar aliado improvável — ou pode não acreditar e continuar do lado errado. A colisão entre os dois antagonistas é recompensa para quem prestou atenção, não obrigação narrativa.",
        },
      ],
    },
  },
  {
    id: "aliancas",
    icon: "🤝",
    label: "Alianças",
    color: "#1a4a6b",
    bg: "#e8f0f8",
    content: {
      title: "Alianças e Traições",
      subtitle: "Três tipos de aliança, cada uma com custo diferente",
      tagline: '"A cidade é pequena. Todo mundo sabe. Dona Cida não perdoa duplicidade."',
      pillars: [
        {
          icon: "🏘️",
          name: "Aliança com a comunidade",
          desc: "Construída devagar através de decisões cotidianas: aluguel justo, presença na Festa de São Pedro, defesa do mangue. Não tem evento único que a estabelece. Quando sólida, a vaquinha da crise é possível e a câmara ouve o jogador no ato final.",
        },
        {
          icon: "📰",
          name: "Aliança com a Bela",
          desc: "Exige honestidade consistente ao longo de toda a campanha. Uma mentira descoberta reseta o nível de confiança — não existe recuperação rápida. O custo é o mais alto em termos de disciplina do jogador.",
        },
        {
          icon: "⚓",
          name: "Aliança com Arlindo — a mais cara",
          desc: "Requer descobrir o segredo do financiamento do Porto Farol, ter construído relação suficiente com Arlindo mesmo sendo rivais, e escolher compartilhar a informação no momento certo. Arlindo pode recusar. Se aceitar, o final de unificação dos dois cais se torna disponível.",
        },
        {
          icon: "⚡",
          name: "Custo de trair",
          desc: "Trair uma aliança tem custo permanente com todos os NPCs que testemunharam ou descobriram. Dona Cida não perdoa segundo plano com duplicidade. Bela publica. Toninho fica quieto de um jeito que pesa mais do que qualquer discurso.",
        },
      ],
    },
  },
  {
    id: "atlantico",
    icon: "🏢",
    label: "Grupo Atlântico",
    color: "#2a2a6b",
    bg: "#eaeaf8",
    content: {
      title: "Rostos do Grupo Atlântico",
      subtitle: "Três personagens além do Abutre",
      tagline: '"O Abutre nem sabe o nome do Marcos. Isso diz tudo sobre como o grupo funciona."',
      npcs: [
        {
          name: "Dra. Patrícia Leal",
          role: "Advogada do grupo",
          personality: "Aparece antes do Abutre — entrega os primeiros documentos formais. Eficiente, impessoal, lê o porto como ativo e o jogador como obstáculo temporário. Em cena opcional no ato 2, o jogador pode descobrir que ela cresceu numa cidade costeira absorvida por um conglomerado. Ela nunca comenta isso diretamente.",
          humor: '"Os documentos estão em ordem. O senhor tem 30 dias para responder." — Dra. Patrícia',
        },
        {
          name: "Marcos",
          role: "Gerente de operações regional",
          personality: "Jovem, ambicioso, trata Arlindo com condescendência velada. Processa os contratos exclusivos que cortam os fornecedores do jogador. Não é um vilão — é alguém fazendo o trabalho sem pensar no que está por baixo.",
          humor: '"É procedimento padrão. Não é pessoal." — Marcos',
        },
        {
          name: "O contato sem nome",
          role: "Ligação interna — identidade revelada no ato 3",
          personality: "Só identificado se o jogador seguiu o fio da carga sem nota. Quando a identidade é revelada, não há música dramática — é uma cena curta com alguém que o jogador já viu antes sem dar importância. O peso vem do reconhecimento, não da revelação.",
          humor: '"Você demorou mais do que eu esperava pra chegar aqui." — O contato',
        },
      ],
    },
  },
  {
    id: "mecanicas_rivais",
    icon: "⚙️",
    label: "Mecânicas Rivais",
    color: "#5a1a6b",
    bg: "#f4eaf8",
    content: {
      title: "Ações Ativas dos Rivais",
      subtitle: "Escalam com o tamanho do porto do jogador",
      tagline: '"No early game, Arlindo mal repara no protagonista. No ato 3, os dois rivais estão em modo ativo."',
      pillars: [
        {
          icon: "🎭",
          name: "Arlindo — 4 ações recorrentes",
          desc: "Dumping de preço: oferece 15% abaixo ao cliente que o jogador acabou de fechar, se a relação ainda for fraca. Recrutamento: aborda funcionário com moral abaixo de 35% por duas semanas seguidas. Lobby na prefeitura: uma vez por mês cria um obstáculo burocrático — licença atrasada, vistoria surpresa, restrição de horário. Amplificação de boato: se o jogador cometeu erro público recente, Arlindo amplifica a queda de reputação.",
        },
        {
          icon: "🏢",
          name: "Grupo Atlântico — 2 ações principais",
          desc: "Bloqueio de fornecedor: a cada dois meses, um fornecedor recebe oferta de exclusividade do Atlântico. O jogador pode contra-oferecer se souber a tempo — a Bela às vezes avisa antes. Pressão financeira indireta: quando o jogador está com dívida alta, o Atlântico circula informação sobre a instabilidade do cais para clientes potenciais. Contratos que estavam prestes a chegar somem sem explicação.",
        },
        {
          icon: "⚖️",
          name: "Princípio de equilíbrio",
          desc: "As ações dos rivais escalam com o tamanho do porto. No early game a pressão é quase imperceptível. No mid game começa a doer. No ato 3 é total. O jogo nunca pune o jogador pequeno com pressão que ele não consegue absorver.",
        },
      ],
    },
  },
  {
    id: "tempo",
    icon: "🕐",
    label: "Tempo",
    color: "#1a4a6b",
    bg: "#e8f0f8",
    content: {
      title: "Unidade de Tempo — Turnos Diários",
      subtitle: "Sem idle. Sem obrigação de abrir todo dia.",
      tagline: '"O jogador abre o jogo quando quer. Porto Mirim não pune quem tirou uma semana de folga."',
      pillars: [
        {
          icon: "📅",
          name: "Como funciona",
          desc: "Cada sessão avança o jogo em dias completos. O jogador toma as decisões do dia — contratos, funcionários, construção, conversas — e confirma o avanço. O jogo processa os resultados e apresenta o que aconteceu. Nada acontece com o app fechado.",
        },
        {
          icon: "⏱️",
          name: "Duração de sessão",
          desc: "Entre 10 e 20 minutos por sessão típica. O jogador vê o que aconteceu no dia anterior, toma as decisões do dia atual e fecha. Pode jogar todo dia ou uma vez por semana — o jogo não pune a segunda opção.",
        },
        {
          icon: "💡",
          name: "Por que não tempo real",
          desc: "Tempo real cria obrigação. O jogador que não abriu o app em dois dias volta para uma crise que não escolheu enfrentar. Isso vai contra o tom de Porto Mirim — uma cidade que convida, não que pressiona.",
        },
        {
          icon: "⚡",
          name: "De onde vem a tensão",
          desc: "Não do relógio do celular — mas das parcelas ao banco e dos prazos das missões críticas. Essa pressão é controlada pelo design, não pelo sistema operacional.",
        },
      ],
    },
  },
  {
    id: "contratos_ux",
    icon: "📋",
    label: "UX Contratos",
    color: "#2d6b1a",
    bg: "#eaf5e8",
    content: {
      title: "Interface de Negociação",
      subtitle: "Tela inteira em modo retrato sem scroll — requisito de design",
      tagline: '"Contrato que exige scroll vai ser ignorado por jogadores mobile."',
      pillars: [
        {
          icon: "👤",
          name: "Três elementos visíveis ao mesmo tempo",
          desc: "O cliente com seu rosto e uma linha de diálogo contextual. Os termos propostos. Duas ou três variáveis ajustáveis pelo jogador.",
        },
        {
          icon: "🎚️",
          name: "Variáveis ajustáveis",
          desc: "Sempre as mesmas: preço, prazo de entrega e uma condição especial que varia por contrato — prioridade de atendimento, seguro incluído, exclusividade de rota. O jogador desliza cada variável dentro de uma faixa possível.",
        },
        {
          icon: "😐",
          name: "Feedback visual, não numérico",
          desc: "Conforme o jogador ajusta, o rosto do cliente reage: satisfeito, neutro, resistente. Não há número de 'felicidade' visível. A leitura é intuitiva — como ler uma pessoa numa conversa.",
        },
        {
          icon: "⏳",
          name: "Deixar em aberto",
          desc: "O contrato pode ser aceito, recusado ou deixado em aberto por 24 horas de jogo. Deixar em aberto é uma estratégia: às vezes o cliente volta com condições melhores. Às vezes vai ao Porto Farol.",
        },
        {
          icon: "🔄",
          name: "Limiar de paciência do cliente — decisão fechada na Fase 1 do roadmap",
          desc: "Em vez do rival simplesmente dumpar preço sem resposta, o jogador pode contra-negociar. Versão simplificada do VS: (1) Input da contra-oferta — 3 presets em botões (ex: 'Igualar rival −15%' / 'Cortar metade −7%' / 'Manter preço'), sem slider e sem input numérico — a granularidade fina é decisão de produção full. (2) Limiar de paciência — máximo 2 tentativas antes de o cliente encerrar a conversa e ir ao Porto Farol, visualizado por uma mood face do cliente com 3 estados discretos: 2 tentativas restantes = neutro, 1 restante = preocupado, 0 = saindo. O VS testa se essa dinâmica é divertida; o detalhamento completo (mais presets, animações, condições de oferta especial) entra na produção full.",
        },
      ],
    },
  },
  {
    id: "mapa",
    icon: "🗺️",
    label: "Mapa",
    color: "#6b5a1a",
    bg: "#f8f4e8",
    content: {
      title: "Mapa Regional",
      subtitle: "Desbloqueado por progressão, não disponível desde o início",
      tagline: '"A expansão geográfica é progressão, não exploração livre."',
      pillars: [
        {
          icon: "🌴",
          name: "Porto Mirim — ato 1 inteiro",
          desc: "A cidade e seus arredores imediatos. O jogador aprende todos os sistemas aqui antes de qualquer expansão.",
        },
        {
          icon: "🌊",
          name: "Foz do Tucunaré — ato 2",
          desc: "Delta fluvial a 40km. Comunidades ribeirinhas com artesanato, frutas tropicais e peixe de água doce. Contratos menores, relação mais pessoal. Onde o jogador aprende a trabalhar com rotas de menor margem mas maior fidelidade.",
        },
        {
          icon: "🏭",
          name: "Porto Seco de Itaquari — ato 2",
          desc: "Hub rodoviário sem litoral. Cargas industriais, clientes corporativos, sem personalidade. Os contratos mais lucrativos do mid game estão aqui — e também a presença mais forte do Grupo Atlântico.",
        },
        {
          icon: "🏝️",
          name: "Ilha das Pedras Brancas — late game",
          desc: "Turismo de alto padrão acessível só por barco. Demanda cara e exigente. Chegar lá requer que o porto já tenha estrutura suficiente para o nível de serviço exigido. É o destino que sinaliza ao jogador que ele chegou ao late game.",
        },
      ],
    },
  },
  {
    id: "regioes",
    icon: "🗺️",
    label: "Regiões",
    color: "#6b5a1a",
    bg: "#f8f4e8",
    content: {
      title: "Regiões — Desbloqueios e Condições",
      subtitle: "Cinco destinos com critérios de acesso definidos",
      tagline: '"O mapa não abre de uma vez. Cada rota nova é uma conquista, não um dado."',
      pillars: [
        {
          icon: "🏠",
          name: "Porto Mirim — disponível desde o início",
          desc: "A cidade base. Mercado local, pescadores, clientes da região imediata. Sem rotas externas ativas, todo contrato é daqui. Clientes: Seu Biu e os pescadores, prefeitura local, pequenos comerciantes. Carga típica: peixe, bebida, material de construção.",
        },
        {
          icon: "🏖️",
          name: "Praia Grande — desbloqueio Fase 1 (sem. 3)",
          desc: "Balneário vizinho a 40 km. Principal origem dos turistas de temporada. Condição de desbloqueio: completar uma docagem com barco de passagem. Clientes: operadoras de turismo náutico, pousadas, revendedores de equipamento. Carga típica: bagagem, equipamento turístico, alimentos festivos. Arlindo já tem rota ativa com Praia Grande — o jogador compete diretamente.",
        },
        {
          icon: "🏭",
          name: "Foz do Tucunaré / Porto Seco de Itaquari — desbloqueio Fase 2 (sem. 6)",
          desc: "Delta fluvial e hub rodoviário ao norte. Contratos de alto valor, prazo agressivo, presença forte do Grupo Atlântico. Condição de desbloqueio: posto de abastecimento operacional + reputação comercial acima de 60. Carga típica: combustível marítimo, material de construção em volume, carga sem nota (às vezes).",
        },
        {
          icon: "🌊",
          name: "Ilha das Pedras Brancas — desbloqueio Fase 2 (sem. 8)",
          desc: "Conjunto de ilhas ao largo. Único destino sem concorrência terrestre de Arlindo. Condição: rota ativa com Praia Grande + reputação comunitária acima de 55. Rota mais lucrativa por unidade — mas menor volume. Clientes: pescadores de alto mar, pesquisadores, turismo exclusivo.",
        },
        {
          icon: "🏙️",
          name: "Capital Regional — desbloqueio Fase 3 (sem. 10)",
          desc: "Cidade de 200 mil habitantes a 150 km. Contratos institucionais e corporativos. Condição: torre de comunicação construída + rota ativa com ao menos duas regiões anteriores. Chegar aqui sinaliza que o cais deixou de ser local. O Grupo Atlântico usa essa rota para pressão final.",
        },
      ],
    },
  },
  {
    id: "eventos",
    icon: "⚡",
    label: "Eventos",
    color: "#6b1a4a",
    bg: "#f8e8f0",
    content: {
      title: "Eventos Aleatórios",
      subtitle: "Cenário mantém o jogo imprevisível. Narrativa cria memórias.",
      tagline: '"Uma campanha tem 30 eventos de cenário e 5 narrativos. São os narrativos que o jogador conta para alguém."',
      pillars: [
        {
          icon: "🌪️",
          name: "Eventos de cenário — gerados pelo sistema",
          desc: "Tempestade em agosto que atrasa barcos. Maré de ressaca que danifica o píer. Surto de medusa que afasta turistas por duas semanas. Greve de caminhoneiros que interrompe o abastecimento. Chegam como notificação curta no início do dia — o jogador lê, avalia e reage.",
        },
        {
          icon: "📖",
          name: "Eventos narrativos — escritos à mão, únicos",
          desc: "Pescador veterano desaparece no mar e a comunidade pede ajuda para organizar busca. Navio encalhado próximo à costa — disputa com Arlindo sobre quem tem direito à carga recuperada. Inspetor federal aparece sem aviso: dependendo do histórico de cargas, pode ser rotina ou crise.",
        },
        {
          icon: "📰",
          name: "O papel da Bela",
          desc: "Ela anuncia alguns eventos de cenário com antecedência nas matérias semanais. Quem lê o jornal se prepara. Quem ignora, reage.",
        },
      ],
    },
  },
  {
    id: "construcao",
    icon: "🏗️",
    label: "Construção",
    color: "#3a3a6b",
    bg: "#eaeaf8",
    content: {
      title: "Progressão de Construção",
      subtitle: "Cinco fases visíveis — não uma árvore de tecnologia",
      tagline: '"O jogador não vê uma interface de árvore. Vê o cais se transformando, estrutura por estrutura."',
      pillars: [
        {
          icon: "1️⃣",
          name: "Fase 1 — O que o avô deixou",
          desc: "Píer de madeira com 6 vagas para pescadores, galpão velho, área de docagem básica (4 docas pequenas para barcos comerciais). Construções disponíveis são consertos e pequenas melhorias. Zezão executa tudo. Custo baixo, impacto imediato. Cobre Ato 1 — sobrevivência até a Parcela 1.",
        },
        {
          icon: "2️⃣",
          name: "Fase 2 — Porto com identidade própria",
          desc: "Posto de abastecimento, câmara frigorífica, segundo píer comercial, área coberta de carga, escritório administrativo. Cada estrutura desbloqueia um tipo de carga ou cliente. Câmara fria abre medicamentos. Segundo píer dobra capacidade de docagem. Escritório faz contratos de médio prazo chegarem com mais frequência. Aqui Kinha aparece como contratável e Carol como administrativa.",
        },
        {
          icon: "3️⃣",
          name: "Fase 3 — Igual ao Porto Farol",
          desc: "Terminal de passageiros, armazém climatizado, torre de comunicação para rotas regionais, área de manutenção naval coordenada pela Kinha (agora chefe de manutenção). Cada estrutura custa mais do que o porto inteiro valia no início. O Memorial do avô pode ser construído nesta fase. Cobre transição do Ato 2 para o Ato 3.",
        },
        {
          icon: "4️⃣",
          name: "Fase 4 — Porto nacional",
          desc: "Terminal de contêineres, aduana, plataforma de granel, ampliação da torre de controle, alojamento para tripulações. Sr. Abutre entra pessoalmente nesta fase — o porto agora interessa ao Grupo Atlântico. Banco de Porto Mirim libera a Linha Empresarial de empréstimos. Cobre Ato 3 inicial e a confrontação direta com o Atlântico. O Memorial também pode ser construído aqui se o jogador atrasou.",
        },
        {
          icon: "5️⃣",
          name: "Fase 5 — Grande porto costeiro",
          desc: "Estaleiro completo (único no mapa), dragagem profunda para navios oceânicos, área industrial separada, terminais especializados. Reservada para finais ambiciosos — o porto atinge esta escala apenas no caminho do Final A (Porto Unificado) ou em campanhas de longa duração após o Ato 3. A maioria das partidas termina na Fase 4. Disponível como horizonte de pós-campanha para quem busca expansão máxima.",
        },
        {
          icon: "🔑",
          name: "Pré-requisitos narrativos, não pontos de tech",
          desc: "Torre de comunicação exige rota ativa com duas regiões do mapa. Terminal de passageiros exige reputação alta com a comunidade. Estaleiro exige Kinha como chefe de manutenção há pelo menos 2 fases. As condições fazem sentido dentro da lógica da cidade. Zezão comenta cada nova estrutura — são os melhores momentos de humor do jogo.",
        },
        {
          icon: "📍",
          name: "Atos narrativos ≠ Fases de construção",
          desc: "O arco narrativo tem 3 Atos (Sobreviver, Resistir, Decidir). A construção tem 5 Fases. Não são a mesma coisa: as Fases marcam o tamanho físico do porto; os Atos marcam o momento dramático da história. Um jogador no Ato 3 pode estar na Fase 3 ou Fase 4. Os dois sistemas correm em paralelo e se conectam apenas por gatilhos específicos (ex.: Sr. Abutre só aparece em pessoa na Fase 4, geralmente coincidindo com o início do Ato 3).",
        },
      ],
    },
  },
  {
    id: "corrupcao",
    icon: "🤫",
    label: "Corrupção",
    color: "#5a4a1a",
    bg: "#f8f4e8",
    content: {
      title: "Corrupção Local",
      subtitle: "Banal, não dramatizada",
      tagline: '"Chefia, o senhor sabe o que ele quer. A pergunta é quanto isso vai custar da outra forma." — Dona Cida',
      pillars: [
        {
          icon: "🏛️",
          name: "Como aparece",
          desc: "Um prefeito que pede favor sem especificar o que é o favor. Um vereador que precisa de 'apoio' na campanha para aprovar uma licença. Um fiscal que demora mais na vistoria quando não se sente bem-vindo. Ninguém usa a palavra corrupção.",
        },
        {
          icon: "⚖️",
          name: "Dois custos, não uma escolha certa",
          desc: "Recusar o favor do prefeito: a licença demora três semanas a mais por razões nunca explicadas. Aceitar: a licença sai rápido, o prefeito aparece na Festa de São Pedro para foto ao lado do protagonista, e Bela pergunta por que os dois parecem tão próximos.",
        },
        {
          icon: "🎭",
          name: "Tom satírico, não panfletário",
          desc: "A corrupção é parte da paisagem de Porto Mirim da mesma forma que o calor e os mosquitos — algo que todo mundo conhece, que alguns aceitam como custo do negócio e que outros resistem com paciência e custo adicional.",
        },
        {
          icon: "📝",
          name: "O jogo registra, não julga",
          desc: "O jogador não recebe punição moral explícita por aceitar favores. Mas as escolhas ficam registradas no relacionamento com Bela, na reputação com a comunidade e em quem aparece — ou não aparece — no ato final.",
        },
      ],
    },
  },
  {
    id: "som",
    icon: "🎵",
    label: "Som",
    color: "#1a5a3a",
    bg: "#e8f5ee",
    content: {
      title: "Identidade Sonora",
      subtitle: "Forró de pé de serra com baião — não o eletrônico",
      tagline: '"Porto Mirim tem som mesmo quando não tem música."',
      pillars: [
        {
          icon: "🪗",
          name: "Base musical",
          desc: "Forró de triângulo, zabumba e sanfona como base — mas a trilha respira Brasil inteiro: baião, samba de roda, ijexá, chorinho. Tom quente e rítmico com alma brasileira. No early game com o cais decadente, a música é esparsa — violão e percussão leve, como se o porto ainda não tivesse energia. Conforme o porto cresce, a trilha ganha camadas.",
        },
        {
          icon: "📉",
          name: "Tensão pelo silêncio",
          desc: "Durante eventos de tensão — atraso de parcela, abordagem do Abutre, crise — a música não muda para algo dramático e genérico. Ela diminui. Fica só o triângulo e um baixo discreto. O silêncio parcial cria mais tensão do que qualquer string orquestral.",
        },
        {
          icon: "⛵",
          name: "A Festa de São Pedro — exceção total",
          desc: "Trilha própria de ciranda com coro, gravada com instrumentos ao vivo. Único momento em que a música para de ser ambiente e vira performance — os NPCs cantam, o porto dança.",
        },
        {
          icon: "🌊",
          name: "Som ambiente",
          desc: "Água batendo no cais, gaivotas, motor de barco distante, rádio AM saindo de algum lugar que nunca se localiza exatamente. A identidade sonora existe independentemente da trilha musical.",
        },
      ],
    },
  },
  {
    id: "dialogo",
    icon: "💬",
    label: "Diálogo",
    color: "#1a3a6b",
    bg: "#e8eef8",
    content: {
      title: "Voz e Humor Regional",
      subtitle: "O jogador ri porque reconhece o tipo humano",
      tagline: '"O humor não é inserido como piada — é parte da personalidade dos personagens."',
      pillars: [
        {
          icon: "🗣️",
          name: "Três elementos da voz de Porto Mirim",
          desc: "O sotaque implícito na estrutura das frases. As expressões que soam imediatamente brasileiras e litorâneas sem precisar de tradução. O timing — a pausa antes da ironia é parte do humor.",
        },
        {
          icon: "👩‍💼",
          name: "Registros por NPC",
          desc: "Dona Cida: rápida, direta, ironia seca. Zezão: fala pouco, sempre concreto, nunca metáfora. Arlindo: linguagem de negócio com cordialidade que torna cada elogio levemente ameaçador. Bela: vocabulário sofisticado mas expressões locais ainda escapam. Seu Biu: fala como quem sabe mais do que vai dizer.",
        },
        {
          icon: "📝",
          name: "Exemplos de linha",
          desc: "Zezão ao saber que a câmara fria precisa de reforma urgente: 'Já vi. Tô esperando você me dizer que tem dinheiro pra isso.' Dona Cida quando o jogador aceita prazo impossível: 'Chefia, eu respeito a coragem. Coragem e burrice têm a mesma cara às vezes.' Seu Biu na manhã depois de evento suspeito: 'Tive uma noite tranquila. Vi tudo. Não vi nada.'",
        },
      ],
    },
  },
  {
    id: "festividades",
    icon: "🎊",
    label: "Festividades",
    color: "#6b1a5a",
    bg: "#f8e8f4",
    content: {
      title: "Festividades Locais",
      subtitle: "Quatro eventos com impacto mecânico real",
      tagline: '"A Semana do Mar não existe no calendário oficial. Acontece todo ano de qualquer forma."',
      pillars: [
        {
          icon: "🎭",
          name: "Carnaval — fevereiro",
          desc: "Bloco desfila em frente ao porto. O jogador pode patrocinar — custo imediato, reputação por 4 semanas. Ou não patrocinar e descobrir que Arlindo patrocinou. O bloco do Porto Farol desfila antes e é maior.",
        },
        {
          icon: "🐟",
          name: "Semana do Mar — outubro",
          desc: "Feira náutica informal dos pescadores. Ceder espaço gratuitamente: reputação com pescadores sobe, Dona Cida reclama. Cobrar taxa simbólica: Dona Cida aprova, um pescador veterano que seria contato valioso decide não aparecer.",
        },
        {
          icon: "🎄",
          name: "Natal — dezembro",
          desc: "A família do protagonista visita o porto. Único momento em que o jogador vê o cais pelos olhos de alguém de fora. Um familiar que não entendia por que o herdeiro ficou olha para o que foi construído e fica quieto de um jeito que significa mais do que qualquer elogio. Há um flashback do avô.",
        },
        {
          icon: "🎆",
          name: "Réveillon — virada de ano",
          desc: "Fretamentos de barco para a virada são os mais caros do ano — preço livre, demanda garantida. Arlindo faz festa no Porto Farol com banda ao vivo para competir. O jogador que não preparou algo para a noite perde os clientes de virada para o rival.",
        },
        {
          icon: "🎂",
          name: "Aniversário do protagonista",
          desc: "No dia de aniversário do jogador no jogo — definido na criação do personagem — o porto para brevemente. Toninho aparece de manhã com um bolo de peixe e uma observação que mistura orgulho e constrangimento. Dona Cida entrega um relatório do ano com uma única nota de rodapé que não é financeira. Cada NPC com vínculo alto tem uma linha exclusiva nesse dia — nenhuma usada em outro momento. Não é uma recompensa mecânica: é um momento. O porto continua operando — a vida não para — mas a data é registrada no Diário com uma foto do porto no momento atual.",
        },
      ],
    },
  },
  {
    id: "bar_mane",
    icon: "🍻",
    label: "Bar do Mané",
    color: "#6b1a4a",
    bg: "#f5e6ef",
    content: {
      title: "Bar do Mané — Vida Noturna",
      subtitle: "Onde os NPCs param de ser funcionários",
      tagline: '"A Dona Cida no bar não é a Dona Cida do escritório. É a Cida. E a Cida ri."',
      pillars: [
        {
          icon: "🚪",
          name: "Onde fica e quando abre",
          desc: "Bar de esquina a 4 quadras do porto, fundado pelo Mané — irmão mais velho da Bela, fato revelado depois de algumas visitas. Aberto todo fim de tarde até meia-noite. O jogador acessa via botão 'sair do porto' no fim de turno: mini-cena visitável, câmera fixa no salão, NPCs distribuídos em mesas. Sem grade de inventário, sem combate, sem economia complexa — é uma cena para conversar.",
        },
        {
          icon: "👥",
          name: "Quem aparece em cada noite",
          desc: "Cada noite tem composição diferente. Toninho vai todas as quartas. Zezão vai sexta com certeza. Marina aparece quando teve dia bom. Dona Cida raramente — mas quando vai, é evento. Seu Biu nunca vai ao bar (toma cachaça em casa). NPCs fora do registro de trabalho mostram lados que não aparecem no porto: Zezão conta piada e ri alto; Marina canta tirolesa quando bêbada o suficiente; Dona Cida fica filosófica.",
        },
        {
          icon: "🎱",
          name: "Atividades por visita — uma escolha por noite",
          desc: "Três opções a cada ida: (1) conversar com um NPC presente — diálogo único daquela noite, não repetível, gera vínculo. (2) jogar sinuca contra NPC ou personagem aleatório — minigame simples de timing, aposta opcional, perder ou ganhar gera diálogo de bar. (3) ouvir conversa de outra mesa — eavesdropping deliberado que pode revelar fofoca, rumor sobre o Grupo Atlântico, info pessoal sobre Arlindo, ou alerta sobre contrato vindo.",
        },
        {
          icon: "🎤",
          name: "Eventos noturnos especiais",
          desc: "Calendário paralelo ao do porto. Noite de futebol no telão: a cidade toda no bar — todos os NPCs presentes, momento social condensado. Karaokê de forró: Toninho canta — uma das cenas mais inesperadas do jogo. Derby Porto Farol vs. Cais Mirim na sinuca: campeonato anual, prêmio simbólico mas reputação real. Cada evento sinalizado com antecedência via boletim ou conversa de NPC.",
        },
        {
          icon: "🌙",
          name: "Custo, impacto e amarrações",
          desc: "Visita ao bar = 1 turno consumido. Bebida cobrada (R$10–40 por noite, conforme consumo). Sem efeito de embriaguez no dia seguinte — o jogo escolhe não punir socializar. Vínculos com NPCs sobem mais rápido por bar do que por trabalho, porque conversar fora do contexto profissional é diferente. Contatos novos podem ser feitos no bar (turistas, viajantes, gente de fora) e entram na Agenda de Contatos. Roupa de trabalho num karaokê: ninguém liga. Terno: alguém vai zoar a noite toda.",
        },
      ],
    },
  },
  {
    id: "correspondencia",
    icon: "✉️",
    label: "Correspondência",
    color: "#1a4e8a",
    bg: "#e6eef8",
    content: {
      title: "Caixa de Correspondência",
      subtitle: "O fluxo lento de cartas — o que chega entre os turnos",
      tagline: '"Carta da minha mãe. Não abri ontem. Vou abrir hoje. Talvez."',
      pillars: [
        {
          icon: "📬",
          name: "Duas caixas físicas — porto e casa",
          desc: "Caixa no escritório do porto (correspondência comercial) e caixa na casa do protagonista (correspondência pessoal). Visualmente, o jogador vê envelopes empilhados — quantos mais não-lidos, mais alto o monte. Sensação visual de coisa pendente sem ser opressiva. Acessível por interação direta no objeto físico, não apenas por menu.",
        },
        {
          icon: "📃",
          name: "Tipos de carta",
          desc: "Formais — banco (Sr. Ribeiro), prefeitura, sindicato, cartórios, capitania. Comerciais — clientes em potencial, fornecedores, contatos do setor. Pessoais — família distante, ex-funcionários que se mudaram, amigos antigos, cartas anônimas que aparecem em momentos específicos. Promocionais — eventos do setor, leilões de arte, ofertas de imóveis. Estas o jogador pode optar por bloquear depois do tutorial.",
        },
        {
          icon: "🕒",
          name: "Ritmo natural de chegada",
          desc: "Cartas chegam ao longo dos turnos, não em rajada. 2–4 cartas novas por semana de jogo em média. Algumas exigem resposta (com prazo informal); outras só informam ou guardam memória. Cartas urgentes (banco, fiscal) têm marca visual diferente — selo vermelho. Cartas com selo da família vêm com música ambiente curta quando o jogador abre — três notas, sempre as mesmas, identidade sonora discreta.",
        },
        {
          icon: "✍️",
          name: "Responder, arquivar, expor",
          desc: "Responder cartas que pedem resposta gera diálogo curto com opções — versão escrita das conversas do jogo. Cartas podem ser arquivadas em pastas (nomeadas pelo jogador), expostas em quadros da casa/escritório, ou descartadas. Cartas com peso narrativo se acumulam num arquivo do Diário do Porto — releitura meses depois é o tipo de coisa que faz BR Port virar memória, não jogo.",
        },
        {
          icon: "📭",
          name: "Cartas que nunca chegam — silêncios que falam",
          desc: "O jogador percebe ao longo do tempo que algumas pessoas nunca escreveram. Arlindo nunca manda carta — é informação. A mãe do protagonista escreve menos do que talvez devesse — ou talvez esteja esperando ele escrever primeiro. Sem prompt explícito, mas a possibilidade existe: o jogador pode iniciar uma carta para qualquer NPC com endereço conhecido. A resposta — ou ausência dela — vira parte da história.",
        },
      ],
    },
  },
  {
    id: "eventos_setor",
    icon: "✈️",
    label: "Eventos do Setor",
    color: "#1a4e8a",
    bg: "#e6eef8",
    content: {
      title: "Eventos do Setor Portuário",
      subtitle: "O mundo além de Porto Mirim — conexões que não chegam até você",
      tagline: '"Arlindo foi à Expo Portos em Recife. Você não foi. O contrato foi para ele."',
      pillars: [
        {
          icon: "📅",
          name: "Tipos de evento e frequência",
          desc: "Feiras e exposições portuárias (2x por ano de jogo), congressos de logística regional (trimestral), encontros de associações de pescadores (mensal, mais acessíveis e locais) e cerimônias de premiação setorial (anuais, desbloqueadas só no ato 3). Cada evento aparece com antecedência no boletim de Bela ou como convite narrativo por e-mail — o jogador decide ir ou não. Sem punição por não ir, mas com bônus claros para quem vai.",
        },
        {
          icon: "🤝",
          name: "O que acontece nos eventos",
          desc: "O jogador não gerencia o porto durante o evento — escolhe ir (1–3 dias de jogo ausente) e retorna com resultado narrativo. Cada evento tem 2–3 outcomes possíveis conforme reputação comercial e roupa usada: contato novo que envia proposta de contrato, informação sobre movimentação do Grupo Atlântico na região, ou convite para evento maior desbloqueado no ato seguinte. Ir de transporte público ou carona: sem penalidade, mas sem o bônus de primeira impressão que um carro premium gera.",
        },
        {
          icon: "🏆",
          name: "Premiações e reconhecimento",
          desc: "No ato 3, o porto pode ser indicado a prêmios regionais de excelência — se a reputação comercial estiver acima de 80. A cerimônia é evento narrativo com todos os NPCs principais reagindo. Ganhar gera aumento permanente na fila de contratos premium. Arlindo também concorre — e se ele ganhar porque o jogador não foi à cerimônia, a cena de Toninho escutando a notícia no rádio é uma das mais discretamente impactantes do jogo.",
        },
        {
          icon: "💼",
          name: "Custo e planejamento",
          desc: "Cada evento tem custo de viagem (transporte + hospedagem, variável conforme a distância da região) e custo de oportunidade (dias sem gerenciar o porto). Com funcionários de alta lealdade, o porto opera bem na ausência. Com equipe fraca, um contrato pode ser perdido. O jogador vê o custo antes de confirmar — a decisão é informada, nunca uma armadilha.",
        },
      ],
    },
  },
  {
    id: "agenda_contatos",
    icon: "📇",
    label: "Agenda de Contatos",
    color: "#1a4e8a",
    bg: "#e6eef8",
    content: {
      title: "Rede de Networking",
      subtitle: "Cada aperto de mão num evento vira uma linha persistente na sua agenda",
      tagline: '"Não é o que você sabe. É quem te liga em janeiro quando você precisa de um contrato em fevereiro."',
      pillars: [
        {
          icon: "📑",
          name: "Como contatos entram na agenda",
          desc: "Cada NPC conhecido nos Eventos do Setor vira entrada permanente: nome, cidade de origem, ramo de atuação, observação curta do primeiro encontro ('A Helena da Logitar pareceu interessada no peixe fresco — mencionou fornecedores do Sul'). Contatos também entram via cartas recebidas, indicações de outros NPCs, clientes recorrentes que viram conhecidos, e conhecidos feitos no Bar do Mané (turistas, viajantes, gente de passagem).",
        },
        {
          icon: "📞",
          name: "Comunicação ativa — eles te procuram",
          desc: "Contatos enviam mensagens periodicamente sem o jogador pedir: oportunidades ('Tenho um cliente em Salvador buscando peixe premium — interessa?'), fofocas do setor ('Soube que o Grupo Atlântico fechou contrato em Itaquari por preço de banana'), convites para eventos exclusivos, pedidos pequenos (referências, recomendações). Cada mensagem é diálogo curto que pode virar decisão ou simples nota informativa.",
        },
        {
          icon: "🤝",
          name: "Manter vs. esfriar — relacionamento tem temperatura",
          desc: "Contato não respondido por muito tempo esfria silenciosamente. Não some, mas para de enviar oportunidades. Reativar exige interação proativa (carta, telefonema, próximo evento). Contato cultivado vira aliado de longo prazo — pode ajudar em momentos críticos do Ato 3. Um contato específico cuja relação foi cultivada cuidadosamente desbloqueia rota completamente nova no fim da campanha.",
        },
        {
          icon: "🎯",
          name: "Tipos de contato",
          desc: "Clientes em potencial (querem comprar serviços do porto), pares do setor (outros donos de porto pequenos, eventuais aliados regionais), reguladores (figuras da Receita, sindicato, capitania — neutros ou hostis dependendo do histórico) e imprensa fora de Porto Mirim (jornalistas regionais que escrevem sobre o setor — Bela tem relação com alguns deles, e pode fazer pontes).",
        },
        {
          icon: "🗺️",
          name: "Mapa de influência",
          desc: "A agenda tem visualização de mapa regional mostrando onde estão os contatos. Conforme cresce, o jogador percebe que tem rede em Praia Grande, Itaquari, Capital Regional — uma teia que o Grupo Atlântico vê e respeita. Visualizar a rede no Ato 3 com mais de 30 contatos ativos é uma das satisfações silenciosas do final de jogo.",
        },
      ],
    },
  },
  {
    id: "pesca_minigame",
    icon: "🎣",
    label: "Pesca",
    color: "#1a5a3a",
    bg: "#e6f5ee",
    content: {
      title: "Mini-game de Pesca",
      subtitle: "Pausa do porto — ritmo diferente, recompensa real",
      tagline: '"Seu Biu pesca o mesmo lugar há quarenta anos. Não é burrice — é sabedoria que parece igual."',
      pillars: [
        {
          icon: "📍",
          name: "Locais e desbloqueio",
          desc: "Cinco pontos de pesca conforme progressão do mapa: Píer do Cais Mirim (disponível desde o início), Enseada da Foz do Tucunaré (fase 2), Recife das Pedras Brancas (fase 2 — Seu Biu guia pessoalmente), Mar Aberto (fase 3, requer embarcação própria ou alugada) e Lagoa da Capital Regional (fase 4, pesca em água doce, espécies diferentes). Cada local tem clima, profundidade, espécies e dificuldade próprios.",
        },
        {
          icon: "🐟",
          name: "Mecânica — três fases por pescaria",
          desc: "Escolha de isca (afeta quais espécies aparecem e probabilidade de fisgada), Espera (animação de água com variação de clima — vento e maré afetam o tempo de espera e a força do peixe) e Resgatar (minigame de tensão: barra de força do peixe vs. tensão da linha — puxar demais quebra a linha; soltar demais perde o peixe). Peixe maior = mecânica mais intensa. Peixe de profundidade = janela de resgatar mais curta. Falhar gera comentário de Seu Biu — nunca repetido, sempre levemente diferente.",
        },
        {
          icon: "🌦️",
          name: "Clima como variável real",
          desc: "O sistema de clima já definido no GDD afeta diretamente a pesca. Mar agitado (agosto): menos espécies mas maior probabilidade de peixe grande. Dias de chuva: pesca em rio melhora, marítima piora. Alta temporada turística (janeiro): os locais mais próximos ficam cheios — pescadores NPCs ocupam espaço e reduzem a paciência disponível para esperar. Seu Biu comenta o clima antes de cada sessão sem ser solicitado.",
        },
        {
          icon: "🎁",
          name: "Recompensas e integração com o loop principal",
          desc: "Peixe pescado vai direto para o inventário do porto como carga fresca com prazo de 24h. Espécies raras desbloqueiam itens decorativos para o escritório ou diálogos únicos com NPCs. Pescar regularmente com Seu Biu constrói vínculo com ele — parte das informações que ele guarda (segredos do porto, movimentos noturnos suspeitos) só são reveladas depois de algumas sessões de pesca compartilhadas.",
        },
        {
          icon: "⏸️",
          name: "Como quebra o ritmo",
          desc: "O mini-game está disponível a qualquer momento entre turnos, sem custo de tempo de jogo. É a única atividade que pausa o loop econômico sem consequências: sem parcelas vencendo, sem rivais agindo, sem notificações. Apenas água, linha e o silêncio de Seu Biu ao lado. Essa zona de calma é intencional. O jogador que só otimiza o porto nunca pesca. O jogador que pesca às vezes descobre coisas que o otimizador perdeu.",
        },
      ],
    },
  },
  {
    id: "concurso_pesca",
    icon: "🏆",
    label: "Concurso de Pesca",
    color: "#1a5a3a",
    bg: "#e6f5ee",
    content: {
      title: "Concurso de Pesca da Semana do Mar",
      subtitle: "Anual, organizado por Seu Biu — o evento que prova que pesca é arte",
      tagline: '"Eu não vou pra ganhar. Vou pra ver quem aprendeu." — Seu Biu, no dia da inscrição',
      pillars: [
        {
          icon: "📅",
          name: "Quando e como acontece",
          desc: "Toda Semana do Mar (outubro) tem o concurso como evento central. Inscrição abre na segunda; competição é no sábado. O jogador pode se inscrever ou organizar a inscrição de NPCs amigos do porto. Inscrever-se exige domínio mínimo do mini-game de pesca — quem nunca pescou no jogo recebe diálogo de Seu Biu sugerindo praticar antes. Sem barreira mecânica, só sugestão narrativa.",
        },
        {
          icon: "🎯",
          name: "Três categorias para focar",
          desc: "Peixe maior (peso), peixe mais raro (espécie) e melhor variedade (5 espécies diferentes em 6 horas). O jogador escolhe uma categoria. A competição é sessão estendida do mini-game de pesca com 6 turnos consecutivos no local escolhido. NPCs competidores (Seu Biu, dois pescadores anônimos, e Arlindo a partir do ato 2) competem em paralelo com resultados visíveis no quadro do concurso.",
        },
        {
          icon: "🥇",
          name: "Prêmios e consequências",
          desc: "Vencer uma categoria = troféu físico (vai para o escritório do porto), reputação comunitária +15 pontos, foto na primeira página do jornal da Bela na semana seguinte. Vencer as três = título de 'Mestre da Maré' que NPCs mencionam pelo resto da campanha. Perder para Arlindo é mais doloroso que perder para Seu Biu — Arlindo gosta de fazer questão. Perder para Seu Biu é diferente: ele oferece dica em silêncio.",
        },
        {
          icon: "🍲",
          name: "Conexão com culinária e filantropia",
          desc: "Se o jogador estudou Culinária (hobby), pode oferecer prato preparado com peixe pescado no concurso para a comunidade — bônus duplo de reputação. Se participa da Filantropia, pode doar parte do peixe pescado durante o concurso para o asilo local ou escola de pescadores — diálogo único de Dona Marlene reconhecendo o gesto. O peixe pescado durante o concurso é especial: tem etiqueta narrativa.",
        },
        {
          icon: "🗓️",
          name: "Memória anual",
          desc: "O Diário do Porto guarda os resultados de cada concurso ano a ano. No Ato 3, cena curta de Seu Biu folheando os resultados acumulados, comentando como a pesca mudou em Porto Mirim desde a primeira edição. Quem ignorou o concurso a campanha toda recebe essa cena também, em tom diferente — não acusatório, melancólico.",
        },
      ],
    },
  },
  {
    id: "conexoes_cruzadas",
    icon: "🔗",
    label: "Conexões Cruzadas",
    color: "#2a4a6b",
    bg: "#e8edf5",
    content: {
      title: "Onde os Sistemas se Tocam",
      subtitle: "As amarrações invisíveis que fazem o jogo parecer vivo",
      tagline: '"O jogador não vê o sistema. Vê uma noite em que o carro novo abriu a porta certa."',
      pillars: [
        {
          icon: "🚗",
          name: "Chegada em eventos — carro + roupa + reputação",
          desc: "Quando o jogador entra num Evento do Setor, o jogo combina três variáveis numa única 'cena de chegada' com outcome composto. Carro premium + terno + reputação alta = entrada com foto de Bela na coluna social no dia seguinte, contato VIP feito. Carro popular + camiseta + reputação média = entrada digna, contatos normais, sem destaque. Transporte público + roupa de trabalho + reputação baixa = chegada discreta, ninguém repara — pode ser estratégia para evitar o Grupo Atlântico. Cada combinação é cena diferente.",
        },
        {
          icon: "🐟",
          name: "Pesca → Filantropia → Festividades",
          desc: "Peixe pescado pelo jogador pode ser doado para asilo local ou escola de pescadores (filantropia) — gera bônus de reputação maior que doação em dinheiro equivalente, porque é trabalho próprio. Se doado durante a Semana do Mar ou Festa de São Pedro, vira evento narrativo: Toninho organiza 'mesa do protagonista' na festividade com cena pública de gratidão. Loop fechado entre três sistemas separados.",
        },
        {
          icon: "📸",
          name: "Personalização → Diário → Memória visual",
          desc: "Cada foto do Diário registra a roupa que o protagonista estava usando naquele dia. Quem mudou de aparência ao longo do jogo vê visualmente sua própria evolução ao folhear o álbum no ato 3 — magro vs. forte, cabelo de neto vs. cabelo de chefe, terno do avô em 3 ocasiões diferentes. A personalização vira história visual sem ser sistema independente.",
        },
        {
          icon: "👷",
          name: "Salário → Aparência dos funcionários",
          desc: "Funcionários bem pagos vestem melhor — sutileza visual no sprite deles. Marina com salário acima da média ganha bota nova; Kinha aparece com camisa limpa. Quem é pago abaixo do mercado mostra o desgaste — mesma roupa por meses, mesmo gesto cansado. A leitura é instintiva: o jogador percebe sem que o jogo aponte. Bela escreve sobre o porto que cuida da equipe — ou que não cuida — sem precisar de tutorial.",
        },
        {
          icon: "🍻",
          name: "Bar do Mané → Vínculos → Informação",
          desc: "Conversa no bar gera vínculo 1,5× mais rápido que interação no porto. Vínculo alto desbloqueia informação privilegiada: Marina avisa de proposta de Arlindo, Carol mostra a planilha que economiza 15%, Toninho conta o que sabe sobre o avô. O bar não é desvio do jogo principal — é atalho silencioso para o conteúdo narrativo mais profundo. Sinuca contra estranho pode render contato novo na Agenda. Eavesdropping pode antecipar evento de mercado.",
        },
        {
          icon: "📔",
          name: "Diário do Porto como integrador final",
          desc: "Quase todo sistema novo gera entradas no Diário — primeira viagem, primeira foto, primeira carta da família, primeira sinuca no bar, primeira pescaria, primeiro hobby concluído, primeiro pet adotado, primeira doação para causa, primeiro concurso vencido. O Diário não é só registro econômico — é a costura narrativa que faz o jogador, meses depois, lembrar de BR Port como uma vida vivida, não uma planilha gerenciada.",
        },
        {
          icon: "🕰️",
          name: "Por que o tempo voa nesse jogo",
          desc: "Cada sessão tem 5–6 micro-atividades disponíveis antes mesmo de pensar no loop econômico: checar correspondência, dar oi pro Pingado, ler o Boletim Financeiro, ver se tem matéria nova da Bela, decidir se vai ao Bar do Mané à noite, treinar pesca, dedicar um turno a hobby. Cada uma rápida, cada uma com chance pequena de trazer algo novo. O porto fica como espinha dorsal, e a vida em volta dele é o que prende. O jogador abre o app pra 'só checar uma coisa rápida' e perde 40 minutos sem perceber.",
        },
      ],
    },
  },
  {
    id: "temas",
    icon: "🌿",
    label: "Temas Sociais",
    color: "#2a5a2a",
    bg: "#eaf5ea",
    content: {
      title: "Desigualdade, Pobreza e Meio Ambiente",
      subtitle: "Contexto vivido, não missão temática",
      tagline: '"Porto Mirim não resolve esses temas. O jogador pode agir dentro de seu alcance — que é considerável mas limitado."',
      pillars: [
        {
          icon: "⚖️",
          name: "Desigualdade",
          desc: "Os pescadores artesanais trabalham há décadas com o mesmo barco de madeira. Os turistas de verão chegam com equipamento que custa mais do que um ano de pesca. O jogo não faz discurso sobre isso. Coloca os dois no mesmo espaço e deixa o jogador observar.",
        },
        {
          icon: "💰",
          name: "Pobreza",
          desc: "O salário que o porto paga é baixo porque é o que o mercado local paga. Kinha é competente demais para o que ganha e sabe disso. Quando o jogador aumenta o salário dela, ela não agradece efusivamente — diz 'era o que deveria ser' e volta ao trabalho. O jogo registra que foi a coisa certa sem transformar o momento em recompensa emocional excessiva.",
        },
        {
          icon: "🌿",
          name: "Exploração ambiental — o arco do mangue",
          desc: "Se o jogador defende o mangue: perde contrato com a construtora do resort, ganha confiança permanente dos pescadores e um arco com Bela narrativamente bem resolvido. Se não se envolve: o resort é construído, a pesca artesanal declina, alguns pescadores do píer partem. O cais perde movimento. Ninguém explica que foi culpa do jogador.",
        },
        {
          icon: "🏆",
          name: "Princípio de design",
          desc: "O jogo não premia messianismo. Premia consistência. O jogador que age bem em pequenas decisões ao longo de toda a campanha constrói uma Porto Mirim diferente de quem otimizou apenas para lucro — e o ato final reflete isso.",
        },
      ],
    },
  },
  {
    id: "monetizacao",
    icon: "💳",
    label: "Monetização",
    color: "#1a6b3a",
    bg: "#e8f8ee",
    content: {
      title: "Modelo de Negócio",
      subtitle: "Premium puro — sem anúncios, sem energia, sem IAP de progressão",
      tagline: '"O jogador paga uma vez. O porto é dele para sempre."',
      pillars: [
        {
          icon: "💰",
          name: "Preço e plataformas",
          desc: "Preço-alvo: US$ 4,99 (Android / iOS) — equivalente a R$ 24–29 no lançamento. Posicionamento no mesmo segmento de Alto-Astral, Monument Valley e similares — premium acessível, não premium de nicho. PC (Steam): US$ 9,99 se/quando portado. Sem versão gratuita com parede — ou o jogador compra ou não joga.",
        },
        {
          icon: "🚫",
          name: "O que nunca entra",
          desc: "Sem anúncios em qualquer forma. Sem moeda premium paralela (gemas, fichas, doblões). Sem energia ou limite de sessão. Sem IAP de aceleração. Sem loot boxes ou gacha. Sem season pass ou conteúdo de campanha por DLC. Essa lista é princípio de design, não promessa de marketing — violá-la quebra o contrato com o jogador.",
        },
        {
          icon: "✅",
          name: "O que é permitido no futuro",
          desc: "DLC de história: expansão com novo porto, novos personagens, nova narrativa — pago separado, nunca necessário para os finais. Pacote cosmético: skins de interface, pixel art alternativa para o cais — sem impacto em gameplay. Update gratuito de conteúdo: eventos sazonais, missões extras, nova carga — recompensa quem já pagou.",
        },
        {
          icon: "📱",
          name: "Por que premium funciona aqui",
          desc: "O público de management games mobile paga premium ativamente se confiar na proposta. Magic Research gerou US$ 400k com dois posts no subreddit certo, sem campanha paga. BR Port tem identidade visual e cultural clara o suficiente para sustentar essa proposta. O risco é alcance menor nos charts — a vantagem é ausência de toxicidade de monetização na comunidade.",
        },
      ],
    },
  },
];

const tagStyle = {
  display: "inline-block",
  fontSize: 11,
  fontWeight: 500,
  padding: "2px 8px",
  borderRadius: 99,
  marginRight: 4,
  marginBottom: 4,
};

function HarborKingsGDD() {
  const [active, setActive] = useState("identity");
  const sec = sections.find((s) => s.id === active);

  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 520, margin: "0 auto", padding: "16px 12px" }}>
      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 24 }}>
        <div style={{ fontSize: 13, letterSpacing: 3, textTransform: "uppercase", color: "#888", fontFamily: "monospace", marginBottom: 4 }}>
          Game Design Document — BR Port
        </div>
        <div style={{ fontSize: 28, fontWeight: 700, color: "#1a3a5c", letterSpacing: -1 }}>
          ⚓ BR Port
        </div>
        <div style={{ fontSize: 13, color: "#888", fontStyle: "italic", marginTop: 2 }}>
          v6.5 — Fase 1 do roadmap concluída · Decisões do VS fechadas
        </div>
      </div>

      {/* Nav tabs */}
      <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 20, justifyContent: "center" }}>
        {sections.map((s) => (
          <button
            key={s.id}
            onClick={() => setActive(s.id)}
            style={{
              fontSize: 12,
              padding: "6px 12px",
              borderRadius: 99,
              border: active === s.id ? `2px solid ${s.color}` : "1px solid #ddd",
              background: active === s.id ? s.bg : "transparent",
              color: active === s.id ? s.color : "#666",
              fontWeight: active === s.id ? 600 : 400,
              cursor: "pointer",
              transition: "all 0.15s",
            }}
          >
            {s.icon} {s.label}
          </button>
        ))}
      </div>

      {/* Content card */}
      <div style={{
        background: sec.bg,
        border: `1.5px solid ${sec.color}33`,
        borderRadius: 14,
        padding: "20px 18px",
        minHeight: 300,
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 4 }}>
          <span style={{ fontSize: 22 }}>{sec.icon}</span>
          <div>
            <div style={{ fontSize: 18, fontWeight: 700, color: sec.color, lineHeight: 1.2 }}>
              {sec.content.title}
            </div>
            <div style={{ fontSize: 11, color: "#999", textTransform: "uppercase", letterSpacing: 1 }}>
              {sec.content.subtitle}
            </div>
          </div>
        </div>

        <div style={{
          fontSize: 13,
          fontStyle: "italic",
          color: sec.color,
          background: `${sec.color}11`,
          border: `1px solid ${sec.color}22`,
          borderRadius: 8,
          padding: "8px 12px",
          margin: "12px 0",
          lineHeight: 1.5,
        }}>
          {sec.content.tagline}
        </div>

        {/* Fields */}
        {sec.content.fields && (
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {sec.content.fields.map((f, i) => (
              <div key={i} style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                <div style={{ fontSize: 12, color: "#999", minWidth: 130, paddingTop: 1 }}>{f.label}</div>
                <div style={{ fontSize: 13, color: "#333", fontWeight: 500, flex: 1 }}>{f.value}</div>
              </div>
            ))}
          </div>
        )}

        {/* NPCs / Funcionários / Cargas */}
        {sec.content.npcs && (
          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginTop: 4 }}>
            {sec.content.npcs.map((n, i) => (
              <div key={i} style={{
                background: "white",
                border: `1px solid ${sec.color}22`,
                borderRadius: 10,
                padding: "10px 12px",
              }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 4, gap: 8 }}>
                  <span style={{ fontWeight: 700, fontSize: 13, color: sec.color, lineHeight: 1.3 }}>{n.name}</span>
                  <span style={{ ...tagStyle, background: `${sec.color}18`, color: sec.color, flexShrink: 0 }}>
                    {n.role}
                  </span>
                </div>
                <div style={{ fontSize: 12, color: "#555", marginBottom: 6, lineHeight: 1.5 }}>{n.personality}</div>
                <div style={{ fontSize: 12, fontStyle: "italic", color: "#777", borderLeft: `3px solid ${sec.color}44`, paddingLeft: 8 }}>
                  {n.humor}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pillars */}
        {sec.content.pillars && (
          <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 4 }}>
            {sec.content.pillars.map((p, i) => (
              <div key={i} style={{
                display: "flex",
                gap: 12,
                background: "white",
                border: `1px solid ${sec.color}22`,
                borderRadius: 10,
                padding: "10px 12px",
                alignItems: "flex-start",
              }}>
                <span style={{ fontSize: 20, marginTop: 2 }}>{p.icon}</span>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 13, color: sec.color, marginBottom: 2 }}>{p.name}</div>
                  <div style={{ fontSize: 12, color: "#555", lineHeight: 1.5 }}>{p.desc}</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <div style={{ textAlign: "center", marginTop: 16, fontSize: 11, color: "#bbb", fontFamily: "monospace" }}>
        BR Port • GDD v6.5 • {sections.length} seções
      </div>
    </div>
  );
}
  return HarborKingsGDD;
})();

/* =================================================================
   Sistemas  —  fonte: BR_Port_Sistemas_v5_5.jsx
   Conteúdo e lógica preservados integralmente; apenas isolado
   em escopo próprio para evitar colisão de identificadores.
   ================================================================= */
const Sistemas = (() => {
// ── Paleta ───────────────────────────────────────────────────────────
const palette = {
  gameplay:     { main: "#1a6b8a", light: "#e8f4f8", border: "#b3d8e8" },
  phases:       { main: "#2d7a3a", light: "#eaf5ec", border: "#a8d8b0" },
  rivals:       { main: "#8a3a1a", light: "#f8ece8", border: "#e8b8a8" },
  monetization: { main: "#5a3480", light: "#f0eafa", border: "#c8aaea" },
  loop:         { main: "#1a5a6b", light: "#e6f2f5", border: "#9dc8d5" },
  mapa:         { main: "#3a6b1a", light: "#edf5e6", border: "#a8cc88" },
  tutorial:     { main: "#6b5a1a", light: "#f5f0e6", border: "#d4b870" },
  npcs:         { main: "#6b1a4a", light: "#f5e6ef", border: "#d48aaa" },
  reputacao:    { main: "#1a3a6b", light: "#e6ecf5", border: "#8aaacb" },
  finais:       { main: "#4a1a1a", light: "#f5e6e6", border: "#c88a8a" },
  economia:     { main: "#1a6b3a", light: "#e6f5ec", border: "#88c8a0" },
  gamefeel:     { main: "#5a1a6b", light: "#f4e8f8", border: "#c098d8" },
  save:                { main: "#2a3a5a", light: "#eaedf5", border: "#9aabcb" },
  onboarding_avancado: { main: "#5a6b1a", light: "#f0f5e6", border: "#c0d088" },
  acessibilidade:      { main: "#4a3a6b", light: "#efeaf5", border: "#b8a8d8" },
  kpis:                { main: "#6b3a4a", light: "#f5eaee", border: "#d8a8b8" },
  pos_lancamento:      { main: "#3a6b5a", light: "#eaf5f0", border: "#88c8b0" },
  voz_personagens:     { main: "#6b5a3a", light: "#f5efea", border: "#d8c088" },
  questions:    { main: "#7a6010", light: "#fdf8e8", border: "#e8d88a" },
};

// ── Questões já resolvidas ───────────────────────────────────────────
const INITIAL_RESOLVED = {
  // Original v3 (grupos 0–3)
  "0-0":true,"0-1":true,"0-2":true,"0-3":true,"0-4":true,"0-5":true,"0-6":true,"0-7":true,
  "1-0":true,"1-1":true,"1-2":true,"1-3":true,"1-4":true,"1-5":true,"1-6":true,"1-7":true,
  "2-0":true,"2-1":true,"2-2":true,"2-3":true,"2-4":true,"2-5":true,"2-6":true,"2-7":true,
  "3-0":true,"3-1":true,"3-2":true,"3-3":true,"3-4":true,"3-5":true,"3-6":true,"3-7":true,
  // Grupos extras — todos fechados na v5.5
  "4-0":true,"4-1":true,"4-2":true,"4-3":true,
  "5-0":true,"5-1":true,"5-2":true,"5-3":true,
  "6-0":true,"6-1":true,"6-2":true,
  "7-0":true,"7-1":true,"7-2":true,"7-3":true,
  "8-0":true,"8-1":true,"8-2":true,"8-3":true,
};

// ── Grupos de perguntas ──────────────────────────────────────────────
const questionGroups = [
  {
    icon: "🎮", label: "Gameplay", color: "#1a6b8a",
    questions: [
      { q: "Há limite de contratos ativos simultaneamente?", why: "Define se o jogador pode superagendar o porto ou se existe um cap. Impacta diretamente a tensão tática e a dificuldade da curva de aprendizado.", decision: "Cap dinâmico por fase. Começa em 3 contratos simultâneos (Fase 1) e cresce até 8–10 na Fase 5. O limite desaparece naturalmente junto com o crescimento do porto." },
      { q: "Trabalhadores têm especialidades fixas ou são intercambiáveis?", why: "Se cada trabalhador tem um papel (estivador, carpinteiro, guarda), a alocação fica muito mais estratégica. Se são genéricos, o sistema é mais simples, mas pode ser menos interessante.", decision: "Especialidades com penalidade. Cada trabalhador tem função principal, mas pode exercer outra com 30–40% menos eficiência. Estratégico sem punir erros de forma irreversível." },
      { q: "Existe cansaço, moral ou turno para os trabalhadores?", why: "Sem esse sistema eles operam a 100% sempre — mais simples, mas menos realista. Com ele, o jogador precisa gerir escala e descanso, o que adiciona profundidade.", decision: "Só moral — sem barra de cansaço. Sobe com bônus e promessas cumpridas, cai com exploração. Moral baixa reduz rendimento e pode culminar em demissão." },
      { q: "Como funciona o fluxo de caixa: por contrato ou periódico?", why: "Receber só ao cumprir contratos cria picos e vales financeiros. Fluxo diário (aluguel de doca, tarifas) é mais previsível. A escolha afeta toda a estratégia econômica.", decision: "Híbrido. Renda passiva semanal (píer, aluguel de armazém) cobre custos fixos. Contratos entregam o lucro real de crescimento. O passivo é o chão; o ativo é o teto." },
      { q: "O que acontece se o porto ficar sem dinheiro?", why: "Game over? Empréstimo forçado com juros? Um NPC que oferece ajuda com custo narrativo? Precisa ser definido para o designer saber onde está o 'chão' do jogo.", decision: "Três camadas progressivas: Sr. Ribeiro avisa sem penalidade → vaga do píer é penhorada → Sr. Abutre faz oferta de compra como único 'final ruim'. Falência é arco narrativo, não tela de game over." },
      { q: "Eventos climáticos (tempestades, neblina) existem no jogo?", why: "Clima adiciona imprevisibilidade e oportunidade para storytelling. Se existir, como o jogador é avisado? Navios atrasam, contratos vencem, como fica?", decision: "Existem com aviso antecipado. Boletim do porto alerta 1 dia antes. Efeitos: navios atrasam, guindaste para, contratos de prazo curto em risco. Sem destruição de infraestrutura." },
      { q: "Há ciclo de dia e noite com efeito mecânico?", why: "Se dia/noite existe só visualmente, é cosmético. Se navios chegam mais à noite ou trabalhadores custam mais em hora extra, vira uma camada de decisão importante.", decision: "Custo e oportunidade. Noite custa mais (hora extra no salário) e fecha alguns clientes (turismo, aduana). Mas abre eventos exclusivos — certos navios e missões narrativas só aparecem à noite." },
      { q: "Onde o jogador compra upgrades de infraestrutura (ex: grua mais rápida)?", why: "Isso define se existe uma 'loja de equipamentos' separada, se upgrades saem do mesmo menu de construção, ou se vêm como recompensa de contrato.", decision: "Clicando no objeto no mapa. Clicar na grua abre o painel daquela grua. Construções novas ficam no menu de construção geral. Cada objeto gerencia a si mesmo." },
    ],
  },
  {
    icon: "🏗️", label: "Fases", color: "#2d7a3a",
    questions: [
      { q: "A reputação pode regredir a ponto de o jogador 'descer' de fase?", why: "Regredir de fase pode ser frustrante ou dramático dependendo da execução. Definir isso impacta diretamente o design de risco e a tolerância a falhas do jogo.", decision: "Regressão parcial com trava. A fase conquistada é permanente, mas se a reputação cair abaixo do mínimo, certos contratos e clientes somem até ela se recuperar. A estrutura permanece; o acesso, não." },
      { q: "As 3 condições de avanço precisam ser cumpridas simultaneamente?", why: "Se sim, o jogador pode ficar travado com reputação alta mas sem a construção obrigatória. Há uma ordem recomendada? Existe dica clara sobre o que falta?", decision: "Simultâneas com painel de progresso claro. As três condições precisam estar ativas ao mesmo tempo, e o jogador vê em tempo real o quanto falta de cada uma. Sem surpresa, sem travamento silencioso." },
      { q: "Existe limite de tempo máximo por fase, ou o jogador avança no próprio ritmo?", why: "Sem limite o jogo é sandbox — mais relaxante. Com prazo, a pressão aumenta e a narrativa fica mais urgente. Precisa ser decidido antes de balancear a dificuldade.", decision: "Pressão narrativa sem limite rígido. Não há timer, mas o Sr. Abutre intensifica a pressão conforme o tempo passa — criando urgência orgânica sem punição de relógio." },
      { q: "Construções antigas podem ser demolidas para liberar espaço?", why: "Se o mapa do porto é limitado, o jogador vai precisar tomar decisões de layout. Demolir e recolocar tem custo? Isso pode ser uma camada estratégica relevante.", decision: "Demolição com custo parcial. Recupera 50% dos recursos. Construções herdadas do avô custam mais para derrubar — o jogo reconhece o valor sentimental mecanicamente." },
      { q: "Existe upgrade de construções existentes ou só construção nova?", why: "Upgrade (ex: cais básico → cais reforçado) é mais fluido e menos custoso visualmente. Construção nova exige espaço e planejamento. As duas abordagens têm trade-offs grandes.", decision: "Ambos, com lógica clara. Estruturas principais (grua, cais, armazém) têm upgrade in-place de até 3 níveis. Estruturas de expansão (nova doca, novo galpão) exigem construção nova e espaço." },
      { q: "Porto Mirim tem efeito mecânico ou é só narrativa/visual?", why: "Se a cidade ao redor afeta gameplay (ex: população alta = mais trabalhadores disponíveis, turistas = renda passiva), vira um sistema a mais. Se é só cenário, simplifica bastante.", decision: "Mecânica leve e passiva. Quanto maior a cidade, mais trabalhadores disponíveis no mercado. Em alta temporada turística, renda passiva pequena entra automaticamente. Sem gestão ativa da cidade." },
      { q: "Existem eventos sazonais dentro das fases (ex: festa de pesca, furacão)?", why: "Eventos sazonais dão ritmo e surpresa ao loop. Precisam de sistema de agenda e variação por fase. Se existirem, como são comunicados ao jogador com antecedência?", decision: "Calendário fixo por fase com aviso prévio. Cada fase tem 2–3 eventos sazonais fixos — ex: Festa de São Pedro, alta temporada em janeiro, vento sul em agosto. O boletim avisa com antecedência." },
      { q: "A missão narrativa de conclusão de fase pode ser revisitada?", why: "Se a cutscene é única e não pode ser rebobinada, o jogador perde se sair do jogo. Se pode revisitar (no diário, por exemplo), adiciona valor de replay e coleta.", decision: "Diário do Porto com cápsula do tempo. Cada missão de fase vai para o Diário com artefatos extras: fotos do porto, cartas de NPCs, manchetes do jornal local. Revisitável a qualquer momento." },
    ],
  },
  {
    icon: "⚔️", label: "Rivais", color: "#8a3a1a",
    questions: [
      { q: "O jogador recebe aviso antes de um rival agir, ou só descobre depois?", why: "Aviso prévio permite reação estratégica — mais fair, menos frustrante. Descobrir depois cria surpresa e urgência. A resposta define o tom de tensão do sistema.", decision: "Aviso parcial por nível de ameaça. Rivalômetro baixo = sem aviso. Médio = sinal vago ('Arlindo está se movimentando...'). Crítico = aviso claro com janela de reação. A informação é proporcional ao risco acumulado pelo jogador." },
      { q: "Rivais podem se aliar entre si e agir em conjunto?", why: "Aliança entre rivais aumenta muito a ameaça e cria situações de 'dois fronts'. Exige mais do jogador, mas pode ser muito frustrante se não for sinalizado adequadamente.", decision: "Aliança como evento narrativo único. Na transição para a Fase 4, Arlindo e Abutre consideram uma aliança em cena exclusiva. O jogador pode intervir via missão com a Bela para impedir. Se não intervir, agem juntos por período limitado." },
      { q: "É possível eliminar um rival permanentemente ou eles sempre retornam?", why: "Eliminação permanente dá sensação de conquista, mas reduz a pressão no late game. Retorno garante tensão contínua. Precisa estar alinhado com o arco narrativo de cada rival.", decision: "Eliminação narrativa, não mecânica. Arlindo pode ser 'derrotado' — seu porto perde relevância e ele para de agir ativamente, podendo virar aliado. Abutre (Atlântico S.A.) nunca é eliminado; a corporação é grande demais e o final narrativo resolve isso." },
      { q: "O Capitão Arlindo pode se tornar aliado permanente após ser derrotado?", why: "Um ex-rival aliado é uma das mecânicas narrativas mais satisfatórias em jogos de gestão. Define se o arco do Arlindo tem um final 'bom', além de criar escolha moralmente interessante.", decision: "Aliado por escolha do jogador, com custo. Após enfraquecer Arlindo na Fase 3, o jogador recebe proposta de parceria. Aceitar dá bônus permanentes mas custa reputação com NPCs que desconfiam dele. Recusar mantém a rivalidade até a Fase 4." },
      { q: "O Rivalômetro é visível o tempo todo na tela ou precisa de menu específico?", why: "Visível desde o início = jogador sempre ciente. Mas isso quebra o beat narrativo crucial onde o jogador descobre que 'não foi azar, foi Arlindo'. Em menu = jogador pode ignorar e ser pego de surpresa.", decision: "Oculto no início, aparece após descoberta narrativa. Os primeiros ataques de Arlindo parecem azar — Conceitos define este como um beat narrativo importante. Quando o jogador percebe o padrão (gatilho narrativo, ~semana 3–4), Toninho ou Bela apresentam o sistema, e o ícone do Rivalômetro aparece pela primeira vez no HUD. A partir daí: ícone compacto que muda de cor (verde/amarelo/vermelho) e expande ao tocar. Sempre visível depois da descoberta. Esse design protege a surpresa do early game e mantém a transparência mecânica do mid/late game." },
      { q: "Como a IA rival decide sua próxima ação?", why: "Script fixo por fase é mais previsível e fácil de balancear. IA reativa ao comportamento do jogador é mais sofisticada, mas exige muito mais testes. Qual é o escopo viável?", decision: "Script por fase com gatilhos reativos. Sequência base predefinida (fácil de balancear), mas comportamentos do jogador disparam reações específicas — ex: dominar todos os leilões por 3 dias seguidos faz Arlindo iniciar campanha de boatos." },
      { q: "Existe sistema de 'inteligência' para o jogador espionar rivais?", why: "Um personagem espião ou sistema de informação pago seria uma camada de meta-jogo rica. Sem isso, o jogador reage cegamente. Define quanto de assimetria de informação o jogo tem.", decision: "Missões pagas com a Bela. A repórter pode ser contratada para investigar um rival por custo em reputação ou dinheiro. Retorna informações específicas e acionáveis. Disponível a partir da Fase 2." },
      { q: "O que acontece se o Rivalômetro crítico for ignorado repetidamente?", why: "Precisa ter um teto claro: o rival conquista um contrato chave? Fecha uma rota? Desencadeia um evento narrativo? Sem isso, o sistema fica sem consequências reais.", decision: "Escalada narrativa em três atos. 1º crítico ignorado → rival fecha o melhor contrato da semana. 2º → planta boato que derruba reputação por 5 dias. 3º → evento narrativo obrigatório com penalidade permanente até o fim da fase." },
    ],
  },
  {
    icon: "💰", label: "Monetização", color: "#5a3480",
    questions: [
      { q: "O que exatamente a demo (Fase 1 completa) inclui e o que fica bloqueado?", why: "Precisa estar listado explicitamente: sistema de rivalidade está na demo? NPCs? Tutorial? Quanto mais rica a demo, maior a conversão — mas o jogo completo precisa justificar a compra.", decision: "Fase 1 completa com rivais introdutórios. Inclui tudo da Fase 1 — contratos, NPCs, construção — mais a primeira aparição do Arlindo e um evento rival simplificado. O jogador sente o loop completo. Para avançar à Fase 2, compra o jogo." },
      { q: "O unlock acontece dentro do app (IAP) ou redireciona para a loja?", why: "IAP in-app é mais fluido, mas Apple e Google ficam com 30%. Redirecionar para site próprio é mais trabalhoso, mas aumenta margem. Afeta o modelo de negócio diretamente.", decision: "IAP in-app no iOS (obrigatório por política da Apple), loja própria no Android (permitido desde 2022). Os dois canais em paralelo maximizam margem onde é possível sem violar regras onde não é." },
      { q: "Os DLCs serão IAPs ou produtos separados nas lojas?", why: "IAPs dentro do app são mais convenientes, mas exigem implementação técnica de conteúdo parcial. Produtos separados na loja são mais simples de gerenciar e descobrir por novos usuários.", decision: "IAPs para DLC de história e cosméticos (compra rápida, sem sair do jogo). Produto separado nas lojas para DLC de cenário — tem página própria, atrai novos jogadores organicamente e justifica vitrine independente." },
      { q: "Há plano de lançamento para PC (Steam) ou console além de mobile?", why: "A UI atual é desenhada para 480px (mobile). Uma versão Steam exige redesign de interface e precisa estar no roadmap desde o início para não ser um retrofit caro.", decision: "Mobile primeiro, Steam 6–12 meses depois. Lança mobile, valida com dados reais, usa a receita para financiar o redesign de UI para PC. A versão Steam é uma segunda janela de lançamento — com novo público e possibilidade de Next Fest." },
      { q: "O save na nuvem usa servidor próprio ou plataforma (Google Play / iCloud)?", why: "Servidor próprio dá controle total, mas exige backend. Google Play Games e iCloud são gratuitos e confiáveis, mas cada plataforma tem sua API. Afeta o escopo técnico do projeto.", decision: "Google Play + iCloud nativos por padrão (gratuito, sem backend), com opção de exportar o save como arquivo para migração manual entre plataformas. Cobre 95% dos casos sem custo de infraestrutura." },
      { q: "Suporte a múltiplos perfis de save por dispositivo?", why: "Importante para família compartilhando tablet — cada pessoa quer seu próprio progresso. Exige um sistema de seleção de perfil na tela de abertura, o que aumenta a complexidade de UX.", decision: "Sim, acessível pelo menu de configurações. Um perfil ativo por padrão — quem não precisa nunca vê. Criar ou trocar de perfil fica nas configurações. Remove fricção do fluxo principal sem sacrificar a funcionalidade." },
      { q: "O preço de R$ 19,90 é fixo ou varia por região/promoção?", why: "Preço regional (ex: preço menor na Índia ou em mercados emergentes) aumenta alcance global. Promoções de lançamento são estratégia de ranking. Precisa estar no plano de marketing.", decision: "Preço padrão global de US$ 3,99. Ajuste regional em mercados-chave: Brasil (referência local já definida), Índia e Sudeste Asiático. Promoção de 30% nas primeiras 2 semanas para impulsionar ranking inicial." },
      { q: "Updates pós-lançamento serão gratuitos ou pagos (além dos DLCs)?", why: "Bug fixes são sempre grátis, mas e o conteúdo novo? Definir isso protege a relação com o jogador e alinha expectativas desde o anúncio do jogo.", decision: "Bug fixes e balanceamento sempre gratuitos. Conteúdo novo substancial vai para DLC pago. Conteúdo pequeno (eventos sazonais extras, diálogos de NPCs) vai gratuito como goodwill. Linha clara entre manutenção e expansão." },
    ],
  },
  // ── GRUPOS EXTRAS ───────────────────────────────────────────────
  {
    icon: "🔄", label: "Loop", color: "#1a5a6b",
    questions: [
      { q: "O que acontece nos primeiros 30 segundos após abrir o app?", why: "A tela de entrada define o tom e a retomada de contexto. O jogador volta depois de horas ou dias — precisa entrar no estado mental certo rapidamente.", decision: "Boletim do Porto automático. Ao abrir, o jogo exibe resumo do último turno em 3 itens: navio chegado, ação rival, prazo urgente. Máximo 5 segundos de leitura, depois o mapa para tomar as decisões do turno atual." },
      { q: "Um 'dia de jogo' tem duração em tempo real definida?", why: "Se o jogo é turn-based, cada dia avança quando o jogador confirma. Não há relógio do mundo real correndo. Define o tom da sessão e o design de notificações.", decision: "Avanço por turno, sem relógio. Cada sessão é uma sequência de dias completos confirmados pelo jogador. Sessão típica: 10–20 min para tomar as decisões de 1 a 3 dias e fechar. Sem 1×/2×/½× — a unidade é o dia, não o minuto." },
      { q: "O loop de 'entrar → verificar → agir → sair' é suportado por notificações?", why: "Em jogo turn-based sem progressão offline, a notificação não pode criar urgência (nada está vencendo). Mas pode lembrar de voltar.", decision: "Push opcional, sem urgência. Desativado por padrão. Quando ativado, serve apenas como lembrete suave ('Faz 4 dias que você não visita o porto') — nunca como alerta de crise, pois nada acontece com o app fechado. Silêncio automático 23h–8h horário local." },
      { q: "O jogador pode ter perdas permanentes por desligar o app?", why: "Definir explicitamente: o jogo avança só quando o jogador joga. Sem isso, fica ambíguo se há ou não pressão temporal externa.", decision: "Sem progresso offline. App fechado = jogo pausado. Navios não chegam, contratos não vencem, rivais não agem enquanto o jogador está fora. A campanha avança exclusivamente quando o jogador joga — o que torna o tom 'convidativo, não pressionado' do mundo coerente com a mecânica." },
    ],
  },
  {
    icon: "🗺️", label: "Mapa", color: "#3a6b1a",
    questions: [
      { q: "O layout do porto usa grid ortogonal ou posicionamento livre?", why: "Grid é mais legível e simples de implementar — padrão em jogos mobile. Livre é mais orgânico, mas mais complexo de validar colisões. Define engine e tooling de level design.", decision: "Grid com snapping automático. Células de 64×64px na resolução base. Estruturas ocupam 1×1, 2×1 ou 2×2 células. Grid snapping automático ao arrastar construção." },
      { q: "Como funciona a expansão de área para a próxima fase?", why: "Expandir para a esquerda? Direita? Mar? Terra? A direção da expansão precisa ser consistente com a narrativa visual (porto crescendo) e com a câmera do jogo.", decision: "Expansão em L — cresce para a direita (terra) e para o sul (mar). F1: 8×6. F2: 12×8. F3: 16×10. F4: 20×12. F5: 24×14 + área estaleiro separada. O cais original do avô fica sempre no canto noroeste." },
      { q: "Existe altura (z-axis) no mapa ou é completamente 2D?", why: "Pixel art com perspectiva levemente isométrica permite z-ordering visual. Se há estruturas de múltiplos andares, o engine precisa suportar depth sorting.", decision: "2D com profundidade visual simulada por z-ordering — sem z-axis real. Godot 4 gerencia depth sorting via CanvasItem.z_index automaticamente: estruturas mais ao sul (perto do mar) renderizam na frente das mais ao norte (perto da cidade). Nenhuma estrutura tem múltiplos andares no MVP. A perspectiva é top-down leve (≈ 30°), não isométrica — elimina o custo de assets extras e garante legibilidade em telas de 4 a 7 polegadas." },
      { q: "Existe limite de construções por tipo ou só de espaço?", why: "Limitar 'só 2 gruas por fase' adiciona decisão estratégica. Limitar só por espaço deixa o jogador livre mas pode criar layouts ineficientes. Precisa de uma regra clara.", decision: "Limite por espaço para a maioria, com cap hard para estruturas que geram recursividade. Gruas, galpões, docas: limitadas só pelo espaço disponível. Exceções com cap hard por fase: Torre de Controle (1 total), Aduana (1 total), Estaleiro (1 total), Oficina Naval (máx. 2 por fase). A regra geral é liberdade de layout; as exceções evitam exploits de balanceamento sem necessidade de playtest extensivo." },
    ],
  },
  {
    icon: "🎓", label: "Tutorial", color: "#6b5a1a",
    questions: [
      { q: "O tutorial é integrado à campanha ou é uma sequência separada?", why: "Tutorial integrado (à la Hades) é mais fluido e imersivo. Tutorial separado é mais didático mas quebra a imersão inicial.", decision: "Tutorial integrado via Toninho nos primeiros 15 minutos de jogo. Toninho é o estivador-chefe veterano que estava no cais antes do protagonista nascer — apresenta os sistemas como se estivesse mostrando o porto para o herdeiro do amigo (Seu Maneco). 4 momentos curtos (~3–4 min cada), sem painel de instrução separado. Sr. Ribeiro entra como tutor financeiro depois da semana 4, junto da Parcela 1 — não no tutorial inicial." },
      { q: "Quais sistemas ficam fora do tutorial inicial?", why: "Mostrar tudo de uma vez é o maior erro de onboarding em management games. Precisa de sequência de introdução definida.", decision: "Tutorial inicial (Toninho, minutos 0–15) cobre o estritamente essencial: chegada e galpão (min 0–3), primeira decisão de custo com Zezão (min 3–7), aluguel de píer aos pescadores com Seu Biu (min 7–11), primeiro barco e apresentação da dívida (min 11–15). Tudo o mais (rivais, moral, leilões, espionagem via Bela, jornada noturna, hobbies) é introduzido progressivamente nas semanas seguintes — sempre dentro de evento narrativo. A primeira parcela ao Sr. Ribeiro na semana 4 é o gancho que apresenta o banco como sistema." },
      { q: "Como o jogador aprende que pode avançar o turno e quando?", why: "Em jogo turn-based, o jogador precisa entender que o tempo só passa quando ele confirma. Sem isso, fica esperando algo acontecer.", decision: "Coach mark forçado uma única vez, ativado por gatilho. No fim do minuto 15 (depois da apresentação da dívida por Dona Cida), o jogo destaca o botão 'Próximo dia' com seta pulsante + linha de Dona Cida: 'Chefia, quando o senhor terminar de decidir, é só avançar o dia.' O jogador toca, o dia avança e o tutorial some. Não se repete. Quem descobre antes (toca no botão por curiosidade) não vê o coach mark." },
    ],
  },
  {
    icon: "⭐", label: "Reputação", color: "#1a3a6b",
    questions: [
      { q: "A reputação é uma barra única ou tem subcategorias?", why: "Uma barra única é mais simples de balancear. Subcategorias permitem estratégias especializadas e leitura mais expressiva.", decision: "Três eixos visíveis e independentes — escala 0–100 cada. Reputação Comercial (clientes e contratos), Reputação Comunitária (cidade, pescadores, câmara), Reputação com a Imprensa (Bela). O jogador vê os três como medidores qualitativos: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. Setores internos não existem — a leitura é por eixo." },
      { q: "Quanto cada ação ganha ou perde? Há tabela de referência?", why: "Sem essa tabela, o balanceamento fica ad hoc. O designer precisa saber: cumprir contrato vale X? Falhar tira Y?", decision: "Tabela base por eixo, na escala 0–100. Cumprir contrato: +1 a +5 na Comercial (proporcional ao valor). Falhar: −3 a −8 na Comercial + −2 a −4 na Imprensa. Missão de NPC cumprida: +3 a +8 no eixo do NPC. Boato de rival ativo: −1 a −3/dia na Comercial. Demolir construção histórica: −5 fixo na Comunitária. Festa de São Pedro com presença: +3 a +6 na Comunitária. Mentira descoberta pela Bela: −15 a −30 na Imprensa de uma vez." },
      { q: "A reputação tem decaimento natural ao longo do tempo?", why: "Se sim, o jogador precisa agir constantemente. Se não, uma vez que atingiu alta, para de se preocupar.", decision: "Decaimento leve e contextual, por eixo. Sem atividade no eixo por 5 dias de jogo: −0,5/dia naquele eixo. Eventos negativos ativos (boato, contrato quebrado): −1/dia adicional enquanto vigentes. Teto de decaimento passivo: −10 pontos totais por eixo — nenhum eixo cai de 80 para 30 só por inatividade. A cidade não esquece, só começa a duvidar." },
      { q: "Como a reputação é exibida ao jogador?", why: "Uma barra clássica é intuitiva. Um título narrativo é mais imersivo mas menos legível. O HUD precisa ser decidido antes de qualquer asset de UI ser produzido.", decision: "Três medidores compactos no painel de status (acessível pelo HUD), cada um com título qualitativo + número 0–100. A mudança de faixa qualitativa é anunciada por linha de diálogo do NPC relevante (Dona Cida para Comercial, Seu Biu para Comunitária, Bela para Imprensa). Sem 'level up' visual — só uma linha de diálogo casual." },
      { q: "Interação entre os eixos — eles se influenciam?", why: "Eixos totalmente independentes parecem mecânicos. Eixos que interagem criam tensão estratégica.", decision: "Sim, com regras claras. Reputação com Bela alta + matéria positiva = +1 na Comercial por 2 semanas. Reputação Comunitária abaixo de 35 = Arlindo recruta funcionários com mais facilidade. Reputação Comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida. Mentira descoberta pela Bela = perda compartilhada (−10 na Imprensa, −5 na Comercial). Os eixos não somam — eles conversam." },
    ],
  },
  {
    icon: "🏁", label: "Finais", color: "#4a1a1a",
    questions: [
      { q: "Quais são exatamente os finais e o que os desbloqueia?", why: "A decisão do ato 3 (sessão pública na câmara) precisa ter condições claras para cada final. Sem isso, o escritor e o programador não sabem o que checar.", decision: "5 finais com condições qualitativas. Final A (Porto Unificado): aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Final B (Porto da Cidade): mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Final C (Sobrevivência Pura): terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. Final D (Venda ao Grupo Atlântico): aceitar proposta do Abutre no Ato 3. Final E (O Custo do Conhecimento, secreto): seguir fio da carga sem nota até o fim + revelar o contato interno do Atlântico para o Abutre + reputação comunitária abaixo de 40." },
      { q: "Existe um 'final ruim' além de vender ao Abutre?", why: "Final ruim por falência é diferente de vender por escolha. O primeiro é punição; o segundo é decisão narrativa. Os dois precisam ter cenas e sensações distintas.", decision: "O Final D (Venda) é a decisão consciente — cutscene digna se voluntária. A falência forçada por dívida não paga é um caminho narrativo separado (cascade de crise → Abutre oferece resgate → aceitar fecha o jogo de forma mais pesada). Não é tecnicamente um final novo, é o Final D ativado em condição de desespero, com cena mais curta." },
      { q: "O final é revelado somente ao terminar, ou o jogador tem previsão do que está construindo?", why: "Se o jogador não sabe que os finais alternativos existem, pode chegar à sessão sem as condições e ficar preso num final que não queria.", decision: "Pistas progressivas, nenhuma explica as condições completas. O Diário do Porto sugere caminhos via fragmentos. NPCs específicos (Toninho sobre o avô, Bela sobre Arlindo, Sr. Ribeiro sobre unificação) deixam dicas conforme reputação cresce. O Final E (secreto) nunca é insinuado por NPC — só pelo fio da carga sem nota. O jogo NUNCA revela 'quantos finais existem' — o jogador descobre jogando." },
      { q: "O Memorial do Avô é pré-requisito de qual final?", why: "Conceitos menciona que o Memorial completo é pré-requisito de um dos finais alternativos. Precisa estar amarrado.", decision: "Memorial completo (todas as peças descobertas + construção física) desbloqueia variação especial do Final B (Porto da Cidade). Em vez do epílogo padrão (cidade cinco anos depois), o jogador tem uma cena final em frente ao Memorial: Toninho conta o que aconteceu nos últimos meses do avô e entrega um único objeto guardado por 20 anos. O ciclo se fecha. Não é um final separado — é uma camada emocional adicional ao Final B." },
      { q: "Existe New Game Plus ou o jogo é single-playthrough?", why: "NG+ com conhecimento das escolhas é uma forma de recompra emocional. Pode ser simples (começa com recursos extras) ou complexo (novo arco). Decisão afeta o escopo.", decision: "Sem NG+ formal. O Diário do Porto fica acessível após o final com todos os fragmentos desbloqueados. O jogador pode reler a campanha inteira. Replayability vem dos 5 finais distintos, não de NG+." },
    ],
  },
];

// ── Decisões fechadas ────────────────────────────────────────────────
const DECISIONS = {
  gameplay: [
    { icon: "📋", title: "Cap de contratos",     summary: "Dinâmico por fase",           detail: "Fase 1: até 3 contratos simultâneos. Cresce até 8–10 na Fase 5. O limite desaparece junto com o crescimento do porto." },
    { icon: "👷", title: "Especialização",       summary: "Com penalidade de eficiência", detail: "Cada trabalhador tem função principal. Pode exercer outra com 30–40% menos eficiência. Estratégico sem ser irreversível." },
    { icon: "💛", title: "Trabalhadores",        summary: "Só moral — sem cansaço",       detail: "Moral sobe com bônus e promessas cumpridas, cai com exploração. Moral baixa = menor rendimento. Pode culminar em demissão." },
    { icon: "💰", title: "Fluxo de caixa",       summary: "Híbrido passivo + ativo",      detail: "Renda passiva semanal (píer, armazém) cobre custos fixos. Contratos entregam o lucro real. O passivo é o chão; o ativo é o teto." },
    { icon: "🏦", title: "Porto sem dinheiro",   summary: "3 camadas narrativas",         detail: "1. Sr. Ribeiro avisa — sem penalidade. 2. Vaga do píer penhorada. 3. Sr. Abutre faz oferta — aceitar é o único final ruim." },
    { icon: "⛈️", title: "Clima",                summary: "Existe, aviso de 1 dia",       detail: "Boletim avisa antes da tempestade. Efeitos: navios atrasam, guindaste para, prazos curtos em risco. Sem destruição de infra." },
    { icon: "🌙", title: "Dia e noite",          summary: "Custo e oportunidade",         detail: "Noite: hora extra, turismo e aduana fechados. Recompensa: navios especiais e missões narrativas exclusivos do período noturno." },
    { icon: "🔧", title: "Upgrades",             summary: "Clicando no objeto no mapa",   detail: "Clicar na estrutura abre o painel dela. Construções novas ficam no menu de construção geral. Cada objeto gerencia a si mesmo." },
  ],
  phases: [
    { icon: "📉", title: "Regressão de fase",    summary: "Parcial com trava",            detail: "Fase conquistada é permanente. Mas se a reputação cair abaixo do mínimo, contratos e clientes somem até ela se recuperar." },
    { icon: "📊", title: "Condições de avanço",  summary: "Simultâneas + painel claro",   detail: "As 3 barras correm em paralelo. Reputação, infraestrutura e missão narrativa avançam de forma independente. O avanço só ocorre quando as três estão ativas." },
    { icon: "⏳", title: "Limite de tempo",       summary: "Pressão narrativa, sem timer", detail: "Não há prazo rígido. Quanto mais tempo o jogador demora, mais o Sr. Abutre intensifica a pressão — urgência orgânica." },
    { icon: "🏚️", title: "Demolição",            summary: "Custo parcial (50%)",          detail: "Pode demolir qualquer construção, recuperando 50% dos recursos. Construções herdadas do avô custam mais — o jogo reconhece o valor sentimental." },
    { icon: "🏗️", title: "Upgrades vs. novas",  summary: "Ambos, com lógica clara",      detail: "Estruturas principais evoluem in-place até 3 níveis. Estruturas de expansão exigem espaço novo. Cada categoria tem sua regra." },
    { icon: "🏙️", title: "Porto Mirim",         summary: "Mecânica leve e passiva",      detail: "Cidade maior = mais trabalhadores no mercado. Alta temporada = renda passiva automática. Sem gestão ativa da cidade." },
    { icon: "📅", title: "Eventos sazonais",     summary: "Calendário fixo com aviso",    detail: "2–3 eventos por fase (Festa de São Pedro, alta temporada jan., vento sul ago.). Boletim avisa com antecedência." },
    { icon: "📖", title: "Diário do Porto",      summary: "Cápsula do tempo por fase",    detail: "Cada missão de virada de fase vai para o Diário com artefatos: fotos do porto, cartas de NPCs, manchetes do jornal local." },
  ],
  rivals: [
    { icon: "📡", title: "Aviso de ação rival", summary: "Proporcional ao Rivalômetro",  detail: "Baixo = sem aviso. Médio = sinal vago ('Arlindo está se movimentando...'). Crítico = aviso claro com janela de reação." },
    { icon: "🤝", title: "Aliança entre rivais",summary: "Evento narrativo único",        detail: "Cena exclusiva na transição para a Fase 4. O jogador pode impedir via missão com a Bela. Se não intervir, agem juntos por período limitado." },
    { icon: "💀", title: "Eliminação de rival", summary: "Narrativa, não mecânica",       detail: "Arlindo para de agir ativamente quando derrotado e pode virar aliado. Abutre nunca é eliminado — a corporação é grande demais." },
    { icon: "⚓", title: "Arco do Arlindo",     summary: "Aliado por escolha, com custo", detail: "Proposta de parceria após Fase 3. Aceitar = bônus permanentes + custo de reputação com NPCs desconfiantes. Recusar = rivalidade até a Fase 4." },
    { icon: "🔴", title: "Rivalômetro no HUD",  summary: "Aparece só após descoberta do rival",     detail: "No início do jogo, o Rivalômetro não existe no HUD. Os primeiros ataques de Arlindo parecem azar — contratos perdidos sem explicação, fornecedores que somem. Quando o jogador percebe o padrão e descobre que é Arlindo (gatilho narrativo, ~semana 3–4 do Ato 1, dependendo das ações), Toninho ou Bela apresentam o conceito de rivalidade e o ícone do Rivalômetro aparece pela primeira vez. A partir daí: ícone compacto por rival, muda de cor (verde → amarelo → vermelho). Tocar expande o painel completo. Sempre visível depois desse momento, nunca intrusivo." },
    { icon: "🤖", title: "IA dos rivais",       summary: "Script + gatilhos reativos",    detail: "Sequência base predefinida por fase. Comportamentos do jogador disparam reações cirúrgicas — ex: dominar leilões por 3 dias aciona campanha de boatos." },
    { icon: "🔍", title: "Espionagem via Bela", summary: "Missões pagas com a repórter",  detail: "A Bela pode ser contratada para investigar rivais por custo em reputação ou dinheiro. Retorna inteligência acionável. Disponível a partir da Fase 2." },
    { icon: "⚠️", title: "Crítico ignorado",    summary: "Escalada em 3 atos",            detail: "1º → rival fecha melhor contrato da semana. 2º → boato derruba reputação por 5 dias. 3º → evento narrativo obrigatório com penalidade permanente." },
  ],
  monetization: [
    { icon: "🎮", title: "Conteúdo da demo",    summary: "Fase 1 completa + rivais",      detail: "Demo inclui toda a Fase 1: contratos, NPCs, construção e a primeira aparição do Arlindo com evento rival simplificado. Avanço à Fase 2 exige compra." },
    { icon: "🔓", title: "Fluxo de unlock",     summary: "IAP iOS · loja própria Android", detail: "iOS: IAP in-app obrigatório. Android: canal próprio (permitido desde 2022). Os dois em paralelo maximizam margem sem violar regras." },
    { icon: "📦", title: "Distribuição de DLCs",summary: "IAP pequeno · produto grande",   detail: "DLC de história e cosméticos = IAP in-app. DLC de cenário = produto separado nas lojas — página própria, descoberta orgânica." },
    { icon: "🖥️", title: "Plataformas",         summary: "Mobile → Steam em 6–12 meses",  detail: "Lança mobile, valida com dados reais, financia redesign com a receita. Steam é segunda janela de lançamento com elegibilidade ao Next Fest." },
    { icon: "☁️", title: "Save na nuvem",       summary: "Nativo + exportação manual",     detail: "Google Play Games e iCloud nativos (gratuito, sem backend). Exportação de save como arquivo cobre migração entre plataformas." },
    { icon: "👤", title: "Múltiplos perfis",    summary: "Sim, nas configurações",         detail: "Um perfil ativo por padrão. Criar ou trocar perfil fica nas configurações — invisível para quem não precisa." },
    { icon: "💲", title: "Precificação",        summary: "US$ 3,99 · regional + promo",    detail: "Preço global US$ 3,99. Ajuste regional em Brasil, Índia e Sudeste Asiático. Promoção de 30% nas primeiras 2 semanas." },
    { icon: "🔄", title: "Updates",            summary: "Fixes grátis · DLC pago · mimos", detail: "Bug fixes sempre gratuitos. Conteúdo grande vai para DLC pago. Eventos extras e diálogos de NPCs vão gratuitos como goodwill." },
  ],
  loop: [
    { icon: "📰", title: "Boletim de abertura",   summary: "3 itens em ≤ 5 segundos",       detail: "Ao abrir o app, o jogo exibe o Boletim do Porto: resumo do dia anterior em 3 itens — navio chegado, ação rival, prazo urgente. O jogador lê e vai direto ao mapa para tomar as decisões do dia atual." },
    { icon: "📅", title: "Avanço por turno",       summary: "1 sessão = 1 ou mais dias",     detail: "Cada sessão é um conjunto de decisões diárias. O jogador confirma o avanço quando quiser; o jogo processa o dia e mostra o resultado. Não há relógio correndo — a unidade é o dia, não o minuto." },
    { icon: "⏱️", title: "Duração de sessão",      summary: "10–20 min típicos",             detail: "Tempo médio de uma sessão saudável. O jogador pode jogar todo dia ou uma vez por semana — o jogo não pune nem recompensa frequência. Pular dias avança o calendário só quando o jogador escolhe avançar." },
    { icon: "🔔", title: "Notificações push",       summary: "Só lembretes opcionais, sem urgência", detail: "Push é desativado por padrão. Quando ativado pelo jogador, serve apenas como lembrete suave ('Faz 4 dias que você não visita o porto') — nunca alerta de crise, pois nada acontece com o app fechado. Silêncio automático 23h–8h horário local." },
    { icon: "🔕", title: "Sem progresso offline",   summary: "App fechado = jogo pausado",    detail: "Porto não opera com o app fechado. Não há fila de navios queimando prazo, contrato vencendo ou rival agindo enquanto o jogador está fora. A campanha avança exclusivamente quando o jogador joga." },
  ],
  mapa: [
    { icon: "🔲", title: "Grid por fase",           summary: "8×6 → 24×14 em 5 fases",      detail: "F1: 8×6 (48 células). F2: 12×8. F3: 16×10. F4: 20×12. F5: 24×14 + área estaleiro separada. Expansão acontece automaticamente ao avançar de fase." },
    { icon: "↗️", title: "Direção de expansão",     summary: "Cresce à direita e ao sul",    detail: "Porto cresce para a direita (mais terra, mais cidade) e para o sul (mais mar, mais docas). O cais original do avô fica sempre no canto noroeste — âncora visual da narrativa." },
    { icon: "📐", title: "Tamanho das estruturas",  summary: "1×1, 2×1 ou 2×2 células",     detail: "Pequenas (grua, posto de guarda): 1×1. Médias (galpão, oficina): 2×1. Grandes (armazém, terminal): 2×2. Estaleiro: 3×2, único no mapa. Grid snapping automático." },
    { icon: "🎨", title: "Perspectiva visual",      summary: "Top-down 30°, z-ordering por y", detail: "2D com profundidade simulada — sem z-axis real. Godot 4 gerencia depth sorting via z_index automático: estruturas mais ao sul renderizam na frente. Perspectiva top-down leve (~30°), não isométrica. Sem estruturas de múltiplos andares no MVP." },
    { icon: "🚫", title: "Cap de construções",      summary: "Espaço livre + 4 exceções hard-capped", detail: "Maioria limitada só por espaço. Cap hard por fase: Torre de Controle (1 total), Aduana (1 total), Estaleiro (1 total), Oficina Naval (máx. 2). Evita exploits sem excesso de restrições artificiais." },
  ],
  tutorial: [
    { icon: "👴", title: "Guia: Toninho",            summary: "Tutorial integrado, 15 minutos", detail: "O estivador-chefe veterano — leal ao avô há 20 anos — recebe o herdeiro e apresenta o porto em 4 momentos curtos (≈3–4 min cada). Cada instrução é fala dele, no contexto. Sem painel de tutorial separado." },
    { icon: "📅", title: "4 momentos do onboarding", summary: "Minutos 0–15, sem painel",        detail: "Min 0–3: chegada e galpão (Toninho recebe). Min 3–7: primeira decisão de custo com Zezão (limpeza do galpão). Min 7–11: aluguel de píer aos pescadores liderados por Seu Biu (três valores possíveis). Min 11–15: primeiro barco + apresentação da dívida por Dona Cida + mapa abre pela primeira vez." },
    { icon: "🏦", title: "Sr. Ribeiro entra depois",  summary: "Semana 4 com a Parcela 1",       detail: "O banqueiro só aparece como NPC ativo na semana 4, quando vence a primeira parcela. Antes disso, é apenas mencionado em diálogo. Toninho cobre o onboarding inicial; Sr. Ribeiro cobre o sistema financeiro a partir do Ato 1." },
    { icon: "▶️", title: "Coach mark de 'Próximo dia'", summary: "Aparece 1 vez, no fim do tutorial", detail: "No fim do minuto 15, Dona Cida diz: 'Chefia, é só avançar o dia.' Botão 'Próximo dia' destacado com seta pulsante. O jogador toca, o dia avança, o tutorial some. Não se repete. Quem descobriu antes não vê o coach mark." },
    { icon: "📚", title: "Camadas avançadas sem painel", summary: "Cada sistema dentro de evento", detail: "Moral, jornada noturna, leilões competitivos, espionagem via Bela, hobbies, Diário, fotografias, eventos do setor — todos introduzidos progressivamente em semanas posteriores, sempre dentro de um evento narrativo que os torna relevantes. Sem 'unlock por nível'." },
  ],
  reputacao: [
    { icon: "🎯", title: "Três eixos visíveis",         summary: "Comercial · Comunitária · Imprensa, 0–100 cada", detail: "Três medidores independentes na escala 0–100. Cada um responde a tipos de ação diferentes. O jogador vê os três como descrições qualitativas: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. Sem setores invisíveis — a leitura é por eixo." },
    { icon: "⚓", title: "Eixo Comercial",              summary: "Define contratos disponíveis",         detail: "Afeta quais contratos chegam e a que preço. Acima de 60: clientes de frete regional aparecem. Acima de 80: contratos exclusivos de longa duração. Abaixo de 30: só contratos de baixo valor, Arlindo intercepta os bons. Aumenta com contratos cumpridos, estrutura mantida. Diminui com atrasos, reclamações públicas, carga avariada." },
    { icon: "🏘️", title: "Eixo Comunitário",           summary: "Define alianças e finais",              detail: "Afeta vaquinha, finais e voto da câmara. Acima de 70: vaquinha possível, Final A acessível com aliança Arlindo. Acima de 85: pescadores defendem o porto. Abaixo de 40: Final E disponível, Final B bloqueado. Aumenta com aluguel justo, Festa de São Pedro, defesa do mangue. Diminui com despejo, corrupção descoberta." },
    { icon: "📰", title: "Eixo Imprensa (Bela)",        summary: "Define cobertura e acesso a info",      detail: "Afeta cobertura semanal e acesso antecipado. Acima de 65: Bela avisa antes de publicar algo delicado. Acima de 80: compartilha pistas das investigações. Abaixo de 40: ela investiga o porto. Mentira descoberta reseta 15–30 pontos de uma vez." },
    { icon: "📋", title: "Tabela base de ganho/perda",  summary: "Escala proporcional 0–100",             detail: "Cumprir contrato: +1 a +5 Comercial. Falhar: −3 a −8 Comercial + −2 a −4 Imprensa. Missão NPC cumprida: +3 a +8 no eixo do NPC. Boato rival: −1 a −3/dia Comercial. Demolir histórica: −5 Comunitária. Festa de São Pedro: +3 a +6 Comunitária." },
    { icon: "📉", title: "Decaimento passivo leve",     summary: "−0,5/dia após 5 dias sem ação no eixo",  detail: "Cada eixo decai 0,5/dia se ficar 5+ dias sem ação relevante. Teto de decaimento passivo: −10 por eixo. Eventos negativos ativos adicionam −1/dia enquanto vigentes. A cidade duvida, mas não esquece." },
    { icon: "⚡", title: "Interação entre eixos",        summary: "Os eixos conversam, não somam",         detail: "Bela alta + matéria positiva = +1 Comercial por 2 sem. Comunitária <35 = Arlindo recruta funcionários mais fácil. Comercial <25 = Sr. Ribeiro recusa renegociar dívida. Mentira descoberta pela Bela = perda compartilhada Imprensa+Comercial." },
  ],
  finais: [
    { icon: "🤝", title: "Final A — Porto Unificado",  summary: "Aliança Arlindo + rep comunitária >70", detail: "Arlindo, sabendo que o Abutre o absorveria depois, une o Porto Farol ao Cais Mirim numa operação conjunta sob o nome do avô. Grupo Atlântico recua. Condições: aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Epílogo: Seu Biu na ponta do cais ao amanhecer." },
    { icon: "🌿", title: "Final B — Porto da Cidade",   summary: "Mangue defendido + vínculos altos",     detail: "Cais Mirim permanece independente. Câmara municipal vota contra o resort. Toninho conta o segredo do avô. Condições: mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Variação especial se Memorial completo: cena final em frente ao Memorial com objeto guardado por 20 anos. Epílogo: cidade cinco anos depois, pescadores ainda no píer." },
    { icon: "💼", title: "Final C — Sobrevivência Pura", summary: "Parcela paga, sem alianças, sem segredos", detail: "O cais sobrevive. O protagonista honrou a dívida. Mas Porto Mirim ficou igual. Condições: terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. Epílogo: sem cena especial. Cais em dia normal. Toninho varrendo o píer." },
    { icon: "⚠️", title: "Final D — Venda ao Atlântico", summary: "Aceitar proposta do Abutre",            detail: "O Cais Mirim vira terminal do Grupo Atlântico. Pescadores perdem as vagas. Toninho não aparece na cena final. Bela publica — manchete como epílogo. Dona Cida deixa o porto no dia seguinte. Disponível como decisão consciente no Ato 3 OU como resgate de desespero quando dívida alta + sem aliança comunitária (versão pesada, mais curta)." },
    { icon: "🔒", title: "Final E — Custo do Conhecimento", summary: "Secreto · Carga sem nota + rep < 40", detail: "Condições obrigatórias: seguir o fio da carga sem nota até o fim + revelar o contato interno do Grupo Atlântico para o Abutre em pessoa + reputação comunitária abaixo de 40. O Abutre usa a informação para purgar o contato e faz oferta melhorada. O jogador ganhou poder de negociação mas perdeu a cidade. Sem música na cena final. NPC algum insinua a existência deste final." },
    { icon: "💬", title: "Sinalização sem spoiler",     summary: "Pistas qualitativas, nenhuma explícita",  detail: "Pistas no Diário (fragmento da carta do avô para Final A), Bela (pergunta sobre Porto Farol quando Arlindo aliado), Sr. Ribeiro (menciona unificação ao se aproximar do Final A), Toninho (referências ao avô que apontam Final B). O Final E nunca é insinuado por NPC. O jogo NUNCA revela quantos finais existem — o jogador descobre jogando." },
    { icon: "📔", title: "Diário pós-final",            summary: "Sem NG+, memória completa",              detail: "Após qualquer final, o Diário do Porto fica acessível com todos os fragmentos desbloqueados. O jogador pode reler a campanha inteira. Replayability via 5 finais distintos." },
  ],
  economia: [
    { icon: "🏗️", title: "Custos de construção",   summary: "R$ 300 – R$ 15.000",           detail: "Galpão: R$ 300. Cais básico: R$ 500. Grua: R$ 800. Oficina naval: R$ 1.500. Doca extra: R$ 1.200. Armazém: R$ 2.500. Torre de Controle: R$ 4.000. Aduana: R$ 5.000. Terminal contêineres: R$ 8.000. Estaleiro: R$ 15.000." },
    { icon: "👷", title: "Salários semanais",       summary: "R$ 80 – R$ 250 / trabalhador (base)",  detail: "Tabela base por especialidade: Estivador R$ 80/sem. Guarda R$ 100/sem. Carpinteiro R$ 120/sem. Logística R$ 160/sem. Mecânico R$ 200/sem. Gerente R$ 250/sem. NPCs nomeados pagam acima da base por senioridade (ex.: Toninho R$ 210 como estivador-chefe, Marina R$ 180 como operadora especializada). Hora noturna: +40% sobre o base. Rescisão sem aviso: 2 semanas de salário." },
    { icon: "📋", title: "Valor de contratos",      summary: "R$ 80 → R$ 20.000",            detail: "Fase 1: R$ 80–300. Fase 2: R$ 300–800. Fase 3: R$ 800–2.000. Fase 4: R$ 2.000–6.000. Fase 5: R$ 6.000–20.000. Leilões: 1,5× teto da fase. Carga ilegal: 2× com risco de reputação." },
    { icon: "💰", title: "Renda passiva semanal",   summary: "R$ 150 – R$ 1.200 / semana",   detail: "Píer (pescadores): R$ 150 (F1) → R$ 600 (F5). Armazém alugado: R$ 300 (F2) → R$ 800 (F5). Alta temporada turística: +30% sobre passivo total. Manutenção de infra: ~5% do valor total/semana." },
    { icon: "🔄", title: "Demolição e recuperação", summary: "50% de retorno (herdadas: 30%)", detail: "Demolir qualquer construção recupera 50% do custo original. Construções herdadas do avô retornam apenas 30% — o jogo reflete o custo emocional de apagar a história." },
    { icon: "⚠️", title: "Multas e penalidades",    summary: "Referência de perdas",          detail: "Contrato quebrado: 20% do valor em multa + queda de reputação proporcional. Navio esperando >1 dia sem doca: −R$ 50/dia. Trabalhador demitido sem aviso: rescisão = 2 semanas de salário." },
    { icon: "💵", title: "Abertura de caixa",       summary: "R$ 600 → R$ 200 após limpeza", detail: "Caixa herdado: R$ 600. Limpeza obrigatória do galpão (semana 1): R$ 400. Caixa disponível para operar: R$ 200. Cenário extremo — qualquer custo extra não planejado nessa semana levaria à crise antes do primeiro barco. DECISÃO: nenhuma outra despesa obrigatória pode existir antes do primeiro barco ser docado. Mesmo no pior cenário, NÃO há game over imediato (alinhado com Conceitos): a sequência de proteção é Dona Cida avisa → Sr. Ribeiro entra → Abutre oferece resgate. A semana 1 tem margem mínima, não morte súbita." },
    { icon: "🏦", title: "Parcelas validadas",      summary: "R$ 8k / R$ 16k / R$ 24k",      detail: "Parcela 1 (sem. 4): R$ 8.000. Parcela 2 (sem. 8): R$ 16.000. Parcela 3 (sem. 12): R$ 24.000. Total: R$ 48.000. ⚠️ A marca 'VALIDADO por modelo de balanceamento (v1.0)' foi RETIRADA em 26/08/2026: o cenário base que a sustentava (2 barcos/sem) não paga nem a Parcela 1 — ver o card 'Margem operacional base'. Apenas a Parcela 1 foi revalidada, por medição em 2.000 partidas do Vertical Slice (vazão de ~13,6 contratos/sem, 8 turnos/sem): fecha com ~20% de folga. As Parcelas 2 e 3 seguem NÃO VERIFICADAS e dependem da vazão e dos valores de contrato das Fases 2 e 3. Ver docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md." },
    { icon: "📊", title: "Margem operacional base", summary: "~R$ 2.400/sem (Fase 1, corrigido)", detail: "CORRIGIDO em 26/08/2026 — o modelo anterior não fechava. Ele dizia: píer R$ 240 + contratos R$ 360 (2 barcos × R$ 180) = R$ 600, custos R$ 230, margem R$ 370/sem, e 4 semanas = R$ 1.480 — contra uma Parcela 1 de R$ 8.000. Faltava 5,4×. O erro não estava no valor do contrato (R$ 80–300 está certo) e sim na VAZÃO: 2 barcos por semana é pouco demais. Modelo corrigido e medido em 2.000 partidas: 8 turnos por semana, 2–3 docas, ~13,6 contratos/semana a R$ 184 médio = R$ 2.500 + píer R$ 240 − custos R$ 230/330 = ~R$ 2.400/sem. Em 4 semanas ≈ R$ 9.600, cobrindo a Parcela 1 com ~20% de folga. ATENÇÃO: as Parcelas 2 e 3 (R$ 16.000 e R$ 24.000) carregam a mesma aritmética não verificada — ver docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md." },
    { icon: "🚨", title: "Risco crítico da Parcela 3", summary: "Exige terceira fonte de renda", detail: "Sem armazém ativo desde a Fase 1, o cenário base não cobre a Parcela 3 (R$ 24.000). DECISÃO: o armazém deve estar disponível como fonte de renda passiva a partir da semana 2 (não semana 5 como era), gerando R$ 150/sem mínimo. Alternativa: reduzir Parcela 3 de R$ 24.000 para R$ 18.000. Uma das duas mudanças é obrigatória antes de codar a economia." },
    { icon: "🔴", title: "Cenário conservador",     summary: "Inviável — não fecha",          detail: "Píer R$ 0 (como o avô) + 1 barco/sem = margem operacional negativa. O jogo só funciona se o jogador cobrar aluguel E docar barcos regularmente. O tutorial deve deixar clara a consequência financeira de cada escolha de aluguel — não como punição, mas como consequência natural (Dona Cida comenta)." },
    { icon: "🟢", title: "Cenário otimista",        summary: "Píer R$ 80 + 3 barcos — folgado", detail: "Receita: R$ 480 (píer) + R$ 540 (3 barcos) = R$ 1.020/sem. Margem: R$ 790/sem. Caixa final semana 12: ~R$ 4.000+ após todas as parcelas. Deixa espaço para upgrades, construções e eventos adversos sem risco de falência. É o 'bom jogador' — não o esperado." },
  ],
};

// ── Seções do GDD ────────────────────────────────────────────────────
const sections = [
  {
    id: "gameplay", icon: "🎮", label: "Gameplay",
    title: "Sistema de Contratos & Tempo",
    intro: "Turnos diários — cada sessão avança o jogo em dias completos, no ritmo do jogador. Sem app aberto, nada acontece.",
    subsections: [
      { heading: "⏱️ Fluxo de tempo", items: [
        { name: "Avanço por turno", desc: "Cada sessão avança o jogo em dias completos. O jogador toma as decisões do dia — contratos, funcionários, construção, conversas — e confirma o avanço. O jogo processa os resultados e apresenta o que aconteceu. Nada acontece com o app fechado." },
        { name: "Duração de sessão", desc: "Sessão típica de 10 a 20 minutos: ler o que aconteceu, decidir e fechar. O jogo não pune quem joga uma vez por semana." },
        { name: "Sem velocidade variável", desc: "Não há 1×/2×/½× — não há relógio correndo. A unidade é o dia. Animações de processamento entre turnos podem ser puladas ou aceleradas, mas isso não afeta a economia do jogo." },
        { name: "Alertas no Boletim, não em push", desc: "Tudo o que o jogador precisa saber chega no Boletim do Porto na abertura do próximo turno. Push notifications são opcionais e só servem para lembrar de jogar, nunca para criar urgência fora do jogo." },
      ]},
      { heading: "📋 Sistema de contratos", items: [
        { name: "Contratos fixos", desc: "Sempre disponíveis na Bolsa do Porto. Prazo, carga e valor definidos. Aceitar ou recusar." },
        { name: "Contratos negociados", desc: "Clientes especiais propõem condições. Jogador pode contrapropor prazo ou bônus." },
        { name: "Leilões ocasionais", desc: "Contratos premium surgem toda semana. Rivais também fazem lances. Quem oferece melhor reputação + preço vence." },
        { name: "Penalidade por quebra", desc: "Contrato não cumprido = queda de reputação + multa. Reincidência afasta clientes." },
      ]},
      { heading: "⚙️ Decisões táticas", items: [
        { name: "Alocação de trabalhadores", desc: "Distribuir equipes entre carga, reparo de barcos e construção." },
        { name: "Prioridade de doca", desc: "Qual navio entra primeiro quando há fila? O jogador decide." },
        { name: "Aceitação de risco", desc: "Contratos de alta reputação têm prazos agressivos. Risco x recompensa." },
      ]},
      { heading: "🕹️ Loop de sessão — os 10 minutos típicos", items: [
        { name: "Abertura (0–1 min): o boletim do dia", desc: "O jogador abre o app e vê 3 itens: navio aguardando doca, ação rival pendente, prazo urgente. Nada mais. Decide se vai jogar 5 minutos ou 20." },
        { name: "Decisão principal (1–4 min): alocar e contratar", desc: "Verifica fila de barcos, aloca trabalhadores para as docagens mais vantajosas, aceita ou recusa o contrato em aberto desde ontem. Cada decisão leva 15–30 segundos. É aqui que mora 80% do engajamento da sessão." },
        { name: "Gestão rápida (4–7 min): checar, reagir, planejar", desc: "Abre a correspondência (1–2 cartas novas). Lê a matéria da Bela se saiu hoje. Vê se Arlindo fez algum movimento. Decide se vai ao Bar do Mané nessa noite — um tap, sem animação longa." },
        { name: "Gancho de saída (7–10 min): o que fica pendente", desc: "O jogo sempre deixa algo inacabado ao fechar: um contrato expira amanhã, uma carta que precisa de resposta, Toninho mencionou algo mas o jogador não teve tempo de checar o galpão. Esse gancho é o motivo do retorno no dia seguinte. Não é notificação push — é narrativa." },
        { name: "Sessão longa (20–40 min): mesma estrutura, mais profundidade", desc: "O jogador que tem mais tempo simplesmente vai mais longe: vai ao Bar do Mané, dedica um turno a hobby, lê todas as cartas, faz uma negociação de salário. O loop não muda de forma — escala em profundidade, não em obrigação." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "gameplay" },
    ],
  },
  {
    id: "phases", icon: "🏗️", label: "Fases",
    title: "Progressão & Desbloqueio",
    intro: "Cada fase exige metas de reputação + infraestrutura construída — mais uma missão narrativa de conclusão.",
    subsections: [
      { heading: "📈 Como subir de fase", items: [
        { name: "Reputação mínima", desc: "Cada fase exige um patamar de reputação atingido e mantido por 3 dias consecutivos." },
        { name: "Infraestrutura obrigatória", desc: "Certas construções precisam estar erguidas antes de avançar." },
        { name: "Missão narrativa", desc: "Uma cutscene + evento especial marca a virada de fase — ex: primeiro navio grande aportando." },
      ]},
      { heading: "🗺️ As 5 fases", phases: [
        { num: "01", name: "Trabalhador do Cais",      rep: "0 – 200",    infra: "Cais básico + 1 galpão",              unlock: "Contratos de pesca e pequenas cargas",                           visual: "Cais de madeira, barcos pequenos, 1 grua enferrujada",       city: "Porto Mirim tem 1 rua principal e mercado de peixe" },
        { num: "02", name: "Cais com Oficina",         rep: "200 – 600",  infra: "Oficina naval + 2 docas",             unlock: "Reparo de barcos, clientes regionais",                           visual: "Oficina, espaço para 2 navios, guindastes novos",            city: "Surgem novos estabelecimentos, calçadão na orla" },
        { num: "03", name: "Porto Regional",           rep: "600 – 1.400",infra: "Armazém + torre de controle",         unlock: "Rotas fixas, leilões regionais, rivais mais agressivos",         visual: "Píer ampliado, armazéns coloridos, placa oficial",           city: "Porto Mirim vira atração, turistas aparecem" },
        { num: "04", name: "Porto Nacional",           rep: "1.400 – 3.000",infra: "Terminal de contêineres + aduana", unlock: "Contratos nacionais, autoridade portuária, crise com Atlântico S.A.", visual: "Contêineres empilhados, navios cargueiros, heliponto", city: "Grua gigante vista de longe, novos bairros na cidade" },
        { num: "05", name: "Grande Porto + Estaleiro", rep: "3.000+",     infra: "Estaleiro completo + doca seca",      unlock: "Construção e reparo naval, rotas internacionais, final narrativo",visual: "Estaleiro imponente, navios em construção, farol renovado",  city: "Porto Mirim virou cidade portuária — aeroporto, hotelaria" },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "phases" },
    ],
  },
  {
    id: "rivals", icon: "⚔️", label: "Rivais",
    title: "Sistema de Rivalidade",
    intro: "A IA rival age continuamente. O jogador pode ignorar, reagir ou contra-atacar — cada escolha tem consequência.",
    subsections: [
      { heading: "🤖 Como a IA rival age", items: [
        { name: "Roubo de contratos", desc: "Rivais fazem lances em leilões e podem oferecer preços menores para atrair clientes fixos." },
        { name: "Boatos e reputação", desc: "Rivais podem espalhar rumores que reduzem sua reputação na cidade temporariamente." },
        { name: "Expansão territorial", desc: "Se o jogador demora a crescer, rivais constroem estruturas que bloqueiam rotas valiosas." },
        { name: "Escalada gradual", desc: "Capitão Arlindo age nas fases 1-3. Sr. Abutre (Atlântico S.A.) entra na fase 4 com poder corporativo." },
      ]},
      { heading: "🛡️ Como o jogador reage", items: [
        { name: "Intervenção em leilão", desc: "Ao detectar lance rival, jogador pode pausar e superar a oferta antes do prazo." },
        { name: "Contra-reputação", desc: "Missões com NPCs (ex: Bela a repórter) podem reverter boatos e gerar PR positivo." },
        { name: "Aliança estratégica", desc: "Certos rivais menores podem virar parceiros se o jogador os ajuda em momentos críticos." },
        { name: "Sabotagem passiva", desc: "Preços mais baixos e prazos mais curtos drenam a clientela rival sem confronto direto." },
      ]},
      { heading: "📊 Rivalômetro", items: [
        { name: "Medidor por rival", desc: "Cada rival tem uma barra de ameaça (baixa / média / crítica). Quanto mais ignora, mais cresce." },
        { name: "Eventos de crise", desc: "Quando a barra atinge crítico, surge um evento especial — ex: Arlindo compra o melhor contrato da semana." },
        { name: "Resolução narrativa", desc: "Cada rival tem um arco: derrotá-lo desbloqueia cenas e bônus permanentes." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "rivals" },
    ],
  },
  {
    id: "monetization", icon: "💰", label: "Monetização",
    title: "Modelo de Negócio",
    intro: "Compra única — sem energia, sem anúncios forçados, sem pay-to-win. O jogador paga uma vez e tem tudo.",
    subsections: [
      { heading: "🏷️ Estrutura de preço", items: [
        { name: "Preço base sugerido", desc: "R$ 19,90 / US$ 3,99 — competitivo para mobile premium." },
        { name: "Demo gratuita", desc: "Fase 1 completa grátis. Para avançar para a Fase 2, compra o jogo completo." },
        { name: "Sem assinatura", desc: "Pagamento único, acesso vitalício a todo o conteúdo lançado junto ao jogo." },
      ]},
      { heading: "📦 Expansões opcionais (DLC)", items: [
        { name: "DLC de história", desc: "Arcos extras de NPCs — ex: passado misterioso do Capitão Arlindo." },
        { name: "DLC de cenário", desc: "Nova cidade costeira com mecânicas únicas — ex: porto no Pantanal fluvial." },
        { name: "Pack cosmético", desc: "Skins de pixel art para construções e barcos. 100% opcional, sem impacto no jogo." },
        { name: "Edição de colecionador", desc: "Trilha sonora + artbook digital + itens cosméticos exclusivos por preço único." },
      ]},
      { heading: "✅ Princípios anti-frustração", items: [
        { name: "Sem energia limitada", desc: "Jogador nunca é bloqueado de jogar por falta de energia ou cooldown." },
        { name: "Sem anúncios", desc: "Zero anúncios — nem opcionais. A experiência é limpa do início ao fim." },
        { name: "Sem pay-to-win", desc: "Nenhum item vendável acelera o jogo ou dá vantagem sobre rivais." },
        { name: "Saves na nuvem", desc: "Progresso sincronizado entre dispositivos incluído sem custo adicional." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "monetization" },
    ],
  },
  // ── SEÇÕES EXTRAS ───────────────────────────────────────────────
  {
    id: "loop", icon: "🔄", label: "Loop",
    title: "Core Loop de Sessão",
    intro: "O que o jogador faz nos primeiros 5 minutos após abrir o app — e o que o faz voltar amanhã.",
    subsections: [
      { heading: "🌅 Fluxo de uma sessão típica", items: [
        { name: "1. Abertura — Boletim do Porto", desc: "O app exibe automaticamente o resumo do último turno em 3 itens: navio chegado, ação rival, prazo urgente. ≤ 5 segundos de leitura. Depois, mapa do dia atual." },
        { name: "2. Verificação — Estado do porto", desc: "O jogador vê quais navios estão na doca, quais trabalhadores estão ociosos, quais contratos estão ativos. Tudo visível sem abrir menus." },
        { name: "3. Decisão — Alocar e priorizar", desc: "Arrastar trabalhadores → definir prioridade de doca → aceitar ou rejeitar contratos da fila. A maioria das sessões termina aqui (5–10 min)." },
        { name: "4. Construção — Expandir quando necessário", desc: "Sessões mais longas (20–30 min) incluem decisões de infraestrutura: o que construir, o que demolir, o que fazer upgrade." },
        { name: "5. Narrativa — Missões e diálogos de NPCs", desc: "Quando disponível, o jogador interage com NPCs e toma decisões de missão. Acontece uma vez por semana de jogo, não em toda sessão." },
        { name: "6. Confirmar avanço — Fim do turno", desc: "Quando todas as decisões do dia foram tomadas, o jogador toca em 'Próximo dia'. O jogo processa o dia, mostra um resumo curto do que aconteceu e abre o próximo turno." },
      ]},
      { heading: "📱 Política de offline e sessão", items: [
        { name: "App fechado = jogo pausado", desc: "Nada acontece sem o jogador. Navios não chegam, contratos não vencem, rivais não agem enquanto o app está fora." },
        { name: "Contratos não têm relógio do mundo real", desc: "Prazo medido em dias de jogo. O dia só passa quando o jogador confirma o avanço — não quando o relógio do celular bate meia-noite." },
        { name: "Sessão curta é suportada", desc: "Uma sessão de 5 minutos — só verificar o Boletim, tomar 1–2 decisões e fechar — é válida e produtiva. O jogador pode avançar 1 dia e parar." },
      ]},
      { heading: "📅 A unidade é o dia, não o minuto", items: [
        { name: "Sem velocidade variável", desc: "Não há 1×/2×/½× — não há relógio correndo. O jogador toma as decisões do dia, confirma o avanço, e o jogo processa o resultado em 1–2 segundos de animação (pulável)." },
        { name: "Por que turn-based", desc: "Tempo real cria obrigação. O jogador que não abriu o app em dois dias volta para uma crise que não escolheu enfrentar. Isso vai contra o tom de Porto Mirim — uma cidade que convida, não que pressiona." },
        { name: "De onde vem a tensão", desc: "Não do relógio do celular — mas das parcelas ao banco e dos prazos das missões críticas, medidos em dias de jogo. Essa pressão é controlada pelo design, não pelo sistema operacional." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "loop" },
    ],
  },
  {
    id: "mapa", icon: "🗺️", label: "Mapa",
    title: "Mapa & Espaço",
    intro: "O porto é um grid que cresce para a direita e para o sul. O cais do avô fica sempre no canto noroeste.",
    subsections: [
      { heading: "🔲 Sistema de grid", items: [
        { name: "Célula base: 64×64px", desc: "Tamanho padrão de célula na resolução mobile base. Estruturas ocupam 1×1, 2×1 ou 2×2 células." },
        { name: "Grid snapping automático", desc: "Ao arrastar uma construção, ela encaixa automaticamente na célula mais próxima." },
        { name: "Estruturas têm tamanho fixo", desc: "Não é possível redimensionar construções. O tamanho é intrínseco ao tipo — não ao nível de upgrade." },
      ]},
      { heading: "📐 Expansão de área por fase", rows: [
        { label: "Fase 1 — Cais básico",   value: "8 × 6  (48 células)" },
        { label: "Fase 2 — Com oficina",   value: "12 × 8  (96 células)" },
        { label: "Fase 3 — Porto regional",value: "16 × 10  (160 células)" },
        { label: "Fase 4 — Porto nacional",value: "20 × 12  (240 células)" },
        { label: "Fase 5 — Grande porto",  value: "24 × 14  (336 células) + área estaleiro separada" },
      ]},
      { heading: "🏗️ Regras de construção e layout", items: [
        { name: "Expansão em L (direita + sul)", desc: "Porto cresce para a direita (terra, cidade) e para o sul (mar, docas). O eixo narrativo é sempre o mesmo." },
        { name: "Âncora visual: cais do avô", desc: "O cais original herdado fica fixo no canto noroeste. Remover custa mais recursos — mecânica de valor sentimental." },
        { name: "Estruturas únicas por mapa", desc: "Torre de Controle, Aduana e Estaleiro: máximo 1 cada por mapa. Reforçam marcos de progressão." },
        { name: "Sobreposição proibida", desc: "Nenhuma estrutura pode ser colocada em célula ocupada — inclusive área de água e área de cidade (fora dos limites do porto)." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "mapa" },
    ],
  },
  {
    id: "tutorial", icon: "🎓", label: "Tutorial",
    title: "Tutorial & Onboarding",
    intro: "Toninho recebe o jogador nos primeiros 15 minutos. 4 momentos curtos, sem painel separado. Sr. Ribeiro entra depois, com a Parcela 1.",
    subsections: [
      { heading: "🎓 Filosofia de onboarding", items: [
        { name: "Integrado à narrativa, não separado", desc: "O tutorial é a chegada do herdeiro ao porto. Toninho — o estivador-chefe que estava no cais antes do protagonista nascer — apresenta o lugar como se estivesse mostrando para o neto do amigo. Cada instrução é fala dele, contextualizada no mundo do jogo." },
        { name: "Nenhuma tela de tutorial separada", desc: "Não existe 'tutorial mode'. O jogador aprende fazendo, no porto, nos primeiros 15 minutos. Nenhum painel sobreposto, nenhuma seta pulsante em cada botão." },
        { name: "Camadas avançadas chegam depois", desc: "Rivais aparecem progressivamente nas semanas 3–6. Moral, jornada noturna, leilões, espionagem e hobbies são introduzidos quando se tornam relevantes — sempre dentro de um evento narrativo." },
      ]},
      { heading: "📅 Os 4 momentos do onboarding (minutos 0–15)", items: [
        { name: "Minutos 0–3 — A chegada (Toninho)", desc: "O jogador chega ao cais. Toninho espera na entrada e explica em duas linhas: 'Seu Maneco deixou tudo pra você. Inclusive as dívidas.' Primeira ação: clicar no galpão velho. Sem tutorial explica o clique — o galpão pisca. Quem não clica em 10s recebe um empurrão gentil de Toninho." },
        { name: "Minutos 3–7 — A primeira decisão (Zezão)", desc: "Zezão aparece sem ser chamado. Inspeciona o galpão. Diz que precisa de limpeza: R$ 400 e dois dias. O jogador tem R$ 600. Aceitar ou esperar é a primeira decisão com custo real. Dona Cida comenta a consequência financeira de qualquer escolha." },
        { name: "Minutos 7–11 — Os pescadores (Seu Biu)", desc: "Seu Biu aparece com dois pescadores para 'renovar o trato com o novo dono.' O avô nunca cobrou. O jogador escolhe entre 3 valores de aluguel (R$ 0, R$ 40, R$ 80 por vaga). Cada opção tem reação visível de Seu Biu. Sem explicar que afeta a reputação comunitária." },
        { name: "Minutos 11–15 — O primeiro barco e a dívida", desc: "Um barco de passagem aparece. Esse é a primeira mecânica com pressão — mas baixa: traz só R$ 150. Ao final, Dona Cida apresenta a dívida (3 parcelas em 12 semanas) e o mapa do porto abre pela primeira vez. O jogo começa." },
      ]},
      { heading: "🏦 Sr. Ribeiro como tutor financeiro (entra na semana 4)", items: [
        { name: "Sr. Ribeiro não está no onboarding inicial", desc: "Ele é mencionado por Dona Cida na apresentação da dívida, mas só aparece em pessoa na semana 4, quando vence a Parcela 1. Aí introduz os sistemas financeiros (empréstimos, investimentos) progressivamente, como tutor secundário." },
        { name: "Banco como sistema é desbloqueado com a Parcela 1", desc: "Antes da semana 4, o jogador só interage com a dívida via Dona Cida. Empréstimos voluntários, linhas de crédito e investimentos só ficam disponíveis depois da primeira parcela paga (ou perdida) — quando o jogador já entendeu a dor." },
      ]},
      { heading: "▶️ Coach mark de 'Próximo dia' — 1 vez", items: [
        { name: "Aparece no fim do tutorial (min 15)", desc: "Depois da apresentação da dívida, Dona Cida diz: 'Chefia, quando o senhor terminar de decidir, é só avançar o dia.' O botão 'Próximo dia' fica destacado com seta pulsante." },
        { name: "Não se repete", desc: "O jogador toca, o dia avança, o coach mark some. Quem descobriu antes (tocou no botão por curiosidade) não vê o coach mark — o sistema checa se o botão já foi usado." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "tutorial" },
    ],
  },
  {
    id: "npcs", icon: "👥", label: "NPCs",
    title: "Elenco & Fichas de Personagens",
    intro: "Cada NPC tem papel mecânico definido, momento de entrada e custo de ignorar.",
    subsections: [
      { heading: "🏠 Equipe do porto (sempre presentes)", npcs: [
        { name: "Dona Cida — Contadora", role: "Presente desde o dia 1 · Insubstituível", personality: "Pragmática, brava, leal. Conhece cada centavo do negócio. Moral alta = avisa sobre contratos ruins antes de assinar. Moral baixa = faz o mínimo e para de dar alertas.", humor: '"O cais tá no vermelho, chefia. Mas que vermelho bonito..."' },
        { name: "Zezão — Mestre de obras / Mecânico", role: "Desbloqueado na Fase 1 · Especialidade: construção e reparo", personality: "Forte, preguiçoso quando quer, gênio quando precisa. Fala pouco. Se leal e com moral alta: conserta estrutura danificada pela tempestade antes de avisar. Se mal tratado: 'consertou' mas o problema volta em 3 dias.", humor: '"Conserto qualquer coisa. Menos gente."' },
        { name: "Toninho Barros — Estivador-chefe", role: "Veterano de 20 anos com o avô · Lealdade altíssima", personality: "Leal por herança afetiva. Cobre erros do jogador em silêncio quando leal. Tem uma missão opcional em que conta o que realmente aconteceu nos últimos meses de vida do Seu Maneco — algo que ninguém mais sabe.", humor: '"Trabalhei pra Seu Maneco vinte anos. Vou te dar seis meses de desconto." — Toninho' },
      ]},
      { heading: "🆕 Equipe contratável (aparecem ao longo do jogo)", npcs: [
        { name: "Kinha Ferreira — Mecânica de embarcações", role: "Disponível na Fase 2 · R$ 200/sem · Especialidade: motores e cascos", personality: "Filha de pescador, autodidata. Competente demais pro salário. Sabe disso. Lealdade alta: conserta motor à meia-noite sem cobrar extra. Lealdade baixa: faz só o mínimo e o barco quebra na hora errada.", humor: '"Eu sei o que esse motor vale. Só quero saber se você sabe também."' },
        { name: "Carol Viana — Logística e administrativa", role: "Disponível na Fase 2 · R$ 160/sem · Especialidade: contratos e planilhas", personality: "Nova no porto, eficiente, ambiciosa. Ainda decidindo se fica. Lealdade > 60: traz planilha que economiza 15% nos custos. Lealdade < 35 em 3 meses: pede demissão — leva o conhecimento dos contratos.", humor: '"Eu tenho outras propostas. Só estou esperando ver o que isso aqui vira."' },
        { name: "Seu Biu — Vigia noturno", role: "Disponível desde a Fase 1 · R$ 120/sem · Especialidade: segurança noturna", personality: "18 meses no porto. Conhece tudo, fala pouco. Lealdade além do que qualquer bônus explica. Lealdade > 85: acorda o jogador quando suspeito entra no cais à noite.", humor: '"Essa noite tava estranha. Mas eu só vigio. Não investigo."' },
      ]},
      { heading: "🌆 NPCs da cidade (externos ao porto)", npcs: [
        { name: "Sr. Ribeiro — Gerente do Banco de Porto Mirim", role: "Antagonista gentil · Tutor do tutorial · Agente de pressão econômica", personality: "Foi amigo do avô. Paciente no início, formal conforme os atrasos crescem. A dívida tem um rosto — e o rosto é simpático, o que torna mais difícil de ignorar.", humor: '"O senhor tem até sexta. Isso não é ameaça — é matemática."' },
        { name: "Bela — Repórter / Aliada opcional", role: "Disponível desde a Fase 1 · Pode ser aliada ou adversária", personality: "Investigativa, idealista. Expõe corrupção. Publicamente não pode ser comprada — e a cena de rejeição existe. Relação boa: avisa antes de publicar algo delicado. Relação ruim: ela investiga o porto do protagonista também.", humor: '"Não faz nada que não queira ver na manchete."' },
      ]},
      { heading: "⚔️ Rivais e antagonistas", npcs: [
        { name: "Capitão Arlindo — Dono do Porto Farol", role: "Rival local · Ativo nas Fases 1–3 · Pode virar aliado", personality: "Simpático na superfície, competitivo por baixo. Tem contatos políticos. Não sabe que é fantoche do Grupo Atlântico — e essa ignorância é sua vulnerabilidade. Se o jogador revelar a verdade, pode virar aliado improvável.", humor: '"Que bom te ver crescer, sobrinho. É mais fácil de acompanhar."' },
        { name: "Sr. Abutre — Grupo Atlântico S.A.", role: "Antagonista principal · Entra na Fase 4 · Não é eliminável", personality: "Educado, implacável. Nunca ameaça diretamente — só apresenta propostas que ficam cada vez melhores enquanto o jogador fica cada vez mais pressionado. A corporação é grande demais para ser 'derrotada'; o final narrativo resolve isso.", humor: '"Tenho admiração pela sua teimosia. Ela tem prazo de validade."' },
      ]},
    ],
  },
  {
    id: "reputacao", icon: "⭐", label: "Reputação",
    title: "Sistema de Reputação",
    intro: "Três eixos independentes — Comercial, Comunitária e Imprensa. Cada um na escala 0–100, com leitura qualitativa para o jogador.",
    subsections: [
      { heading: "⭐ Como a reputação funciona", items: [
        { name: "Três eixos independentes", desc: "O jogador vê três medidores: Comercial (afeta contratos e clientes), Comunitária (afeta cidade e finais), Imprensa (afeta cobertura da Bela). Eles não somam — conversam." },
        { name: "Escala 0–100 em cada eixo", desc: "O número existe para cálculos. O jogador lê como faixa qualitativa: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. A mudança de faixa é anunciada por linha de diálogo do NPC relevante." },
        { name: "Reputação define quem te procura", desc: "Clientes premium aparecem em Comercial 80+. Vaquinha desbloqueada em Comunitária 70+. Bela compartilha pistas de investigação em Imprensa 80+." },
      ]},
      { heading: "⚓ Eixo Comercial — clientes e contratos", items: [
        { name: "0–30 — Cais marginal", desc: "Só contratos de baixo valor. Arlindo intercepta os bons. Sr. Ribeiro recusa renegociar dívida abaixo de 25." },
        { name: "31–60 — Porto funcional", desc: "Contratos regulares disponíveis. Clientes locais recorrentes." },
        { name: "61–80 — Porto respeitado", desc: "Clientes de frete regional aparecem. Negociação fica favorável ao jogador." },
        { name: "81–100 — Referência comercial", desc: "Contratos exclusivos de longa duração. Clientes corporativos. Atenção do Grupo Atlântico." },
      ]},
      { heading: "🏘️ Eixo Comunitário — cidade e câmara", items: [
        { name: "Abaixo de 40", desc: "Comunidade se afasta. Final E disponível, Final B bloqueado. Câmara não ouve o jogador no Ato 3." },
        { name: "70–84 — Vaquinha possível", desc: "Em crise de dívida, pescadores e Dona Cida iniciam vaquinha. Arrecadação proporcional à reputação. Câmara municipal começa a ouvir." },
        { name: "85+ — Cidade defende o porto", desc: "Pescadores defendem ativamente em eventos públicos. Câmara vota com o jogador. Final B disponível em condições plenas. Final A acessível com aliança Arlindo." },
      ]},
      { heading: "📰 Eixo Imprensa — Bela", items: [
        { name: "Abaixo de 40", desc: "Bela investiga o porto. Matérias negativas frequentes. Acima de 20 ainda há diálogo, abaixo de 20 ela publica negativo toda semana." },
        { name: "65+ — Aviso antecipado", desc: "Bela avisa antes de publicar algo delicado. Janela para o jogador agir." },
        { name: "80+ — Pistas de investigação", desc: "Bela compartilha pistas das três investigações independentes (origem do dinheiro do Atlântico, ligação de Arlindo com a prefeitura, dívidas reais do avô). Vira aliada narrativa." },
        { name: "Mentira descoberta", desc: "−15 a −30 pontos de uma vez. Recuperar leva semanas. Custo da disciplina honesta." },
      ]},
      { heading: "📊 Tabela base de ganho e perda", rows: [
        { label: "Cumprir contrato",            value: "+1 a +5 Comercial (proporcional ao valor)" },
        { label: "Falhar contrato",             value: "−3 a −8 Comercial + −2 a −4 Imprensa" },
        { label: "Boato de rival ativo",        value: "−1 a −3 / dia Comercial até resolver" },
        { label: "Missão de NPC cumprida",      value: "+3 a +8 no eixo do NPC (Comunitária ou Imprensa)" },
        { label: "Demolir construção histórica",value: "−5 fixo Comunitária" },
        { label: "Festa de São Pedro presente", value: "+3 a +6 Comunitária" },
        { label: "Carga ilegal descoberta",     value: "−5 a −15 Comercial + −5 a −10 Imprensa" },
        { label: "Promessa cumprida a NPC",     value: "+1 a +4 no eixo do NPC" },
        { label: "Promessa quebrada a NPC",     value: "−2 a −6 no eixo do NPC" },
        { label: "Mentira descoberta pela Bela",value: "−15 a −30 Imprensa + −5 Comercial" },
      ]},
      { heading: "⚡ Interação entre eixos", items: [
        { name: "Imprensa alta amplifica Comercial", desc: "Reputação com Bela alta + matéria positiva publicada = +1 na Comercial por duas semanas. A imprensa vira marketing orgânico." },
        { name: "Comunitária baixa enfraquece a equipe", desc: "Comunitária abaixo de 35 = Arlindo recruta funcionários do porto com mais facilidade. A cidade se afasta e os trabalhadores também." },
        { name: "Comercial baixa fecha o banco", desc: "Comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida. Sem opção financeira de emergência." },
        { name: "Os eixos não somam", desc: "Não existe 'reputação total'. Cada decisão e cada final lê os eixos relevantes separadamente. O jogador pode ser referência Comercial e Questionável Comunitário ao mesmo tempo — e isso conta." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "reputacao" },
    ],
  },
  {
    id: "finais", icon: "🏁", label: "Finais",
    title: "Condições de Final & Desfechos",
    intro: "Cinco finais com condições qualitativas — três positivos, um negativo, um secreto. O que o jogador construiu ao longo da campanha determina o que está disponível.",
    subsections: [
      { heading: "🏁 Os cinco finais", items: [
        { name: "Final A — Porto Unificado", desc: "Condições: aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Arlindo, sabendo que o Abutre o absorveria depois, une o Porto Farol ao Cais Mirim numa operação conjunta sob o nome do avô. O Grupo Atlântico recua. Epílogo: cena de Seu Biu na ponta do cais ao amanhecer. Ele não diz nada. Não precisa." },
        { name: "Final B — Porto da Cidade", desc: "Condições: mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Cais Mirim permanece independente. A câmara municipal vota contra o resort. Toninho conta o segredo do avô numa cena noturna no galpão. Epílogo: o jogador vê a cidade cinco anos depois — os pescadores do píer ainda estão lá. Variação se Memorial completo: cena adicional em frente ao Memorial." },
        { name: "Final C — Sobrevivência Pura", desc: "Condições: terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. O cais sobrevive. O protagonista honrou a dívida. Mas Porto Mirim ficou igual. Epílogo: sem cena especial. O jogo mostra o cais em dia normal de operação. Toninho varrendo o píer. Isso é tudo." },
        { name: "Final D — Venda ao Grupo Atlântico", desc: "Condições: aceitar a proposta do Abutre no Ato 3 (disponível quando dívida alta + sem aliança comunitária). O Cais Mirim vira terminal do Grupo Atlântico. Pescadores perdem as vagas. Toninho não aparece na cena final. Bela publica — o jogador lê a manchete como epílogo. Dona Cida deixa o porto no dia seguinte. Variação por desespero (cascade de falência → aceitar resgate do Abutre): mesma estrutura, cena mais curta e mais pesada, o avô não aparece, só o cais vazio." },
        { name: "Final E — O Custo do Conhecimento (secreto)", desc: "Condições obrigatórias (todas): seguir o fio da carga sem nota até o fim + revelar o contato interno do Grupo Atlântico para o Abutre em pessoa + reputação comunitária abaixo de 40. O Abutre usa a informação para purgar o contato interno e faz oferta melhorada. O jogador ganhou poder de negociação mas perdeu a cidade. Sem música na cena final." },
      ]},
      { heading: "🕯️ Conexão com o Memorial do Avô", items: [
        { name: "Memorial completo desbloqueia variação do Final B", desc: "Não é um final separado. O jogador que descobriu todas as peças do Memorial e construiu a estrutura tem uma cena adicional no Final B: conversa com Toninho em frente ao memorial, ele entrega um único objeto guardado por 20 anos, o ciclo se fecha. Camada emocional adicional, não condição de novo final." },
        { name: "Memorial não é pré-requisito de outros finais", desc: "Memorial completo enriquece o Final B. Não afeta os Finais A, C, D ou E — eles permanecem acessíveis nas suas próprias condições, com ou sem Memorial." },
      ]},
      { heading: "📡 Como o jogo sinaliza os finais sem spoilar", items: [
        { name: "O Diário do Porto como mapa de caminhos", desc: "Fragmentos acumulados no Diário sugerem que há mais de um desfecho possível — sem descrevê-los. Quem leu tudo percebe. Quem não leu chega na câmara com o que construiu." },
        { name: "NPCs deixam pistas qualitativas, nunca números", desc: "Toninho menciona o avô em referências que apontam Final B. Bela pergunta sobre o Porto Farol quando Arlindo está como aliado (sugere Final A). Sr. Ribeiro fala em 'unificação' quando o jogador se aproxima do Final A. Nenhum NPC fala em pontos de reputação. O Final E nunca é insinuado por NPC algum." },
        { name: "O jogo NUNCA revela quantos finais existem", desc: "Sem painel de progresso de finais. Sem 'desbloqueado 2/5'. O jogador descobre o número total apenas relendo o Diário após a primeira campanha ou conversando com outros jogadores." },
      ]},
      { heading: "⚠️ Cascade de falência — como o jogo avisa que está indo mal", items: [
        { name: "Nível 1 — Sinal precoce (semanas antes do prazo)", desc: "Dona Cida comenta no início do dia: 'A margem tá ficando apertada, chefia.' Sr. Ribeiro envia carta 2 semanas antes da parcela. O HUD não muda ainda. Quem lê os diálogos sabe." },
        { name: "Nível 2 — Pressão visível (1 semana antes)", desc: "O contador de caixa no HUD muda de cor: verde → amarelo. Uma linha discreta aparece embaixo: 'Parcela em X dias'. Arlindo intensifica ações — o jogo acumula pressão de fora e de dentro ao mesmo tempo." },
        { name: "Nível 3 — Crise ativa (menos de 3 dias, caixa insuficiente)", desc: "HUD vira laranja. Sr. Ribeiro visita pessoalmente pela primeira vez. Dona Cida apresenta lista de cortes possíveis — o jogador pode demitir, cancelar construção, aceitar condições piores em contratos. A música diminui (ver Conceitos)." },
        { name: "Nível 4 — Oferta de resgate (caixa negativo)", desc: "O Abutre aparece com oferta de compra apresentada como 'parceria'. Aceitar neste momento ativa a variação pesada do Final D — diferente de escolher o Final D voluntariamente no Ato 3. A cutscene é mais curta e mais pesada." },
        { name: "Não existe game over imediato", desc: "O jogo nunca trava numa tela de 'você perdeu'. A falência é uma narrativa que o jogador entra de olhos abertos — sempre há um caminho ainda em aberto, mesmo que seja vender. O último recurso disponível antes da venda forçada é sempre visível." },
        { name: "Sem reinício forçado", desc: "Se o jogador aceitar a venda no nível 4, o Diário fica acessível. É um final, não um game over. Quem quiser jogar de novo cria um novo save — não é forçado." },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "finais" },
    ],
  },
  {
    id: "economia", icon: "📊", label: "Economia",
    title: "Tabela de Referência Econômica",
    intro: "Números de balanceamento iniciais validados por modelo semanal (v1.0). Todos sujeitos a ajuste pós-playtest — o propósito aqui é ter uma base comum entre designer e programador.",
    subsections: [
      { heading: "💵 Abertura de caixa — Semana 1", rows: [
        { label: "Caixa inicial (herança do avô)", value: "R$ 600" },
        { label: "Custo obrigatório — limpeza do galpão (sem. 1)", value: "R$ 400" },
        { label: "Caixa disponível após limpeza", value: "R$ 200 ⚠️" },
        { label: "Alerta de design", value: "Nenhum outro custo pode ser obrigatório antes do 1º barco. R$ 200 não tem margem." },
      ]},
      { heading: "🏦 Dívida — Parcelas ao Sr. Ribeiro", rows: [
        { label: "Parcela 1 — fim da Semana 4 (Ato 1)", value: "R$ 8.000" },
        { label: "Parcela 2 — fim da Semana 8 (Ato 2)", value: "R$ 16.000" },
        { label: "Parcela 3 — fim da Semana 12 (Ato 3)", value: "R$ 24.000" },
        { label: "Total da dívida", value: "R$ 48.000" },
        { label: "Ponto de ruptura", value: "Parcela 3 — a maior. Exige terceira fonte de renda ativa." },
      ]},
      { heading: "📊 Cenários de viabilidade — modelo 12 semanas", rows: [
        { label: "🔴 Conservador (píer R$ 0 + 1 barco/sem)", value: "INVIÁVEL — margem negativa" },
        { label: "🟡 Base (píer R$ 40/vaga + 2 barcos/sem)", value: "Viável — caixa final ~R$ 300 ⚠️" },
        { label: "🟢 Otimista (píer R$ 80/vaga + 3 barcos/sem)", value: "Folgado — caixa final ~R$ 4.000+" },
        { label: "Margem operacional semanal (cenário base)", value: "R$ 370 / semana" },
        { label: "Margem × 4 semanas (sem upgrades)", value: "R$ 1.480 — insuficiente para Parcela 3 isolado" },
      ]},
      { heading: "🚨 Riscos identificados & decisões obrigatórias", items: [
        { name: "RISCO CRÍTICO — Parcela 3 não fecha sem 3ª fonte de renda",
          desc: "O cenário base (píer + barcos) não cobre os R$ 24.000 da Parcela 3. DECISÃO OBRIGATÓRIA antes de codar: (A) disponibilizar armazém como renda passiva desde a semana 2 (R$ 150/sem mínimo) — não semana 5 como estava implícito no GDD — OU (B) reduzir a Parcela 3 de R$ 24.000 para R$ 18.000. Uma das duas é necessária. Ambas funcionam narrativamente." },
        { name: "RISCO MÉDIO — Semana 1 sem margem de erro",
          desc: "Caixa de R$ 200 após a limpeza do galpão. Qualquer custo extra não previsto no design nessa semana quebra o jogo antes de começar. Blindagem: garantir que Zezão não cobre nada além da limpeza, que não haja evento gerador de custo antes do 1º barco, e que o primeiro barco apareça na semana 1." },
        { name: "RISCO MÉDIO — Cenário conservador é matematicamente inviável",
          desc: "O jogador que escolher píer R$ 0 + docagem mínima entra em espiral. Isso é design intencional — as consequências das escolhas importam — mas o jogo precisa comunicar claramente (via Dona Cida) o impacto financeiro de cada decisão de aluguel. Sem esse feedback, o jogador se sente punido sem saber por quê." },
      ]},
      { heading: "✅ Recomendações de ajuste (pré-código)", items: [
        { name: "1. Armazém disponível como renda desde a semana 2",
          desc: "R$ 150/sem resolve o gap do cenário base e torna o jogo viável mesmo com 2 barcos/sem. Narrativamente: Zezão termina a limpeza e o armazém começa a receber pequenas cargas locais espontaneamente — sem nova missão necessária." },
        { name: "2. Aviso de Sr. Ribeiro 2 semanas antes de cada parcela",
          desc: "O GDD já prevê isso. É essencial para o jogador planejar, não só reagir. Implementar como evento fixo no calendário de semanas 2, 6 e 10 — não como push notification, mas como diálogo em jogo." },
        { name: "3. Tutorial deve mostrar impacto financeiro de cada aluguel de píer",
          desc: "Dona Cida comenta o valor escolhido com ironia calibrada (já previsto no GDD). Incluir explicitamente a projeção semanal: 'Com R$ 40 por vaga, o píer rende R$ 240 por semana. Com R$ 0, rende zero.' Simples e suficiente." },
        { name: "4. Manter parcelas sem alteração se armazém for adiantado",
          desc: "Se a decisão for (A) — armazém na semana 2 — as parcelas de R$ 8k/16k/24k permanecem. Elas criam a tensão dramática correta e são atingíveis. Se a decisão for (B) — reduzir Parcela 3 — considerar R$ 18.000 como valor alternativo." },
      ]},
      { heading: "🏗️ Custo de construção (referência inicial)", rows: [
        { label: "Galpão pequeno",          value: "R$ 300" },
        { label: "Cais básico",             value: "R$ 500" },
        { label: "Grua básica",             value: "R$ 800" },
        { label: "Doca extra",              value: "R$ 1.200" },
        { label: "Oficina naval",           value: "R$ 1.500" },
        { label: "Armazém",                 value: "R$ 2.500" },
        { label: "Torre de Controle",       value: "R$ 4.000" },
        { label: "Aduana",                  value: "R$ 5.000" },
        { label: "Terminal de contêineres", value: "R$ 8.000" },
        { label: "Estaleiro completo",      value: "R$ 15.000" },
      ]},
      { heading: "👷 Salários semanais — tabela base por especialidade", rows: [
        { label: "Estivador básico (entrada)",  value: "R$ 80 / sem" },
        { label: "Carpinteiro naval (entrada)", value: "R$ 120 / sem" },
        { label: "Guarda noturno (entrada)",    value: "R$ 100 / sem" },
        { label: "Logística administrativa",    value: "R$ 160 / sem" },
        { label: "Mecânico naval",              value: "R$ 200 / sem" },
        { label: "Gerente / Contadora",         value: "R$ 250 / sem" },
        { label: "Hora noturna (add-on)",       value: "+40% sobre o salário base" },
        { label: "Rescisão sem aviso",          value: "2 semanas de salário" },
      ]},
      { heading: "👤 Salários dos NPCs nomeados (com senioridade)", rows: [
        { label: "Toninho — Estivador-chefe",   value: "R$ 210 / sem (base + 162% por 20 anos no porto)" },
        { label: "Marina — Operadora de guindaste", value: "R$ 180 / sem (especialização)" },
        { label: "Carol — Logística",           value: "R$ 160 / sem (base)" },
        { label: "Kinha — Mecânica → Chefe de manutenção", value: "R$ 200 / sem (F2-F3) → negociável a R$ 280+ na F3 quando promovida" },
        { label: "Seu Biu — Vigia noturno (contratado)", value: "R$ 120 / sem (base + 20%, pela permanência e confiança)" },
        { label: "Dona Cida — Gerente / Contadora", value: "R$ 250 / sem (base — função única)" },
        { label: "Nota: NPCs aceitam negociação", value: "Salários acima da base refletem experiência. Pagar abaixo da expectativa cai a lealdade." },
      ]},
      { heading: "📋 Faixa de valor de contratos por fase", rows: [
        { label: "Fase 1",              value: "R$ 80 – R$ 300 por contrato" },
        { label: "Fase 2",              value: "R$ 300 – R$ 800" },
        { label: "Fase 3",              value: "R$ 800 – R$ 2.000" },
        { label: "Fase 4",              value: "R$ 2.000 – R$ 6.000" },
        { label: "Fase 5",              value: "R$ 6.000 – R$ 20.000" },
        { label: "Leilões (premium)",   value: "1,5× o teto da fase vigente" },
        { label: "Carga ilegal",        value: "2× com risco de reputação se descoberto" },
      ]},
      { heading: "💰 Renda passiva semanal estimada", rows: [
        { label: "Píer — aluguel pescadores (F1)", value: "R$ 150 / sem (base: 6 vagas × R$ 40)" },
        { label: "Píer — aluguel pescadores (F5)", value: "R$ 600 / sem" },
        { label: "Armazém (disponível sem. 2+)",   value: "R$ 150 / sem mínimo ← DECISÃO v1.0" },
        { label: "Armazém alugado (F2+)",          value: "R$ 300 / sem" },
        { label: "Armazém alugado (F5)",           value: "R$ 800 / sem" },
        { label: "Bônus alta temporada turística", value: "+30% sobre toda a renda passiva" },
        { label: "Manutenção de infra",            value: "~5% do valor total das construções / sem (~R$ 30 na F1)" },
      ]},
      { heading: "✅ Decisões de design fechadas", decisions: "economia" },
    ],
  },
  {
    id: "gamefeel", icon: "✨", label: "Game Feel",
    title: "Feedback & Game Feel",
    intro: "Para cada ação do jogador: o que aparece na tela, o que toca, e o que o mundo faz. Sem isso, o jogo parece morto mesmo com arte boa.",
    subsections: [
      { heading: "🎯 Ações principais → resposta imediata", items: [
        { name: "Docagem concluída", desc: "Moedas voam da doca até o contador de caixa no HUD (animação de arco, 0.6s). Número verde sobe e dissolve (+R$ valor). SFX: dois tons ascendentes em terça maior (sino + cavaquinho). Nenhuma dessas animações bloqueia input — o jogo continua." },
        { name: "Contrato aceito", desc: "O rosto do cliente pisca satisfeito por 1 frame. Um ícone de documento aparece no HUD com o prazo. SFX: clique de madeira seco. Sem fanfarra — contratos são rotina, não conquista." },
        { name: "Construção iniciada", desc: "Zezão aparece no tile com animação de trabalho (martelo ou serrote, 4 frames em loop). Partículas de poeira saem do tile. SFX: som de construção em loop suave enquanto Zezão estiver trabalhando." },
        { name: "Construção concluída", desc: "Faíscas/confete por 1.5s no tile. Banner flutuante '✔ Pronto!' dissolve em 2s. SFX: sino final + zabumba 1 acorde. Versão ampliada se for marco de fase (ver transição de fase)." },
        { name: "Ação bloqueada / erro", desc: "Elemento que recebeu o tap faz shake de 3px por 0.3s. Borda vermelha flash 1 frame. SFX: tom descendente grave, madeira batendo, nunca agressivo. Nenhuma tela de erro — só o elemento sacudindo." },
        { name: "Rival age (Arlindo)", desc: "Ícone do Rivalômetro pulsa 3× no HUD. Linha discreta aparece no log do dia: '← Arlindo fechou o contrato da Praia Grande.' Sem animação dramática — a perda é notada, não dramatizada." },
      ]},
      { heading: "🔁 Feedback de estado (passivo, sem input)", items: [
        { name: "Estrutura com saúde baixa", desc: "Overlay progressivo: >70% normal, 30–70% rachaduras + dessaturação, <30% fumaçinha + ícone vermelho piscando no tile. Funciona como leitura visual antes de qualquer alerta de texto." },
        { name: "Funcionário ocioso", desc: "Sprite do funcionário faz idle alternado (cocôco a cabeça, mexe os pés) com ciclo mais lento. Não há indicador de texto 'sem tarefa' — a leitura é visual. Um funcionário parado parece parado." },
        { name: "Barco esperando fila", desc: "Balanço suave ±3px + fumaça de motor em idle. Timer visual com contagem regressiva aparece após 30s de espera. Se app estava fechado, barco volta na posição de idle sem timer — sem punição visual." },
        { name: "Caixa caindo (nível 2 em diante)", desc: "Contador de caixa muda de verde → amarelo → laranja conforme a cascade de falência. Não pisca — muda de cor progressivamente. O jogador percebe a degradação gradual, não um alarme binário." },
      ]},
      { heading: "🎬 Transições que têm peso", items: [
        { name: "Virada de fase", desc: "Flash branco 1 frame → porto ilumina da esquerda para a direita → 2–3 tiles novos aparecem → protagonista para e olha horizonte (idle especial 2s) → fade para tela estática 'Fase X — [nome]' com arte-chave. Duração total: 5–8s. Não pulável na primeira vez." },
        { name: "Abertura do app após ausência", desc: "Boletim do dia aparece sobre o porto com overlay semi-transparente. 3 itens máximo. O porto é visível ao fundo — o jogador está de volta ao espaço, não numa tela de menu." },
        { name: "Diálogo de NPC importante", desc: "Portrait box 96×96px aparece no canto inferior. Texto em fonte sans-serif (Inter ou Nunito OFL), 14px. Sem animação de entrada dramática — aparece rápido, como se o NPC simplesmente falasse. A pausa vem do conteúdo, não do efeito visual." },
      ]},
      { heading: "🔕 O que nunca acontece", items: [
        { name: "Sem números flutuando durante ações neutras", desc: "Números só flutuam quando há ganho ou perda real. Ações de organização (mover trabalhador sem contrato ativo, rotacionar estrutura) são silenciosas." },
        { name: "Sem tela de loading visível", desc: "Transições entre seções do porto usam fade rápido (<0.3s). Se o carregamento demorar mais, a tela do porto aparece primeiro e os elementos carregam progressivamente — nunca um spinner bloqueando tudo." },
        { name: "Sem confirmação dupla em ações reversíveis", desc: "Aceitar contrato: sem 'tem certeza?'. Alocar trabalhador: sem 'confirmar'. Só construção e demolição têm confirmação — e só porque têm custo econômico real e a demolição de construção herdada do avô tem custo narrativo permanente." },
      ]},
    ],
  },
  // ── SEÇÕES v5.5 — preenchimento de lacunas ─────────────────────────
  {
    id: "save", icon: "💾", label: "Save & Nuvem",
    title: "Save, Sincronização e Múltiplos Perfis",
    intro: "Política completa de save: slots, autosave, nuvem, conflitos e migração entre plataformas.",
    subsections: [
      { heading: "💾 Slots de save", items: [
        { name: "3 slots manuais + 1 autosave por perfil", desc: "Cada perfil tem até 3 slots manuais (nomeáveis pelo jogador) + 1 slot de autosave atualizado a cada fim de turno. O autosave nunca é sobrescrito pelo jogador manualmente — é segurança contra crash. Total: 4 saves visíveis por perfil." },
        { name: "Múltiplos perfis no mesmo dispositivo", desc: "Até 4 perfis ativos por dispositivo (cada um com seus 4 slots, 16 saves no total). Útil para família que compartilha tablet. Um perfil ativo por padrão; criar ou alternar perfil fica em Configurações." },
        { name: "Nome e timestamp visíveis", desc: "Cada save mostra: nome do porto, fase atual, semana de jogo, dinheiro em caixa, momento do salvamento (data real + 'Há 2 horas'). Tela de seleção de save é folha de calendário do porto — não lista de dados." },
      ]},
      { heading: "💿 Política de autosave", items: [
        { name: "Quando acontece", desc: "Após cada confirmação de 'Próximo dia'. Antes de eventos narrativos críticos (sessão da câmara, escolha de final). Ao fechar o app pelo botão 'Sair' do menu (não ao matar processo)." },
        { name: "Quando não acontece", desc: "Durante uma decisão ainda não confirmada. Em meio a uma animação de processamento. Durante leilão aberto (autosave só após o leilão fechar). Isso evita salvar estados parciais." },
        { name: "Recuperação de crash", desc: "Se o app fechar inesperadamente, ao reabrir o jogo oferece: 'Encontramos um turno interrompido. Restaurar do ponto antes do crash, ou começar o novo turno do zero?' O jogador escolhe — sem perda de progresso anterior ao turno." },
      ]},
      { heading: "☁️ Sincronização com a nuvem", items: [
        { name: "Google Play Games + iCloud nativos", desc: "Gratuito, sem backend próprio. Sincronização automática ao fechar cada sessão. Sem dependência de servidor proprietário — funciona mesmo se o estúdio parar de operar." },
        { name: "Resolução de conflito cloud vs local", desc: "Se houver conflito (jogador editou save local sem internet, depois sincroniza), o jogo apresenta os dois: 'Save local de 14h32 vs Save da nuvem de 09h15. Qual manter?'. Nunca sobrescreve automaticamente. Nunca soma — só substitui." },
        { name: "Backup manual e exportação", desc: "Configurações → Exportar Save → arquivo .brport-save compartilhável (e-mail, drive). Importação na mesma tela. Cobre migração entre plataformas (Android ↔ iOS) e backup para o jogador paranoico. Arquivo é texto JSON criptografado leve — não impede edição mas registra na carga (matérias da Bela podem mencionar 'algo estranho com os registros do porto')." },
      ]},
      { heading: "📱 Cross-device migration UX", items: [
        { name: "Mesma plataforma", desc: "Android → Android (mesma conta Google) ou iOS → iOS (mesma Apple ID): automático ao instalar e logar. Nenhuma ação do jogador necessária." },
        { name: "Plataforma diferente", desc: "Android → iOS ou vice-versa: o jogador exporta no dispositivo antigo (arquivo .brport-save), envia para si mesmo, importa no novo dispositivo. Tela de configurações tem botão grande 'Migrar para outro celular' com instruções passo a passo." },
        { name: "Mensagem padrão de segurança", desc: "Na tela de configurações: 'Seu progresso está salvo automaticamente na sua conta [Google Play / iCloud]. Você nunca precisa se preocupar em perder o porto.' Uma linha, sem jargão técnico." },
      ]},
    ],
  },
  {
    id: "onboarding_avancado", icon: "📚", label: "Onboarding Avançado",
    title: "Camadas Avançadas — Quando e Como Cada Sistema é Introduzido",
    intro: "O tutorial inicial cobre os 15 primeiros minutos. Estes são os gatilhos de cada sistema avançado introduzido depois.",
    subsections: [
      { heading: "🏦 Sistemas financeiros (semanas 3–6)", items: [
        { name: "Sr. Ribeiro e a Parcela 1 — semana 4", desc: "Primeira parcela vence. Sr. Ribeiro visita pessoalmente, apresenta a planilha de juros, abre o sistema de empréstimos voluntários como conselho ('Se precisar de fôlego'). A partir daqui, banco é sistema acessível pelo HUD." },
        { name: "Investimentos — semana 5–6, se caixa positivo", desc: "Dona Cida menciona que o caixa parado poderia render. Abre opção de Caderneta/CDB/Fundo. Aparece como diálogo casual, não menu novo." },
      ]},
      { heading: "⚔️ Rivalidade (semanas 3–5)", items: [
        { name: "Primeiro 'azar' — semana 2–3", desc: "Um contrato bom escapa por motivo sem explicação. Outro fornecedor some. O jogo não nomeia rivalidade ainda. Esse é o beat narrativo de desinformação." },
        { name: "A descoberta — semana 3–5", desc: "Toninho ou Bela conecta os pontos: 'Chefia, isso não é coincidência. É o Arlindo.' O Rivalômetro aparece no HUD pela primeira vez (ver Sistemas/Reputação). A partir daí o sistema é transparente." },
        { name: "Sr. Abutre — Fase 4 / Ato 3", desc: "Aparece em pessoa quando o porto cresce o suficiente para interessar ao Atlântico. Dra. Patrícia o antecede na Fase 2 com documentos. A pressão econômica do Atlântico é sentida antes — o homem em si só vem depois." },
      ]},
      { heading: "👷 Moral, lealdade e jornada noturna (Fase 2)", items: [
        { name: "Moral exposta na contratação do 3º funcionário", desc: "Quando o jogador chega ao limite da Fase 1 e tenta contratar o 4º, Dona Cida explica que precisa expandir primeiro — e que cada funcionário tem moral diária. Sistema visível a partir daí." },
        { name: "Jornada noturna — primeira escolha", desc: "Ao fim de uma tarde, aparece pela primeira vez a decisão: 'Vai dormir cedo ou ficar acordado essa noite?' Acompanha explicação curta de Seu Biu sobre o que pode acontecer à noite. Depois, é silencioso." },
      ]},
      { heading: "📰 Bela e espionagem (Fase 2)", items: [
        { name: "Primeira matéria que afeta o porto — semana 5–6", desc: "Bela publica algo que muda contrato (positivo ou negativo). O jogador percebe que ela existe como sistema, não só personagem. Acesso à ficha dela aparece no menu." },
        { name: "Espionagem disponível — Fase 2 final", desc: "Quando reputação com Bela > 50, ela menciona que aceita 'investigações por conta do porto'. Sistema de missões pagas via Bela é desbloqueado." },
      ]},
      { heading: "🎨 Hobbies, Diário, Fotografias, Casa (orgânico)", items: [
        { name: "Hobbies — desbloqueados ao entrar em casa pela primeira vez", desc: "Geralmente semana 1–2. Livros do avô na estante chamam atenção. Cada hobby tem ponto de entrada visual diferente (livro de gestão na escrivaninha, mapa náutico no quarto, etc.). Sem painel de hobbies — só objetos clicáveis." },
        { name: "Diário do Porto — sempre acessível desde o dia 1", desc: "Botão fixo no menu desde o início, mas o jogador raramente nota antes que apareça a primeira entrada automática (final do dia 1). A partir daí, o ícone tem ponto vermelho quando há entrada nova não lida." },
        { name: "Fotografias — desbloqueadas com câmera encontrada", desc: "A câmera do avô é encontrada na casa ~semana 2 (objeto interativo). Antes disso, fotos automáticas acontecem (polaroids de marco) mas o jogador não tira manualmente. Após achar a câmera, botão de foto aparece no HUD." },
      ]},
    ],
  },
  {
    id: "acessibilidade", icon: "♿", label: "Acessibilidade",
    title: "Acessibilidade & Localização",
    intro: "Como o jogo funciona para quem tem necessidades específicas — daltonismo, baixa visão, leitor de tela — e como a localização preserva a alma brasileira em outras línguas.",
    subsections: [
      { heading: "👁️ Visão e cor", items: [
        { name: "Daltonismo — sinais nunca dependem só de cor", desc: "Toda informação crítica codificada por cor é redundante por forma, ícone ou texto. Status verde/amarelo/vermelho (caixa, Rivalômetro, saúde de estrutura) sempre acompanhado de ícone distinto (✓ / ! / ✗). Modo daltônico opcional em Configurações ajusta paleta para deuteranopia, protanopia e tritanopia." },
        { name: "Tamanho de fonte ajustável", desc: "3 níveis: Pequena (padrão), Média (+25%), Grande (+50%). Aplicado em todos os textos do jogo, exceto títulos decorativos. Tela de configurações tem preview em tempo real." },
        { name: "Alto contraste opcional", desc: "Modo de alto contraste reforça bordas de UI e aumenta a saturação de elementos interativos. Pensado para baixa visão (não cegueira total)." },
      ]},
      { heading: "🦻 Leitor de tela e som", items: [
        { name: "Suporte a leitor de tela em menus", desc: "Todos os botões de UI, lista de contratos, ficha de NPC, configurações e diálogos suportam VoiceOver (iOS) e TalkBack (Android) via AccessibilityNode do Godot 4. Ordem de leitura: topo → baixo, esquerda → direita. Não cobre o mapa animado (fora de escopo do MVP)." },
        { name: "Legendas em todo áudio narrativo", desc: "Cutscenes, falas de NPCs e efeitos sonoros importantes (alerta de crise, chegada de navio) têm legenda opcional sempre que houver áudio. Ativadas por padrão em mercados com leitura forte de legenda." },
        { name: "Música e SFX independentes", desc: "Sliders separados para Música, Efeitos sonoros, Ambiente e Diálogos. Cada um de 0 a 100. Mute total possível em qualquer canal." },
      ]},
      { heading: "🌍 Localização — preservando a alma brasileira", items: [
        { name: "Estratégia: traduzir significado, preservar referente", desc: "Personagens mantêm nomes em português (Toninho, Seu Biu, Dona Cida, Bela, Zezão, Kinha) em todas as línguas — esses nomes são parte da identidade do mundo. Apelidos têm tradução cuidada: 'chefia' vira 'boss' em inglês mas com nota de intimidade respeitosa, não corporativa. Eventos culturais (Festa de São Pedro, Carnaval, baião, choro) têm glossário in-game acessível pelo HUD em ❓." },
        { name: "Hobby de idioma é separado da UI", desc: "O jogador pode jogar em inglês mas o protagonista, dentro da ficção, fala português como nativo. O hobby de idioma estrangeiro cobre inglês ou espanhol como segunda língua do personagem — independe da língua da interface." },
        { name: "Plataforma de tradução", desc: "Todos os textos do jogo em arquivos de localização (não hardcoded). Plataforma sugerida: Weblate ou Crowdin para gestão de tradutores voluntários e profissionais. Tokens como {portName} preservados em todas as traduções." },
        { name: "Idiomas MVP", desc: "Lançamento: EN-US + PT-BR simultâneos. Roadmap pós-lançamento: ES-LA, FR, DE, JA, ZH-CN — nessa ordem, conforme demanda da comunidade." },
      ]},
    ],
  },
  {
    id: "kpis", icon: "📊", label: "KPIs & QA",
    title: "Métricas de Sucesso, Plano de QA e Compliance",
    intro: "O que significa sucesso comercial, como o jogo é testado antes do lançamento, e como a privacidade do jogador é tratada.",
    subsections: [
      { heading: "🎯 KPIs de sucesso comercial", items: [
        { name: "Critério mínimo (sobrevivência)", desc: "5.000 cópias vendidas em 6 meses pós-lançamento. Cobre custos diretos de produção de um dev solo (~12 meses de trabalho). Sem isso, o projeto não se paga e o estúdio precisa repensar estratégia. Esse é o piso de não-falência." },
        { name: "Critério bom (continuidade)", desc: "20.000 cópias em 12 meses. Financia DLC de história + DLC de cenário e mantém o estúdio ativo. Justifica continuação do BR Port como franquia." },
        { name: "Critério excelente (escala)", desc: "50.000+ cópias em 12 meses. Permite contratação parcial (artista contratado, músico contratado), lançamento Steam ampliado e segundo título da casa. Esse é o cenário 'sucesso de público'." },
        { name: "Métricas de engajamento", desc: "D1 retention ≥ 40%. D7 ≥ 20%. D30 ≥ 10% (premium mobile, sem ads, retenção baixa é normal). Sessão média ≥ 12 min. Campanha completa em ≥ 30% dos jogadores que abrem mais de 3 vezes. Funil de conversão da demo: 8% mínimo (demo grátis → compra)." },
        { name: "Review score", desc: "Steam ≥ 85% positivo em 100+ reviews. App Store ≥ 4.3 estrelas. Google Play ≥ 4.2 estrelas. Reviews públicas são vetor crítico de descoberta orgânica em premium mobile." },
      ]},
      { heading: "🧪 Plano de QA pré-lançamento", items: [
        { name: "QA interno — designer + 2–3 voluntários", desc: "Durante toda a produção. Foco em: bugs bloqueadores, balanceamento por playtest, leitura de UX em devices reais. Cada build importante (fim de fase de produção) tem ciclo de 3–5 dias de teste antes de avançar." },
        { name: "Beta fechado — 50–100 testadores", desc: "3 meses antes do lançamento. Recrutados via mailing list e Discord. NDA leve (sem stream antes do release). Foco em: viabilidade do tutorial sem ajuda, retenção D1–D7 simulada, identificação de softlocks no Ato 3." },
        { name: "Beta aberto — 1 mês antes (opcional)", desc: "Decisão a tomar quando o jogo estiver pronto: vale mais o burburinho de beta aberto ou o impacto do lançamento surpresa? Depende de quanto polish foi conseguido até lá." },
        { name: "Devices de teste — lista mínima", desc: "iOS: iPhone SE (3ª geração), iPhone XR, iPhone 14. Android: Samsung A23 (3GB RAM), Samsung A53, Motorola G34 (mercado brasileiro popular). Mínimo cobre 80% do mercado-alvo. Cada release final testado em todos os 6 antes do envio às lojas." },
        { name: "Cronograma de QA vs release", desc: "Code freeze 4 semanas antes do release. 2 semanas de QA intensivo dedicado. 1 semana de soak test (jogo rodando 24h em loop com bot simulando ações). 1 semana de buffer para submissão às lojas (Apple costuma demorar 3–7 dias de aprovação)." },
      ]},
      { heading: "🔒 Compliance — LGPD e GDPR", items: [
        { name: "Política de privacidade explícita", desc: "Tela acessível em Configurações + link na loja. Descreve: que dados são coletados (sessão, crash reports, analytics opcional via Firebase), por quanto tempo são retidos, com quem são compartilhados (Firebase = Google), direitos do titular (deletar conta, exportar dados, opt-out)." },
        { name: "Opt-in para analytics", desc: "Na primeira abertura, o jogador escolhe se aceita compartilhar dados de uso anônimos. Default: opt-out. Sem analytics, o jogo funciona idêntico — o jogador não perde nada. Decisão revogável a qualquer momento em Configurações." },
        { name: "Sem coleta de dados pessoais por padrão", desc: "Nenhum dado pessoal (email, nome real, localização) é coletado para gameplay. Login com Google Play ou Apple ID é só para sincronização — nada é enviado para o estúdio. Dados de pagamento ficam exclusivamente nas plataformas." },
        { name: "LGPD (Brasil) e GDPR (UE)", desc: "Conformidade desde o lançamento. Política de privacidade em PT-BR e EN-US. Botão 'Solicitar exclusão de dados' em Configurações funcional desde o dia 1." },
        { name: "Sem coleta de dados de menores", desc: "Classificação etária 12+. Sem chat in-game, sem login social além de Google/Apple, sem coleta de dados que identifiquem menor de idade. Conforme COPPA (EUA) e LGPD (Brasil)." },
      ]},
    ],
  },
  {
    id: "pos_lancamento", icon: "🚀", label: "Pós-Lançamento",
    title: "Comunidade, DLCs e Roadmap de Conteúdo",
    intro: "O que acontece depois do lançamento: comunidade, atualizações, DLCs planejados e balanceamento de fases avançadas.",
    subsections: [
      { heading: "👥 Comunidade pré-lançamento", items: [
        { name: "Discord do estúdio — desde 6 meses antes", desc: "Servidor aberto desde o desenvolvimento. Devlog mensal. Canais: anúncios, feedback, sugestões de lore, fan art. O dev solo participa pessoalmente — pequenez é vantagem aqui." },
        { name: "Devlog público — Twitter + Bluesky + YouTube", desc: "Quinzenal. Mostra processo: balanceamento, design de NPCs, decisões difíceis. Constrói relacionamento com 'comprador antecipado'. Frequência menor que diário (queima ideias) mas regular o suficiente para manter relevância." },
        { name: "Mailing list", desc: "Inscrição na landing page do jogo. Newsletter mensal com 1 atualização e 1 curiosidade de design. Lista é o canal mais resiliente a mudanças de algoritmo de redes sociais." },
      ]},
      { heading: "🎪 Eventos de lançamento e descoberta", items: [
        { name: "Steam Next Fest", desc: "Versão demo do BR Port no festival mais próximo do lançamento Steam. Demo = Fase 1 completa + Arlindo introdutório (mesma demo do mobile premium). Stream do dev solo durante o festival." },
        { name: "BIG Festival (Brasil)", desc: "Submissão ao Brasil's Independent Games Festival. Reconhecimento local é vetor crítico para imprensa brasileira cobrir." },
        { name: "Cobertura editorial pré-lançamento", desc: "3 meses antes: envio de build de preview para curadores e jornalistas pré-selecionados (PC Gamer Brasil, IGN Brasil, Voxel, sites independentes de gestão como Strategy Gamer)." },
      ]},
      { heading: "📦 Roadmap de DLCs", items: [
        { name: "DLC 1 — 'Estações de Porto Mirim' (sazonais)", desc: "IAP in-app, ~R$ 8,00. Adiciona Carnaval (Fev), Festa de Iemanjá (Dez), Semana do Mar (Out) como eventos jogáveis com missões, NPCs visitantes e contratos sazonais únicos. Lançamento: 4 meses pós-game launch. Escopo: ~3 semanas de produção em arte + escrita." },
        { name: "DLC 2 — 'O Outro Cais' (cenário separado)", desc: "Produto independente nas lojas, ~R$ 15,00. Nova cidade litorânea (Praia do Engenho), 12 semanas, 4 NPCs principais novos, 3 finais próprios. Reutiliza ~70% dos sistemas, recompõe arte e narrativa. Lançamento: 9–12 meses pós-game launch. Escopo: ~3 meses de produção." },
        { name: "DLC 3 — 'O Avô e o Mar' (história prequel)", desc: "IAP in-app, ~R$ 10,00. 4 horas de campanha jogando Seu Maneco em 1985, antes da decisão de recusar o Atlântico. Foco narrativo, sistemas simplificados. Lançamento: 12–18 meses pós-game launch. Escopo: ~2 meses de produção." },
        { name: "Princípio editorial — DLC nunca corta conteúdo do jogo base", desc: "Nenhum sistema, NPC ou final do jogo base é 'reservado para DLC'. DLCs sempre adicionam — nunca completam o que estava prometido. Jogador que comprou o base tem o jogo inteiro." },
      ]},
      { heading: "⚖️ Balanceamento das Fases 4 e 5", items: [
        { name: "Fase 4 — modelo de balanceamento", desc: "Contratos R$ 2.000–6.000. Salários elevados (chefe de manutenção R$ 280+, gerente sênior). Custo fixo semanal: ~R$ 1.200. Caixa esperado de entrada: R$ 35.000+. Sr. Abutre faz oferta de compra. Final do Ato 3 narrativo." },
        { name: "Fase 5 — pós-campanha e horizonte", desc: "Acessível apenas em modo de continuação após Final A (Porto Unificado) ou em playthrough de extensão livre. Contratos R$ 6.000–20.000. Estaleiro completo. Equipe de até 24 funcionários. Não há mais arco narrativo principal — sandbox de gestão pura para quem ama o porto e não quer terminar." },
        { name: "Sem grindfest", desc: "Fase 5 não é 'farmar mais reputação'. O jogador entra nela com a campanha já fechada. É espaço de continuidade emocional, não progressão obrigatória. A maioria dos jogadores terminará na Fase 4." },
      ]},
      { heading: "🔄 Política de updates pós-lançamento", items: [
        { name: "Bug fixes e balanceamento — sempre gratuitos", desc: "Cadência: hotfix em 1 semana para bugs críticos. Update de balanceamento mensal nos primeiros 3 meses, trimestral depois." },
        { name: "Pequenas adições — gratuitas como goodwill", desc: "Diálogos extras, eventos sazonais menores (Dia da Marinha, aniversários de NPCs), polaroids especiais. Frequência: trimestral. Mantém comunidade ativa entre DLCs." },
        { name: "Conteúdo substancial — DLC pago", desc: "Linha clara: novo cenário, nova campanha, novo arco de NPC = DLC. Comunicado com antecedência. Sem 'surpresas' que decepcionam quem comprou o base esperando que fosse completo." },
      ]},
    ],
  },
  {
    id: "voz_personagens", icon: "🎭", label: "Voz dos Personagens",
    title: "Guia de Estilo — Como Cada NPC Fala",
    intro: "Referência centralizada para escrita futura (DLCs, hotfixes, eventos sazonais) preservar o tom dos personagens.",
    subsections: [
      { heading: "🗣️ Princípios gerais", items: [
        { name: "Brasileiro contemporâneo regional", desc: "Linguagem do litoral brasileiro misturado — não fixar num só estado. Permitir 'chefia', 'cumpadi', 'arretado', 'oxente' sem caricatura. Nunca usar todos juntos no mesmo personagem." },
        { name: "Cada NPC tem 1–2 traços de fala", desc: "Não fazer dicionário inteiro por personagem. Um ou dois maneirismos consistentes = personalidade. Mais que isso vira paródia." },
        { name: "Diálogos curtos sempre que possível", desc: "Mobile = leitura rápida. Cada fala em 1–3 linhas. Diálogos longos quebrados em múltiplos balões. Exceção: cenas narrativas de virada (final, descoberta de segredo) podem ser mais longas." },
      ]},
      { heading: "👴 Toninho — Estivador-chefe / Memória viva", items: [
        { name: "Tom", desc: "Conciso, observador, irônico sem amargura. Fala como quem viu de tudo e não precisa provar nada. Pausas longas implícitas." },
        { name: "Maneirismos", desc: "Chama o protagonista de 'chefia' com afeto. Refere-se ao avô como 'Seu Maneco' — sempre com respeito. Quando vai contar algo importante, começa com 'Olha, chefia...' e faz pausa." },
        { name: "Exemplos", desc: "'Seu Maneco me ensinou tudo sobre esse cais. Inclusive a não contar tudo que sei.' / 'O galpão tá chamando, chefia.' / 'Olha, chefia... seu avô não morreu por dívida. Morreu de outra coisa. Mas isso é conversa pra outra hora.'" },
      ]},
      { heading: "🎣 Seu Biu — Pescador veterano / Vigia por hábito", items: [
        { name: "Tom", desc: "Lacônico, enigmático, observador. Diz a verdade de um jeito que parece mentira ou metáfora. Sotaque litorâneo discreto." },
        { name: "Maneirismos", desc: "Quase nunca usa nome próprio dos outros. Refere-se a coisas e pessoas em terceira pessoa. Quando responde pergunta direta, dá resposta indireta que precisa ser interpretada." },
        { name: "Exemplos", desc: "'Tive uma noite tranquila. Vi tudo. Não vi nada.' / 'O mar sabe quem é honesto. Mas o mar não fala.' / 'Quem chega de fora vai embora rápido. Quem é daqui... também, às vezes.'" },
      ]},
      { heading: "💼 Dona Cida — Contadora / Gerente", items: [
        { name: "Tom", desc: "Pragmática, brava, leal. Fala direto, sem rodeios. Ironia calibrada — nunca cruel, sempre verdadeira. Tem opinião sobre tudo e não tem medo de dar." },
        { name: "Maneirismos", desc: "Usa 'chefia' (como Toninho) mas em tom mais formal. Comenta cifras com naturalidade. Quando algo é grave, fica curta: uma frase, sem adjetivos. Quando algo é leve, usa ironia." },
        { name: "Exemplos", desc: "'O cais tá no vermelho, chefia. Mas que vermelho bonito...' / 'Aceitou esse contrato? Boa sorte explicando pro banco.' / 'Chefia, com R$ 200 no caixa, qualquer espirro é falência.'" },
      ]},
      { heading: "🔨 Zezão — Mestre de obras / Mecânico", items: [
        { name: "Tom", desc: "Curto, prático, ocasionalmente filosófico. Fala mais com mão que com boca. Quando fala, tem peso." },
        { name: "Maneirismos", desc: "Frases incompletas que terminam com encolher de ombros. Comenta cada estrutura nova com uma linha que parece neutra mas tem opinião embutida. Raramente usa 'chefia' — quando usa, é importante." },
        { name: "Exemplos", desc: "'Conserto qualquer coisa. Menos gente.' / 'Esse galpão? Ainda tem vida. Bonita ele não tem.' / 'Chefia. Precisa parar um instante.'" },
      ]},
      { heading: "📰 Bela — Repórter / Aliada opcional", items: [
        { name: "Tom", desc: "Articulada, investigativa, idealista sem ingenuidade. Frases compostas, sintaxe correta. Sabe usar silêncio para fazer pergunta." },
        { name: "Maneirismos", desc: "Nunca usa 'chefia' nem apelidos. Chama pelo nome real do protagonista. Quando suspeita de algo, faz pergunta aparentemente neutra que é armadilha narrativa." },
        { name: "Exemplos", desc: "'Não faz nada que não queira ver na manchete.' / 'O Porto Farol cresceu rápido demais. Você já se perguntou de onde veio o dinheiro?' / 'Eu não escrevo o que me dizem. Escrevo o que descubro.'" },
      ]},
      { heading: "🔧 Kinha — Mecânica / Chefe de manutenção", items: [
        { name: "Tom", desc: "Pragmático, direto, sem desculpa para si nem para os outros. Sotaque do interior litorâneo. Não usa diminutivo. Quando elogia, é raro e vale." },
        { name: "Maneirismos", desc: "Refere-se a problemas técnicos com precisão. Refere-se a problemas humanos com mesma precisão. Não distingue. Chama o protagonista pelo nome (quando lealdade alta) ou 'você' (quando neutro)." },
        { name: "Exemplos", desc: "'Tô consertando o que o Zezão não quer admitir que quebrou.' / 'Eu sei o que esse motor vale. Só quero saber se você sabe também.' / 'Era o que deveria ser. Sem comemoração.'" },
      ]},
      { heading: "🏦 Sr. Ribeiro — Banqueiro / Antagonista gentil", items: [
        { name: "Tom", desc: "Formal, paciente no início, esfriando com atrasos. Vocabulário cuidadoso — nunca ameaça, sempre informa. A pressão vem da educação, não da grosseria." },
        { name: "Maneirismos", desc: "Usa 'o senhor' / 'a senhora' sempre. Refere-se a si mesmo como 'o banco' em momentos formais. Quando bravo, fica MAIS educado, não menos." },
        { name: "Exemplos", desc: "'O senhor tem até sexta. Isso não é ameaça — é matemática.' / 'Seu avô foi um homem honrado. Ele não atrasava.' / 'O banco aprecia regularidade. Eu também.'" },
      ]},
      { heading: "⚔️ Arlindo — Rival local", items: [
        { name: "Tom", desc: "Simpático na superfície, competitivo por baixo. Usa diminutivos e familiaridade como ferramenta de poder. Sempre sorrindo quando ataca." },
        { name: "Maneirismos", desc: "Chama todo mundo de 'sobrinho' ou 'querido' — independente da idade. Refere-se ao próprio porto como 'a casa'. Quando perde, é o último a admitir." },
        { name: "Exemplos", desc: "'Que bom te ver crescer, sobrinho. É mais fácil de acompanhar.' / 'Querido, esse contrato é grande demais pra um cais desse tamanho. Não acha?' / 'A casa sempre ganha. Mesmo quando perde.'" },
      ]},
      { heading: "🦅 Sr. Abutre — Grupo Atlântico", items: [
        { name: "Tom", desc: "Educado, implacável, calculado. Nunca apressado. Sentenças curtas em momentos importantes. Frases longas quando quer enredar." },
        { name: "Maneirismos", desc: "Não usa apelidos. Não usa nomes próprios — só 'você' e 'o senhor / a senhora' alternando deliberadamente. Quando elogia, é avaliação fria. Quando ameaça, é via observação neutra." },
        { name: "Exemplos", desc: "'Tenho admiração pela sua teimosia. Ela tem prazo de validade.' / 'O senhor construiu algo interessante. Pena que vai pertencer a outro.' / 'Não é pessoal. É só matemática numa escala que o senhor ainda não entendeu.'" },
      ]},
    ],
  },
];

const DECISION_COLORS = {
  gameplay: "#1a6b8a", phases: "#2d7a3a", rivals: "#8a3a1a", monetization: "#5a3480",
  loop: "#1a5a6b", mapa: "#3a6b1a", tutorial: "#6b5a1a",
  reputacao: "#1a3a6b", finais: "#4a1a1a", economia: "#1a6b3a",
  save: "#2a3a5a", onboarding_avancado: "#5a6b1a", acessibilidade: "#4a3a6b",
  kpis: "#6b3a4a", pos_lancamento: "#3a6b5a", voz_personagens: "#6b5a3a",
};

const DECISION_BG = {
  gameplay: "#eaf5fb", phases: "#eafbea", rivals: "#fdf1ee", monetization: "#f4eefa",
  loop: "#e6f2f5", mapa: "#edf5e6", tutorial: "#f5f0e6",
  reputacao: "#e6ecf5", finais: "#f5e6e6", economia: "#e6f5ec",
  save: "#eaedf5", onboarding_avancado: "#f0f5e6", acessibilidade: "#efeaf5",
  kpis: "#f5eaee", pos_lancamento: "#eaf5f0", voz_personagens: "#f5efea",
};
const DECISION_BORDER = {
  gameplay: "#90c8e0", phases: "#a8d8a8", rivals: "#e8b8a8", monetization: "#c8aaea",
  loop: "#9dc8d5", mapa: "#a8cc88", tutorial: "#d4b870",
  reputacao: "#8aaacb", finais: "#c88a8a", economia: "#88c8a0",
  save: "#9aabcb", onboarding_avancado: "#c0d088", acessibilidade: "#b8a8d8",
  kpis: "#d8a8b8", pos_lancamento: "#88c8b0", voz_personagens: "#d8c088",
};
const DECISION_ACCENT = {
  gameplay: "#2196f3", phases: "#4caf50", rivals: "#c4470a", monetization: "#7c3aed",
  loop: "#0097a7", mapa: "#558b2f", tutorial: "#f57f17",
  reputacao: "#1565c0", finais: "#b71c1c", economia: "#2e7d32",
  save: "#3949ab", onboarding_avancado: "#827717", acessibilidade: "#6a1b9a",
  kpis: "#ad1457", pos_lancamento: "#00695c", voz_personagens: "#bf8f00",
};

// ── Componente principal ─────────────────────────────────────────────
function HarborKingsSystems() {
  const [active, setActive]       = useState("gameplay");
  const [openPhase, setOpenPhase] = useState(null);
  const [openQ, setOpenQ]         = useState(null);
  const [resolved, setResolved]   = useState(INITIAL_RESOLVED);
  const [openDec, setOpenDec]     = useState({});

  const isQuestions = active === "questions";
  const sec = !isQuestions ? sections.find(s => s.id === active) : null;
  const pal = palette[active] || palette.questions;

  const totalQ        = questionGroups.reduce((a, g) => a + g.questions.length, 0);
  const totalResolved = Object.values(resolved).filter(Boolean).length;
  const totalOpen     = totalQ - totalResolved;

  const navItems = [
    ...sections.map(s => ({ id: s.id, icon: s.icon, label: s.label })),
    { id: "questions", icon: "❓", label: "Questões" },
  ];

  const toggleDec = (key) =>
    setOpenDec(prev => ({ ...prev, [key]: !prev[key] }));

  // ── Painel de decisões fechadas ───────────────────────────────────
  const DecisionPanel = ({ type }) => {
    const list   = DECISIONS[type] || [];
    const color  = DECISION_COLORS[type];
    const bg     = DECISION_BG[type];
    const border = DECISION_BORDER[type];
    const accent = DECISION_ACCENT[type];
    return (
      <div>
        <div style={{ background: bg, border: `1px solid ${border}`, borderRadius: 10, padding: "10px 12px", marginBottom: 8 }}>
          <div style={{ fontSize: 12, color, fontWeight: 700, marginBottom: 8 }}>
            ✔ {list.length} decisões fechadas — toque para detalhar
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
            {list.map((d, i) => {
              const key = `${type}-${i}`;
              const on  = openDec[key];
              return (
                <button key={i} onClick={() => toggleDec(key)} style={{
                  fontSize: 11, padding: "4px 10px", borderRadius: 99, cursor: "pointer",
                  border: on ? `1.5px solid ${color}` : `1px solid ${border}`,
                  background: on ? color : "white",
                  color: on ? "white" : color,
                  fontWeight: on ? 700 : 500,
                  transition: "all 0.15s",
                }}>
                  {d.icon} {d.title}
                </button>
              );
            })}
          </div>
        </div>
        {list.map((d, i) => {
          const key = `${type}-${i}`;
          if (!openDec[key]) return null;
          return (
            <div key={i} style={{ background: "white", border: `1.5px solid ${border}`, borderRadius: 10, padding: "12px 14px", marginBottom: 6 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
                <span style={{ fontSize: 20 }}>{d.icon}</span>
                <div>
                  <div style={{ fontSize: 13, fontWeight: 700, color }}>{d.title}</div>
                  <div style={{ fontSize: 11, color: `${color}99`, fontFamily: "monospace" }}>{d.summary}</div>
                </div>
              </div>
              <div style={{ fontSize: 12, color: "#444", lineHeight: 1.7, borderLeft: `3px solid ${accent}`, paddingLeft: 10 }}>
                {d.detail}
              </div>
            </div>
          );
        })}
      </div>
    );
  };

  // ── Render ────────────────────────────────────────────────────────
  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 480, margin: "0 auto", padding: "16px 12px" }}>

      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 18 }}>
        <div style={{ fontSize: 11, letterSpacing: 3, textTransform: "uppercase", color: "#aaa", fontFamily: "monospace" }}>
          Game Design Document
        </div>
        <div style={{ fontSize: 24, fontWeight: 700, color: "#1a3a5c", letterSpacing: -0.5, margin: "4px 0 2px" }}>
          ⚓ BR Port
        </div>
        <div style={{ fontSize: 12, color: "#999", fontStyle: "italic" }}>
          Sistemas de Jogo — v6.5 — Fase 1 do roadmap concluída · Decisões do VS fechadas
        </div>
      </div>

      {/* Nav tabs */}
      <div style={{ display: "flex", gap: 5, justifyContent: "center", flexWrap: "wrap", marginBottom: 16 }}>
        {navItems.map(s => {
          const p  = palette[s.id] || palette.questions;
          const on = active === s.id;
          return (
            <button key={s.id} onClick={() => { setActive(s.id); setOpenPhase(null); setOpenQ(null); }} style={{
              fontSize: 11, padding: "5px 11px", borderRadius: 99, cursor: "pointer",
              border: on ? `2px solid ${p.main}` : "1px solid #ddd",
              background: on ? p.light : "transparent",
              color: on ? p.main : "#777",
              fontWeight: on ? 700 : 400,
            }}>
              {s.icon} {s.label}
            </button>
          );
        })}
      </div>

      {/* ── Questões ── */}
      {isQuestions && (
        <div>
          <div style={{ background: palette.questions.light, border: `1px solid ${palette.questions.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 16, textAlign: "center" }}>
            <div style={{ fontSize: 20, fontWeight: 700, color: palette.questions.main }}>{totalResolved} / {totalQ}</div>
            <div style={{ fontSize: 12, color: palette.questions.main }}>questões respondidas</div>
            {totalOpen > 0 && <div style={{ fontSize: 11, color: "#c07000", marginTop: 4 }}>⚠️ {totalOpen} questões ainda abertas</div>}
          </div>
          {questionGroups.map((group, gi) => (
            <div key={gi} style={{ marginBottom: 20 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: group.color, marginBottom: 8, fontFamily: "monospace" }}>
                {group.icon} {group.label}
              </div>
              {group.questions.map((item, qi) => {
                const key = `${gi}-${qi}`;
                const isResolved = resolved[key] === true;
                const isOpen = openQ === key;
                return (
                  <div key={qi} style={{ marginBottom: 6, background: "white", border: `1px solid ${isResolved ? "#c8e8c0" : "#e8d88a"}`, borderRadius: 10, overflow: "hidden" }}>
                    <button onClick={() => setOpenQ(isOpen ? null : key)} style={{
                      width: "100%", textAlign: "left", background: isResolved ? "#f0faf0" : "#fdf8e8",
                      border: "none", padding: "9px 12px", cursor: "pointer",
                      display: "flex", alignItems: "center", gap: 8
                    }}>
                      <span style={{ fontSize: 14 }}>{isResolved ? "✅" : "🔲"}</span>
                      <span style={{ fontSize: 12, color: "#333", flex: 1, lineHeight: 1.4 }}>{item.q}</span>
                      <span style={{ fontSize: 11, color: "#aaa" }}>{isOpen ? "▲" : "▼"}</span>
                    </button>
                    {isOpen && (
                      <div style={{ padding: "0 12px 12px" }}>
                        <div style={{ fontSize: 12, color: "#666", lineHeight: 1.6, marginBottom: 8, paddingTop: 6, borderTop: "1px solid #eee" }}>
                          <strong>Por que importa:</strong> {item.why}
                        </div>
                        <div style={{ fontSize: 12, color: "#333", lineHeight: 1.6, background: isResolved ? "#eafaec" : "#fff8e1", borderRadius: 8, padding: "8px 10px" }}>
                          <strong>{isResolved ? "✅ Decisão:" : "⚠️ Status:"}</strong> {item.decision}
                        </div>
                        <button
                          onClick={() => setResolved(prev => ({ ...prev, [key]: !prev[key] }))}
                          style={{ marginTop: 8, fontSize: 11, padding: "4px 12px", borderRadius: 99, cursor: "pointer",
                            border: `1px solid ${isResolved ? "#88b880" : "#c8a020"}`,
                            background: isResolved ? "#eafaec" : "#fff8e1",
                            color: isResolved ? "#2d7a3a" : "#7a6010" }}>
                          {isResolved ? "↩ Reabrir" : "✓ Marcar como resolvida"}
                        </button>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      )}

      {/* ── Seção GDD ── */}
      {!isQuestions && sec && (
        <div>
          <div style={{ background: pal.light, border: `1px solid ${pal.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 16 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: pal.main }}>{sec.icon} {sec.title}</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: pal.main, background: `${pal.main}11`, border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginTop: 8, lineHeight: 1.5 }}>
              {sec.intro}
            </div>
          </div>

          {sec.subsections.map((sub, si) => (
            <div key={si} style={{ marginTop: 16 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: pal.main, marginBottom: 8 }}>{sub.heading}</div>

              {/* Painel de decisões */}
              {sub.decisions && <DecisionPanel type={sub.decisions} />}

              {/* Fases acordeão */}
              {sub.phases && (
                <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
                  {sub.phases.map((ph, pi) => {
                    const open = openPhase === `${si}-${pi}`;
                    return (
                      <div key={pi} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, overflow: "hidden" }}>
                        <button onClick={() => setOpenPhase(open ? null : `${si}-${pi}`)} style={{
                          width: "100%", textAlign: "left", background: "none", border: "none",
                          padding: "10px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 10
                        }}>
                          <span style={{ fontSize: 11, fontWeight: 700, fontFamily: "monospace", background: pal.main, color: "white", padding: "2px 7px", borderRadius: 99 }}>{ph.num}</span>
                          <span style={{ fontSize: 13, fontWeight: 700, color: "#333", flex: 1 }}>{ph.name}</span>
                          <span style={{ fontSize: 11, color: pal.main, fontFamily: "monospace" }}>★ {ph.rep}</span>
                          <span style={{ fontSize: 12, color: "#aaa" }}>{open ? "▲" : "▼"}</span>
                        </button>
                        {open && (
                          <div style={{ padding: "0 12px 12px", display: "flex", flexDirection: "column", gap: 6 }}>
                            {[["🏗️ Infra obrigatória", ph.infra], ["🔓 Desbloqueios", ph.unlock], ["🎨 Visual do porto", ph.visual], ["🏙️ Cidade ao redor", ph.city]].map(([label, val], i) => (
                              <div key={i} style={{ display: "flex", gap: 8, fontSize: 12 }}>
                                <span style={{ color: "#999", minWidth: 130 }}>{label}</span>
                                <span style={{ color: "#444", flex: 1 }}>{val}</span>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}

              {/* Lista de itens */}
              {sub.items && (
                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  {sub.items.map((item, ii) => (
                    <div key={ii} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                      <div style={{ width: 6, height: 6, borderRadius: 99, background: pal.main, marginTop: 5, flexShrink: 0 }} />
                      <div>
                        <div style={{ fontSize: 13, fontWeight: 700, color: "#333", marginBottom: 2 }}>{item.name}</div>
                        <div style={{ fontSize: 12, color: "#666", lineHeight: 1.5 }}>{item.desc}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Fichas de NPC */}
              {sub.npcs && (
                <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                  {sub.npcs.map((npc, ni) => (
                    <div key={ni} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 12, padding: "12px 14px" }}>
                      <div style={{ fontSize: 13, fontWeight: 700, color: pal.main }}>{npc.name}</div>
                      <div style={{ fontSize: 11, color: "#999", fontFamily: "monospace", marginBottom: 6 }}>{npc.role}</div>
                      <div style={{ fontSize: 12, color: "#555", lineHeight: 1.6, marginBottom: 6 }}>{npc.personality}</div>
                      {npc.humor && (
                        <div style={{ fontSize: 11, fontStyle: "italic", color: "#888", borderLeft: `3px solid ${pal.main}55`, paddingLeft: 8 }}>
                          {npc.humor}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {/* Tabela de linhas (economia, reputação) */}
              {sub.rows && (
                <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, overflow: "hidden" }}>
                  {sub.rows.map((row, ri) => (
                    <div key={ri} style={{
                      display: "flex", gap: 8, padding: "8px 12px",
                      borderBottom: ri < sub.rows.length - 1 ? `1px solid ${pal.border}` : "none",
                      background: ri % 2 === 0 ? "white" : pal.light,
                    }}>
                      <span style={{ fontSize: 12, color: "#888", minWidth: 145, flexShrink: 0 }}>{row.label}</span>
                      <span style={{ fontSize: 12, color: "#333", flex: 1, fontFamily: "monospace" }}>{row.value}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      <div style={{ textAlign: "center", marginTop: 18, fontSize: 11, color: "#ccc", fontFamily: "monospace" }}>
        BR Port • GDD v6.5 • Sistemas de Jogo
      </div>
    </div>
  );
}
  return HarborKingsSystems;
})();

/* =================================================================
   VisualAudio  —  fonte: BR_Port_Visual_Audio_v5_5.jsx
   Conteúdo e lógica preservados integralmente; apenas isolado
   em escopo próprio para evitar colisão de identificadores.
   ================================================================= */
const VisualAudio = (() => {
const palette = {
  art:     { main: "#c4470a", light: "#fff3ee", border: "#f5c4a8" },
  sound:   { main: "#1a5c8a", light: "#eaf3fb", border: "#a8cfec" },
  session: { main: "#2d7a3a", light: "#eaf5ec", border: "#a8d8b0" },
  map:     { main: "#6a3480", light: "#f4eefa", border: "#c8a8e8" },
  tech:    { main: "#2a4a7a", light: "#e8eef8", border: "#a8c0e0" },
};

/* ══════════════════════════════════════════════════════
   PERGUNTAS DE DESIGN — v6.5
   Todas as questões fechadas — v5.5 / Protótipo V3 aprovado
   Respostas atualizadas marcadas com (atualizado — Sistemas/Conceitos v5.5)
══════════════════════════════════════════════════════ */
const DESIGN_QUESTIONS = {
  art: [
    {
      category: "🖼️ Animação & Feedback Visual",
      questions: [
        { id: "a1", priority: "alta",
          q: "Como o personagem reage visualmente ao ser selecionado — balão, brilho, sacudir?",
          why: "Define a linguagem de interação central do jogo. Sem isso, o jogador não sabe se clicou certo.",
          answer: "Outline pulsante na cor do personagem (2px, ciclo de 0.4s) + seta indicadora pequena acima do sprite. Sacudir é reservado para erro. Balão só aparece quando o personagem tem algo a dizer. A seta desaparece após 1.5s se nenhuma ação for tomada." },
        { id: "a2", priority: "alta",
          q: "Qual é o feedback visual imediato ao completar uma ação importante (construção pronta, contrato entregue)?",
          why: "O 'juice' de satisfação — sem ele o jogo parece morto. Pode ser partícula, moeda voando, brilho.",
          answer: "Construção pronta: faíscas/confete por 1.5s + banner flutuante '✔ Pronto!' que dissolve em 2s. Contrato entregue: moedas voando da doca até o contador do HUD + número verde flutuante (+R$ valor) que sobe e some. O efeito de moeda voando para o HUD é prioridade máxima de implementação." },
        { id: "a3", priority: "média",
          q: "Como é a transição visual entre fases do jogo (fade, dissolve, cinemática animada)?",
          why: "A virada de fase é um momento de impacto emocional — deve ter peso visual.",
          answer: "Cinemática animada em Flat Design de 5–8s: (1) flash branco de 1 frame, (2) porto se ilumina da esquerda para a direita com tween de brilho, (3) cidade cresce com 2–3 estruturas novas aparecendo via scale tween, (4) protagonista para e olha o horizonte com pose especial, (5) fade para tela estática 'Fase X — [nome]' com arte-chave do novo estado do porto." },
        { id: "a4", priority: "média",
          q: "Existe animação de dano/deterioração para estruturas em mau estado?",
          why: "Ajuda o jogador a identificar prioridades de manutenção sem consultar menus.",
          answer: "Três estados visuais via overlay progressivo: Bom (>70% saúde) = sprite normal. Desgastado (30–70%) = rachaduras + cor levemente dessaturada. Crítico (<30%) = ícone vermelho piscando + fumaçinha saindo do sprite. Estado crítico também dispara alerta no HUD." },
      ],
    },
    {
      category: "🎭 Identidade & Personagens",
      questions: [
        { id: "a5", priority: "alta",
          q: "O protagonista tem expressões faciais distintas nos eventos narrativos (raiva, alegria, surpresa)?",
          why: "Cria empatia e torna os NPCs memoráveis. Flat Design permite expressões ricas via animação rigged sem custo de frame a frame.",
          answer: "Portrait box de 96×96px nos diálogos (padrão de jogos mobile de gestão modernos). 6 expressões: Neutro, Feliz/aliviado, Surpreso, Bravo/frustrado, Preocupado, Determinado. No mapa, personagem animado via Godot Skeleton2D — partes separadas (cabeça, tronco, braços) permitem expressão fluida sem redesenhar frame a frame. Protagonista personalizável por gênero (Conceitos v5.5) — dois rigs base com 6 expressões cada." },
        { id: "a6", priority: "média",
          q: "Como navios de diferentes origens ou tipos de carga se diferenciam visualmente (cor do casco, bandeira, fumaça)?",
          why: "Permite o jogador identificar o navio antes de clicar — leitura visual rápida em gameplay.",
          answer: "3 camadas de leitura: Cor do casco = tipo de carga (azul escuro → pesca, vermelho enferrujado → cargueiro, amarelo/branco → turismo, cinza escuro → carga suspeita). Bandeirinha no mastro = origem (locais sem bandeira, forasteiros com miniatura). Fumaça = estado do motor (branca fina = ok, preta grossa = motor forçado). Leitura deve funcionar em 2 segundos sem clicar." },
        { id: "a7", priority: "alta",
          q: "Existe sistema de skin/aparência para as estruturas conforme o porto sobe de nível?",
          why: "Progressão visual é uma das recompensas mais satisfatórias em jogos de gestão.",
          answer: "Sim — cada estrutura principal tem 5 estados visuais (um por fase), assets vetoriais separados, progressão automática. Guindaste: F1=enferrujado/cores apagadas, F2=reformado/pintura nova, F3=laranja vibrante/iluminação noturna, F4=moderno/cabine envidraçada, F5=industrial/imponente. Animação por partes — braço gira via Skeleton2D, não frame a frame. Cidade ao fundo acompanha via 5 estados automáticos." },
        { id: "a8", priority: "baixa",
          q: "Os trabalhadores do porto têm variação visual (gênero, roupa, cor de pele) ou são sprites idênticos?",
          why: "Diversidade visual enriquece o mundo sem custo narrativo — e reflete o Brasil real.",
          answer: "4 rigs vetoriais genéricos (homem/mulher × dois tons de pele) com troca de cor de roupa via shader de paleta no Godot. NPCs fixos nomeados têm visual único reconhecível à distância — forma de roupa e silhueta diferenciados: Toninho (estivador veterano), Kinha (macacão de mecânica, Fase 3+), Seu Biu (pescador), Zezão (macacão de obras). Total: 4 rigs genéricos + 6 personagens fixos (protagonista em 2 variantes + 4 NPCs principais). Flat Design permite trocar cor de pele/roupa via shader sem redesenho." },
      ],
    },
    {
      category: "🌦️ Ambiente & Ciclo Visual",
      questions: [
        { id: "a9", priority: "alta",
          q: "Como chuva e tempestade afetam o visual do mapa além da gameplay?",
          why: "Clima é um evento de crise — o visual precisa comunicar urgência antes do alerta de texto.",
          answer: "5 camadas progressivas: (1) sprite sheet de gotas diagonais sobre todo o mapa, (2) tile de água com amplitude aumentada, (3) overlay cinza-azulado semi-transparente (25% opacidade), (4) relâmpagos ocasionais (flash branco 1–2 frames a cada 8–15s aleatorizados), (5) navios balançando ±3px. O visual da tempestade chega antes do alerta de texto — o jogador sente antes de ler. Tempestades ocorrem em agosto (Conceitos v5.5: vento sul, mar agitado)." },
        { id: "a10", priority: "baixa",
          q: "Existe neblina matinal ou pôr-do-sol que muda o mood visual da cena?",
          why: "Adiciona charme e variedade sem complexidade de gameplay. Momentos bonitos geram screenshots.",
          answer: "Implementar os dois. Pôr-do-sol (18h–19h de tempo de jogo): overlay gradiente laranja/roxo crescente, lanternas e luzes das estruturas acendem com brilho, dura ~10 segundos reais (Sistemas v5.5: 4 min/dia; 1h de jogo ≈ 10s reais). Neblina matinal (5h–8h): overlay branco leitoso 20% opacidade que dissolve gradualmente — dura ~30s reais. Navios chegando na neblina têm estética cinematográfica forte." },
        { id: "a11", priority: "baixa",
          q: "As estações do ano alteram a paleta — vegetação mais seca no verão, mais verde no inverno?",
          why: "Define se o ciclo temporal do jogo é puramente funcional ou também estético.",
          answer: "Sim, via color overlay — sem recriar arte. Jan/Fev (verão/Carnaval): paleta mais saturada, vegetação amarelada. Mai/Jun (estação chuvosa): céu cinzento, vegetação mais verde. Ago (vento sul): overlay azulado leve, ondas maiores. Dez (fim de ano): noites chegando mais cedo, luzes de festa no bairro Porto Mirim. Cada período corresponde a faixas de semanas de jogo (Conceitos v5.5: 12 semanas = 1 ciclo narrativo completo)." },
      ],
    },
    {
      category: "🕐 Períodos do Dia (turn-based — v5.5)",
      questions: [
        { id: "a_cc1", priority: "alta",
          q: "Como o jogo turn-based representa o ciclo dia/noite sem relógio real?",
          why: "Sistemas v5.5 estabelece avanço por turno (sem relógio correndo). O visual ainda precisa comunicar o momento do dia em que cada evento acontece — manhã, tarde, noite — sem fazer o jogador esperar.",
          answer: "Cada dia de jogo é dividido em 3 períodos discretos: Manhã (operacional, eventos comerciais, contratos), Tarde (manutenção, conversas com NPCs, hobbies) e Noite (eventos narrativos especiais — carga sem nota, vigia, missões opcionais). O jogador toma decisões em cada período antes de avançar ao próximo. Visualmente: cada período tem paleta própria via color overlay (manhã = luz dourada leve, tarde = saturação normal, noite = overlay azul profundo + lanternas acesas). A transição entre períodos é animada em 1–2 segundos reais, puláveis. O jogador nunca espera o relógio — ele decide quando avançar." },
        { id: "a_cc2", priority: "alta",
          q: "Eventos exclusivos de noite — como o jogador acessa sem mecânica de tempo real?",
          why: "Carga sem nota, vigia noturno, missões narrativas noturnas (Conceitos) precisam ter momento de acontecimento claro num jogo onde o jogador controla o avanço.",
          answer: "Eventos noturnos são oferecidos como decisão no fim da tarde: 'Vai dormir cedo ou ficar acordado essa noite?'. Ficar acordado consome o turno noturno em troca de acesso aos eventos narrativos exclusivos do período — mas custa moral do protagonista no dia seguinte (pensa pior, opções limitadas no diálogo). Dormir cedo pula a noite sem incidente. O jogador nunca perde um evento noturno por não estar online no horário certo — ele perde por escolher dormir naquela noite específica, decisão consciente." },
      ],
    },
    {
      category: "🎨 Sistema de Cores & Tipografia (v5.5)",
      questions: [
        { id: "a_c1", priority: "alta",
          q: "A paleta de 8 cores tem regras de contraste e uso além dos hex codes — quais combinações são permitidas e proibidas?",
          why: "Sem regras de uso, cores do HUD podem combinar com o mapa criando leitura impossível. Definir antes de qualquer asset de UI ser produzido.",
          answer: "Paleta definitiva: Azul Oceano #2B7FBF (mar, water tiles, ícones de doca), Laranja Porto #E8621A (guindastes, alertas, ações primárias de HUD), Verde Mangue #3A9E52 (vegetação, reputação positiva, construção concluída), Areia Quente #E8C97A (praia, terra, cais antigo, fundo de painéis), Vermelho Casco #C43030 (navios cargueiros, alertas críticos, dívida), Branco Espuma #F0F0E8 (texto primário, espuma, luz de dia), Roxo Noite #3D2A6E (céu noturno, sombras, fundo do HUD noturno), Cinza Concreto #7A7A72 (calçada, muros, elementos neutros). Regras: Laranja Porto (#E8621A) NUNCA sobre Vermelho Casco — contraste insuficiente para daltônicos. Texto primário SEMPRE em Branco Espuma ou Cinza Concreto escuro, nunca em Laranja ou Verde diretamente. Paleta de sombra = cor base com opacidade 60% em Roxo Noite sobreposto. Paleta de highlight = cor base com 30% de Branco Espuma misturado. Em modo daltônico: Laranja Porto → #E8A21A (amarelo-âmbar), Vermelho Casco → #7A2090 (roxo), mantendo distinção para deuteranopia." },
        { id: "a_c2", priority: "alta",
          q: "Qual é a tipografia definitiva do jogo — fonte específica, licença e suporte a diacríticos do inglês e português?",
          why: "O jogo lança em inglês (EN-US) e PT-BR simultaneamente (Conceitos v5.5). A fonte precisa cobrir ã, ç, ê, ü e caracteres especiais sem fallback grotesco. Fonte hardcoded é técnica para Godot; fonte de sistema depende do device.",
          answer: "Fonte principal: Inter ou Nunito (Google Fonts, licença OFL — gratuita para uso comercial). Ambas cobrem Latin Extended completo, incluindo todos os diacríticos PT-BR. Tamanhos definidos: UI crítica (reputação, dinheiro) = 16px bold; diálogos e contratos = 14px regular; tooltips e labels secundários = 12px; mínimo absoluto = 11px (nunca abaixo). Para títulos e destaques: versão Bold/ExtraBold da mesma família — sem segunda fonte. Fontes importadas como DynamicFont no Godot 4. Teste de legibilidade obrigatório: texto de 14px lido a 30cm em iPhone SE (375pt de largura), com Dynamic Type do iOS respeitado onde aplicável." },
      ],
    },
    {
      category: "⚡ Performance Visual (v5.5)",
      questions: [
        { id: "a_perf1", priority: "alta",
          q: "Qual é o FPS alvo por perfil de dispositivo — e quais efeitos visuais são sacrificados em hardware mais fraco?",
          why: "O mercado brasileiro tem penetração alta de Android de médio e baixo custo. Sem degradação controlada, o jogo trava em 30–40% do hardware do público-alvo.",
          answer: "60fps em high-end (iPhone 14+, Snapdragon 778+, 4GB+ RAM). 30fps estável em mid-range (iPhone XR, Samsung A53, 3GB RAM). 30fps com degradação controlada em low-end (2GB RAM Android, Mediatek G85 e equivalentes). Escala de degradação: Low-end desativa partículas de fundo (fumaça de chaminé, espuma de água), reduz pool de animações simultâneas de 8 para 4 workers, desativa overlay de neblina e pôr-do-sol. High-priority animations (chegada de navio, animação de crise, feedback de contrato) mantêm framerate em todos os perfis — nunca são degradadas. Godot 4 usa VisibilityNotifier2D para culling automático de sprites fora de câmera: peça fundamental para performance no mapa de F5 com 24×14 células ativas." },
        { id: "a_perf2", priority: "alta",
          q: "Qual é o tamanho máximo do download inicial (APK/IPA) e do app instalado — visando o mercado brasileiro?",
          why: "No Brasil, 32–64GB de armazenamento ainda são comuns em Android entry-level, e planos de dados têm franquias limitadas. App de +150MB no install perde conversões antes de ser aberto.",
          answer: "Download inicial (assets de F1 + tutorial): ≤ 80MB. Total instalado (todas as fases): ≤ 200MB. Estratégia: texturas exportadas com ETC2 (Android) e ASTC (iOS) via Godot export presets — reduz ~55% do tamanho bruto. Áudio: OGG Vorbis a 96kbps em mobile (não 128kbps como no PC Steam) sem perda perceptível em speakers de celular. Assets de F3–F5: bundled comprimidos no APK, decomprimidos na primeira vez que a fase é acessada (sem download separado — mais simples de QA). Sprite atlas: um atlas por fase (4096×4096px max), estruturas compartilham atlas para evitar draw call overhead. Referência: Stardew Valley mobile ~350MB instalado; BR Port deve ficar significativamente abaixo por ser mobile-native, não portado de PC." },
      ],
    },
    {
      category: "📐 HUD — Layout & Hierarquia",
      questions: [
        { id: "a12", priority: "alta",
          q: "Como o HUD escala em telas pequenas (iPhone SE, Android compacto) sem perder legibilidade?",
          why: "Mobile-first exige testar na menor tela do mercado. Um elemento que não cabe no SE quebra em ~30% do mercado brasileiro.",
          answer: "HUD flutua sobre o mapa — nunca comprime a área de jogo. iPhone SE (375×667pt): barra superior máx. 44pt, ícones 24pt, fonte mínima 12pt (Inter/Nunito — v5). Barra inferior 56pt com safe area. Zona de crise: banner de 36pt que colapsa após 4s. Abaixo de 360pt de largura, rótulos de texto somem — ficam só ícones + números. Sans-serif escalável mantém legibilidade em qualquer tamanho sem anti-aliasing forçado. Regra de ouro: testar no SE antes de qualquer outro dispositivo." },
        { id: "a14", priority: "alta",
          q: "Qual é a hierarquia visual do HUD — o que o olho deve ver primeiro, segundo e terceiro?",
          why: "Sem hierarquia definida o UI fica poluído. Decisão de design, não de arte — antes de qualquer pixel de UI.",
          answer: "1º Zona de crise (topo, centralizado): só aparece em urgências — fundo vermelho pulsante, ícone grande. Some completamente quando não há crise. 2º Recursos operacionais (topo fixo): dinheiro, três medidores compactos de reputação (Comercial · Comunitária · Imprensa, escala 0–100 cada com título dinâmico — Sistemas v5.5), trabalhadores disponíveis. 3º Ações e navegação (barra inferior): Contratos, Construção, Trabalhadores e Menu. Rivalômetro: ícone compacto por rival no topo, muda de cor verde→amarelo→vermelho (Sistemas v5.5 — 'ícone compacto com expansão ao tocar'). O mapa ocupa 100% da área central." },
        { id: "a15", priority: "alta",
          q: "Quais elementos do HUD ficam sempre visíveis e quais somem ao explorar o mapa?",
          why: "HUD constante compete com o mapa por área de tela — decisão de layout mais importante do UI.",
          answer: "Modo normal → Modo exploração (ao arrastar o mapa): Recursos e zona de crise permanecem em ambos. Barra inferior some com fade de 0.2s no modo exploração. Tooltips abertos fecham automaticamente. Botão de recolher aparece apenas no modo exploração. A barra inferior retorna automaticamente ao soltar — sem gesto extra." },
        { id: "a16", priority: "média",
          q: "O HUD tem versão landscape além do portrait, ou o jogo é exclusivamente portrait?",
          why: "Tablets e alguns jogadores preferem landscape. Suportar os dois duplica o trabalho de UI.",
          answer: "Portrait exclusivo no MVP. O mapa de porto tem proporção naturalmente vertical (grid cresce mais em altura — Sistemas v5.5: F5 = 24×14, razão 1.7:1). Landscape duplica o trabalho de UI sem ganho narrativo. Mercado mobile brasileiro usa majoritariamente portrait em jogos casuais. Landscape pode ser considerado na versão Steam desktop (6–12 meses após mobile, Sistemas v5.5)." },
        { id: "a17", priority: "baixa",
          q: "Existe modo de tela cheia que esconde o HUD para capturar screenshots do porto?",
          why: "Jogadores compartilham prints nas redes — facilitar isso é marketing orgânico gratuito.",
          answer: "Sim — gesto de três dedos SIMULTÂNEOS (não sequenciais — evita conflito com os gestos do iOS de copiar/colar/desfazer que usam 3 dedos em swipe). Oculta todo o HUD por 3 segundos, depois retorna automaticamente. Um toque durante esse tempo aciona screenshot nativo do dispositivo. Implementação Godot: opacity 0 nos dois containers de HUD + timer de 3s. Custo: menos de meio dia de desenvolvimento." },
      ],
    },
    {
      category: "👆 Interação & Touch",
      questions: [
        { id: "a18", priority: "alta",
          q: "Qual é o tamanho mínimo de área de toque para elementos interativos?",
          why: "Apple e Google recomendam 44×44pt mínimo. Em Flat Design, elementos pequenos são vetoriais e escalam — mas o target de toque ainda precisa respeitar o tamanho físico do dedo.",
          answer: "Convenção para todo o jogo: botões de UI mín. 36pt visuais com área de toque 44×44pt. Ícones de recurso no HUD: 24pt visual, 44×44pt de toque. NPCs no mapa: sprite 32×32px art tile com área de toque 48×48pt. Estruturas: bounding box do sprite + 8pt de margem. Células do grid de 64×64px (Sistemas v5.5): sempre maiores que o mínimo de toque em zoom 2 (nível operacional). No zoom 1 (visão geral), estruturas ficam abaixo do mínimo — esse nível é só navegação, sem seleção individual." },
        { id: "a19", priority: "alta",
          q: "Como funciona o toque longo (long press) — e é consistente em todo o jogo?",
          why: "Long press é poderoso em mobile mas confuso se inconsistente. Convenção clara antes de implementar.",
          answer: "Convenção única: toque curto = selecionar / confirmar ação principal. Long press (0.6s) = menu de contexto com ações secundárias. Exemplos: toque em NPC abre diálogo; long press abre (Ver ficha, Designar tarefa, Dispensar). Toque em estrutura seleciona; long press abre (Reparar, Melhorar, Demolir, Mover). Long press em área vazia = menu de construção naquele ponto. Menu de contexto sempre aparece acima do dedo — nunca abaixo, nunca fora da tela." },
        { id: "a20", priority: "média",
          q: "O pinch-to-zoom tem limites mínimo e máximo definidos — e o zoom mínimo permite interagir?",
          why: "Zoom muito aberto torna sprites invisíveis. Zoom muito fechado perde contexto. Limites são decisão de design.",
          answer: "Três níveis fixos com snap automático — sem zoom livre infinito. Zoom 1 (Visão geral, 1× escala): só navegação, sem seleção individual. Zoom 2 (Operacional, 2× escala, 64×64px de cell visível): interação completa, nível padrão ao abrir — alinha com o grid de 64px do Sistemas v5.5. Zoom 3 (Detalhe, 4× escala): animações e NPCs individuais visíveis, ideal para missões narrativas. Pinch faz snap ao nível mais próximo ao soltar. Double tap alterna entre Zoom 2 e 3." },
        { id: "a21", priority: "alta",
          q: "Existe confirmação explícita para ações irreversíveis como demolir estrutura ou cancelar contrato?",
          why: "Toques acidentais em mobile são comuns. Sem confirmação, uma ação irreversível errada gera frustração e abandono.",
          answer: "Sim — qualquer ação sem desfazer exige confirmação. Ações cobertas: demolir estrutura, cancelar contrato ativo com penalidade, dispensar NPC fixo, aceitar empréstimo de emergência. Dialog usa texto específico (ex: 'Demolir o Armazém A devolve R$ 3.100 em materiais. Essa ação não pode ser desfeita.'). Botão destrutivo à direita em Vermelho Casco (#C43030), botão seguro à esquerda — padrão iOS/Android sem inversão." },
      ],
    },
    {
      category: "♿ Acessibilidade & Inclusão",
      questions: [
        { id: "a13", priority: "média",
          q: "Existe modo de alto contraste ou opção para daltônicos?",
          why: "10% dos jogadores masculinos são daltônicos — afeta alertas de crise, saúde das estruturas e status de contrato.",
          answer: "Duas opções independentes nas configurações. Modo daltônico: substitui Laranja Porto por #E8A21A e Vermelho Casco por #7A2090 em alertas — seguro para deuteranopia e protanopia. Alto contraste: aumenta opacidade dos overlays de HUD, reforça bordas de seleção. Em ambos os modos, ícones nunca dependem só de cor: sempre com forma (triângulo = alerta, círculo = ok, quadrado = neutro). Paleta base (Azul Oceano / Areia Quente) já é segura para a maioria dos tipos de daltonismo." },
        { id: "a22", priority: "média",
          q: "Textos de UI têm tamanho mínimo legível — e existe opção de aumentar fonte?",
          why: "Fonte pequena demais é ilegível em telas de baixa resolução ou para jogadores mais velhos.",
          answer: "Fonte base Inter/Nunito a 14px para UI em inglês/PT-BR. 12px mínimo absoluto. Elementos críticos: recursos no HUD em 16px bold, alertas de crise em 15px bold. Configuração de acessibilidade com três tamanhos (Normal / Grande / Muito Grande) — reescala fontes e ícones de UI sem afetar mapa ou personagens. DynamicFont no Godot 4 escala perfeitamente em qualquer tamanho — sem restrição de múltiplos inteiros como em fontes bitmap." },
        { id: "a23", priority: "alta",
          q: "Alertas de crise comunicam urgência por pelo menos dois canais simultâneos?",
          why: "Depender só de cor falha para daltônicos. Depender só de som falha no mudo.",
          answer: "Nenhum alerta depende de canal único. Informativo: ícone azul no HUD (só visual). Atenção: banner amarelo + ícone ⚠️ + SFX suave. Urgente: banner Vermelho Casco pulsante + ícone 🚨 + SFX de alarme + vibração curta (200ms). Crise total: overlay vermelho nas bordas + ícone 🚨 + trilha muda para tema de crise + vibração longa (500ms). Vibração desativável nas configurações." },
        { id: "a24", priority: "baixa",
          q: "O jogo tem suporte a VoiceOver (iOS) e TalkBack (Android) nos menus principais?",
          why: "Sem nenhum suporte, o jogo é inacessível para jogadores com deficiência visual.",
          answer: "Suporte básico nos menus, sem cobertura do mapa. Coberto: Menu, Configurações, Lista de Contratos, Ficha de NPC, Notificações, Diálogos narrativos. Fora de escopo no MVP: mapa animado, construção e leilões em tempo real. Labels de acessibilidade em todos os botões de UI (AccessibilityNode em Godot 4). Ordem de leitura topo→baixo / esquerda→direita." },
      ],
    },
    {
      category: "🗂️ Menus, Tooltips & Onboarding",
      questions: [
        { id: "a25", priority: "média",
          q: "Tooltips têm tamanho e posição adaptáveis — nunca saem da tela nem ficam atrás do dedo?",
          why: "Tooltip cortado ou escondido pela mão do jogador é problema clássico de UI mobile.",
          answer: "Tooltips abrem na direção oposta ao toque. Largura máxima 240pt, nunca ultrapassa bordas. Fecham com toque em qualquer outra área. Conteúdo sempre em duas linhas: nome (bold, em inglês/PT-BR conforme idioma ativo) + informação mais útil no contexto." },
        { id: "a26", priority: "média",
          q: "Existe glossário in-game para termos portuários (calado, baldeação, praticagem)?",
          why: "BR Port usa vocabulário técnico real. Jogadores casuais — maioria do mercado mobile — não conhecem esses termos.",
          answer: "Sim — ícone ❓ fixo no canto do HUD. Organizado em: Operações portuárias (calado, baldeação, praticagem, manifesto), Mecânicas do jogo (Rivalômetro, três eixos de reputação 0–100, cap de contratos por fase), Personagens (função de cada NPC). Cada verbete em 2–3 linhas + exemplo prático. Disponível em inglês e PT-BR. O glossário é arquivo de localização — não hardcoded — para facilitar tradução futura (Weblate/Crowdin — Tech tab)." },
        { id: "a27", priority: "alta",
          q: "O tutorial pode ser revisitado voluntariamente após a primeira vez?",
          why: "Jogadores que voltam após semanas esquecem mecânicas. Tutorial revisitável tem custo zero de implementação adicional.",
          answer: "Sim — Menu Ajuda → 'Rever tutorial'. Tutorial integrado via Sr. Ribeiro (Sistemas v5.5 — tutorial de 3 semanas in-game), revisitável por módulo: (1) contratos básicos, (2) clima e expansão, (3) Rivalômetro. Módulos acessíveis no HUD real, não ambiente simulado. Badge de concluído mas pode rever livremente. Alinhado com tutorial integrado do Sistemas v5.5 — o Toninho substitui painéis de instrução na cena de abertura (Conceitos v5.5)." },
      ],
    },
  ],

  sound: [
    {
      category: "🎼 Composição & Identidade Sonora",
      questions: [
        { id: "s1", priority: "alta",
          q: "Existe um leitmotif central — uma melodia de 4–8 notas reconhecível em todas as faixas?",
          why: "Um tema forte é o que transforma trilha em memória afetiva (pense em Stardew Valley).",
          answer: "Sim — 6 notas com caráter de apito de navio: 4 ascendentes (esperança, chegada) + 2 descendentes (peso do mar, trabalho real). Base musical: forró de triângulo, zabumba e sanfona (Conceitos v5.5 — 'forró de pé de serra, não o eletrônico'). Aparece em todas as faixas adaptado ao contexto: tema principal (orquestrado completo), crise (4 primeiras notas em modo menor), protagonista (versão lenta em viola caipira), virada de fase (versão jubilosa 2× mais rápida com metais). Regra: qualquer jogador que ouvir 3 faixas deve reconhecer que vieram do mesmo jogo." },
        { id: "s2", priority: "média",
          q: "O protagonista tem um tema musical próprio que aparece nos momentos de cutscene?",
          why: "Cria identidade emocional para o personagem mesmo sem dublagem completa.",
          answer: "Sim — variação do leitmotif central: viola caipira solo + humming (voz sem letra) + pandeiro esparso. Aparece em três momentos exclusivos: tela de título + logo, cutscenes de virada emocional (backstory, primeira grande conquista), créditos finais. Não aparece no loop de gameplay — a ausência preserva o impacto. Conforme Conceitos v5.5: tensão pelo silêncio — 'a música diminui, fica só o triângulo e um baixo discreto' nos momentos de crise, não cresce." },
        { id: "s3", priority: "alta",
          q: "Quão longa é cada faixa antes do loop? Existe variação de arranjo para evitar fadiga auditiva?",
          why: "Loop de 2 min repetido por 30 min é pior que silêncio.",
          answer: "Mínimo de 3 minutos antes do loop, com variação estrutural interna: seção A (60s, tema base em sanfona + triângulo), B (60s, variação harmônica + zabumba entra), A' (45s, contraponto de viola caipira), Bridge (30s, só percussão), retorno ao A. A cada loop o sistema sorteia variações de camada — pandeiro some, linha de baixo fretless aparece. A bridge prepara o retorno ao A de forma que soe como chegada, não repetição. Exceção: Festa de São Pedro tem trilha própria de ciranda com coro ao vivo — única faixa com performance, não ambiente (Conceitos v5.5)." },
        { id: "s4", priority: "média",
          q: "A trilha muda por zona do porto (docas, zona industrial, mangue) além de mudar por estado emocional?",
          why: "Música por zona cria senso de lugar e ajuda o jogador a se localizar no mapa.",
          answer: "Por camadas adicionadas à faixa de contexto atual, não por faixas diferentes. Conforme câmera se aproxima de zona: Docas (ondas, gaivotas, motor de navio em idle), Zona industrial (guindastes metálicos, rádio distante), Mangue (insetos, rã, vento em folhas — sem sons industriais), Bairro Porto Mirim (vozes de mercado, crianças). Sons de zona implementados via AudioStreamPlayer2D posicionais no Godot 4 — fade automático por distância de câmera." },
      ],
    },
    {
      category: "🔊 Efeitos Sonoros & Áudio Ambiente",
      questions: [
        { id: "s5", priority: "alta",
          q: "Qual é a lista mínima de SFX essenciais para o MVP?",
          why: "Definir o conjunto mínimo evita escopo infinito de áudio na produção.",
          answer: "13 SFX essenciais no MVP, organizados por prioridade. Bloqueadores (sem esses o jogo não funciona): toque em botão de UI, erro/ação bloqueada, confirmação/ação bem-sucedida, moeda/receita recebida, alerta de urgência. Essenciais de gameplay: navio chegando, navio partindo, guindaste operando, construção iniciada, construção concluída, trabalhador designado, contrato aceito, contrato entregue. Pós-MVP: caminhão de carga, chuva no metal, gaivota, rádio AM (Conceitos v5.5: 'rádio AM saindo de algum lugar que nunca se localiza exatamente'). Todos os SFX do MVP com menos de 1.5s de duração." },
        { id: "s6", priority: "alta",
          q: "O feedback sonoro de sucesso é diferente do de falha — e os dois são distintos do feedback neutro?",
          why: "Três sons claramente diferentes ensinam o jogador sem texto explicativo.",
          answer: "Sucesso: dois tons ascendentes em terça maior — sino pequeno + cavaquinho pizzicato, 0.4s. Falha/erro: tom descendente único, grave e opaco — madeira batendo, nunca agressivo, 0.3s. Neutro/confirmação simples: clique seco de madeira, sem melodia, 0.15s. Critério de validação: tocar os três para alguém sem contexto e pedir que identifique qual é qual. Se errar, redesenhar. Testado também em mono speaker — ver a_t3 nas especificações técnicas." },
        { id: "s7", priority: "média",
          q: "Como o áudio ambiente escala com o crescimento do porto?",
          why: "Som procedural que reflete o estado do jogo amplifica a sensação de progresso.",
          answer: "Sistema de camadas procedurais indexadas ao estado do jogo. Quatro variáveis controlam o mix: navios atracados (0–max por fase) aumentam volume de motores e guindastes; trabalhadores ativos aumentam vozes de fundo; docas construídas expandem atividade sonora da área portuária; fase atual (1–5) muda o caráter base — Fase 1 quase só mar e vento, Fase 5 industrial em plena operação. Implementado via AudioBus nativo do Godot 4: cada categoria de som em bus separado com volume controlado por variável de estado. O jogador ouve o próprio progresso sem precisar olhar para o HUD." },
        { id: "s8", priority: "média",
          q: "Existe variação aleatória nos SFX para evitar o 'efeito máquina de escrever'?",
          why: "Pitch shift ±5% e 3 variantes de cada SFX resolvem isso com baixo custo.",
          answer: "Duas técnicas combinadas. Pitch shift aleatório: cada SFX toca com variação de ±5% de pitch via AudioStreamPlayer.pitch_scale no Godot 4 — sem novos arquivos. Pool de variantes: SFX de alta frequência (clique de UI, colisão de container) têm 3 variantes cada — escolha aleatória evitando repetir a mesma duas vezes seguidas. SFX raros (apito de navio, sino de contrato) não precisam de variantes — raridade já evita fadiga." },
      ],
    },
    {
      category: "🎚️ Transição & Dinâmica",
      questions: [
        { id: "s9", priority: "alta",
          q: "Como a trilha transita suavemente entre contextos — crossfade, troca no beat, fade out/in?",
          why: "Transição brusca quebra a imersão. Decisão técnica necessária antes da produção de áudio.",
          answer: "Troca sincronizada ao beat com crossfade de 2–4 compassos via Timer node do Godot 4 alinhado ao BPM da faixa atual. Três tipos por urgência: porto ocioso → contrato (crossfade suave, 4 compassos, ~8s); contrato → leilão (crossfade rápido, 2 compassos, percussão entra antes, ~4s); qualquer estado → crise (corte imediato no downbeat + stinger de 1 acorde de metais, <1s). O stinger de crise é a única exceção ao crossfade — o choque é intencional. Resolução da crise: fade out + fade in do estado anterior em 4 compassos. Tensão por silêncio (Conceitos v5.5): durante abordagem do Abutre, a música diminui em vez de crescer — fica só o triângulo e um baixo discreto." },
        { id: "s10", priority: "média",
          q: "A intensidade musical sobe gradualmente conforme o prazo de um contrato se aproxima, ou é binária?",
          why: "Transição gradual cria tensão natural — muito mais eficaz que um alarme binário.",
          answer: "Gradual — 4 estágios indexados ao contrato mais urgente em tela, medido em dias de jogo restantes. Acima de 3 dias de jogo: trilha normal. 2–3 dias: percussão +15% em volume, BPM inalterado. 1 dia: staccato de cordas entra como camada. No último dia: trilha completa de leilão/rivalidade, urgência máxima. O primeiro estágio é imperceptível conscientemente mas cria inquietação sutil. O cálculo é puramente narrativo — sem tempo real." },
        { id: "s11", priority: "alta",
          q: "Quando múltiplos eventos ocorrem ao mesmo tempo (leilão + crise + missão), qual trilha prevalece?",
          why: "Sistema de prioridade de áudio precisa ser definido antes de implementar a engine de música.",
          answer: "Hierarquia fixa de 6 níveis — a trilha de maior prioridade sempre prevalece. P1: crise total (rival age criticamente, tempestade, falência iminente) → orquestra completa. P2: cutscene/evento narrativo → tema do protagonista, interrompe tudo. P3: leilão com prazo < 30min de jogo. P4: contrato em prazo crítico < 30min. P5: contrato em andamento normal → trilha focada/rítmica. P6 (base): porto ocioso → trilha ambiente calma (forró esparso). Quando evento de alta prioridade termina, desce um nível por vez — nunca pula do P1 para P6 diretamente." },
      ],
    },
    {
      category: "♿ Acessibilidade de Áudio",
      questions: [
        { id: "s12", priority: "alta",
          q: "O jogo funciona completamente sem som — existe equivalente visual para todos os alertas sonoros importantes?",
          why: "Jogadores surdos ou em ambientes sem áudio precisam de acesso pleno às informações.",
          answer: "Sim — 100% jogável no mudo. Nenhuma informação crítica chega exclusivamente pelo áudio. Equivalências: apito de navio chegando → ícone animado no HUD; SFX de erro → shake do elemento + borda vermelha; trilha subindo de urgência → banner de prazo + cor do HUD muda; stinger de crise → overlay vermelho pulsante nas bordas; construção concluída → partícula visual + banner '✔ Pronto!'; alerta de rival → ícone do Rivalômetro pisca + notificação. Critério de validação: testador com fone desligado joga sessão completa sem perder informação relevante." },
        { id: "s13", priority: "alta",
          q: "Existe controle separado de volume para música, SFX e voz nos menus de configurações?",
          why: "Padrão da indústria. Jogadores que ouvem música própria desativam trilha mas mantêm SFX.",
          answer: "Quatro sliders independentes via AudioBus do Godot 4: Volume geral (master), Música (trilha dinâmica e tema do protagonista), Efeitos sonoros (todos os SFX de gameplay e UI), Vozes/NPCs (humming e diálogos narrados). Cada slider salva individualmente e persiste entre sessões. Padrão inicial: todos em 80%, não 100% — evita pico no primeiro uso. Jogadores que ouvem Spotify enquanto jogam (segmento real no mercado brasileiro) conseguem desativar música sem perder SFX de gameplay." },
      ],
    },
    {
      category: "🔧 Especificações Técnicas de Áudio (v5.5)",
      questions: [
        { id: "s_t1", priority: "alta",
          q: "Qual engine/middleware de áudio será usado — Godot AudioServer nativo, FMOD ou Wwise?",
          why: "A escolha de middleware impacta custo, complexidade e as features de crossfade e camadas procedurais descritas em s4, s7, s9. FMOD e Wwise custam licença e exigem integração de plugin.",
          answer: "Godot 4 AudioServer nativo. Features necessárias são suportadas nativamente: AudioBus com sends/returns, AudioStreamPlayer com pitch_scale, AudioStreamPlayer2D para som posicional por zona, Timer node para sincronização ao beat. FMOD (free até US$200k receita) e Wwise (free até 200 sounds) adicionam complexidade desnecessária para solo dev. Estrutura de buses: Master Bus → Music Bus → SFX Bus → Voice Bus → Ambient Bus (por zona de mapa). Crossfade implementado via dois AudioStreamPlayers com tweens de volume — sem dependência externa." },
        { id: "s_t2", priority: "alta",
          q: "Qual é o formato de arquivo para trilhas e SFX — e qual o bitrate target?",
          why: "OGG vs WAV vs MP3 afetam qualidade, tamanho e velocidade de carregamento. Definir antes da produção evita reprocessamento de centenas de arquivos.",
          answer: "Trilhas musicais: OGG Vorbis a 96kbps (build mobile) / 128kbps (build Steam PC). Godot 4 suporta OGG Vorbis nativamente sem licença de MP3. SFX curtos (<1.5s): WAV 44.1kHz 16-bit — carregamento instantâneo sem descompressão, ideal para SFX de UI e feedback. SFX médios (1.5–5s): OGG Vorbis a 192kbps. Vozes/humming: OGG Vorbis a 128kbps. Masters de produção (arquivo entregável pelo compositor/sound designer): WAV 44.1kHz 24-bit. Conversão para formatos de build é etapa de CI/CD (script Python com ffmpeg). Naming convention: sfx_[categoria]_[nome]_v[1-3].wav (ex: sfx_ui_click_v1.wav)." },
        { id: "s_t3", priority: "alta",
          q: "Qual é o loudness target para as lojas — e como garantir que o mix soa bem no speaker mono de celular barato?",
          why: "Apple exige -14 LUFS; Google Play -13 LUFS. Speaker de celular entry-level tem resposta de frequência limitada — mix ótimo em headphone pode ser incompreensível no speaker.",
          answer: "Integrated loudness: -16 LUFS para trilhas (conservador — headroom para speakers fracos), -12 dBFS True Peak máximo. SFX: -12 a -6 dBFS de pico. Protocolo obrigatório de speaker: exportar mix mono completo (pan law -3dB) e testar a 30% de volume num iPhone SE ou equivalente Android de baixo custo. Critério de aprovação: todos os SFX de gameplay inteligíveis, leitmotif reconhecível, nenhuma frequência crítica abaixo de 200Hz (speakers de celular não reproduzem). Frequências principais de SFX e melodia devem estar na faixa 250Hz–6kHz. Zabumba e percussão de baixa frequência (graves do forró): reforçadas com ataque de mid em 400–800Hz para soar em speakers pequenos." },
        { id: "s_t4", priority: "média",
          q: "Qual é o orçamento total estimado de áudio — número de faixas, SFX e duração total?",
          why: "Sem esse número, produção de áudio é escopo aberto e pode virar o maior gargalo do projeto solo.",
          answer: "Estimativa MVP (Fases 1–3): Trilhas musicais: 6 faixas × 3–4 min = ~21 min de música original + 8 stingers/transições (0.5–2s cada). SFX gameplay: 13 essenciais × 3 variantes = 39 arquivos + 4 atmosféricos = 43 arquivos de SFX. SFX de UI: 6 sons. Total MVP: ~57 arquivos de áudio. Tamanho comprimido estimado (OGG 96kbps): ~35–40MB. Cronograma sugerido: 6–8 semanas para trilhas (compositor externo), 2 semanas para SFX (biblioteca + gravações originais com instrumentos de forró). Pós-MVP (F4–F5 + sazonais, incluindo trilha própria da Festa de São Pedro com coro ao vivo): +4 faixas, +12 SFX atmosféricos. Total instalado de áudio: ~50MB." },
      ],
    },
  ],

  session: [
    {
      category: "⏰ Tempo de Jogo & Comportamento Offline",
      questions: [
        { id: "ss1", priority: "alta",
          q: "O porto opera em tempo real enquanto o app está fechado — ou pausa quando o jogador sai?",
          why: "Decisão central de filosofia: produção offline (idle game) vs. pausa total (sem punição). Definir isso resolve ss2, ss3 e a maioria das questões de notificação. Atualizado — Sistemas v5.5.",
          answer: "ATUALIZADO (Sistemas v5.5): O porto PAUSA quando o app é fechado. Nada acontece offline. Navios já na fila de espera aguardam até 24h reais sem penalidade — ao retornar, o jogador os encontra onde os deixou. Contratos não vencem durante sessão offline. Esta decisão elimina a mecânica de '8h de produção offline' da v3 anterior. Razão: evita punição por ausência (anti-premium mobile), evita que jogadores acordem para crises que não escolheram. A pressão do jogo vem das parcelas ao banco e dos prazos das missões críticas — gerenciados pelo design, não pelo relógio do sistema operacional (Conceitos v5.5)." },
        { id: "ss2", priority: "alta",
          q: "Contratos com prazo expiram se o jogador não abrir o app? Existe penalidade, aviso antecipado?",
          why: "Punição excessiva por ausência é a principal causa de abandono em jogos mobile.",
          answer: "ATUALIZADO (v5.5 — turn-based): Sem progresso offline. Contratos fixos: prazo medido em dias de jogo, só avança quando o jogador avança o turno. Leilões competitivos: oferecidos com prazo em dias de jogo (3 dias para fazer lance). Cada turno avançado consome 1 dia do leilão. Se o jogador encerra o app no meio de um leilão, o leilão fica congelado — retoma na mesma posição quando o app reabrir. Push opcional pode lembrar que há leilões abertos, mas nunca cria urgência (nada vence enquanto o app está fechado)." },
        { id: "ss3", priority: "média",
          q: "Existe um modo 'férias' que pausa explicitamente eventos competitivos por dias?",
          why: "Jogos que respeitam a vida do jogador têm retenção de longo prazo muito maior.",
          answer: "Sim — 'Porto em Descanso', em Menu → Configurações. Com a pausa automática ao fechar o app (Sistemas v5.5), o modo férias serve especificamente para pausar leilões competitivos que têm prazo em tempo de jogo: sem Modo Férias, um leilão com prazo de 3 dias de jogo expira após 12 min de gameplay acumulado; com Modo Férias, o prazo do leilão fica congelado. Duração: 1 a 30 dias reais definidos pelo jogador. Limite: uma ativação por mês. NPC Seu Biu cuida do cais durante o período com mensagem de retorno." },
        { id: "ss4", priority: "média",
          q: "Como o jogo lida com diferença de fuso horário em eventos globais?",
          why: "Crucial se houver elementos multiplayer ou eventos temporais sincronizados.",
          answer: "Fuso local do dispositivo para a maioria dos eventos. Leilões competitivos: exibidos com dois horários — fuso local do jogador e horário de Brasília (BRT), referência oficial do jogo. Silêncio automático de notificações entre 23h e 8h no horário local (Sistemas v5.5). Para o MVP com foco no mercado brasileiro (PT-BR simultâneo — Tech tab), BRT cobre 95% dos jogadores sem complexidade de servidor global." },
      ],
    },
    {
      category: "🔔 Notificações & Engajamento",
      questions: [
        { id: "ss5", priority: "alta",
          q: "Quais eventos disparam notificação push — e qual é a hierarquia para evitar spam?",
          why: "Notificações demais viram spam e são desativadas. Hierarquia definida — Sistemas v5.5.",
          answer: "CONFIRMADO (Sistemas v5.5): 3 níveis, máx. 2 notificações/dia combinadas dos níveis 1 e 2. Nível 1 crítico (default ativo, não desativável individualmente): navio aguardando doca há +24h, contrato expirando em <2h de jogo, Rivalômetro crítico. Nível 2 oportunista (default ativo, desativável): leilão aberto com carga relevante, NPC com diálogo novo, construção próxima de concluir. Nível 3 informativo (default desativo): rival construiu estrutura, evento sazonal amanhã. Silêncio automático entre 23h e 8h no horário local." },
        { id: "ss6", priority: "média",
          q: "O jogador pode customizar quais notificações receber, ou é tudo ou nada?",
          why: "Controle de notificações aumenta confiança e reduz desinstalações por irritação.",
          answer: "Painel granular em Configurações → Notificações com três opções por tipo: Ativo, Silencioso (aparece na central sem som/vibração) e Desativado. Agrupado por categoria (Construção, Contratos, Rivais, NPCs, Eventos). Botão 'Modo Foco' silencia tudo por 24h sem desativar permanentemente — ideal para reuniões. Após 24h retorna ao padrão anterior automaticamente." },
        { id: "ss7", priority: "média",
          q: "Qual é a frequência ideal de eventos narrativos com NPC por semana de jogo?",
          why: "Narrativa episódica precisa de cadência. Muito frequente = banaliza. Raro = esquece.",
          answer: "Dois eventos por semana de jogo como cadência base. Estrutura: segunda/terça de jogo = diálogo de NPC com impacto leve (dica, oferta, recado); quinta/sexta = evento narrativo com peso emocional ou decision point. Eventos de fim de semana: opcionais, sazonais, sem urgência. Desbloqueados por gatilho de progresso, não por timer puro. Máximo em semanas especiais (Carnaval, Festa de São Pedro — Conceitos v5.5): até 3 eventos com mínimo de 1 dia de jogo de intervalo." },
        { id: "ss8", priority: "baixa",
          q: "Existe recompensa de login diário, ou a progressão natural já é suficiente como motivador de retorno?",
          why: "Login diário pode parecer obrigação. Vale pesar contra o custo de implementação e o tom do jogo.",
          answer: "Não — substituído por 'Recompensa de Retorno', que premia o tempo desde a última sessão produtiva. Retornou após 8h de jogo acumulado: bônus de moral da equipe por 30 min de jogo. Após 24h reais: bônus de moral + notícia positiva de NPC. Após modo férias: cena de reabertura com animação especial. Sistema recompensa ausências sem punir presença constante — alinhado com a filosofia de não-punição offline do Sistemas v5.5." },
      ],
    },
    {
      category: "☁️ Save, Dados & Analítica (v5.5)",
      questions: [
        { id: "ss_save1", priority: "alta",
          q: "Como funciona o save na nuvem — qual plataforma, o que acontece ao trocar de dispositivo ou plataforma?",
          why: "Decisão já tomada no Sistemas v5.5 — precisa ser documentada no GDD de sessão para consistência de UX e comunicação com o jogador.",
          answer: "CONFIRMADO (Sistemas v5.5): Google Play Games (Android) e iCloud (iOS) nativos — gratuito, sem backend próprio, sem custo de infraestrutura. Sincronização automática ao fechar cada sessão. Troca de dispositivo na mesma plataforma: automática ao instalar e logar. Migração entre plataformas (Android → iOS): Menu → Configurações → Exportar Save → arquivo compartilhável. O jogador importa no novo dispositivo. Múltiplos perfis: sim, via configurações — invisível para quem não precisa, um perfil ativo por padrão (Sistemas v5.5). O sistema funciona mesmo se o estúdio parar de operar — sem dependência de servidor proprietário. Comunicar ao jogador: 'Seu progresso está salvo automaticamente na sua conta [Google Play / iCloud].' — uma linha na tela de configurações." },
        { id: "ss_save2", priority: "média",
          q: "Quais eventos serão rastreados por analytics — e qual plataforma de dados será usada?",
          why: "Analytics é a única forma de saber se os sistemas funcionam sem playtests constantes. Sem dados, o balanceamento é baseado em intuição. Definir antes do launch evita dados incompletos retroativamente.",
          answer: "Plataforma: Firebase Analytics (gratuito, SDK disponível para Godot 4 via plugin da comunidade, integrado ao Google Play Console). Eventos críticos rastreados desde o dia 1: session_start (com duração ao encerrar), tutorial_step_complete (para cada módulo de Ribeiro), phase_advance (F1→F2 etc.), contract_accepted, contract_failed, rival_action_triggered, npc_dialog_triggered, game_ending_reached (com qual dos 3 finais). Funil de conversão da demo: demo_launch → fase1_complete → purchase_prompt_shown → purchase_complete (taxa de conversão meta: >12%). Evento de saúde: active_players_per_phase por semana (indica onde jogadores estão travando). O que NÃO rastrear: conteúdo de diálogos, escolhas narrativas individuais (privacidade LGPD). Dashboard mínimo: D1/D7/D30 retention + funil da demo + fases ativas." },
      ],
    },
    {
      category: "📱 App Launch & Sessão Mínima (v5.5)",
      questions: [
        { id: "ss_launch1", priority: "alta",
          q: "Qual é a experiência dos primeiros 10 segundos ao abrir o app — splash, loading, entrada direta?",
          why: "Time to interactive afeta avaliações na loja. <3s é percebido como rápido; >5s como lento. Cold start vs hot start têm experiências diferentes.",
          answer: "Cold start (primeira abertura do dia / após semanas): Splash screen com logo BR Port e leitmotif em sanfona (1.5s) → Boletim do Porto automático com 3 cards (navio, rival, prazo — Sistemas v5.5: 'máximo 5s de leitura') → mapa. Hot start (retorno rápido dentro de minutos): direto para o mapa sem splash — o app nunca reinicia assets que já estão carregados. Target de loading: <3s do ícone ao mapa em dispositivos mid-range (iPhone XR, Samsung A53 3GB RAM). Assets de F1 pré-carregados no install; F2–F5 carregados em background durante a primeira sessão de F1. A tela de título em cold start nunca excede 5s antes de ser interativa — jogador pode tocar para avançar antes do fim da animação de logo." },
        { id: "ss_launch2", priority: "alta",
          q: "O que o jogador consegue fazer numa sessão de 2 minutos — existe uma 'ação mínima valiosa'?",
          why: "Jogadores mobile frequentemente têm 2-3 minutos livres no transporte ou fila. O jogo não pode exigir 10 min de atenção para ser satisfatório — senão o loop de retorno quebra.",
          answer: "Em 2 minutos (30s do Boletim + 90s de ação): o jogador consegue pausar o jogo, ler o boletim, aceitar ou rejeitar 1 contrato, realocar trabalhadores para a tarefa mais urgente e sair — constituindo uma 'sessão de manutenção' válida. O porto avança na direção certa sem crise. Regra de ouro de design: a ação mais urgente do dia deve ser visível sem abrir nenhum submenu — sempre na tela inicial do Boletim ou no HUD. A tela de saída com 3 ganchos (construção, NPC, leilão) funciona mesmo numa sessão de 2 min. O jogo nunca força menus ou popups que impeçam esse fluxo rápido em retornos. Referência: o Boletim do Porto (Sistemas v5.5) foi projetado exatamente para isso — '3 itens em até 5 segundos de leitura'." },
      ],
    },
    {
      category: "📈 Progressão & Dificuldade",
      questions: [
        { id: "ss9", priority: "alta",
          q: "Existe uma curva de dificuldade definida — quando o loop começa a pedir mais decisões simultâneas?",
          why: "Sem curva planejada, o jogo fica fácil demais no início e impossível no meio.",
          answer: "Cinco fases, cinco perfis de complexidade. F1: 1–2 decisões/sessão, só contratos e trabalhadores (cap de 3 contratos — Sistemas v5.5). F2: 2–3, primeiro rival e leilões desbloqueados. F3: 3–4, reputação com peso real e crises climáticas (cap de 6 contratos). F4: 4–5, dois rivais ativos e contratos com interdependências (cap de 8 contratos). F5: 5–6, todos os sistemas ativos simultaneamente (cap de 8–10). Regra central: cada fase introduz um sistema novo e torna o anterior mais automático. Na F5, Zezão gerencia contratos básicos via 'Diário do Porto', liberando o jogador para decisões estratégicas." },
        { id: "ss10", priority: "alta",
          q: "Como o tutorial se integra ao loop sem quebrar o ritmo natural da sessão?",
          why: "Tutorial longo e separado tem taxa de abandono alta. Integrado ao fluxo real é mais eficaz.",
          answer: "CONFIRMADO (Sistemas v5.5 — tutorial integrado via Sr. Ribeiro): Sequência de 3 semanas de jogo, um sistema por semana. Sem 1: contratos básicos + 2 trabalhadores. Sem 2: clima + expansão de espaço. Sem 3: primeiro confronto com Arlindo + Rivalômetro. Cada instrução é um conselho de Sr. Ribeiro, não um painel de tutorial. Moral, sistema noturno e espionagem via Bela: apenas a partir da Fase 2. Onboarding narrativo dos primeiros 15 min: Toninho na chegada, Zezão com o galpão, Seu Biu com o píer, primeiro barco — conforme Conceitos v5.5 (tutorial sem indicador de progresso, sem painel de instrução, sem recompensa ao concluir)." },
        { id: "ss11", priority: "média",
          q: "Existe safety net para o jogador que tomou decisões ruins — empréstimo de emergência, missão de resgate?",
          why: "Sem rede de segurança, falhas catastróficas levam ao abandono. Não é sobre facilidade, é sobre agência.",
          answer: "Três níveis de proteção automáticos. Nível 1 — Aviso precoce (caixa < 20% do necessário para próxima parcela): Zezão sugere qual contrato aceitar via balão de diálogo. Nível 2 — Empréstimo de emergência (caixa zerada, porto parado): Sr. Ribeiro oferece empréstimo via diálogo narrativo — um botão, uma confirmação. Nível 3 — Missão de resgate (espiral de dívida): evento especial com contrato emergencial de alto valor justificado narrativamente. Falência forçada é arco narrativo, não tela de game over (Sistemas v5.5 — 'aceitar resgate do Abutre é o único final ruim')." },
        { id: "ss12", priority: "alta",
          q: "O Rivalômetro tem impacto real na dificuldade ou é puramente narrativo/cosmético?",
          why: "Se não tem dente, perde significado rapidamente.",
          answer: "CONFIRMADO (Sistemas v5.5): Impacto concreto. Mercado de contratos: Rivalômetro alto = rival vê melhores contratos primeiro. Leilões: rival dominante dá lances até 30% mais agressivos. Escalonamento em 3 atos quando ignorado: 1º crítico ignorado → rival fecha melhor contrato da semana. 2º → boato derruba reputação por 5 dias. 3º → evento narrativo obrigatório com penalidade permanente (Sistemas v5.5). A IA rival usa script por fase com gatilhos reativos — ex: dominar todos os leilões por 3 dias seguidos aciona campanha de boatos do Arlindo." },
      ],
    },
    {
      category: "🔁 Gancho & Retenção",
      questions: [
        { id: "ss13", priority: "média",
          q: "Qual é o gancho máximo simultâneo — quantos 'algo vai acontecer quando eu voltar' existem ao mesmo tempo?",
          why: "Um gancho é fraco. Três é ótimo. Dez é ansiedade.",
          answer: "Exatamente três ganchos ativos ao fechar o jogo — sistema seleciona e prioriza automaticamente. Hierarquia: 1º construção com tempo definido (mais tangível), 2º evento narrativo agendado de NPC, 3º oportunidade competitiva (leilão futuro). Tela de saída exibe os três como cards visuais — não texto de sistema. Se houver menos de três eventos reais, o jogo não inventa. Forçar ganchos falsos treina o jogador a ignorar todos. CONFIRMADO (Sistemas v5.5): Boletim do Porto ao reabrir exibe os 3 itens de retorno em até 5 segundos." },
        { id: "ss14", priority: "baixa",
          q: "O jogador pode planejar a próxima sessão antes de fechar — tipo 'definir prioridades para amanhã'?",
          why: "Dar ao jogador controle sobre o futuro aumenta comprometimento com o retorno.",
          answer: "Sim — função 'Deixar Ordens', acessível na tela de saída. O jogador define até 3 instruções (ex: 'Quando o guindaste ficar pronto → iniciar Armazém B', 'Se contrato de pesca > R$8.000 aparecer → aceitar automaticamente'). As ordens são executadas quando o jogador retoma a sessão e confirma o avanço de tempo. Não é automação total — o jogador ainda retorna para ajustes táticos e NPCs. Transforma a saída do jogo num ato de planejamento intencional." },
      ],
    },
  ],

  map: [
    {
      category: "🏗️ Construção & Layout",
      questions: [
        { id: "m1", priority: "alta",
          q: "O jogador pode desfazer ou mover uma estrutura já construída? Se sim, qual é o custo?",
          why: "Irreversibilidade frustrante leva ao abandono. Mas desfazer sem custo remove peso das decisões.",
          answer: "Mover: permitido com custo de 25% dos recursos originais e metade do tempo de construção — estrutura fica inoperante durante a mudança. Janela de graça: primeiros 10 min após construção, mover é gratuito e instantâneo. Demolição com custo escalonado: construída há <24h de jogo = 75% de recuperação; construída há >30 dias de jogo = 40% (Sistemas v5.5 confirma: 50% padrão, construções herdadas do avô = 30% — o jogo reflete o custo emocional de apagar a história)." },
        { id: "m2", priority: "alta",
          q: "Existe snap-to-grid automático, posicionamento livre, ou encaixe inteligente por tipo?",
          why: "Define toda a UX de construção — deve ser decidido antes de implementar qualquer outra feature de mapa.",
          answer: "CONFIRMADO (Sistemas v5.5): grid com snapping automático. Células de 64×64px, estruturas em 1×1, 2×1 ou 2×2 células. Encaixe inteligente por tipo: docas fazem snap à linha d'água; armazéns fazem snap às bordas de estruturas adjacentes; torre de controle exibe raio de cobertura em tempo real durante arrastar (verde/amarelo/vermelho). Estradas internas conectam-se automaticamente ao tile de estrada mais próximo. O jogador arrasta e solta — o Godot 4 TileMap cuida do alinhamento via snapping nativo." },
        { id: "m3", priority: "alta",
          q: "Como funciona a demolição — o que é recuperado? Existe diferença para construção própria vs herdada?",
          why: "Jogadores cometem erros de layout. A penalidade define se aprendem ou se frustram.",
          answer: "CONFIRMADO (Sistemas v5.5): 50% dos recursos recuperados para construções próprias. Construções herdadas do avô: 30% — custo emocional mecanicamente representado. Escala de tempo: <24h de jogo = 75%, >30 dias = 40%. Dialog de confirmação obrigatório com valor calculado em tempo real: 'Demolir o Armazém B devolve R$ 3.100 em materiais. Confirmar?' Botão destrutivo em Vermelho Casco à direita, seguro à esquerda." },
        { id: "m4", priority: "média",
          q: "Estruturas podem ser rotacionadas (90°, 180°) ou só têm uma orientação fixa?",
          why: "Rotação multiplica as possibilidades de layout sem adicionar novos assets.",
          answer: "4 direções com botão de rotação durante o drag — a estrutura gira visualmente em tempo real antes de confirmar. Implicações estratégicas: armazéns mudam orientação da porta de acesso (impacta fluxo de trabalhadores via NavigationPolygon — ver m_nav1); guindastes mudam o lado do braço (impacta qual navio pode ser atendido); docas têm apenas 2 orientações válidas (paralela ou perpendicular à linha d'água); torre de controle é simétrica — rotação apenas cosmética." },
        { id: "m5", priority: "média",
          q: "Existe terraplanagem ou modificação do terreno, ou o terreno é totalmente fixo?",
          why: "Modificação de terreno abre camadas estratégicas mas aumenta complexidade técnica.",
          answer: "Dois tipos específicos — sem terraplanagem livre. Dragagem (aprofundar linha d'água): desbloqueada na F2, permite docas médias e grandes, custo alto de recursos e tempo, permanente (altera o NavigationPolygon da zona de docas). Aterro portuário (avançar sobre o mar): desbloqueado na F3, expande área de docas além do grid original, limitado a 2 células de avanço por fase. Aterro cria células de 'cais novo' com textura diferente da terra original. Terraplanagem livre: fora de escopo do MVP." },
      ],
    },
    {
      category: "🗺️ Expansão & Fases",
      questions: [
        { id: "m6", priority: "alta",
          q: "Haverá múltiplos mapas jogáveis ou apenas um mapa que evolui ao longo de todas as fases?",
          why: "Um mapa evolutivo é mais coeso narrativamente; múltiplos mapas dão variedade. Decisão de escopo.",
          answer: "Um único mapa evolutivo para o jogo base — Porto Mirim é protagonista tanto quanto o personagem. CONFIRMADO (Sistemas v5.5): expansão em L, crescendo para a direita (terra/cidade) e para o sul (mar). F1: 8×6 células. F2: 12×8. F3: 16×10. F4: 20×12. F5: 24×14 + área estaleiro separada. O cais original do avô fica sempre no canto noroeste — âncora visual da narrativa. Pós-F5 (DLC pago): segundo mapa em outra região do litoral." },
        { id: "m7", priority: "alta",
          q: "Como novas áreas construtíveis são desbloqueadas — por compra com recursos, missão, tempo ou fase?",
          why: "O gatilho de expansão define o ritmo de progressão e o tipo de motivação do jogador.",
          answer: "CONFIRMADO (Sistemas v5.5): gatilho duplo — marco de fase atingido + critério narrativo (evento específico). Não é possível avançar apenas com dinheiro antes da semana mínima. F1→F2: zona industrial leste desbloqueada ao concluir tutorial + construir oficina. F2→F3: litoral norte + nova faixa de doca ao atingir reputação 600 + completar rota com Praia Grande. F3→F4: expansão urbana de Porto Mirim ao atingir reputação 1.400 + parcela 2 paga. F4→F5: zona industrial sul + canal ao atingir reputação 3.000 + 3 contratos de grande porte entregues. Expansão aparece com animação de névoa se dissipando (referência a mapas de estratégia clássicos)." },
        { id: "m8", priority: "média",
          q: "Existe limite máximo de tamanho de porto, ou a expansão pode continuar além da Fase 5?",
          why: "Jogadores longa data precisam saber se existe 'fim' ou se o jogo é endless.",
          answer: "O mapa tem limite físico em F5 (24×14 + estaleiro) — morros ao norte, mangue ao sul (Conceitos v5.5: área ambiental intocável sob pena de queda de reputação) e cidade a leste são barreiras permanentes comunicadas narrativamente. Após o mapa completo, o jogo entra em modo de aprofundamento: sem novos tiles, mas com melhorias verticais (guindastes mais rápidos, armazéns com maior capacidade). O fim narrativo é a conclusão dos 3 atos e um dos 3 finais disponíveis (Sistemas v5.5: vender, manter, unificar)." },
        { id: "m9", priority: "média",
          q: "A cidade de Porto Mirim cresce e muda visualmente conforme o porto progride?",
          why: "A cidade reagindo ao sucesso do jogador é uma das recompensas mais imersivas possíveis.",
          answer: "CONFIRMADO (Sistemas v5.5 — mecânica leve e passiva): 5 estados visuais automáticos. F1: casas simples, mercado de peixe, rua de terra. F2: rua calçada, bar novo na esquina. F3: comércio diversificado, praça central, iluminação pública; turistas aparecem (Conceitos v5.5). F4: prédios de 2 andares, escola, posto de saúde; Porto Mirim vira atração. F5: cidade vibrante, hotel à beira-mar, aeroporto. Muda automaticamente ao avançar de fase. NPCs comentam as mudanças. A reputação alta com a comunidade é pré-requisito de algumas evoluções (mangue protegido, câmara municipal positiva)." },
      ],
    },
    {
      category: "⚓ Docas & Logística",
      questions: [
        { id: "m10", priority: "alta",
          q: "Docas têm tamanho fixo ou o jogador pode construir docas maiores para navios maiores em fases avançadas?",
          why: "Define a progressão de capacidade logística — um dos eixos de crescimento do jogo.",
          answer: "Três tamanhos de doca, desbloqueados por fase. Doca pequena (F1): botes de pesca e balsas, ocupa 2×1 células (128×64px no grid de 64px do Sistemas v5.5). Doca média (F2): cargueiros e ferries, ocupa 2×2 células. Doca grande (F4): navios-tanque e grandes cargueiros, ocupa 3×2 células. Docas antigas não são substituídas automaticamente — o jogador escolhe manter as pequenas (mais contratos, mais rotatividade) ou demolir e construir maiores (contratos de alto valor, menos slots). Este dilema entre especialização e diversificação logística é um dos eixos estratégicos centrais do jogo." },
        { id: "m11", priority: "média",
          q: "Como funciona o congestionamento de docas — existe fila visual de navios esperando?",
          why: "Filas visíveis criam tensão orgânica sem necessitar de alertas de texto.",
          answer: "Fila visual obrigatória no tile de fundeadouro. Navios aguardam com animação de idle (balanço suave, fumaça em idle). Fila máxima: 3 navios no fundeadouro por fase — o quarto é redirecionado (contrato perdido, queda de reputação leve). Cada navio em fila exibe timer visual com contagem regressiva. ATUALIZADO (Sistemas v5.5): navios aguardam até 24h reais sem penalidade quando app está fechado — a fila visual persiste ao reabrir." },
        { id: "m12", priority: "média",
          q: "A estrada de acesso pode ser melhorada ou é sempre o mesmo gargalo de capacidade?",
          why: "Estrada como recurso limitado cria decisões estratégicas de layout muito interessantes.",
          answer: "Dois upgrades sequenciais desbloqueados por fase. Estrada original (F1–F2): 2 caminhões simultâneos, asfalto simples. Estrada ampliada (F3): 4 caminhões, pista dupla. Via expressa portuária (F5): 8 caminhões + trilho de carga lateral. Upgrades construídos sobre o tile existente via upgrade in-place (Sistemas v5.5: estruturas principais têm até 3 níveis de upgrade in-place). A via expressa muda visualmente a silhueta do mapa — uma das estruturas mais imponentes visualmente." },
      ],
    },
    {
      category: "🏴‍☠️ Rivais & Presença no Mapa",
      questions: [
        { id: "m13", priority: "alta",
          q: "Os rivais aparecem no mesmo mapa do jogador ou em mapas paralelos que influenciam indiretamente?",
          why: "Presença física no mesmo mapa é mais imersiva mas multiplica a complexidade técnica.",
          answer: "Mapas paralelos com influência indireta — sem presença física no mapa de Porto Mirim. Os rivais têm portos próprios mencionados narrativamente e visíveis no Mapa do Litoral (desbloqueado na F2 — Conceitos v5.5). A presença é sentida por três canais: mercado (contratos aceitos pelo rival somem da lista), Rivalômetro (ícone compacto no HUD que muda de cor — Sistemas v5.5) e narrativa (Bela noticia o que o rival está construindo)." },
        { id: "m14", priority: "média",
          q: "É possível visitar o porto de um rival — e o que o jogador pode ver lá?",
          why: "Visitar rival é motivação de comparação social — poderosa para retenção se bem implementada.",
          answer: "Sim — visita de reconhecimento via missão paga com a Bela (Sistemas v5.5 — 'espionagem via missões pagas com a repórter, disponível a partir da Fase 2'). O jogador vê: layout congelado na última sincronização, nível de cada estrutura principal, 3 contratos recentes concluídos e comentário de NPC local sobre o rival. Não vê: caixa, reputação exata, contratos em andamento. Cooldown de 48h de jogo. Principal valor: ver o porto do rival concretamente motiva a melhorar o próprio." },
        { id: "m15", priority: "baixa",
          q: "Existe um mapa regional mostrando todos os portos da área — uma visão geopolítica?",
          why: "Macro-mapa transforma o jogo individual em narrativa coletiva.",
          answer: "Sim — 'Mapa do Litoral', desbloqueado na F2 (Conceitos v5.5: regiões com desbloqueios progressivos — Praia Grande na sem. 3, Foz do Tucunaré/Porto Seco na sem. 6, Ilha das Pedras Brancas na sem. 8, Capital Regional na sem. 10). Exibe vista estilizada do litoral com portos como ícones; portos rivais com cor do Rivalômetro; rotas marítimas como linhas animadas; zonas de influência coloridas. Não em tempo real — atualizado por progressão de jogo." },
        { id: "m16", priority: "média",
          q: "Rivais podem sabotar fisicamente o mapa do jogador ou só competem por contratos?",
          why: "Sabotagem direta é emocionante mas pode ser percebida como injusta se mal calibrada.",
          answer: "Não o mapa físico. Sabotagem operacional via Rivalômetro > 80% (F3+): três ações possíveis de Arlindo (uma por semana de jogo): atraso de navio 2h, encarecimento de material por 24h, rumor que derruba reputação 5 pontos por 12h. Cada ação é sempre identificada (Sistemas v5.5: 'o jogador é sempre notificado de quem agiu — nunca parece azaração aleatória'). Bela pode avisar antes de ações do Grupo Atlântico se reputação com ela for > 70 (Conceitos v5.5)." },
      ],
    },
    {
      category: "🤖 Navegação & Comportamento de Entidades (v5.5)",
      questions: [
        { id: "m_nav1", priority: "alta",
          q: "Qual algoritmo de pathfinding os trabalhadores usam — e como se comportam com obstáculos dinâmicos recém-construídos?",
          why: "Sem spec de pathfinding, o comportamento de trabalhadores é imprevisível e difícil de debugar em produção. Em um jogo onde o layout muda constantemente (construção, demolição), o pathfinding precisa de rebuildamento dinâmico.",
          answer: "NavigationAgent2D nativo do Godot 4 com NavigationPolygon gerado proceduralmente sobre o TileMap. Godot 4 usa A* interno com suavização de caminho. O NavigationPolygon é rebuildado em thread separado ao construir ou demolir estrutura — operação dura <100ms em F1, <300ms em F5, sem freezar o frame principal. Obstáculos dinâmicos (navios atracando, outros workers): cada worker desvia ao chegar a 1 célula de distância do obstáculo. Se o caminho for completamente bloqueado por 3 segundos reais, o worker aguarda e tenta rota alternativa a cada 5s — sem loop infinito de tentativas. Limite de densidade: máximo 1 worker em trânsito por célula de 64×64px. Segundo worker usa rota alternativa automaticamente via prioridade por tempo de espera." },
        { id: "m_nav2", priority: "alta",
          q: "O que fazem os trabalhadores sem tarefa designada — ficam parados, voltam a um ponto base ou têm comportamento procedural?",
          why: "Trabalhadores parados quebram a ilusão de porto vivo. Vagando aleatoriamente, parecem bugados. O comportamento idle é a principal diferença visual entre um porto vivo e um screenshot estático.",
          answer: "Comportamento idle em 3 fases: (1) Retorno ao ponto base (2s): worker caminha até a zona da estrutura principal da sua função (estivadores → galpão/armazém; mecânicos → oficina naval; guardas → portaria). (2) Idle animado em loop de 4–8s: animações variadas aleatórias — examinar ferramenta, olhar para o horizonte, conversar com NPC adjacente se outro worker estiver no mesmo ponto base, varrer um tile adjacente. Cada tipo de worker tem 3 animações idle distintas. (3) Indicação de disponibilidade: círculo verde translúcido discreto sob o sprite, visível apenas no Zoom 2 e 3 — indica 'disponível para tarefa' sem poluir a visão geral. Workers com moral baixa têm animação idle distinta (ombros caídos, movimentos mais lentos) — feedback visual de gestão sem necessitar de UI adicional." },
        { id: "m_nav3", priority: "alta",
          q: "Qual é o limite definitivo de docas por fase — a 'X' do placeholder na descrição das zonas de doca?",
          why: "O placeholder 'Até X docas simultâneas' precisa ser preenchido antes da produção do sistema de logística e do balanceamento de contratos. A linha d'água determina o espaço físico disponível; o grid do Sistemas v5.5 define a matemática.",
          answer: "RESOLVIDO — calculado a partir do grid do Sistemas v5.5 (linha d'água = borda sul do grid, largura varia por fase): F1 (linha d'água: 8 células): máximo 4 docas pequenas (2×1 células cada = 8 células totais). F2 (12 células): máximo 3 docas médias (2×2) + 2 pequenas, ou 6 pequenas. F3 (16 células): máximo 2 docas grandes (3×2) + 2 médias + 2 pequenas, ou 4 médias + 4 pequenas. F4 (20 células): máximo 4 docas grandes + 2 médias, ou 5 grandes + 2 pequenas. F5 (24 células + área estaleiro separada): máximo 6 docas grandes no mapa principal + 4 slots de atracação no estaleiro. Regra de design: a restrição de capacidade logística (número de trabalhadores e guindastes) deve ser atingida antes da restrição de espaço físico nas fases iniciais — o jogador não deve se sentir limitado por espaço em F1–F2." },
      ],
    },
  ],

  tech: [
    {
      category: "🖥️ Engine & Build",
      questions: [
        { id: "t1", priority: "alta",
          q: "Qual engine e versão são usados — e quais plugins essenciais são necessários?",
          why: "Documento canônico da engine para alinhamento entre todos os GDDs. O Sistemas v5.5 referencia Godot 4 (z_index via CanvasItem, NavigationAgent2D) sem nomear explicitamente — aqui fica a decisão formal.",
          answer: "Godot 4.2+ LTS (versão LTS ativa no início da produção). Razão: gratuito, MIT license, pipeline 2D nativo excelente (TileMap, NavigationAgent2D, AudioBus), exportação oficial para Android e iOS sem SDK externo, GDScript com sintaxe Python-like acessível para solo dev. Plugins essenciais: godot-firebase (analytics via Firebase — ss_save2), GodotSteam (build Steam futuro — monetização v5.5). Recursos nativos do Godot 4 confirmados em outros GDDs: z_index automático para depth sorting (mapa top-down 30°), AudioStreamPlayer2D para som posicional por zona, NavigationAgent2D com NavigationPolygon para pathfinding de workers, TileMap para grid de 64×64px, CanvasLayer para HUD separado do viewport do jogo. Target de build: APK para Google Play, IPA via Xcode Cloud para App Store." },
        { id: "t2", priority: "alta",
          q: "Quais são as versões mínimas de iOS e Android suportadas — e quais são os dispositivos de teste prioritários?",
          why: "Versão mínima define o mercado atingível e os recursos de hardware disponíveis. No Brasil, Android 8–10 ainda representa parcela significativa do mercado ativo.",
          answer: "iOS 15.0 mínimo: cobre ~97% de iPhones ativos (suporte oficial do Godot 4, Metal API). Android 8.0 (API 26) mínimo: cobre ~92% de Androids ativos, garante Vulkan support para o renderer do Godot 4. RAM mínima testada: 2GB Android, 3GB iOS. Resolução mínima: 375×667pt (iPhone SE 2020 — referência de a12). Dispositivos de teste por perfil: Low-end (Samsung Galaxy A14, Android 8, 3GB RAM), Mid-range (iPhone XR, 3GB RAM), High-end (iPhone 15, Pixel 8). Esses 3 dispositivos cobrem ~80% do hardware do público-alvo no Brasil. Emuladores para cobertura de versões de Android sem hardware físico: Android Emulator no Android Studio." },
        { id: "t3", priority: "média",
          q: "Como é o processo de build e deployment — CI/CD, assinatura, certificados — para solo dev?",
          why: "Solo dev precisa de pipeline simples mas confiável para não perder dias em problemas de build antes de cada release. Definir antes de chegar ao ponto de ter builds para distribuir.",
          answer: "CI/CD: GitHub Actions com Godot export server. Pipeline: push para branch main → build automático de APK (Android) e IPA (iOS) → upload para Firebase App Distribution para playtests internos. Release para lojas: APK exportado localmente para Google Play Console (abre canal próprio para Android — Sistemas v5.5); IPA via Xcode Cloud para App Store (Apple Developer Program, US$99/ano). Assinatura Android: keystore armazenado em GitHub Secrets — nunca versionado. Godot export templates instalados via versão pinada no repositório para builds reproduzíveis independente de máquina. Tempo de build estimado: ~10 min Android, ~20 min iOS em máquina local M-series. Versão de build numerada semanticamente: MAJOR.MINOR.PATCH (ex: 1.0.3)." },
      ],
    },
    {
      category: "📊 Targets de Performance",
      questions: [
        { id: "t4", priority: "alta",
          q: "Qual é o FPS alvo, consumo de bateria aceitável e RAM máxima por perfil de dispositivo?",
          why: "Sem targets definidos, qualidade técnica é avaliada subjetivamente. Targets numéricos permitem testes automatizados e decisões de escopo com critério objetivo.",
          answer: "FPS: 60fps estável em high-end, 30fps estável em mid-range, 30fps com degradação controlada de efeitos em low-end (nunca crash, nunca freeze >2s). Consumo de bateria: ≤ 8% por hora de sessão em mid-range (equivalente a streaming de música, não de vídeo — Godot 4 2D tem consumo de GPU baixo para este tipo de jogo). RAM: ≤ 350MB em F1–F3, ≤ 450MB em F4–F5 (expansão do NavigationPolygon e sprite atlas). Testes de performance: PerformanceMonitor do Godot (Physics FPS, Draw Calls, Object Count, Memory Used) medido em release build, não em editor, em cada dispositivo de teste. Limite de draw calls por frame: ≤ 120 em F1, ≤ 200 em F5 (controlado pelo sprite atlas único por fase e pelo CanvasItem.z_index batching)." },
        { id: "t5", priority: "alta",
          q: "Qual é o tamanho máximo do APK inicial e do app instalado — e qual é a estratégia de compressão?",
          why: "Tamanho do app afeta conversão antes de ser aberto. No Brasil, dispositivos com 32–64GB são comuns em Android entry-level, e dados móveis têm franquias limitadas.",
          answer: "Download inicial (F1 + tutorial): ≤ 80MB. Total instalado (todas as fases + áudio completo): ≤ 200MB. Estratégia de compressão: texturas em ETC2 (Android) e ASTC (iOS) via Godot export presets — redução de ~55% do tamanho bruto de PNG. Áudio: OGG Vorbis a 96kbps em mobile (vs 128kbps no PC Steam). Sprites organizados em atlas único por fase (4096×4096px max) para reduzir overhead de textura. Assets de F3–F5: incluídos no APK comprimidos, descomprimidos na primeira execução de cada fase — sem download adicional pós-install (simplifica QA e evita dependência de CDN). Meta de comparação: Stardew Valley mobile ~350MB instalado; BR Port como mobile-native deve ficar significativamente abaixo." },
      ],
    },
    {
      category: "🌐 Localização & Idioma",
      questions: [
        { id: "t6", priority: "alta",
          q: "O jogo é lançado em inglês com PT-BR simultâneo ou PT-BR vem como update posterior?",
          why: "Decisão do Conceitos v5.5: 'Língua principal: Inglês — mercado global.' Mas a identidade cultural é brasileira e o mercado BR pode ser o maior. Lançar só em inglês pode perder o público local; lançar só em PT-BR limita o alcance global.",
          answer: "Lançamento simultâneo em EN-US e PT-BR. O Brasil tem 160+ milhões de usuários de smartphone e é o principal mercado-alvo natural para uma IP com identidade cultural brasileira. Estratégia técnica: textos de jogo em arquivos de localização CSV desde o início (nunca hardcoded no código) — permite adicionar idiomas sem refatoração. EN-US como idioma padrão no código; PT-BR como primeiro arquivo de localização paralelo no build. Ferramenta: Weblate (open-source) integrado ao GitHub para facilitar revisões. Idiomas futuros planejados: ES-LATAM (mercado latino, pós-lançamento), PT-PT (opcional). A identidade sonora (forró, zabumba, humor regional dos NPCs) permanece independente do idioma de texto — é sempre brasileira." },
        { id: "t7", priority: "média",
          q: "Como os nomes dos NPCs e expressões culturalmente específicas são tratados na versão em inglês?",
          why: "Nomes como 'Seu Biu', 'Dona Cida', 'Zezão' e expressões como 'chefia' são culturalmente específicos. Tradução direta perde o sabor sem ganhar compreensibilidade para o público internacional.",
          answer: "Nomes dos NPCs: permanecem em português em todas as versões (Seu Biu, Zezão, Dona Cida, Kinha, Toninho) — são proper names, não traduzidos. Títulos de tratamento (Seu, Dona): mantidos em português em itálico na versão EN como marcadores culturais explícitos. Expressões regionais: adaptadas preservando ritmo e personalidade — não tradução literal. Exemplo canônico (Conceitos v5.5): 'O cais tá no vermelho, chefia. Mas que vermelho bonito...' → EN: 'The dock's in the red, boss. But what a gorgeous shade of red...' — tom, timing e ironia preservados. A palavra 'boss' substitui 'chefia' como vocativo de autoridade irônica. Um Localization Glossary (PT-BR → EN) é documento separado construído com o roteirista antes de qualquer tradução ser feita. Revisão por falante nativo de EN-US familiar com cultura brasileira — não apenas tradução direta." },
      ],
    },
  ],
};

/* ══════════════════════════════════════════════════════
   DADOS ESTÁTICOS DO GDD
══════════════════════════════════════════════════════ */
const COLOR_SWATCHES = [
  { name: "Azul Oceano",    hex: "#2B7FBF", use: "Mar, water tiles, ícones de doca, UI de contratos" },
  { name: "Laranja Porto",  hex: "#E8621A", use: "Guindastes, alertas atenção, ações primárias de HUD, botões CTA" },
  { name: "Verde Mangue",   hex: "#3A9E52", use: "Vegetação, reputação positiva, construção concluída, confirmações" },
  { name: "Areia Quente",   hex: "#E8C97A", use: "Praia, terra, cais velho, fundo de painéis de diálogo" },
  { name: "Vermelho Casco", hex: "#C43030", use: "Navios cargueiros, alertas críticos, dívida, botões destrutivos" },
  { name: "Branco Espuma",  hex: "#F0F0E8", use: "Texto primário, espuma, luz de dia, fundo de tooltips" },
  { name: "Roxo Noite",     hex: "#3D2A6E", use: "Céu noturno, sombras, fundo do HUD em modo noite" },
  { name: "Cinza Concreto", hex: "#7A7A72", use: "Calçada, muros, píer, elementos neutros de UI" },
];

const SESSION_STEPS = [
  { num: "01", time: "0–2 min", icon: "🔔", title: "Abrir & Boletim do Porto",
    color: "#c4470a",
    actions: [
      "Boletim automático: 3 itens em ≤ 5s (navio, ação rival, prazo urgente)",
      "Checar Rivalômetro — ícone colorido no HUD indica nível de ameaça",
      "Ler mensagem de NPC se houver evento narrativo agendado",
    ],
    feel: "Sensação de urgência suave — algo sempre aconteceu desde a última sessão. Equivale a ~30s de jogo em 1×." },
  { num: "02", time: "2–5 min", icon: "👷", title: "Pausar & Alocar Trabalhadores",
    color: "#2d7a3a",
    actions: [
      "Pausar o jogo (4 min reais = 1 dia de jogo — pode pausar a qualquer momento)",
      "Redistribuir equipes: carga × reparo × construção",
      "Verificar fila de navios no fundeadouro — quem entra primeiro?",
    ],
    feel: "Decisão tática central. A pausa é gratuita e mantém todos os menus ativos — design de 10–20 min por sessão típica." },
  { num: "03", time: "5–8 min", icon: "📋", title: "Contratos & Leilões",
    color: "#1a5c8a",
    actions: [
      "Revisar lista de contratos fixos disponíveis na Bolsa do Porto",
      "Aceitar, recusar ou deixar em aberto por 24h de jogo",
      "Se houver leilão ativo: analisar rival e dar lance antes do prazo",
    ],
    feel: "Momento de estratégia — qual contrato cabe na capacidade atual? Uma semana completa de jogo ≈ 28 min de sessão em 1×." },
  { num: "04", time: "8–10 min", icon: "🏗️", title: "Construir & Sair",
    color: "#6a3480",
    actions: [
      "Iniciar construção de melhoria ou nova estrutura no grid",
      "Definir 'Deixar Ordens' para a próxima sessão (opcional)",
      "Tela de saída: 3 ganchos visuais — construção, NPC, leilão",
    ],
    feel: "Gancho para retorno. O jogador sai sabendo o que vai encontrar. Ação mínima válida em 2 min: aceitar 1 contrato + realocar workers." },
];

const MAP_ZONES = [
  { id: "fixas", label: "Zonas Fixas", color: "#1a5c8a",
    desc: "Determinadas pela geografia do mapa — não podem ser movidas ou construídas sobre.",
    items: [
      { icon: "🌊", name: "Linha d'água", desc: "Onde as docas precisam estar. Define o eixo principal do porto. Largura cresce de 8 células (F1) a 24 células (F5)." },
      { icon: "🛣️", name: "Estrada de acesso", desc: "Rota fixa de caminhões. Não pode ser bloqueada por construções. Upgradável in-place (F3: ampliada, F5: via expressa)." },
      { icon: "🏘️", name: "Bairro Porto Mirim", desc: "Cidade já existe — evolui automaticamente em 5 estados visuais conforme o porto progride. Sem gestão ativa." },
      { icon: "🌴", name: "Mangue protegido", desc: "Área ambiental intocável. Construir aqui gera queda de reputação comunitária permanente. Arco narrativo central do Ato 2." },
    ],
  },
  { id: "livres", label: "Áreas Livres", color: "#c4470a",
    desc: "O jogador posiciona livremente dentro dos limites de cada zona — snap-to-grid de 64×64px.",
    items: [
      { icon: "🏗️", name: "Zona industrial", desc: "Galpões, guindastes, oficinas — posicionamento livre. Cresce para a direita a cada fase (expansão em L — Sistemas v5.5)." },
      { icon: "⚓", name: "Zona de docas", desc: "F1: 4 docas pequenas max. F2: 3 médias + 2 pequenas. F3: 2 grandes + 2 médias + 2 pequenas. F4: 4 grandes + 2 médias. F5: 6 grandes + estaleiro separado." },
      { icon: "🏢", name: "Zona administrativa", desc: "Escritório (desbloqueia F2), Torre de Controle (única no mapa — cap hard), Aduana (única). Locais de gestão e burocracia." },
      { icon: "🌆", name: "Expansão urbana", desc: "Conforme o porto cresce, áreas da cidade se tornam construtíveis. Pré-requisito: reputação comunitária específica por fase." },
    ],
  },
];

const SOUND_LAYERS = [
  { context: "Porto ocioso", mood: "Calmo e vivo", instruments: "Sanfona + triângulo suaves, sons de mar", desc: "Forró esparso com camadas de porto: gaivotas, ondas, rádio AM distante (Conceitos v5.5)." },
  { context: "Contrato em andamento", mood: "Focado, rítmico", instruments: "Zabumba + baixo fretless + cavaquinho", desc: "Ritmo sutil aumenta levemente — sensação de produtividade sem ansiedade." },
  { context: "Leilão / rivalidade", mood: "Tenso, dramático", instruments: "Cordas em pizzicato + percussão crescente + metais", desc: "Música sobe em intensidade conforme o prazo do leilão se aproxima (4 estágios graduais)." },
  { context: "Evento de crise", mood: "Urgente — stinger de 1 acorde", instruments: "Corte imediato no downbeat + acorde de metais (<1s)", desc: "Crise por silêncio (Conceitos v5.5): a música diminui, fica só o triângulo e um baixo discreto. Stinger de impacto para eventos de crise total." },
  { context: "Missão narrativa / cutscene", mood: "Emotivo, brasileiro", instruments: "Viola caipira solo + humming + pandeiro esparso", desc: "Tema do protagonista — não aparece no gameplay, preserva o impacto." },
  { context: "Festa de São Pedro", mood: "Performance — exceção total", instruments: "Ciranda ao vivo, coro, instrumentos reais gravados", desc: "Único momento em que a música para de ser ambiente e vira performance (Conceitos v5.5)." },
];

const ART_SPECS = [
  { category: "Personagens (Flat Design vetorial)", spec: "Vetores exportados como PNG/spritesheet · Animação por partes via Godot Skeleton2D (rigged) · idle, caminhar, trabalhar, conversar · NPCs fixos com visual único", refs: "Referências: Hay Day, Township, Port City. Formas limpas, cores sólidas, contorno fino opcional. Protagonista em 2 variantes de gênero. IA útil: Midjourney (conceito) + Adobe Firefly (refinamento)." },
  { category: "Estruturas do porto", spec: "Vetores escaláveis por célula de 64px · 5 estados por fase (F1–F5) com variação de cor e detalhe · sombra projetada plana sob cada estrutura", refs: "Guindaste como ícone central de progressão. F1=desgastado/cores apagadas, F5=industrial vibrante. Animação por partes (braço gira, cabine abre) — não frame a frame." },
  { category: "Navios e barcos", spec: "Doca pequena (2×1 células): 128×64px · Doca média (2×2): 128×128px · Doca grande (3×2): 192×128px · Vetores com silhueta limpa e cor de casco sólida", refs: "Leitura visual por cor de casco + bandeirinha + fumaça em loop. 4 tipos: pesca (azul), cargueiro (vermelho), turismo (branco/amarelo), suspeito (cinza escuro). Animação de chegada: tween de posição, não sprite animado." },
  { category: "HUD e UI", spec: "Fonte sans-serif (Inter, Nunito ou Poppins) OFL · 16px (recursos) · 14px (diálogo) · 12px mínimo · ícones vetoriais 24–32px", refs: "UI limpa inspirada em apps mobile modernos. Painéis com cantos arredondados, sombra suave, cores da paleta principal. HUD em CanvasLayer separado. Fonte com suporte completo a PT-BR e EN-US." },
  { category: "Efeitos e animações", spec: "Tweens nativos do Godot 4 para movimento · Partículas para fumaça/espuma/moedas · Loops de animação por partes (Skeleton2D) para elementos vivos", refs: "Fumaça de chaminé: emitter simples. Moeda voando: tween de posição + fade. Construção: grow tween + partícula de poeira. Low-end: reduz emitters, mantém tweens." },
  { category: "Ferramentas de produção", spec: "Figma ou Affinity Designer para design vetorial · Spine 2D ou Godot Skeleton2D para animação rigged · Midjourney/Firefly para conceito, nunca para asset final", refs: "Fluxo: conceito IA → aprovação visual → redesenho vetorial no Figma → exportar PNG → importar no Godot. IA garante direção visual; o vetor final garante consistência e escalabilidade." },
];

const TECH_SPECS = [
  { label: "Engine", value: "Godot 4.2+ LTS · GDScript · MIT License" },
  { label: "Grid do mapa", value: "64×64px por célula · F1: 8×6 → F5: 24×14 · Expansão em L (direita + sul)" },
  { label: "Perspectiva visual", value: "Top-down 30° · Z-ordering automático via z_index (sul renderiza na frente)" },
  { label: "Engine de áudio", value: "Godot AudioServer nativo · 4 buses: Master, Música, SFX, Voz" },
  { label: "Formato de áudio", value: "Música: OGG 96kbps (mobile) · SFX curtos: WAV 44.1kHz 16-bit" },
  { label: "Loudness target", value: "-16 LUFS integrado (músicas) · -12 dBFS True Peak máximo" },
  { label: "Pathfinding", value: "NavigationAgent2D + NavigationPolygon procedural · A* nativo do Godot 4" },
  { label: "Save na nuvem", value: "Google Play Games (Android) + iCloud (iOS) · Exportação manual entre plataformas" },
  { label: "Analytics", value: "Firebase Analytics via plugin Godot · D1/D7/D30 retention + funil de conversão da demo" },
  { label: "iOS mínimo", value: "iOS 15.0 (~97% de iPhones ativos)" },
  { label: "Android mínimo", value: "Android 8.0 API 26 (~92% de Androids ativos)" },
  { label: "FPS target", value: "60fps high-end · 30fps mid-range estável · 30fps low-end com degradação controlada" },
  { label: "Tamanho do app", value: "≤80MB download inicial · ≤200MB instalado total" },
  { label: "Idiomas no launch", value: "EN-US (padrão) + PT-BR simultâneos · Textos em CSV de localização, nunca hardcoded" },
  { label: "Plataformas", value: "Mobile (Android/iOS) primeiro · Steam PC 6–12 meses após (Sistemas v5.5)" },
];

/* ══════════════════════════════════════════════════════
   COMPONENTE PRINCIPAL
══════════════════════════════════════════════════════ */
function BRPortVisualAudioV4() {
  const [active, setActive] = useState("art");
  const [showQ, setShowQ] = useState(false);
  const [openStep, setOpenStep] = useState(null);
  const [openZone, setOpenZone] = useState("fixas");
  const [statuses, setStatuses] = useState({});

  const pal = palette[active];

  const STATUS_CONF = {
    open: { label: "Aberta",     bg: "#fff",    border: "#ddd",    color: "#999" },
    wip:  { label: "Em análise", bg: "#fff8e1", border: "#f0c040", color: "#a07000" },
    done: { label: "Decidida",   bg: "#eafbf0", border: "#5cb87a", color: "#2d7a3a" },
  };
  const PRIO_CONF = {
    alta:  { bg: "#fff0f0", color: "#c43030", label: "Alta" },
    média: { bg: "#fff8e8", color: "#c47000", label: "Média" },
    baixa: { bg: "#f0f7ff", color: "#1a5c8a", label: "Baixa" },
  };

  const tabs = [
    { id: "art",     icon: "🎨", label: "Arte" },
    { id: "sound",   icon: "🎵", label: "Trilha" },
    { id: "session", icon: "⏱️", label: "Sessão" },
    { id: "map",     icon: "🗺️", label: "Mapa" },
    { id: "tech",    icon: "⚙️", label: "Técnica" },
  ];

  const qData  = DESIGN_QUESTIONS[active];
  const allQs  = qData.flatMap(c => c.questions);
  const totalQ = allQs.length;
  const doneQ  = allQs.filter(q => statuses[q.id] === "done").length;

  const cycleStatus = (id) => {
    setStatuses(prev => {
      const cur = prev[id] || "open";
      const next = cur === "open" ? "wip" : cur === "wip" ? "done" : "open";
      return { ...prev, [id]: next };
    });
  };

  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 500, margin: "0 auto", padding: "16px 12px" }}>

      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 18 }}>
        <div style={{ fontSize: 10, letterSpacing: 3, textTransform: "uppercase", color: "#aaa", fontFamily: "monospace" }}>Game Design Document</div>
        <div style={{ fontSize: 22, fontWeight: 700, color: "#1a3a5c", letterSpacing: -0.5, margin: "4px 0 2px" }}>⚓ BR Port</div>
        <div style={{ fontSize: 11, color: "#999", fontStyle: "italic" }}>Arte · Som · Sessão · Mapa · Técnica — v5.5 (base) / v6.5</div>
        <div style={{ fontSize: 10, color: "#bbb", marginTop: 2, fontFamily: "monospace" }}>
          Incorpora decisões de Conceitos v5.5 + Sistemas v5.5 · {totalQ} questões
        </div>
      </div>

      {/* Nav tabs */}
      <div style={{ display: "flex", gap: 5, justifyContent: "center", flexWrap: "wrap", marginBottom: 12 }}>
        {tabs.map(t => {
          const p = palette[t.id]; const on = active === t.id;
          return (
            <button key={t.id} onClick={() => { setActive(t.id); setShowQ(false); }} style={{
              fontSize: 11, padding: "5px 12px", borderRadius: 99, cursor: "pointer",
              border: on ? `2px solid ${p.main}` : "1px solid #ddd",
              background: on ? p.light : "transparent",
              color: on ? p.main : "#777", fontWeight: on ? 700 : 400,
            }}>
              {t.icon} {t.label}
            </button>
          );
        })}
      </div>

      {/* Toggle GDD ↔ Perguntas */}
      <div style={{ display: "flex", gap: 6, marginBottom: 16 }}>
        <button onClick={() => setShowQ(false)} style={{
          flex: 1, fontSize: 12, padding: "6px 0", borderRadius: 8, cursor: "pointer",
          border: !showQ ? `2px solid ${pal.main}` : "1px solid #ddd",
          background: !showQ ? `${pal.main}15` : "white",
          color: !showQ ? pal.main : "#888", fontWeight: !showQ ? 700 : 400,
        }}>📄 GDD</button>
        <button onClick={() => setShowQ(true)} style={{
          flex: 1, fontSize: 12, padding: "6px 0", borderRadius: 8, cursor: "pointer",
          border: showQ ? `2px solid ${pal.main}` : "1px solid #ddd",
          background: showQ ? `${pal.main}15` : "white",
          color: showQ ? pal.main : "#888", fontWeight: showQ ? 700 : 400,
        }}>❓ Perguntas ({doneQ}/{totalQ})</button>
      </div>

      {/* ── PERGUNTAS (qualquer aba) ── */}
      {showQ && (
        <div>
          {qData.map((cat, ci) => (
            <div key={ci} style={{ marginBottom: 18 }}>
              <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 8,
                borderBottom: `2px solid ${pal.border}`, paddingBottom: 4 }}>{cat.category}</div>
              {cat.questions.map(q => {
                const st = statuses[q.id] || "open";
                const sc = STATUS_CONF[st];
                const pc = PRIO_CONF[q.priority];
                return (
                  <div key={q.id} style={{ background: sc.bg, border: `1px solid ${sc.border}`,
                    borderRadius: 10, padding: "10px 12px", marginBottom: 8 }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 6 }}>
                      <div style={{ fontSize: 12, fontWeight: 600, color: "#2a2a2a", flex: 1, lineHeight: 1.4, paddingRight: 8 }}>{q.q}</div>
                      <button onClick={() => cycleStatus(q.id)} style={{
                        fontSize: 10, padding: "2px 7px", borderRadius: 99, cursor: "pointer",
                        border: `1px solid ${sc.border}`, background: "white", color: sc.color, fontWeight: 600, whiteSpace: "nowrap", flexShrink: 0,
                      }}>{sc.label}</button>
                    </div>
                    <div style={{ fontSize: 10, color: "#888", fontStyle: "italic", marginBottom: 5, lineHeight: 1.4 }}>{q.why}</div>
                    <div style={{ display: "flex", gap: 6, marginBottom: 6 }}>
                      <span style={{ fontSize: 10, padding: "1px 6px", borderRadius: 99,
                        background: pc.bg, color: pc.color, fontWeight: 600 }}>Prioridade: {pc.label}</span>
                      <span style={{ fontSize: 10, padding: "1px 6px", borderRadius: 99,
                        background: "#f5f5f5", color: "#666" }}>#{q.id}</span>
                    </div>
                    <div style={{ fontSize: 11, color: "#444", lineHeight: 1.65,
                      borderLeft: `3px solid ${pal.main}55`, paddingLeft: 8, background: `${pal.main}06`, borderRadius: "0 6px 6px 0", padding: "6px 8px" }}>
                      {q.answer}
                    </div>
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      )}

      {/* ── GDD ARTE ── */}
      {!showQ && active === "art" && (
        <div style={{ background: pal.light, border: `1.5px solid ${pal.border}`, borderRadius: 14, padding: "18px 16px" }}>
          <div style={{ fontSize: 17, fontWeight: 700, color: pal.main, marginBottom: 4 }}>🎨 Arte Visual</div>
          <div style={{ fontSize: 12, fontStyle: "italic", color: pal.main, background: `${pal.main}11`,
            border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginBottom: 14, lineHeight: 1.5 }}>
            "Flat Design tropical brasileiro — limpo, vibrante e cheio de personalidade."
          </div>

          {/* Paleta de cores */}
          <div style={{ marginBottom: 16 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>🎨 Paleta Definitiva</div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 5 }}>
              {COLOR_SWATCHES.map((s, i) => (
                <div key={i} style={{ background: "white", border: "1px solid #eee", borderRadius: 8, padding: "7px 10px", display: "flex", gap: 8, alignItems: "flex-start" }}>
                  <div style={{ width: 20, height: 20, borderRadius: 4, background: s.hex, flexShrink: 0, marginTop: 1, border: "1px solid #eee" }} />
                  <div>
                    <div style={{ fontSize: 11, fontWeight: 700, color: "#222" }}>{s.name}</div>
                    <div style={{ fontSize: 9, fontFamily: "monospace", color: "#888" }}>{s.hex}</div>
                    <div style={{ fontSize: 10, color: "#666", lineHeight: 1.3, marginTop: 2 }}>{s.use}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Art specs */}
          <div style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>📐 Especificações de Arte</div>
            {ART_SPECS.map((s, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 8, padding: "8px 10px", marginBottom: 5 }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: "#333", marginBottom: 3 }}>{s.category}</div>
                <div style={{ fontSize: 10, color: "#555" }}>{s.spec}</div>
                <div style={{ fontSize: 10, color: "#888", fontStyle: "italic", marginTop: 2 }}>{s.refs}</div>
              </div>
            ))}
          </div>

          {/* Master Clock */}
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px" }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>🕐 Master Clock — Ciclo Dia/Noite</div>
            {[
              ["1 dia de jogo", "4 minutos reais (velocidade 1×)"],
              ["1 hora de jogo", "10 segundos reais"],
              ["Amanhecer (5h–8h)", "Segundos 50–80 do ciclo de 240s"],
              ["Dia pleno (8h–17h)", "Segundos 80–170 do ciclo"],
              ["Pôr-do-sol (17h–19h)", "Segundos 170–190 — overlay laranja/roxo"],
              ["Noite (19h–5h)", "Segundos 190–240 + 0–50 do próximo ciclo"],
              ["Velocidade 2×", "Todos os períodos pela metade"],
              ["Sincronização", "Interna — não sincronizado com relógio do dispositivo"],
            ].map(([l, v], i) => (
              <div key={i} style={{ display: "flex", gap: 8, fontSize: 10, marginBottom: 4 }}>
                <span style={{ color: "#999", minWidth: 140, flexShrink: 0 }}>{l}</span>
                <span style={{ color: "#444" }}>{v}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── GDD SOM ── */}
      {!showQ && active === "sound" && (
        <div style={{ background: pal.light, border: `1.5px solid ${pal.border}`, borderRadius: 14, padding: "18px 16px" }}>
          <div style={{ fontSize: 17, fontWeight: 700, color: pal.main, marginBottom: 4 }}>🎵 Identidade Sonora</div>
          <div style={{ fontSize: 12, fontStyle: "italic", color: pal.main, background: `${pal.main}11`,
            border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginBottom: 14, lineHeight: 1.5 }}>
            "Forró de triângulo, zabumba e sanfona. Porto Mirim tem som mesmo quando não tem música."
          </div>
          <div style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>🎚️ Camadas por Contexto</div>
            {SOUND_LAYERS.map((l, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 8, padding: "8px 10px", marginBottom: 5 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 3 }}>
                  <div style={{ fontSize: 11, fontWeight: 700, color: "#222" }}>{l.context}</div>
                  <span style={{ fontSize: 10, padding: "1px 6px", borderRadius: 99, background: `${pal.main}15`, color: pal.main }}>{l.mood}</span>
                </div>
                <div style={{ fontSize: 10, color: "#555", marginBottom: 2 }}>{l.instruments}</div>
                <div style={{ fontSize: 10, color: "#888", fontStyle: "italic" }}>{l.desc}</div>
              </div>
            ))}
          </div>
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px" }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>🔧 Especificações Técnicas</div>
            {[
              ["Engine de áudio", "Godot 4 AudioServer nativo (4 buses)"],
              ["Formato musical", "OGG Vorbis 96kbps (mobile) / 128kbps (Steam PC)"],
              ["Formato SFX curtos", "WAV 44.1kHz 16-bit (carregamento instantâneo)"],
              ["Loudness target", "-16 LUFS integrado · -12 dBFS True Peak"],
              ["Variação de SFX", "Pitch shift ±5% + 3 variantes por SFX de alta frequência"],
              ["MVP — total arquivos", "~57 arquivos de áudio · ~35–40MB comprimido"],
            ].map(([l, v], i) => (
              <div key={i} style={{ display: "flex", gap: 8, fontSize: 10, marginBottom: 4 }}>
                <span style={{ color: "#999", minWidth: 130, flexShrink: 0 }}>{l}</span>
                <span style={{ color: "#444" }}>{v}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── GDD SESSÃO ── */}
      {!showQ && active === "session" && (
        <div style={{ background: pal.light, border: `1.5px solid ${pal.border}`, borderRadius: 14, padding: "18px 16px" }}>
          <div style={{ fontSize: 17, fontWeight: 700, color: pal.main, marginBottom: 4 }}>⏱️ Design de Sessão</div>
          <div style={{ fontSize: 12, fontStyle: "italic", color: pal.main, background: `${pal.main}11`,
            border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginBottom: 14, lineHeight: 1.5 }}>
            "Sessão típica de 10–20 min. 1 dia de jogo = 4 min reais. O porto pausa quando o app fecha."
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 0, marginBottom: 14 }}>
            {SESSION_STEPS.map((step, i) => {
              const open = openStep === i;
              return (
                <div key={i} style={{ display: "flex", gap: 0 }}>
                  <div style={{ display: "flex", flexDirection: "column", alignItems: "center", width: 32, flexShrink: 0 }}>
                    <div style={{ width: 28, height: 28, borderRadius: 99, background: step.color, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, flexShrink: 0, zIndex: 1 }}>{step.icon}</div>
                    {i < SESSION_STEPS.length - 1 && <div style={{ width: 2, flex: 1, minHeight: 20, background: "#ddd" }} />}
                  </div>
                  <div style={{ flex: 1, marginLeft: 10, marginBottom: 10 }}>
                    <button onClick={() => setOpenStep(open ? null : i)} style={{ width: "100%", textAlign: "left", background: "white", border: `1px solid ${open ? step.color : "#e0e0e0"}`, borderRadius: 10, padding: "9px 12px", cursor: "pointer" }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <div>
                          <div style={{ fontSize: 12, fontWeight: 700, color: "#333" }}>{step.title}</div>
                          <div style={{ fontSize: 10, color: step.color, marginTop: 1 }}>{step.time}</div>
                        </div>
                        <span style={{ fontSize: 11, color: "#bbb" }}>{open ? "▲" : "▼"}</span>
                      </div>
                    </button>
                    {open && (
                      <div style={{ background: "white", border: `1px solid ${step.color}44`, borderTop: "none", borderRadius: "0 0 10px 10px", padding: "10px 12px" }}>
                        {step.actions.map((a, ai) => (
                          <div key={ai} style={{ display: "flex", gap: 8, fontSize: 11, color: "#444", marginBottom: 4 }}>
                            <span style={{ color: step.color, fontWeight: 700 }}>→</span><span>{a}</span>
                          </div>
                        ))}
                        <div style={{ marginTop: 7, fontSize: 11, fontStyle: "italic", color: step.color, borderLeft: `3px solid ${step.color}55`, paddingLeft: 8, lineHeight: 1.5 }}>{step.feel}</div>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px", marginBottom: 8 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 4 }}>☁️ Save & Dados</div>
            {[
              ["Save na nuvem", "Google Play Games (Android) + iCloud (iOS) nativos"],
              ["Migração", "Exportação manual de arquivo entre plataformas"],
              ["Múltiplos perfis", "Sim — via configurações, invisível para quem não precisa"],
              ["Analytics", "Firebase Analytics · D1/D7/D30 retention + funil da demo"],
              ["App launch (cold)", "<3s do ícone ao Boletim do Porto (mid-range)"],
              ["Sessão mínima", "2 min: aceitar 1 contrato + realocar workers = sessão válida"],
            ].map(([l, v], i) => (
              <div key={i} style={{ display: "flex", gap: 8, fontSize: 10, marginBottom: 4 }}>
                <span style={{ color: "#999", minWidth: 120, flexShrink: 0 }}>{l}</span>
                <span style={{ color: "#444" }}>{v}</span>
              </div>
            ))}
          </div>
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px" }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 4 }}>🔔 Gancho de Retorno</div>
            <div style={{ fontSize: 11, color: "#555", lineHeight: 1.6 }}>
              O jogador fecha o jogo sabendo que: (1) uma construção ficará pronta em X dias de jogo, (2) Toninho/Zezão têm um diálogo novo, (3) um leilão vai abrir. Porto pausa ao fechar o app — sem punição por ausência.
            </div>
          </div>
        </div>
      )}

      {/* ── GDD MAPA ── */}
      {!showQ && active === "map" && (
        <div style={{ background: pal.light, border: `1.5px solid ${pal.border}`, borderRadius: 14, padding: "18px 16px" }}>
          <div style={{ fontSize: 17, fontWeight: 700, color: pal.main, marginBottom: 4 }}>🗺️ Mapa do Porto</div>
          <div style={{ fontSize: 12, fontStyle: "italic", color: pal.main, background: `${pal.main}11`,
            border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginBottom: 14, lineHeight: 1.5 }}>
            "Grid de 64×64px. Expansão em L (direita + sul). O cais do avô sempre no canto noroeste."
          </div>

          {/* Layout esquemático */}
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: 12, marginBottom: 14 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: pal.main, marginBottom: 8 }}>🖼️ Layout — Fase 1 (8×6 células)</div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gridTemplateRows: "auto auto auto", gap: 3, fontSize: 9, textAlign: "center" }}>
              {[
                { label: "🌴 Mangue\n(intocável)", bg: "#3A9E5233", border: "#3A9E52", span: "1 / 2", row: "1" },
                { label: "🏘️ Porto Mirim\n(bairro inicial)", bg: "#E8C97A33", border: "#c4a030", span: "2 / 4", row: "1" },
                { label: "🏗️ Zona Industrial\n(livre, cresce →)", bg: "#6a348022", border: "#6a3480", span: "1 / 3", row: "2" },
                { label: "🚚 Estrada\n(fixa, upgradável)", bg: "#7A7A7222", border: "#7A7A72", span: "3 / 4", row: "2" },
                { label: "⚓ Docas\n(livre, até 4 docas P)", bg: "#1a5c8a22", border: "#1a5c8a", span: "1 / 3", row: "3" },
                { label: "🌊 Mar\n(aterro F3+)", bg: "#2B7FBF44", border: "#2B7FBF", span: "3 / 4", row: "3" },
              ].map((z, i) => (
                <div key={i} style={{ background: z.bg, border: `1.5px solid ${z.border}`, borderRadius: 5,
                  padding: "7px 4px", gridColumn: z.span, gridRow: z.row, color: "#333", fontWeight: 600,
                  lineHeight: 1.3, whiteSpace: "pre-line" }}>{z.label}</div>
              ))}
            </div>
          </div>

          {/* Zonas */}
          <div style={{ display: "flex", gap: 6, marginBottom: 10 }}>
            {MAP_ZONES.map(z => (
              <button key={z.id} onClick={() => setOpenZone(z.id)} style={{ flex: 1, fontSize: 11, padding: "5px 0", borderRadius: 8, cursor: "pointer",
                border: openZone === z.id ? `2px solid ${z.color}` : "1px solid #ddd",
                background: openZone === z.id ? `${z.color}15` : "white",
                color: openZone === z.id ? z.color : "#777", fontWeight: openZone === z.id ? 700 : 400 }}>
                {z.label}
              </button>
            ))}
          </div>
          {MAP_ZONES.filter(z => z.id === openZone).map(zone => (
            <div key={zone.id} style={{ marginBottom: 14 }}>
              <div style={{ fontSize: 11, color: "#666", fontStyle: "italic", marginBottom: 8 }}>{zone.desc}</div>
              {zone.items.map((item, i) => (
                <div key={i} style={{ background: "white", border: `1px solid ${zone.color}33`, borderRadius: 8, padding: "8px 10px", display: "flex", gap: 10, marginBottom: 5 }}>
                  <span style={{ fontSize: 16 }}>{item.icon}</span>
                  <div>
                    <div style={{ fontSize: 11, fontWeight: 700, color: "#333", marginBottom: 1 }}>{item.name}</div>
                    <div style={{ fontSize: 10, color: "#666" }}>{item.desc}</div>
                  </div>
                </div>
              ))}
            </div>
          ))}

          {/* Escala e câmera */}
          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px" }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 4 }}>📏 Escala, Câmera & Navegação</div>
            {[
              ["Tamanho do mapa", "F1: 8×6 → F5: 24×14 células (+ estaleiro separado)"],
              ["Célula do grid", "64×64px · Estruturas: 1×1, 2×1 ou 2×2 células"],
              ["Perspectiva", "Top-down 30° · Z-ordering automático por y-position"],
              ["Expansão", "Em L: direita (cidade) + sul (mar)"],
              ["Zoom", "3 níveis fixos: Visão geral / Operacional (padrão) / Detalhe"],
              ["Câmera", "Segue ação automática · jogador pode fixar manualmente"],
              ["Pathfinding", "NavigationAgent2D + A* nativo do Godot 4"],
            ].map(([l, v], i) => (
              <div key={i} style={{ display: "flex", gap: 8, fontSize: 10, marginBottom: 4 }}>
                <span style={{ color: "#999", minWidth: 100, flexShrink: 0 }}>{l}</span>
                <span style={{ color: "#444" }}>{v}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── GDD TÉCNICA ── */}
      {!showQ && active === "tech" && (
        <div style={{ background: pal.light, border: `1.5px solid ${pal.border}`, borderRadius: 14, padding: "18px 16px" }}>
          <div style={{ fontSize: 17, fontWeight: 700, color: pal.main, marginBottom: 4 }}>⚙️ Ficha Técnica</div>
          <div style={{ fontSize: 12, fontStyle: "italic", color: pal.main, background: `${pal.main}11`,
            border: `1px solid ${pal.border}`, borderRadius: 8, padding: "7px 11px", marginBottom: 14, lineHeight: 1.5 }}>
            "Godot 4 LTS · Mobile-first · EN-US + PT-BR simultâneos · Premium puro, sem backend próprio."
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
            {TECH_SPECS.map((s, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 8,
                padding: "8px 12px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                <div style={{ minWidth: 130, flexShrink: 0, fontSize: 10, color: "#888", fontFamily: "monospace", paddingTop: 1 }}>{s.label}</div>
                <div style={{ fontSize: 11, color: "#333", lineHeight: 1.4 }}>{s.value}</div>
              </div>
            ))}
          </div>

          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px", marginTop: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>📱 Dispositivos de Teste Prioritários</div>
            {[
              { perfil: "Low-end",   device: "Samsung Galaxy A14", spec: "Android 8, 3GB RAM, Mediatek G80" },
              { perfil: "Mid-range", device: "iPhone XR / Samsung A53", spec: "iOS 15 / Android 10, 3–4GB RAM" },
              { perfil: "High-end",  device: "iPhone 15 / Pixel 8", spec: "iOS 17+ / Android 14, 6–8GB RAM" },
            ].map((d, i) => (
              <div key={i} style={{ display: "flex", gap: 8, marginBottom: 7 }}>
                <span style={{ fontSize: 10, padding: "1px 7px", borderRadius: 99, background: pal.light, color: pal.main, fontWeight: 700, flexShrink: 0, alignSelf: "flex-start", marginTop: 1 }}>{d.perfil}</span>
                <div>
                  <div style={{ fontSize: 11, fontWeight: 600, color: "#333" }}>{d.device}</div>
                  <div style={{ fontSize: 10, color: "#888" }}>{d.spec}</div>
                </div>
              </div>
            ))}
          </div>

          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px", marginTop: 10 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 6 }}>🌐 Localização</div>
            <div style={{ fontSize: 11, color: "#555", lineHeight: 1.65 }}>
              Lançamento simultâneo EN-US + PT-BR. Textos em arquivos CSV de localização desde o início — nunca hardcoded. Nomes de NPCs permanecem em português em todas as versões (proper names). Idiomas futuros: ES-LATAM, PT-PT. Ferramenta: Weblate (open-source) integrado ao GitHub.
            </div>
          </div>

          <div style={{ background: "white", border: `1px solid ${pal.border}`, borderRadius: 10, padding: "10px 12px", marginTop: 10 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: pal.main, marginBottom: 8 }}>♿ Acessibilidade — Requisitos Mínimos</div>
            <div style={{ fontSize: 11, color: "#666", fontStyle: "italic", marginBottom: 10, lineHeight: 1.5 }}>
              Requisitos não-negociáveis para aprovação nas lojas e respeito ao jogador. Testados antes do Vertical Slice.
            </div>
            {[
              { cat: "Toque", items: [
                ["Área mínima de toque", "44×44pt (Apple HIG) · 48×48dp (Material Design) — nenhum botão abaixo disso, mesmo que o sprite seja menor. Godot 4: usar Control com custom_minimum_size."],
                ["Margem entre alvos tocáveis", "8pt mínimo entre qualquer dois elementos interativos. Evita toques acidentais em telas de 5 polegadas."],
                ["Feedback de toque", "Toda área tocável tem resposta visual em ≤50ms — highlight, press state ou shake. Nunca silêncio total após um tap."],
              ]},
              { cat: "Texto e Leitura", items: [
                ["Tamanho mínimo de fonte", "12px em qualquer texto de gameplay. 11px mínimo absoluto. Fonte principal: Inter ou Nunito OFL (sans-serif escalável)."],
                ["Contraste mínimo", "4.5:1 para texto sobre fundo (WCAG AA). Testado em todas as combinações de paleta — especialmente texto sobre overlays de tempestade e neblina."],
                ["Velocidade de diálogo", "Opção de texto instantâneo (sem animação de digitação) nas configurações. Padrão: animação. Não escondido em menu profundo."],
              ]},
              { cat: "Visual e Motor", items: [
                ["Redução de movimento", "Opção para desativar partículas, shake e animações não-essenciais. Padrão: ativo. Para jogadores com sensibilidade vestibular."],
                ["100% jogável no mudo", "Nenhuma informação crítica chega só pelo áudio. Todo alerta sonoro tem equivalente visual (ver s12 nas Perguntas de Trilha)."],
                ["Daltonismo", "Nunca usar cor como único diferenciador. Barras de reputação e saúde têm ícone + cor. Navios diferenciados por forma/textura + cor de casco."],
              ]},
              { cat: "Configurações acessíveis", items: [
                ["Localização das configurações", "Acessível em no máximo 2 taps a partir de qualquer tela do jogo — nunca enterrado em submenus."],
                ["Persistência", "Todas as preferências de acessibilidade salvas localmente e restauradas ao reabrir. Não pedem confirmação para ativar."],
              ]},
            ].map((grupo, gi) => (
              <div key={gi} style={{ marginBottom: 12 }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: pal.main, marginBottom: 5, fontFamily: "monospace" }}>{grupo.cat}</div>
                {grupo.items.map(([label, desc], ii) => (
                  <div key={ii} style={{ display: "flex", gap: 8, marginBottom: 6, background: pal.light, borderRadius: 7, padding: "6px 8px" }}>
                    <div style={{ minWidth: 120, flexShrink: 0, fontSize: 10, color: "#666", fontWeight: 600, lineHeight: 1.4 }}>{label}</div>
                    <div style={{ fontSize: 10, color: "#444", lineHeight: 1.5 }}>{desc}</div>
                  </div>
                ))}
              </div>
            ))}
          </div>
        </div>
      )}

      <div style={{ textAlign: "center", marginTop: 14, fontSize: 10, color: "#ccc", fontFamily: "monospace" }}>
        BR Port • GDD v6.5 • Arte · Som · Sessão · Mapa · Técnica<br/>
        Incorpora: Conceitos v5.5 + Sistemas v5.5 · {totalQ} questões · {Object.values(statuses).filter(s => s === "done").length} decididas
      </div>
    </div>
  );
}
  return BRPortVisualAudioV4;
})();


/* =================================================================
   Prototipo  —  Escopo do Protótipo v1.1 — APROVADO (Playtest V3)
   Seção operacional: deve ser lida antes de qualquer código ser
   escrito. Isolada em IIFE para evitar colisão de identificadores.
   ================================================================= */
const Prototipo = (() => {

const PAL_P = {
  main:      "#7a4a00",
  light:     "#fff8ef",
  border:    "#e8c88a",
  accent:    "#c47800",
  muted:     "#f5ede0",
  red:       "#8a1a1a",
  redBg:     "#fdf0f0",
  redBorder: "#e8b0b0",
  green:     "#1a6b3a",
  greenBg:   "#eaf5ec",
  greenBorder:"#a8d8b0",
};

const SECOES_P = [
  { id: "definicao",  icon: "🧪", label: "Definição"  },
  { id: "dentro",     icon: "✅", label: "Dentro"     },
  { id: "fora",       icon: "🚫", label: "Fora"       },
  { id: "loop",       icon: "🔄", label: "Loop"       },
  { id: "tempo",      icon: "⏱️",  label: "Tempo"      },
  { id: "criterios",  icon: "🎯", label: "Critérios"  },
  { id: "cronograma", icon: "📅", label: "Cronograma" },
];

const DEFINICAO_P = {
  tagline: '"A única pergunta do protótipo é: esse loop é divertido com retângulos?"',
  items: [
    { icon: "🧪", name: "O que é o protótipo",        desc: "Um executável feio, sem arte final, sem narrativa, sem NPCs nomeados. Retângulos coloridos no lugar de personagens. Labels no lugar de diálogos. Existe para responder uma única pergunta antes de qualquer segundo ser gasto em arte ou escrita." },
    { icon: "❓", name: "A única pergunta",            desc: '"Alocar trabalhadores em barcos, gerenciar caixa vs. dívida e reagir a um rival é divertido por si só — sem o contexto de Porto Mirim?" Se sim: avança para o vertical slice. Se não: o problema é no loop, e narrativa não conserta loop quebrado.' },
    { icon: "📐", name: "O que o protótipo NÃO é",    desc: "Não é uma demo. Não é a Fase 1 do jogo. Não é uma prévia do visual. É um instrumento de diagnóstico — como um esboço num guardanapo antes de chamar o arquiteto." },
    { icon: "🔗", name: "Relação com o Vertical Slice",desc: "Protótipo → responde 'é divertido?'. Vertical Slice → responde 'consigo produzir?'. São dois artefatos distintos com perguntas distintas. O Vertical Slice só começa quando o protótipo passar nos critérios de sucesso desta seção. Pular essa ordem é o erro mais caro de um dev solo." },
    { icon: "🎬", name: "Escopo do Vertical Slice — fechado na Fase 1 do roadmap", desc: "O VS é uma sessão jogável da Fase 1 do JOGO (Ato 1 — Início): herdar o cais, conhecer Dona Cida, sobreviver até a primeira parcela paga ao Sr. Ribeiro, com Arlindo como rival visível desde o começo. Arte próxima do final (não placeholder). 1 NPC com diálogos completos (Dona Cida) + Sr. Ribeiro com sprite e diálogo curto na cena de parcela. 1 rival ativo (Arlindo, sem Rivalômetro). UI mobile production-quality nas telas listadas no escopo fechado. Áudio mínimo: SFX core + ambiente loop + 1 música via Suno (timebox de 1 dia). Duração alvo jogada: 15–25 minutos (atualizado do alvo original de 5–10 min do Roadmap v2, agora coerente com a Fase 1 do jogo no Roadmap v2.1). Marco de revisão intermediária: loop core jogável end-to-end com arte placeholder, antes de gastar arte final pesada. Critério de conclusão: o dev jogou do início ao fim sem quebrar e ainda quer continuar o projeto." },
    { icon: "⏰", name: "Tempo de build do Protótipo",      desc: "Máximo 2 semanas de código (referente ao Protótipo, não ao VS). Se levar mais de 2 semanas para construir o protótipo, o escopo está errado — volte e corte mais. O protótipo deve ser simples o bastante para ser refeito do zero em 3 dias se o teste mostrar que o loop está fundamentalmente errado. O VS tem prazo próprio, definido na Fase 2 do roadmap." },
    { icon: "📌", name: "Spec autoritativa = este GDD", desc: "Existem rascunhos antigos do protótipo em HTML (mockups feitos para discussão) que podem divergir desta spec — por exemplo, mockups com 4 parcelas em 6 semanas em vez das 3 parcelas em 4 semanas definidas aqui. Em caso de conflito, ESTE GDD é a fonte da verdade. Os mockups HTML servem como referência visual e foram superados pelos números do balanceamento v5.5." },
    { icon: "📋", name: "Aprendizados do V3 — decisões fechadas para o VS", desc: "Três ajustes do playtest V3, agora fechados na Fase 1 do roadmap: (1) Dificuldade semanas 3–4 — solução escolhida: PARCELA FINAL MAIS PESADA. Sem rival mais agressivo nem evento de custo inesperado no VS — o VS é instrumento de diagnóstico de produção e a parcela apertada testa a sensação de pressão por custo mínimo. Se não corrigir, evento e rival reativo entram na produção full com base nesse dado. (2) Reputação intuitiva — solução escolhida: COR PULSANTE NO INDICADOR + ÍCONE DE REAÇÃO DE NPC ADJACENTE (Dona Cida). Sem linha de texto contextual no VS. A combinação dá dois sinais independentes pra observar no playtest: se o jogador percebe sem ler, foi a cor; se cita um NPC específico, foi o ícone. (3) Negociação de preço simplificada — solução escolhida: 3 PRESETS EM BOTÕES (sem slider, sem input numérico) + MOOD FACE DO CLIENTE com 3 estados discretos (2 tentativas restantes = neutro, 1 = preocupado, 0 = saindo). Diagnóstico limpo da mecânica antes de granularidade." },
    { icon: "🖼️", name: "VS — Telas IN (production-quality)", desc: "12 telas com arte e UI próximas do final: (1) Boletim do dia — abertura de sessão com 3 itens (navio aguardando, ação rival pendente, prazo urgente). (2) Doca + drag-and-drop de trabalhadores — o loop core. (3) Fila de barcos/contratos com tap pra detalhes. (4) Tela de contra-oferta — 3 presets + mood face do cliente. (5) Diálogo Dona Cida — 3 variações de tom. (6) Boletim Financeiro semanal — cena curta da Dona Cida. (7) Indicador de reputação Comercial — cor pulsante + ícone NPC. (8) Tela de construção/upgrade — apenas o upgrade da Fase 1 (ex: ampliar píer). (9) Cena de parcela com Sr. Ribeiro — sprite + diálogo curto, beat narrativo de fechamento da Fase 1. (10) Diário do Porto — 1 página inicial pra testar o conceito de costura narrativa. (11) Cena de fim de Fase 1 — estática, narra a virada. (12) Pause / menu mínimo — voltar ao loop, sair." },
    { icon: "⚙️", name: "VS — Sistemas IN", desc: "Loop de turno completo (alocação → docagem → receita). Economia: caixa, parcela única da Fase 1 (R$ 8.000 ao Sr. Ribeiro), upgrade único. Reputação Comercial (eixo único no VS — escala 0–100 com leitura qualitativa em 5 faixas). Contra-oferta com Arlindo (3 presets + mood face). Curva de pressão: dificuldade sobe na reta final via parcela mais pesada. Autosave local (sem cloud, sem slots manuais)." },
    { icon: "🚫", name: "VS — Sistemas e telas OUT (deferidos para produção full)", desc: "Reputação Comunitária e Imprensa (só Comercial no VS). Bela, sistema de imprensa, Rivalômetro completo. Mapa regional e outras regiões. Hobbies, pesca, bar, vida pessoal. Múltiplas estruturas além do upgrade único da Fase 1. Save manual com slots, cloud save. Acessibilidade completa — só fonte ajustável em 3 níveis no VS, sem leitor de tela, sem alto contraste, sem modo daltônico. Cinemática/tela inicial polida (placeholder estático no VS)." },
    { icon: "🎨", name: "VS — Assets a produzir (lista de estimativa)", desc: "Personagens: 1 sprite + animações básicas da Dona Cida com 3 expressões para o sistema de feedback de reputação; 1 sprite + animação leve do Arlindo (visível durante negociação); 1 sprite + diálogo curto do Sr. Ribeiro (cena de parcela); 2 sprites de trabalhador genérico para drag-and-drop. Cenário: sprite do píer (estado base + estado upgraded); 2–3 sprites de barco (variação visual mesmo com mecânica única). UI: artwork production-quality das 12 telas listadas. Áudio: ~8 SFX core (drag-and-drop, chegada de navio, parcela paga, alerta de tentativa final na contra-oferta, etc.); 1 loop de ambiente de 1–2 min (água + gaivotas + rádio AM distante); 1 música-tema da Fase 1 via Suno com timebox de 1 dia (se a iteração não render em 1 dia, cai sem culpa pra só ambiente loop sem música). Texto: diálogos da Dona Cida (boletim + 3 variações + comentários no loop); linhas de negociação do Arlindo; cena de parcela do Ribeiro; narração de fim de Fase 1; 1 página inicial do Diário do Porto." },
    { icon: "🔄", name: "VS — Marco de revisão intermediário", desc: "Gatilho de revisão fechado na Fase 1 do roadmap: LOOP CORE JOGÁVEL END-TO-END COM ARTE PLACEHOLDER. Critério concreto: dá pra completar uma semana de jogo do início ao fim sem crash; drag-and-drop funciona; pelo menos 1 contra-oferta com Arlindo dispara e o cliente reage (vai/fica); parcela é cobrada e o caixa muda. Quando esse marco fechar: o dev joga sozinho 2 dias, depois entrega pra 1 pessoa de confiança jogar sem instrução. Se algo estiver fundamentalmente quebrado, descobre-se antes de produzir arte final pesada — evita refazer dois (sistema + arte) por um erro de design." },
    { icon: "🏁", name: "VS — Critério de conclusão", desc: "(1) O dev joga do início ao fim sem crash. (2) Os 3 ajustes do V3 estão observáveis no playtest: pressão clara na reta final via parcela mais pesada; feedback visual imediato de reputação via cor pulsante + ícone NPC; negociação com paciência via 3 presets + mood face. (3) O dev ainda quer continuar o projeto depois de jogar do início ao fim. Os três critérios precisam estar satisfeitos pra avançar à Fase 5 do roadmap (Testes e correções)." },
  ],
};

const DENTRO_P = {
  tagline: '"Tudo que testa o loop. Nada que distrai do loop."',
  rows: [
    { label: "Tipos de barco",      value: "1 — barco genérico, tamanho único" },
    { label: "Tipos de carga",      value: "1 — carga genérica, valor único" },
    { label: "Funcionários",        value: "2 — sem nome, sem moral, sem especialidade" },
    { label: "Slots de doca",       value: "2 simultâneos (1 por funcionário)" },
    { label: "Rival",               value: "1 — ação única: dumping de preço (15% menos)" },
    { label: "Semanas de jogo",     value: "4 semanas / 12 turnos de 'dia'" },
    { label: "Parcelas da dívida",  value: "3 parcelas: R$400, R$800, R$1.200 (sem. 2, 3, 4)" },
    { label: "Caixa inicial",       value: "R$ 600" },
    { label: "Receita por barco",   value: "R$ 100–250 por docagem" },
    { label: "Custo fixo semanal",  value: "R$ 180 (2 funcionários × R$ 90)" },
    { label: "Upgrade disponível",  value: "1 — ampliar píer para +1 slot (R$ 400)" },
    { label: "Interface",           value: "Retângulos coloridos + labels de texto puro" },
    { label: "Engine",              value: "Godot 4 — sem assets de arte final" },
    { label: "Plataforma de teste", value: "Build mobile (Android APK) em primeiro lugar — testar em telefone real. Build PC com mouse só para iteração rápida do designer/programador, não para validação final de mobile-feel" },
  ],
};

const FORA_GRUPOS_P = [
  { label: "Narrativa & NPCs",    icon: "📖", items: ["Tutorial scriptado com Toninho, Zezão, Seu Biu","Diálogos de NPCs (nenhum NPC tem nome no protótipo)","Arco narrativo dos 3 Atos","Segredos e fios de investigação","Bela e sistema de imprensa/reputação","Vínculos afetivos com personagens","Cenas de virada (câmara municipal, Natal, São Pedro)","Qualquer texto além de labels funcionais"] },
  { label: "Sistemas Complexos",  icon: "⚙️", items: ["Reputação de 3 eixos com interações cruzadas","Moral e lealdade de funcionários","Sazonalidade e calendário festivo","Preços dinâmicos por oferta/demanda","Cargas especiais (ilegal, medicamentos, arte)","Missões críticas com consequência permanente","Sistema de contratação e demissão","Corrupção e favores políticos"] },
  { label: "Conteúdo & Finais",   icon: "🏁", items: ["5 finais possíveis","5 regiões do mapa regional","Mapa regional desbloqueável","Construções além do upgrade único do protótipo","Eventos aleatórios narrativos e de cenário","Demo pública ou qualquer conteúdo de marketing"] },
  { label: "Arte, Som & Técnica", icon: "🎨", items: ["Pixel art de qualquer resolução ou detalhe","Trilha sonora e SFX","Animações de personagem ou estrutura","UI final com ícones, cores de marca ou logotipo","Localização EN-US + PT-BR","Build mobile (Android/iOS)","Sistema de save/load"] },
  { label: "Rival Avançado",      icon: "⚔️", items: ["Comportamento escalado do Grupo Atlântico","Arlindo com lobby político e licenças atrasadas","Boatos que derrubam reputação","Recrutamento de funcionários pelo rival","IA de rival com múltiplas ações por fase"] },
];

const LOOP_PASSOS_P = [
  { num: "1", name: "Abertura do turno",        desc: "O jogo exibe o estado atual: caixa disponível, barcos na fila, trabalhadores ociosos. Uma linha de status no topo — sem boletim, sem diálogo. O jogador lê em 3 segundos.", gesto: "Nenhum — leitura passiva" },
  { num: "2", name: "Barco(s) na fila",         desc: "0, 1 ou 2 barcos aparecem na fila de doca. Cada um mostra: tipo de carga (ícone genérico), valor estimado da docagem (R$), tempo de operação (X turnos). Com 2 barcos na fila e só 2 slots, o jogador tem que escolher qual priorizar.", gesto: "Tap no barco para ver detalhes" },
  { num: "3", name: "Alocação de trabalhadores", desc: "O jogador arrasta cada trabalhador (retângulo colorido) para o slot de doca desejado. 1 trabalhador por slot. Sem trabalhador = sem operação = sem receita. Essa é a decisão central do turno.", gesto: "Drag-and-drop — gesto principal do loop" },
  { num: "4", name: "Confirmar e processar",    desc: "O jogador toca em 'Avançar dia'. O jogo processa: barcos docados geram receita, barcos ignorados somem (foram ao rival). Funcionários alocados ficam ocupados por X turnos conforme o contrato.", gesto: "Tap único no botão de avanço" },
  { num: "5", name: "Ação do rival (1-em-3)",   desc: "Com probabilidade de 33%, o rival aparece: oferece 15% a menos ao próximo cliente da fila. O cliente mostra ícone de indecisão. O jogador pode manter o preço ou baixar para competir. Sem texto — só ícone de preço e setas de ajuste.", gesto: "Tap para ver oferta + slider de preço" },
  { num: "6", name: "Parcela semanal",          desc: "Ao final da semana 2, 3 e 4: o banco cobra a parcela. Se o caixa não cobrir: pagar parcialmente (juros no próximo turno), empréstimo emergencial (+20%), ou game over. Sem cena, sem NPC — só a decisão econômica.", gesto: "Tap nas opções de pagamento" },
];

const LOOP_DECISOES_P = [
  { icon: "⚓", name: "Quais barcos docam?",     desc: "Com 2 slots e potencialmente 3 barcos na fila, o jogador escolhe quais 2 aceitar. O barco rejeitado some para o rival." },
  { icon: "👷", name: "Quantos trabalhadores?",  desc: "Usar 1 e guardar outro para emergência, ou usar os 2 e dobrar a receita com risco de zero buffer. Esse é o trade-off de liquidez do loop." },
  { icon: "🏗️", name: "Investir ou pagar?",     desc: "O upgrade custa R$400 e abre um 3º slot. Comprar na semana 1 esvazia o caixa antes da parcela da semana 2. Esse é o dilema de timing do protótipo." },
  { icon: "⚔️", name: "Competir ou ceder?",    desc: "Quando o rival faz dumping, baixar o preço salva o cliente mas reduz a margem. Manter pode perder o cliente — mas mantém a saúde financeira se houver outros barcos na fila." },
];

const TEMPO_ITEMS_P = [
  { icon: "✅", name: "Decisão — Turnos diários, sem pressão de relógio",         desc: "O modelo do GDD define turnos diários onde o jogador avança quando quiser — e essa é a decisão correta para o protótipo. Nada acontece enquanto o app está fechado. A pressão vem das parcelas e da fila de barcos, não de um temporizador real." },
  { icon: "⚠️", name: "Contradição a resolver — O alerta de 2 minutos do tutorial",desc: "O tutorial descreve um 'barco de passagem com alerta de 2 minutos reais'. Isso contradiz o modelo de turnos e cria pressão de relógio do sistema operacional — padrão F2P, não premium. Decisão: no protótipo, o barco fica na fila até o jogador avançar o turno. Nenhum temporizador real." },
  { icon: "🔎", name: "Para o jogo final — o alerta vai para o Boletim do Porto",  desc: "O 'barco chegou' é um item do Boletim do Porto (abertura da sessão). O jogador é informado ao abrir o app, não pressionado enquanto joga. Isso mantém a urgência como contexto, não como coerção." },
  { icon: "⏱️", name: "Velocidade do tempo no protótipo",                         desc: "Sem velocidade ajustável no protótipo. 1 turno = 1 toque em 'Avançar dia'. O jogador controla o ritmo manualmente. A velocidade configurável (1×, 2×) é feature de produção." },
];

const CRIT_OBR_P = [
  { id: "ob1", label: "5+ playtesters jogam 15 min sem instrução e pedem mais uma rodada",         detalhe: "✅ ATINGIDO — Playtest V3. Todos os participantes pediram mais rodadas espontaneamente. Nota: a partir das semanas 3–4 a dificuldade ficou baixa demais, o que facilitou a nota A para todos. Sinal de rebalanceamento para o VS — semanas finais precisam de mais pressão." },
  { id: "ob2", label: "3+ playtesters descrevem espontaneamente uma estratégia que desenvolveram", detalhe: "✅ ATINGIDO — Playtest V3. Estratégia emergente documentada: maximizar ocupação dos trabalhadores + upgrades para aumentar receita antes das parcelas. Exatamente o tipo de agência que o protótipo precisava provar. O sistema comunica incentivos corretamente." },
  { id: "ob3", label: "0 playtesters abandona antes de 5 min alegando confusão sobre o objetivo",  detalhe: "✅ ATINGIDO — Playtest V3. Nenhum abandono por confusão. A barra de reputação ainda não está totalmente intuitiva (melhora prevista no VS com feedback visual imediato), mas não travou ninguém." },
];

const CRIT_DES_P = [
  { id: "de1", label: "Tempo médio até o primeiro 'aha moment' < 2 min",   detalhe: "✅ ATINGIDO — Playtest V3. Os eventos semanais deram propósito claro à barra de reputação e aceleraram o entendimento do loop. Ponto de melhoria: a reputação ainda não comunica bem suas consequências imediatas — solucionado no VS com feedback visual ao mudar de valor." },
  { id: "de2", label: "Playtester comete erro e tenta corrigi-lo sozinho", detalhe: "✅ ATINGIDO — Playtest V3. A estratégia de upgrade emergiu como resposta a rodadas anteriores onde a receita não cobriu as parcelas. Sinal de que o sistema comunica consequências e gera aprendizado." },
];

const CRIT_FALHA_P = [
  { id: "fa1", label: "Playtesters entendem o loop, mas acham chato depois de 5 min",            detalhe: "O problema é na profundidade da decisão — não no onboarding. Reavalie a quantidade de barcos, o upgrade, a variação de valor." },
  { id: "fa2", label: "Playtesters ficam confusos sobre o objetivo mesmo depois de 10 min",      detalhe: "O loop não comunica seus objetivos. Simplifique: menos opções, mais consequências claras e imediatas." },
  { id: "fa3", label: "Nenhum playtester articula uma estratégia após a sessão",                 detalhe: "O sistema não permite agência real. Isso é estrutural. O loop precisa ser reprojetado." },
  { id: "fa4", label: "Feedback unânime: 'precisa de história para ser interessante'",           detalhe: "Sinal crítico. A narrativa amplifica um loop bom, mas não salva um loop fraco. Pivot antes de escrever uma linha de diálogo." },
];

const CRONOGRAMA_P = [
  { semanas: "Sem. 1–2", fase: "Build do protótipo",  cor: "#7a4a00", alerta: "Se levar mais de 2 semanas, o escopo está grande — corte o upgrade ou o rival e adicione depois.", acoes: ["Godot 4: grid, drag-and-drop, 1 tipo de barco, 2 funcionários","Economia: caixa, receita, parcelas e custo fixo","Rival com ação de dumping (probabilidade 1/3)","1 upgrade disponível com custo e efeito no loop","Sem arte, sem texto além de labels funcionais"] },
  { semanas: "Sem. 3–4", fase: "Playtest interno",    cor: "#1a5a6b", alerta: null, acoes: ["Você + 2 pessoas próximas (não da área de games)","Grave a tela e observe — não explique o jogo","Anote comportamento, não opinião","Corrija bugs críticos de UX (gesto que não funciona, feedback visual ausente)","Não adicione conteúdo — só corrija o que impede o teste"] },
  { semanas: "Sem. 5–6", fase: "Playtest externo",    cor: "#1a6b3a", alerta: null, acoes: ["5+ pessoas que não te conhecem bem (Reddit, Discord de devs, amigos de amigos)","Entregue o executável sem instrução escrita","Meça os critérios desta seção — registre cada sessão","Em paralelo: montagem da landing page de smoke test (Carrd)","Em paralelo: criação dos 3–4 criativos de ad com mockups"] },
  { semanas: "Sem. 7–8", fase: "✅ Decisão go / no-go — CONCLUÍDO",  cor: "#1a6b3a", alerta: "Protótipo V3 aprovado. Todos os critérios obrigatórios atingidos. Vertical Slice liberado.", acoes: ["✅ Todos os critérios obrigatórios atingidos no Playtest V3","✅ Estratégia emergente documentada (upgrade + ocupação máxima)","✅ Nenhum abandono por confusão de objetivo","→ DECISÃO: GO — Iniciar Vertical Slice","Ajustes para o VS: rebalancear dificuldade sem. 3–4, reputação com feedback visual, negociação de preço simplificada"] },
];

function BRPortProtatipo() {
  const [ativo, setAtivo]       = useState("definicao");
  const [abertoFora, setAbertoFora] = useState(null);
  const [checados, setChecados] = useState({});
  const [expandStep, setExpandStep] = useState(null);
  const [expandCron, setExpandCron] = useState(null);

  const toggle = (id) => setChecados(prev => ({ ...prev, [id]: !prev[id] }));
  const obConcluidos = CRIT_OBR_P.filter(c => checados[c.id]).length;
  const deConcluidos = CRIT_DES_P.filter(c => checados[c.id]).length;

  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 480, margin: "0 auto", padding: "16px 12px" }}>

      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 16 }}>
        <div style={{ fontSize: 11, letterSpacing: 3, textTransform: "uppercase", color: "#aaa", fontFamily: "monospace" }}>Game Design Document — BR Port</div>
        <div style={{ fontSize: 24, fontWeight: 700, color: "#1a3a5c", letterSpacing: -0.5, margin: "4px 0 2px" }}>⚓ BR Port</div>
        <div style={{ fontSize: 12, color: "#999", fontStyle: "italic" }}>Escopo do Protótipo — v1.1 — ✅ APROVADO · Fase 1 do roadmap concluída · Decisões do VS fechadas</div>
      </div>

      {/* Badge operacional */}
      <div style={{ background: PAL_P.greenBg, border: `1.5px solid ${PAL_P.greenBorder}`, borderRadius: 10, padding: "8px 12px", marginBottom: 14, display: "flex", gap: 8, alignItems: "center" }}>
        <span style={{ fontSize: 16 }}>✅</span>
        <div style={{ fontSize: 11, color: PAL_P.green, lineHeight: 1.5 }}>
          <strong>Protótipo V3 — APROVADO.</strong> Todos os critérios obrigatórios atingidos no playtest. O Vertical Slice está liberado para iniciar. Os aprendizados do V3 estão registrados nos Critérios abaixo e nas notas de escopo do VS.
        </div>
      </div>

      {/* Nav */}
      <div style={{ display: "flex", gap: 5, justifyContent: "center", flexWrap: "wrap", marginBottom: 16 }}>
        {SECOES_P.map(s => {
          const on = ativo === s.id;
          return (
            <button key={s.id} onClick={() => { setAtivo(s.id); setAbertoFora(null); setExpandStep(null); setExpandCron(null); }} style={{ fontSize: 11, padding: "5px 11px", borderRadius: 99, cursor: "pointer", border: on ? `2px solid ${PAL_P.main}` : "1px solid #ddd", background: on ? PAL_P.light : "transparent", color: on ? PAL_P.main : "#777", fontWeight: on ? 700 : 400, fontFamily: "Georgia, serif", transition: "all 0.15s" }}>
              {s.icon} {s.label}
            </button>
          );
        })}
      </div>

      {/* ── DEFINIÇÃO ── */}
      {ativo === "definicao" && (
        <div>
          <div style={{ background: PAL_P.light, border: `1.5px solid ${PAL_P.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>🧪 O que é o Protótipo</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.main, background: `${PAL_P.main}11`, border: `1px solid ${PAL_P.border}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>{DEFINICAO_P.tagline}</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {DEFINICAO_P.items.map((item, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${PAL_P.border}`, borderRadius: 10, padding: "10px 12px" }}>
                <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                  <span style={{ fontSize: 18, flexShrink: 0, marginTop: 1 }}>{item.icon}</span>
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 700, color: PAL_P.main, marginBottom: 3 }}>{item.name}</div>
                    <div style={{ fontSize: 12, color: "#555", lineHeight: 1.6 }}>{item.desc}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── DENTRO ── */}
      {ativo === "dentro" && (
        <div>
          <div style={{ background: PAL_P.greenBg, border: `1.5px solid ${PAL_P.greenBorder}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.green, marginBottom: 6 }}>✅ Dentro do Protótipo</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.green, background: `${PAL_P.green}11`, border: `1px solid ${PAL_P.greenBorder}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>{DENTRO_P.tagline}</div>
          </div>
          <div style={{ fontSize: 13, fontWeight: 700, color: PAL_P.green, marginBottom: 8 }}>📋 Especificação do escopo</div>
          <div style={{ background: "white", border: `1px solid ${PAL_P.greenBorder}`, borderRadius: 10, overflow: "hidden", marginBottom: 14 }}>
            {DENTRO_P.rows.map((row, i) => (
              <div key={i} style={{ display: "flex", gap: 8, padding: "8px 12px", borderBottom: i < DENTRO_P.rows.length - 1 ? `1px solid ${PAL_P.greenBorder}` : "none", background: i % 2 === 0 ? "white" : PAL_P.greenBg }}>
                <span style={{ fontSize: 12, color: "#888", minWidth: 150, flexShrink: 0 }}>{row.label}</span>
                <span style={{ fontSize: 12, color: "#333", fontFamily: "monospace", flex: 1 }}>{row.value}</span>
              </div>
            ))}
          </div>
          <div style={{ background: PAL_P.greenBg, border: `1px solid ${PAL_P.greenBorder}`, borderRadius: 10, padding: "10px 12px" }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.green, marginBottom: 5 }}>💡 Regra de ouro</div>
            <div style={{ fontSize: 12, color: "#444", lineHeight: 1.7 }}>Se um elemento não testa diretamente se <em>"alocar trabalhadores, gerenciar caixa e reagir ao rival é divertido"</em>, ele não entra no protótipo. O protótipo deve ser reconstruível do zero em 3 dias.</div>
          </div>
        </div>
      )}

      {/* ── FORA ── */}
      {ativo === "fora" && (
        <div>
          <div style={{ background: PAL_P.redBg, border: `1.5px solid ${PAL_P.redBorder}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.red, marginBottom: 6 }}>🚫 Fora do Protótipo</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.red, background: `${PAL_P.red}11`, border: `1px solid ${PAL_P.redBorder}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>"Esta lista protege você de si mesmo. Imprima e cole na parede."</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {FORA_GRUPOS_P.map((grupo, gi) => {
              const aberto = abertoFora === gi;
              return (
                <div key={gi} style={{ background: "white", border: `1.5px solid ${PAL_P.redBorder}`, borderRadius: 10, overflow: "hidden" }}>
                  <button onClick={() => setAbertoFora(aberto ? null : gi)} style={{ width: "100%", textAlign: "left", background: aberto ? PAL_P.redBg : "white", border: "none", padding: "10px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 10 }}>
                    <span style={{ fontSize: 16 }}>{grupo.icon}</span>
                    <span style={{ fontSize: 13, fontWeight: 700, color: PAL_P.red, flex: 1 }}>{grupo.label}</span>
                    <span style={{ fontSize: 12, color: "#aaa", fontFamily: "monospace" }}>{grupo.items.length} itens</span>
                    <span style={{ fontSize: 12, color: PAL_P.red }}>{aberto ? "▲" : "▼"}</span>
                  </button>
                  {aberto && (
                    <div style={{ padding: "0 12px 12px", borderTop: `1px solid ${PAL_P.redBorder}` }}>
                      {grupo.items.map((item, ii) => (
                        <div key={ii} style={{ display: "flex", gap: 8, padding: "5px 0", borderBottom: ii < grupo.items.length - 1 ? `1px dashed ${PAL_P.redBorder}` : "none" }}>
                          <span style={{ color: PAL_P.red, fontSize: 11, paddingTop: 2, flexShrink: 0 }}>✕</span>
                          <span style={{ fontSize: 12, color: "#555", lineHeight: 1.5 }}>{item}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
          <div style={{ background: PAL_P.redBg, border: `1px solid ${PAL_P.redBorder}`, borderRadius: 10, padding: "10px 12px", marginTop: 12 }}>
            <div style={{ fontSize: 12, color: PAL_P.red, lineHeight: 1.7 }}>
              <strong>Se você se pegar pensando em adicionar algo desta lista ao protótipo:</strong> pare, leia a aba "Definição" e responda se aquela adição responde a pergunta <em>"o loop é divertido?"</em>. Se não responde, não entra.
            </div>
          </div>
        </div>
      )}

      {/* ── LOOP ── */}
      {ativo === "loop" && (
        <div>
          <div style={{ background: PAL_P.light, border: `1.5px solid ${PAL_P.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>🔄 Anatomia do Turno</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.main, background: `${PAL_P.main}11`, border: `1px solid ${PAL_P.border}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>"Cada turno tem 6 etapas. A única com decisão real é a etapa 3. O protótipo testa se essa decisão é interessante o bastante por si só."</div>
          </div>
          <div style={{ fontSize: 13, fontWeight: 700, color: PAL_P.main, marginBottom: 8 }}>📋 Os 6 passos do turno</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 16 }}>
            {LOOP_PASSOS_P.map((p, i) => {
              const aberto = expandStep === i;
              return (
                <div key={i} style={{ background: "white", border: `1px solid ${PAL_P.border}`, borderRadius: 10, overflow: "hidden" }}>
                  <button onClick={() => setExpandStep(aberto ? null : i)} style={{ width: "100%", textAlign: "left", background: "none", border: "none", padding: "9px 12px", cursor: "pointer", display: "flex", gap: 10, alignItems: "center" }}>
                    <span style={{ fontSize: 12, fontWeight: 700, fontFamily: "monospace", background: PAL_P.main, color: "white", padding: "2px 7px", borderRadius: 99, flexShrink: 0 }}>{p.num}</span>
                    <span style={{ fontSize: 13, fontWeight: 700, color: "#333", flex: 1 }}>{p.name}</span>
                    <span style={{ fontSize: 11, color: "#aaa" }}>{aberto ? "▲" : "▼"}</span>
                  </button>
                  {aberto && (
                    <div style={{ padding: "0 12px 12px" }}>
                      <div style={{ fontSize: 12, color: "#555", lineHeight: 1.6, marginBottom: 8, paddingTop: 6, borderTop: `1px solid ${PAL_P.border}` }}>{p.desc}</div>
                      <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                        <span style={{ fontSize: 10, fontFamily: "monospace", background: PAL_P.muted, color: PAL_P.accent, padding: "2px 8px", borderRadius: 99, fontWeight: 700 }}>GESTO</span>
                        <span style={{ fontSize: 11, color: PAL_P.accent }}>{p.gesto}</span>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
          <div style={{ fontSize: 13, fontWeight: 700, color: PAL_P.main, marginBottom: 8 }}>🎯 As 4 decisões por turno</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
            {LOOP_DECISOES_P.map((d, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${PAL_P.border}`, borderRadius: 10, padding: "10px 12px", display: "flex", gap: 10, alignItems: "flex-start" }}>
                <span style={{ fontSize: 18, flexShrink: 0, marginTop: 1 }}>{d.icon}</span>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.main, marginBottom: 2 }}>{d.name}</div>
                  <div style={{ fontSize: 12, color: "#555", lineHeight: 1.55 }}>{d.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── TEMPO ── */}
      {ativo === "tempo" && (
        <div>
          <div style={{ background: PAL_P.light, border: `1.5px solid ${PAL_P.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>⏱️ Modelo de Tempo — Decisão</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.main, background: `${PAL_P.main}11`, border: `1px solid ${PAL_P.border}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>"A tensão vem das parcelas e da fila de escolhas — não de um relógio no canto da tela."</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {TEMPO_ITEMS_P.map((t, i) => (
              <div key={i} style={{ background: "white", border: `1.5px solid ${t.icon === "⚠️" ? PAL_P.redBorder : PAL_P.border}`, borderRadius: 10, padding: "10px 12px" }}>
                <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                  <span style={{ fontSize: 18, flexShrink: 0, marginTop: 1 }}>{t.icon}</span>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 700, color: t.icon === "⚠️" ? PAL_P.red : PAL_P.main, marginBottom: 3 }}>{t.name}</div>
                    <div style={{ fontSize: 12, color: "#555", lineHeight: 1.65 }}>{t.desc}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
          <div style={{ background: PAL_P.muted, border: `1px solid ${PAL_P.border}`, borderRadius: 10, padding: "10px 12px", marginTop: 10 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>📋 Protótipo vs. Jogo Final</div>
            {[
              ["Avanço de tempo",   "Tap manual em 'Avançar dia'",       "Contínuo (1 dia = 4 min reais)"],
              ["Barco aguardando",  "Fica na fila até o jogador agir",   "Fica na fila até 24h reais"],
              ["Alerta de barco",   "Sem alerta — item visível na fila", "Boletim do Porto na abertura"],
              ["Timer real?",       "Nunca",                             "Nunca — decisão permanente"],
              ["Velocidade ajust.", "Não",                               "Sim (1×, 2×, ½×)"],
            ].map(([label, proto, final], i) => (
              <div key={i} style={{ display: "flex", gap: 6, fontSize: 11, padding: "5px 0", borderBottom: i < 4 ? `1px dashed ${PAL_P.border}` : "none" }}>
                <span style={{ color: "#999", minWidth: 120, flexShrink: 0 }}>{label}</span>
                <span style={{ color: PAL_P.main, flex: 1, fontFamily: "monospace" }}>{proto}</span>
                <span style={{ color: "#888", flex: 1, fontStyle: "italic" }}>{final}</span>
              </div>
            ))}
            <div style={{ display: "flex", gap: 6, fontSize: 10, marginTop: 6 }}>
              <span style={{ minWidth: 120 }} /><span style={{ flex: 1, fontWeight: 700, color: PAL_P.main }}>Protótipo</span><span style={{ flex: 1, fontWeight: 700, color: "#888" }}>Jogo final</span>
            </div>
          </div>
        </div>
      )}

      {/* ── CRITÉRIOS ── */}
      {ativo === "criterios" && (
        <div>
          <div style={{ background: PAL_P.light, border: `1.5px solid ${PAL_P.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>🎯 Critérios de Sucesso</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.main, background: `${PAL_P.main}11`, border: `1px solid ${PAL_P.border}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>"Definidos aqui, antes dos testes. Quem define depois dos dados racionaliza os resultados."</div>
          </div>
          {/* Placar */}
          <div style={{ display: "flex", gap: 8, marginBottom: 14 }}>
            {[
              { val: obConcluidos, total: 3, label: "obrigatórios", ok: obConcluidos === 3 },
              { val: deConcluidos, total: 2, label: "desejáveis",   ok: deConcluidos >= 1 },
            ].map((p, i) => (
              <div key={i} style={{ flex: 1, background: p.ok ? PAL_P.greenBg : PAL_P.muted, border: `1px solid ${p.ok ? PAL_P.greenBorder : PAL_P.border}`, borderRadius: 10, padding: "8px 10px", textAlign: "center" }}>
                <div style={{ fontSize: 20, fontWeight: 700, color: p.ok ? PAL_P.green : PAL_P.main }}>{p.val}/{p.total}</div>
                <div style={{ fontSize: 10, color: "#888" }}>{p.label}</div>
              </div>
            ))}
            <div style={{ flex: 1.4, background: obConcluidos === 3 && deConcluidos >= 1 ? PAL_P.greenBg : PAL_P.muted, border: `1px solid ${obConcluidos === 3 && deConcluidos >= 1 ? PAL_P.greenBorder : PAL_P.border}`, borderRadius: 10, padding: "8px 10px", textAlign: "center" }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: obConcluidos === 3 && deConcluidos >= 1 ? PAL_P.green : "#999", lineHeight: 1.3, marginTop: 4 }}>{obConcluidos === 3 && deConcluidos >= 1 ? "✅ GO" : "⏳ em curso"}</div>
              <div style={{ fontSize: 10, color: "#888" }}>decisão</div>
            </div>
          </div>
          {/* Obrigatórios */}
          <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.green, marginBottom: 6 }}>✅ Obrigatórios — todos 3 devem passar</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 14 }}>
            {CRIT_OBR_P.map((c) => {
              const on = !!checados[c.id];
              return (
                <div key={c.id} style={{ background: on ? PAL_P.greenBg : "white", border: `1.5px solid ${on ? PAL_P.greenBorder : PAL_P.border}`, borderRadius: 10, padding: "10px 12px" }}>
                  <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <button onClick={() => toggle(c.id)} style={{ width: 20, height: 20, borderRadius: 5, flexShrink: 0, cursor: "pointer", border: `2px solid ${on ? PAL_P.green : PAL_P.border}`, background: on ? PAL_P.green : "white", display: "flex", alignItems: "center", justifyContent: "center", marginTop: 1 }}>
                      {on && <span style={{ color: "white", fontSize: 11 }}>✓</span>}
                    </button>
                    <div>
                      <div style={{ fontSize: 12, fontWeight: 700, color: on ? PAL_P.green : "#333", marginBottom: 2, lineHeight: 1.4 }}>{c.label}</div>
                      <div style={{ fontSize: 11, color: "#777", lineHeight: 1.55, fontStyle: "italic" }}>{c.detalhe}</div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
          {/* Desejáveis */}
          <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>🟡 Desejáveis — pelo menos 1 deve passar</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 14 }}>
            {CRIT_DES_P.map((c) => {
              const on = !!checados[c.id];
              return (
                <div key={c.id} style={{ background: on ? PAL_P.greenBg : "white", border: `1.5px solid ${on ? PAL_P.greenBorder : PAL_P.border}`, borderRadius: 10, padding: "10px 12px" }}>
                  <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <button onClick={() => toggle(c.id)} style={{ width: 20, height: 20, borderRadius: 5, flexShrink: 0, cursor: "pointer", border: `2px solid ${on ? PAL_P.green : PAL_P.border}`, background: on ? PAL_P.green : "white", display: "flex", alignItems: "center", justifyContent: "center", marginTop: 1 }}>
                      {on && <span style={{ color: "white", fontSize: 11 }}>✓</span>}
                    </button>
                    <div>
                      <div style={{ fontSize: 12, fontWeight: 700, color: on ? PAL_P.green : "#333", marginBottom: 2, lineHeight: 1.4 }}>{c.label}</div>
                      <div style={{ fontSize: 11, color: "#777", lineHeight: 1.55, fontStyle: "italic" }}>{c.detalhe}</div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
          {/* Sinais de falha */}
          <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.red, marginBottom: 6 }}>🚨 Sinais de falha — indicam pivot, não iteração</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {CRIT_FALHA_P.map((c) => {
              const on = !!checados[c.id];
              return (
                <div key={c.id} style={{ background: on ? PAL_P.redBg : "white", border: `1.5px solid ${on ? PAL_P.redBorder : "#eee"}`, borderRadius: 10, padding: "10px 12px" }}>
                  <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                    <button onClick={() => toggle(c.id)} style={{ width: 20, height: 20, borderRadius: 5, flexShrink: 0, cursor: "pointer", border: `2px solid ${on ? PAL_P.red : "#ddd"}`, background: on ? PAL_P.red : "white", display: "flex", alignItems: "center", justifyContent: "center", marginTop: 1 }}>
                      {on && <span style={{ color: "white", fontSize: 11 }}>✓</span>}
                    </button>
                    <div>
                      <div style={{ fontSize: 12, fontWeight: 700, color: on ? PAL_P.red : "#555", marginBottom: 2, lineHeight: 1.4 }}>{c.label}</div>
                      <div style={{ fontSize: 11, color: "#777", lineHeight: 1.55, fontStyle: "italic" }}>{c.detalhe}</div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* ── CRONOGRAMA ── */}
      {ativo === "cronograma" && (
        <div>
          <div style={{ background: PAL_P.light, border: `1.5px solid ${PAL_P.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 14 }}>
            <div style={{ fontSize: 17, fontWeight: 700, color: PAL_P.main, marginBottom: 6 }}>📅 Cronograma — 8 semanas até go/no-go</div>
            <div style={{ fontSize: 13, fontStyle: "italic", color: PAL_P.main, background: `${PAL_P.main}11`, border: `1px solid ${PAL_P.border}`, borderRadius: 8, padding: "7px 11px", lineHeight: 1.5 }}>"Sem arte final. Sem narrativa. Sem Flat Design. 8 semanas de diagnóstico custam R$ 300–500 e poupam 6 meses."</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {CRONOGRAMA_P.map((etapa, i) => {
              const aberto = expandCron === i;
              return (
                <div key={i} style={{ background: "white", border: `1.5px solid ${etapa.cor}44`, borderRadius: 12, overflow: "hidden" }}>
                  <button onClick={() => setExpandCron(aberto ? null : i)} style={{ width: "100%", textAlign: "left", background: `${etapa.cor}08`, border: "none", padding: "10px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 10 }}>
                    <span style={{ fontSize: 11, fontWeight: 700, fontFamily: "monospace", background: etapa.cor, color: "white", padding: "3px 8px", borderRadius: 99, flexShrink: 0, whiteSpace: "nowrap" }}>{etapa.semanas}</span>
                    <span style={{ fontSize: 13, fontWeight: 700, color: etapa.cor, flex: 1 }}>{etapa.fase}</span>
                    <span style={{ fontSize: 12, color: "#bbb" }}>{aberto ? "▲" : "▼"}</span>
                  </button>
                  {aberto && (
                    <div style={{ padding: "0 12px 12px" }}>
                      <div style={{ borderTop: `1px solid ${etapa.cor}33`, paddingTop: 10, display: "flex", flexDirection: "column", gap: 5 }}>
                        {etapa.acoes.map((acao, ai) => (
                          <div key={ai} style={{ display: "flex", gap: 8, fontSize: 12 }}>
                            <span style={{ color: etapa.cor, flexShrink: 0, paddingTop: 2 }}>→</span>
                            <span style={{ color: "#444", lineHeight: 1.5 }}>{acao}</span>
                          </div>
                        ))}
                        {etapa.alerta && (
                          <div style={{ background: PAL_P.redBg, border: `1px solid ${PAL_P.redBorder}`, borderRadius: 8, padding: "7px 10px", marginTop: 6, fontSize: 11, color: PAL_P.red, lineHeight: 1.5 }}>
                            ⚠️ {etapa.alerta}
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
          {/* Smoke test em paralelo */}
          <div style={{ background: "#eaeaf8", border: "1.5px solid #b0b0e0", borderRadius: 10, padding: "10px 12px", marginTop: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: "#3a3a7a", marginBottom: 6 }}>🔀 Em paralelo — Sem. 5–8: Smoke Test de Marketing</div>
            {["Landing page no Carrd (1h de trabalho, gratuito no free tier)","Trailer de 20–30s com mockups + gameplay do protótipo","R$ 300–500 em Meta Ads + TikTok Ads (fãs de Dave the Diver, Two Point Hospital)","3–4 variações de criativo: 'porto BR', 'rivais', 'sem ads/energia', 'narrativa'","Meta: CTR ≥ 1,5% no melhor criativo + 500 e-mails/wishlists em 8 semanas"].map((item, i) => (
              <div key={i} style={{ display: "flex", gap: 8, fontSize: 11, marginBottom: 4 }}>
                <span style={{ color: "#6060b0", flexShrink: 0 }}>→</span>
                <span style={{ color: "#444", lineHeight: 1.5 }}>{item}</span>
              </div>
            ))}
          </div>
          {/* Árvore de decisão */}
          <div style={{ background: PAL_P.muted, border: `1.5px solid ${PAL_P.border}`, borderRadius: 10, padding: "10px 12px", marginTop: 10 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: PAL_P.main, marginBottom: 8 }}>🏁 Semana 8 — Árvore de Decisão</div>
            {[
              { tag: "GO",    sinal: "3 obrigatórios + 1 desejável + CTR ok",  acao: "Iniciar Vertical Slice — Fase 1 com arte final e 1 NPC",    cor: PAL_P.green },
              { tag: "ITER",  sinal: "2 de 3 obrigatórios OU CTR ok",          acao: "Mais 2 semanas de protótipo e novo playtest",               cor: PAL_P.main  },
              { tag: "PIVOT", sinal: "≤ 1 obrigatório após 3 ciclos",          acao: "Repensar o conceito antes de qualquer pixel art",           cor: PAL_P.red   },
            ].map((linha, i) => (
              <div key={i} style={{ display: "flex", gap: 8, marginBottom: 8, alignItems: "flex-start" }}>
                <span style={{ fontSize: 10, padding: "2px 7px", borderRadius: 99, background: `${linha.cor}22`, color: linha.cor, fontWeight: 700, flexShrink: 0, whiteSpace: "nowrap", marginTop: 2 }}>{linha.tag}</span>
                <div style={{ fontSize: 11, color: "#555", lineHeight: 1.55 }}>
                  <strong style={{ color: linha.cor }}>{linha.sinal}:</strong>{" "}{linha.acao}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div style={{ textAlign: "center", marginTop: 18, fontSize: 10, color: "#ccc", fontFamily: "monospace" }}>
        BR Port • Protótipo V3 • ✅ APROVADO · Roadmap v2 incorporado · Planejamento do VS a seguir
      </div>
    </div>
  );
}
  return BRPortProtatipo;
})();


/* =================================================================
   BR Port — PLANO DE PRODUÇÃO DO VS (Fase 2 → GDD 7)
   Novo documento adicionado no GDD 7. Incorpora todas as decisões
   do Plano de Produção v1.0 (Fase 2 do roadmap). CONGELADO.
   ================================================================= */
const PlanoProducao = (() => {

const PAL = {
  main: "#1a3a5c", light: "#e8f0f8", border: "#c0d0e0",
  green: "#1a6b3a", greenBg: "#e8f5ec", greenBorder: "#90c8a0",
  red: "#8a2020", redBg: "#fbeaea", redBorder: "#e0a0a0",
  amber: "#7a5010", amberBg: "#fdf5e0", amberBorder: "#e0c870",
  muted: "#f0f4f8", accent: "#2a5080",
};

const BLOCOS = [
  {
    num: "B1", semanas: "Sem. 1–6", horas: "~48h", cor: "#7a4a00",
    titulo: "Setup + Godot + frontload da escrita",
    foco: "Aprender + escrever texto bruto",
    tarefas: [
      "Instalação de Godot + setup do projeto + Git/GitHub privado",
      "Tutoriais essenciais: cenas, nodes, sinais, input mobile, GDScript básico",
      "Export Android + WebGL — build VAZIA em device real desde o dia 1",
      "Frontload da escrita (nas 2h semanais): rascunho de todos os diálogos",
    ],
    criterio: "Consigo criar uma cena com sprite respondendo a um clique. Build vazia roda no celular. Texto bruto pronto em arquivo separado.",
    nota: "30–50h de curva de aprendizado de Godot embutidas neste bloco.",
  },
  {
    num: "B2", semanas: "Sem. 7–16", horas: "~80h", cor: "#1a5c8a",
    titulo: "Loop core com placeholder",
    foco: "Sistema todo funcionando feio",
    tarefas: [
      "Sistema de turno: alocação → docagem → receita",
      "Drag-and-drop de trabalhadores",
      "Fila de barcos com tap para detalhes",
      "Economia: caixa, parcela, upgrade único",
      "Reputação Comercial: lógica numérica + UI placeholder",
      "Contra-oferta com Arlindo: 3 presets + mood face placeholder",
      "Curva de pressão: parcela final mais pesada (sem. 4 do jogo)",
      "Autosave local",
    ],
    criterio: "Dá para completar uma semana de jogo do início ao fim sem crash. Drag-and-drop funciona. Pelo menos 1 contra-oferta dispara e o cliente reage. Parcela é cobrada e o caixa muda. Arte ainda placeholder.",
    nota: "Este é o MARCO INTERMEDIÁRIO na semana 16.",
  },
  {
    num: "B3", semanas: "Sem. 17–19", horas: "~24h", cor: "#5a3480",
    titulo: "Marco intermediário: validar antes de gastar arte",
    foco: "Loop fundamentalmente sólido antes da arte cara",
    tarefas: [
      "Dev joga sozinho 2 dias seguidos — anota o que incomoda",
      "Entrega para 1 pessoa de confiança jogar SEM instrução — observa comportamento, não opinião",
      "Decide: avança para arte final OU ajusta sistemas primeiro",
      "Ajustes de sistema se necessário — só corrigir o que está quebrado, sem inflar escopo",
    ],
    criterio: "Decisão registrada: 'loop pronto para receber arte final' OU 'preciso de mais X semanas de ajuste'. Se ajuste > 3 semanas → replanejar Fase 2.",
    nota: "Se algo estiver fundamentalmente quebrado, descobre-se antes de produzir arte pesada.",
  },
  {
    num: "B4", semanas: "Sem. 20–34", horas: "~120h", cor: "#1a6b3a",
    titulo: "Arte final + áudio + integração",
    foco: "Produção dos assets em ordem",
    tarefas: [
      "Style guide de flat design (sem. 1 do bloco) — paleta, peso de linha, proporções. ANTES de qualquer sprite.",
      "Sprites de personagem (4–5 sem.) — Dona Cida primeiro, depois Arlindo, Ribeiro, trabalhadores",
      "Sprites de cenário (2 sem.) — píer + barcos",
      "UI das 12 telas (5–6 sem.) — meta: 1 tela por fim de semana",
      "Áudio (1 sem.) — SFX em lote + ambiente loop + tentativa Suno (timebox 1 dia)",
      "Integração progressiva — cada asset vai para o projeto assim que sai",
    ],
    criterio: "Todas as 12 telas com arte final. Todos os personagens no jogo. Áudio integrado. Build roda no celular sem placeholder visível.",
    nota: "A meta de 1 tela/fim de semana é agressiva mas factível com IA.",
  },
  {
    num: "B5", semanas: "Sem. 35–44", horas: "~80h", cor: "#4a1a6b",
    titulo: "Polish, bugs, build, publicação",
    foco: "Fechar e publicar",
    tarefas: [
      "Fechar todos os bugs bloqueantes listados nos blocos anteriores",
      "Revisão final dos diálogos frontloadados no Bloco 1",
      "Cinemática de abertura placeholder (estática, simples)",
      "Testar em pelo menos 2 devices reais: iPhone + Android",
      "Configurar página itch.io: descrição, screenshots, GIF curto",
      "Upload APK Android + build WebGL",
      "Publicar",
    ],
    criterio: "VS jogável publicado, URL pública no itch.io, dev jogou do início ao fim sem quebrar.",
    nota: "Critério de conclusão da Fase 4 do roadmap — não desta fase.",
  },
];

const ASSETS_CHARS = [
  { asset: "Dona Cida", var: "sprite base + 3 expressões (neutro, satisfeita, preocupada)", uso: "Diálogo, boletim financeiro, ícone no indicador de reputação" },
  { asset: "Arlindo", var: "sprite + anim leve (idle + reação)", uso: "Tela de contra-oferta" },
  { asset: "Sr. Ribeiro", var: "sprite simples", uso: "Cena de parcela (só Fase 1)" },
  { asset: "Trabalhador genérico", var: "1 sprite em 2 variações de cor", uso: "Drag-and-drop" },
];

const ASSETS_CENARIO = [
  { asset: "Píer", var: "estado base + estado upgraded (mesma composição)" },
  { asset: "Barcos", var: "3 variações visuais (mesma mecânica)" },
];

const ASSETS_UI = [
  "Boletim do dia (abertura de sessão)",
  "Doca + drag-and-drop de trabalhadores",
  "Fila de barcos/contratos",
  "Tela de contra-oferta (3 presets + mood face)",
  "Diálogo Dona Cida (3 variações de tom)",
  "Boletim Financeiro semanal",
  "Indicador de reputação Comercial (cor pulsante + ícone NPC)",
  "Tela de construção/upgrade (só o upgrade da Fase 1)",
  "Cena de parcela com Sr. Ribeiro",
  "Diário do Porto (1 página inicial)",
  "Cena de fim de Fase 1 (estática)",
  "Pause / menu mínimo",
];

const RISCOS = [
  { risco: "Subestimação de tempo de Godot", prob: "Alta", mit: "Buffer de 40% no plano. Se Bloco 1 estourar 2 semanas, replanejar." },
  { risco: "Frustração no debug (curva inicial)", prob: "Alta", mit: "Trabalho pesado só no fim de semana — vida durante a semana protegida." },
  { risco: "Scope creep (feature nova durante produção)", prob: "Alta", mit: "Escopo travado aqui. Ideias novas vão para arquivo 'ideias pós-VS'." },
  { risco: "Arte inconsistente entre telas", prob: "Média", mit: "Style guide ANTES de produzir qualquer sprite (início do Bloco 4)." },
  { risco: "Música Suno não rendendo", prob: "Média", mit: "Timebox de 1 dia. Fallback: só ambiente loop. Sem culpa." },
  { risco: "Perda de motivação no meio do projeto", prob: "Alta", mit: "Marco intermediário (semana 16) dá sensação de 'consegui algo jogável' antes da arte." },
  { risco: "Vida pessoal cortar tempo disponível", prob: "Alta", mit: "Plano conta com 8h ideais e 6h reais de piso. Abaixo disso, replanejar janela." },
  { risco: "IA com código Godot fraco", prob: "Média", mit: "Combinar IA com documentação oficial. Não confiar 100% na primeira sugestão." },
];

const FORA = [
  "Marketing, devlog público, Discord pré-lançamento — VS é instrumento de validação interna. Externo só após Fase 6.",
  "Localização — VS sai só em PT-BR.",
  "Acessibilidade completa — só fonte ajustável em 3 níveis (GDD 6.5).",
  "Beta fechado, QA externa formal — vem na produção full. VS: 1–3 pessoas testando informalmente.",
  "Loja Steam, App Store, Google Play — VS sai só no itch.io.",
];

const MARCOS = [
  { marco: "Fim do Bloco 1", semana: "6", criterio: "Build vazia roda no celular. Texto bruto pronto." },
  { marco: "MARCO INTERMEDIÁRIO", semana: "16", criterio: "Loop core jogável end-to-end com placeholder.", destaque: true },
  { marco: "Fim do Bloco 3", semana: "19", criterio: "Decisão registrada — avança ou ajusta mais." },
  { marco: "Fim do Bloco 4", semana: "34", criterio: "Todos os assets integrados." },
  { marco: "FIM DA FASE 4", semana: "44–62", criterio: "VS publicado no itch.io.", destaque: true },
];

function PlanoProducaoComp() {
  const [aba, setAba] = useState("resumo");
  const [blocoAberto, setBlocoAberto] = useState(null);

  const ABAS = [
    { id: "resumo", icon: "📋", label: "Resumo" },
    { id: "blocos", icon: "🔧", label: "Blocos" },
    { id: "assets", icon: "🎨", label: "Assets" },
    { id: "semana", icon: "📅", label: "Semana" },
    { id: "riscos", icon: "⚠️", label: "Riscos" },
  ];

  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 480, margin: "0 auto", padding: "16px 12px" }}>

      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <div style={{ fontSize: 11, letterSpacing: 3, textTransform: "uppercase", color: "#aaa", fontFamily: "monospace" }}>GDD 7 — Plano de Produção</div>
        <div style={{ fontSize: 24, fontWeight: 700, color: PAL.main, letterSpacing: -0.5, margin: "4px 0 2px" }}>⚓ BR Port</div>
        <div style={{ fontSize: 12, color: "#999", fontStyle: "italic" }}>Vertical Slice · Fase 2 incorporada · CONGELADO</div>
      </div>

      {/* Badge congelado */}
      <div style={{ background: PAL.greenBg, border: `1.5px solid ${PAL.greenBorder}`, borderRadius: 10, padding: "8px 12px", marginBottom: 14, display: "flex", gap: 8, alignItems: "center" }}>
        <span style={{ fontSize: 16 }}>🔒</span>
        <div style={{ fontSize: 11, color: PAL.green, lineHeight: 1.5 }}>
          <strong>Plano de Produção — CONGELADO.</strong> Escopo não cresce durante a produção. Ideias novas vão para "ideias pós-VS". Mudanças neste documento significam reabrir a Fase 2.
        </div>
      </div>

      {/* Nav */}
      <div style={{ display: "flex", gap: 5, justifyContent: "center", flexWrap: "wrap", marginBottom: 16 }}>
        {ABAS.map(a => {
          const on = aba === a.id;
          return (
            <button key={a.id} onClick={() => { setAba(a.id); setBlocoAberto(null); }} style={{
              fontSize: 11, padding: "5px 11px", borderRadius: 99, cursor: "pointer",
              border: on ? `2px solid ${PAL.main}` : "1px solid #ddd",
              background: on ? PAL.light : "transparent",
              color: on ? PAL.main : "#777",
              fontWeight: on ? 700 : 400,
              fontFamily: "Georgia, serif", transition: "all 0.15s",
            }}>
              {a.icon} {a.label}
            </button>
          );
        })}
      </div>

      {/* ── RESUMO ── */}
      {aba === "resumo" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {[
            { icon: "🎮", label: "O que é o VS", val: "Fase 1 do JOGO (Ato 1 — Início), 15–25 min jogados, arte production-quality em flat design, publicado no itch.io (Android + WebGL)." },
            { icon: "👤", label: "Quem produz", val: "Dev solo iniciante em Godot, aprendendo no caminho com apoio de IA (Claude para escrita; IA para código; flat design com IA; Suno + ElevenLabs para áudio)." },
            { icon: "⏱️", label: "Capacidade", val: "8h/semana — 6h em bloco de fim de semana (pesado: código, debug, integração) + 2h pingadas na semana (leve: texto, prompts, planejamento)." },
            { icon: "📆", label: "Janela alvo", val: "44 semanas brutas (~10 meses) + buffer de 40% → 10–14 meses entre início da Fase 4 e VS publicado." },
            { icon: "🧱", label: "Premissa central", val: "Trabalho pesado APENAS nos blocos de fim de semana. As 2h da semana são intocáveis para trabalho leve. Se atrasar 2 semanas seguidas: replanejar, não acelerar." },
            { icon: "🚫", label: "O que NÃO está aqui", val: "Decisões de polish, balanceamento fino, narrativa estendida — fica para dentro da produção ou para o GDD 8." },
          ].map((item, i) => (
            <div key={i} style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 10, padding: "10px 12px" }}>
              <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                <span style={{ fontSize: 18, flexShrink: 0, marginTop: 1 }}>{item.icon}</span>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 700, color: PAL.main, marginBottom: 3 }}>{item.label}</div>
                  <div style={{ fontSize: 12, color: "#555", lineHeight: 1.6 }}>{item.val}</div>
                </div>
              </div>
            </div>
          ))}

          {/* Cronograma resumido */}
          <div style={{ background: PAL.light, border: `1.5px solid ${PAL.border}`, borderRadius: 12, padding: "12px 14px", marginTop: 4 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 10 }}>📊 Cronograma resumido</div>
            {[
              { bloco: "B1 — Setup + Godot + escrita", sem: "1–6", h: "~48h", cor: "#7a4a00" },
              { bloco: "B2 — Loop core placeholder", sem: "7–16", h: "~80h", cor: "#1a5c8a" },
              { bloco: "B3 — Marco intermediário", sem: "17–19", h: "~24h", cor: "#5a3480" },
              { bloco: "B4 — Arte + áudio + integração", sem: "20–34", h: "~120h", cor: "#1a6b3a" },
              { bloco: "B5 — Polish + build + publicação", sem: "35–44", h: "~80h", cor: "#4a1a6b" },
            ].map((r, i) => (
              <div key={i} style={{ display: "flex", gap: 8, marginBottom: 6, alignItems: "center" }}>
                <span style={{ fontSize: 10, fontWeight: 700, fontFamily: "monospace", background: r.cor, color: "white", padding: "2px 8px", borderRadius: 99, flexShrink: 0, whiteSpace: "nowrap" }}>Sem. {r.sem}</span>
                <span style={{ fontSize: 12, color: "#333", flex: 1 }}>{r.bloco}</span>
                <span style={{ fontSize: 11, color: "#888", fontFamily: "monospace", flexShrink: 0 }}>{r.h}</span>
              </div>
            ))}
            <div style={{ borderTop: `1px dashed ${PAL.border}`, marginTop: 8, paddingTop: 8 }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 12, color: PAL.main, fontWeight: 700 }}>
                <span>Total bruto: 44 sem / ~352h</span>
                <span>Com buffer: até 62 sem</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ── BLOCOS ── */}
      {aba === "blocos" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <div style={{ background: PAL.light, border: `1px solid ${PAL.border}`, borderRadius: 10, padding: "10px 12px", marginBottom: 4 }}>
            <div style={{ fontSize: 12, color: PAL.main, lineHeight: 1.6 }}>
              Ordem sequencial nos blocos pesados. Frontload da escrita acontece em paralelo ao Bloco 1. Toque em cada bloco para ver tarefas e critério de conclusão.
            </div>
          </div>
          {BLOCOS.map((b, i) => {
            const aberto = blocoAberto === i;
            return (
              <div key={i} style={{ background: "white", border: `1.5px solid ${b.cor}44`, borderRadius: 12, overflow: "hidden" }}>
                <button onClick={() => setBlocoAberto(aberto ? null : i)} style={{ width: "100%", textAlign: "left", background: aberto ? `${b.cor}10` : "white", border: "none", padding: "11px 13px", cursor: "pointer", display: "flex", alignItems: "center", gap: 10 }}>
                  <span style={{ fontSize: 11, fontWeight: 700, fontFamily: "monospace", background: b.cor, color: "white", padding: "2px 7px", borderRadius: 99, flexShrink: 0 }}>{b.num}</span>
                  <div style={{ flex: 1, textAlign: "left" }}>
                    <div style={{ fontSize: 13, fontWeight: 700, color: b.cor }}>{b.titulo}</div>
                    <div style={{ fontSize: 11, color: "#888" }}>{b.semanas} · {b.horas} · {b.foco}</div>
                  </div>
                  <span style={{ fontSize: 12, color: "#bbb" }}>{aberto ? "▲" : "▼"}</span>
                </button>
                {aberto && (
                  <div style={{ padding: "0 13px 13px" }}>
                    <div style={{ borderTop: `1px solid ${b.cor}33`, paddingTop: 10, display: "flex", flexDirection: "column", gap: 5, marginBottom: 10 }}>
                      {b.tarefas.map((t, ti) => (
                        <div key={ti} style={{ display: "flex", gap: 8, fontSize: 12 }}>
                          <span style={{ color: b.cor, flexShrink: 0, paddingTop: 2 }}>→</span>
                          <span style={{ color: "#444", lineHeight: 1.5 }}>{t}</span>
                        </div>
                      ))}
                    </div>
                    <div style={{ background: PAL.greenBg, border: `1px solid ${PAL.greenBorder}`, borderRadius: 8, padding: "8px 10px", marginBottom: 6 }}>
                      <div style={{ fontSize: 11, fontWeight: 700, color: PAL.green, marginBottom: 3 }}>✅ Critério de conclusão</div>
                      <div style={{ fontSize: 12, color: "#333", lineHeight: 1.5 }}>{b.criterio}</div>
                    </div>
                    {b.nota && (
                      <div style={{ background: PAL.amberBg, border: `1px solid ${PAL.amberBorder}`, borderRadius: 8, padding: "7px 10px" }}>
                        <div style={{ fontSize: 11, color: PAL.amber, lineHeight: 1.5 }}>💡 {b.nota}</div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* ── ASSETS ── */}
      {aba === "assets" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>

          {/* Personagens */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 6 }}>👤 Personagens — 4 sprites</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
              {ASSETS_CHARS.map((c, i) => (
                <div key={i} style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "8px 11px" }}>
                  <div style={{ fontSize: 12, fontWeight: 700, color: PAL.accent, marginBottom: 2 }}>{c.asset}</div>
                  <div style={{ fontSize: 11, color: "#555", lineHeight: 1.5 }}>{c.var}</div>
                  <div style={{ fontSize: 11, color: "#888", marginTop: 2, fontStyle: "italic" }}>Uso: {c.uso}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Cenário */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 6 }}>🌊 Cenário</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
              {ASSETS_CENARIO.map((c, i) => (
                <div key={i} style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "8px 11px" }}>
                  <div style={{ fontSize: 12, fontWeight: 700, color: PAL.accent, marginBottom: 2 }}>{c.asset}</div>
                  <div style={{ fontSize: 11, color: "#555" }}>{c.var}</div>
                </div>
              ))}
            </div>
          </div>

          {/* UI */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 6 }}>📱 UI — 12 telas production-quality</div>
            <div style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "10px 12px", display: "flex", flexDirection: "column", gap: 4 }}>
              {ASSETS_UI.map((t, i) => (
                <div key={i} style={{ display: "flex", gap: 8, fontSize: 12 }}>
                  <span style={{ color: PAL.main, fontFamily: "monospace", flexShrink: 0, fontSize: 10, paddingTop: 2 }}>{String(i + 1).padStart(2, "0")}</span>
                  <span style={{ color: "#444", lineHeight: 1.5 }}>{t}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Áudio */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 6 }}>🔊 Áudio</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
              {[
                { label: "~8 SFX core", desc: "Drag pega/solta, chegada de navio, parcela paga, alerta de tentativa final, click de UI, transição de turno, reputação sobe, reputação cai." },
                { label: "1 loop de ambiente", desc: "1–2 min, água + gaivotas + rádio AM distante." },
                { label: "1 música-tema via Suno", desc: "Timebox: 1 dia. Se não render → fallback para só ambiente loop. Sem culpa." },
              ].map((a, i) => (
                <div key={i} style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "8px 11px" }}>
                  <div style={{ fontSize: 12, fontWeight: 700, color: PAL.accent, marginBottom: 2 }}>{a.label}</div>
                  <div style={{ fontSize: 11, color: "#555", lineHeight: 1.5 }}>{a.desc}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Texto */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 6 }}>📝 Texto narrativo</div>
            <div style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "10px 12px", display: "flex", flexDirection: "column", gap: 4 }}>
              {[
                "Boletim Dona Cida — 1 modelo + 3 variações tonais",
                "Comentários de Dona Cida no loop — ~6–8 linhas curtas",
                "Linhas de negociação do Arlindo — ~5–8 linhas",
                "Diálogo Sr. Ribeiro (cena de parcela) — ~4–6 linhas",
                "Narração de fim de Fase 1 — ~10–15 linhas",
                "1 página inicial do Diário do Porto",
              ].map((t, i) => (
                <div key={i} style={{ display: "flex", gap: 8, fontSize: 12 }}>
                  <span style={{ color: PAL.main, flexShrink: 0, paddingTop: 2 }}>→</span>
                  <span style={{ color: "#444", lineHeight: 1.5 }}>{t}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ── SEMANA ── */}
      {aba === "semana" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>

          {/* Estrutura semanal */}
          <div style={{ background: PAL.light, border: `1.5px solid ${PAL.border}`, borderRadius: 12, padding: "12px 14px" }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 10 }}>⏰ Estrutura da semana</div>
            {[
              { bloco: "Fim de semana (sáb OU dom)", horas: "6h", tipo: "PESADO", desc: "Código, integração, debug, decisões de design", cor: "#c4470a" },
              { bloco: "2h pingadas na semana", horas: "2h", tipo: "LEVE", desc: "Texto, prompts de IA, geração de SFX, planejamento da próxima semana", cor: "#2d7a3a" },
            ].map((s, i) => (
              <div key={i} style={{ background: "white", border: `1px solid ${PAL.border}`, borderRadius: 8, padding: "9px 11px", marginBottom: 6, display: "flex", gap: 10, alignItems: "flex-start" }}>
                <div>
                  <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 3 }}>
                    <span style={{ fontSize: 10, fontWeight: 700, padding: "1px 7px", borderRadius: 99, background: `${s.cor}20`, color: s.cor }}>{s.tipo}</span>
                    <span style={{ fontSize: 12, fontWeight: 700, color: "#333" }}>{s.horas}</span>
                    <span style={{ fontSize: 11, color: "#777" }}>— {s.bloco}</span>
                  </div>
                  <div style={{ fontSize: 11, color: "#555", lineHeight: 1.5 }}>{s.desc}</div>
                </div>
              </div>
            ))}
            <div style={{ background: PAL.amberBg, border: `1px solid ${PAL.amberBorder}`, borderRadius: 8, padding: "8px 10px", marginTop: 4 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: PAL.amber, marginBottom: 4 }}>🛡️ Regras de proteção</div>
              {[
                "Fim de semana perdido pela vida → não repor com 12h na semana seguinte. Aceitar e seguir.",
                "Trabalho pesado fora do fim de semana só em exceção real — não vira hábito.",
                "Abaixo de 6h/semana por 1 mês → replanejar janela total, não comprimir.",
              ].map((r, i) => (
                <div key={i} style={{ display: "flex", gap: 7, fontSize: 11, marginBottom: 3 }}>
                  <span style={{ color: PAL.amber, flexShrink: 0 }}>→</span>
                  <span style={{ color: "#555", lineHeight: 1.5 }}>{r}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Marcos */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.main, marginBottom: 8 }}>🏁 Marcos e checkpoints</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              {MARCOS.map((m, i) => (
                <div key={i} style={{
                  background: m.destaque ? PAL.greenBg : "white",
                  border: `1.5px solid ${m.destaque ? PAL.greenBorder : PAL.border}`,
                  borderRadius: 10, padding: "9px 12px",
                  display: "flex", gap: 10, alignItems: "flex-start"
                }}>
                  <span style={{ fontSize: 11, fontWeight: 700, fontFamily: "monospace", background: m.destaque ? PAL.green : PAL.main, color: "white", padding: "2px 7px", borderRadius: 99, flexShrink: 0, whiteSpace: "nowrap" }}>Sem. {m.semana}</span>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: m.destaque ? 700 : 500, color: m.destaque ? PAL.green : PAL.main, marginBottom: 2 }}>{m.marco}</div>
                    <div style={{ fontSize: 11, color: "#555", lineHeight: 1.5 }}>{m.criterio}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Fora */}
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: PAL.red, marginBottom: 6 }}>🚫 Fora do VS (deliberadamente)</div>
            <div style={{ background: PAL.redBg, border: `1px solid ${PAL.redBorder}`, borderRadius: 8, padding: "10px 12px", display: "flex", flexDirection: "column", gap: 5 }}>
              {FORA.map((f, i) => (
                <div key={i} style={{ display: "flex", gap: 7, fontSize: 11 }}>
                  <span style={{ color: PAL.red, flexShrink: 0, paddingTop: 2 }}>✕</span>
                  <span style={{ color: "#555", lineHeight: 1.55 }}>{f}</span>
                </div>
              ))}
              <div style={{ fontSize: 11, color: PAL.red, fontWeight: 700, marginTop: 4 }}>Tudo isso é deliberadamente cortado. Não é descuido.</div>
            </div>
          </div>
        </div>
      )}

      {/* ── RISCOS ── */}
      {aba === "riscos" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <div style={{ background: PAL.amberBg, border: `1px solid ${PAL.amberBorder}`, borderRadius: 10, padding: "10px 12px", marginBottom: 4 }}>
            <div style={{ fontSize: 12, color: PAL.amber, lineHeight: 1.6 }}>
              Riscos mapeados na Fase 2. Mitigações são decisões — não esperanças. Se um risco se materializar sem mitigação prevista, replanejar imediatamente.
            </div>
          </div>
          {RISCOS.map((r, i) => (
            <div key={i} style={{ background: "white", border: `1px solid ${r.prob === "Alta" ? PAL.redBorder : PAL.amberBorder}`, borderRadius: 10, padding: "10px 12px" }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 5 }}>
                <span style={{ fontSize: 10, fontWeight: 700, padding: "2px 8px", borderRadius: 99, background: r.prob === "Alta" ? PAL.redBg : PAL.amberBg, color: r.prob === "Alta" ? PAL.red : PAL.amber, flexShrink: 0 }}>{r.prob}</span>
                <span style={{ fontSize: 12, fontWeight: 700, color: "#333" }}>{r.risco}</span>
              </div>
              <div style={{ fontSize: 12, color: "#555", lineHeight: 1.55, borderLeft: `3px solid ${r.prob === "Alta" ? PAL.redBorder : PAL.amberBorder}`, paddingLeft: 9 }}>
                → {r.mit}
              </div>
            </div>
          ))}
        </div>
      )}

      <div style={{ textAlign: "center", marginTop: 18, fontSize: 10, color: "#ccc", fontFamily: "monospace" }}>
        BR Port • Plano de Produção VS • Fase 2 incorporada ao GDD 7 • CONGELADO
      </div>
    </div>
  );
}
  return PlanoProducaoComp;
})();


/* =================================================================
   BR Port — GDD COMPLETO v7
   Documento unificado: reúne os quatro GDDs sem perda de informação.
   Cada documento roda em seu escopo isolado; este componente apenas
   alterna qual deles é exibido.
   ================================================================= */
const BR_PORT_DOCS = [
  { id: "ConceitosPrincipais", icon: "📖", label: "Conceitos Principais", Comp: ConceitosPrincipais },
  { id: "Sistemas",            icon: "⚙️", label: "Sistemas de Jogo",     Comp: Sistemas            },
  { id: "VisualAudio",         icon: "🎨", label: "Visual · Áudio · Técnica", Comp: VisualAudio     },
  { id: "Prototipo",           icon: "🧪", label: "Protótipo",            Comp: Prototipo            },
  { id: "PlanoProducao",       icon: "📋", label: "Plano de Produção",    Comp: PlanoProducao        },
];

export default function BRPortGDDCompleto() {
  const [doc, setDoc] = useState("ConceitosPrincipais");
  const current = BR_PORT_DOCS.find((d) => d.id === doc) || BR_PORT_DOCS[0];
  const Active = current.Comp;

  return (
    <div style={{ fontFamily: "Georgia, serif", maxWidth: 560, margin: "0 auto", padding: "12px 8px 4px" }}>
      {/* Capa / título global */}
      <div style={{ textAlign: "center", marginBottom: 6 }}>
        <div style={{ fontSize: 11, letterSpacing: 4, textTransform: "uppercase", color: "#9aa", fontFamily: "monospace" }}>
          Game Design Document — Documento Unificado
        </div>
        <div style={{ fontSize: 30, fontWeight: 700, color: "#1a3a5c", letterSpacing: -1, margin: "2px 0" }}>
          ⚓ BR Port
        </div>
        <div style={{ fontSize: 12, color: "#999", fontStyle: "italic" }}>
          v7 — Plano de Produção incorporado · CONGELADO para início da produção do VS
        </div>
      </div>

      {/* Seletor de documento */}
      <div style={{
        display: "flex", gap: 6, justifyContent: "center", flexWrap: "wrap",
        margin: "12px 0", padding: "8px", borderRadius: 14,
        background: "#f4f6f8", border: "1px solid #e2e6ea"
      }}>
        {BR_PORT_DOCS.map((d) => {
          const on = d.id === doc;
          return (
            <button
              key={d.id}
              onClick={() => setDoc(d.id)}
              style={{
                fontSize: 13,
                padding: "8px 16px",
                borderRadius: 99,
                cursor: "pointer",
                border: on ? "2px solid #1a3a5c" : "1px solid #ccc",
                background: on ? "#1a3a5c" : "white",
                color: on ? "white" : "#445",
                fontWeight: on ? 700 : 500,
                fontFamily: "Georgia, serif",
                transition: "all 0.15s",
              }}
            >
              {d.icon} {d.label}
            </button>
          );
        })}
      </div>

      <div style={{ borderTop: "2px solid #e2e6ea", paddingTop: 4 }}>
        <Active />
      </div>

      <div style={{ textAlign: "center", margin: "20px 0 8px", fontSize: 10, color: "#bbb", fontFamily: "monospace" }}>
        BR Port • GDD Completo v7 • Plano de Produção incorporado • {BR_PORT_DOCS.length} documentos reunidos sem perda de informação
      </div>
    </div>
  );
}
