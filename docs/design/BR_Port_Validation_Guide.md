## BR Port: Guia Prático de Validação para um Management Game Mobile Premium Solo

Antes de você investir 6, 12 ou 18 meses construindo o **BR Port** — um simulador premium de gestão de porto costeiro brasileiro em pixel art, com narrativa, NPCs, rivais e progressão por fases — a pergunta certa não é "será que dá pra fazer?", mas sim **"alguém quer jogar isto, e quer o bastante para pagar uma vez por ele em vez de pelo concorrente free-to-play da loja?"**.

A boa notícia: você não precisa do jogo pronto para responder isso. A indústria indie tem hoje um playbook bem definido de validação que pode ser executado em **semanas, com orçamento próximo de zero**, antes de qualquer asset final ser produzido. A regra de ouro, repetida por veteranos como Rami Ismail e por estúdios como o da Mintrocket (Dave the Diver), é: **protótipos servem pra descobrir se você *deveria* fazer o jogo; vertical slice serve para descobrir se você *consegue* fazer; e marketing começa antes do código**.

Este relatório consolida sete frentes — smoke test, prototipagem, validação de mercado, captação de feedback, métricas, casos de referência e stack de ferramentas — em um roteiro acionável para um único desenvolvedor com bolso curto. No final, há um cronograma sugerido de 8–12 semanas para o BR Port atravessar a fase de validação antes de você assumir o compromisso de produção completa.

## 1. Smoke test e landing page de validação

O **smoke test** é a forma mais barata de validar uma ideia: você constrói apenas a "fachada" do produto (uma página, um trailer fake, um anúncio) e mede se as pessoas demonstram intenção real — clicar, se inscrever, fazer wishlist, pré-comprar. A lógica vem do mundo de growth e startups: se 50 pessoas não se interessam por uma página, dificilmente 50 vão instalar o jogo. Em jogos mobile, gigantes do hipercasual como Voodoo e Clap Clap Games usam exatamente isso há anos — criam vídeos de gameplay que *não existem ainda*, rodam como ad no Facebook/TikTok, e só desenvolvem o jogo se o CTR (click-through rate) bater um piso.

### Estrutura mínima de uma landing page de validação para o BR Port

A página não precisa ser bonita; precisa ser **clara, com proposta forte e CTA único**. Para um premium pixel art com ambientação brasileira, o conteúdo essencial é:

- **Headline com proposta única**: algo como "Comande o porto. Domine a costa. Sem anúncios, sem energia, sem espera." Deixa explícito o diferencial premium contra o oceano de mobile F2P.
- **Mockup visual ou GIF curto** (5–10 s) do core loop — pode ser feito no Aseprite + um protótipo bem feio no Godot, gravado e editado. O importante é transmitir o "feel".
- **3–5 screenshots ou mockups** mostrando: gestão do porto, NPCs, ambientação brasileira, sistema de rivais.
- **CTA único**: "Entre na lista de espera" (e-mail), "Adicione à wishlist na Steam" (se você publicar uma página Steam paralela como vitrine, mesmo sendo mobile-first) ou — o sinal mais forte — "Pré-reserve por R$ X,XX". Edwin (Tradecraft) e o playbook clássico da Indie Hackers recomendam testar o botão "Comprar" mesmo sem produto: quem clica vai para uma página "estamos finalizando, deixe seu e-mail" e isso vira um sinal *muito* mais forte que um simples newsletter signup.
- **Preço visível**, mesmo placeholder. Sem preço o visitante não se auto-seleciona, e você confunde curiosos com compradores.

### Critérios de sucesso definidos *antes* do teste

O erro mais comum, segundo a CXL e a Bundl, é rodar o smoke test sem cutoff. Antes de publicar, escreva no papel:

- "Se em 3 semanas atingirmos X% de conversão de visitante → e-mail/wishlist, sigo em frente."
- Benchmarks razoáveis (não são lei, mas servem de bússola):
  - **Conversão landing page → e-mail/waitlist**: 5–15% em tráfego pago direcionado é saudável; abaixo de 2% é sinal de baixa ressonância.
  - **CTR de anúncio de conceito no Meta/TikTok**: o time da GameAnalytics e Matej Lancaric (UA expert) usam como referência para hipercasual **CTR ≥ 4%** para seguir; abaixo de 1,5–2% é red flag. Premium pixel art com nicho de gestão costuma ter CTR menor (1,5–3%) mas com **conversão muito mais alta**, então combine com o sinal de wishlist.
  - **Wishlists na Steam** (se você abrir uma página paralela): sites como "How To Market A Game" sugerem que **acima de 100 wishlists no primeiro mês orgânico já indica ressonância**; abaixo de 7 mil até o lançamento é considerado baixo para Steam, mas para um título mobile-first usado só como vitrine de validação, qualquer crescimento consistente importa.

### Fake door, fake ad e variações úteis

Três variações do smoke test cabem bem no BR Port:

1. **Fake door / "Pré-compre"**: botão de compra que leva a "saindo do forno — deixe seu e-mail e ganhe 30% de desconto no lançamento". Mede intenção quase real de compra.
2. **Fake ad de gameplay**: monte um trailer de 15–30 s mostrando o core loop *como você imagina que vai ser* (mesmo com placeholders), e rode R$ 100–300 em Meta Ads e TikTok Ads segmentando fãs de Mini Motorways, Two Point Hospital, Game Dev Tycoon, Stardew Valley e ambientação brasileira. Compare CTR entre 2–4 criativos diferentes (ex.: um focado em "porto brasileiro", outro em "rivais", outro em "narrativa de NPCs"). O criativo com melhor CTR te diz **qual ângulo vender** o jogo.
3. **A/B de headline e capa**: troque só a headline ou só o key art principal entre versões e veja qual converte melhor (com Carrd, Webflow ou Unbounce o teste leva 1 hora pra montar).

Cuidado importante: **CTR alto não é, sozinho, prova de sucesso**. A Geeklab e a Adjust apontam que ads enganosos podem produzir CTR alto e *piores* taxas de instalação e retenção. Para um premium, você quer CTR moderado + alta intenção (wishlist/e-mail/pré-compra), não cliques baratos.

## 2. Protótipo mínimo viável e vertical slice: provando o core loop antes de produzir os assets

Aqui há uma confusão clássica que vale corrigir antes de gastar uma semana fazendo a coisa errada. Como Rami Ismail (ex-Vlambeer, hoje consultor de indies) descreve no seu material *Levelling The Playing Field*, prototipagem e vertical slice são **dois estágios distintos**:

- **Protótipo**: responde "esse loop é divertido?". É feio, descartável, focado em uma pergunta de cada vez. Pode usar quadrados cinzas, assets de outros jogos, qualquer placeholder.
- **Vertical slice**: responde "eu consigo *produzir* esse jogo no padrão final?". Vem **depois** do protótipo, é uma fatia pequena (5–10 minutos de gameplay) com arte, áudio e UI próximos do final. Custa 1–3 meses.

Para o BR Port, **você precisa do protótipo primeiro**. Pular direto para o vertical slice é o que a Wayline chama de "vertical slice deception": polir cedo demais cria apego emocional a mecânicas talvez quebradas, e descobrir o problema custa caríssimo de consertar.

### O protótipo do BR Port: o que cortar e o que manter

O core loop de um management game de porto provavelmente é algo como: **receber navio → alocar recursos/funcionários → resolver gargalo → faturar → reinvestir → enfrentar rival/evento → próxima fase**. Esse ciclo é o que precisa ser testado, e nada mais.

Recomendações concretas:

- **Use retângulos coloridos no lugar dos assets de pixel art**. Aseprite vai esperar. O Stardew Valley começou com placeholders horrorosos por anos. Validar fun factor primeiro.
- **Reduza a 1 tipo de navio, 1 tipo de carga, 2 funcionários, 1 rival, 3 fases**. Se for divertido nesse mínimo, será divertido escalado. Se não for, mais conteúdo não conserta.
- **Sem narrativa, sem NPCs, sem progressão de carreira no protótipo**. Esses elementos *amplificam* um core loop bom, mas **não salvam** um core loop sem graça. Teste o esqueleto primeiro.
- **Implemente cedo a "feel"** do toque mobile: arraste, tap, feedback tátil/visual. Em mobile, 70% do prazer está no *juice* dos gestos. Um botão satisfatório vale mais do que três features extras.
- **Tempo de sessão alvo**: 3–7 minutos por "rodada/fase". Mobile premium é jogado em transporte público, fila, banheiro. Se uma fase exige 25 min ininterruptos, retenção mobile despenca.

Defina previamente o que significa "protótipo bem-sucedido". Sugestão de critérios para o BR Port:

1. **5+ playtesters jogam por 15 minutos sem instrução e pedem "mais uma rodada"** sem você puxar a conversa.
2. **Pelo menos 3 deles descrevem espontaneamente uma "estratégia"** que desenvolveram — sinal de que o sistema permite agência e profundidade.
3. **Zero playtester abandona antes de 5 min** alegando confusão sobre o objetivo.

Se esses critérios não baterem, **itere o protótipo antes de pensar em arte**.

### Vertical slice: vem só depois

Quando o protótipo provar diversão, então sim você constrói o vertical slice: uma única fase do BR Port (digamos, Porto de Santos, 1900) com pixel art final, 1 NPC com diálogo escrito, 1 rival funcional, UI mobile responsiva, áudio mínimo (música + 5 SFX). Aqui o objetivo é duplo:

- **Para você**: descobrir quanto tempo leva produzir uma fase em qualidade final. Multiplique pelo número de fases planejadas — é o seu cronograma real. Foi exatamente isso que a Monolith Soft fez por exigência da Nintendo em *Xenoblade Chronicles*: produziram **uma região completa em qualidade final** e usaram esse dado para orçar o jogo inteiro.
- **Para o mercado**: virar o "vertical slice demo" que você vai publicar no itch.io, mandar para streamers e usar em ads de conversão real.

## 3. Estratégias de validação de mercado sem lançar o jogo completo

Existem várias camadas de validação de mercado entre "página com e-mail capture" e "lançamento global na App Store". Para um solo dev premium, **empilhar essas camadas** sequencialmente é o que reduz risco sem queimar orçamento.

### Pré-lançamento (anúncio precoce)

Mesmo sendo mobile-first, **abra uma página Steam Coming Soon do BR Port** o mais cedo possível, mesmo que você só pretenda vender mobile depois. Por quê:

- Wishlists na Steam funcionam como termômetro público e gratuito de interesse. Ninguém precisa pagar para sinalizar intenção.
- Steam Next Fest (3x por ano) é uma vitrine grátis e enorme. Indies como NIMRODS, Mushroom Musume e dezenas de outros tracionam ali.
- Você pode fazer crossplatform depois (Steam Deck + mobile) ou usar Steam só para validar, com o foco principal sendo Google Play e App Store.
- O conselho recorrente de "How To Market A Game" (Chris Zukowski) é simples: **suba a página Steam o mais cedo possível, mesmo que o jogo só saia em 1–2 anos. Wishlists pequenas são ruído individual; em agregado, validam ressonância**.

Para mobile especificamente, abra **pré-registro na Google Play** assim que tiver assets suficientes — é gratuito, captura intenção e gera notificação automática no lançamento.

### Demo no itch.io: a etapa que ninguém deve pular

O caso da NIMRODS, documentado pelo Chris Zukowski, é didático: o estúdio postou uma versão "um pouco além de game jam" no itch.io em maio de 2023, manteve atualizando até outubro de 2024, e usou aquilo como **public beta com a comunidade**. Quando lançaram em Early Access na Steam, já tinham milhares de wishlists e tração orgânica. Importante: **o itch demo não canibalizou as vendas Steam** — pelo contrário, alimentou-as.

Recomendação para o BR Port:

1. Publique uma **demo WebGL/Android jogável no itch.io** assim que o protótipo estiver minimamente apresentável (mesmo com placeholders).
2. Mantenha gratuita. O itch tem comunidade que recompensa exposição: views, comentários, ratings, tudo é dado de validação real.
3. Coloque um link claro para a wishlist Steam e para o e-mail de waitlist na página do itch.
4. Use o itch como **lab vivo**: atualize a cada 2–4 semanas, registre o que muda na retenção, peça feedback nos devlogs.

### Early Access: cuidado com a armadilha

Zukowski é categórico: **Steam Early Access não é incubadora**. EA é seu lançamento, e exige um jogo com dezenas de horas de conteúdo e milhares de wishlists já acumuladas — caso contrário, você queima sua janela de visibilidade Steam com uma audiência fria. Para um mobile premium, **EA da Steam não é o caminho**; o caminho é: itch.io → soft launch mobile → lançamento global.

### Soft launch em mercados secundários (estratégia mobile)

Big mobile fazem isso sempre: lançam primeiro em Filipinas, Canadá, Holanda ou Brasil (mercados menores ou com perfil similar ao alvo final) por 1–3 meses, medem retenção, monetização e ajustam. Para um solo dev, uma versão simplificada:

- **Lance no Brasil + Portugal primeiro** no Google Play (sem App Store ainda, para evitar fee Apple). Você é brasileiro, falará com seu público, e o tema do jogo é nativo.
- Use isso como **validação de monetização real**: a R$ 19,90 ou R$ 24,90, quantas vendas em 30 dias? Calcule sua taxa de conversão sobre installs orgânicos.
- Só vá para o lançamento global (EUA, Europa, Ásia) com dados.

### Crowdfunding como ferramenta de validação binária

Kickstarter mudou de propósito ao longo dos anos. Como o Codecks resume, hoje campanhas exigem meses de preparação e raramente são "lance pra ver se rola". Mas continua sendo o **teste de demanda mais brutalmente honesto que existe**: as pessoas botam dinheiro de verdade.

Para o BR Port, faz sentido pensar em Catarse ou Kickstarter **se** você já tiver:

- Um vertical slice que funciona e gera reação positiva em playtest;
- Uma audiência mínima (1–3 mil pessoas em alguma rede — Twitter, TikTok, Discord, lista de e-mail);
- Tempo para fazer um trailer profissional e dedicar 2–3 meses à campanha.

Caso contrário, fica como Plan B depois das outras camadas.

## 4. Como conseguir feedback de jogadores reais cedo

Feedback de jogadores reais (não da sua mãe e do seu melhor amigo) é o combustível da iteração. Para um solo dev brasileiro com um jogo de nicho-mas-cultural-forte, há canais com ROI excelente.

### Playtest presencial e remoto

- **Faça playtest sempre que possível em pessoa**, mesmo que sejam 3–5 pessoas. Observe **silenciosamente** onde travam, o que tocam, o que ignoram. As pessoas mentem (educadamente) sobre divertimento, mas a linguagem corporal não.
- **Sessões remotas via Discord + Parsec/Steam Remote Play** funcionam para testar a build no PC simulando mobile (vertical com mouse), gravando reações com tela compartilhada. Use roteiro de "task" ("tente terminar a primeira fase", "tente derrotar o rival") em vez de perguntas abertas.
- Plataformas como **PlaytestCloud** e **UserTesting** são opções pagas, mas saem caro (US$ 30–80 por sessão). Para solo dev, comece grátis e só pague quando precisar de público fora da sua bolha.

### Discord: a comunidade mais valiosa para indies hoje

A maioria dos hits indie modernos teve Discord ativo desde antes do lançamento. Algumas ações concretas para o BR Port:

- **Crie seu próprio Discord** já na semana que abrir a landing page. Pode começar vazio. Cada e-mail capturado leva para lá.
- **Entre em servidores existentes** e participe genuinamente (não spamme):
  - r/IndieDev Discord
  - Discords de gêneros próximos: Game Dev Tycoon, Two Point Hospital, Mini Motorways, Stardew Valley, Project Zomboid (gente de gestão/sim hardcore)
  - Comunidades brasileiras: BIG Festival, BRGameDev, Discord da ABRAGAMES, GameDev BR
  - Servidores de pixel art (Pixel Joint, Lospec)
- **Faça "Feedback Friday"** mostrando devlog curtinho. Pessoas adoram opinar e se sentem parte.

### Reddit: subreddits que importam

Reddit ainda gera mais leads qualificados que TikTok para gêneros de nicho. Subreddits relevantes para o BR Port:

- **r/IndieDev** e **r/gamedev** — comunidade dev, bom para feedback técnico e de marketing.
- **r/playmygame** e **r/IndieGaming** — comunidade que **explicitamente quer testar** seus protótipos. Postar build jogável aqui rende feedback em horas.
- **r/incremental_games**, **r/IdleGames**, **r/managementgames**, **r/CityBuilders** — público-alvo direto se o BR Port tiver elementos de gestão profunda.
- **r/PixelArt** — para validar a parte visual isoladamente.
- **r/brdev**, **r/gamedevBR**, **r/jogosindie** — comunidade brasileira.

Um caso emblemático: o solo dev argentino Matías Colotto, criador de **Magic Research**, gerou **mais de US$ 400 mil em 12 meses** com **apenas dois posts no r/incremental_games**, sem nenhuma campanha paga. Subreddit certo > orçamento de marketing.

Regras práticas para postar no Reddit: leia a regra de cada sub (alguns proíbem self-promo, outros têm dia específico — "Self-Promo Saturday"). Não venda; mostre. Coloque GIF ou vídeo curto no corpo do post, não link externo (Reddit penaliza). Responda *todos* os comentários nas primeiras 6h.

### TikTok, Twitter/X, Bluesky, YouTube Shorts

Devlogs curtos (15–60 s) em TikTok têm penetração viral inigualável hoje para indies. Mas atenção ao alerta de "How To Market A Game": **views viraliais não convertem se o público não está logado em Steam ou loja**. TikTok é mobile-friendly, então para BR Port isso é vantagem — public TikTok = público mobile.

Estratégia mínima: **um post por dia**, mostrando algo do dev (mesmo trivial: "como faço o pixel art do contêiner", "o NPC do estivador hoje"). Hashtags: #gamedev #indiegame #pixelart #brasil #jogosindie #devlog. Não espere viralizar nos primeiros 30 posts. A "regra dos 100 vídeos" se aplica.

### Eventos e showcases brasileiros

- **BIG Festival** (Brazil's Independent Games Festival) — historicamente um trampolim para indies BR. Diversos jogos como *Chroma Squad*, *Dandara*, *Out of Space* tiveram exposição internacional ali.
- **Latin American Games Showcase** (parte do Summer Game Fest) — chance de exposição global.
- **SBGames** — acadêmico, mas com bom networking.
- **Brasil Game Show (BGS)** — área indie cresceu nos últimos anos.
- **Game jams locais** (Global Game Jam, Ludum Dare, Itch jams temáticas) — você pode usar uma jam para construir o protótipo do core loop em 48–72h, e já levar feedback.

### A regra mais importante: peça feedback específico

"O que você achou?" gera respostas inúteis. Pergunte:

- "No minuto 3, você parecia confuso. O que estava tentando fazer?"
- "Se o jogo custasse R$ 24,90, você compraria? Por quê / por que não?"
- "Que outro jogo te lembrou? E o que ele faz melhor?"

Use o framework de *The Mom Test* (Rob Fitzpatrick): só confie em fatos sobre comportamento passado, nunca em promessas sobre comportamento futuro.

## 5. Métricas de validação: o que medir para saber se a ideia tem potencial

Métrica sem decisão atrelada é vaidade. Antes de medir qualquer coisa, defina: **"se essa métrica bater X, eu sigo. Se ficar abaixo, eu pivoto ou paro."** Isto pega tudo: pixels gastos em ads, semanas de dev, sua sanidade.

### Métricas de validação de mercado (pré-código completo)

| Métrica | O que mede | Benchmark de referência | Onde medir |
|---|---|---|---|
| **CTR do ad de conceito** | Atratividade da ideia | Hipercasual: 4%+ é bom, <1,5% mata o conceito. Premium/midcore: 1,5–3% saudável; combine com conversão | Meta Ads, TikTok Ads |
| **Conversão LP → e-mail/wishlist** | Intensidade do interesse | 5–15% em tráfego pago direcionado é forte; <2% é red flag | Google Analytics, Plausible |
| **Wishlists Steam / mês orgânico** | Demanda agregada | 100+ no 1º mês orgânico = boa ressonância; cresce com tempo | Steamworks dashboard |
| **Pré-registros Google Play** | Intenção mobile real | Sem benchmark público fixo; busque crescimento de 2–5×/mês com posts orgânicos | Google Play Console |
| **Custo por inscrição (CPL)** | Eficiência do funil | <US$ 1 por e-mail/wishlist em tráfego pago é ótimo para mobile premium nichado | Meta/Google Ads |

### Métricas de validação de produto (com protótipo/demo na mão)

Quando o protótipo já está jogável (no itch.io, em playtest, em soft launch):

| Métrica | Definição | Benchmark de referência |
|---|---|---|
| **Retenção D1** | % que abre o jogo no dia seguinte | Mobile premium bom: 35–45%+. F2P referência: 35–40% D1. <25% = problema no onboarding ou no fun. |
| **Retenção D7** | % que continua jogando após 1 semana | Premium/midcore bom: 15–25%. Sinal forte de "vale o preço". |
| **Sessão média (min)** | Tempo médio por abertura | Mobile premium gestão: 6–15 min. Se <2 min, jogadores não estão engajando; se >25 min, talvez não esteja "mobile-friendly". |
| **Sessões/dia** | Quantas vezes o jogador volta no mesmo dia | Bom mobile: 2–4. Sinal de hábito. |
| **Tempo até primeiro "aha moment"** | Quanto leva até o jogador entender e gostar | Idealmente <2 minutos. |
| **% que completa tutorial** | Conclusão da fase 1 | Acima de 70% indica onboarding ok. Abaixo de 50%, refaça. |
| **Net Promoter Score (NPS)** ou "compraria por R$ X?" | Intenção declarada de compra/recomendação | NPS ≥ 30 é decente; ≥ 50 é forte. |

### Para o BR Port especificamente

Combine três sinais antes de tomar a decisão "ir para produção completa":

1. **Sinal de mercado**: pelo menos 500 wishlists/pré-registros/e-mails acumulados em 2–3 meses de marketing leve, ou CPL <R$ 4 sustentável.
2. **Sinal de produto**: protótipo gera **3+ playtesters pedindo "mais uma rodada"** organicamente e retenção D1 do demo itch.io >35% (mede pelo Plays/Returning Users).
3. **Sinal de monetização**: em soft launch ou pré-compra, **conversão visitante → comprador ≥ 1–2%** a R$ 19–24,90 (preço médio de premium indie no Brasil hoje).

Se os três sinais forem positivos: comprometa-se com a produção completa. Se 2 de 3: itere mais 6–8 semanas no ponto fraco. Se 0 ou 1: **pivote o conceito ou abandone**. Dói, mas dói menos do que descobrir isso depois de 9 meses de dev.

### Ferramentas de analytics gratuitas

- **GameAnalytics** (gratuito até volumes altos) — eventos, retenção, funil.
- **Firebase Analytics + Crashlytics** (gratuito do Google) — padrão para mobile.
- **Unity Analytics / Unity Cloud** ou **Godot + plugin de analytics** com endpoint próprio (Supabase free tier resolve).
- **Plausible** ou **Umami** (analytics da landing page, leves e privacy-friendly; Plausible tem teste grátis, Umami é open source).
- **Hotjar free tier** — mapas de calor da landing page, vê onde as pessoas clicam e param.

## 6. Casos de sucesso de quem validou cedo

Três tipos de caso valem o estudo: solo devs internacionais que validaram cedo; estúdios pequenos que usaram Early Access/itch como rampa; e brasileiros que provaram que dá para ir longe.

### Dave the Diver (Mintrocket) — o exemplo mais relevante para o BR Port

Apesar de hoje ser produto de subsidiária da Nexon, Dave the Diver é o caso mais próximo do que você quer fazer:

- **Conceito comparável**: management sim + ação + narrativa + pixel art. Vendeu **mais de 5 milhões de cópias** até nov/2024, premium.
- **Validação por Early Access**: entrou em EA em **outubro de 2022** e só lançou versão final em junho de 2023. O diretor Jaeho Hwang afirma em entrevista que o EA foi *fundamental* — eles refinaram missões, balanceamento, dificuldade com base em feedback.
- **Origem como protótipo descartado**: o projeto começou em 2017 como um conceito simples "mergulhador pesca peixes". Esse protótipo foi **considerado simplista e descartado**, e a equipe reiniciou com foco em resource management. **Eles cortaram o conceito ruim em vez de teimar.**
- **Mobile premium em desenvolvimento**: a Mintrocket está fazendo a versão mobile como **premium pago**, confirmando que existe mercado mobile para management premium quando o jogo se diferencia.

Lição para o BR Port: não tenha medo de jogar fora a primeira versão se o protótipo provar fraco. E o pixel art + management + narrativa é uma fórmula provada que escala.

### Magic Research (Maticolotto) — solo dev premium

- Solo dev argentino Matías Colotto, idle/management de magia, mobile premium 4,9 estrelas no Google Play.
- **Mais de US$ 400 mil em 12 meses** com **zero ads pagos** — só 2 posts no subreddit certo (r/incremental_games).
- Validação: encontrou o nicho, postou em comunidade do nicho, deixou retenção e word of mouth fazerem o trabalho.

Lição: para premium nichado, **comunidade > publicidade**. Ache os subreddits/Discords do seu nicho e seja parte deles antes do lançamento.

### NIMRODS (Underplayed Games) — a rampa itch → Steam

- Roguelite postou versão "além de game jam" no itch.io em maio/2023, manteve por 17 meses, fez **123 mil views e 81 mil plays no browser**.
- Usou survey para fazer gut check da ideia e dimensionar oportunidade.
- Lançou Steam EA em out/2024 com tração orgânica acumulada; mais de 1.200 reviews no Steam pós-lançamento.
- Demo itch *não canibalizou* o jogo Steam pago — ao contrário, alimentou.

Lição: itch.io como laboratório longo é estratégia comprovada.

### Vampire Survivors (poncle) — escopo apertado, ciclo rápido

- Luca Galante lançou versão inicial **em poucos meses** a US$ 3. Iterou em público, ouviu a comunidade, escalou.
- Validou o core loop antes de tudo: o "fun" das hordas + builds estava lá desde a primeira versão feia. Polimento veio depois.

Lição: scope tight, lance cedo barato, escale o que provar funcionar.

### Bart Bonte (puzzles mobile premium) — sobrevivência sustentada como solo

- Belga, solo dev de puzzles mobile há ~10 anos. Faz tudo: código, arte, música.
- Estratégia documentada em texto público: **muitos jogos pequenos** (3–4 meses cada) > um grande hit. Catálogo gera revenue longo (curvas long-tail).
- Foco em premium + alguns free com IAP suave; restrições autoimpostas como motor criativo.

Lição para você: se o BR Port for seu primeiro mobile, considere primeiro um jogo de **escopo menor** para validar pipeline, monetização e canais antes de comprometer 12+ meses no BR Port "completo".

### Casos brasileiros relevantes

- **Pocket Trap (Dodgeball Academia, Pipistrello and the Cursed Yoyo)** — pixel art, narrativa, escala consistente. Showcase circuit (BIG, Gamescom) foi parte importante da validação.
- **Behold Studios (Knights of Pen & Paper, Chroma Squad)** — Brasília. Validaram premiações em festivais (SBGames, SXSW) antes de lançamentos globais.
- **Rockhead Games (Starlit Adventures)** — Porto Alegre. Mobile premium primeiro, depois console.
- **Long Hat House (Dandara)** — pixel art metroidvania brasileiro publicado pela Raw Fury; usaram demo e showcase para conquistar publisher.
- **Mad Mimic (Dolmen, Mark of the Deep)** — presença em Gamescom 2024 antes do lançamento, gerando wishlist e cobertura.
- **Aquiris (Horizon Chase)** — mobile premium brasileiro que conquistou Apple e prêmios internacionais.
- **Mombo Combo Legacy** — sequência de Super Mombo Quest (>1M downloads, 4.8 na Play Store). Mostra que mobile premium-ish brasileiro escala.

Padrão recorrente: **festivais + showcases + demo público + community building** antes do lançamento. Nenhum desses jogos surgiu "do nada".

## 7. Ferramentas gratuitas ou baratas para o solo dev

Para solo dev brasileiro, sem dinheiro para Asset Store cara nem licenças anuais, há um stack confortável que cobre todo o pipeline.

### Game engine: Godot vs. Unity para o BR Port

Para um 2D pixel art mobile premium, **Godot 4 é provavelmente a melhor escolha em 2026**:

- **Gratuito e open source**, sem royalty, sem mudanças de licença (Unity teve crise pública de licenciamento em 2023/2024 — Godot é à prova de surpresa).
- **Workflow 2D nativo**: pixel-perfect movement, sprite import sem ajuste manual, scenes intuitivas. Vários devs migraram de Unity especificamente por causa do 2D.
- **GDScript** (parecido com Python) é fácil de aprender e iterar; também suporta C#.
- Performance ótima em mobile para 2D.
- Comunidade brasileira crescente (canais como Ksp1996, GDQuest em PT-BR).
- Trade-off: **mercado/asset store menor que Unity**; tutoriais específicos de mobile premium são mais escassos; deploy para iOS exige passos manuais. Para iOS especificamente, Unity ainda tem caminho mais batido.

Considere **Unity** se: você já tem familiaridade prévia, precisa de Asset Store rica, ou planeja iOS desde o primeiro dia. O free tier serve até US$ 200k de receita anual.

Alternativas: **GameMaker Studio** (excelente para pixel art, usado em Undertale, Hyper Light Drifter; tem export mobile pago) e **Construct 3** ou **GDevelop** (no-code/low-code, ótimos para protótipo rápido de validação).

### Recomendação prática

Para a **fase de protótipo de validação** (semanas 1–6 do BR Port): considere usar **Godot** ou até **GDevelop** se você quer só testar o loop sem aprender engine. Para a fase de produção: **Godot 4 com GDScript** se for sua primeira engine; **Unity** se já tem proficiência ou precisa de iOS desde já.

### Pixel art e arte

- **Aseprite** (US$ 19,99 uma vez) — padrão de fato para pixel art. Vale o investimento mínimo.
- **LibreSprite** — fork gratuito do Aseprite.
- **Pyxel Edit** — alternativa com forte suporte a tilemaps.
- **Lospec.com** — paletas pré-prontas (use uma paleta brasileira — verde-amarelo + tons terrosos costeiros — para identidade visual única).
- **itch.io asset packs** — muitos pacotes pixel art gratuitos ou ≤ US$ 5 (mas evite usá-los no jogo final premium se for vendido como original).

### Áudio

- **LMMS** ou **Bosca Ceoil** — música 8/16-bit, gratuitos.
- **Bfxr** ou **ChipTone** — SFX 8-bit grátis online.
- **Audacity** — edição.
- **Freesound.org** e **OpenGameArt.org** — sons CC0 e CC-BY.
- **Suno** ou **Udio** (IA) — útil para placeholders ou trilhas atmosféricas; verifique licença para uso comercial.

### Landing page e smoke test

- **Carrd.co** — landing page profissional em 1h, US$ 19/ano plano Pro, free tier para protótipo.
- **Webflow** ou **Framer** — mais polido, free tier suficiente.
- **Notion + Super.so** — landing page barata a partir de uma página Notion.
- **GitHub Pages + template HTML** — 100% grátis, só dá trabalho.
- **MailerLite** ou **Buttondown** (free tier) — captura de e-mail e newsletter.
- **Tally.so** ou **Typeform** free — surveys de validação.
- **Plausible / Umami / Google Analytics** — analytics.

### Tráfego e validação paga

- **Meta Ads Manager** (Facebook/Instagram) — orçamento mínimo R$ 5/dia. Para teste de CTR de conceito, R$ 300–500 já gera amostra estatisticamente útil.
- **TikTok Ads** — bom para vídeo curto de gameplay.
- **Reddit Ads** — barato para nichos específicos.

### Distribuição da demo / validação

- **itch.io** — gratuito, taxa flexível (default 10%, você define), WebGL para jogar no browser, dashboard simples. Ideal para o demo de validação.
- **Google Play Console** — US$ 25 uma vez (vitalício). Pré-registro gratuito, soft launch por país.
- **Apple App Store Connect** — US$ 99/ano. Só pague quando estiver mais perto do lançamento.
- **Steam (Steamworks)** — US$ 100 por jogo (Steam Direct fee). Página Coming Soon e wishlist são as ferramentas mais valiosas mesmo para mobile-first.

### Versionamento e gestão

- **Git + GitHub** (free tier privado ilimitado para solo).
- **GitHub Desktop** ou **GitKraken** se preferir GUI.
- **Trello / Notion / Codecks (especializado em gamedev)** — backlog e gestão.
- **HacknPlan** — gratuito, voltado para gamedev.

### Total de custo da fase de validação (estimativa)

| Item | Custo |
|---|---|
| Godot + Aseprite + ferramentas free | R$ 0 + ~R$ 100 (Aseprite) |
| Carrd Pro + domínio | ~R$ 200/ano |
| Steam Direct (1 jogo) | ~R$ 550 (US$ 100) |
| Google Play Dev fee | ~R$ 140 (US$ 25, uma vez) |
| Ads de validação (Meta + TikTok) | R$ 500–1.500 (variável) |
| **Total fase validação** | **R$ 1.500–2.500** |

Tudo isto antes de gastar 1 hora a mais de dev em recursos não validados. Comparado a 6+ meses de oportunidade perdida construindo o jogo errado, é barato.

## Cronograma sugerido: 12 semanas de validação para o BR Port

Compilando tudo: este é um cronograma sugerido para o BR Port atravessar validação completa antes de você assumir um compromisso de produção de 9–12 meses. Trabalhe em paralelo sempre que possível.

### Semana 1–2: Pesquisa, posicionamento e setup

- Estude concorrentes: Mini Motorways, Two Point Hospital, Game Dev Tycoon, Project Highrise, Pocket City, Mini Metro, Dave the Diver. Leia reviews 1 e 2 estrelas — eles dizem o que falta no mercado.
- Defina **uma frase de posicionamento** ("Gerencie o porto costeiro mais movimentado do Brasil em pixel art, com rivais, histórias e zero anúncios").
- Crie identidade visual mínima (logo, paleta, 2–3 mockups).
- Suba **landing page no Carrd** com CTA único + captura de e-mail e Discord.
- Crie Twitter/X, TikTok, Instagram e Discord do BR Port.
- Faça pesquisa rápida no Reddit (r/managementgames, r/CityBuilders, r/CozyGamers, r/incremental_games) só lendo: o que o público quer e o que reclama.

### Semana 3–6: Protótipo de core loop (placeholders)

- Em Godot ou GDevelop, construa o **loop bruto** com retângulos: navio chega → aloca trabalhador → resolve carga → faturamento → fase 2.
- Sem arte, sem narrativa, sem polish.
- A cada semana: 2–3 playtests com pessoas que não te amam. Anote *comportamento*, não opinião.
- Itere até 5+ playtesters pedirem "mais uma rodada" sem incentivo.

### Semana 5–8 (em paralelo): Smoke test de marketing

- Crie um trailer de 20–30 s com mockups + gameplay simples do protótipo.
- Rode **R$ 300–500 em Meta Ads + TikTok Ads** segmentando fãs dos jogos concorrentes, com 3–4 variações de criativo (foco em "porto brasileiro", "rivais", "narrativa", "sem ads/energia").
- Meça CTR e conversão da landing page.
- Poste no r/playmygame, r/IndieDev, r/gamedev, Twitter/TikTok.
- Abra **Steam page Coming Soon** + pré-registro Google Play.

### Semana 9–12: Decisão e demo polida (se for em frente)

- Avalie o **dashboard de validação**:
  - 500+ inscritos somando e-mail + wishlists + pré-registros?
  - CTR ≥ 1,5–2% no melhor criativo?
  - 5+ playtesters genuinamente engajados?
- Se sim em pelo menos 2 de 3: **comprometa-se** com o vertical slice.
- Se não: pivote o ângulo (talvez o BR Port deva ser "porto + restaurante" à la Dave the Diver, ou "narrativa de família dona do porto" à la Disco Elysium gestão, ou hyper-focar em uma cidade). Volte para o protótipo.

### Semana 13–24: Vertical slice (uma fase em qualidade final)

- Uma fase completa em pixel art final, 1 NPC com diálogo, 1 rival, UI responsiva mobile, áudio mínimo.
- Publique **demo gratuita no itch.io** (build Android e WebGL).
- Devlog público semanal (TikTok + Twitter + Discord).
- Considere submeter ao **BIG Festival** e **Steam Next Fest**.
- Acompanhe retenção D1/D7 dos jogadores do demo itch.io.

### Semana 25+: Decisão final de produção

Com vertical slice, demo pública, números reais, festivais, comunidade — você terá clareza honesta sobre se o BR Port merece os 6–9 meses adicionais de produção full, e quanto pode esperar de vendas. Se decidir avançar, considere então **Catarse/Kickstarter** para co-financiar e validar mais profundamente, **soft launch Brasil + Portugal** antes do global, e **publisher indie** se você quiser apoio de marketing (Raw Fury, Akupara, Hooded Horse, Coffee Stain Publishing já publicaram brasileiros).

---

### Os princípios que importam mais que qualquer tática específica

1. **Anuncie cedo, mesmo feio.** Para 99% dos devs, ninguém está esperando seu jogo. Comece a construir audiência no dia 1.
2. **Separe protótipo (fun?) de vertical slice (consigo produzir?).** Não polir antes de provar o loop.
3. **Comportamento > opinião.** Wishlists, pré-compras, retenção D7 valem mais que 100 "achei legal".
4. **Defina critérios de sucesso *antes* dos testes**, no papel, com número.
5. **Comunidade > publicidade para premium nichado.** Magic Research provou: 2 posts no subreddit certo > US$ 10k em ads.
6. **Esteja disposto a matar a ideia.** Validação que diz "não" é tão valiosa quanto validação que diz "sim". A Mintrocket descartou o primeiro Dave the Diver inteiro e refez. Você não está casado com a primeira versão do BR Port.
7. **Sua identidade brasileira é diferencial, não desvantagem.** Pixel art + tema cultural local + ambientação portuária do Brasil é exatamente o tipo de nicho específico que faz indies premium funcionarem hoje. Mas explore-o com profundidade real (folclore, regionalismos, personagens icônicos das cidades portuárias — Santos, Salvador, Recife, Belém, Manaus), não como verniz superficial.

O BR Port é, no papel, um projeto com mercado plausível e diferencial claro. A pergunta não é se vale a pena fazer — é se vale a pena fazer **agora, deste jeito, neste escopo, sozinho**. As próximas 8–12 semanas de validação responderão isso com dados, e você terá investido entre R$ 1.500 e R$ 2.500 em vez de meio ano da sua vida. Vá em frente.

Relatório completo entregue em sete seções principais mais introdução e cronograma de fechamento, cobrindo: smoke test e landing page (com benchmarks de CTR e conversão), distinção entre protótipo e vertical slice com critérios de sucesso, estratégias de validação de mercado (Steam wishlist, itch.io, Early Access, soft launch, crowdfunding), captação de feedback (playtest, Discord, Reddit, eventos brasileiros), métricas com benchmarks específicos (retenção D1/D7, CPL, NPS, wishlists), casos de sucesso (Dave the Diver, Magic Research, NIMRODS, Vampire Survivors, Bart Bonte, e jogos indie brasileiros), stack de ferramentas para solo dev (Godot recomendado para 2D pixel art, Aseprite, Carrd, Meta/TikTok Ads, itch.io), e um cronograma prático de 12 semanas com decisão de go/no-go baseada em dados, fechando com 7 princípios estratégicos. Custo total estimado da fase de validação: R$ 1.500–2.500.