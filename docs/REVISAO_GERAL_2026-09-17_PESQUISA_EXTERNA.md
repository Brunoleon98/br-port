# Prompt de pesquisa profunda — a partir da revisão de 17/09

> **O que é.** O pedido de pesquisa que sai da revisão geral
> (`docs/REVISAO_GERAL_2026-09-17.md`), escrito para ser colado inteiro numa
> ferramenta de pesquisa profunda externa (ChatGPT Deep Research ou
> equivalente). Ele é **auto-contido**: quem o lê não tem o repositório, e o
> prompt diz isso com todas as letras em vez de contar com um anexo.
>
> **Por que existe.** A revisão diz o que está torto e propõe o conserto de
> cada coisa. O conserto proposto é o de quem estava dentro do problema — e
> este projeto regista o que acontece quando se acredita numa previsão sem a
> medir. A pesquisa existe para **atacar os consertos propostos** e trazer o
> que a indústria já resolveu, com fonte.
>
> **Como usar.** Copie tudo entre as duas linhas de corte. Se a ferramenta
> aceitar anexo, mande junto o `REVISAO_GERAL_2026-09-17.md` — mas o prompt
> não depende disso.
>
> **O que fazer com a resposta.** Ela é entrada da F1 de uma sessão futura (o
> desenho da medição), nunca um patch para aplicar. Uma recomendação sem prova
> desenhada continua a ser uma previsão, e este repositório não as aceita.

---
✂️ ─────────────── INÍCIO DO PROMPT ───────────────

Você vai fazer uma pesquisa profunda para me ajudar a decidir **como**
consertar onze coisas num jogo mobile que estou construindo, e a descobrir
onde o conserto que eu já imaginei é pior do que o que a indústria faz. Quero
estado da arte com fontes, e crítica ao que eu proponho — não concordância.

## 1. O projeto, em vinte linhas

**BR Port** é um jogo mobile de gestão de porto, em **Godot 4.6.3 com
GDScript**, retrato travado em 720×1280 (`stretch/mode = canvas_items`, ou
seja, o aparelho renderiza na resolução nativa e o conteúdo 2D é escalado), em
**português do Brasil** — código, comentários e documentos em português.
Desenvolvimento solo, com assistentes de IA a escrever a maior parte do código
sob regras escritas.

A Fase 1 é o *vertical slice*: 4 semanas de 8 turnos ("dias"), 3 docas, 7
estruturas para construir, uma parcela de dívida a vencer no fim, três
personagens que falam (a contadora, o rival, o banqueiro), e um mapa
isométrico gerado por script (SVG por Python; props renderizados em Blender
headless por script, nunca por gerador de imagem).

A cultura do projeto, que importa para o formato da sua resposta:

- **Mede-se antes de mexer.** Há um simulador que joga 600 partidas por perfil
  de jogador em 26 segundos e imprime taxas, medianas e margem operacional.
- **Toda guarda nova é provada com um DEFEITO INJETADO**: escreve-se o teste,
  quebra-se o código de propósito, e exige-se que ele reprove. Um validador que
  nunca reprovou nada não é um validador. Há doze maneiras registadas de um
  defeito injetado não provar nada (o defeito longe da linha amostrada, a regra
  duplicada em dois sítios, a asserção que monta o esperado da mesma fonte do
  defeito, o `mini` trocado por `maxi` que passa porque os dois valores quase
  sempre coincidem…).
- **Aprovação é uma STRING na saída, não o código de saída** — um erro de
  execução em GDScript aborta a função e o processo encerra com 0.
- O CI (GitHub Actions, Ubuntu, headless) roda seis suítes, um validador de
  assets, um conferidor de documentação, regenera mapas/sons/tabelas e **compara
  byte a byte**, exporta APK e build Web, e tira 16 capturas determinísticas
  (semente fixa e `--fixed-fps 60`).

## 2. O que você NÃO tem, e o que isso implica

**Você não tem o repositório e não vai ter.** Portanto:

- **Não invente caminhos de arquivo, nomes de função ou trechos "do meu
  código".** Quando precisar mostrar código, escreva GDScript 4.x ou Python
  genérico e rotule como esboço.
- **Não me devolva um patch.** Devolva decisões fundamentadas, com o
  trade-off e a fonte.
- Onde a resposta depender de um detalhe que só eu tenho, **diga qual detalhe
  é e o que muda conforme ele** — em vez de assumir.
- Prefira fonte primária: documentação do Godot 4.x, W3C/WCAG, ITU-R/EBU,
  palestras da GDC, post-mortems, papers. Fóruns e blogs valem quando são a
  única fonte, e devem ser marcados como tal.
- **Diga quando não há resposta consolidada.** "A indústria não converge nisto"
  é uma resposta útil; um consenso inventado não é.

## 3. As restrições que a resposta tem de respeitar

Uma recomendação que as viole é inútil para mim, por mais correta que seja no
geral:

1. **Godot 4.6.3 + GDScript.** Sem C#, sem GDExtension, sem plugin pago.
2. **Não se mexe** nas constantes de balanceamento, na projeção isométrica, na
   versão do save, nem em nada que o CI compare byte a byte — cada um desses
   tem processo próprio e medição própria.
3. **Nada de dependência pesada.** O contêiner de desenvolvimento não alcança
   o SDK do Android; Python usa biblioteca padrão sempre que possível (o
   gerador de som inteiro é biblioteca padrão). `numpy`/`pillow` são aceitáveis
   em ferramenta de análise; um download de 1 GB não é.
4. **Não há placa de som** em lado nenhum da cadeia — nem aqui, nem no CI.
   Nenhum commit pode dizer "o som ficou bom".
5. **Alvo é telefone**, tela pequena, luz variável, toque. Alvo de toque mínimo
   de 44 px é regra do projeto.
6. **Tudo em pt-BR**, e a interface não usa emoji (há um conjunto de ícones SVG
   próprios).

## 4. As frentes. Para cada uma: o estado medido, o conserto que eu proponho, e a pergunta

### Frente A — Duas fontes de texto escrevem no mesmo rótulo, e a segunda apaga a primeira

**Medido.** Existe uma "faixa de mensagem" (um único `Label`) que recebe duas
coisas: mensagens do modelo de jogo ("Píer 2 — pronto. +1 doca e +1
trabalhador") e falas de personagem ("Zezão terminou. Demorou o dobro do
previsto"). Quando o mesmo evento produz as duas, elas chegam no **mesmo
frame** e a segunda sobrescreve a primeira. Provei instanciando a cena e lendo
o texto do rótulo depois da compra: a fala da personagem nunca aparece. Há um
comentário no código a afirmar o contrário desde que aquilo foi escrito.

**O que torna isto interessante:** o mesmo projeto **já resolveu este problema
exato para o ÁUDIO**. O reprodutor de som é um singleton que recebe *pedidos*
durante o frame, cada som tem uma **prioridade** e uma **espera mínima**
própria, e no fim do frame só o de maior prioridade toca. Avançar o dia emite
quatro sinais e sai um som. A faixa de texto não tem nada disso.

**O que eu proponho:** trocar a ordem dos sinais, ou fazer a fala escrever
depois da mensagem de sistema.

**Pergunte-se se isso é o certo, e pesquise:**
- Qual é o padrão consolidado para **fila de mensagens efêmeras** em jogos
  (toast/notification queue): prioridade, coalescência, tempo mínimo de
  leitura, descarte versus enfileiramento?
- **Quanto tempo uma linha precisa de ficar na tela para ser lida?** Quero
  números defensáveis (velocidade de leitura em palavras por minuto para
  leitura incidental, não para leitura focada; efeito de tela pequena;
  acessibilidade — WCAG 2.2 SC 2.2.1 sobre conteúdo temporizado).
- Quando um **log rolável** ("histórico do dia") bate uma faixa única, e como
  jogos de gestão/tycoon mobile resolvem isto na prática. Exemplos concretos.
- A simetria com o áudio é uma boa ideia ou uma armadilha? Prioridade em texto
  tem um modo de falhar que prioridade em som não tem — **o texto que é
  descartado nunca mais é lido**, enquanto o som perdido é só um som perdido.

### Frente B — Falas condicionais que afirmam um estado falso

**Medido.** Duas falas mentem sobre o mundo:
- *"Semana nova. Barcos na fila, caixa no limite."* — dispara em toda semana
  nova, sem olhar o caixa. Numa captura determinística ela sai com o
  equivalente a quase o dobro da dívida no banco.
- *"Zezão terminou. Demorou o dobro do previsto, mas ficou bom."* — a
  construção neste jogo é **instantânea**: o botão compra e a estrutura existe
  no mesmo turno. Nada demorou coisa nenhuma.

Uma terceira, do mesmo feitio, já foi corrigida antes: o boletim financeiro
abria a dizer *"A semana anterior foi melhor"* na **primeira** semana, quando
não havia semana anterior.

**O que eu proponho:** pôr uma condição em cada fala (caixa abaixo de X), e
reescrever a frase da obra.

**Pesquise:**
- **Sistemas de diálogo reativo por regras** — o padrão de base de dados de
  regras com predicados sobre o estado do mundo, do tipo apresentado por Elan
  Ruskin (*AI-driven Dynamic Dialog through Fuzzy Pattern Matching*, GDC 2012,
  usado em Left 4 Dead e Dota 2) e o que veio depois. Vale a pena para **oito
  falas**, ou é canhão para mosca? Onde é que a complexidade passa a pagar?
- Como se **testa automaticamente** que uma fala só sai num estado em que ela é
  verdadeira? Há prática estabelecida (propriedades sobre o estado, testes
  baseados em propriedades, fuzzing do estado de jogo)?
- **Barks e repetição:** a literatura de design sobre quantas vezes uma linha
  pode repetir antes de irritar, e sobre variação por conjunto de linhas.
- O caso específico da frase que é **gramaticalmente perfeita e factualmente
  falsa no mundo do jogo** — há técnica para isso além de alguém ler em voz
  alta? (Eu tenho um gate humano de leitura em voz alta; quero saber se há
  mais.)

### Frente C — Contraste de texto abaixo do mínimo, pela quarta vez, e agora vindo do tema

**Medido**, amostrando as capturas do próprio jogo (régua calibrada contra dois
números que o projeto já publicava, batendo em ambos):

| Onde | Razão de contraste | Tamanho |
|---|---:|---:|
| Rótulo de seção ("RECEITAS", "Caixa: R$…") sobre cartão branco | **2,93:1** | 13–14 px |
| Convite tocável em âmbar sobre cartão branco | **3,19:1** | 13 px |
| Texto de botão desabilitado sobre botão claro | **2,16:1** | 15 px |
| Rodapé sobre fundo escuro (para referência, passa) | 5,04:1 | 13 px |

A cor de 2,93:1 é a **cor de texto neutro do tema**, feita para fundo escuro, e
está a ser usada numa variação de rótulo que cai em cartões brancos. O projeto
já registou três encontros anteriores com essa mesma cor sobre branco. Existe
uma guarda automática de contraste, mas ela percorre **um** painel de doze.

**O que eu proponho:** trocar a cor da variação (há uma já medida a 5,46:1) e
pôr a guarda a percorrer todos os painéis.

**Pesquise:**
- **WCAG 2.x aplica-se a jogos?** Qual é a posição atual (WCAG 2.2, EN 301 549,
  European Accessibility Act 2025, CVAA) sobre interface de jogo, e o que as
  *Game Accessibility Guidelines* dizem de específico sobre contraste.
- **Texto desabilitado é isento pela WCAG** — mas 2,16:1 num botão que o
  jogador precisa de ler para saber *por que* está desabilitado ainda é boa
  ideia? O que a prática recomenda.
- **APCA / WCAG 3**: em que pé está, e faz sentido um projeto novo medir por
  APCA em vez de razão de contraste? Qual é o risco de adotar um rascunho.
- **Hierarquia visual sem sacrificar contraste**: como fazer um rótulo
  "secundário" que recue sem cair abaixo do mínimo (peso, tamanho,
  espaçamento, maiúsculas, cor).
- Telefone **sob luz solar**: há números úteis sobre o contraste efetivo com
  reflexo, e recomendações de mínimo prático acima do mínimo legal?
- Ferramentas para **automatizar auditoria de contraste dentro de um engine de
  jogo** (não no DOM): alguém já fez isto em Godot/Unity/Unreal, e como?

### Frente D — Um tema como fonte única de estilo, e 22 lugares que o desobedecem

**Medido.** A regra do projeto é "o tema é o ponto único de estilo; script não
pinta cor na mão". Há **22** chamadas de sobreposição de cor espalhadas por
cinco scripts, e dez constantes de cor declaradas fora do tema. Foi por aí que
o âmbar de 3,19:1 escapou: a guarda lê o tema, e aquela cor não está no tema.

**Pesquise:**
- **Godot 4**: qual é o uso idiomático de `Theme`, *theme type variations* e
  `theme_override_*`; quando a sobreposição em script é legítima (estado
  dinâmico?) e quando é dívida.
- Como **fazer cumprir** isto automaticamente: um lint que reprove sobreposição
  de cor fora de uma lista autorizada, feito por varredura estática do
  `.gd`/`.tscn` ou por percurso da árvore de nós em tempo de execução.
  Compensa? Alguém publicou algo assim?
- O paralelo com **design tokens** em web/mobile: o que a prática de lint de
  design system ensina a um projeto de jogo pequeno (e o que não se aplica).

### Frente E — A leitura automática dos números cita o perfil errado desde que a lista cresceu

**Medido.** O simulador de balanceamento imprime, no fim, uma "Leitura" em
prosa: *"Jogar mal ganha 80% — o ERRO NÃO CUSTA"* e *"vão de 20 pontos entre
jogar bem e jogar mal"*. Os números certos, na tabela dez linhas acima, são
**37,3%** e **63 pontos**. A causa é uma linha que pega o "pior jogador" como
**o último item da lista de perfis** — e há três meses entrou um quarto perfil
no fim da lista, que não é o pior. O CI publica essa leitura na página da
corrida toda semana.

**Pesquise:**
- Padrões para **camada de interpretação sobre métricas** que não dependa de
  posição: seleção por identidade, esquemas versionados, contratos de dados.
- Como se **testa uma saída em prosa gerada a partir de números** — "golden
  narrative"/*approval testing*, asserções sobre afirmações, geração de
  linguagem natural a partir de dados com verificação. O que funciona sem virar
  um segundo sistema para manter?
- Mais amplo e mais útil: **como um relatório automático evita afirmar o que os
  dados não dizem?** Há trabalho publicado (jornalismo de dados automatizado,
  relatórios clínicos, BI) sobre asserções que se auto-verificam.

### Frente F — Documentação e instruções de agente que envelhecem em silêncio

**Medido.** Dez afirmações erradas espalhadas por três "skills" (as instruções
que o assistente de IA lê antes de trabalhar), pelo hook de arranque e por
quatro documentos: mandam rodar **cinco** suítes quando são seis, **dois**
mapas quando são quatro, dizem que o CI roda 30 partidas quando roda 600, e
listam uma etapa de arte como pendente quando ela foi feita, medida e
rejeitada há duas semanas. Cada uma foi verdade no dia em que foi escrita.

Há um conferidor automático de documentação, mas ele confere **existência e
referências**, não afirmações.

**Pesquise:**
- **Documentação executável / verificável**: doctest, *literate programming*,
  *docs-as-tests*, `mdbook test`, testes de exemplos em README, geração de
  documentação a partir do código. O que dá para aplicar a prosa que faz
  **afirmações contáveis** ("são cinco suítes")?
- Como quem mantém **instruções para agentes de IA versionadas** — o arquivo
  de regras na raiz do repositório (o `CLAUDE.md` daqui, o equivalente
  "AGENTS" de outras ferramentas), `.cursorrules`, skills, prompts de sistema
  versionados — mantém isso sincronizado com o código. Há prática emergente?
  Testes de prompt? Revisão obrigatória quando certos arquivos mudam?
- O caso específico: **como tornar uma contagem em prosa verificável** sem a
  tornar ilegível. Derivar o número de uma fonte única e injetá-lo? Escrever
  "todas" e nunca um número? Uma guarda que conte e reprove?
- Existe medição publicada sobre **quanto custa instrução desatualizada a um
  agente de IA** — taxa de erro, retrabalho? (Se não existir, diga; não
  invente.)

### Frente G — Áudio: o que se prova sem ouvir, e o que só o ouvido julga

**Medido.** Catorze efeitos gerados por script Python (biblioteca padrão pura),
32 kHz, mono, WAV PCM. Medi duração, pico, RMS em dB, amostra inicial e final,
componente contínua e amostras saturadas. Nenhum estalo de borda (todos começam
e acabam em zero), nenhuma saturação, contínua desprezível. A hierarquia de
nível é: interface a −12 a −13 dB RMS, ambiente e fauna a −19 a −23 dB RMS.

**Pesquise:**
- **A medida certa.** RMS em dB é o que eu tenho; o padrão da indústria é
  **LUFS** (ITU-R BS.1770-4, EBU R128). Para efeitos **curtos** (90 ms a 3,6 s),
  LUFS integrado é significativo, ou o certo é *momentary*/*short-term*, ou
  outra coisa? Qual é a prática para bibliotecas de SFX?
- **Alvos.** Há números publicados para mixagem de jogo mobile — alvo de LUFS
  para música, para ambiente, para interface; *headroom* de pico verdadeiro;
  relação entre camadas? Quero saber se os meus **8 a 10 dB** entre interface e
  ambiente são hierarquia sã ou interface aos gritos.
- **Outras medidas objetivas que eu deveria estar a fazer e não faço**:
  *true peak* (sobreamostrado), descontinuidade no meio do sinal (não só nas
  bordas), conteúdo espectral (energia em bandas que o alto-falante de telefone
  não reproduz — abaixo de ~500 Hz um telefone entrega quase nada), faixa
  dinâmica, mascaramento entre dois sons que tocam juntos.
- **Ferramentas leves** que façam isto: `pyloudnorm`, `ffmpeg -af
  loudnorm/ebur128`, `librosa`. Quais valem o peso; qual é a mais barata de pôr
  num CI sem placa de som.
- **O outro lado, honestamente:** o que continua a exigir um ouvido humano, e
  qual é o protocolo mínimo para uma sessão de escuta útil (em que aparelho,
  quantas vezes, com que perguntas). O meu gate de áudio é uma pessoa a ouvir,
  e quero que essa sessão renda.

### Frente H — Pluralização e texto em pt-BR

**Medido.** A interface diz *"32 dia(s) restante(s)"*, *"2 tentativa(s)"*. É
muleta em três lugares, num jogo que já escreve números por extenso na
narração de propósito.

**Pesquise:** o suporte de **plural em Godot 4** (`tr_n`, arquivos de tradução,
regras de plural CLDR) e se compensa para um jogo **monolíngue** em pt-BR; as
alternativas (uma função de pluralização própria; reescrever a frase para não
precisar de plural, que é a saída que a escrita costuma preferir); e boas
práticas de **número em prosa** numa interface de jogo (quando dígito, quando
por extenso).

### Frente I — Captura determinística e o estado que o jogador nunca vê

**Medido.** Há 16 capturas determinísticas (semente fixa, passo de tempo fixo)
que o CI anexa a cada pull request, com tabela de "mudou / igual / novo" por
comparação byte a byte contra a base. Funciona. Dois problemas:
1. A ferramenta que avança N turnos antes da foto **gasta uma iteração** quando
   o jogo pede uma decisão, e **avança turnos por baixo de um painel modal
   aberto** — a foto do boletim semanal mostra um estado que o jogador não
   alcança jogando.
2. Os registos de execução das 16 capturas são **apagados** no fim sem ninguém
   procurar erro neles. Hoje estão limpos; a guarda que o resto do CI tem não
   existe aqui.

**Pesquise:**
- **Teste por imagem de referência** em jogos: byte a byte versus comparação
  perceptual (SSIM, diferença perceptual), como se lida com instabilidade
  (GPU, driver de software, tempo), e onde a prática assenta.
- Como se detecta que **o cenário de teste montou um estado impossível**? Há
  nome para isto (validação de invariantes em fixtures? *state legality
  checks*?) e prática estabelecida?
- Boas práticas de **simulação de jogo em modo headless para produzir
  evidência**: dirigir a máquina de estados em vez de contar turnos.

### Frente J — A pergunta de cima

Depois de responder às nove, responda a esta:

**Dada esta lista, qual é a ordem que reduz mais risco por hora de trabalho?**
A minha ordem é: (1) a leitura errada dos números, porque o CI a publica toda
semana e alguém vai lê-la como medida; (2) a família das falas; (3) as
instruções desatualizadas do agente, porque são lidas *antes* do código; (4) o
contraste; (5) o resto.

**Discorde se tiver razão para isso**, e diga o critério que usou. Considere
especificamente: o que é mais provável que **cause um erro novo** (e não só
mantenha um antigo), e o que é mais barato **agora** do que depois de a Fase 2
existir.

## 5. O que eu quero de volta

Para **cada frente**, nesta ordem:

1. **O que a indústria faz** — o padrão, com nome, e quem o usa. Três
   parágrafos, não trinta.
2. **Recomendação, com o trade-off dito.** Uma escolha, não um menu. Se houver
   uma segunda opção defensável, diga por que ficou em segundo.
3. **Onde o meu conserto proposto está errado, ou é subótimo, ou é bom.** Isto
   não é opcional — é a razão de eu estar a pedir pesquisa em vez de
   implementar.
4. **Como PROVAR que funcionou.** Este projeto exige que toda guarda nova venha
   com o **defeito injetado** que a faria reprovar. Para cada recomendação que
   envolva um teste ou uma métrica, diga: o que se mede, contra que valor, e
   **que defeito eu introduzo de propósito para ver a guarda reprovar**. Se a
   sua proposta não tiver como ser provada, diga isso em voz alta.
5. **Custo e risco**, em ordem de grandeza (uma hora? um dia? toca em quantos
   arquivos? pode quebrar o quê?).
6. **Fontes**, com link, e uma linha dizendo o que cada uma sustenta.

No fim, **uma página só**: a ordem recomendada, o critério dela, e as três
coisas que você mudaria no meu plano.

## 6. O que faz uma resposta ruim, para você poder evitá-la

- **Concordar comigo.** Se os onze consertos que propus estiverem todos certos,
  a pesquisa não valeu o tempo. Procure ativamente os que estão errados.
- **Recomendação sem prova.** "Use uma fila de mensagens" sem dizer como eu
  sei que ela funcionou é uma opinião.
- **Padrão de web aplicado a jogo sem dizer o que muda.** Muita coisa de
  acessibilidade e design system vem do DOM e não atravessa para uma árvore de
  nós de engine. Diga onde não atravessa.
- **Número sem fonte.** Especialmente em áudio e em velocidade de leitura, onde
  números redondos circulam sem origem.
- **Escala errada.** Isto é um jogo pequeno, feito por uma pessoa, com oito
  falas de personagem e catorze efeitos sonoros. Uma arquitetura para um estúdio
  de trinta pessoas é a resposta errada, mesmo quando é a resposta certa para
  outra gente. Quando recomendar algo grande, diga qual é a versão pequena.

✂️ ─────────────── FIM DO PROMPT ───────────────
