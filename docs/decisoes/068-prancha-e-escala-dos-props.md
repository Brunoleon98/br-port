# 068 — A frente 6: a prancha de um prop e a página de escala

**27/09/2026 · frente 6 do A5**, escolhida pelo Bruno depois de a frente 3
fechar. A nota dele nas três folhas de contato (23/09, «Não» nas três) pedia
duas coisas: *«pode melhorar e deixar mais útil para a IA alterar e fazer os
testes que precisa para que os props saiam melhores»* e *«pode buscar
referências profissionais de como fazer essas folhas de contato»*. A nota
dos camiões acrescentava a terceira: *«tome cuidado com a proporção em
relação ao mapa e seus itens, pois no futuro carros e pessoas devem ser
adicionadas»*. **Veredito: por dar.**

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A frente depois da 3 (entre a 4, a 5, a 6 e o galpão V3) | **6 — a folha de props** |
| O que a frente entrega | **A prancha por prop (A/B)** e **a página de escala** |
| O catálogo com zoom dentro de cada célula | **Não marcado** — as três páginas ficam como estão |

## As referências, e o que se tirou delas

Lidas pela BUSCA, porque o proxy bloqueia as páginas (`063`): são pistas de
padrão, e nenhuma página foi lida. As que se repetem em fontes diferentes:

- **Compare sempre contra uma referência conhecida** — a escala errada muda
  a leitura da proporção, do detalhe e da distância. Numa prancha de prop, a
  figura humana ao lado é a régua.
- **Silhueta chapada e valor em cinzento, sobre o fundo REAL.** A forma lê
  antes da cor, e o valor tem de separar o objeto do fundo antes de o matiz
  ajudar; o teste é o prop numa cor só, e depois em cinzento.
- **Teste no fundo e na escala do jogo antes de gerar variações**, e reduza
  até ao tamanho de uso: o que sobrevive é silhueta, contraste e um foco.
- **A comparação é estável e justa**: cada candidata com o identificador, a
  composição inteira à vista e a mesma transformação que a base — nunca
  normalizada à parte para parecer semelhante.

O `art_lab` já dizia o mesmo pelo lado da produção (§14 D e §18 Q03–Q05 do
plano do ChatGPT): 1:1, ampliado, a mesma instância no jogo, e métricas que
**nunca substituem a decisão**.

## A prancha — `brport_vs/tools/prancha_prop.gd`

Uma folha por prop, com **A** (o PNG no disco) à esquerda e **B** (a
candidata) à direita, sempre na **mesma janela** — a união dos dois desenhos,
para uma diferença de posição se ver em vez de ser alinhada fora. Seis
linhas: a **foto do jogo**; **1:1 sobre o chão** do mapa, com a **diferença**
a magenta; a **ampliação** sem filtro; a **silhueta e o valor**; a
**escala** entre o trabalhador e o camião; e os **números** (tamanho a 1:1,
pixels opacos, folga até à borda do quadro, luminância mediana e Weber
contra cada chão, e a distância A↔B da régua 16×16). O log repete o contexto
e os números — quem itera sem abrir a imagem lê-os lá.

- **A e B leem-se do ARQUIVO**, nunca do `load()`, que devolve o `.ctex` de
  quando o projeto foi importado. E entram na foto do jogo pelo mesmo
  caminho (`ImageTexture` no nó), senão uma diferença de importador passaria
  por diferença de desenho.
- **A ampliação é em pixels da TEXTURA**: 1,5×, 3×, 4,5×… do jogo são 1, 2,
  3… pixels de textura, que é o que chega a um telefone de 1080 e o que se
  pode ampliar sem filtro. Ela fica com a altura que sobra — um prop de 9 px
  merece a página que um casco de 140 não deixa.
- **Sem candidata, B = A**, e ela exige **Δ zero exato e as duas fotos do
  jogo iguais ao byte**. É o controle da régua («o mesmo arquivo dos dois
  lados tem de dar zero»), feito a cada corrida e não num teste à parte.
- **A régua 16×16 é a do `comparar_props.py`, com a mesma conta** (média
  pré-multiplicada, nunca `resize`, `047`). Conferidas uma contra a outra no
  mesmo par: **0,0465 nas duas**.

### A foto do jogo

A partida é a da bateria (semente 20260902, espaço 1, nomes dados) e passa
por três estágios — **em ruínas, meio e completo**, 4 + 4 + 8 turnos, com os
trabalhadores alocados para o porto operar. A cada turno os painéis fecham-se
e a prancha procura um nó **visível** a mostrar o prop; ao achá-lo, **congela
o `Main` inteiro** (os tweens dos camiões param e ninguém lhe reescreve a
textura) e tira **três fotos: com A, com B e sem o prop**.

⚠️ **A TERCEIRA FOTO É A PROVA.** Visível na árvore e com o centro dentro da
tela não é visto: na primeira versão o casco grande foi achado na doca 3 e
esconder a troca mudou **0 px**, e a prancha recusou esse momento e seguiu.
Não foi a barra do HUD, que foi o primeiro palpite — a doca 3 cai a y = 540,
dentro do mapa —, mas quase de certeza um painel: essa versão ainda não
fechava os painéis que o dia abria antes de olhar, e o camião da mesma
corrida saiu fotografado através do escurecer de um. Hoje fecham-se.

⚠️ **O QUE O SORTEIO NÃO TRAZ ENTRA NO LUGAR DE UM IRMÃO, e diz-se.** Um
irmão é uma textura da mesma família do jogo (o mesmo nó troca entre elas)
com o mesmo **papel** — o eixo do camião, a classe do casco —, lido das
tabelas `CAMINHOES` e `CASCOS`. A primeira versão escolhia pelo tamanho do
desenho e pôs um camião de eixo `mx` no lugar de um de eixo `my`: atravessado
na rua, com a prancha a chamar-lhe contexto. A prancha escreve «FORÇADO no
lugar de X» no título; um contexto inventado que se apresentasse como visto
seria a folha a mentir sobre o que mediu.

⚠️ **E PROP SEM FOTO DO JOGO REPROVA**, se não estiver na `SEM_ANCORA`. A
primeira versão escrevia «não apareceu» e seguia verde, e uma prova partida
poria as 58 pranchas a dizê-lo sem uma queixa. É a conta dos dois lados da
folha de contato: o órfão declarado não pode ter foto, e quem não é órfão
tem de a ter.

⚠️ **E A ESCALA ALINHA PELO PÉ DO DESENHO**, não pelo centro do quadro. O
centro do quadro é a origem do mundo e seria o chão de todos — se todos
pousassem no chão. O trabalhador partilha a âncora do píer e é desenhado à
altura do tabuado: pelo centro, flutuava acima do camião.

## A página de escala — `brport_vs/tools/escala_props.gd`

Os 59 props a 1:1, do mais alto ao mais baixo, com o pé na mesma linha e o
trabalhador no começo de cada fila; o nome vai para a legenda por número,
porque um nome por baixo afastaria os props pela largura do NOME. Chão
neutro e único: a pergunta é o tamanho, e o contraste é da folha e da
prancha. Na primeira foto já se lê o que a folha de contato escondia: o bote
de pesca é mais baixo do que os camiões, e o trabalhador tem a altura da
cabine de um deles.

## O que saiu da folha, e porquê

O catálogo, a régua do mapa, a cena, as famílias e o chão viviam dentro da
`folha_props.gd`, e a prancha precisava de perguntar o mesmo. Saíram para
`brport_vs/tools/catalogo_props.gd`, e **as três páginas da folha ficaram
iguais ao byte** (o mesmo `md5` antes e depois) — o que mudou foi o
endereço, não a conta.

## A página do veredito

As duas fotos novas entram na bateria (`escala` e `prancha`, esta sem
candidata, que é o controle) e levam legenda no `tools/trilha_de_arte.py`, que
monta a página onde o Bruno dá o veredito. ⚠️ **E FALTAVAM DOZE LEGENDAS**:
as fotos da frente 3 entraram na bateria sem passar por lá, e a ferramenta
reprova foto sem legenda — a página do veredito desta frente não se montaria.
Nada no CI a corre, e por isso ninguém viu.

## As guardas, e os defeitos injetados

| Mutante | Quem reprovou |
|---|---|
| E1 — um prop da escala com alfa 0 | a prova com/sem da escala («cabeco.png não chegou à foto») |
| E2 — vão de 60 px entre props | a conta da página (1.501 px pedidos, 1.280 de tela) |
| E3 — legenda a 15 px | a largura da coluna da legenda |

| M1 — a troca sem congelar o `Main` | o controle B = A: o camião anda entre a foto A e a B («fotos do jogo iguais: false») |
| M2 — a terceira foto sem esconder o prop | nenhum contexto passa a prova (9 tentativas recusadas) e a prancha reprova por não ter foto |
| M3 — a diferença a comparar com o pixel ao lado | o controle B = A: 143 px «mudados» entre dois arquivos iguais |
| M4 — o painel da silhueta com alfa 0 | a prova com/sem da prancha, nos dois lados |
| M5 — um prop visto declarado órfão | a conta dos dois lados da `SEM_ANCORA` |
| A candidata a 512 px | o contrato do quadro (768 contra 512) |
| A candidata com um canto opaco | a guarda do fundo pintado |

**Corrida nos 59, com o critério do papel: 59 verdes, 504 s** — 48 vistos a
aparecer, 10 no lugar de um irmão (dois cascos grandes e os oito camiões
de contêiner e de granel, cada um no do mesmo eixo) e o órfão. De 2 a 19 s por
prop: o que aparece no porto em ruínas sai em 3 s, o que só vem no completo
passa dos 10.

## O que fica de fora

- **Uma posição no jogo, não três.** O `art_lab` pede três locais e um caso
  de oclusão; o prop fica onde o jogo o põe, e a foto mostra os vizinhos e
  quem o tapa. Três locais só existem para a fauna, que anda.
- **Os números são descritores.** Nenhum decide: o Weber da MEDIANA não vê
  o matiz (a telha separava-se do asfalto pelo matiz, `CLAUDE.md`), e a
  régua 16×16 é cega a um pixel.
- **A prancha não corre no Blender.** Renderizar a candidata é o
  `gerar_props_iso.py` com a pasta de saída noutro sítio; a prancha só a lê.
