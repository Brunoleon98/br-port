# BR Port — como o projeto chegou aqui

> O caminho, bloco a bloco, e os defeitos que cada playtest achou. Saiu do
> `ESTADO_DO_PROJETO.md` em 02/09, que carregava isto junto com o estado atual
> e por isso se contradizia: a mesma página afirmava uma parcela de R$8.000 e
> uma de R$550.000, e três leituras diferentes do balanceamento.
>
> **Nada aqui descreve o jogo de hoje** — para isso,
> `docs/ESTADO_DO_PROJETO.md`. O texto está como foi escrito, na data em que
> foi escrito, e é essa a utilidade dele.

---

## O caminho, do mais recente para o mais antigo

**O CI PASSOU A MOSTRAR O QUE FICOU** (02/09) — item B3, fechado. Até aqui o CI
provava que nada tinha quebrado e não mostrava nada: para ver o porto era
preciso abrir uma sessão e rodar a captura na mão. Agora cada PR leva o
artefato `brport-captura` com cinco imagens — tela inicial, porto reconstruído,
Boletim Financeiro, menu de pausa e a folha de contato dos ícones — e, quando é
pull request, o job fotografa **também o commit-base** e escreve na página da
corrida qual das cinco mudou. É a metade de máquina do gate do A5, que é
literalmente *olhar cada antes/depois*.

⚠️ **Para o antes/depois valer, a foto teve de virar função só do código — e
isso exigiu DUAS coisas, não uma.** A semente fixa o mundo sorteado (e vem
antes do `new_game()`, que já sorteia a mão inicial — a mesma armadilha que o
simulador documenta). Não chegou: medido, duas corridas do mesmo código com a
mesma semente ainda davam **1.030 pixels diferentes**, porque os tweens em laço
— o balanço do barco, a lança do guindaste, o pulso do cartão — andam por
*delta* e não por frame. Com `--fixed-fps 60`, dois clones independentes do
repositório produzem PNGs **byte a byte idênticos**.

⚠️ **E a foto do porto saía com o Boletim Financeiro tapando o mapa inteiro.**
Com a semente fixa, doze turnos calham num fim de semana e o painel abre; a
imagem chamava-se "porto" e mostrava uma tabela, sem um `push_error` sequer a
denunciá-la. O `capturar_tela.gd` passou a imprimir quantos painéis estão por
cima, e `tools/capturar_evidencia.sh` exige zero nos tiros do mapa e um no do
menu de pausa. O boletim virou o quinto tiro, de propósito. A outra guarda é
para a tela chapada, que também é um PNG válido: medido, uma imagem de cor
única pesa 2,7–4,5 KB contra os 87–517 KB das de verdade, e o corte ficou em
20 KB. Os dois defeitos foram injetados e os dois reprovaram.

**O simulador longo também saiu do caminho de cada PR** —
`.github/workflows/balanceamento.yml` roda as 600 partidas por perfil às
segundas e sob demanda. **A razão de não ser a cada PR não é o custo:** medido,
as 600 levam 26 segundos. É o ruído — um número com ±4 pontos de margem
anexado a todo PR convida a ler sorteio como regressão, que é o erro que a
ferramenta existe para evitar. Ele reprova só o que não depende de julgamento
(o simulador chegar ao fim, nenhuma partida travar, o modelo das Parcelas
reconstruir a semana medida) e publica as taxas sem as julgar: cravar o alvo no
workflow dar-lhe-ia um terceiro endereço para envelhecer.

**O JOGO RODOU NUM TELEFONE DE VERDADE, e a primeira vez achou três defeitos**
(02/09). O Bruno instalou o APK e mandou duas fotos. Dez minutos num aparelho
acharam mais do que quatro blocos de CI — que é exatamente o argumento com que
o A1 foi posto em segundo lugar na fila, e agora é fato medido e não previsão.

⚠️ **O JOGO ABRIU DEITADO.** `window/handheld/orientation="portrait"` é valor do
**Godot 3**. Na 4 a chave é um enum `DisplayServer.ScreenOrientation` e o
exportador do Android faz `int()` dela — e `int("portrait")` é **0**, que é
LANDSCAPE. O manifesto do APK saiu em paisagem enquanto o projeto se dizia
retrato havia cinco blocos.

**Nada podia pegar isso.** O valor é aceite sem reclamar, lê certo para uma
pessoa, e no PC o jogo abre correto porque lá a janela nasce do tamanho da
viewport e a orientação nem se aplica. Hoje é `1`, e o bloco F5 do
`teste_fumaca.gd` confere o TIPO além do valor — o tipo, porque era o tipo que
estava errado.

⚠️ **O BOTÃO VOLTAR FECHAVA O JOGO.** Padrão do Godot
(`quit_on_go_back=true`). Com o boletim da semana aberto, um toque em Voltar
matava a aplicação. Quem decide agora é o `_notification` do `Main.gd`, e **a
regra é a fase do `GameState`**, não uma lista de painéis: fora de `"playing"`
o jogo espera uma resposta, e fechar esse painel deixaria a fase de pé sem nada
na tela para a resolver. A exceção é declarada pelo próprio painel
(`PainelNarrativo.fecha_com_voltar`), e a `TelaNomes` desliga-a: fechá-la
BATIZA o cais, e a escolha é irrevogável (GDD 7).

⚠️ **O APK tinha o ROBÔ DO GODOT por ícone.** O exportador resolve "escolha no
preset → ícone do projeto → padrão do motor" e o projeto não tinha nenhum dos
dois. `tools/gerar_icone_app.gd` gera os três arquivos que o Android quer a
partir do `art/icones/doca.svg` — a mesma âncora que a barra de HUD já desenha.
Gerado e não desenhado, para a marca não divergir da do jogo.

**As barras pretas ficam, e isso foi medido.** 720x1280 é 9:16 e o telefone de
hoje é 9:20, então o `keep` deixa ~um quinto de um 1080x2400 em barra. As duas
alternativas foram renderizadas e olhadas: `keep_width` enche a tela mas larga
um TERÇO dela vazia embaixo (cada nó do `Main.tscn` está posicionado em
absoluto a partir do topo, e o mapa é uma textura 720x720 que não estica);
`keep_height` corta pelos lados. **Encher tela alta a sério é trabalho de ARTE**
— um mapa mais alto —, não de configuração. O que era de graça foi feito: a
barra deixou de ser preta e passou a ser a navy do jogo.

⏳ **O gate continua de pé: jogar dez minutos no APK novo.** As três correções
estão na main e num APK verde; o que elas mostram no aparelho, só o aparelho diz.

**O jogo finalmente SAI daqui** (02/09) — item A1, metade de máquina fechada;
a outra metade é do Bruno. Quatro blocos e sessenta commits com o projeto
descrito como "mobile", e ele nunca tinha saído de um contêiner: tudo o que se
sabia sobre o comportamento dele num telefone era dedução.

`brport_vs/export_presets.cfg` passou a ser versionado — escrito à mão para
**não guardar chave nenhuma**: os campos de keystore ficam vazios de propósito,
e o Godot lê as variáveis de ambiente quando os encontra em branco. Um segundo
job do CI exporta Web e Android a cada push e anexa os dois à corrida
(`brport-apk`, `brport-web`). A receita, pelos dois caminhos, está em
`brport_vs/COMO_RODAR.md`.

**Existe APK.** Medido na corrida verde: **29 MB**, `arm64-v8a`, assinado com
uma chave de debug gerada na hora — descartável de propósito, porque o alvo é
o telefone do Bruno e não uma loja. O Web sai ao lado, com `.pck` de 2.045.588
bytes e `.wasm` de 37,7 MB. As duas passaram a excluir do pacote as cinco
suítes, o simulador e as capturas: o primeiro export levava tudo isso dentro.

⚠️ **O export Android falha com a lista de erros VAZIA**, e foi preciso ler o
código do motor para saber porquê: de uns vinte testes de configuração, só o do
ETC2/ASTC reprova sem escrever mensagem. Pior, ele depende do SISTEMA em que se
exporta — passa num Mac e reprova em Linux, que é onde o CI corre. O
`project.godot` ganhou `import_etc2_astc=true` com a explicação ao lado, e o
bloco F5 do `teste_fumaca.gd` tranca isso e mais o preset (sem chaves, com os
dois presets, com as pastas de ferramenta fora do pacote) — na suíte rápida,
para a resposta chegar em segundos e não depois de um export de 25 minutos.

⚠️ **O APK não se consegue construir nesta máquina.** O `dl.google.com` responde
403 por política da organização, então o SDK do Android é inalcançável e o CI é
o único lugar onde esse export se verifica. O Web esse corre aqui.

⏳ **O gate é do Bruno: instalar o APK num telefone de verdade e jogar.** A
entrega deste item não é o arquivo — é uma partida jogada.

**A reputação passou a fazer alguma coisa** (01/09) — item A3, fechado, e era
ele que travava os itens 5 a 15 da fila. Reputação alta faz o cliente do Arlindo
aceitar pagar cheio com mais frequência; reputação baixa faz o contrário. Só nas
apostas ("cortar metade", "manter o preço") — igualar continua a fechar sempre,
porque é o recuo de emergência do jogador.

O caminho foi escolha do Bruno, entre três. O registro, com todos os números,
está em `docs/decisoes/003-a-reputacao-passa-pela-negociacao.md`.

⚠️ **A barra estava SATURADA, e medir antes de codar foi o que salvou o item.**
Com +4 de reputação por barco e um porto que atende ~13 barcos por semana, ela
batia no teto de 100 na primeira semana: 79,8% das contra-ofertas do jogador
Ótimo e 53,8% das do Mediano aconteciam já no teto. Os dois perfis cuja
separação é o que interessa chegavam à decisão com a mesma barra. Os ganhos
foram divididos por cinco, e as medianas na oferta passaram a 86,0 / 74,1 /
59,5. **Uma barra saturada não é um sistema — é um bónus fixo com mais código.**

Medido, com o efeito desligado e ligado: a aposta ganha sobe de 71,3% para
87,3% no jogador Ótimo, de 43,0% para 49,5% no Mediano, e CAI de 44,4% para
39,0% no Descuidado. O balanceamento aguentou: 100% / 47,8% / 0% contra os
100% / 47,3% / 0% da base, mesma medida dentro da margem de ±4,0.

**A sessão já abre com o Godot pronto** (01/09) — item B1 da fila, fechado,
**a partir do momento em que estiver na main**: sessão nova arranca do branch
padrão, e um hook que viva só numa branch de trabalho não corre.
`.claude/hooks/session-start.sh` baixa o binário, roda o `--import` e diz numa
linha o que ficou disponível; a primeira mensagem de uma conversa nova já pode
rodar a suíte. Doze segundos a frio, seis a quente. O `bpy` (~1 GB) ficou de
fora de propósito: só faz falta em sessão de arte.

Construir isso destapou uma divergência que já existia: **o `CLAUDE.md` mandava
baixar a 4.6.1 e o CI rodava a 4.6.3.** A sessão testava numa versão e o PR era
barrado noutra. A versão passou a viver em `.godot-version`, lido pelos dois.

**O jogo ganhou história** (01/09) — item A4, construído; falta o gate humano.
Até aqui o loop estava inteiro e **a Dona Cida não aparecia uma única vez no
código**; o Sr. Ribeiro era uma linha de texto num painel. Agora são sete telas,
não as seis do plano — a entrada dos dois nomes ganhou tela própria por decisão
do Bruno, e é a primeira coisa que o jogador vê.

O texto todo vive em `scripts/Narrativa.gd`, como o ícone vive no `Icones.gd`.
O nome do cais e o do jogador saem por `GameState.texto()`, um ponto só, e o
teste de fumaça reprova qualquer `{token}` que chegue cru à tela.

⚠️ **Nenhuma tela é fase do `GameState`, e isso não é detalhe.** Uma fase nova
que bloqueasse o turno faria **24 de 30 partidas não terminarem** no simulador —
e o CI passaria na mesma, porque só procurava a linha `=== Leitura ===`. Medido,
consertado (o CI agora reprova `possível travamento`) e escrito no `CLAUDE.md`.
Como overlay, o balanceamento medido fica intocado por construção — e medido:
600 partidas por perfil deram **100% / 47,8% / 0%**, com a mediana do mediano em
R$7.960 contra a parcela de R$8.000. Nenhuma das 1.800 partidas travou.
*(Números de 01/09, antes da reescala. Serviram para provar que o A4 não mexeu
na economia; os do jogo de hoje estão lá em cima, em "O jogo hoje".)*

⏳ **O gate é do Bruno: ler o texto em voz alta.** Três desvios do rascunho de
escrita esperam por esse julgamento, e estão listados no A4 do plano.

**A cena que abre passou a ter teste** (01/09) — item B4, fechado.
`brport_vs/tests/teste_fumaca.gd` é o quinto passo do CI e espera `FUMACA OK`.
Cobre as três coisas que até aqui só o olho cobria: **toda** `.tscn` do projeto
instancia (as doze são achadas por varredura, não por lista — uma lista
envelhece calada e deixaria de fora justamente a cena nova), todo ícone
registrado em `Icones.gd` tem arquivo no disco, e o save de outra versão é
descartado. Os quatro defeitos foram injetados e os quatro reprovaram.

⚠️ **E o teste achou um bug de verdade, na migração de save.** Um save da
versão CORRENTE mas com o roster vazio era recusado *depois* de o `load_game()`
já ter escrito `turn`, `cash` e o resto por cima do estado vivo — e o arquivo
impossível ficava no disco para ser tentado outra vez no arranque seguinte. O
jogo sobrevivia por acidente: o `new_game()` que vem a seguir por acaso
reescreve todos os campos. Bastava um campo novo que ele não zerasse para o
estado impossível atravessar para a partida seguinte, que é **o bug das 4 docas
com outra roupa**. Agora tudo o que recusa vem antes de tudo o que escreve.

**Os números do jogo têm fonte única** (01/09) — item A2, fechado.
`docs/design/BR_Port_Numeros_Fase_1.md` é GERADO do `GameState.gd` e o CI
reprova quem mexe numa constante sem regerar. São dois programas de propósito:
o Godot despeja o que ele avalia de verdade, o Python lê o texto (é de lá que
saem os comentários que dizem se o número veio do GDD ou é TUNING), e as duas
leituras são cruzadas nome a nome — uma constante que o parser não entenda
REPROVA, em vez de sumir da tabela em silêncio.

**As Parcelas 2 e 3 deixaram de ser desconhecidas** (01/09) — e a resposta é o
contrário do que o GDD temia. Elas fecham: 2,2× e 4,5× de folga no cenário
conservador, para o jogador que joga bem; 2,0× e 4,0× para o mediano. O card
"Risco crítico da Parcela 3", que mandava escolher entre pôr o armazém a render
desde a semana 2 ou baixar a Parcela 3 para R$18.000, **perdeu o motivo** — ele
nascia do mesmo cenário de 2 barcos/semana que a errata já tinha derrubado.

⚠️ **Fica uma pergunta de design em aberto, e ela é a que importa.** O valor de
contrato cresce ×2,9 e depois ×2,5 por fase; a parcela cresce ×2,0 e ×1,5. A
receita corre mais depressa do que a dívida, então **a tensão que faz a Fase 1
medir 47% desaparece a partir da semana 5.** Subir as parcelas, assumir que é
de propósito, ou trocar o que pressiona — não está decidido, e codar a economia
da Fase 2 sem resolver isto é construir em cima de uma pergunta. O registro,
com os números e o modo de refazer a conta, está em
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.

Isto é **projeção, não medição** — a Fase 1 é medida no jogo que existe, as
outras duas são a mesma conta com os números que o GDD dá para elas. Vira
medição quando as Fases 2 e 3 estiverem implementadas, e a errata continua a
dizer que isso não se faz antes de o VS sair.

**O mapa foi refeito a partir do que a captura mostrou** (31/08). O que estava
errado, e agora não está: 40% do quadro era uma laje de asfalto atrás da vila
(virou solo tropical com orla de mata, moita e capim); o escritório e o armazém
pousavam em cima de casas (a vila abre vão no `my` que a PROJEÇÃO diz, não no
`my` do prédio); a rua tinha o mesmo cinza do pátio e nenhuma borda (asfalto
mais escuro e meio-fio); a água eram três faixas chapadas com aresta dura e
oito ondas repetidas igual em todo degrau (gradiente radial de profundidade,
ondas variadas, espuma na linha de costa); e a baliza da Zona de Espera
projetava sombra de contato NA ÁGUA.

**O pipeline Blender -> Godot do pacote está implementado** (31/08):
`blender/` com quatro estúdios que partilham a câmera de `gerar_props_iso.py`,
15 assets novos, manifest, dois validadores (um de cada lado), a cena
`scenes/tests/AssetPlacementTest.tscn` e um passo novo no CI. O que foi e o que
NÃO foi feito está em `docs/arquivo/BRP_IMPLEMENTATION_NOTES.md`; os resultados
medidos, em `docs/arquivo/BRP_VALIDATION_REPORT.md`.

**Chegou um pacote de arte externo em 31/08, e ele NÃO reabre o design.** Seis
partes, 27 PNGs e 12 guias, com telas de gameplay dos cinco níveis e um prompt
de pipeline Blender → Godot. As telas descrevem outro jogo — tempo real com
controle de velocidade, formato paisagem, Pesquisa e Loja —, e ficou decidido
que **o GDD 7 continua valendo**: o pacote entra como referência de arte e nada
mais. O registro, com as medições que sustentam a decisão, está em
`docs/decisoes/001-pacote-de-arte-externo-e-o-gdd-7.md`. O conferidor de lote
que saiu daí é `tools/conferir_lote_de_arte.py` — **rodar em toda arte que
chegar de fora**: o lote de 31/08 tinha metade das peças em outra projeção
(34,6° contra os 26,57° do mapa) e nenhuma a olho denunciava isso.

**O planejamento das Fases 4 a 7 foi REFEITO em 30/08** —
`docs/design/BR_Port_Plano_v3_Claude_Code.md`. O cronograma antigo (44 semanas,
~490h com buffer, 10–14 meses) foi calibrado para *"dev solo iniciante em Godot,
8h/semana"*: os Blocos 2 a 4, orçados ali em 28 semanas, saíram em sete dias.
O plano novo troca a semana pela **sessão** como unidade, ordena o trabalho em
duas trilhas — o JOGO e o PROJETO/CLAUDE — e orça a parte que continua cara:
os seis momentos em que só uma pessoa resolve (jogar, ouvir, olhar, decidir).

**Fase 4 — Produção do Vertical Slice**. O **Bloco 2 (loop core)** está entregue
e o **Bloco 3 (marco intermediário) está FECHADO** — playtest humano feito,
decisão registrada, ajustes aplicados.

As Fases 1–3 já foram concluídas antes: o protótipo HTML de diagnóstico foi
jogado e aprovado (Playtest V3 ✅ GO) e o **GDD 7 está congelado** como fonte da
verdade (`docs/design/BR_Port_GDD_V7.jsx`).

**Decisão do Bloco 3 (26/08):** *ajustar antes de ir para a arte* — e os
ajustes já foram feitos, dentro de 1 semana. O registro completo, com as 5
partidas do playtest e o raciocínio, está em
`docs/arquivo/BLOCO3_MARCO_INTERMEDIARIO.md`, Parte 3.

**Bloco 4 — arte final, áudio e integração — está EM ANDAMENTO.** Os dois
primeiros itens da ordem de trabalho (`docs/arquivo/BLOCO4_BRIEFING_VISUAL.md`) saíram
em 27/08:

1. ✅ **Style guide de flat design** —
   `docs/design/BR_Port_Style_Guide_Flat_Design.md`. Paleta de UI (já
   validada) + paleta nova de mapa/cenário, peso de linha, espaçamento,
   proporções canônicas e convenção de cor por estado.
2. ✅ **Estrutura do mapa do porto com placeholder** — a antiga fileira
   "Docas" virou um mapa visto de cima (`Main.tscn`, seção "Porto"):
   Escritório (terreno) | Docas (dinâmico, 2–3 conforme upgrade) | Zona de
   Espera, sobre um fundo de água. Ainda formas simples — valida a leitura
   espacial antes de encomendar sprite.

3. ✅ **Pacote de sprites tratado** (28/08) — os PNGs vieram **sem canal alpha**
   (o quadriculado que parece transparência estava pintado nos pixels);
   `tools/preparar_sprites.py` conserta isso e é para ser reusado a cada leva
   nova. Análise do pacote em `docs/arquivo/BLOCO4_PACOTE_SPRITES.md`.
   ⚠️ Desses 5 PNGs, **só `trabalhador.png` continua carregado pelo jogo** — o
   resto ficou para a migração isométrica, porque em cima de um mapa topo-down
   eles eram erro de perspetiva.
4. ✅ **Mapa virou a tela do jogo** (28/08) — docas são 3 vagas fixas sobre os
   píeres, e "Ampliar píer" acende a terceira.
5. ✅ **Camada de ícones fechada** (29/08) — os 20 ícones da interface são SVG
   em `art/icones/`, registrados em `scripts/Icones.gd`. **Nenhuma tela do jogo
   usa emoji.** São vetor chapado, não isométrico: ícone de HUD é interface e
   precisa se ler a 19px, o que o estilo isométrico não entrega nesse tamanho —
   então esta camada NÃO muda quando o mapa migrar.

Faltam os itens 6–7 do plano: áudio e integração progressiva.

🔄 **Direção de arte: ISOMÉTRICA (decidida 28/08) — decisão fechada.** Ela
oscilou três vezes na sessão (3/4 ilustrado → chapado topo-down → isométrico);
o histórico e o porquê estão na §2 do briefing de continuação, para não voltar
atrás de novo.

**O jogo em produção JÁ É isométrico** (29/08) e continua com a suíte inteira
passando. `Main.tscn` roda sobre `porto_mapa_iso.svg` com os props de
`tools/gerar_props_iso.py` — píer nos dois estados, barcos, cenário. O que
destravou foi gerar por script em vez de por prompt: num plano isométrico
nenhum eixo é horizontal (ambos a 26,57°), e o ângulo deixou de ser uma coisa
que alguém acerta para ser uma conta que não pode sair errada.

Continuam com gerador de imagem só os **retratos** (Arlindo, Sr. Ribeiro), onde
a perspectiva não importa porque vivem em painel.

👉 **Para retomar, o ponto de entrada é `docs/arquivo/BLOCO4_BRIEFING_CONTINUACAO.md`**
— estado atual, decisões fechadas e os caminhos que restam (o dos ícones foi
fechado em 29/08).
`docs/arquivo/BLOCO4_BRIEFING_VISUAL.md` continua válido como registro das decisões
sobre a imagem de referência original (turnos mantidos, R$ e não $, retrato).

---
---

## Balanceamento — como foi resolvido no Bloco 3

> ⚠️ **Os números desta seção foram SUPERADOS pela reescala de 02/09**
> (`docs/decisoes/005`), que trocou a parcela de R$8.000 por R$550.000 e o
> contrato de R$80–300 por R$8.000–70.000. O que continua a valer aqui é o
> raciocínio — a causa era a vazão e não o valor do barco — e o registro de que
> a dívida técnica dos "valores de barco acima do GDD" foi paga.


O jogo **estava no fio da navalha**, não fácil como o handoff dizia. O playtest
humano confirmou: 5 partidas, 1 vitória, e uma delas perdida por **R$ 1**
(R$ 7.999 contra R$ 8.000) — jogando bem, sem perder barco.

A causa não era o valor do barco: era a **vazão**. Com 3 turnos por semana, a
parcela só cabia inflando o barco para R$ 240–760, fora da faixa do GDD.

**Correção aplicada:** 8 turnos por semana, barcos de volta a **R$ 80–300**
(a faixa que o GDD define para a Fase 1).

| Perfil | Antes | Depois |
|---|---|---|
| Joga perfeito | 58,5% | **99,7%** |
| Joga mediano | 7,2% | **63,8%** |
| Joga mal | 0,1% | **0,7%** |
| Folga no vencimento | 2% | **20%** |

A dívida técnica registrada antes — "valores de barco acima do GDD" — **não
existe mais**.

### Achados de design que vieram junto

- **A contra-oferta do Arlindo virou uma decisão de verdade.** O botão "Manter
  preço" não tinha chance nenhuma de dar certo — apertar duas vezes sempre
  perdia o barco. Agora os 3 presets são os do GDD ("Igualar −15%" / "Cortar
  metade −7%" / "Manter preço"), os dois últimos são apostas reais, e igualar
  depois de insistir custa 28% em vez de 15%.
- **A economia do GDD não fechava.** Erro de aritmética no próprio GDD: o
  modelo da Fase 1 acumulava R$ 1.480 em 4 semanas contra uma parcela de
  R$ 8.000. Corrigido, com registro em
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. As Parcelas 2 e 3 ficaram
  não verificadas até 01/09, quando foram projetadas — ver o roadmap acima:
  **fecham com folga grande, e o problema virou o oposto.**
- **Ninguém quebra por caixa.** O píer sozinho paga os custos, então a derrota
  por caixa negativo continua sendo código morto: a única forma de perder é o
  portão da parcela. Fica anotado, não foi mexido.
- ~~A reputação ainda não afeta nada mecanicamente~~ — **resolvido em 01/09**
  (item A3). Ela decide a contra-oferta. Ver o roadmap acima e
  `docs/decisoes/003`.

Para medir qualquer mudança: constantes marcadas `# TUNING:` no topo de
`brport_vs/autoload/GameState.gd`, e o simulador mede o efeito em segundos.

---
---

## Histórico de correções relevantes

O playtest de 30/08 encontrou um bug de estado e três defeitos de imagem:

1. **A compra dos píeres duplicava.** O jogador via as opções "Reconstruir o
   Píer 2" e "Píer 3" mesmo já tendo os píeres, e comprá-los levava o porto a
   **4 docas num mapa que só desenha 3** — a quarta recebia barco e nunca
   aparecia na tela. A causa não estava na compra: estava no SAVE. Ele não
   tinha versão, e um jogo gravado quando o porto ainda abria com 2 docas
   continuava a ser carregado depois de `DOCKS_BASE` cair para 1. Hoje há
   `SAVE_VERSION`, `BERCOS_NO_MAPA` é regra do jogo (não constante de tela) e
   `_reconciliar_roster()` deriva docas e trabalhadores do que está
   construído.
2. **O trabalhador parecia pendurado no guindaste.** Era o último filho de
   `Dock.tscn` e por isso desenhado por cima do cabo e do moitão, que estão à
   frente dele no mundo. Ordem de nó é profundidade num plano isométrico.
3. **O enrocamento aparecia como cascalho pintado no cais.** As pedras eram
   espalhadas degrau por degrau e nas quinas da escada caíam dentro do degrau
   seguinte, que é mais largo. Hoje a costa é um contorno explícito, com os
   espelhos dos degraus, e tudo o que a acompanha anda por ele.
4. **Os nomes flutuavam sobre o mapa** e as chips das docas tapavam a arte.
   Ver a seção anterior.
5. **O enrocamento cruzava a raiz de cada píer** e as pedras liam-se como se
   estivessem por cima do tabuado. Elas param onde o píer começa: ninguém
   joga pedra na frente da entrada de um píer.
6. **Faixas claras atravessavam o pátio até dar na água.** Não eram estrada —
   eram a margem de meia unidade que sobrava entre um degrau e o seguinte. O
   pátio passou a ocupar o degrau inteiro, e no lugar delas entrou uma malha
   viária desenhada de propósito.
7. **Os coqueiros nasciam no meio do asfalto e por cima do armazém.** Foram
   para o passeio e o cenário passou a ser desenhado por profundidade.
8. **A ferramenta de captura fotografava o porto errado sem avisar** — 30% das
   vezes `new_game()` abre oferta do rival, e com o jogo nesse estado toda
   compra é recusada, então a foto do porto "completo" saía do porto em
   ruínas. Resolve a oferta antes de comprar e grita se alguma falhar.

O primeiro playtest humano (25/08) encontrou dois bugs sérios, ambos corrigidos:

1. **Jogo travava** depois de aceitar a oferta do rival — o botão "Avançar dia"
   ficava desabilitado para sempre. Era ordem de emissão de sinais; hoje toda
   troca de fase passa por um ponto único que avisa a interface.
2. **O mesmo trabalhador podia ser alocado em várias docas** ao mesmo tempo,
   multiplicando receita de graça. Hoje é bloqueado, e tocar na doca libera o
   trabalhador (para desfazer arrasto errado).

Lição registrada: a verificação automatizada agora **instancia a cena real** e
checa o estado dos botões. A versão anterior só chamava a lógica direto, e por
isso não pegou nenhum dos dois.

Segunda lição, do dia 25/08: **um harness que joga perfeito não mede
dificuldade.** A taxa de vitória de ~63% que constava aqui vinha da suíte de
testes jogando sem errar uma vez sequer — o que descrevia o teto do jogo, não a
experiência de quem pega no controle pela primeira vez. Medir dificuldade exige
simular também o jogador que erra, e com amostra grande o bastante para a
margem de erro não engolir a conclusão. Daí o
`tools/simular_balanceamento.gd`.

---