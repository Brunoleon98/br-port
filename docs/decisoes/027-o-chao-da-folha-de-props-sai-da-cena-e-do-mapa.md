# 027 — O chão da folha de props sai da CENA e do MAPA, e não da tabela

**16/09/2026.** A folha de contato dos props nasceu na véspera com todo o
catálogo sobre **um fundo só** — o asfalto do pátio —, e isso estava escrito
como limitação assumida: *contraste depende do FUNDO, e um casco julgado sobre
asfalto não diz nada sobre um casco na água*. Ela respondia *"dá para olhar?"* e
não *"separa do fundo?"*. Esta é a sessão que lhe deu a segunda pergunta.

---

## 1. Duas fontes, e qual é cada uma

A **ÂNCORA** de cada prop sai da **CENA**: o `offset` do nó que o desenha, lido
do `SceneState` de `Main.tscn` e de `Dock.tscn`. A **COR** sai do **RASTER DO
MAPA**, que sai do gerador. É a mesma porta por onde o D20 pergunta se a pista é
pista e o D21 onde o barco fundeia — quem diz o sítio e quem diz a cor são
arquivos diferentes.

Uma tabela de posições escrita na ferramenta seria o espelho de que o
`CLAUDE.md` avisa; e ler a posição da **tabela de âncoras** seria quase o mesmo
espelho, porque a tabela e o raster saem os dois do gerador.

⚠️ **E não se confere aqui que a cena concorda com a tabela.** Já há quem o
faça: o bloco **D1** do teste de design exige que Píer, Lança e Barco das três
docas caiam em cima do que o `porto_mapa_ancoras.json` publica. Uma regra que
viva em dois sítios nunca reprova num defeito injetado, e a correção escrita no
`CLAUDE.md` é apagar a cópia — então a folha herda o acordo em vez de o repetir.

⚠️ **Lê-se o `SceneState`, não se instancia a cena.** Um `Main.tscn` instanciado
corre o `_ready()` dele, que arma o `Registro` e carrega o autosave que estiver
em `user://` — a armadilha que o `capturar_cena.gd` pagou em 12/09. O estado
guardado responde à pergunta (onde está o nó) sem pôr nada de pé.

⚠️ **E a âncora é relativa ao `MapaWrap`.** Ele tem `offset_top = 62`, e somar
esse deslocamento põe toda amostra 62 px abaixo do prop. É a armadilha que o
`CLAUDE.md` já carrega escrita — *"três recortes já foram ao lugar errado por
causa disto"* — e ela mordeu na PRIMEIRA medição desta ferramenta.

## 2. O buraco previsto não era o buraco

O briefing da sessão anterior contava com cinco famílias sem âncora: as
alternativas em ruína (`galpao_velho`, `escritorio_ruina`), o `pier_vazio`, os
**nove cascos** que nascem em `Dock.tscn` e o órfão `doca_concreto`.

**Medido, a cena responde por 50 dos 51.** A previsão olhava para a TABELA de
âncoras, onde eles de facto não estão — e a cena é outra coisa: a ruína e o
prédio pronto partilham o NÓ que o `Main.gd` troca (`Armazem`, `Escritorio`), e
os cascos, as lanças e os píeres partilham as VAGAS da doca. A âncora é do
SLOT; quem a partilha sai das tabelas do jogo (`CASCOS`, `ArtePier`,
`ArteLanca`, `CAMINHOES`), percorridas como a `folha_frota` as percorre.

Sobra **`doca_concreto`** — o órfão que o `tools/arte_orfa.py` acha desde 14/09,
que nada no jogo desenha. Ele sai sobre um chão **LISTRADO**, que nenhuma
amostra do mapa pode imitar, com `sem âncora · recurso` escrito por baixo.

É a regra do `CLAUDE.md` sobre prever com medição antiga, com outra roupa:
**antes de herdar um buraco previsto, pergunte de que fonte a previsão o leu.**

## 3. As escolhas que a medição decidiu

**A janela é 7×7 px de TELA e o que se tira dela é o pixel MEDIANO por
luminância.** Média inventaria uma cor que não está no mapa — *cor misturada
nunca casa com um tom publicado* —, e o chão desta folha tem de ser um chão que
existe. O raio é o mesmo do D20: medido nos 51 props, é onde a amostra deixa de
ser cara-ou-coroa entre dois pixels vizinhos sem ainda atravessar para o terreno
do lado (a 5 px o coqueiro do passeio já lê capim, e o cabeço já lê água).

**Um prop pode pisar DOIS chãos**, e a célula leva uma faixa por chão distinto,
com o prop em cima da emenda. Uma célula por avistamento faria a folha crescer
de 51 para 65 — com 12 dessas repetições a mostrarem o mesmo tom duas vezes.

**O corte do "distinto" vai ao MEIO da banda medida:** os pares que têm de
colapsar (duas águas do largo, dois pixels do mesmo asfalto) chegam a **11** de
diferença máxima de canal, e os que têm de separar (passeio contra capim, baixio
contra areia) começam em **35**. O corte é **23** — 2,1× de folga de um lado e
1,5× do outro. ⚠️ **Escolher 40 daria exactamente duas páginas cheias, e é por
isso mesmo que não se escolhe:** seria apertar o teto de uma guarda até o
resultado ficar bonito.

**Qual dos dois mapas responde por um prop** sai do jogo e não daqui: o
`EQUIPAMENTO_DE_PATIO` do `Main.gd` só aparece quando o pátio existe, então
julgá-lo sobre a terra batida seria julgá-lo num estado em que ele não aparece.

⚠️ **E o que se amostra é o MAPA, que não é sempre o que o prop pisa.** Quem
pousa em cima de OUTRO prop — o trabalhador e as três lanças, no tabuado do
píer — sai sobre a água do berço. É limitação assumida e escrita, como o fundo
único era até hoje: o convés do píer não está no mapa, está num PNG.

## 4. As guardas novas, e o defeito injetado em cada uma

| Guarda | Defeito injetado | Resultado |
|---|---|---|
| Família aponta para um nó que a cena tem | `Armazem` → `ArmazemX` | reprovou |
| A textura que a cena põe no slot pertence à família | família do `Armazem` trocada pela do escritório | reprovou |
| Prop sem âncora tem de estar declarado | tirar `doca_concreto` da lista | reprovou |
| Declarado que afinal tem âncora sai da lista | juntar `cabeco` à lista | reprovou |
| O mapa rasteriza na régua da tabela | apontar para um SVG de outro tamanho | reprovou |
| O rótulo cabe na célula (duas linhas) | `FONTE_CHAO` 10 → 20 | reprovou (202 px de 159) |

⚠️ **E um defeito NÃO pegou, e está medido porquê.** Baixar o `CORTE_CHAO` a
zero — que parte todo prop em todos os tons crus que ele pisa — **não reprova**
a guarda do rótulo: a segunda linha só transborda ao QUARTO chão (170 px contra
159), e nenhum prop do catálogo de hoje pisa quatro (o máximo são três, 126 px).
Quem está apertado é a PRIMEIRA linha: `caminhao_armazenagem_mx` pede 155 px num
orçamento de 159, e dois caracteres a mais já reprovam. **Uma guarda defende o
que defende** — escreve-se ao lado dela o que fica de fora, em vez de se apertar
o teto até ela apanhar o defeito seguinte.

⚠️ **E a guarda que reprovou no defeito da fonte foi a do rótulo de RECURSO**
(`sem âncora · recurso`, 202 px), não a linha de dois hexadecimais que se queria
exercer. É o *"confira QUAL guarda está a segurar a asserção"* do `CLAUDE.md` à
escala de um rótulo: o número dos 170 px do quarto chão foi medido com a mesma
chamada que a guarda faz, e não estimado.

## 5. O que fica por fazer

A metade de OLHAR, que é do Bruno, e é o gate A5 inteiro: a trilha dos 30 pontos
e estas duas páginas. O `doca_concreto` continua órfão — entra no jogo ou sai do
catálogo, e **é decisão dele**.
