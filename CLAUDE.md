# BR Port — instruções do projeto

Jogo mobile de gestão de porto. Godot 4.6 + GDScript, retrato 720×1280, em
português do Brasil. O código, os comentários, os documentos e os nomes de nó
são em português — commits e PRs em inglês.

> **A documentação tem quatro camadas, e mais nenhuma.** Este arquivo é a
> primeira, e a única que carrega sozinha.
>
> | Camada | Onde | Responde |
> |---|---|---|
> | Regras | este arquivo | O que nunca se faz aqui |
> | Estado | `docs/ESTADO_DO_PROJETO.md` | Como o jogo está hoje |
> | Rumo | `docs/design/BR_Port_Plano_v3_Claude_Code.md` | O que vem a seguir, e quem faz o quê |
> | Decisões | `docs/decisoes/NNN-*.md` | Por que se decidiu assim, uma por arquivo |
>
> Para retomar o trabalho são **dois** documentos: o estado e o plano. Até
> 02/09 eram cinco em cadeia, e esta linha apontava para o terceiro elo.
> O que aconteceu em cada sessão que fechou vive em `docs/arquivo/`, com
> índice — **nada se apaga**, e nada de lá descreve o jogo de hoje.
>
> Os documentos de trabalho não são camada e continuam onde a mão os
> alcança: `docs/BRP_SPATIAL_CONTRACT.md` (o contrato da projeção),
> `docs/design/BR_Port_Plano_Arte_Blender.md` (o caminho medido da arte),
> `docs/PROTOCOLO_DE_ESCUTA.md` (o gate do A6, que só o Bruno passa) e
> `art_lab/README.md` (o laboratório de arte partilhado com o ChatGPT: o plano
> de produção dele, os conceitos e as candidatas, e o caminho de uma peça até
> ao jogo).
>
> **O Codex também contribui neste repositório**, por branches `codex/*` e PR,
> com tarefas que o Bruno lhe entrega. Ele lê `AGENTS.md`, que só aponta para
> este arquivo e diz como os dois agentes não se atropelam — as regras daqui
> valem para ele. Antes de mexer num arquivo de alto conflito, veja os PRs
> abertos dele.
> `tools/conferir_docs.py` tranca isto no CI, e espera `DOCS OK`.
>
> **O GDD 7 lê-se em `docs/gdd/`**, uma seção por arquivo, GERADAS do
> `BR_Port_GDD_V7.jsx` — não as edite. Ele descreve o jogo das Fases 1 a 5 e
> está **congelado antes da reescala de 02/09**: onde os números dele
> divergirem do jogo, quem manda é `docs/design/BR_Port_Numeros_Fase_1.md`,
> que sai do `GameState.gd`.

---

## Como rodar, aqui dentro

**O Godot e o Blender rodam neste contêiner.** Duas rodadas de trabalho visual
já foram feitas às cegas por não se saber disto. Não trabalhe no escuro.

**Numa sessão remota o Godot já está pronto quando a conversa abre**, e o `$G`
já aponta para ele: quem faz isso é `.claude/hooks/session-start.sh`, que baixa
o binário, roda o `--import` e diz numa linha o que ficou disponível. Se a
primeira mensagem da sessão não trouxer essa linha, o hook não correu — aí vale
a receita manual abaixo.

**O hook só vale a partir da MAIN.** Uma sessão nova arranca do branch padrão,
então uma alteração ao hook que esteja só numa branch de trabalho não corre —
nem na sessão que a escreveu, nem em nenhuma outra, até o PR ser fundido. Quem
mexer no hook e não vir efeito na sessão seguinte deve olhar para isto antes de
o ir depurar.

```sh
# Godot (~70 MB, ~12 s) — só se o hook de arranque não tiver corrido
V=$(tr -d '[:space:]' < .godot-version)   # a versão vive num arquivo só
curl -fsSL -o /tmp/g.zip https://github.com/godotengine/godot/releases/download/$V-stable/Godot_v$V-stable_linux.x86_64.zip
mkdir -p ~/godot-bin && unzip -q -o /tmp/g.zip -d ~/godot-bin
chmod +x ~/godot-bin/Godot_v$V-stable_linux.x86_64
G=~/godot-bin/Godot_v$V-stable_linux.x86_64

$G --headless --path brport_vs --import                       # UMA VEZ por clone
$G --headless --path brport_vs --script res://tests/run_tests.gd
$G --headless --path brport_vs --script res://tests/teste_design.gd
$G --headless --path brport_vs --script res://tests/teste_audio.gd
$G --headless --path brport_vs --script res://tests/teste_fumaca.gd
$G --headless --path brport_vs --script res://tests/teste_registro.gd
$G --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_tela.gd -- 12 foto.png completo

tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"   # todas de uma vez

# Blender como biblioteca Python (~1 GB, minutos)
pip install "bpy==4.5.0"                                      # precisa de Python 3.11
python3 tools/gerar_props_iso.py brport_vs/art/props [prop ...]
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  --sem-pavimento brport_vs/art/porto_mapa_iso.svg

# Efeitos sonoros — sem dependência, biblioteca padrão só
python3 tools/gerar_sons.py brport_vs/audio/sfx
```

**`--import` não é opcional.** Num clone novo não existe `.godot/`, e sem ela
a suíte falha com uma pilha de `referenced non-existent resource` que não tem
nada a ver com o que se está testando. O hook de arranque já a roda; a regra
continua escrita aqui porque ela vale mesmo quando o hook não correu.

**A versão do Godot vive em `.godot-version`, e num lugar só.** O hook e o CI
leem esse arquivo. Antes dele, este documento mandava baixar a 4.6.1 e o CI
rodava a 4.6.3 — a sessão testava numa versão e o PR era barrado noutra.

**O APK NÃO se constrói aqui, e o Web sim.** O `dl.google.com` responde 403 por
política da organização, então o SDK do Android é inalcançável e o CI é o único
lugar onde o export do APK se verifica — ele corre a cada push e deixa o
`brport-apk` e o `brport-web` em Artifacts. O Web só precisa dos templates
(~1,2 GB), que o CI cacheia; a receita completa, pelos dois caminhos, está em
`brport_vs/COMO_RODAR.md`.

**Mas o `.pck` mede-se aqui, e sem template nenhum** — é o que responde "quanto
custa isto ao pacote?" sem esperar uma corrida do CI:
`$G --headless --path brport_vs --export-pack Android /tmp/brport.pck`. O APK e
o `brport-web` continuam a ler-se dos artefatos, e o **antes** costuma já estar
lá: a última corrida do `main` mediu-os no commit que a branch tem por base.

⚠️ **E O DELTA DO `.pck` É O DELTA DO APK, medido** (`029`): a alavanca B fez os
três crescerem os MESMOS ~1,87 MB, com o APK a 1,0009× e o web a 1,0025× do que
o `.pck` local dizia — **0,09% de erro**. Logo não se espera pelo CI para saber
quanto um asset custa ao pacote.
⚠️ **Mas a PERCENTAGEM é outra em cada um, e só uma é a do jogador.** Os mesmos
1,87 MB são +42,29% do `.pck` e **+5,91% do APK**, porque o APK é sobretudo o
binário do Godot. Ao citar custo, diga contra que denominador.

**E a VRAM também se mede aqui**, com o jogo aberto: `xvfb-run -a $G --path
brport_vs --resolution 720x1280 --rendering-driver opengl3 --script
res://tools/medir_vram.gd`, espera `VRAM MEDIDA`. ⚠️ O monitor do motor conta
**4/3 de `w×h×4`**, e a base já traz os retratos (um autoload faz-lhes
`preload`): a régua calibra-se sozinha com uma textura de tamanho conhecido, e
em `--headless` recusa-se em vez de publicar um zero (`049`).

⚠️ **O CI regera e compara BYTE A BYTE, e o `sum()` de floats mudou na Python
3.12.** Ela passou a somar por compensação de Neumaier; o runner é
`ubuntu-latest` e subiu de versão sozinho. Medido em 05/09, o mesmo arquivo:
`CX = 508.49999999999994` na 3.10/3.11 contra `508.50000000000006` na 3.12/3.13
— 1e-14 que o `%.1f` do gerador arredonda para o outro lado e vira **190 linhas
de diferença** nos dois mapas, com o PR vermelho e nenhuma coordenada do mundo
mudada. Num gerador cuja saída o CI compara assim: `math.fsum` em vez de `sum`,
e **arredonde o que alimenta tudo o resto** — número que sai de divisão e entra
em toda coordenada tem de ser exato, senão a máquina decide o desenho.

⚠️ **PODA QUE REORDENA UM `argmin` MUDA O RESULTADO, e aqui isso é o PNG.** O
campo de cor da água mede, para cada um de 518 mil pixels, a distância ao
segmento de costa mais perto — e usa o `my` do VENCEDOR. Com a costa das pontas
desenhada foram 10 segmentos para ~500, e a força bruta passou de 5 s para 182 s
por mapa; o índice espacial que a substituiu só é legítimo porque (a) descarta
apenas segmentos que **não podem** ganhar, por um piso de distância, e (b) mantém
a ORDEM original, que é quem desempata. Trocar a ordem teria mudado a cor de
pixels que ninguém pediu para mudar, sem erro nenhum. Otimização num gerador que
o CI compara byte a byte prova-se assim: **corra a versão lenta e a rápida e
exija os mesmos bytes**, na entrada velha E na nova.

⚠️ **`zlib.Z_FIXED` NÃO torna um PNG byte-estável entre zlib e zlib-ng.** A
árvore de Huffman fica fixa, mas cada implementação ainda pode escolher
casamentos LZ diferentes. Medido no PR 45: os pixels RGBA eram idênticos e só
a linha base64 mudava nos dois mapas entre Python 3.14/zlib-ng no Windows e o
runner Linux. O raster costeiro usa `_zlib_fixo()`, com procura LZ e DEFLATE
próprios; não o troque por `compressobj()` enquanto o CI comparar o SVG byte a
byte.

⚠️ **Valor de Godot 3 numa chave de Godot 4 não dá erro — dá outra coisa.**
`window/handheld/orientation="portrait"` é sintaxe da 3; na 4 a chave é um enum
INTEIRO, e o exportador faz `int()` dela. `int("portrait")` é **0**, que é
PAISAGEM: o APK saiu deitado enquanto o projeto se dizia retrato havia cinco
blocos, e nenhuma das cinco suítes lia aquela linha. Ao conferir uma chave de
`project.godot`, confira o **TIPO** e não só o valor — e desconfie de toda
string numa chave que a documentação da 4 descreve como enum.

⚠️ **O `viewport_width=720` NÃO É A RESOLUÇÃO DE RENDER — é um sistema de
coordenadas.** Com `window/stretch/mode="canvas_items"`, o Godot desenha na
resolução NATIVA do aparelho e escala o conteúdo 2D: num telefone de 1080×2400
o jogo já sai a 1080 de largura. Logo **subir o viewport para 1080×1920 não dá
um pixel de informação** — daria um `offset` reescrito em toda `.tscn`, mais o
`MEIA_LARG`, as âncoras e o teste de design, em troca de nada. Quem quiser mais
detalhe sobe a resolução dos ASSETS, não a do viewport (a §7 do plano v3 tem as
três alavancas medidas, e a Etapa 7 do plano de arte tem o desenho que elas
pagam). O que o viewport decide de verdade é a PROPORÇÃO, e essa é outro
problema: 9:16 num mundo 9:20 perde ~240 px de barra em cima e outros 240 em
baixo, medido e escrito no `project.godot`.

⚠️ **O export Android reprova com a lista de erros VAZIA.** De uns vinte testes
de configuração do Godot, só o do ETC2/ASTC põe `valid = false` sem escrever
mensagem — e ele depende do SISTEMA em que se exporta, passando num Mac e
reprovando em Linux. É por isso que `project.godot` traz
`textures/vram_compression/import_etc2_astc=true` com a explicação ao lado, e
que o bloco F5 do `teste_fumaca.gd` o tranca na suíte rápida: a resposta chega
em segundos em vez de depois de um export inteiro.

O `xvfb-run` só faz falta para a captura, que precisa de contexto gráfico.
Teste e import rodam sem tela.

---

## Antes de fechar qualquer mudança

> A skill **`/fechar-sessao`** conduz esta lista inteira — mais a varredura do
> que se aprendeu e o `ESTADO_DO_PROJETO.md`. Esta seção continua aqui porque é
> o que carrega sozinho; a skill é para quando se chega ao fim de um bloco.

1. `tests/run_tests.gd` — a lógica. Espera `TODOS OS TESTES PASSARAM`.
2. `tests/teste_design.gd` — o encaixe e o layout. Espera `DESIGN OK`.
   `tests/teste_audio.gd` — o encanamento de som. Espera `AUDIO OK`.
   `tests/teste_fumaca.gd` — a cena abre, o ícone existe, o save não migra.
   Espera `FUMACA OK`.
   `tests/teste_registro.gd` — o gravador de partida. Espera `REGISTRO OK`.
   `scripts/validation/asset_validator.gd` — o contrato dos assets. Espera
   `ASSET OK`.
   ⚠️ **SÃO SEIS, e esta lista dizia quatro.** O `teste_registro` entrou no CI
   em 02/09 e não era citado em documento nenhum dos seis que o repetiam —
   nem aqui, nem no hook, nem nas três skills, nem no `COMO_RODAR`. Quem
   manda hoje é o `testes.yml`, e `tools/conferir_docs.py` reprova quem
   divergir dele (`docs/decisoes/032`).
3. Mexeu em QUALQUER `const` do `GameState.gd`? Regere a tabela dos números —
   `despejar_constantes.gd` + `tools/gerar_tabela_numeros.py --contra-godot`,
   espera `TABELA OK`. Ela é gerada do código, e o CI reprova se envelhecer:
   os números já viveram no GDD e nas constantes ao mesmo tempo, e divergiram.
4. Mexeu em preço ou constante `# TUNING:`? `tools/simular_balanceamento.gd`.
   O balanceamento medido é **100% / 80,2% / 37,3%** por perfil, com a mediana
   do jogador mediano em R$716.179 contra uma parcela de R$530.000. Mexer sem
   medir quebra isso.
   **O alvo é TRANQUILO, e é decisão registrada** (`docs/decisoes/005`): a
   dívida deixou de ser o motor. Os 100% / 47% / 0% que este arquivo afirmou
   até 02/09 eram a fantasia de sobrevivência que essa decisão substituiu — são
   história, não meta. Quem discrimina os jogadores agora é **o porto que
   conseguem levantar** — e desde a trava de 06/09 quem mede isso é a MARGEM
   em regime (R$674.019 contra R$103.290), não a contagem de barcos: o porto
   pobre só recebe pesqueiro, descarrega num turno e atende MAIS barcos do que
   o rico (46,1 contra 13,6). `docs/decisoes/009`.
   ⚠️ **A PARCELA MOVE O DESCUIDADO E QUASE NÃO MOVE O MEDIANO**, e não é
   acaso: cada R$10.000 valem ~3 pontos a um e ~0,5 ao outro, porque a mediana
   do Mediano fecha muito acima da parcela e a do Descuidado logo abaixo dela.
   Botão só move quem está em cima da linha — e um varrimento que não acha o
   ponto costuma estar a varrer o eixo errado (`docs/decisoes/008`).
   ⚠️ **E o jogo perfeito voltou aos 100%** com a trava do nível: a exceção
   medida em 06/09 — o Ótimo a levantar as sete estruturas num sorteio mau e a
   chegar curto — desapareceu, porque o porto que constrói tudo também passou a
   receber navio melhor.
   **Medir é com `-- 600`, e é o que o CI roda desde 05/09.** ⚠️ Esta linha
   anunciava uma amostra de fumaça no CI e ficou a descrever um comando que
   deixou de existir no dia em que o portão das Parcelas passou a precisar de
   uma MEDIÇÃO — no arquivo que carrega sozinho, portanto lido em toda sessão
   (`docs/decisoes/032`). Uma rodada CURTA continua a ser teste de fumaça
   (prova que a ferramenta não quebrou junto com o `GameState`) e tem margem
   de dezenas de pontos: comparar aquele número com estes é comparar sorteio.
   O próprio simulador avisa quando a rodada é curta demais para medir.
   ⚠️ **E PORTÃO ALIMENTADO COM FUMAÇA REPROVA POR SORTEIO.** O CI passava ao
   portão de calibração do `projetar_parcelas.py` a medição de 30 partidas — a
   mesma que o simulador imprime rotulada de TESTE DE FUMAÇA — e comparava-a
   com uma tolerância de 5%. Em 06/09 ele reprovou o Mediano por 5,4% **com o
   modelo certo**: medido com cinco sementes, a margem em regime de 30 partidas
   oscila ±6% a ±9% sozinha, e a semente do CI calhava dar o valor mais baixo.
   Quando um portão compara contra um número MEDIDO, pergunte quanto esse
   número se mexe sozinho antes de escolher a tolerância — e se ele se mexer
   mais do que ela, o defeito é do portão, não do que ele reprova. Hoje o CI
   mede com 600 e o projetor recusa-se a calibrar abaixo de 100 partidas.
   ⚠️ **E RESULTADO MEDIDO NUMA CONSTANTE NÃO SE PREVÊ NOUTRA — nem quando as
   duas entram na mesma razão.** A `/balancear` regista que encarecer as
   ESTRUTURAS inverte a dificuldade (o cauteloso não constrói, acumula e paga a
   parcela). Em 11/09 a F1 leu isso como uma propriedade da razão
   `caixa / custo`, previu a mesma inversão baixando o `START_CASH` e desenhou
   uma varredura inteira para a apanhar: ela **não veio em nenhum dos sete
   pontos**. Encarecer a estrutura mexe só em QUEM CONSTRÓI; baixar o caixa
   mexe nisso e no NÍVEL ABSOLUTO contra a parcela, e o segundo domina — o
   acumulador só ganha se tiver o que acumular. Antes de prever com uma
   medição antiga, confira que ela mexeu na MESMA constante (`018`).
   ⚠️ **E CONTA QUE RESPONDE PELO PRIMEIRO TURNO NÃO DESCREVE 32 DELES.** Na
   mesma F1, `caixa >= custo × folga` pôs um penhasco em 320.000 — abaixo disso
   o Descuidado "não abre com compra nenhuma". Medido, ele levanta o escritório
   em 100% das partidas até aos 200.000 e em 86% a 150.000, porque acumula
   receita e compra no turno 9. Um limiar só vira penhasco quando a partida
   acaba antes de o perfil poupar a diferença.
   ⚠️ **E UMA MUDANÇA DE CADÊNCIA NÃO MOVE O JOGADOR CONTRA A LINHA — MOVE A
   LINHA CONTRA ELE.** Medido em 13/09 ao varrer `TURNS_PER_WEEK` para 7: o
   plano previa que "o porto pobre sente primeiro", e quem sofreu 2,4× mais foi
   o **Mediano** (−37,4 pontos contra −15,8). A regra da `008` — botão só move
   quem está em cima da linha — continua de pé; o que faltava é a outra metade,
   que é **quem está em cima dela pode MUDAR**. A mediana do Mediano atravessou
   a parcela de cima para baixo, e o Descuidado, já do lado errado, tinha menos
   a perder. Antes de prever quem sente uma mudança, pergunte onde ela põe cada
   mediana — e não onde elas estão hoje.
   ⚠️ **E COMPENSAR PROPORCIONALMENTE SOBRECOMPENSA, quando a constante entra
   num LAÇO.** Na mesma medição: encolher a semana 12,5% tirou 12,3% ao Ótimo —
   exactamente a proporção, porque com folga 1,0 ele compra assim que dá e chega
   ao mesmo porto — e **23,9% ao Mediano**, porque a folga de 2,0 deixa de ser
   atingida e *menos receita → porto menor → menos receita*. Daí que devolver os
   mesmos 12,5% no custo das estruturas devolva MAIS do que 12,5% de porto: o
   ponto "coerente" de tudo × 7/8 mediu 100 / 90,5 / 51,5, muito acima do alvo.
   **Constante que alimenta o que GERA a receita não se compensa por regra de
   três** — compensa-se varrendo, e o ponto sai onde a medição o puser.
5. Mexeu no visual? **Tire uma captura e olhe.** Teste verde não prova que
   ficou bonito. O CI já anexa TODAS a cada PR (artefato `brport-captura`) e
   diz na página da corrida qual mudou — mas dizer que mudou não é dizer que
   ficou bom, e essa parte continua a ser de quem olha. **Cinco delas mostram
   uma PARTIDA SORTEADA**, e o que varia com o sorteio não se prova ali: para
   isso são as duas folhas de contato, a dos ícones e a da frota.
   ⚠️ **E A SEMENTE DO JOGO NÃO É A SEMENTE GLOBAL.** O `seed()` do Godot
   semeia o gerador global; o `GameState` sorteia com um
   `RandomNumberGenerator` próprio, que o `_ready()` dele `randomize()` — quem
   quiser foto reprodutível escreve `GS._rng.seed`. O `capturar_tela.gd`
   fazia-o e o `capturar_cena.gd` não, e isso só apareceu no dia em que um
   painel fotografado passou a ler o sorteio: duas corridas do mesmo código
   deram R$16.104 e R$0.
   **Captura só se compara com semente E passo de tempo fixos.** É o que o
   `tools/capturar_evidencia.sh` faz, e as duas fazem falta: com a semente
   sozinha, duas corridas do MESMO código davam 1.030 pixels diferentes,
   porque os tweens em laço andam por *delta* e não por frame. Quem tirar a
   captura à mão sem `--fixed-fps 60` tem uma foto para olhar, não uma para
   comparar.
   ⚠️ **E FERRAMENTA DE EVIDÊNCIA QUE CONTA VOLTAS NÃO ENTREGA O QUE PROMETE.**
   O `capturar_tela.gd -- N` contava iterações de laço, e a oferta do rival
   gastava uma sem virar o dia: medido em 18/09, `-- 10` entregava o turno 9,
   `-- 34` entregava o 27. Ferramenta que promete um ESTADO avança até o estado
   — `while GS.turn < alvo`, e um teto de voltas para o caso de o estado nunca
   chegar (`docs/decisoes/031`).
   ⚠️ **E CONTAR O QUE ESTÁ ABERTO NO FIM NÃO DIZ O QUE ESTAVA ABERTO
   DURANTE.** A contagem de painéis existe desde que o `porto` saiu com o
   Boletim por cima, e não podia apanhar o defeito irmão: a ferramenta avançava
   turnos por BAIXO do modal — no jogo o botão "Avançar dia" fica debaixo do
   escurecer de todo `PainelNarrativo`, que é um `ColorRect` a tela cheia no
   `CanvasLayer`, logo aquelas fotos são estados que ninguém alcança a jogar.
   Medido: com o defeito injetado, o tiro do boletim chegou ao turno 13 **com
   um painel**, que é exatamente o número que a guarda velha exigia. Guarda de
   ESTADO FINAL não prova PROCESSO — cada tiro passou a declarar também o TURNO
   em que pára, e é isso que reprova.
   E ao recortar a captura para conferir um detalhe, lembre que
   **o mapa não começa no topo da tela**: `MapaWrap` tem `offset_top = 62`, e
   as coordenadas que saem da projeção são do MAPA. Somar os 62 é a diferença
   entre olhar o prop e olhar o telhado ao lado dele — três recortes já foram
   ao lugar errado por causa disto.
   ⚠️ **E VALE IGUAL PARA QUEM ANDA PELA ÁRVORE DE NÓS, que é onde ele se
   disfarça.** Uma ferramenta que some os `offset` de pai em pai apanha o do
   `MapaWrap` sem o ver, e o erro não se parece nada com um recorte torto — sai
   uma cor plausível, do sítio errado. Quem lê coordenada de mapa começa a
   contar NO `MapaWrap`, e não na raiz da cena (mordeu na `folha_props`, 16/09).
6. **Captura de painel sem tema é uma fotografia mentirosa.** No jogo quem
   aplica o tema é o `_abrir_painel()`; cena instanciada solta nasce com o
   cinzento padrão do Godot. O `capturar_cena.gd` já o aplica, e também chama
   `setup()` com os argumentos extra — sem isso os painéis que dependem dele
   saem VAZIOS e a captura passa por "a cena abre" sem mostrar nada.
   ⚠️ **E O AUTOLOAD NÃO NASCE VAZIO — ele tenta `load_game()` ANTES de
   `new_game()`.** Logo toda ferramenta que fotografe uma cena solta herda o
   autosave que estiver em `user://`, e a bateria tira as fotos de JOGO
   primeiro, que gravam. Medido em 12/09: o painel da parcela afirmava que
   R$498.200 eram "menos de uma das estruturas que faltam" porque o save da
   foto anterior já tinha as SETE construídas — com partida nova a mesma
   quantia compra quatro. **Foto que depende do que está no disco não compara
   nada**, e é a regra de a ferramenta DERIVAR o estado outra vez: o
   `capturar_tela.gd` já fazia `clear_save()` + semente + `new_game()`, o
   `capturar_cena.gd` não fazia, e o que prova o conserto é rodar a bateria
   DUAS vezes e exigir os mesmos bytes.
   ⚠️ **E A GUARDA QUE PULA O `setup()` CAVA O BURACO QUE O COMENTÁRIO AO LADO
   DESCREVE.** No mesmo dia: o `capturar_cena.gd` só chamava `setup()` quando
   havia argumentos extra na linha de comando, e os quatro painéis cujo
   `setup()` não EXIGE argumento — Calendário, Docas, Parcela, Reputação —
   nunca o recebiam. A captura saía com o escurecer e um cartão de altura zero,
   imprimia "Tela salva em" e passava por boa; o Diário escapou por montar no
   `_ready()`, e foi por isso que isto viveu escondido. **Condição de atalho
   numa ferramenta de evidência é uma foto que ninguém tirou.**
   ⚠️ **E PAINEL FOTOGRAFADO EM PARTIDA NOVA PROVA QUE A CENA ABRE E MAIS
   NADA.** A cena solta nasce no turno 1 do porto em ruínas, e é exactamente aí
   que os painéis do HUD não dizem nada: no dia 1 o calendário não tem dia
   PASSADO, em ruínas o Construir não tem cartão VERDE, com uma doca a contagem
   nunca passa de 1 — que é onde o singular e o plural dão o mesmo texto — e a
   reputação está no patamar de partida, onde um "▸" que ande não se distingue
   de um pregado. Escrever o estado à mão (`turn=9`) põe o rótulo certo com o
   resto parado no dia 1: verdadeiro no rótulo, falso no resto. Uma partida
   JOGADA deriva tudo de uma vez — é o `--painel=<nome>` do `capturar_tela.gd`,
   que abre cada um pela PORTA DO JOGADOR e traz de graça as guardas do turno e
   da contagem de painéis, que a cena solta não tem (`docs/decisoes/038`).
   ⚠️ **E A PORTA DO JOGADOR TAMBÉM TEM FASE.** Tocar no botão verdadeiro não
   basta: o `pay_debt()` sai CALADO fora de `debt_payment`, e numa cena solta
   o «Pagar» mostrava a resposta de quem pagou sem o dinheiro ter mudado de
   mãos — texto certo, estado que não existe a jogar. A montagem
   `parcela=vencida` chega lá pelo `advance_turn()`, e o F10 prova-o pelo
   `parcela_paid` (`051`).
   ⚠️ **E COBERTURA DECLARADA MENTE; COBERTURA MEDIDA NÃO.** Cada guarda de
   captura responde pelo SEU tiro — a imagem saiu, o erro não apareceu, a
   contagem e o turno batem — e **nenhuma responde pelo CATÁLOGO**, que é como
   cinco painéis viveram sem foto. A saída fácil é o tiro declarar ao lado dele
   o que cobre, e essa declaração mente: medido, um tiro que prometia o Caixa e
   fotografava o Calendário passou a contagem (1 painel), o turno (13) e o
   tamanho (306.639 bytes). Quem o apanhou foi a FOTO — as duas ferramentas
   imprimem `Paineis: res://...` com a cena de cada painel na tela, e o
   `tools/conferir_cobertura_paineis.py` lê os logs contra o que o `Main` abre
   (`docs/decisoes/039`).
   ⚠️ **E INVENTÁRIO QUE OLHA UMA PASTA PERDE O QUE NÃO ESTÁ NELA.** Três
   sessões contaram os painéis deste jogo e as três disseram treze; são
   **quinze**. O `EndGame.tscn` não vive em `scenes/panels/` — está em
   `scenes/`, e por isso escapou a todos —, e a `TelaNomes` escapa por outro
   caminho: o `capturar_tela.gd` dispensa-a DE PROPÓSITO, com `definir_nomes()`,
   para ela não tapar o que se ia fotografar. **A convenção de pasta é uma
   suposição sobre o conteúdo**, e quem conta pergunta ao que o jogo ABRE, não
   ao que a pasta guarda.
   ⚠️ **E UM PAINEL NÃO É UMA TELA.** A cobertura perguntava por CENA, e a do
   Sr. Ribeiro são três — entrada, pagou, não pagou. A bateria fotografava só
   o primeiro tempo de cada painel, e a despedida do Arlindo viveu dez dias a
   dizer «Cliente ouvindo a proposta. (2 tentativas)» por baixo de um negócio
   fechado. Hoje o catálogo desce ao TEMPO (`tempo = &"<id>"`, sempre
   literal), e o que não se pode fotografar fica DECLARADO como lacuna — a
   afirmação perigosa é a positiva, e a lacuna só envelhece para o lado que
   reprova (`docs/decisoes/051`).
   Para olhar um detalhe pequeno, `tools/recortar_captura.gd` amplia sem
   suavizar: a 19px um ícone não se julga a olho na captura inteira, e foi
   ampliando que se viu que o ícone `doca` era um fantasma no painel branco.
   **E a própria ferramenta de captura tem números que envelhecem.** O
   `capturar_tela.gd -- N foto.png completo` dava R$100.000 ao jogador para
   comprar o porto inteiro; depois da reescala o porto passou a custar
   R$785.000, as duas últimas compras falhavam, e a foto saía com o porto A
   MEIO chamando-se "completo". O caixa vem da tabela de preços agora — como
   na suíte. Ferramenta que finge um estado tem de o DERIVAR do estado.
7. Escreveu um validador e ele **passou de primeira**? Desconfie. Injete o
   defeito que ele deveria pegar e veja-o reprovar antes de confiar nele. Um
   validador que nunca reprovou nada não é um validador — e, na primeira vez
   que se fez isto aqui, quem estava furado era o teste, não o validador.
   ⚠️ **E UM VALOR IMPOSSÍVEL É O MESMO ALARME QUE O ZERO, e mais barato de
   ver.** A irmã da regra do zero em tudo, do outro lado: ali a régua não
   consegue devolver outra coisa; aqui ela devolve uma coisa que não pode
   existir. Em 19/09 a régua da faixa de mensagem relatou **−194** mensagens
   "nunca apresentadas" — uma contagem negativa —, e o sinal apontava para a
   causa: a sonda pendurava-se num funil que tinha deixado de ser único.
   **SONDA PRESA A UM PONTO DE PASSAGEM MORRE QUANDO O PONTO DEIXA DE
   PASSAR TUDO**, e não se queixa; quem mexe no funil vai ver quem estava
   pendurado nele.
   ⚠️ **E `has()` NÃO CONTA DUPLICATAS, no relatório cujo assunto É a
   duplicata.** Na mesma régua, já corrigida, a contagem discordava dela
   própria — 49 pela subtração contra 42 pelo `has()`, porque um texto escrito
   duas vezes e apresentado uma contava por duas vistas. Onde o caso
   interessante é a repetição, a conta é de MULTICONJUNTO. E foi a discordância
   entre os dois métodos que a apanhou: **uma régua que responde à mesma
   pergunta por dois caminhos denuncia-se sozinha.**
   ⚠️ **PERCURSO RESPONDE PELO QUE SE VÊ; ARQUIVO RESPONDE PELO QUE EXISTE.**
   Uma régua que caminha pelo jogo só mede o que o caminho ALCANÇA, e isso não
   se nota porque ela publica um total grande. Medido em 21/09: dos sítios que
   pintam cor à mão, o percurso de 19 estados do `medir_contraste_ui.gd` não
   chega a três — o dia já vivido do calendário (ele abre no dia 1), a estrutura
   já construída (abre com o porto em ruínas) e a doca sob oferta do rival. O
   `COR_PASSADO` que o briefing entregou como CASO DE TESTE nunca esteve nos 214
   textos, e os 5,42:1 dele eram conta à mão. Antes de tratar um inventário em
   runtime como inventário, pergunte que estados ele NÃO monta.
   ⚠️ **E MUTANTE QUE SÓ UMA SUÍTE APANHA NÃO É SUÍTE A MAIS — é o que a
   outra não tem como ver.** Medido no R5 (`034`): dos três defeitos
   injetados na fila de mensagens, o de "interromper antes do tempo mínimo"
   reprovou **só** o bloco de aritmética pura. O bloco de integração drena a
   fila com passos de 99 s — ele pergunta o que chega à tela, não quando —, e
   é cego ao tempo por construção. Antes de dar um teste por redundante,
   pergunte que defeito ele vê que o outro não vê.
   ⚠️ **E A RÉGUA PRECISA DO MESMO DEFEITO INJETADO QUE O VALIDADOR — e precisa
   mais.** Um validador que nunca reprovou dá um verde de graça; uma régua muda
   dá um NÚMERO, e o número vira a conclusão da sessão. Em 14/09 a medição do
   raster da água devolveu "0,00% dos pixels mudam" — e uma régua que estivesse
   a comparar o arquivo consigo mesmo teria dito exatamente o mesmo. O que
   separa as duas coisas são duas corridas de dois segundos: **o mesmo arquivo
   dos dois lados tem de dar zero EXATO** (deu: Δ máx 0,00, o que prova que ela
   não tem ruído próprio), **e um par que se sabe diferente tem de dar muito**
   (o mapa do pátio deu 5,89% da janela e Δ máx 145). Só depois disso "zero"
   quer dizer zero.
   ⚠️ **E TEMPO COMPARA-SE EMPARELHADO, uma volta de cada.** O mesmo comando de
   geração deu 18,71 s de manhã e 22–23 s à tarde neste contêiner: **20% de
   deriva da máquina**, que é mais do que muita diferença que este projeto mede.
   Duas corridas soltas em horas diferentes comparam a carga, não o código.
   ⚠️ **E RECEITA DERIVADA QUE NÃO CASA NADA DÁ UM VERDE DE GRAÇA.** É a regra
   da amostra vazia com a roupa de um bloco de shell, e mordeu na sessão que a
   escreveu: o `/fechar-sessao` passou a derivar do `testes.yml` os comandos que
   regeram os mapas, o `grep` casou **zero** deles — no workflow eles estão
   partidos por continuações `\` —, nada correu, o `git diff` saiu vazio e isso
   leu-se como sucesso. **Conte o que a derivação achou antes de acreditar no
   silêncio dela** (`docs/decisoes/032`).
   ⚠️ **E NÚMERO PARTIDO POR UMA QUEBRA DE LINHA ESCAPA A TODO `grep` DE
   LINHA.** A prosa deste repositório quebra aos ~79 caracteres, então qualquer
   facto de vários tokens pode ficar a cavalo de duas linhas. Em 18/09 o sétimo
   sítio a repetir as taxas do balanceamento estava escrito `100,0% / 80,2%` +
   `/ 37,3%` — e sobreviveu a uma revisão externa E a uma varredura à mão,
   ambas feitas com `grep -n`. Régua que procura FACTO lê o arquivo inteiro com
   `\s*` a atravessar a quebra; e normalize a grafia, que `100,0%` contra
   `100%` abriu um segundo endereço sem a guarda ver.
   ⚠️ **E CONTAGEM QUE INSTRUI CONFERE-SE; CONTAGEM QUE NARRA FICA.** A regra
   irmã — *"contagem em prosa de lista que cresce tira-se"* — diz o que fazer;
   esta diz onde NÃO fazer. O `grep` por "as cinco suítes" dá dezenas de
   acertos e quase todos são história verdadeira (*"nenhuma das cinco suítes
   lia aquela linha"* descreve o dia em que eram cinco). Corrigi-los é
   reescrever o registo para ficar verde. Antes de trocar um número, pergunte
   se ele manda fazer alguma coisa.
   **E confira que o defeito injetado pegou.** Dois já não pegaram: um usou uma
   variável de ambiente que a sessão já trazia definida, e outro quebrou o
   GDScript de tal jeito que o passo anterior falhou calado e reaproveitou o
   arquivo da corrida antiga. Nos dois casos o validador "passou" sem nunca ter
   visto defeito nenhum — que é pior do que não o ter testado, porque agora há
   confiança.
   **E confira o `$?` do comando certo.** Em 02/09 um defeito injetado reprovou
   como devia e o `$?` deu 0: a corrida acabava em `| tail -3`, e o que se
   estava a medir era o `tail`. Redirecione para arquivo e leia o código de
   saída antes de olhar a saída — num cano, o `$?` é do último elo.
   **E confira que o defeito chegou a quem o havia de ver.** Em 03/09 baixou-se
   o `RUA_RECUO` para reproduzir o pátio estreito e o teste passou: o
   `gerar_mapa_iso.py` escreve as âncoras AO LADO do SVG, e o SVG tinha ido
   para `/tmp`. O teste leu a tabela antiga e nunca soube do defeito. Antes de
   concluir "o validador não pega", confira que o arquivo que ele lê mudou.
   **E CONTAGEM SÓ SE TESTA ACIMA DE UM.** Em 03/09 injetou-se um `break` que
   fazia o contador parar no primeiro trabalhador livre, e o teste passou: o
   porto abre com UM trabalhador e uma doca, e com esses números contar um e
   contar todos dá a mesma resposta. O bloco passou a montar três e dois.
   **E defeito injetado numa regra que existe em DOIS sítios nunca reprova.**
   No mesmo dia, tirar `if phase != "playing"` de `trabalho_parado()` não
   reprovou nada, porque `doca_aceita_trabalhador()` carregava a mesma guarda.
   Quando um defeito não pega, a primeira suspeita é que a regra esteja
   duplicada — e a correção é apagar a cópia, não reforçar o teste.
   **E confira QUAL guarda está a segurar a asserção.** Mordeu duas vezes em
   03/09, e não é a regra duplicada: são duas guardas DIFERENTES a proteger a
   mesma asserção, e a errada a segurar. Tirar o `not parcela_paid` de quem
   quita a dívida não reprovou nada, porque quitar deixa o caixa abaixo da
   parcela e a guarda do DINHEIRO fechava a porta no lugar dela; e tirar o
   teto de profundidade da marcha do caminhão não reprovou nada, porque o teto
   de gosto (42px) era mais apertado. Em ambos os casos a correção é montar o
   estado em que a guarda sob teste é a que APERTA — caixa de sobra, vizinho
   mais perto — e não reforçar a asserção.
   ⚠️ **E ASSERÇÃO RELACIONAL PEDE O ESTADO CERTO DO OUTRO LADO — «relacional»
   não é, sozinho, o contrário de «espelho».** Mesma armadilha com duas
   VARIAÇÕES no lugar de duas guardas. Em 22/09 o D34 perguntava se a seleção
   muda a borda do trabalhador comparando-a com o **repouso OBSERVADO**, e o
   mutante que matava o canal da cor **passou**: o HUD abre com trabalho
   parado, logo o repouso é o `TrabParado` de borda LARANJA, e pintar a
   seleção do verde do `TrabLivre` continua a diferir dele. Quem a seleção
   substitui é o cartão LIVRE — derivado, não suposto —, e contra ele o
   defeito reprova. **Antes de comparar dois estados, pergunte qual deles o
   estado sob teste REALMENTE substitui**, que quase nunca é o que a tela
   calha mostrar (`docs/decisoes/045`).
   ⚠️ **E «SUBSTITUI» TEM DUAS RESPOSTAS: a do RECURSO e a da MECÂNICA.** A de
   cima é a do recurso — a seleção veste o fundo do livre —, e está certa para
   o cartão. Para a TROCA que o jogador vê, a resposta é da mecânica: só se
   aloca com barco à espera, e aí o cartão é PARADO. Contra ele a borda mudava
   **1,33:1**, não os 2,26 publicados, e a foto da bateria mostrava a única
   seleção que não serve para nada (`050`). Pergunte de que lado está a
   pergunta antes de escolher o estado.
   ⚠️ **E QUEM PROVA QUE UM NÓ LARGA UM ESTADO PROVA-O NO MESMO NÓ.** A
   primeira guarda do reset do selo olhava o cartão depois de alocado, e o
   mutante sem o reset PASSOU: o `_refresh_workers()` RECRIA os cartões, e o
   nó novo nunca teve selo. O caminho em que o mesmo nó sai da seleção é o
   segundo toque, e é lá que a guarda vive (`050`).
   ⚠️ **E NEM TODA GUARDA NOVA PRECISA DE SER SUSTENTADORA — o que precisa é
   que a AFIRMAÇÃO ao lado dela seja verdadeira.** É o X1b/Y2b visto do outro
   lado: ali o par prova que a peça nova faz falta; aqui ele provou que NÃO
   fazia. No mesmo dia, o mutante com a guarda da derivação retirada reprovou
   na mesma por outras três, e o comentário que eu já tinha escrito — «sem
   esta linha as outras passariam contentes» — era falso. A guarda ficou,
   porque nomeia a CAUSA onde as outras nomeiam o sintoma; o comentário é que
   passou a dizer a verdade. **Comentário que atribui poder a uma asserção
   mede-se como se mede a asserção.**
   ⚠️ **E A PREVISÃO DE QUEM REPROVA «NO DIA EM QUE» MEDE-SE NESSE DIA.** O
   conferidor das capturas dizia que, com a lista de lacunas vazia, uma
   expressão partida só seria apanhada pela linha do catálogo vazio. Em 23/09
   a lista esvaziou e eu escrevi ao lado «medido, não suposto» antes de
   medir: quem reprovou foi outra guarda, sete vezes, e a linha calou-se
   (`053`). Comentário escrito no futuro é a forma mais barata de o ser falso.
   ⚠️ **E A GUARDA QUE ESCREVE ELA PRÓPRIA O ESTADO PROVA A LEITURA, NÃO A
   ESCRITA.** Para pôr um camião a meio da ré, a varredura do D35 marca-o como
   a sair à mão — e prova que a previsão lê a marca. O mutante que tirava a
   linha do JOGO que a escreve passou verde, porque a fixture fazia o trabalho
   dela. Quando o teste monta um estado que o jogo devia montar, a outra ponta
   — o jogo a escrevê-lo — pede a sua guarda (`052`). E um sub-bloco leva a
   sua BANDEIRA: um erro de execução lá dentro só aborta ele, e a bandeira do
   chamador ficava verde.
   ⚠️ **E CAMINHO QUE REPROVA CEDO ESCONDE O QUE OS OUTROS VERIAM.** O F11
   nasceu com três caminhos em fila num bloco só, e o primeiro vermelho saía
   do bloco: a primeira leva de mutantes deu UMA reprovação a cada um, e os
   outros dois caminhos nem tinham corrido. Separados, cada um com a sua
   bandeira, o M1 e o M4 reprovaram nos três — e só assim se pôde perguntar
   o que o terceiro vê de único (`054`). Antes de dizer que uma guarda NÃO
   reprova, confira que ela chegou a correr.
   **E confira que a base está LIMPA antes de injetar o defeito seguinte.** No
   mesmo dia, o `git checkout` que devolvia o arquivo entre um defeito e outro
   restaurou a versão anterior ao trabalho inteiro — e os três testes seguintes
   relataram, contentes, a mesma falha herdada. Nenhum deles provou nada. Entre
   um defeito e o próximo, rode o validador uma vez e exija que ele PASSE; e
   guarde o original com `cp`, nunca com `git`, que não sabe o que ainda não foi
   commitado.
   **E ASSERÇÃO QUE MONTA O ESPERADO DA MESMA FONTE DO DEFEITO NÃO TESTA
   NADA.** Em 06/09 o teste do sorteio de motivos montava a lista do que devia
   aparecer LENDO OS PESOS, e comparava com o que apareceu: pôr o peso de um
   motivo a zero tirava-o dos dois lados ao mesmo tempo, e a asserção passava
   contente com o motivo desaparecido do jogo. O defeito só reprovou depois de
   entrar uma pergunta que NÃO sai dos pesos — "todo motivo escrito na tabela
   chega ao jogo?", que é a irmã do `barco_medio` renderizado, validado e nunca
   posto em doca nenhuma. Antes de escrever o esperado, pergunte de onde ele
   vem: se vem de onde o defeito vai morar, o teste é um espelho.
   **E `mini` TROCADO POR `maxi` PODE PASSAR EM TUDO.** Em 06/09 a trava do
   nível do navio é `mini(nivel_pier(), nivel_guindaste())`, e trocar o `mini`
   por `maxi` não reprovou uma única asserção — porque em quase todo estado do
   jogo os dois níveis são IGUAIS, e aí min e max dão o mesmo. O estado que
   APERTA é um só: pórtico comprado e cais ainda não. Antes de dar um defeito
   por não pegado, pergunte em que estado as duas versões DIVERGEM — e monte
   esse estado, que costuma ser um só entre muitos.
   ⚠️ **E FUNÇÃO COM GUARDA NÃO É RAMO COM GUARDA.** Em 23/09 a
   `silhueta_do_trecho()` tinha duas asserções a perguntar-lhe trecho a trecho,
   e nenhuma passava o `de_re` — o argumento opcional que decide a ré do camião:
   apagar o ramo dele não reprovava nada. Antes de dar uma função por coberta,
   pergunte que ARGUMENTOS as asserções lhe passam; o que tem valor por omissão
   é, quase sempre, o que ninguém passa (`047`).
   ⚠️ **E ESSE ESTADO PODE SER O QUE O JOGO NÃO FAZ — aí a fixture REALISTA é a
   que não prova nada.** A regra acima manda montar o estado em que as duas
   versões divergem; esta diz o que fazer quando ele é justamente o estado raro.
   Em 17/09, na Leitura do simulador, trocar PONTOS percentuais por diferença
   RELATIVA não reprovou asserção nenhuma: com o Ótimo a 100%, `100 − 30 = 70` e
   `(100 − 30)/100 = 70%` dão o mesmo número — e o Ótimo a 100% é o jogo de
   hoje. O defeito só cai com o Ótimo FORA do teto (a 80%: 50 pontos contra
   62,5%), que é um estado sintético de propósito. **Fixture copiada da medição
   real é a mais fácil de escrever e a que mais vezes calha no ponto cego**;
   depois de a escrever, calcule à mão o que o defeito daria ali e exija que os
   dois números sejam diferentes.
   **E confira que quem reprovou foi a guarda que se estava a testar.** No
   mesmo dia, o primeiro defeito injetado nesse sorteio reprovou — pela
   asserção dos PESOS, que somam 100 e denunciam qualquer peso mexido. A do
   conjunto, que era a que se queria provar, nunca chegou a ser exercida. O
   defeito seguinte teve de mexer em dois pesos ao mesmo tempo, para a soma
   continuar em 100 e só a guarda certa poder reprovar.
   **E o defeito pode pegar e o teste passar na mesma.** Aconteceu em 02/09:
   tirar `tests/*` do filtro de export não reprovou nada, porque o teste
   perguntava `contains("tests/*")` e o `scenes/tests/*` que ficou no arquivo
   contém essa string. Num arquivo de configuração, `contains()` quase nunca é
   a pergunta que se quer fazer — separe a lista e compare ITEM a item. Vale a
   mesma desconfiança ao ler chave de config: uma linha dentro de um
   COMENTÁRIO satisfaz uma busca no arquivo inteiro.
   ⚠️ **E NÚMERO DE TURNO CRAVADO NUMA ASSERÇÃO REPROVA O CÓDIGO CERTO.** É a
   regra do "número em pixel escrito à mão" que este arquivo já carrega, com o
   CALENDÁRIO no lugar do tamanho. O bloco 7b do `run_tests.gd` amostrava o
   desconto da parcela em `[4, 12, 20, 28, PARCELA_DUE_TURN]`, e aqueles 28 são
   o penúltimo turno de uma semana de OITO: com `TURNS_PER_WEEK = 7` o prazo
   passa a 28, a lista fica com o vencimento DUAS vezes, os dois custos saem
   iguais e a asserção reprova uma mudança que estava certa. **Amostrar um
   intervalo derivado custa o mesmo que percorrê-lo inteiro** — e percorrer não
   crava nada, além de cobrir os turnos que a amostra saltava.
   ⚠️ **E A SAÍDA DAS FERRAMENTAS DESTE PROJETO É UM CONTRATO — a mensagem
   nova pode colidir com uma sentinela.** Aqui quem decide aprovação é uma
   STRING na saída e não o código de saída, e de propósito: a linha final de
   cada suíte, `(Tela|Folha) salva em` no `capturar_evidencia.sh`, `=== Leitura
   ===` e `possível travamento` no CI, `FORA` no `projetar_parcelas.py`. Em
   12/09 uma linha NOVA que anunciava uma exclusão legítima dizia "FORA DO
   PORTÃO" e reprovou o projetor inteiro — código 1 a dizer que o modelo não
   calibra, quando ele calibrava. É a regra acima do outro lado: ali a busca
   achava o que não devia num ARQUIVO, aqui numa MENSAGEM que se acabou de
   escrever. Antes de imprimir texto novo numa ferramenta, procure que strings
   alguém procura na saída dela.
   ⚠️ **E UM MARCADOR NOVO PODE CONTER UM VELHO POR DENTRO.** Em 21/09 a régua
   do sinal de áudio ia chamar-se `MEDIDA DE AUDIO OK` — e essa string CONTÉM
   `AUDIO OK`, que é exactamente o que o passo do `teste_audio.gd` procura no
   `testes.yml`. Duas ferramentas diferentes a satisfazer o mesmo `grep`: o
   passo do encanamento passaria a ficar verde com a régua do sinal, e ninguém
   veria. Ela chama-se `SINAL OK`. **Marcador novo confere-se por SUBSTRING
   contra os que já existem**, não por ser um nome diferente.
   ⚠️ **E GUARDA DE «NÃO HOUVE ERRO» ESCOLHE-SE MEDINDO O QUE A CORRIDA
   SAUDÁVEL IMPRIME.** O marcador diz que a ferramenta chegou ao fim; não diz
   que ela não se queixou pelo caminho, e o Godot encerra com 0 nas duas
   situações. Só que a guarda óbvia — `grep ERROR` — reprovaria quase tudo o
   que está certo: medido em 18/09, em corridas VERDES, **cinco das seis
   suítes** e o simulador encerram com `ERROR: 1 resources still in use at
   exit` — e no simulador isso sai DEPOIS do marcador —, e o `teste_fumaca`
   imprime um `ERROR: Parse JSON failed` **de propósito**, que é o save
   inválido que ele injeta para provar que o jogo o recusa.
   ⚠️ **E O PREFIXO NÃO SEPARA AS CLASSES:** medido numa sonda, `push_error()`
   sai como `ERROR:` e não como `USER ERROR:` — a queixa da FERRAMENTA tem o
   prefixo do barulho do MOTOR. Quem separa é a ORIGEM, escrita na linha `at:`:
   só quem chamou `push_error` traz `at: push_error (`. O par das SUÍTES é
   `SCRIPT ERROR|at: push_error \(`, e quem DERIVA do workflow a lista de quem
   o tem é `tools/conferir_guardas_ci.py` — ela era escrita à mão, e foi por
   isso que faltou em cinco dos onze passos (`docs/decisoes/031`).
   ⚠️ **E SÃO TRÊS FORMAS, NÃO DUAS — o par das suítes conhece duas.** Medido
   em 21/09, uma sonda por forma: `push_error()` e o erro de EXECUÇÃO trazem
   ambos o bloco `GDScript backtrace`; o erro de COMPILAÇÃO traz `SCRIPT ERROR`
   e NÃO traz backtrace (`at: GDScript::reload`); e a **chamada falhada** —
   `Error calling method from 'callv'` — sai como `ERROR:` com `at:` em C++ e
   backtrace, porque quem se queixa é o MOTOR sobre uma chamada que o NOSSO
   script fez. Nenhum dos dois padrões a apanha, e foi assim que o `PainelCaixa`
   saiu PRETO com a bateria verde. Quem escreve a origem é o Godot, no bloco do
   backtrace — o ruído de encerramento não o tem. A **bateria de captura** varre
   hoje `SCRIPT ERROR|GDScript backtrace`, e as suítes NÃO: o `teste_fumaca`
   imprime de propósito um erro de JSON que traz backtrace, e alargar lá poria
   uma suíte verde a vermelho (`docs/decisoes/038`).
   ⚠️ **E A QUARTA FORMA DE FALHAR É NÃO ACABAR.** Chamada com o número errado
   de argumentos dentro do `_process` de um `SceneTree` ABORTA a função, e um
   `--script` que aborta antes do `quit()` repete o `_process` a cada frame e
   NUNCA ENCERRA — sem log, sem foto e sem uma palavra. É a irmã da regra do
   teto de voltas do laço de turnos, um andar acima: no CI aquilo não é
   vermelho, é o job a morrer de timeout sem dizer qual passo foi. Toda bateria
   de ferramentas leva teto de tempo POR TIRO (`timeout 180` no `tirar()`).
   ⚠️ **E O ESCOPO DA GUARDA É O ESCOPO DO DEFEITO.** A primeira versão desse
   portão exigia a varredura de todo arquivo de um passo que rodasse
   `--script`, e reprovou a saída de um leitor em **Python** — onde uma exceção
   sai com código ≠ 0 e o `set -e` apanha. Sair com zero depois de um erro é
   problema do Godot e só dele. Antes de alargar uma guarda ao passo inteiro,
   pergunte de QUE ferramenta é o defeito que ela caça.
   **E TESTE QUE LÊ ARTE GERADA LÊ O ARQUIVO, NUNCA O `load()` DA TEXTURA.**
   `load("res://art/porto_mapa_iso.svg")` devolve o `.ctex` de
   `.godot/imported/`, que é de quando o projeto foi importado: com o mapa
   regerado na mesma sessão, o D20 reprovou a apontar para um defeito que já
   tinha sido corrigido — verdadeiro, e de ontem. Rasterize o arquivo
   (`load_svg_from_string`, que é o mesmo ThorVG); o cache do importador é uma
   resposta velha, e num teste isso mente nas duas direções.
   ⚠️ **E FOTO ADIANTADA É PIOR DO QUE FOTO ERRADA, porque parece um defeito
   do que se acabou de construir.** É a regra dos dois frames com a roupa de
   uma captura. Em 19/09 o tiro novo do histórico de mensagens abria o painel
   na mesma volta em que o laço de turnos acabava: a lista saía com CINCO
   entradas enquanto a faixa por trás já anunciava "+7", porque três falas
   daquele turno ainda estavam em `call_deferred`. A foto era verdadeira do
   instante em que foi tirada e mentia sobre o sistema. **Ferramenta que
   fotografa depois de agir espera o que a ação deixou pendente** — e num
   projeto onde a fala entra por `call_deferred`, esperar é medido em frames.
  ⚠️ **E VALE IGUAL PARA A CAPTURA: regerou arte, `--import` ANTES de
  fotografar.** Em 13/09 duas rondas de retratos foram fotografadas ao asset
  VELHO — o Godot desenha o `.ctex` de `.godot/imported/`, e a foto saiu
  bonita, verdadeira na aparência e sobre o desenho de antes. É pior do que
  não fotografar, porque se passou a discutir o que já estava corrigido.
   **E "TODOS APARECEM" NÃO IMPLICA "NA ORDEM CERTA", nem o contrário.** Duas
   guardas sobre a mesma tabela e nenhuma delas de graça: uma conta pode
   devolver os três portes de barco ao CONTRÁRIO e cumprir a alcançabilidade,
   e pode manter a ordem perfeita alcançando só dois. Quando duas perguntas se
   parecem, o teste é montar o estado em que UMA falha e a outra passa; se esse
   estado não existir, a segunda é confiança de graça — e se existir dos dois
   lados, são duas asserções e não uma.
   ⚠️ **E MÉTRICA DE FORMA LIDA DE NÚMERO PUBLICADO MEDE O ARREDONDAMENTO.**
   Em 14/09 a guarda nova da costa (D28) media "a maior reta" juntando segmentos
   cujo ângulo batesse a menos de meio grau — e o defeito injetado, a costa de
   volta à escada, **não a reprovou**: a tabela publica pixel com UMA casa
   decimal, e meio pixel de arredondamento num segmento de 6,7 px vale 0,43
   grau. Cada par de segmentos colineares parecia dobrar, e a reta de 224 px
   saía partida em trinta. O que reprovou foi a asserção da QUINA, ao lado — a
   armadilha do "confira QUAL guarda reprovou" com outra roupa. A métrica que
   pega é a de uma **régua pousada em cima do desenho**: até onde ela vai sem
   que a linha se afaste mais de um pixel dela. Antes de medir forma, pergunte
   quanto ruído o número que se vai ler já traz consigo.
   ⚠️ **E PROVA DE FRONTEIRA POR PRIMEIRA TRAVESSIA NÃO SOBREVIVE AO ENFEITE.**
   No mesmo bloco, a asserção que procurava a borda da água atravessando a linha
   de 1 em 1 px reprovou o mapa CERTO por 9 px: sobre a rampa da praia pousam
   pedras cinzento-azuladas, e a varredura vinda da areia dava a água por
   começada em cima da primeira delas. Fronteira mede-se por **contagem** (uma
   pedra de dois pixels desloca o total em dois) e não pela primeira amostra que
   troca de lado — e quando nem a contagem separa, a asserção pode simplesmente
   não valer o que custa: aquela foi construída, medida e RETIRADA, depois de se
   confirmar que o defeito que ela caçava reprovava noutra pergunta.
   ⚠️ **E UM CORTE COLADO A UMA PONTA DA BANDA MEDIDA É SORTEIO.** A irmã das
   duas regras abaixo, e a mais fácil de cometer depois de medir bem: em 14/09 a
   janela nova do D20 dava **5** px no mapa certo e **42** com o defeito
   injetado, e o corte que eu tinha escolhido era **41** — reprovava por UM
   pixel. O número estava medido e mesmo assim não servia. Quando os dois lados
   estão medidos, o corte vai para o MEIO da banda, e diz-se a folga que ficou
   de cada lado (4x e 2,1x).
   ⚠️ **E NÃO SE APERTA O TETO DE UMA GUARDA ATÉ ELA APANHAR UM SEGUNDO
   DEFEITO.** É a irmã do "portão alimentado com fumaça", do outro lado: ali a
   tolerância era folgada demais para o ruído do número; aqui é a tentação de a
   fechar até o defeito seguinte cair dentro. No D29 (14/09) o primeiro defeito
   reprovou os oito cascos e o segundo só UM; baixar o teto de 62% para 57%
   apanharia seis dos oito — e deixaria o arrasteiro BOM a passar por dois
   pontos, o que é vermelho na primeira vez que alguém mexer num casco. O teto
   ficou onde estava. **Uma guarda defende o que defende; o que não se pode é
   fingir que ela defende mais** — escreva ao lado dela o que fica de fora, e
   quem prova o resto é a medição registada. Nem tudo o que se mede precisa de
   asserção.
   ⚠️ **E DUAS PROTEÇÕES DIFERENTES PEDEM UM DEFEITO QUE QUEBRE AS DUAS.** Não é
   a regra da "regra duplicada", é o contrário dela: ali a correção era apagar a
   cópia, aqui as duas guardas defendem coisas distintas e ambas são precisas. A
   areia não chega à pista por DOIS motivos — o recuo do mundo põe-na longe, e a
   ordem de desenho põe a rua por cima —, e em 14/09 quebrar cada um sozinho não
   reprovou nada. Antes de dar uma asserção por morta, conte quantas coisas
   diferentes impedem o defeito de chegar até ela.
   ⚠️ **E COR MISTURADA NUNCA CASA COM UM TOM PUBLICADO.** Na mesma caça, o
   defeito das manchas secas não pegou porque elas saem a `opacity="0.45"`: a
   asserção da areia do D20 só apanha areia OPACA, e isso nunca estava escrito.
   Quando um defeito de COR não pega, pergunte primeiro se o que ele pinta chega
   ao pixel puro.
   **E ANTES DE CULPAR A MUDANÇA, MEÇA A VERSÃO ANTIGA COM O MESMO DEFEITO.**
   A janela nova do D20 não apanhava a areia e a suspeita óbvia era a janela.
   Baixar o mínimo a 1 — mais sensível do que o pixel único que lá estava —
   continuou a dar zero, o que prova que a limitação é ANTERIOR e que a mudança
   não perdeu poder nenhum. É barato, e é a diferença entre registar um achado e
   reforçar um teste às cegas.
   **E DEFEITO INJETADO LONGE DA LINHA AMOSTRADA NÃO CHEGA A ELA.** Um bloco
   que percorre um caminho só vê o que o caminho cruza. Pintar a passadeira com
   a cor da calçada não reprovou o D20 e não foi falha dele: com passo
   `RUA_LARG/8`, a barra n.º 6 acaba em `dentro + 1,35`, que é ao milésimo a
   faixa por onde o camião anda — o defeito passou rente. Ao injetar num teste
   que amostra uma linha, ponha o defeito EM CIMA dela.

---

## As regras que já custaram trabalho

### Projeção isométrica — é um contrato entre três arquivos

`tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py` e `brport_vs/scenes/Main.tscn`
têm de concordar. As constantes: `MEIA_LARG=30`, `MEIA_ALT=15` (razão 2:1),
`ZOOM=2/3`, câmera do Blender a `ROT_X=60°`, `ROT_Z=45°`, `ESCALA_ORTO`
derivada delas.

- **São DOIS espaços desde 05/09, e a fronteira é `tela()`.** O mapa DESENHA a
  30 num quadro de 1080 e o `viewBox` do SVG entrega 720 — a câmera é o `ZOOM`,
  e o `MEIA_LARG` efetivo é 20. Quem desenha fala DESENHO; a tabela de âncoras,
  o `Main.tscn`, o `Main.gd`, o manifest BRP e o teste de design falam TELA.
  ⚠️ **E A TEXTURA JÁ NÃO TEM O TAMANHO DO ESPAÇO TELA.** Os quatro SVG de mapa
  declaram `width="720"` sobre `viewBox` de 1080, e o importador rasteriza pelo
  `width`: até 14/09, com `svg/scale=1.0`, o desenho existia a 1080 e chegava à
  textura a 720, que o `canvas_items` voltava a ampliar 1,5× no aparelho — uma
  redução seguida de uma ampliação. Hoje eles importam a **1,5** e os três nós
  de mapa têm `expand_mode = 1`, de modo que o rect continua com 720 de
  COORDENADAS e a textura carrega 1080 PIXELS (`docs/decisoes/025`). Logo, o
  espaço TELA continua a ser 720 e é isso que a tabela de âncoras publica; quem
  amostra a textura por coordenada de tela tem de escalar, e quem o faz num
  lugar só é o `_mapa_lido` do teste de design.
  ⚠️ **E SUBIR O `svg/scale` REMOVE UMA REDUÇÃO — NÃO AMPLIA UM DESENHO.** Desde
  14/09 os quatro mapas importam a **1,5** e a textura sai com os 1080 que o
  arquivo já tinha (`docs/decisoes/025`). A armadilha que o plano previa — *"a
  1,5x um traço de 1 px passa a 1,5 e um vinco calibrado para quase sumir
  reaparece"* — **não vale aqui**, e a conta diz porquê: um `stroke-width` está
  em unidades do `viewBox` de 1080, e num telefone de 1080 ele media 1,6 px
  físicos antes (rasterizado a 1,067 e ampliado pelo `canvas_items`) e mede os
  mesmos 1,6 px depois, agora nítidos. Ela vale para a alavanca **B**, que
  redesenha props nas unidades da SAÍDA. Antes de varrer constantes em pixel por
  causa de uma mudança de escala, pergunte se o que mudou foi o DESENHO ou só a
  amostragem dele — e confirme na medição: se o desenho tivesse sido ampliado, a
  rampa de cada fronteira ocuparia 1,5x mais pixels; ela ficou 14,3% mais
  estreita.
  ⚠️ **E O MAPA TEM DUAS CAMADAS COM ESCALAS DIFERENTES.** O campo de cor da
  água é um PNG de **720x720 embutido** no SVG, esticado sobre o `viewBox` de
  1080: são **43% da janela** onde a precisão que falta não está no arquivo, e
  nenhum `svg/scale` lha dá. Ele melhora na mesma, por outra razão — deixa de
  fazer três reamostragens e passa a fazer uma —, e não se denuncia porque
  desenha campo CONTÍNUO. Medir o quadro todo de uma vez misturaria o ganho do
  vetor com o zero do raster; a máscara sai de rasterizar o SVG uma segunda vez
  sem a `<image>`.
  ⚠️ **E ELE FICA A 720 — construído a 1080, medido e REJEITADO** (`026`).
  **Resolução só se paga onde há FRONTEIRA para afiar**, e este raster não tem
  nenhuma: é uma rampa contínua da distância à costa, e tudo o que tem traço
  naquela água — pedras, espuma, riscos de onda, linha de areia — é VETOR, e já
  ganhou na alavanca A. A 1080 o pico da fronteira não se mexe (29,73 → 29,71) e
  o maior Δ de canal na janela é **4/255**, com ZERO pixels a chegarem ao piso
  de Weber — por 1,8x o tempo de geração dos dois mapas grandes. **"43% da
  janela" e "2,25x de pixels" são verdade e não querem dizer nada:** a pergunta
  nunca é quantos pixels a camada tem, é que fronteira há dentro dela.
  ⚠️ **E A BATERIA DE 720 NÃO RESPONDE À PERGUNTA DA RESOLUÇÃO.** Ela é travada
  a 720x1280, e a 720 a textura de 1080 é reduzida pela GPU de volta a quase o
  que era. O antes/depois honesto é a **1080x1920** — 1,5x exato nos dois eixos.
  E o aparelho pequeno foi medido e **melhora**: o downscale de 1,5:1 age como
  supersampling parcial, com os pontos soltos a caírem de 3,10% para 2,90% das
  fronteiras.

  **A razão de não escrever 20 na constante:** altura, naquele arquivo, é
  PIXEL — o `ALT_CAIS`, as paredes da vila, a largura de cada traço —, e baixar
  só o `MEIA_LARG` encolheria a PLANTA deixando as ALTURAS paradas, com o porto
  esticado 1,5× para cima e nenhuma das cinco suítes a lê-lo. Escala-se no
  GRUPO, que é a mesma regra dos props.
- **O prop não tem `viewBox`: quem o encolhe é o `ortho_scale`, e só ele.** O
  `z()` continua na escala de DESENHO de propósito — o fator de altura e o
  `ortho_scale` cancelam-se, e mexer nele levantaria cada prop 1,5×. Afastar
  uma câmera não estica o que ela filma.
  ⚠️ **E O PROP TEM DUAS MEDIDAS DESDE 16/09: 512 de COORDENADA e 768 de
  PIXEL** (`docs/decisoes/029`, a alavanca B). O `ESCALA_ORTO` sai do
  `RESOLUCAO_TELA` e NÃO do `RESOLUCAO` — presos um ao outro, a câmera
  afasta-se na mesma proporção em que o quadro cresce e a alavanca entrega
  256 px de moldura vazia em vez de um pixel de desenho. Quem desfaz a
  diferença é `expand_mode = 1` nos 31 nós de prop (a mesma linha dos três nós
  de mapa), a `scale` que o `Fauna.gd` escreve nos seis `Sprite2D`, e o
  `PropIso` para toda régua que leia `get_used_rect()`. O **D31** tranca-o.
  ⚠️ **E A ALAVANCA B NÃO REDESENHA NADA, ao contrário do que o item previa.**
  A previsão era que "os props são desenhados nas unidades da SAÍDA", logo todo
  número em pixel do gerador teria de ser varrido. Medido: a geometria dele
  está em unidades de MUNDO (`chanfrar()` 0,020; `TABUA` 0,30; o ruído), e os
  "31px na tela" dos comentários são OBSERVAÇÕES do que esses valores produzem,
  não entradas. Com o `ortho_scale` parado, o mesmo mundo é amostrado mais
  fino: pelo `comparar_props.py`, que reduz os dois a 16×16 e é cego à
  resolução, **51 dos 61 props medem no máximo 0,0059** — contra 0,022 de um
  pixel de deslocamento e 0,42 de um prop trocado por outro. É a mesma razão
  estrutural pela qual a A também não a encontrou: **antes de varrer constantes
  por causa de uma mudança de escala, pergunte se o que mudou foi o DESENHO ou
  só a amostragem dele.**
  ⚠️ **E OS QUATRO QUE MUDARAM NÃO DESMENTEM ISSO — DENUNCIAM OUTRA COISA.**
  Três retratos do Sr. Ribeiro mediram 0,08 porque a GRAVATA e a CAMISA
  estavam coplanares, e a resolução mais fina passou a desenhar o empate: a
  gravata saía partida ao meio, escura em cima e rosa lavado em baixo. O
  defeito era de 01/09 e o que o revelou foi a alavanca. **Subir a resolução
  não cria geometria degenerada: tira-lhe o disfarce** — e quem o apanhou foi
  a régua que compara levas, não suíte nenhuma.
  O que a alavanca envelheceu foi o outro lado: os números em pixel de quem
  MEDE o PNG — `MEIO_QUADRO`, o pivô da lança, a régua da pessoa de 15 px, o
  `D29_LARG_MIN`, o `ZOOM` das duas folhas de contato.
  ⚠️ **E RESOLUÇÃO PAGA-SE NO QUADRO INTEIRO E ENTREGA NO DESENHO.** É a irmã
  da regra da `026` — *"só se paga onde há FRONTEIRA para afiar"* — do lado do
  CUSTO em vez do ganho. Medido nos 61 props: **o desenho ocupa 10,4% do
  quadro, e 89,6% é moldura vazia** (o poste 0,04%, o píer 7,4%; só os dez
  retratos passam de metade). Daí a B custar **+80 MB de VRAM e +42,3% de
  `.pck`** para mudar 1,56% da janela, contra os +9,89 MB e 5,12% da A — **15 a
  27 vezes o preço por pixel visível**, e nenhuma das duas medidas mente.
  Antes de subir a resolução de um asset, meça que fração dele é desenho: o que
  torna esta alavanca barata é CORTAR o quadro.
  ⚠️ **E CORTOU-SE SEM MEXER NO QUADRO** (`049`): o importador `texture_atlas`
  apara a moldura e a MARGEM do `AtlasTexture` repõe os 768, logo nenhum nó,
  âncora ou manifest mudou — a VRAM de textura em jogo foi de 235,68 a 64,04
  MB e o `.pck` perdeu 17,4%. O briefing previa `bpy` e os 69 regerados porque
  lia o quadro como ARQUIVO; a pergunta era o quadro na VRAM. **Antes de pagar
  um contrato novo, pergunte se o motor já separa o que o arquivo junta.**
  ⚠️ **E O EMPACOTADOR ARREDONDA A LARGURA A POTÊNCIA DE DOIS:** um retrato de
  510 px sai num atlas de 1024, 26% pior do que o quadro. Os retratos ficam
  fora, e quem o decide é o validador (atlas mais caro do que o quadro
  reprova), não uma lista.
  ⚠️ **E PROP NOVO ENTRA PELO IMPORTADOR POR OMISSÃO**, que o validador
  reprova. A receita: o `.import` dele passa a `texture_atlas` (a forma está em
  qualquer vizinho — conserve o `uid` do próprio arquivo), o `--import` corre
  **DUAS vezes** (a primeira escreve o atlas em `art/props/_atlas/`, a segunda
  importa-o) e o atlas e o `.import` dele vão no commit. Sem eles, o import
  único do CI deixa o `preload` a apontar para um atlas por importar.
- **Constante em PIXEL é constante que envelhece quando o `ZOOM` muda, e ela
  não dá erro.** Foram cinco em 05/09: a silhueta do caminhão e o corte que
  exige pegada no teste de design, a largura de telhado da vila, os sprites do
  pátio e o avanço da espuma. Duas reprovavam o que estava certo; **uma deixou
  de reprovar seja o que for** — o corte de 130px passou a ficar acima de todos
  os props, e a asserção que exige pegada nunca mais teria exigido nenhuma.
  Ao mexer na câmera, procure todo número medido em pixel e pergunte de que
  escala ele é.

- **Altura é em PIXELS DO MAPA**, não em unidades do Blender. A conversão está
  em `z()` num lugar só. Ignorar isso põe um píer 2,4× mais alto que o cais
  desenhado ao lado.
- **`pos()` inverte o sinal de Y.** No Blender a direita da tela é (+X, +Y);
  no mapa o `+my` puxa para a ESQUERDA. Um prop simétrico não denuncia a
  diferença — o primeiro assimétrico saiu 40px fora.
- **⚠️ E A PROJEÇÃO ESPELHA O CHÃO: DIREITA E ESQUERDA PERGUNTAM-SE À TELA.**
  Com `mx` e `my` lidos como o `x` e o `y` de um caderno, quem desce em `+my`
  tem a água à direita; na tela tem a VILA. Dezasseis dias de camiões na mão
  inglesa com o comentário a jurar a brasileira, e as retas e os cotovelos
  escritos com a regra de sinais opostos — daí as duas rotas se cruzarem em
  dez pontos (`052`). Mão, sentido de volta e "à direita de" escrevem-se como
  CONTA — o vetor projetado contra a direita do sentido projetado, `(-hy, hx)`
  com o `y` para baixo —, e é assim que o D13 §7g a pergunta.
- **O quadro de todo prop tem 512 de COORDENADA e o centro dele é a origem do
  mundo.** Posicionar um prop na cena é subtrair meio quadro, não acertar no
  olho — e desde 16/09 meio quadro são **256 na cena e 384 no PNG**, que até
  aquele dia eram o mesmo número (`029`). Toda régua que leia a textura e
  responda em coordenada passa pelo `PropIso`.
  ⚠️ **E O `get_image()` DE UM PROP DE MAPA JÁ NÃO É O QUADRO** (`049`): num
  `AtlasTexture` ele devolve a REGIÃO, com o canto em (0, 0), e uma régua que
  lesse o `get_used_rect()` dela apontaria 300 px ao lado. Pixel de prop lê-se
  por `PropIso.imagem()`. E **um `AtlasTexture` por cima de outro não
  compõe**: o `get_image()` do conjunto dá o desenho e o `draw` desenha a
  margem vazia — recorte-se do atlas de BAIXO (`PropIso.recorte()`).
- **E desprojetar um prop de volta ao mundo pede a ALTURA em que ele pousa.**
  Quem está em terra pousa a `ALT_CAIS`; quem está na água, a 0 — é o que o
  `_origem`/`_mundo` do teste de design faz. Desprojetar tudo a 0 desloca cada
  prop de terra em **+0,87 em mx E em my**, o que é pouco para se notar e
  suficiente para mudar a que DEGRAU ele pertence. Custou uma tabela inteira
  de posições errada em 04/09, e ela parecia plausível.
- **Mas REESCALAR a projeção é uma semelhança, e aí a altura cancela-se.**
  Desprojetar num espaço e reprojetar noutro dá `novo = P + (velho − Q) × ZOOM`
  — a altura entra e sai, desde que o `alt_cais` encolha junto com a câmera.
  A regra acima continua a valer para ler o MUNDO de um prop; para mover 37
  props de uma escala para outra ela não muda nada, e saber isso é a diferença
  entre uma migração de uma linha e uma tabela feita à mão. O que prova que
  correu bem é a âncora: as três docas têm de cair a 0,00 px do que a tabela
  publica.
- **⚠️ DUAS PEÇAS À MESMA ALTURA NO MUNDO NÃO ESTÃO À MESMA ALTURA NA IMAGEM,
  se estiverem a FUNDOS diferentes.** Nesta câmera cada unidade de
  profundidade vale meia unidade de altura na tela, então uma placa na face da
  frente (`y = -fundo/2`) desce meia profundidade em relação a uma peça no
  meio (`y = 0`). Medido nos retratos de 13/09: a gola pousada na face do peito
  saiu a FLUTUAR dez pixels abaixo do pescoço, com um buraco de blusa pelo
  meio, e a conta do mundo dizia que estavam encostadas. Peça que tem de
  ENCOSTAR noutra partilha o fundo dela — a gola virou uma caixa à volta do
  pescoço. É a irmã da regra do chanfro a 45°: ali a folga esticava-se na
  diagonal, aqui a altura desloca-se com a profundidade.
- **E NUMA PEÇA QUE ENVOLVE OUTRA, É O FUNDO QUE DECIDE QUEM SE VÊ.** A gola
  dos três retratos tinha 50 de fundo e o degrau do ombro 68: a face da frente
  do degrau fica nove pixels à FRENTE da dela, e o colarinho claro das três
  personagens simplesmente não aparecia no render — sem erro nenhum, só um
  pescoço sem gola. Quem tem de ser visto é mais fundo do que o que o rodeia.
- **E pela mesma conta a profundidade projeta-se para CIMA: cortar fundo não
  achata, tira TELHADO.** O primeiro busto tinha 96 de fundo na cabeça e 104 no
  cabelo, e saiu um capote a comer o quadro com a cara lá em baixo. Encolher o
  fundo devolveu o espaço à face — e não emagreceu nada, porque o que se via
  daquele fundo era a face de cima.
- **Só as faces `+x` e `-y` são visíveis** por esta câmera. Detalhar as outras
  é render que ninguém vê.
- **E o `-x` É O FUNDO DA IMAGEM, o que é outra pergunta.** A regra acima diz
  que FACE se vê; esta diz que PONTA do prop fica à frente. Peça alta em `-x`
  projeta-se para cima e para trás, e o que estiver baixo atrás dela desaparece:
  o arrasteiro nasceu com a casa do leme a meia-nau e o arrasto todo a `-x`, e o
  tambor de rede saiu invisível com o pórtico a ler como parede ao fundo. Ao
  compor um prop com um lado que trabalha e um lado que não, o que se quer VER
  avança para `+x` — e vale a pena perguntar se a coisa de verdade também é
  assim, porque muitas vezes é (um arrasteiro tem mesmo a ponte à frente).
- **Ordem de nó É profundidade.** Quem tem `mx+my` maior está mais perto da
  câmera e tapa quem tem menor. Vale em `Dock.tscn` e em `MapaWrap/Cenario`.
  O teste de design confere isto.
- **⚠️ CHANFRO A 45° INFLADO PELA FOLGA AFASTA-SE `√2` VEZES MAIS.** Vale para
  toda peça que exista em versões concêntricas — asfalto, meio-fio, calçada. A
  esquina inflada de `folga` em `mx` E em `my` põe a reta a 45° a `folga · √2`
  da original, não a `folga`: medida no render, a faixa de passeio saltava de
  **3,9 px** nas retas para **8,8 px** em cima do bisel, e lia-se como um muro.
  Recuar o corte de `folga · (2 − √2)` acerta. Sobra 1,58×, e essa parte não se
  corrige: em isométrico a direção (1,1) comprime-se e a (1,−1) estica-se, logo
  **faixa de largura constante NO MUNDO não tem largura constante NA TELA** — e
  igualá-la seria escrever pixel dentro de geometria de mundo, que é a fronteira
  que o `tela()` existe para não deixar atravessar.
- Mexer na projeção **obriga** a regerar props e mapas e a rodar o teste de
  design — que existe exatamente para pegar essa divergência.

### Tudo o que vive em terra é medido A PARTIR DA BEIRA DO CAIS

O cais avança 4 unidades por degrau. O que não avança com ele sai do
enquadramento: a rua e as casas ficariam a 4 unidades da água no primeiro
degrau e a 16 no último. `APRON`, `RUA_RECUO`, `VILA_RECUO` são recuos, não
`mx` absoluto.

### Save

`SAVE_VERSION` sobe **sempre** que a forma do estado muda. Save de outra
versão é descartado, não adaptado. Já custou um porto com 4 docas num mapa que
desenha 3.

**E recusar é recusar sem ter tocado em nada.** O `load_game()` escrevia os
campos um a um e só conferia a sanidade do roster no fim: um save recusado
deixava o `turn` e o `cash` do arquivo no estado vivo, com zero docas. Passava
despercebido porque o `new_game()` que vem a seguir por acaso reescreve todos
os campos — uma segurança que dependia de duas funções distantes continuarem a
concordar sobre a lista de campos, e que um campo novo teria quebrado calada.
**Tudo o que recusa vem antes de tudo o que escreve**, e o `teste_fumaca.gd`
tranca isso.

### Arte

- **Arte que chega de fora passa por `tools/conferir_lote_de_arte.py` antes de
  entrar.** Ele mede alfa e o ângulo da base contra os 26,57°. Dois lotes já
  vieram com o xadrez de transparência pintado nos pixels, e o de 31/08 vinha
  ainda com metade das peças noutra projeção.
  ⚠️ **E trabalho de fora chega com uma BASE: confira-a no GitHub antes de ler
  um número dele.** O pacote do ChatGPT de 23/09 foi feito sobre o PR #58 num
  checkout cujo HEAD o GitHub não conhece, com decisões `034`–`036` que colidem
  em número com as daqui e um galpão «aprovado» que só existe lá. O remendo
  aplicou limpo na `main` e o teste de design passou — sem nenhuma guarda a
  perguntar pela peça nova. Hoje o material dele vive em `art_lab/`, e a
  porta de entrada diz a base, a pasta e a prova de cada entrega.
- **Asset novo sai de `blender/gerar_brp.py`**, que partilha a câmera e o kit
  com `gerar_props_iso.py`. Nada de um segundo estúdio ao lado.
- **Prop no cenário nunca sai de gerador de imagem.** Duas levas perdidas: o
  gerador não erra o desenho, erra o ÂNGULO, e ângulo errado não se conserta
  rodando no Godot. Retrato em painel, sim; prop no mapa, não.
- **⚠️ A TÉCNICA DE UM ASSET É ESCOLHA DO BRUNO — o que a regra PERMITE não
  é o que ele escolheu.** Em 23/09, na frente dos retratos, a sessão julgou que
  o kit de caixas do Blender não chegava e desenhou nove retratos em VETOR,
  fotografados no jogo: *«não deveriam ter sido criados»*. Ele queria o
  Blender melhor. Protótipo não é neutro: gasta a sessão e empurra a escolha.
  Achou que a técnica em uso não alcança o pedido? **Pergunte qual, antes de
  produzir** — é a regra de paragem, com arte no lugar do `# TUNING:`.
- **O que troca de estado numa partida não pode estar assado no fundo.** Píer,
  armazém, escritório e pátio são props ou mapas alternativos. A vila é a
  exceção, e de propósito: ela troca entre FASES, não entre turnos.
- **E o estado ANTES não pode partilhar as peças do estado DEPOIS.** O
  `galpao_velho` reusava a lista de paredes do `galpao` — plinto, caixa branca
  limpa, portão fechado, calha e três janelas de vidro — e trocava só a cor do
  telhado. O porto abria "em ruínas" com um galpão de paredes novas, e a
  queixa que isso gerou foi "as construções parecem avançadas para um porto
  inicial". A regra certa já estava escrita ao lado, no comentário do
  escritório: **a ruína não é o prédio pintado de velho, é MENOS prédio** —
  parede caída, vidro nenhum, meio telhado. Partilhar peças entre dois estados
  poupa render e custa a leitura, que é o que o estado existe para dar.
- **E o estado DEPOIS precisa de vocabulário próprio, não só o ANTES.** É a
  mesma regra com o sinal trocado, e foi o que sobrou depois de a ruína ser
  consertada em 05/09: o armazém ACABADO continuou a ser desenhado só com o
  repertório doméstico — parede lisa, telha, `janela()` com moldura, a
  `porta()` do kit esticada — e lia-se como a maior casa da vila. Prédio que
  tem função no jogo precisa das peças DA FUNÇÃO: um armazém quer plataforma
  de carga, portão de enrolar, chapa corrugada e fita de vidro corrida.
- **⚠️ E REDUZIR UMA JANELA A UMA COR PEDE A MEDIANA, NUNCA A MÉDIA.** A regra
  acima diz que cor misturada não casa com tom publicado; esta diz como não a
  fabricar sem querer. A média de uma janela INVENTA um valor que não está no
  desenho — e que pode calhar na banda de uma terceira cor da paleta, como o
  pixel de antisserrilhado que reprovou o D20. O pixel MEDIANO por luminância é
  um pixel de verdade, e não se deixa mover por uma pedra, um risco de junta ou
  um tufo de capim dentro da janela (`docs/decisoes/027`).
- **⚠️ COPIAR O VALOR DE UMA COR QUE NÃO VIVIA DELE NÃO COPIA NADA.** Irmã da
  regra do matiz, logo abaixo, e do outro lado dela. O telhado de zinco do
  armazém foi escolhido para ter a luminância do telhado de telha (108 contra
  105), e medido no jogo ficou a **0,12 de Weber** contra o asfalto do pátio —
  que é o que a telha já dava (0,13). A telha nunca se separou do chão pelo
  VALOR; separou-se pelo MATIZ, e copiar a luminância copiou a metade que não
  fazia o trabalho. **Antes de preservar um número, descubra se era ele que
  segurava a leitura** — e a resposta mede-se contra o FUNDO, não na paleta.
- **A paleta mente sobre o que se vai separar no render.** No dicionário a doca
  do armazém (152) fica noventa pontos abaixo da parede (241); com a luz da
  cena, a doca sai a ~150 e os vincos da chapa a ~135 — a faixa da base e a
  textura da parede na MESMA banda. Quem separou foram três pixels de `metal`
  no topo da doca. A esta escala quem separa não é o tom, é a LINHA escura, e
  isso confere-se no render e não na tabela de cores.
  ⚠️ **E ENTRE O HEX E O PNG HÁ UMA CAMADA QUE NINGUÉM ESCOLHEU: o AgX.** O
  `preparar_cena()` não declara a transformada de vista e o Blender 4.x dá AgX
  a toda cena nova. Medido em 23/09: o `#eef2f5` sai a 191 num plano de
  emissão, e **nenhum prop passa de ~190 no p99** (231–236 em Standard, sem
  estourar um pixel). O mapa é SVG e não passa por ele. Todo contraste de prop
  medido em jogo foi medido através do AgX; trocar é decisão do Bruno
  (plano de arte, §7).
- **Peça que avança o CHÃO de um prop avança a PEGADA, e as faces não têm a
  mesma folga.** Antes de escolher em que face sai um deck, uma escada ou um
  toldo que pousa, meça a folga de cada uma em `porto_mapa_ancoras.json` — o
  armazém tem 0,236 unidades em `+my` (até o cotovelo da rua) e 0,746 em `+mx`
  (até o avental), e a plataforma de carga foi para `+x` por causa disso e não
  por gosto. A história do prop confirma ou não a régua; nunca a substitui.
- **Trocar cor olhando só o MATIZ achata a imagem.** Em 02/09 a água passou de
  mar frio a turquesa tropical com valores amostrados da referência, e ficou
  bonita e chapada: pôr as duas pontas amostradas nas duas pontas da rampa
  comprimiu a separação de luminância entre água funda e baixio em 25%, e a
  espuma — traço claro que contrastava sobre água escura — perdeu um quinto do
  contraste de Weber sobre água clara. **Ao trocar uma paleta, meça a
  amplitude de luminância antes e depois**, e lembre que o contraste que o olho
  vê é razão e não diferença. Na captura inteira nada disso aparecia; a 3× de
  ampliação era evidente.
- **Contraste depende do FUNDO, e isso vale para sombra como vale para cor.**
  Irmã da regra acima, e mordeu no mesmo dia: a sombra do tema é navy (lum 49)
  e o fundo da barra inferior é #0d1a26 (lum 24) — pôr sombra nos cartões
  escuros desenharia um HALO. Cartão escuro sobre fundo escuro ganha corpo por
  borda, não por sombra. Antes de aplicar profundidade, amostre o fundo.
  **Cor de texto sobre fundo colorido mede-se com a WCAG**, não se escolhe: o
  âmbar do tema com rótulo branco dá 2,39:1 e reprova até o corte de texto
  grande (3,0); com rótulo navy dá 5,27:1 e passa o AA.
- **⚠️ CORTE DE QUINA E ESTREITAMENTO FORTES, NO MESMO PRISMA, DÃO GEOMETRIA
  DEGENERADA.** O chanfro corre por cima de tudo no fim, e numa quina já
  cortada a 46px que ainda encolhe 22% em `x` ele dobra-se sobre si mesmo: os
  três bustos de 13/09 saíram com uma BARRA PRETA de ponta a ponta no topo do
  ombro. A 38 de corte e 0,86 de estreitamento desaparece — as duas coisas são
  boas sozinhas, é somá-las que sai caro, e o sintoma não se parece nada com a
  causa.
- **Duas faces no MESMO plano dão um buraco preto, e não dão erro.** Um tampo
  que acaba à altura exata do topo do corpo põe duas faces coplanares, o
  z-buffer escolhe ao acaso e o prop sai com um losango preto que se lê como
  caixa aberta. Mordeu duas vezes em 02/09 — no tampo do caixote e numa chapa
  de metal sobre o contêiner. Peça que pousa noutra afunda uma fração ou sobe
  uma fração; nunca encosta.
  **E DUAS PAREDES QUE SE CRUZAM NUMA QUINA são o mesmo caso** (05/09): se as
  duas chegam ao mesmo `x`, as duas faces exteriores ficam coplanares por toda
  a altura e sai uma BARRA PRETA de pé na quina, que se lê como uma coluna que
  não existe. Elas encaixam em L — uma leva a quina inteira, a outra começa
  onde ela acaba — e nunca se cruzam.
- **Vão recuado perto de uma quina atravessa a parede vizinha.** Irmã da
  anterior: um `vao_cego` é uma placa RECUADA, e a menos de meia largura da
  quina ela sai do outro lado. Meia largura de folga, e mais um pouco.
- **Asset GERADO não é asset EM CENA, e nada perguntava a diferença.** O
  `barco_medio` era renderizado a cada leva, entrava no manifest, passava o
  `asset_validator` e as cinco suítes — e o jogo nunca o punha numa doca:
  escolhia entre dois cascos por um booleano, e o terceiro só existia como
  enfeite na Zona de Espera. Toda a maquinaria de validação deste projeto
  pergunta se o que está na CENA existe no disco; nenhuma perguntava o
  contrário — até 16/09, quando `tools/arte_orfa.py` passou a fazê-la. Ele
  encontrou **11 de 109 arquivos** sem uma referência: a pasta `art/brp`
  INTEIRA (que o mapa em SVG substituiu), dois SVG de píer na raiz e o
  `doca_concreto`. É relatório e não portão, porque o destino de cada um é
  decisão do Bruno. Ao acrescentar um prop, acrescente também quem o mostra — e
  a asserção de que ele chega à tela.
  ⚠️ **E «ÓRFÃO» E «APAGÁVEL» SÃO DUAS PERGUNTAS — o relatório só faz a
  primeira.** Triados em 22/09, os onze eram TRÊS grupos e não uma pilha:
  **nove tinham propósito ESCRITO** (os oito de `art/brp` e o `doca_concreto`
  servem a `scenes/tests/AssetPlacementTest.tscn`, que a ferramenta exclui de
  propósito, e o `art/brp/README.md` nomeia a condição de regresso — reabrir a
  `001`), e só DOIS não eram referidos por nada. Saíram esses dois. Quem ler o
  relatório e contar apagáveis conta a mais (`docs/decisoes/046`).
  ⚠️ **E DISCO NÃO É PACOTE: os onze mediam 687 KB em disco e 282 KB no
  `.pck`**, porque o que embarca é o `.ctex` comprimido. ⚠️ **E eles embarcam
  MESMO SEM SEREM REFERIDOS** — o preset é `export_filter="all_resources"` e o
  Godot não faz tree-shaking: o `exclude_filter` tira a CENA de teste e não
  tira a ARTE que ela usa. Antes de estimar o que apagar arte poupa, exporte o
  `.pck` das duas maneiras; e apagar um dos nove reprova o `asset_validator`
  («no manifest e não no disco»), logo a entrada do manifest sai junto ou não
  sai nenhum dos dois.
- **Peça invisível conta como peça, e é por isso que contar não chega.** A
  boia levou uma corrente que ficou DENTRO do cone do corpo: o contador dizia
  cinco, o render mostrava quatro. Contagem de peças só vale depois de olhar
  o render — o contador não sabe o que está tapado.
- **Prop da cor do chão onde pousa desaparece.** É a irmã da regra do
  `pilha_caixotes` ("faces vizinhas do mesmo tom fundem-se"), mas entre peça e
  CENÁRIO: o caixote era `madeira` num tabuado de `madeira`, e enquanto foi
  caixa lisa isso passou. Ao ganhar tampo e cinta, o corpo continuou fundido
  com o convés e só as peças novas ficaram visíveis — o caixote saiu da
  renderização parecendo um banquinho, com tampo e pernas. A suíte passou.
- **⚠️ O COMENTÁRIO QUE DIZ QUAL CONTA APERTA PODE APONTAR PARA A ERRADA.** O
  `RUA_LARG` tinha ao lado a conta do pátio (`RUA_RECUO - RUA_LARG - CALCADA -
  APRON`) e a afirmação de que o armazém cabe — e cabe, em `mx`. Ao alargar a
  rua em 07/09, quem fechou primeiro foi a janela em **`my`** entre o acesso ao
  berço e o cotovelo, que nem estava escrita: ela vale `3,98 - RUA_LARG` e o
  armazém precisa de 1,987, o que põe o teto em 1,99 e não em 2,2. **Antes de
  confiar na restrição que o comentário nomeia, procure as outras** — e depois
  varra o valor, que é como se acha a que aperta.
- **⚠️ E DERIVAÇÃO E TESTE COM LIMIARES IGUAIS TÊM ZERO DE MARGEM.** O
  `vaos_da_vila()` abre o vão a `0,6` da meia-largura do sprite e o D14 mede a
  `0,30` da largura — o MESMO número. Só que um mede do canto do lote e o outro
  do centro da casa, e essa diferença chega a 0,315 unidades: uma casa cujo
  centro cai dentro do limiar do teste e cujo canto cai fora do da derivação
  escapa ao vão e sai fatiada pelo prédio. Passou despercebido enquanto nenhuma
  casa calhou naquela fatia de 6 px, e apareceu no dia em que os prédios se
  mexeram. **Dois números iguais medidos de sítios diferentes não são a mesma
  guarda** — o que gera tem de ser mais folgado do que o que confere.
- **⚠️ NADA PERGUNTAVA SE DOIS DESENHOS DO MAPA SE SOBREPÕEM.** Toda a
  maquinaria de cerco deste projeto mede PEGADA DE PROP contra faixa publicada
  — e um desenho do gerador não é prop. Os dois lotes reservados do pátio
  nasceram a olho em 07/09 e caíram em cima dos ACESSOS AOS BERÇOS, que o
  `vias()` desenha e que nenhuma faixa declarava; ficaram assim uma sessão
  inteira, invisíveis, porque o camião passava reto pela rua. Viram-se no
  primeiro frame em que ele entrou na doca e foi encostar em cima da
  demarcação. Ao acrescentar desenho ao mapa, publique-o na tabela de âncoras e
  confira-o contra o que já lá está — **interseção de intervalos nos dois
  eixos**, que é a mesma regra dos quatro cantos.
- **⚠️ E NADA PERGUNTAVA COM QUE COR O MAPA PINTA UM PONTO.** A irmã da regra
  acima, do outro lado: ali dois desenhos ocupavam o mesmo sítio, aqui a
  GEOMETRIA ESTÁ TODA CERTA e quem erra é a ordem. A calçada do cotovelo saía
  depois do asfalto da faixa reta e é 0,22 mais funda do que ele: sobrava uma
  fita da cor do passeio ATRAVESSADA NA PISTA, da largura da rua, na entrada de
  cada um dos cinco cotovelos, e viveu assim uma sessão inteira. Todo cerco
  deste projeto pergunta POSIÇÃO — pegada contra faixa, lote contra acesso,
  casa contra vão — e nenhum perguntava COR. Hoje o **D20** rasteriza os dois
  mapas com o ThorVG e percorre a `ROTA_ESTRADA` a exigir que nenhum ponto dela
  caia em calçada; a rota serve porque é escrita à mão no `Main.gd` e o mapa sai
  do gerador — duas fontes, e não um espelho. E a pergunta é **«não é calçada»,
  não «é asfalto»**: a rodagem leva pintura, e exigir o cinzento reprovaria uma
  zebra bem desenhada (`docs/decisoes/013`).
- **⚠️ E CASAR HEXADECIMAL EXATO SÓ SERVE EM TINTA CHAPADA.** A regra acima
  abriu a porta de perguntar COR ao mapa; esta diz onde ela não passa. A rua é
  chapada e compara-se exata com a folga do antisserrilhado; a ÁGUA leva coisa
  por cima — manchas de corrente em gradiente radial e duas camadas de espuma,
  todas semitransparentes. O pixel do berço da doca 3 sai `#3aacc7` onde a
  paleta diz `#3fb6cf`: fora dos 4/255, e o primeiro D21 reprovou um berço que
  estava certo. Onde o alvo leva camadas por cima, separe por LUMINÂNCIA com o
  limiar DERIVADO das cores publicadas — a meio entre a família escura e a
  clara —, nunca por igualdade de tom. Aqui isso dá 92,6 com 16 pontos de folga
  de cada lado, e mancha nenhuma atravessa.
- **⚠️ E A FRONTEIRA ENTRE DUAS TINTAS CHAPADAS NÃO É CHAPADA.** A regra acima
  diz onde o hexadecimal exato passa — em tinta chapada — e esta diz que a
  exceção mora DENTRO dela. O D20 reprovou o mapa CERTO em 14/09: a rota do
  camião atravessa a fronteira entre o pavimento do pátio (`#ced4d7`) e o
  asfalto (`#49535b`), e o pixel de antisserrilhado dessa fronteira sai a
  `#b1b8bc` — a **3/255** da calçada (`#aeb8bf`), dentro da folga de 4 que o
  `_mesma_cor` dá ao próprio antisserrilhado. **O valor por que uma rampa passa
  pode calhar na banda de uma TERCEIRA cor da paleta**, e nenhuma das duas tintas
  tem culpa. O remédio é o que o D17 e o D24 já sabiam e o D20 era o último a não
  saber: pergunte **quanto desenho há à volta do ponto**, nunca de que cor é o
  ponto (`docs/decisoes/025`).
- **⚠️ E A JANELA DE UMA PROVA ESCALA COM O FATOR, MAS O MÍNIMO ESCALA COM O
  QUADRADO DELE.** O raio é uma DISTÂNCIA, a contagem de pixels dentro dele é
  uma ÁREA. Escalar só o raio pede os mesmos 40 px numa janela 2,25x maior, e a
  prova passa de graça — a versão em área de "não se aperta o teto de uma guarda
  até ela apanhar um segundo defeito", com o sinal trocado.
- **⚠️ E DISTÂNCIA EM UNIDADES NÃO SOBREVIVE A UM DEGRAU DA COSTA.** A conta
  óbvia — `mx` do prop menos a borda do cais da banda de `my` dele — deu **6,85**
  para uma peça que o mapa pinta de `agua_media`, cuja banda acaba aos 6,0.
  Não há erro na conta: perto de um degrau o ponto de costa mais próximo não é a
  borda da própria banda, é a face do degrau ao lado, e as faixas de
  profundidade seguem o CONTORNO. Toda medida "a que distância da costa" neste
  mapa pergunta-se ao desenho, não à aritmética — e pela mesma razão uma
  varredura dessa distância **não é monótona**: entre 2,0 e 3,0 o número de
  props no largo sobe, desce e sobe, e parar no primeiro valor que serve é
  assentar em cima de uma fronteira que se mexe.
- **E a guarda que DUAS outras já implicam nunca reprova.** Irmã da regra de
  injetar defeito, um andar acima: a primeira asserção do desvio varria-o contra
  o retângulo do acesso, e o desvio é uma reta entre dois pontos que outras duas
  asserções já prendem aos números publicados — com aquelas de pé, esta não
  tinha como falhar. Antes de escrever a terceira asserção sobre a mesma coisa,
  pergunte que estado a violaria **sem violar as outras**; se não houver, ela é
  confiança de graça.
- **Prédio que não cabe no pátio não dá erro — dá prédio em cima do asfalto.**
  O armazém ocupa 3,76 unidades em `mx` e o pátio tinha 1,68: 0,70 dele ficavam
  na rua e 0,08 pendurados sobre a água. O teste de design passava porque
  conferia a ÂNCORA, que é um ponto, e o ponto estava no lugar certo. **Prop
  grande responde pela PEGADA**, e a largura do pátio sai de uma conta —
  `RUA_RECUO - RUA_LARG - CALCADA - APRON` — que hoje está escrita no gerador.
- **E conferir o QUADRO de um prop não é conferir o PROP.** Irmã da regra
  acima, e ela passou despercebida por duas sessões: o D7 exigia que o pé do
  mastro de um letreiro caísse dentro do quadro do prédio — que tem 512px,
  para um prédio DESENHADO de 103. Sobravam duzentos pixels de folga de cada
  lado, e a placa do armazém pairava 12px acima do telhado com o teste a dizer
  "apoiado". Toda asserção de encaixe mede-se contra `get_used_rect()`, nunca
  contra o quadro — o quadro é o mesmo em todos os props e não sabe nada sobre
  nenhum deles.
- **⚠️ E A CAIXA DESENHADA NÃO É O DESENHO.** Irmã da regra acima, do outro
  lado: ali o quadro de 512 não sabia nada do prop, aqui o `get_used_rect()`
  sabe demasiado pouco. Ele funcionou enquanto os três cascos eram de portes
  diferentes; assim que eles passaram a partilhar o costado e a mudar só o
  CONVÉS, o porta-contêineres e o graneleiro médios deram a MESMA caixa — 97 ×
  83 no mesmo sítio — e a asserção reprovou dois desenhos bem distintos. E os
  bytes também não servem, pela regra do denoiser mais abaixo. O que responde é
  reduzir os dois a 16×16 e comparar: cada célula é a média de ~1.000 pixels, o
  que apaga o ruído de ±2/255 por construção.
- **⚠️ E NUMA PEÇA COM CABOS A CAIXA MENTE QUASE DE GRAÇA.** A terceira cara
  das duas regras acima, e a mais barata de cair: um cabo, um estai ou um
  amantilho tem dois pixels de largura e ESTICA o `get_used_rect()` para o
  outro lado do prop. Logo `used_rect.has_point(p)` custa quase nada de
  satisfazer — o D17 exigia que a lança cobrisse o próprio centro de rotação e
  media a moldura, e uma lança inteira desenhada FORA do eixo continuava a
  passar, porque uma corda qualquer atravessava o ponto. Pergunte quanto
  DESENHO há à volta do ponto (a fração de pixels opacos num raio pequeno), e
  nunca se o ponto cai na caixa.
- **⚠️ CONTAR `caixa()` DESCREVE A CONSTRUÇÃO, E NÃO A LEITURA.** O kit tem 178
  chamadas a `caixa()` contra 42 a `cone()`, e daí não sai qual prop lê
  quadrado: quem responde é a SILHUETA, que nesta câmera só sabe três direções
  quando a peça é uma caixa alinhada aos eixos (±26,57° e a vertical). É o que
  `tools/medir_silhueta_props.py` mede, e a resposta contrariou o palpite —
  renderizado sozinho, o CASCO do cargueiro mediu 0,620 contra 0,563 do galpão,
  e o contêiner por cima não fazia o navio ler quadrado: **tapava** o casco
  (`docs/decisoes/024`).
- **⚠️ E O CHANFRO QUE O KIT INTEIRO APLICA É INVISÍVEL POR CONSTRUÇÃO.**
  Varrido: um filete só entra na imagem a partir de **3 px** de raio e só LÊ a
  partir de **6**. O `chanfrar()` usa 0,020 unidades, e uma unidade vale 20 px
  de tela — **0,4 px**. Curva que se decide num prop mede-se em 0,15 e 0,30 de
  mundo, nunca em 0,02. E daí sai um portão de TAMANHO: a 40 px de largura um
  filete de 6 px já leva a caixa para baixo da linha do cilindro — deixou de
  ser quina arredondada e passou a ser outra forma.
- **⚠️ REFERÊNCIA DE FORMA TEM DE TER A CAIXA ENVOLVENTE DA PEÇA, senão mede o
  TAMANHO e a ESBELTEZ.** Um contorno fechado dá 360° de curva no total, então
  o preço das quinas é fixo em pixels e pesa tanto mais quanto menor for a
  peça. Duas consequências medidas: **abaixo de ~24 px de diagonal a caixa
  ideal e a forma redonda medem o mesmo** (a pergunta não tem resposta, e a
  ferramenta recusa-se a dar número em vez de dar um plausível); e **numa peça
  ESBELTA a caixa e o cilindro medem quase o mesmo** — 0,640 contra 0,635 a
  10×35. Peça comprida não se conserta arredondando a secção: a estaca do píer
  media 1,065, o valor mais alto do kit, e uma estaca cilíndrica tem os mesmos
  dois lados verticais. O ganho não paga, e registou-se em vez de se arredondar.
- **⚠️ E ÍNDICE NORMALIZADO SÓ VALE ENQUANTO A PEÇA ENCHE A CAIXA QUE O
  NORMALIZA.** A regra acima diz que a referência tem de ter a caixa envolvente
  da peça; esta diz quando isso deixa de bastar. Ao arquear o tronco do
  coqueiro, o índice desabou de 0,491 para −0,47 aos 15° e **voltou a subir**
  aos 30 e aos 45 — não monótono, e nada disso é a peça a ficar redonda: um
  tronco curvo deixa de ENCHER a caixa dele (a largura vai de 16 para 29 px sem
  o desenho engordar), e comparar uma fita curva com a caixa e a elipse CHEIAS
  daquele retângulo mede o vazio à volta. E o mesmo prop já media 0,491 contra
  0,741 do CILINDRO ideal — ou seja, nunca leu quadrado, e o número que o item
  herdou dizia o contrário (`docs/decisoes/028`).
- **⚠️ E RÉGUA DE FORMA TEM RUÍDO PRÓPRIO, que não é zero.** A irmã da regra do
  validador injetado, para números em vez de verdes: ali o mesmo arquivo dos
  dois lados tem de dar zero EXATO; aqui a peça CERTA dá 1,73 px de flecha, que
  é a largura de 16 px, as seis faces e o antisserrilhado. Sem medir esse piso,
  os 2,53 px de uma curva de 15° passariam por curva. **Meça o piso antes de os
  números valerem.**
- **⚠️ ESCALAR UM CONTORNO CURVO ACHATA A CURVA DELE.** O fundo do casco era a
  amurada escalada por `(0,88, 0,42)`: a curva chegava lá 58% menor e o que
  sobrava desviava-se menos de 1 px ao longo de 60 px — a régua lia uma reta, e
  era ela que continuava a fazer o casco medir quadrado depois de o convés já
  curvar. Anel de baixo de um prisma leva contorno PRÓPRIO, não um fator.
- **⚠️ E CURVAR UMA LINHA SEM CURVAR O QUE ASSENTAVA NELA DEIXA-O ATRAVESSADO.**
  Enquanto o bordo do casco era reto, o guarda-corpo reto coincidia com ele por
  acidente; com o bordo curvo ficou a cortar o convés em diagonal, com as
  pontas a morrer no meio da chapa. É "ao corrigir um, VARRA OS IRMÃOS" com a
  geometria no lugar do prop: quem muda uma linha muda tudo o que a seguia.
- **⚠️ E MUDAR A FORMA DE UM PROP NÃO PODE MUDAR A CAIXA ENVOLVENTE DELE.** Os
  extremos do casco — proa, popa e boca máxima — ficaram no mesmo pixel de
  propósito: o barco cai em `Dock.tscn` num `offset` fixo, e um casco meio
  pixel mais gordo mexeria nele sem dar erro nenhum.
- **PARTILHA TOTAL OU NENHUMA, numa tabela de arte.** O pesqueiro usa o mesmo
  casco nos dois motivos dele de propósito — pescado e armazenagem são o mesmo
  peixe indo para sítios diferentes, e o barco não muda com o destino da carga.
  Um cargueiro que apontasse dois serviços para o mesmo PNG seria copiar-colar,
  e numa tabela as duas coisas leem-se IGUAL. Exigir 1 ou N separa-as: partilhar
  é uma afirmação sobre a classe inteira, nunca sobre um par de chaves.
- **Conferir os quatro cantos de um retângulo contra uma faixa não é conferir
  o retângulo.** Foi assim que a primeira versão daquele teste deixou passar o
  defeito que ela existia para pegar: os cantos caíam a 2,82 e a 5,58, a rua
  ocupava 2,98..4,52, e a pegada atravessava o asfalto inteiro sem pousar nele
  com canto nenhum. Retângulo contra faixa é **interseção de intervalos**.
- **Uma conta que só divergiria com um modificador ativo não se testa num
  porto em ruínas.** A projeção do dia (item da interface, 03/09) e o fecho
  real da semana partilham `_custos_da_semana()` de propósito — e o teste que
  provava isso rodava sem pátio nem escritório construídos, onde a fórmula
  errada e a certa dão o mesmo número por acidente (nenhuma das duas aplica
  bónus nenhum). Só com os dois construídos um defeito injetado na cópia
  reprovou. É a mesma lição de "contagem só se testa acima de um", aplicada a
  um bónus em vez de uma quantidade.
- **⚠️ CONTRASTE GASTO ENTRE DUAS PEÇAS DO PROP PODE DEIXAR O PROP INVISÍVEL.**
  As regras acima dizem que a paleta mente e que o contraste é contra o FUNDO;
  esta diz de que maneira se esquece isso. Ao desenhar o pau de carga do n1
  escolheu-se `tronco` para o pau SEPARAR DO MASTRO — 0,45 de Weber entre os
  dois, de sobra — e mediu-se aí. No jogo o pau passa por cima da AREIA e deu
  0,21: some. **Duas peças que se separam bem uma da outra podem estar as duas
  na banda do fundo.** A conta que decide a cor é sempre peça contra fundo; a
  separação entre peças é a segunda pergunta, nunca a primeira.
- **⚠️ PROVA POR PIXEL ÚNICO É FRÁGIL, E A JANELA TEM DE SER DA ESCALA DA
  PEÇA.** A primeira metade já estava escrita no D17 — pergunte quanto DESENHO
  há à volta do ponto, e nunca se o ponto cai na caixa. A segunda custou dois
  defeitos injetados que **não pegaram** (13/09, D24): com um raio único de
  12 px, tirar o campanário da igreja passava porque a janela ainda apanhava o
  remate 7 px abaixo, e dar um telhado à obra passava porque à volta dela há
  creme por todo o lado. Uma peça de 18 px pede uma janela de 9×9; uma laje de
  50, uma de 21×21 — e o raio vive na PROVA, não numa constante do teste.
  E o pixel único mentiu três vezes antes disso, sempre reprovando o que estava
  certo: por mirar o meio de um volume (que em isométrico cai na FACE lateral e
  não no topo), por cair debaixo de uma peça elevada (que se projeta para cima
  e para TRÁS, tapando todo ponto de `mx + my` menor) e por cair dentro de uma
  copa.
- **⚠️ E A GUARDA QUE SE SATISFAZ COM O VIZINHO NÃO GUARDA NADA.** É o que
  estava por trás dos dois defeitos acima, e apareceu três vezes no mesmo dia: a
  prova do piso da praça contava os pixels da CALÇADA DA RUA, que passa a poucos
  pixels dali — teria passado com a praça inteira apagada. Antes de escolher o
  que provar, pergunte o que é EXCLUSIVO da peça: a praça passou a ser provada
  pelo coreto, que é a única coisa que só ela tem. E quando a peça se define por
  uma AUSÊNCIA, a prova é negativa — ter laje creme não distingue uma obra das
  casas, que são do mesmo creme; **não ter telha por cima**, sim.
- **⚠️ NÚMERO ABSOLUTO DENTRO DE PEÇA COM TAMANHO PRÓPRIO NÃO SOBREVIVE.** A
  cruz da igreja ia de `cx0 - 0,14` a `cx0 + 0,22` — **0,36 unidades num
  campanário de 0,30**, mais larga do que a torre que a sustenta, a cobrir o
  topo inteiro em planta. Não deu erro nenhum; quem a apanhou foi a prova a ler
  `tronco` onde a tabela prometia telha. É a irmã de "encolher um prop escala-se
  no GRUPO, nunca reescrevendo as literais": ali o risco é deixar uma literal
  por escalar, aqui é escrevê-la em unidades de mundo dentro de uma peça cuja
  medida é uma fração de outra.
- **⚠️ E UM PROP SÓ ATRAVESSA DOIS FUNDOS: nenhum tom ganha os dois.** No mesmo
  prop, o gancho pende sobre o BAIXIO (claro, ~106) e o pau corre sobre a AREIA
  (~159), com água funda (~67) à volta. `metal_claro` mede 0,75 sobre a água
  funda e **0,01** sobre o baixio. Quando um tom não vence os dois fundos, quem
  resolve não é a cor — é a MASSA: o gancho voltou ao metal escuro e passou a
  ser encontrado por ser a única ferragem grande, depois de os olhais dos
  estais encolherem de 0,11 para 0,075.
- **Cor calibrada para um fundo não atravessa para outro sem medir de novo.**
  O cinzento-azulado que marca texto neutro sobre o fundo ESCURO do jogo
  (0,51/0,6/0,706, usado no aviso de trabalhador ocioso) foi reaproveitado
  sem medir no calendário (03/09), sobre CARTÃO BRANCO: mediu 2,93:1, abaixo
  do corte de texto grande da WCAG (3,0). Reaproveitar cor entre dois fundos
  diferentes é reaproveitar cor nenhuma — é medir duas vezes.
- **"Está em cima da estrada" pode ser problema de ESCALA, não de posição.**
  Em 03/09 o pátio foi alargado, o teste passou a provar que a pegada dos dois
  prédios não toca o asfalto — e o jogador continuou a ver o escritório em
  cima da rua. Estava certo: a base era legal, mas os prédios levantavam-se
  ~4× a altura de uma casa da vila, e em isométrico é a ALTURA que projeta a
  silhueta para cima e para trás, por cima do que está atrás. Antes de mover
  um prop que "invade" algo, meça a altura dele contra os vizinhos.
- **A rua tem COTOVELOS, e faixa reta nenhuma os declara.** Irmã da regra
  acima, e o que estava mesmo por trás daquela queixa. Depois de encolher os
  dois prédios o teste passava, e a estrada continuava com o armazém em cima
  dela: entre um degrau e o seguinte a rua VIRA, e o `vias()` desenha esse
  cotovelo em `mx` por cinco unidades e meia, atravessando o pátio de lado a
  lado. As quatro faixas `rua` que o gerador publicava não o cobriam — e
  nenhuma delas mentia, porque a rua RETA estava mesmo livre. Cinco props
  estavam dentro dos cotovelos, dois deles com meia unidade de pegada. Hoje o
  gerador publica `cotovelos` e o D2 confere-os; a lição é anterior ao teste:
  **conferir o retângulo contra PARTE da rua não é conferi-lo contra a rua**,
  como conferir os quatro cantos não era conferir o retângulo.
- **Limite de GOSTO disfarçado de limite geométrico reprova o que está certo.**
  O validador do Blender recusou o retrato do trabalhador dizendo que ele "vai
  sair cortado do quadro de 512px" — e o render tinha 18px de folga em cima e
  16 em baixo. O número (8 unidades) era uma regra de gosto para prop do mapa,
  com a mensagem de uma regra geométrica; a geometria nunca chegou a ser
  medida. Hoje são duas perguntas separadas, e a geométrica projeta mesmo os
  cantos. **Validador que reprova o que está certo gasta-se depressa** — na
  vez seguinte alguém sobe o limite em vez de olhar.
- **⚠️ DUAS METADES DE UM PROP ENCAIXAM — NÃO SE SOBREPÕEM.** É a "validador
  que reprova o que está certo" com a métrica no lugar do limite. A guarda nova
  do D30 pedia que a peça de cima COBRISSE o topo da de baixo (a fração de
  desenho numa janela, a régua do D17), e o `poste_luz` deu 0,11: a luminária
  não cobre a ponta do braço, **ela continua a partir dela**. O que vale para as
  duas metades é onde está a MASSA da de cima — em cima da ponta da de baixo, e
  não a meio dela nem ao lado. E quem achou o par que denunciou isso foi a
  DERIVAÇÃO (nós do cenário que partilham a posição): uma lista escrita à mão
  teria guardado só o coqueiro, e a métrica errada teria passado.
- **E caixa alinhada aos eixos de um GRUPO tem quinas que não existem.** Ao
  medir a projeção peça a peça a resposta bateu com o render; medindo pela
  caixa do grupo, ela juntava o `x` de um braço com o `y` de uma bota e o `z`
  do capacete e errava por 17px. Caixa de grupo serve para saber se algo cabe
  num sítio; não serve para dizer o que a câmera vê.
- **⚠️ NUM ROSTO PEQUENO, A POSE VALE MAIS DO QUE A CARA.** Os nove retratos
  de 13/09 tinham três bocas, três sobrancelhas e três olhos diferentes — e a
  queixa foi que eram pouco expressivos, com razão: numa cara de 56px o que
  muda entre duas expressões são seis pixels de boca e quatro de sobrancelha,
  enquanto INCLINAR A CABEÇA muda a silhueta inteira, que é o que o olho lê
  primeiro. Cabeça de lado lê como interesse antes de se chegar à boca; queixo
  em baixo lê como peso. A pose roda sobre um pivô no MEIO do pescoço (sobre a
  base do crânio abre-se uma fresta), em ângulos pequenos, e vem ANTES do giro
  para a câmera — somar 45° ao Z é pré-multiplicar por Rz, porque o Z é o fator
  de fora da Euler XYZ.
- **⚠️ E PEÇA PEQUENA ENCOSTADA A PEÇA GRANDE DESAPARECE SEM ERRO NENHUM.** O
  lápis atrás da orelha levou duas tentativas: no `x` da orelha ficou DENTRO
  dela, e mais para dentro ficou dentro da cúpula do cabelo, que é um cone de
  raio 76. A régua para pôr um acessório é o raio da peça VIZINHA e não a
  largura da cabeça — e quem conta peças conta cinco na mesma, que é a regra da
  boia com a corrente dentro do cone, à escala de uma cara.
- **⚠️ E O QUE A PEÇA TEM DE MOSTRAR DECIDE O ENQUADRAMENTO DELA.** Irmã da
  regra abaixo, um passo antes: ali o tamanho do widget decide a escala, aqui a
  FUNÇÃO decide o corte. O `trabalhador_retrato` é de corpo inteiro porque
  identifica uma unidade, e o que identifica é o capacete e o colete —
  silhueta, que sobrevive a qualquer tamanho. Os três retratos de fala de 13/09
  são BUSTOS porque carregam EXPRESSÃO, e expressão vive em meia dúzia de
  pixels de cara: medido, de corpo inteiro a cara tem 16px e o olho 2 no cartão
  de 96px, e as nove imagens seriam a mesma imagem. Cortado no peito, com a
  cabeça a valer 61% da altura, a cara fica com 44px e o olho com 5. **Antes de
  desenhar arte de interface, pergunte que informação ela tem de entregar e a
  que tamanho** — a resposta muda o desenho, não só a escala.
- **Peça de INTERFACE mede-se no tamanho do widget, não no do quadro.** Um prop
  do mapa fica pequeno no PNG de 512 e é o Godot que o põe no sítio; um retrato
  num `TextureRect` com `KEEP_ASPECT_CENTERED` escala o PNG INTEIRO, a
  transparência incluída — 251px de boneco num quadro de 512 saem com 34px num
  cartão de 70. Ele passava em todas as asserções. Arte para interface enche o
  quadro; arte para o mapa, não.
- **E letreiro é interface: desenha-se por cima do mapa, e o teste de design
  não sabe onde ele cai.** O caminhão nasceu num ponto que passava em todas as
  asserções e saía na captura com metade dele debaixo do letreiro do
  ESCRITÓRIO. Prop que se põe para ser VISTO confere-se na foto, não na régua.
  ⚠️ **E OS LETREIROS JÁ NÃO EXISTEM** — foram removidos a pedido, com o
  `Letreiro.gd` e a variação de tema (ver `BR_Port_Plano_Arte_Blender.md`). A
  lição fica porque não era sobre placas: antes de morrerem eles carregavam
  offsets cravados que punham uma placa mais larga do que o prédio que nomeia e
  outra a pairar 12px acima do telhado, com o teste a dizer "apoiado". É o que
  este arquivo repete sobre altura e sobre cor — **número em pixel escrito à
  mão envelhece calado quando o que ele descreve muda de tamanho**.
- **Encolher um prop escala-se no GRUPO, nunca reescrevendo as literais.**
  Porta contra parede, janela contra porta, beiral contra telhado: são trinta
  números e trinta chances de um ficar por escalar. E cada objeto UMA vez —
  `galpao` e `galpao_velho` partilham as paredes de propósito, então escalar
  grupo a grupo passaria duas vezes nas peças comuns e elas sairiam a `k²`,
  sem erro nenhum a apontá-lo.
- **⚠️ "A PEÇA É PARTILHADA POR RESTRIÇÃO" merece ser medida antes de aceite.**
  A torre do guindaste era a mesma nos três níveis, e o comentário dizia que o
  `pivot_offset` único da lança obrigava a isso. Obriga UM PONTO — o topo —,
  não a coluna inteira; e como a torre é a coluna que ocupa a silhueta e a
  lança é o braço fino lá em cima, o porto inicial e o completo liam como o
  mesmo guindaste. Quando um comentário justifica uma partilha, pergunte de que
  TAMANHO é a amarra: quase sempre é menor do que a peça que ela está a
  segurar.
- **⚠️ ÂNGULO DE PEÇA INCLINADA MEDE-SE NA IMAGEM, NUNCA NO MUNDO.** É a irmã
  da regra do chanfro a 45°, aplicada a uma peça em vez de a uma faixa: a
  câmera comprime a direção (1,1) e estica a (1,−1), então graus de mundo não
  são graus de tela. O pau-de-carga do arrasteiro desce 26° no Blender e saiu
  HORIZONTAL no render — no mesmo ângulo de tela da travessa do pórtico e do
  tambor, e as três peças cinzentas fundiram-se num andaime só. A 42° ele
  desce. Escolha o número olhando o PNG, e escreva no comentário que foi
  medido lá.
- **⚠️ E UM PROP DESTA ESCALA TEM LUGAR PARA UMA SILHUETA MEMORÁVEL, NÃO PARA
  CINCO.** O arrasteiro nasceu com pórtico de popa, dois tangones, tambor,
  mastro e pau — cinco peças de metal a 82px, e o que se lia era um borrão de
  andaime com o mastro perdido lá dentro. Cortar quatro fez a quinta aparecer.
  O mesmo vale para a COR DE ACENTO: ela só acentua enquanto for UMA. Com o
  pórtico e o pau ambos laranja o laranja deixou de apontar para coisa nenhuma;
  o pau voltou ao cinzento e o arco passou a ser o barco.
- **Rodar um prop 90° manda metade dos detalhes para a face que a câmera não
  vê.** Só `+x` e `-y` são visíveis. Rodar o caminhão para o eixo da estrada
  punha o para-brisa a olhar certo e a janela lateral para `-x` — invisível, e
  ninguém notaria no render, só na silhueta chapada. Prop que muda de eixo
  RECONSTRÓI-SE com os detalhes repostos nas faces visíveis.
- **Prop que a captura não vê é prop que ninguém revê.** A travessia do
  caminhão nasceu com um desvanecer de 1,1 s no INÍCIO do ciclo, e as cinco
  fotos do CI assentam em poucos frames: o caminhão saía invisível de todas
  elas. Animação nova começa no estado VISÍVEL, e o desvanecer vai no fim.
  ⚠️ **E A CAPTURA DE JOGO SÓ MOSTRA O QUE O SORTEIO ESCOLHEU.** Em 07/09 os
  cascos passaram a ser seis (um por par de classe e motivo) e os camiões oito;
  as cinco fotos de jogo mostraram **dois** cascos e **um** camião, porque quem
  decide o que atraca é a partida. Passaram no `asset_validator`, no D13 e no
  D17 — nenhuma dessas perguntas é "dá para olhar". Arte que varia com sorteio
  prova-se com uma FOLHA DE CONTATO que percorre a tabela: é o que a
  `folha_icones.gd` já fazia para os ícones e o que a `folha_frota.gd` passou a
  fazer para a frota.
  ⚠️ **E ARTE PRESA A UM ESTADO DO JOGO NÃO É SORTEIO — É PIOR.** O sorteio ao
  menos pode calhar; um estado que nenhuma foto monta não calha nunca. Os
  barcos de pesca só atracam no porto de NÍVEL 1, e das oito imagens do CI de
  então o `inicio` era o turno ZERO (docas vazias) e as outras portos de nível 2 e
  3: a frota inteira do começo do jogo não tinha foto nenhuma, e é o estado onde
  o perfil Descuidado passa a partida toda. Ao acrescentar arte que uma
  condição do jogo destrava, pergunte QUAL das capturas monta essa condição —
  e se nenhuma monta, o tiro novo faz parte da entrega.
  ⚠️ **E «AS FOTOS NÃO MUDARAM» PEDE UM CONTROLE POSITIVO, senão é verde de
  graça.** A calibração — duas corridas da MESMA árvore com os mesmos hashes —
  prova que a bateria não tem ruído PRÓPRIO; **não** prova que ela veria a
  mudança que se acabou de fazer. Medido em 22/09, ao escurecer o texto de
  aviso da faixa de mensagem: mudaram **zero** das 24. O controle responde —
  pintar o texto NEUTRO da mesma faixa de vermelho mexeu **12 das 24**, logo a
  bateria vê a faixa em metade das fotos, e **as doze mostram-na sempre no
  estado neutro**. A cor mudada não aparece em foto nenhuma. É a regra do
  mesmo arquivo dos dois lados com um PNG no lugar do arquivo: zero só quer
  dizer zero depois de um par que se sabe diferente ter dado muito
  (`docs/decisoes/042`).
  ⚠️ **E O `getbbox()` DO PILLOW NUM RGBA SÓ OLHA PARA O ALFA.** Em 23/09 a
  comparação das 30 fotos contra as da `main` deu **zero** mudadas, com os
  camiões todos noutra faixa: a diferença de duas fotos opacas tem o alfa a
  zero em todo o lado, e o `getbbox()` devolvia `None`. Os `md5` diferiam — foi
  isso que o denunciou. Em RGB, e com o mesmo arquivo dos dois lados a dar zero
  exato, mudaram 14 (`052`).
  ⚠️ **E FOLHA DE CONTATO QUE CRESCE SOZINHA TEM DE REPROVAR AO TRANSBORDAR.**
  Ela é uma captura de 720×1280 e ganha linhas a cada porte, motivo ou classe
  nova: o que passar da última linha é recortado sem uma palavra, e o prop fica
  exatamente como estava — gerado, validado e por olhar, que é o buraco que a
  folha existe para tapar. A conta da altura reprova em vez de recortar.
  ⚠️ **E QUANDO ELA TEM PÁGINAS, QUEM CHAMA DIZ QUANTAS ESPERA.** A dos props
  não cabe numa tela (51 props a 1:1, 28 por página), e uma folha que decida
  sozinha o número de páginas escreve a página nova onde ninguém a vai buscar —
  o `capturar_evidencia.sh` nomeia cada arquivo. Ela recebe `<página> <total>`,
  conta o que o catálogo pede e REPROVA se não bater: acrescentar a chamada faz
  parte de acrescentar o prop.
  ⚠️ **E QUADRO VAZIO NÃO É ERRO PARA QUEM NÃO O PERGUNTA.** Em 23/09 as folhas
  de contato gravaram os doze cascos EM BRANCO e imprimiram "Folha salva em"
  (`049`). A pergunta que apanha é **"esconder a peça muda a foto?"** — duas
  fotos, com e sem a arte, e a diferença por peça: dá zero exato no defeito,
  não depende da cor do chão e não pode ser enganada pelo `get_image()`, que era
  quem mentia. Ferramenta de evidência prova que o que declara ESTÁ na foto.
- **Antes de gerar MAIS, veja onde o que já se gera está a cair.** A queixa
  "a vegetação é bem pobre" tinha 136 copas de mata geradas e **7** dentro do
  quadro: o viés da densidade (`random ** 2.2`) empurrava-as contra
  `FUNDO_TERRA`, que é, pelo próprio nome, a parte do mundo fora do ecrã. O
  comentário da função dizia a intenção com todas as letras — "a densidade
  cresce para o fundo". Medido por degrau, a fração da faixa de mata visível
  era 11% / 50% / 10% / **0%**. Toda faixa deste mapa medida a partir do cais
  tem uma janela visível estreita, e o orçamento de desenho é de peças
  DESENHADAS, nunca de sorteios — `no_quadro()` existe para isso.
- **Fileira dupla só lê se a separação passar de UM elemento.** Em isométrico
  duas fileiras separadas por `Δmx` ficam a `Δmx × MEIA_LARG` px na tela. A
  segunda fileira da vila nasceu com 57px de separação para telhados de 78: a
  casa de trás saía 73% tapada e as duas fileiras liam como um borrão de
  telha. É a irmã da regra "duas faces no MESMO plano dão um buraco preto" —
  sobreposição que o olho não consegue desfazer não é profundidade, é sujeira.
- **Peça pequena sem aresta lê como mancha, e a receita já existe.** A copa de
  árvore eram duas elipses concêntricas deslocadas 8-14px numa copa de 40 — a
  MESMA forma que o enrocamento tinha tentado e descartado em 03/09. `com_saia()`
  em `gerar_mapa_iso.py` é essa receita com nome: polígono irregular de topo e
  uma saia por aresta virada para baixo. Antes de desenhar volume pequeno,
  procure-a — e antes de corrigir um defeito de leitura, procure se a função
  IRMÃ já o corrigiu (o capim tinha a correção escrita num dos dois sítios e
  não no outro; a mancha de desgaste do cais estava a ser pintada no relvado
  enquanto a junta, dez linhas abaixo, sabia exatamente onde parar).
  ⚠️ **E AO CORRIGIR UM, VARRA OS IRMÃOS — a lição escrita não anda sozinha
  até eles.** Em 07/09 o pau-de-carga dos cargueiros foi girado para o costado
  porque no plano do mastro ele lia como uma CRUZ, e a armadilha ficou escrita
  ao lado da correção; o pesqueiro, que tem o mesmo mastro com o mesmo pau,
  ficou com a cruz por mais uma sessão inteira, porque ninguém voltou a abrir o
  prop. Correção de leitura fecha-se com um `grep` pela FORMA que a causou, não
  pela peça onde ela apareceu.
- **Comentário que explica como a constante ao lado apodrece é um pedido para
  ela ser derivada.** O `VILA_VAZIOS` — onde os prédios do pátio tapam a vila
  — eram dois intervalos escritos à mão com vinte linhas a avisar que
  envelheciam calados, e envelheceram. Hoje saem de `vaos_da_vila()`, e a
  derivação achou o que a versão à mão escondia: a coluna da tela não chega,
  porque um prédio tapa para CIMA e só até à altura do sprite dele.
  ⚠️ **E ACONTECEU OUTRA VEZ NO ANDAR DE BAIXO, com o mesmo par de prédios.**
  O `PREDIOS_DO_PATIO` dizia no comentário "lido de `Main.tscn`" e NÃO era
  lido: era copiado, e o `my` estava 1,10 e 1,05 unidades adiantado — meia
  casa de vão fora do sítio, com o D14 a passar porque lê a mesma constante
  onde o defeito mora. Um comentário que diga "lido de X" e não leia X é a
  forma mais barata desta armadilha: **se está escrito que sai de algum lado,
  faça-o sair de lá.**
- **⚠️ CAMPO PREENCHIDO A 100% PODE ESTAR PREENCHIDO PARA OUTRA PERGUNTA.** O
  manifest tem `habitat` nas 44 entradas, e em 14/09 propus agrupar a folha de
  contato por ele. Medido antes de codar: dos 51 props de MAPA só 26 estão no
  manifest, e **20 desses 26 são `terra`** — os outros seis são habitats de uma
  peça cada (`vila`, `ar`, `areia`...). O campo foi desenhado para a FAUNA, onde
  cada bicho tem o seu. Cobertura não é distribuição: antes de agrupar por um
  campo, conte quantos valores DISTINTOS ele tem no conjunto que interessa — um
  campo quase constante não agrupa, e o resto sairia de uma lista à mão.
- **Escala de ruído é relativa ao tamanho da peça.** Numa longarina de 0,045
  o número 14 dá uma marca; numa parede de 3 unidades dá setenta, e a parede
  vira lixa.
- **Padrão dirigido não entra na PALETA, entra peça a peça.** É a regra acima
  aplicada a padrão em vez de a ruído: `madeira` veste o tabuado de 4,5×2,4 e
  também o caixote de 25px, então ripar a entrada da paleta poria oito tábuas
  dentro de um caixote. Pela mesma conta o pesqueiro (67px) não enferruja e os
  cargueiros (97px) enferrujam.
- **A MELHORIA não pode ser mais lisa do que aquilo que ela substitui.** O
  convés do píer n2 era uma chapa de `madeira` — a maior superfície do jogo,
  138px, três vezes na tela — e o n1, que é o pontão provisório, gasta
  geometria em nove ripas com fresta. O jogador comprava o upgrade e o convés
  ficava LISO. Ao construir dois estados de uma peça, confira que o melhor tem
  mais desenho, não menos.
- **Sombra entre peças precisa de PATAMAR, não de rampa.** Uma rampa linear de
  dois pontos só chega ao escuro total no último pixel: num tabuado de passo
  6px o que se via no jogo eram bandas de tom, não tábuas. Três pontos — escuro,
  escuro, claro — dão à sombra metade da largura dela em valor cheio. Vale para
  toda junta, fiada ou vinco desenhado por material.
- **⚠️ `Pointiness` NÃO SEPARA QUINA DE PANO NUMA CAIXA, e não dá erro.** Ele é
  atributo de VÉRTICE, e uma caixa chanfrada não tem vértice nenhum no meio da
  face — o valor no pano é interpolado dos cantos, e não existe campo plano
  contra o qual comparar. Medido no galpão em ruína: varia de 29 a 181 com
  mediana 146 e 31% da parede acima de mediana+10, quando o efeito precisa de
  uma distribuição bimodal. Aplicado, pintou a parede inteira. Efeito que
  depende de aresta, neste kit, sai de uma COORDENADA (distância à aresta da
  caixa), nunca da curvatura da malha.
- **Recuar um contorno para DENTRO não é `costa_deslocada` com o sinal
  trocado.** Aquele empurra cada vértice na diagonal (+d em mx, −d em my), o
  que serve para uma faixa de água; ao longo de um MURO isso desloca também o
  `my`, e a linha recuada sai adiantada da original. Ao fazer a praia de 04/09
  a crista ficou 1,3 unidade à frente da linha de água e abriu-se um triângulo
  de **água funda dentro da terra**, no fim do cais. Recuo é pela normal de
  cada segmento, e cada quina leva o remate que pede: chanfro onde a terra
  abraça a quina, cruzamento das duas linhas onde ela é uma ponta.
- **⚠️ REAMOSTRAR UMA CAMINHADA COM SORTEIO MOVE TUDO O QUE ELA ESPALHA.** O
  `andar_costa` percorre a costa a passos irregulares tirados de um `Random`, e
  dele saem o enrocamento do cais, a espuma, as pedras da praia, o capim e as
  árvores da restinga. Ao desenhar as pontas em 14/09, densificar a linha teria
  mudado o número de sorteios ANTES do cais e trocado de sítio as ~300 pedras do
  enrocamento — meia sessão de diferença visual no porto por causa de uma
  correção na praia. A caminhada continua a medir-se na ESCADA, com os mesmos
  comprimentos de segmento e a mesma sequência de sorteios; o que mudou foi só
  o ponto onde cada coisa cai. **Quem mexe na geometria de uma varredura
  sorteada pergunta primeiro o que mais bebe daquele mesmo `Random`.**
- **⚠️ E FAMÍLIA DE CURVAS CONCÊNTRICA É O QUE IMPEDE COSTURA.** Tudo o que
  acompanha a costa — linha de água, baixio, espuma, pedras, as três linhas da
  rampa e o campo de cor da água — sai de `ponto_costeiro()`, uma função só, com
  o fileto de cada quina em volta de um centro FIXO e o raio a crescer com a
  distância à terra. Duas curvas assim nunca se cruzam, e quando o raio chega a
  zero a curva volta a ser a quina de sempre — que é como o cais fica byte a
  byte igual sem uma linha de exceção. **Uma costura é duas contas a discordar;
  a saída não é afiná-las, é haver uma só.**
- **Faixa que acompanha a costa desenha-se pelo CONTORNO, nunca degrau a
  degrau.** A regra já estava escrita no `costa_deslocada` — "a versão anterior
  tratava cada degrau como uma faixa solta" — e mordeu outra vez um andar
  acima: a praia feita por degrau saiu como duas rampas soltas com um degrau
  de terra a pique entre elas, no sítio onde a costa vira.
- **Fronteira paralela à costa precisa de meandro LONGO.** Sacudir cada
  amostra dá ruído de 11 px de período, que na tela não é nada: três tons de
  areia com as fronteiras assim sacudidas saíram como três FITAS de largura
  constante. Duas senóides de períodos diferentes resolvem — e três faixas
  eram uma a mais, porque a referência pede "uma faixa clara" e não um
  arco-íris.
- **Areia vista pela água não é a cor da areia misturada com a água.** Pintar
  `#d8cb9c` a 0,40 sobre o turquesa dá `#8bc8c2`, que mede **0,06** de Weber
  contra o baixio — some —, e a faixa lavada pelo mesmo caminho dá um
  azeitona que lê como lama. Baixio de areia é água CLARA e pouco saturada:
  escolhe-se pelo VALOR (209 contra os 176 do baixio) em vez de sair de uma
  mistura. É a irmã da regra do matiz, do outro lado.
- **O que CRESCE no chão pertence à camada do chão.** O capim da restinga
  nasceu junto com a areia, que é desenhada no fim com o enrocamento — depois
  da rua e depois da vila —, e apareceu por cima dos telhados e do passeio. O
  mundo estava certo (ele para 0,15 antes da calçada); a ORDEM é que não,
  porque uma casa levanta-se 20 px e o que vem depois cai-lhe em cima.
- **⚠️ CONTORNO DE TRAÇO ESTÁ FECHADO: as DUAS técnicas foram testadas e
  rejeitadas.** O Freestyle fecha o vazado da treliça e engorda peça pequena
  (30/08). O contorno pelo compositor — a saída que o plano propunha — foi
  construído e medido em 05/09, e falha por outra razão, mais funda: **este
  estilo desenha o detalhe COM fronteiras de valor** (o corrugado, as fiadas,
  as cantoneiras, porque a esta escala relevo não sobrevive ao
  antisserrilhado), e um filtro de borda procura exatamente fronteiras de
  valor — ele acha o desenho e desenha-o outra vez. Medido: a parede do galpão
  PERDE 14% de desvio local, e a treliça perde 21% de saturação com o traço
  rente à silhueta. **Quem faz o trabalho do contorno é o contraluz do rig de
  três pontos**, que separa a silhueta sem tocar no que está dentro do prop. A
  prova refaz-se com `gerar_props_iso.py --contorno`; não a ligue.
- **E na peça FINA o contorno apaga a COR, não a forma.** Vale para qualquer
  efeito de borda que venha a seguir: a silhueta da lança não mudou UM pixel
  (1133 opacos com e sem, vazados abertos) e ela saiu de laranja a castanho.
  Contar pixel de silhueta não mede o dano; medir saturação mede.
- **Prop NÃO é artefato byte-reprodutível, e o resto dos gerados é.** Os dois
  mapas, os sons e a tabela dos números têm de sair idênticos, e o CI compara.
  Um PNG de prop não: o denoiser do Cycles varia ±2/255 em algumas dezenas de
  pixels entre corridas, e os props que não estão em `SOMBRA` ainda levam um
  carimbo de data do Blender no PNG (os de `SOMBRA` escapam porque o
  `compor_sombra` os reescreve com o gravador do projeto). `cmp` num prop não
  responde "a imagem mudou" — para isso, compare os PIXELS.
- **E quem responde "este prop mudou?" é `tools/comparar_props.py`**, que reduz
  os dois a 16×16 — a mesma régua do bloco dos cascos distintos. Calibrado: duas
  corridas do mesmo código dão 0,000 e os PNGs diferem nos bytes (carimbo de
  data), um pixel de deslocamento dá 0,022, e um prop trocado por outro dá 0,42.
  ⚠️ **E A RÉGUA IRMÃ, NO TESTE DE DESIGN, NÃO FAZIA A MESMA CONTA** — com o
  mesmo comentário. O `comparar_props.py` faz a média (`reshape().mean`); a
  `_assinatura()` do D13/D17 fazia `Image.resize(16, 16, INTERPOLATE_BILINEAR)`,
  que numa redução de 48x **não faz média**, e o `TRILINEAR` mediu igual. Ela
  deu 0,0039 a dois camiões com 1.106 pixels diferentes (0,062 pela média).
  **Duas réguas com a mesma promessa conferem-se uma contra a outra no mesmo
  par** — e redução que tem de ser média escreve-se como média (`047`).
- A sombra de contato tem **azimute próprio (250°)**, diferente do azimute do
  mapa: no azimute do mapa ela cai atrás do prop e não se vê.
- **O importador de SVG do Godot é o ThorVG e não desenha `<text>`.** Texto no
  mapa é polígono de estêncil (ver `DIGITOS`).

### Áudio

- **Este contêiner NÃO tem placa de som.** Ninguém aqui consegue ouvir o que
  produz. Nunca escrever "o som ficou bom" num commit — escrever "toca no
  evento X, dura Y ms, roteado no bus Z", que é o que dá para provar.
- Som sai por `Audio.tocar(id)` — um ponto só, como `Icones.gd` para ícone.
  `AudioStreamPlayer` espalhado por cena é o que se está a evitar.
- **Pedir não é tocar.** Avançar o dia emite quatro sinais no mesmo frame; só
  o de maior prioridade soa. Cada som tem também uma espera mínima própria.
- Os WAV são **gerados** por `tools/gerar_sons.py` (sem dependência nenhuma) e
  forçados a PCM sem perdas — o Godot 4.4+ importa WAV como QOA por omissão,
  que é compressão com perdas.
- `tests/teste_audio.gd` cobre o que é verificável. Espera `AUDIO OK`.
- **E o SINAL dentro do arquivo é outra pergunta, com outra ferramenta.** O
  `teste_audio` responde pelo ENCANAMENTO — carrega, bus, sinal certo, espera
  mínima. Quem responde pela ONDA é `tools/medir_audio.py`, que espera
  `SINAL OK`: true peak, descontinuidade interna, espectro e a soma offline.
  Biblioteca padrão só, 1,5 s, no CI.
  ⚠️ **O MARCADOR NÃO PODE CONTER `AUDIO OK`**, e por pouco não conteve:
  "MEDIDA DE AUDIO OK" tem `AUDIO OK` como substring, e o passo do
  `teste_audio.gd` procura exactamente essa string — dois marcadores a casar no
  mesmo `grep` é o "FORA DO PORTÃO" outra vez. Daí `SINAL OK`.
- ⚠️ **PICO DE AMOSTRA NÃO É PICO.** Entre duas amostras a onda reconstruída
  sobe, e o conversor do aparelho toca essa subida. Medido num mutante: um
  arquivo com pico de AMOSTRA 0,950, zero amostras saturadas e as duas bordas
  em zero — verde por toda regra antiga deste projeto — mede **+2,50 dBTP** e
  satura no telefone. Quem pergunta é a sobre-amostragem 4x da BS.1770-4.
- ⚠️ **E A CONFERÊNCIA DE BORDAS NÃO VÊ O MEIO DO ARQUIVO.** Ela pergunta pela
  primeira e pela última amostra; um estalo no meio passa inteiro, com as duas
  bordas a zero. O que o apanha é o salto comparado com o p99,9 **do próprio
  arquivo** — comparação do arquivo consigo mesmo, que é o que a torna cega a
  o som ser suave ou percussivo.
  ⚠️ **E A SENSIBILIDADE DISSO VARIA 10x ENTRE ARQUIVOS**: o apito do navio,
  que é liso e grave, denuncia um salto de 0,05; o mar, o clique e a gaivota
  precisam de ~0,4. O corte está em 3,0 com 2,5x de folga acima do maior valor
  legítimo, e o que fica de fora está escrito ao lado dele.
- ⚠️ **SOMA OFFLINE NÃO É A MIX, e o que a autoriza lê-se do bus layout.** Os
  dois buses estão a 0 dB e sem efeito — conferido, não suposto —, e só por
  isso a soma dos true peaks diz alguma coisa. Ela é um TETO aritmético
  (+7,68 dBTP com três vozes), nunca uma previsão: a mix real tem fase,
  instante de entrada e o volume que o jogador escolheu.
- ⚠️ **SEIS DOS CATORZE SONS VIVEM ABAIXO DOS 500 Hz**, que é onde o
  alto-falante de um telefone começa a perder. O aviso (`sfx_ui_warn`) é o caso
  que interessa: duas notas de triângulo a 392 e 330 Hz, **99% da energia
  abaixo de 500**. Isto é DESCRITOR e não veredito — ninguém aqui mediu
  alto-falante nenhum, e o ouvido reconstrói fundamental a partir de harmónica.
  A pergunta está escrita em `docs/PROTOCOLO_DE_ESCUTA.md` §4, e é do Bruno.
- ⚠️ **E A RÉGUA DE ÁUDIO CALIBRA-SE ANTES DE MEDIR, senão o número mente por
  omissão.** Nenhum dos 14 arquivos chega perto de 0 dBFS, então uma régua de
  true peak que devolvesse só o pico de amostra passaria despercebida para
  sempre. O `--autoteste` corre ANTES de tudo e a ferramenta **recusa-se a
  imprimir medição** se ele falhar. Ele apanhou dois defeitos na própria régua
  no dia em que foi escrita: um ganho de borda (Gibbs num degrau, que era o
  TESTE errado e não o filtro) e um defeito injetado que caiu num cruzamento de
  zero e **não pegou**.

### Narrativa

- **Todo texto de fala vive em `scripts/Narrativa.gd`**, como o ícone vive no
  `Icones.gd`. Fala espalhada por painel é o que aconteceu com os emojis, e
  trocar um custava caçar string por string em sete scripts.
  ⚠️ **E O `get_script_constant_map()` NÃO A LÊ TODA.** A narração do fim de
  fase é um texto LOCAL do `fim_de_fase()`, e o mapa das constantes, que o F4
  usa, não o vê. Catálogo de fala que tem de ser completo lê o ARQUIVO — é o
  que faz a guarda do nome longo no F10 (`053`).
- **O nome do porto e o do jogador saem por `GameState.texto()`**, um lugar só,
  como o dinheiro sai pelo `moeda()`. Os textos trazem `{portName}` e
  `{playerName}`; quem não passar pela substituição mostra a chaveta crua ao
  jogador, e isso não dá erro nenhum. O `teste_fumaca.gd`, bloco F4, tranca:
  todo token tem de ser um dos seis conhecidos, e nada que saia de um
  resolvedor pode ter chaveta.
- **Porto Mirim é a CIDADE; Cais Mirim é o nome-padrão do PORTO.** São coisas
  diferentes e o rascunho de escrita usa as duas. O banco do Sr. Ribeiro é de
  Porto Mirim e não muda; o cais é o que o jogador batiza, e a escolha é
  irrevogável (GDD 7).
- **O nome do jogador pode estar vazio, e nenhum padrão o preenche.** Inventar
  um é pôr palavra na boca de quem não a escolheu. Toda fala com vocativo tem
  variante sem ele — e a vírgula viaja com o nome, senão sai "Boa tarde ,.".
- **Número em prosa sai de constante, nunca escrito à mão.** A narração de fim
  de fase dizia "Doze semanas / Três parcelas", que é a Fase 1 do GDD e não o
  VS. Texto com número cravado é um número a mais para envelhecer — o mesmo
  problema que a tabela dos números existe para resolver.
  ⚠️ **E O VALOR À MÃO COINCIDE COM A CONSTANTE NO DIA EM QUE É ESCRITO**, que
  é o que torna este defeito invisível: uma guarda que compare o NÚMERO passa
  contente (`moeda(400000)` é exactamente o que a prosa diz) e só divergiria na
  sessão seguinte. Quem o pega pergunta pela FORMA — nenhuma fala escreve `R$`
  seguido de dígito —, e é o que o F4 faz desde 11/09 (`docs/decisoes/018`).
- **⚠️ E A GUARDA QUE APANHOU ISSO COBRIA UM PERSONAGEM SÓ.** Em 13/09 o mesmo
  defeito estava vivo ao lado: `ARLINDO_VENCEU` e `ARLINDO_PERDEU` escritas
  desde 01/09 e nunca disparadas — a negociação fechava calada, ganhasse quem
  ganhasse —, e o F4 passava contente porque varre `CIDA_LINHAS` e mais nada.
  É a regra "ao corrigir um, VARRA OS IRMÃOS" aplicada a uma GUARDA em vez de a
  um prop: quem escreve a asserção para uma tabela pergunta logo quais são as
  outras tabelas da mesma forma, senão o defeito sobrevive à sua própria lição.
- **⚠️ FALA ESCRITA NÃO É FALA OUVIDA, e nada perguntava a diferença.** É o
  `barco_medio` na narrativa, e a terceira vez que este projeto o apanha:
  `perdeu_para_arlindo` e `bom_contrato` viviam em `CIDA_LINHAS` desde 01/09 e
  **nenhuma linha do projeto as disparava** — um quarto da voz da Dona Cida em
  jogo, mudo. O bloco do fumaça não podia apanhar, porque perguntava *"todo id
  da tabela tem fala?"*, lendo a tabela dos DOIS lados. A pergunta que pega é a
  inversa, e a sua segunda fonte é o `Main.gd`: a tabela vive na Narrativa e o
  gatilho no Main, logo não é espelho. **Ao escrever fala nova, escreva o
  gatilho no mesmo commit** — e ao varrer código como texto, corte as linhas de
  COMENTÁRIO antes, senão o próprio comentário que explica a armadilha
  satisfaz a busca.
- **⚠️ E FALA DISPARADA NÃO É FALA VISTA — a QUARTA cara do `barco_medio`.**
  A de cima pergunta se alguém a dispara, e alguém dispara. Esta é do outro
  lado do frame: **o que sobrou no `Label` depois de TODOS os emits daquele
  evento.** O `GameState` emite o sinal narrativo uma linha ANTES do
  `message.emit` da mesma chamada, e os dois escrevem no mesmo rótulo. Medido
  em 18/09, cinco sementes, partidas inteiras: `upgrade_pronto` escrita 35
  vezes e vista ZERO, `caixa_baixo` 11 e zero, `reputacao_caiu` 12 e zero.
  ⚠️ **E A MEMÓRIA É QUEIMADA JUNTO COM A FALA**: o `_cida_caixa` marca a
  travessia e o `_cida_semana` marca a semana mesmo quando a linha é tapada —
  não é "tapada", é consumida, e não volta naquela travessia.
  ⚠️ **E A REVISÃO CONTOU QUATRO PARES; ERAM CINCO.** Faltavam
  `_fechar_negocio` e `_perder_para_rival`, que chamam `_change_reputation()` e
  emitem `message` logo a seguir — é "ao corrigir um, VARRA OS IRMÃOS" com um
  SINAL no lugar do prop. Quem conserta um par procura os outros pelo PADRÃO
  (sinal seguido de `message.emit` na mesma chamada), nunca pela lista de quem
  já se conhece. O bloco **F8** do `teste_fumaca` tranca isto (`033`).
- **⚠️ E O PREDICADO DE UMA FALA LÊ-SE ONDE ELA É ESCRITA, não onde o sinal
  dispara.** `turn_advanced` sai ANTES de `_check_end() -> _spawn_boats()`, e o
  laço de serviço já esvaziou toda doca sem trabalhador: medido, em **315**
  viradas de turno `docas_esperando()` deu **zero todas as vezes**, e um
  instante depois deu barco à espera em **148 de 310** (48%). Uma variante que
  dissesse *"Barcos na fila"* no instante do sinal seria uma frase que ninguém
  jamais leria — o `barco_medio` outra vez, e desta vez a caminho de ser
  escrito de propósito. **Antes de condicionar uma fala, meça o predicado NO
  INSTANTE EM QUE ELA APARECE** — e se a condição nunca puder ser verdade ali,
  o que está errado é o momento, não a frase.
- **⚠️ E CONSERTAR A ORDEM EXPÕE AS FRASES QUE A ORDEM ESCONDIA.** `caixa_baixo`
  afirma *"A parcela não vai esperar"*, e `pagar_parcela_adiantado()` existe
  desde o playtest: medido com um perfil que quita assim que pode, **12
  travessias com a parcela já paga e ZERO com ela por pagar** — para esse
  jogador a frase era falsa em todas as ocorrências, e estava escondida pela
  mesma mensagem que a engolia. Um defeito de VISIBILIDADE e um defeito de
  VERDADE na mesma fala não se consertam em sessões diferentes: o primeiro
  mascara o segundo, e fechar só o primeiro entrega a frase falsa à tela.
- **⚠️ E DERIVAR O NÚMERO DA CONSTANTE PODE ESTRAGAR A PROSA.** A regra acima
  manda o número sair da constante, e está certa — mas `"%d semanas"` pôs
  **"4 semanas." e "32 turnos de decisão."** na narração de fim de fase, e
  dígito no meio de uma peça literária lê como leitura de instrumento. Pior: a
  guarda que provava a ligação comparava o DÍGITO, então era ela que mantinha o
  defeito de pé — reprovou o texto certo no dia em que ele foi escrito por
  extenso. Derive **e escreva por extenso** (`por_extenso()`), faça a guarda
  procurar a forma escrita, e acrescente a metade que falta: **nenhum dígito na
  narração**, senão ninguém impede o regresso.
- **⚠️ E FALA QUE AFIRMA O ESTADO TEM DE SER VERDADE NO PRIMEIRO TURNO.** O tom
  mau do boletim abre a dizer *"A semana anterior foi melhor"*, e o
  `tom_do_boletim()` escolhia-o só por `resultado < 0`, sem olhar se havia
  semana anterior. Medido em 12/09: quem aloca trabalhador nunca cai ali (0 de
  60 partidas), quem **não aloca ninguém cai sempre** (60 de 60, a −R$16.000) —
  ou seja, quem ouvia a frase errada era exatamente o principiante, no primeiro
  boletim que via. O estado que APERTA uma fala é o mais pobre, não o médio.
  ⚠️ **E o número dentro da fala sai de onde o EVENTO sai.** A mesma varredura
  achou *"Dois contratos recusados essa semana"* num gatilho que é a queda de
  FAIXA da reputação — nunca dois contratos. Não havia o que corrigir no
  número: ele não saía de lado nenhum.
  ⚠️ **E O TOM ESCOLHIDO POR UM NÚMERO AFIRMA MAIS DO QUE O NÚMERO.** O
  boletim escolhia o tom pelo resultado e pela média, e as falas afirmavam a
  semana ANTERIOR e a PARCELA. Medido em 23/09 com `tools/medir_boletim.gd`:
  **2.005 afirmações falsas em 4.000 boletins**, e *"a semana passada foi
  menos pior"* falsa em 856 de 856 — nunca verdade. Cada afirmação de uma fala
  tem de estar numa condição de quem a escolhe; e na régua, ⚠️ **afirmação
  que É a condição do tom é espelho** — ela só reprova quando lê um campo que a
  escolha não leu (`048`).
- **⚠️ FALA QUE NARRA O QUE A TELA JÁ MOSTROU É FALA QUE NINGUÉM PRECISAVA.**
  Queixa do Bruno em 23/09 sobre *"Mas vim pessoalmente porque sei que é o
  primeiro mês"*: o Sr. Ribeiro explicava o próprio gesto, pela segunda vez na
  mesma cena. Vale para toda fala já escrita e para as que vierem. Os sinais:
  abrir narrando o evento (*"Perdeu pro Arlindo"*, *"Os números fecharam"*);
  explicar o motivo do personagem; repetir na resposta o que a entrada ou a
  despedida já dizem; frase que qualquer personagem diria (*"o banco existe
  pra isso"*). **Cada linha traz o que a tela não diz** — um detalhe do mundo,
  uma opinião, um subtexto: *"ele pagava sempre na véspera; dizia que no dia
  já é tarde"* diz mais sobre o prazo do que *"vim pessoalmente"* (`048`).
- **⚠️ PALAVRA DE OFÍCIO NUMA FALA É JARGÃO, e nenhuma asserção a vê.** A
  leitura em voz alta de 19/09 apanhou "caixa": ele é o termo certo, está no
  HUD e no painel da parcela — e só quer dizer *dinheiro* para quem já
  trabalhou com ele. O jogo é de gestão para quem pode não saber finanças, e a
  palavra passou a ser "dinheiro" nas falas. É a irmã da regra abaixo: ali a
  frase é verdadeira em português e falsa neste mundo, aqui é verdadeira nos
  dois e ilegível para quem joga. Só uma pessoa a ler vê qualquer uma das duas.
- **⚠️ E CONDIÇÃO QUE UMA FALA JÁ APRENDEU, A IRMÃ DELA NÃO APRENDEU.** No
  mesmo dia: `caixa_baixo` tinha a variante para a parcela já quitada desde
  18/09, e a fala da SEMANA NOVA — escrita no mesmo commit, a ler o mesmo
  `caixa_curto()` — continuava a dizer "a parcela correndo" a quem já a tinha
  pago. "Ao corrigir um, VARRA OS IRMÃOS" com um PREDICADO no lugar do prop, e
  quem o apanhou foi o Bruno a ler, não uma suíte.
- **⚠️ FRASE QUE VAI AO GATE FOTOGRAFA-SE NO ESTADO EM QUE APARECE.** O A4
  carregou *"0 dias daqui"* por quatro dias como palavra a decidir, e ela nunca
  chegava à tela — a conta só dava zero depois do vencimento. Fotografado o
  painel no dia 32, o defeito era outro: *"1 dia daqui"* no próprio dia em que
  vence, porque a conta contava os dias que ainda se JOGAM (certo para o "N dias
  restantes" do HUD) e "daqui" pede a DISTÂNCIA. **O mesmo número serve a uma
  palavra e mente noutra**; antes de pedir uma decisão de redação, monte o
  estado e leia o que o jogador lê (`037`, T11).
- **⚠️ A FRASE PODE SER VERDADEIRA EM PORTUGUÊS E FALSA NESTE MUNDO.** A Dona
  Cida dizia *"porto que fecha no azul é porto que abre segunda-feira"* — bonita,
  idiomática, e **errada: um porto opera 24/7 e não abre na segunda.** Nenhuma
  das cinco suítes podia apanhar, e nenhuma régua de escrita também: não há
  token cru, não há número à mão, não há contradição interna. Só quem conhece o
  mundo vê. É a razão de o gate do A4 ser uma pessoa a LER, e não uma asserção
  — e a primeira leitura em voz alta (13/09) achou-a à segunda frase.
- **⚠️ E MELHORAR A PROSA PODE INTRODUZIR UM ERRO DE FACTO.** Na véspera, a
  narração de fim de fase dizia *"32 turnos de decisão"* — vocabulário de
  máquina, e trocá-lo por *"Trinta e dois dias"* foi uma melhoria de leitura
  real. Só que "turno" não promete calendário e "dia" promete: logo abaixo de
  *"Quatro semanas"*, a frase passou a afirmar que quatro semanas dão trinta e
  dois dias. **Dão vinte e oito.** O `TURNS_PER_WEEK` é 8 e a interface inteira
  já chamava turno de dia, então a contradição existia dispersa pelo jogo e só
  ficou visível quando os dois números se encostaram na mesma peça. Ao trocar
  uma palavra técnica por uma palavra do mundo, pergunte o que a nova palavra
  PROMETE — e se o resto do jogo cumpre a promessa.
- **⚠️ MANEIRISMO QUE APARECE UMA VEZ NÃO É MANEIRISMO — É TROPEÇO.** O Arlindo
  fechava a negociação perdida com *"sobrinho"*, e a primeira pergunta da
  leitura foi *"como assim sobrinho?"*. A palavra está CERTA e documentada — o
  GDD assina *"chama todo mundo de sobrinho ou querido, independente da
  idade"* —, e mesmo assim a intenção não chegou: no GDD ele fala assim em toda
  cena, no VS diz sete linhas e usa o maneirismo numa. **A dose é parte da
  escrita.** Antes de cortar o que soou estranho, conte quantas vezes ele
  aparece — pode faltar, e não sobrar.
  ⚠️ **E A CORREÇÃO DE ESCRITA É HIPÓTESE ATÉ A LEITURA SEGUINTE.** A de 13/09
  foi de dose — plantar o "querido" na abertura —, e a leitura de 23/09
  tropeçou no MESMO sítio: *"achei estranho ele chamar de sobrinho"*. A
  palavra saiu (é "meu caro", escolha do Bruno). Quem corrige uma queixa de
  leitura pede outra leitura; o raciocínio que justificou a correção não a
  prova.
- **⚠️ CONTAGEM QUE O JOGADOR LÊ CONCORDA A FRASE INTEIRA, e zero leva
  PLURAL.** `Narrativa.concordar(n, um, varios)` recebe as duas frases
  completas — "dia restante" / "dias restantes" —, e não substantivo e adjetivo
  em separado: concordá-los dentro da função obrigaria-a a saber género e a
  distinguir "restante" (que muda) de "esperando" (que não muda), que é um
  dicionário de português. ⚠️ **O singular é SÓ em `n == 1`**, e o zero é o
  ÚNICO estado em que um `n <= 1` escrito por distração diverge — com 1, 2 e 32
  as duas versões dão o mesmo texto (`docs/decisoes/037`).
  ⚠️ **E A BUSCA PELA PEÇA ACHA MENOS DO QUE A BUSCA PELA FORMA.** A revisão
  nomeou TRÊS rótulos; o `grep` por `(s)` achou **cinco** (dois deles no
  `GameState.gd`, que ninguém tinha aberto); e o `grep` pela FORMA achou
  **oito** — os últimos três escreviam a concordância com um ternário à mão
  (`"" if n == 1 else "s"`), com saída certa e a regra duplicada em cinco
  sítios. Num deles a MESMA condição estava escrita duas vezes na mesma
  expressão, uma para o substantivo e outra para o particípio. Hoje quem
  pergunta é o bloco **F9** do `teste_fumaca`.
- **⚠️ QUEIXA DE ESTRANHEZA PODE SER LACUNA, e aí não há rótulo a corrigir.** A
  triagem leu *"é estranho o porto ter dívida mas o jogador começar com
  R$400.000"* como um nome errado e propôs chamar EMPRÉSTIMO ao caixa — que
  contradiz o que o Sr. Ribeiro já diz (*"O Seu Maneco assinou isso. Agora é
  seu"*: a dívida é do avô) e poria o banco a cobrar 32,5% em quatro semanas.
  Não faltava rótulo: **faltava uma frase a dizer de onde vem o dinheiro**, e
  ela nunca existiu. Antes de renomear o que o jogador achou estranho, leia o
  que o jogo já diz sobre aquilo — a resposta costuma estar meia escrita.

### Interface

- **Tela nova é OVERLAY, nunca fase do `GameState`.** Uma fase nova que bloqueie
  o turno não dá erro nenhum: o `advance_turn()` retorna calado fora de
  `"playing"`, e o laço do `simular_balanceamento.gd` só sabe resolver
  `rival_offer` e `debt_payment`. Medido: uma fase a mais fez **24 de 30
  partidas não terminarem**, e o CI passava na mesma porque só procurava a
  linha `=== Leitura ===`. Hoje ele também reprova `possível travamento`, mas a
  regra vale antes do CI: como overlay, o balanceamento medido fica intocado
  **por construção**, e não por cuidado de quem escreveu.
- **Fala de personagem vai em BALÃO, informação do jogo não.** As telas
  narrativas misturam dois registros e, sem diferença visual, a fala da Dona
  Cida lia como rodapé de planilha. A variação `Fala` do tema (creme com barra
  âmbar à esquerda) é o balão; `RotuloSecao` é o rótulo que guia e sai da
  frente; `RotuloTotal` é a linha única que o olho tem de encontrar primeiro —
  duas em destaque é nenhuma em destaque.
- **Linha com valor zero não entra em tabela.** O boletim mostrava
  `Armazém R$0` e `Parcela R$0` nas semanas em que não havia nem um nem outro:
  ruído que o olho descarta toda semana para chegar ao que mudou.
- Painel novo herda de `PainelNarrativo.gd` — o andaime (escurecer, cartão,
  título, parágrafo, botão, seção, total, fala, fio) num lugar só. `montar(largura, 0)` faz o cartão
  **ajustar-se ao conteúdo**; altura fixa só quando há área de rolagem. Três
  painéis saíram com uma faixa branca debaixo do botão por causa disto, e o
  mesmo painel muda de tamanho conforme o caso.
- **Tela que abre SOZINHA passa pela vez** (`_na_vez()` no `Main`). Três
  sinais do mesmo instante abriam três painéis empilhados, e o toque só
  alcança o de cima: a resposta do Sr. Ribeiro ficava por baixo do fim de
  fase, que oferece «Jogar de novo». Quem tem a vez fica na tela, os outros
  esperam por ordem de chegada, e a vez passa pelo `tree_exited`, que é por
  onde passa TODA saída de painel — o `fechou` não passa pelo `remove_child`
  das ferramentas, e aí o turno ficou preso sem painel (`054`).
- **Mecânica nova precisa de um sítio onde se LEIA, ou não existe.** A trava do
  nível do navio (06/09) seria invisível — o jogador veria o navio grande
  deixar de aparecer sem saber que é o porto dele que não o aguenta. Hoje o
  painel Construir abre com "Porto nível 1 — recebe pesqueiro / Ainda não
  aguenta: cargueiro, navio de longo curso", e a linha PERCORRE a tabela das
  classes em vez de as listar à mão. É a mesma regra do motivo no cartão da
  doca, e a mesma do `barco_medio`: o que o jogo tem e não mostra não conta.
- Nada de interface pousa sobre o mapa. Uma doca tem duas metades:
  `Dock.tscn` (cenário) e `DocaCartao.tscn` (texto e alvo de toque).
- **⚠️ O PAINEL É BRANCO E A COR NEUTRA DO JOGO É PARA FUNDO ESCURO** — e isto
  já mordeu TRÊS vezes com a mesma cor. O cinzento-azulado 0,51/0,6/0,706 mede
  **2,93:1** sobre branco, abaixo do corte de texto GRANDE da WCAG (3,0), e
  todo texto de painel é menor do que isso. Foi apanhado no calendário em
  03/09, e o painel Construir carregava-o em OITO rótulos até 06/09 sem que
  nada perguntasse. Sobre branco use 0,35/0,42/0,50, que mede 5,46:1 e passa o
  AA. O bloco **D19** do teste de design percorre os rótulos e mede.
  ⚠️ **E FORAM QUATRO, E À QUARTA ELA VEIO PELO TEMA.** Em 20/09 a mesma cor
  estava na linha `RotuloSecao` de `tema_brport.tres`, que vive em NOVE painéis
  — e as três guardas de contraste que havia percorriam **um painel cada** (o
  D19 o Construir, o D23 o menu-celular, o D32 a faixa de mensagem). **Guarda
  que pergunta por um sítio não responde pelos outros treze**, e um defeito que
  desce do tema toca em todos de uma vez. Medidos os 19 estados, reprovavam
  **22** textos por **quatro** causas distintas, e a revisão externa nomeava
  uma. Hoje quem percorre tudo é o **D33**, e `tools/medir_contraste_ui.gd`
  imprime a tabela do mesmo motor (`docs/decisoes/035`).
  ⚠️ **E O QUINTO ENDEREÇO NÃO ERA UM RÓTULO**: era a SUGESTÃO do campo
  (`font_placeholder_color`), a 2,70:1, que as quatro caças anteriores não
  citavam por não estarem à procura de um `LineEdit`. Ao varrer uma cor,
  pergunte que OUTROS papéis de texto existem além do rótulo.
  ⚠️ **E "O PAINEL É BRANCO" NÃO É O FUNDO REAL.** A mesma variação mede
  5,46:1 no cartão, **5,03:1** no balão da fala (#f0f6ff) e **5,27:1** no creme
  da faixa; o neutro media 2,93 no cartão e **2,70** no campo. Mede-se contra o
  `bg_color` composto alfa sobre alfa até ao primeiro opaco, com o `modulate`
  aplicado ao texto e ao fundo por cadeias SEPARADAS — são duas, porque começam
  em nós diferentes.
  ⚠️ **E COMPOSIÇÃO QUE NÃO FECHA É PENDÊNCIA, NUNCA VERDE.** Onde o que está
  por trás é desconhecido — o cartão da doca tem alfa 0,96 e pousa sobre o
  MAPA —, a resposta honesta são DUAS: o pior sobre preto e o pior sobre
  branco. Se as duas pontas concordarem em passar, passa; se discordarem,
  reprova e vai à mão. Escolher a ponta que convém é a irmã de arredondar para
  aprovar.
- **⚠️ A ISENÇÃO DA WCAG PARA TEXTO INATIVO PODE ENGOLIR O MOTIVO DO
  BLOQUEIO.** A 1.4.3 isenta o texto de um componente desligado, e a isenção é
  legítima — o desastre é quando a única frase que explica POR QUE ele está
  desligado é o rótulo dele. O painel Construir fazia `btn.text = ... else
  impedimento`: a explicação saía a **2,16:1** e uma régua correta dava-a por
  isenta com razão. E não se conserta acrescentando uma linha (o cartão já
  crescia a ~920px numa tela de 1280, com o "Fechar" rente à borda):
  conserta-se **tirando o botão**, que é um convite falso — o cartão ficou
  60px mais curto. A pergunta que separa o caso bom do mau **deriva do
  percurso**: a forma do rótulo inativo tem de aparecer VIVA nalgum estado.
  "Pagar R$…" aparece, logo descreve a AÇÃO; "Precisa antes de: …" só existe
  bloqueada, logo é a EXPLICAÇÃO. A primeira versão da guarda perguntava "o
  painel tem algum texto legível?", que é confiança de graça — todo painel tem
  um título, e ela passava com o defeito posto (`docs/decisoes/035`).
  ⚠️ **E UMA BORDA TEM DUAS ADJACÊNCIAS, e medir só uma engana.** Texto tem um
  fundo; uma borda tem o que está DENTRO e o que está FORA, e o número muda de
  veredito entre os dois. Medido no pixel da captura em 22/09, a borda do
  trabalhador escolhido dá **7,37:1** contra a barra escura por fora e
  **2,24:1** contra o fundo do cartão por dentro — a primeira leitura da
  sessão publicou o 2,24 como se fosse «a» medida e concluiu que a seleção
  quase não se via. Vê-se: o corte de 3,0 da WCAG **1.4.11** (o que identifica
  ESTADO de componente, e não o 4,5 do texto) passa com folga por fora. O que
  ficava abaixo era outra pergunta — distinguir os dois ESTADOS pela cor, 2,26:1
  entre o âmbar e o verde de repouso —, e quem a responde é a LARGURA, 2px para
  4px. **Antes de julgar uma borda, diga contra QUAL dos dois lados mediu, e
  separe «vê-se a fronteira?» de «distinguem-se os estados?»** (`045`).
  ⚠️ **E NENHUM TOM GANHA DOIS FUNDOS — na interface, quem resolve é trocar
  TEXTO por FUNDO.** É a regra do pau-de-carga (*"UM PROP SÓ ATRAVESSA DOIS
  FUNDOS"*) com um rótulo no lugar do prop. O âmbar de marca mede 2,39:1 sobre
  o cartão branco, e escurecê-lo até passar o AA (5,06:1 a V=0,58) custa a
  separação contra o navy à volta, de 5,27:1 para **2,49:1**. Aceitou-se, e a
  razão é a mesma da telha: **quem separa ali é o MATIZ, não o valor** — estão
  a ~180° um do outro, e a captura confirma. Quem quiser a separação de volta
  não muda a cor, muda a MASSA: âmbar de FUNDO com texto navy mede 5,27:1 e já
  existe no `BotaoPrimario`.
  ⚠️ **E ISSO TEM CONTA: um tom ENTRE dois vizinhos só passa 3:1 contra os dois
  se eles estiverem a 9:1 um do outro**, e abaixo disso o melhor possível é a
  raiz da razão entre eles. A borda do trabalhador escolhido fica entre o verde
  que substitui e o fundo claro, a 5,05:1 — e o âmbar já estava nos 2,25 da
  raiz: "subir a cor" não tinha para onde ir. Faça a conta ANTES de varrer
  cores. Quem deu a troca pela cor foi a MASSA — um selo no rótulo, e não o
  cartão inteiro, porque o retrato tem a luminância do âmbar escuro (0,149
  contra 0,158) e sumia nele: **fundo escolhe-se também contra a ARTE que mora
  nele**, que o D33 não mede (`050`).
- **⚠️ «ESTA COR É LEGÍVEL?» E «DE ONDE VEIO ESTA COR?» SÃO DUAS PERGUNTAS, e
  quem só tem a primeira acrescenta cor à mão sem ver.** Medido em 21/09: no
  MESMO commit em que migrou três overrides para o tema, o R6 **acrescentou um
  quarto** — e o D33 estava certo em deixá-lo passar, porque a cor nova mede
  5,46:1. O briefing seguinte anunciou "ficaram 18", que é 21 − 3 feito de
  cabeça; contado no HEAD eram **19**. Hoje quem pergunta a segunda é
  `tools/conferir_escopo_ui.py` (`ESCOPO UI OK`), e o registro das exceções é
  `tools/excecoes_cor_ui.json` (`docs/decisoes/036`).
  ⚠️ **E A SUPERFÍCIE ERA O DOBRO DO QUE SE DIZIA, porque cor de interface não
  chega só por chamada.** Contado no que o jogo exporta: 19
  `add_theme_color_override`, mas também **10 `theme_override_colors/*` em
  cena**, **4 cores de `StyleBoxFlat`** em `sub_resource` e **1 pintada num
  StyleBox em código** — 34 ao todo, e as 15 últimas nunca tinham sido contadas
  por ninguém. Todo inventário anterior procurava a CHAMADA.
  ⚠️ **E A EXCEÇÃO DECLARA-SE PELO TRIO (arquivo, receptor, propriedade), COM
  CONTAGEM.** Por arquivo a ficha proíbe — e foi por arquivo que a chamada nova
  passou, já que aquele arquivo tinha outras. Por LINHA não, que é a regra do
  número em pixel escrito à mão com outra roupa. E a CONTAGEM entra na chave
  porque sem ela uma segunda chamada da mesma forma — mesmo nó, mesma
  propriedade, mesma cor — passa por declarada.
  ⚠️ **E A LEVA ESCOLHE-SE PELO QUE A RÉGUA ALCANÇA, nunca pelo tamanho
  dela.** Migrar uma cor que o portão de contraste não monta troca dívida
  VISÍVEL por invisível: o verde do `UpgradePanel` só existe com estrutura
  construída e o âmbar do `DocaCartao` só com doca sob oferta, e o percurso não
  monta nenhum dos dois. A primeira leva foi a barra escura por ser a única em
  que ele já media tudo menos um estado — e esse ganhou-se ANTES de a cor
  migrar, que é a ordem (`docs/decisoes/041`).
  ⚠️ **E «JÁ É MEDIDO PELO D33» É AFIRMAÇÃO A CONFERIR, NUNCA A HERDAR.** O
  registro de exceções afirmava que o contraste dos QUATRO estados da faixa de
  mensagem já era medido, e o briefing da conversa repetia-o. Medido: o
  `_message_label` dava **três linhas em 237**, e as três eram o mesmo estado
  NEUTRO — os outros três nunca tinham sido medidos, e um deles reprovava. A
  afirmação perigosa é a POSITIVA: quando uma entrada diz que o estado NÃO é
  alcançado, a régua confirma-a ao não publicar a linha; «já é medido» só se
  confere CONTANDO as linhas na tabela (`docs/decisoes/042`).
  ⚠️ **E FALA DISPARADA NÃO É FALA VISTA — VALE PARA A RÉGUA DO CONTRASTE.** A
  `033` registou isto para o jogador; a régua caiu no mesmo buraco, por duas
  razões que se somam. O `acao` do percurso corre ANTES de a cena existir, logo
  o `message` que ele provoca sai para ninguém; e mesmo emitido depois, o texto
  entra numa FILA com tempo mínimo, e o que fica no rótulo é a mensagem de
  ABERTURA. Medido: o estado "HUD (nada parado)" tinha uma mensagem BOA presa
  com `pendentes() == 1`, e a régua publicava a neutra de trás dela — uma linha
  com razão e veredito, a descrever OUTRO estado. **Quem mede uma tela que tem
  fila, drena a fila.**
  ⚠️ **E DRENAR SÓ NO FIM NÃO CHEGA, porque a fila ordena por PRIORIDADE.**
  `bad > warn > good`, então duas ações seguidas entregam na tela a de MENOR
  prioridade e não a última: medido, com um dreno único no fim o caso do aviso
  publicava o VERDE da ação anterior. Drena-se depois de CADA ação, que é
  também a ordem em que o jogador as veria.
  ⚠️ **E A FORMA DO CÓDIGO ESCOLHE-SE PELO QUE A RÉGUA ALCANÇA.** O `_pintar()`
  ia trocar quatro ramos por um dicionário com `.get()` — mais arrumado, e
  invisível ao portão: o `conferir_escopo_ui.py` procura
  `theme_type_variation = "<nome>"`, e num dicionário o nome não está depois do
  `=`. As quatro variações ficariam fora da guarda que existe para as conferir,
  e um erro de digitação cairia no `Label` base **sem uma palavra** — a
  armadilha escrita no cabeçalho do próprio portão. São quatro literais
  `&"..."`, como a `041` já escrevia.
  ⚠️ **E ONDE A VARREDURA DE TEXTO NÃO ALCANÇA, QUEM ALCANÇA É UMA PERGUNTA EM
  RUNTIME.** A regra acima diz para escolher a forma do código pelo que a régua
  vê; esta diz o que fazer quando a forma já está escrita e não se pode mudar.
  O `DocaCartao` punha a variação do painel por
  `theme_type_variation = StringName(variacao)` — o mutante X6 da `042` VIVO em
  produção, e medido: com o nome trocado à mão, o portão do escopo sai
  **verde**. Nenhuma regex o apanha, porque a expressão é dinâmica. Quem o
  apanhou foi uma guarda que lê o NÓ MONTADO e pergunta que variação ele está a
  vestir: a regex lê a intenção, a guarda lê o resultado, e o resultado não tem
  como ser contornado por forma de código nenhuma (`docs/decisoes/043`).
  ⚠️ **E ESTADO QUE NÃO MONTA PUBLICA LINHAS PLAUSÍVEIS — é a irmã de «fala
  disparada não é fala vista», um andar acima.** Ali a régua media o texto
  errado; aqui ela mede o ESTADO errado, e o caso que o pediu não se queixa: ele
  monta, mede, e publica linhas verdadeiras sobre outra coisa. O percurso do D33
  montava a oferta do rival escrevendo `docks[d]["rival_offer"]`, **uma chave
  que ninguém no projeto lê** — a irmã do `.get(chave, omissão)`, do lado de
  quem ESCREVE —, e o cartão da doca nunca chegou ao quarto fundo dele. Medido:
  com a guarda retirada, o mesmo arquivo fica VERDE e a tabela publica o estado
  «sob oferta do rival» a mostrar a cor CALMA. **Caso que declara um estado
  prova que o obteve**, e a prova é DERIVADA — vai ver a consequência no nó —,
  nunca declarada ao lado dele.
  ⚠️ **E O PISO DESSA PROVA PODE PASSAR: a contagem tem de ser EXATA.** A
  guarda irmã, no painel Construir, contava os rótulos verdes e pedia `>= o
  número de estruturas compradas`, para não se prender ao desenho do cartão.
  Medido: tirar a variação de UM dos DOIS rótulos de uma estrutura deixa a
  contagem a cumprir o piso, e o rótulo órfão cai no `Label` base, que sobre o
  cartão branco mede 12,58:1 e **passa o contraste**. Nada o via. É a condição
  que a regra do «segundo defeito» nomeia, cumprida em vez de invocada — o
  teto aperta-se quando o defeito seguinte cai fora dele E nada de legítimo cai
  dentro, e uma contagem determinística não tem ruído para a proteger. Escreva
  ao lado o preço: quem acrescentar um rótulo sobe o número de propósito
  (`docs/decisoes/044`).
  ⚠️ **E AGIR PARA ALCANÇAR UM ESTADO CAI DOS DOIS LADOS DO FRAME.** Parece um
  mecanismo só e são dois opostos: a faixa de mensagem precisa da ação DEPOIS
  da cena, porque o texto vive numa fila com tempo mínimo; o painel Construir
  precisa dela ANTES, porque lê o `GameState` enquanto se monta. O `acao_vista`
  nem sequer serve a um painel — exige que a cena TENHA fila para drenar, e um
  painel não tem. Antes de reaproveitar o mecanismo que destravou o estado
  anterior, pergunte de que lado do frame o novo é lido.
  ⚠️ **E VERIFICAÇÃO QUE SE IA PROMOVER A REGRA GERAL PROCURA-SE PRIMEIRO A
  EXCEÇÃO.** `comprar_estrutura()` devolve `false` calado, e a tentação era
  reprovar toda ação do percurso que devolvesse `false`. Medido antes de
  escrever: o caso do aviso da faixa chama `assign_worker` **para ser
  recusado** — é a recusa que emite a mensagem que ele mede —, e a regra cega
  teria reprovado o que está certo.
  ⚠️ **E O REGISTRO DIZ ONDE A COR É DECLARADA, NUNCA QUEM CONSOME A PEÇA QUE A
  CARREGA.** O stylebox `pilula` tinha duas cores declaradas e CINCO
  consumidores — as quatro pílulas por `styles/panel` e o botão Pausar por
  `styles/normal` —, e o portão não podia dizê-lo, porque uma referência ao
  stylebox não é uma cor. Movê-lo para o tema pelo inventário das CORES deixou
  o `Main.tscn` sem carregar. Antes de mover uma peça de estilo, procure todo
  `SubResource("<id>")`: a peça tem consumidores que a cor não tem. E um
  `Button` não veste variação de `PanelContainer`.
  ⚠️ **E O FUNDO VERIFICA-SE PELA FRENTE.** Guarda nenhuma aqui mede a cor de um
  FUNDO; o que se mede é o texto CONTRA ele. Logo a prova de que uma variação
  de stylebox chegou mesmo aos nós é pintar o stylebox de outra cor e ver as
  razões moverem-se em bloco — 12 reprovas, que são 4 números × 3 estados.
  ⚠️ **E VARIAÇÃO QUE EMPACOTA TAMANHO COM COR NÃO SERVE A QUEM SÓ QUER A COR.**
  O `RotuloSecao` traz `font_size = 13`, e os quatro rótulos que pediam a cor
  dele medem 12, 13, 15 e 12 px: vesti-los dele encolheria três e mexeria no
  leiaute que o D18 e o D22 medem, numa migração que só devia mexer na COR. Daí
  o `RotuloApoio` ser **só cor** — o irmão do `RotuloAlerta`, que já não declara
  tamanho pela razão simétrica. Duas variações com o mesmo valor não são a
  divergência calada que se veio acabar quando a diferença entre elas é
  ESTRUTURAL; o `COR_PASSADO` a 0,52 contra os 0,50 do tema era cosmética, e
  por isso foi **apagado** em vez de renomeado.
  ⚠️ **E `theme_type_variation` PARA UMA VARIAÇÃO QUE NÃO EXISTE NÃO DÁ ERRO** —
  cai no tipo base e sai com a cor errada, que é a irmã do valor de Godot 3 numa
  chave de Godot 4. O portão exige que toda variação usada esteja no tema.
- **Texto que passa a vir de uma TABELA cresce, e Label que não cabe não dá
  erro — corta.** O motivo da escala pôs no cartão da doca uma palavra vinda de
  `MOTIVOS`, e "Armazenagem" tem quase o dobro de "Granel". Medido: o interior
  do cartão dá 200px, e o nome mais longo no CABEÇALHO, ao lado do valor a
  19px, pede 233 — sairia cortado na captura sem nada a apontá-lo. Quem põe
  texto de tabela na interface mede o PIOR CASO montado à mão, e não o que os
  três cartões calham mostrar: um deles diz "aguardando barco" e passaria
  sempre. O bloco D18 do teste de design faz essa conta.
- **⚠️ E O `size` DO RÓTULO NÃO É O QUE ELE DESENHA.** `AUTOWRAP_WORD` só
  quebra em fronteira de palavra, e a tela de nomes aceita 24 letras sem
  espaço: com elas «Boa tarde, WWWW…» passava por FORA do cartão com o
  retângulo do rótulo intacto. Quem mede o desenho é `get_character_bounds()`,
  e o controle que o prova é medir pela caixa com o defeito posto — ficou
  VERDE. Fala que leva nome quebra por `AUTOWRAP_WORD_SMART`, que num texto sem
  palavra longa dá as mesmas linhas ao pixel (`051`).
- **⚠️ E ÁREA ROLÁVEL NÃO CORTA — ESCONDE, que não deixa marca.** A regra acima
  é sobre `Label` que corta; num `paragrafo_rolavel` o que não cabe desce para
  baixo da dobra sem sinal nenhum. Acrescentar quatro linhas ao diário (~100px)
  fez a primeira tela acabar a meio de *"Talvez o avô soubesse o que tava
  fazendo quando"* — a frase que FECHA o texto —, com o botão logo abaixo a
  convidar a sair sem rolar. **As cinco suítes passaram; quem apanhou foi a
  captura.** Altura de painel com texto é CALIBRADA contra o texto, e o
  `PainelDiario` até dizia no comentário que já tinha sido medida uma vez: quem
  cresce o texto refotografa o painel e confere qual é a última linha visível.
  ⚠️ **E A ALTURA ESCRITA À MÃO ESCONDEU METADE DA PEÇA DURANTE ONZE DIAS.** A
  lição acima foi aprendida no diário em 11/09 e remediada lá; o painel IRMÃO —
  o fim de Fase 1, o mesmo `paragrafo_rolavel` — nunca foi reaberto. Ele dava
  430 px a um texto que pede **847**: o remate (*"Em quem tá olhando."*, a linha
  para onde a peça inteira anda) nunca esteve na tela sem rolar, com o botão
  logo abaixo a convidar a sair. É a regra "ao corrigir um, VARRA OS IRMÃOS"
  a cobrar a fatura — e a correção certa não é medir outra vez à mão: a altura
  passou a sair de `altura_do_texto()`, e o **D22** tranca-a.
  ⚠️ **E MEDIR TEXTO PEDE O `line_spacing` POR FORA.** O
  `get_multiline_string_size()` devolve só a soma das linhas; o `Label`
  acrescenta o espaçamento ENTRE elas. No fim de fase isso são 99 px em 847
  (33 × 3) — ~12% —, e a conta sem eles esconde a última dobra, que é o mesmo
  defeito a reaparecer dentro da função escrita para o acabar.
- **⚠️ E O PAINEL SÓ É BRANCO ENQUANTO FOR UM CARTÃO.** A regra acima tranca a
  cor NEUTRA sobre o branco; esta é a outra ponta, e apareceu no menu-celular de
  13/09, a primeira tela deste jogo com fundo escuro: a cor de texto **padrão**
  do tema é navy, porque os doze painéis anteriores eram cartões brancos, e
  sobre a tela do aparelho ela sai navy sobre navy — **1,18:1**, invisível, sem
  erro nenhum. Tela de fundo escuro leva variações de rótulo próprias, e o
  **D23** mede-as (o neutro do jogo dá 5,05:1 ali, que é a primeira vez que ele
  está no fundo para o qual foi feito).
- **⚠️ O PIOR CASO DE UM RÓTULO SAI DO QUE O JOGO ESCREVE, não de um texto
  suposto.** Irmã do D18, um passo antes: ali a lição é medir o pior caso em vez
  do que os três cartões calham mostrar; aqui é que **o pior caso também não se
  inventa**. O D23 montou à mão `"Construir · 7 estruturas"` e o jogo escreve
  `"Construir · 7 disponíveis"` — a palavra real é mais longa (240 px contra
  235), e a asserção media um caso mais fácil do que o que o jogador vê. Quem o
  apanhou foi a CAPTURA. Monte o estado, e leia o `text` de quem o escreve.
- **⚠️ MEDIR LARGURA DE `Control` TEM DUAS ARMADILHAS, e as duas dão folga que
  não existe.** (a) **`custom_minimum_size` menor do que o conteúdo é
  IGNORADO** — o botão de menu declara 46 e ocupa 54, porque o ícone de 26 mais
  as margens de 14+14 do tema pedem mais; e o defeito injetado que baixava o
  mínimo **não pegou nada**, porque não mexia no que a guarda mede. (b) **`size`
  de um painel acabado de instanciar é o tamanho MÍNIMO**, e num `Button` o
  mínimo sai do próprio texto: `pede <= botao.size.x` passava com 5 px de folga
  e não reprovava alargar o vizinho, porque o esperado e o medido saíam da mesma
  fonte. É a armadilha do espelho em forma de pixel. Derive a largura do
  CONTENTOR — a linha menos o irmão menos a separação — e peça
  `get_combined_minimum_size()` quando quiser o que uma peça ocupa mesmo.
- **⚠️ NUMA GRELHA, UM NOME COMPRIDO ALARGA UMA COLUNA E NÃO TODAS.** Custou um
  defeito injetado que falhou **por 4 px**: com cinco apps em três colunas, o
  nome longo caía sozinho na coluna dele, então a conta não é `3 × maior`, é a
  soma dos máximos por coluna. Ao montar o estado que aperta uma guarda de
  grelha, pergunte em que COLUNA o defeito cai.
- **⚠️ E PROPORÇÃO É O QUE FAZ UMA METÁFORA LER — antes do ícone e antes da
  moldura.** O menu-celular nasceu com o `montar(largura, 0)` do andaime, que
  ajusta a altura ao conteúdo, e saiu **400 × 390**: com cantos redondos, borda
  e grelha de apps, lia-se como mais um cartão. A **680** (1:1,7) ninguém
  pergunta o que é. É a única altura fixa deste projeto que não é defeito, e a
  diferença está escrita na constante: a faixa branca que mordeu três painéis
  era cartão SEM CONTEÚDO; ali é a tela de um telefone com lugar para o que vem.
- Alvo de toque mínimo 44px. O teste de design cobre.
- Dinheiro sai por `GameState.moeda()` — separador de milhar, um lugar só.
- O tema (`ui/tema_brport.tres`) é o ponto único de estilo. Script não pinta
  cor na mão.

---

## O que cabe numa sessão

Uma sessão que tenta fazer tudo entrega tudo pela metade, e a seguinte não sabe
o que ficou por acabar. Meia página para evitar isso.

⚠️ **E O TETO DO ESTADO RECUSA DEPOIS DE O COMMIT ESTAR ESCRITO, que é o
momento em que menos apetece parar.** Em 14/09 o fecho encadeou
`conferir_docs.py && git commit` sem olhar: o conferidor reprovou por 202 bytes,
o `&&` não segurou nada porque o commit vinha de um comando à parte, e a sessão
empurrou com o CI vermelho. Comprimir custou três minutos e não dependia de
pensar em nada — **o custo era só a vontade de ter acabado**. Num fecho, rode
TODAS as verificações e leia o código de saída de cada uma **antes** de escrever
a mensagem de commit, e nunca no mesmo comando que ela.

**Uma sessão fecha com o `ESTADO_DO_PROJETO.md` em dia, ou não fecha.** É o
único artefato crítico que nenhum teste protege — e quando envelhece, a sessão
seguinte trabalha com uma fotografia errada. Em 02/09 ele tinha dobrado de
tamanho sem ninguém decidir, e carregava dentro DUAS parcelas do Sr. Ribeiro
(R$8.000 e R$550.000) e três respostas diferentes para "por onde começo", todas
lidas como atuais. Hoje `tools/conferir_docs.py` toca o alarme antes de dobrar
outra vez, mas o alarme não escreve o documento.

**Prometa UM item da fila, não três.** A fila da §7 do plano é ordenada, e os
itens têm tamanhos honestos: um item por sessão é o ritmo que os últimos blocos
mediram. Sobrou tempo? Comece o seguinte e diga onde parou — melhor do que três
metades.

**Meça antes de codar, e o custo de medir quase nunca é o que se supõe.** Três
vezes em dois dias a suposição estava errada e nas três para o lado caro: a
barra de reputação que se ia afinar já estava saturada no teto; as 600 partidas
que se evitavam por "demorarem minutos" levam 26 segundos; e a `/arte` foi
adiada por "precisar de 1 GB de `bpy`" quando metade das etapas não precisa de
Blender nenhum e o conferidor de lote precisa de `numpy` + `pillow`, que
instalam em 8. Rodar a ferramenta antes de decidir é mais barato do que
discutir o que ela diria.

### Qual MODELO faz o quê — Sonnet por omissão, Opus para decidir

`docs/decisoes/016`. **Sonnet 5 custa 2,5× menos do que Opus 5 nas duas
pontas**, e este projeto usava Opus em tudo. O eixo que divide NÃO é "difícil
contra fácil" — escrever um script de medição parece mais difícil do que olhar
para um render, e é o contrário. **O eixo é quem ESCOLHE.**

**A omissão é Sonnet.** Ele faz o que já foi decidido, e o projeto tem a receita
escrita: rodar as suítes e ler o código de saída de cada uma; regerar mapas,
props, sons e a tabela dos números; `--import`, capturas, recortes, folhas de
contato e o antes/depois; aplicar uma alteração de cor, ângulo ou proporção JÁ
escolhida e medir o que foi pedido; arrastar o rasto de prosa a partir de uma
decisão já escrita; comprimir o `ESTADO_DO_PROJETO.md` para caber no teto;
`grep`, inventário e `conferir_docs.py`; consertar vermelho de causa óbvia
(import a faltar, caminho errado, `.import` por commitar); commit e push.

**Sobe para Opus quando a sessão tem de DECIDIR:**

- diagnosticar uma queixa que não diz o que corrigir — *"o design pode ser
  melhorado"*, *"está sem graça"*, *"parece avançado demais"*;
- escolher a gramática de um prop, ou o que substitui uma peça que não lê;
- **escrever asserção nova e escolher o defeito injetado** (ver abaixo);
- ler uma medição que contrariou a previsão e decidir o que ela quer dizer;
- qualquer `# TUNING:`, e a leitura das 600 partidas;
- reabrir decisão registada, ou mexer em contrato entre arquivos — projeção,
  `MEIA_LARG`, `RUA_RECUO`, enquadramento, `SAVE_VERSION`;
- triar playtest e ordenar a fila;
- escrever `docs/decisoes/NNN` e a varredura de lições do `/fechar-sessao`.

⚠️ **O DEFEITO INJETADO NUNCA DESCE, e é por medição.** A regra 7 acima tem doze
parágrafos de maneiras de um defeito injetado não provar nada, e cada um é um
caso real em que se acreditou num validador que nunca tinha visto defeito
nenhum. É o sítio do projeto onde poupar sai mais caro.

### As SETE FASES de uma sessão, numeradas — diga o número, e o modelo sai daí

Esta é a tabela a citar em conversa: **"estou na F3"**, **"pare na F4"**. Ela
vale para qualquer item da fila; as três skills trazem a versão delas, com os
mesmos números.

| # | Fase | O que é | Modelo |
|---|---|---|---|
| **F1** | **Escolher e desenhar** | ler a fila, escolher o item, e desenhar a MEDIÇÃO — que constante varrer, em que intervalo, contra o quê, e o que conta por bom | **Opus** |
| **F2** | **Medir o ANTES** | rodar o que a F1 desenhou: 600 partidas por perfil, ou a bateria de capturas, ou a varredura. É receita e não tem escolha nenhuma dentro | **Sonnet** |
| **F3** | **Ler a medição** | dizer o que o número quer dizer, e decidir se contraria a previsão | **Opus** |
| **F4** | **Decidir a mudança** | qual `# TUNING:`, qual cor, qual ângulo, qual gramática — e quanto | **Opus** |
| **F5** | **Aplicar e remedir** | escrever a alteração já escolhida e correr a mesma medição da F2 | **Sonnet** |
| **F6** | **Asserção nova** | escrever a guarda que faltava e escolher o DEFEITO INJETADO. ⚠️ Nunca desce, por medição — ver o aviso acima | **Opus** |
| **F7** | **Fechar** | as suítes, o rasto de prosa pelos documentos, o `ESTADO_DO_PROJETO.md` no teto, o commit e o push | **Sonnet** |

**A F6 não acontece em toda sessão** — só quando a mudança descobre uma
pergunta que nenhuma guarda fazia. Quando acontece, ela volta a subir e o resto
da F7 desce outra vez.

⚠️ **A F3 é a que se perde com mais facilidade, e é a mais cara de errar.** É
tentador deixar a F2 correr direto para a F5 porque "o número está ali" — mas o
número não diz o que fazer com ele, e a taxa de vitória é o valor mais fácil de
ler errado deste projeto. Entre medir e mexer há sempre uma leitura.

**A regra de paragem, que é o que torna isto seguro: a sessão barata NÃO
decide.** Ao encontrar uma cor, um ângulo ou uma proporção por escolher; uma
asserção nova, ou um defeito injetado que não reprovou; um `# TUNING:`; uma
medição que contraria o que estava escrito; ou um teste vermelho cuja causa não
é óbvia numa leitura — **pare e devolva**, em vez de escolher. E o contrário
vale igual: assim que a decisão estiver escrita na `docs/decisoes/`, o resto da
sessão desce para Sonnet, que costuma ser a maior parte dela.

⚠️ **E O QUE CUSTA NUMA SESSÃO LONGA NÃO É O MODELO, É A CONVERSA.** A premissa
da `016` é a razão de preço entre os dois, e ela está certa — mas medido nesta
sessão ao fim de nove dias e cinco itens: **672 mil tokens de contexto, 65
MILHÕES de tokens de leitura de cache**, e a maior parte do gasto não é produzir
trabalho novo, é reprocessar o histórico a cada turno. Daí três coisas:

- **trocar de modelo a meio** continua a carregar o contexto todo, só que a
  preço mais baixo — ajuda menos do que parece;
- **sessão NOVA no modelo certo**, apontada ao documento que descreve o ponto
  de partida, arranca perto de zero e corta muito mais;
- por isso é que o desenho de uma medição vive num DOCUMENTO e não só na
  conversa: é o que torna a sessão descartável sem perder o trabalho.

⚠️ **E BURACO PREVISTO NUM BRIEFING PERGUNTA-SE DE QUE FONTE FOI LIDO.** O
briefing de 15/09 avisava que a folha de props ia ficar com cinco famílias sem
âncora — as construções em ruína, os nove cascos, o píer vazio —, e estava
errado: ele lera a TABELA de âncoras, onde eles de facto não estão, e a CENA
responde por 50 dos 51 props, porque prop alternativo partilha o NÓ que o jogo
troca. Meia sessão estava desenhada à volta de um remendo que não fazia falta.
Um briefing é a previsão de quem já fechou a conversa: antes de herdar o buraco
que ele anuncia, **pergunte a que fonte ele o perguntou, e pergunte à outra**.

⚠️ **E `git diff --stat` NOMEIA O ARQUIVO, NUNCA O QUE MUDOU DENTRO DELE.**
Este projeto descreve diffs arquivo a arquivo — em decisão, em briefing e em
corpo de PR —, e a lista de nomes convida a inventar o motivo de cada um. Em
22/09 escrevi que o `Main.gd` era «follow-through» da leva de cor do cartão da
doca: eram **duas referências em COMENTÁRIO**, de `_estilo()` para `refresh()`,
porque aquela função se dissolveu. O `--stat` tinha-me dado o nome e eu supus o
resto. **Antes de escrever o que um arquivo mudou, abra o diff DELE** — e vale
o dobro quando o texto vai para um registo público, que é onde a suposição
passa a parecer facto.

⚠️ **E `git fetch origin A B` NÃO ATUALIZA O `A` SE O `B` NÃO EXISTIR.** Ele
aborta com `fatal: couldn't find remote ref B` e **código 128**, e nenhum dos
dois refs se mexe — reproduzido em 21/09. O natural, ao abrir sessão, é
perguntar pela `main` e pela branch designada na mesma linha; se a branch já
foi apagada depois do PR fundir, a `main` local fica na fotografia de quando o
contêiner subiu. Medido nesse dia: `origin/main` ficou no PR **#51** enquanto o
GitHub estava no **#62** — 40 commits —, e daí saem duas leituras erradas que
custam caro: `git diff origin/main..HEAD` varre a sessão inteira dos outros, e
`git checkout -B <branch> origin/main` **apaga tudo o que foi fundido nesses
40 commits**. Peça um ref de cada vez, e confirme o HEAD real com o GitHub
antes de reapontar seja o que for.
⚠️ **E ELE FALHA ALTO — quem o cala é o cano.** O `fatal` sai no `stderr` e o
código é 128, mas `git fetch ... | tail -2` devolve **0**, que é o do `tail`.
É a regra do "`$?` do comando certo" a morder na primeira linha da sessão, que
é o pior sítio: tudo o que vem depois herda uma `main` velha.

⚠️ **E PR FUNDIDO NÃO QUER DIZER BRANCH FUNDIDA.** A branch designada deste
projeto reaproveita o nome entre sessões, e a receita de a reiniciar da `main`
depois de um PR fundir é `git checkout -B <nome> origin/main` — que DESCARTA o
que a branch tiver a mais. Em 11/09 isso apanhou um commit fechado e empurrado
DEPOIS de o PR ter sido fundido: ele só sobreviveu por estar no remoto. Antes de
reapontar, pergunte o que fica de fora — `git log --oneline origin/main..HEAD` —
e recupere pelo remoto (`git reset --hard origin/<nome>`) em vez de assumir que
a main tem tudo.

⚠️ **Nenhum modelo troca o próprio modelo — quem troca é o Bruno**, com
`/model`. O que a sessão faz é ANUNCIAR numa linha qual modelo o próximo bloco
pede, antes de o começar, e parar quando for para cima. Sob pedido dele, um
bloco fechado de execução pode ir para um subagente com `model` próprio.

**Quando abrir um subagente de varredura, e quando não.** Vale quando a
pergunta é "onde está X" numa área que não se conhece e a resposta cabe em
linhas — ele lê muito e devolve pouco. Não vale para ler um arquivo que já se
sabe qual é, para uma edição, nem para nada que precise do julgamento de quem
está na conversa: ele arranca frio e re-deriva o contexto que esta sessão já
tem. Na dúvida, `grep` primeiro.

**O que se aprendeu vai para onde se lê, antes de a conversa fechar.** A
varredura do `/fechar-sessao` mediu dez de doze lições já registradas à medida
que o trabalho andava — a skill existe para as outras duas. Regra que vale
sempre entra neste arquivo; por que se decidiu assim, em `docs/decisoes/`;
armadilha de uma função, no comentário dela.

---

## Estilo de código

- **`GS` é destipado, e `var x := GS.qualquer_coisa` NÃO compila.** As
  ferramentas e os testes pegam o autoload por `root.get_node("GameState")`,
  que devolve um `Node` sem tipo, e o Godot recusa-se a inferir a partir dele:
  *"Cannot infer the type of X because the value doesn't have a set type"*.
  Escreva o tipo à mão — `var x: float = GS.RIVAL_KEEP_CHANCE`. Isto mordeu
  três vezes num dia só, em três arquivos diferentes, e cada vez custou uma
  corrida: **o Godot encerra com código 0** nesse erro, então quem olha só o
  `$?` conclui que passou.
- **Erro de execução DENTRO de um teste aborta a função e a suíte passa na
  mesma.** Aconteceu em 02/09: uma chamada com o número errado de argumentos
  matou o bloco T5g inteiro e o `run_tests.gd` imprimiu `TODOS OS TESTES
  PASSARAM` com sete asserções por correr. É a irmã da regra acima — o erro sai
  no `stderr`, o contador de falhas fica em zero, e nada reprova. Todo bloco de
  teste novo põe uma bandeira na ÚLTIMA linha e quem o chama confere que ela
  ficou verdadeira; só assim "passou" quer dizer "correu".
- **⚠️ `ResourceLoader.exists()` SÓ DIZ QUE O ARQUIVO ESTÁ LÁ.** Com um
  `SubResource` órfão o `load()` devolve `null`, o `.instantiate()` num `null`
  ABORTA a função — e quem chamou recebe o mesmo `null` que já significava "não
  montei, e já me queixei". Medido em 21/09: a régua do contraste encerrou com
  `CONTRASTE MEDIDO` e código **0**, com 46 textos a menos, e o D33 publicou
  `PASS em 147 medidos` com 90 em falta. Separe o `load()` do `instantiate()` e
  queixe-se do `null`. É a regra da amostra vazia um andar acima: ali a cena
  montava e não produzia texto, **e havia guarda**; aqui ela nunca chegou a
  montar, e não havia nenhuma.
- **⚠️ E `await process_frame` RETOMA ANTES DO FLUSH DA FILA ADIADA.** Ele
  volta no INÍCIO do frame seguinte, e o que foi posto em `call_deferred`
  naquele frame ainda não correu. Medido em 18/09: com um `await` só, o rótulo
  que a fala escreve por `call_deferred` ainda tinha a mensagem do sistema, e a
  asserção reprovava o código CERTO; com dois, a fala já lá está. **São dois, e
  escreva ao lado que foi medido.**
  ⚠️ **E A RÉGUA CAIU NO MESMO BURACO ANTES DA GUARDA** — a primeira medição
  depois da correção deu **zero em todas as falas**, o que se lê como "não
  acontece nada" e não como "li cedo demais". É a irmã de "receita derivada que
  não casa nada dá um verde de graça", com FRAMES no lugar do `grep`: **quando
  uma régua nova devolve zero em TUDO, a primeira pergunta é se ela consegue
  devolver outra coisa.**
- **⚠️ E `_process` DE UM `SceneTree` QUE DEVOLVE `true` MATA A ÁRVORE NO FIM
  DO FRAME.** Enquanto nenhum bloco espera, isso não se nota — quem encerra é o
  `quit()` explícito e o `true` chega depois. No dia em que um bloco passou a
  usar `await`, o `await` nunca voltou: a suíte imprimiu o marcador com o bloco
  inteiro por correr, verde e sem ter testado nada. Num `--script` que precise
  de esperar frames, `_process` devolve `false` e quem encerra é só o `quit()`.
- **⚠️ E ANIMAÇÃO PROVA-SE SEM ESPERAR FRAME NENHUM.** Num teste síncrono — o
  `teste_design` devolve `true`, e um `await` lá nunca volta — o tween que o
  jogo cria apanha-se pela diferença de `get_processed_tweens()` antes e depois
  da ação, e anda-se com `custom_step()`, lendo o NÓ a cada passo, que é o que o
  jogador vê. O passo tem de ser menor do que o trecho mais curto, senão um
  trecho inteiro cabe num passo e nunca é lido; e a ação que não criou tween
  tem de REPROVAR, senão a lista vazia passa por "nada de errado" (`047`).
- **⚠️ E NUMA SUÍTE QUE NUNCA DEIXA PASSAR UM FRAME, OS TWEENS NUNCA SAEM DA
  LISTA.** O motor só tira os acabados e os mortos no `process` seguinte, e o
  `teste_design` corre inteiro num `_process`: ao D35 chegavam 983. Perguntar
  `Array.has()` a cada um, a cada passo, fez um bloco custar 62 s a uma suíte
  de 3; um `Dictionary` devolveu-a a 9 (`052`).
- **⚠️ DECISÃO QUE PERGUNTA NUM PASSO E AGE NO SEGUINTE TEM UMA CORRIDA.** O
  arranque dos camiões perguntava se a ponta estava livre e deixava o tween
  teleportar no passo seguinte: dois que perguntassem no mesmo passo saíam
  juntos, em cima um do outro para a volta inteira. Nenhuma agenda o provocava
  — foi um mutante de OUTRA regra, que só mexia no tempo, que o expôs. Quem
  pergunta ocupa o sítio no mesmo instante (`052`).
- **⚠️ E `preload` DE UM SCRIPT QUE FALA DO AUTOLOAD, A PARTIR DE UM
  `--script`, DÁ UM GDScript VAZIO.** A terceira cara da regra abaixo, e a que
  menos se parece com ela: `const D := preload("res://scripts/Dock.gd")` numa
  ferramenta de `--script` compila o `Dock.gd` ANTES de os autoloads existirem,
  e o que sai não é erro de compilação — é um `GDScript` sem funções, que só se
  denuncia como *"Nonexistent function 'arte_do_barco' in base 'GDScript'"* na
  hora de o usar. Num `--script`, carregue-o com `load()` dentro do `_process`,
  quando a árvore já está de pé.
- **O autoload não resolve pelo nome dentro de um `class_name`.**
  `GameState.x` funciona num script de cena, que o Godot compila com os
  autoloads já registrados; NÃO funciona dentro de uma classe alcançada a
  partir de um script de `--script`, que é compilada antes disso. O erro sai
  como *"Compile Error: Identifier not found: GameState"* e derruba a suíte
  inteira, não só a linha culpada. Busque pela árvore —
  `Engine.get_main_loop().root.get_node("GameState")` — e escreva o tipo à mão
  no que vier de lá. É a irmã da regra acima, e tem a mesma origem: a suíte
  roda o jogo POR FORA.
- **Autoload novo nasce DESLIGADO, e quem o liga é o JOGO.** Um autoload
  carrega também em `--script` — é por isso que a suíte pega o `GameState` por
  `root.get_node()`. Logo, tudo o que ele faça por omissão acontece TAMBÉM
  durante as 600 partidas por perfil do simulador e durante as cinco suítes. O
  `Registro.gd` só grava depois de `armar()`, e a única linha do projeto que
  arma é o `Main._ready()`. É a irmã da regra "tela nova é overlay, nunca fase
  do `GameState`": ambas são coisas que funcionam no jogo e envenenam calado
  quem mede.
- **`.get(chave, omissão)` num dicionário de configuração transforma erro de
  digitação em número plausível.** Em 02/09 o `Registro` lia
  `ESTRUTURAS[id].get("preco", 0)` — a chave é `custo` — e o relatório dizia,
  sem erro nenhum, que o jogador construía de graça. A mesma linha errada
  estava em dois arquivos. Num dicionário cujas chaves são conhecidas, acesso
  DIRETO: um `id` inexistente tem de rebentar em vez de mentir. E **zero é o
  pior valor de omissão que há, porque se lê como medida** — no mesmo dia, um
  contador por turno que era zerado e nunca incrementado fez o relatório
  afirmar "0 barcos servidos" num porto que atendeu 184.
- **⚠️ FORMATAR PARA O OLHO PODE APAGAR O NÚMERO, e "0." lê-se como zero.**
  Irmã da regra acima — ali o zero de omissão passava por medida; aqui é o
  número de verdade que se perde a caminho do papel. O `gerar_tabela_numeros.py`
  fixava `"%.2f"` e depois fazia `rstrip("0")`: correto para os 0,50 e 0,28 que
  o jogo tinha, e destruidor para o primeiro valor abaixo de 0,005 — o
  `JUROS_POR_TURNO` (0,0025) foi para a tabela como **`0.`**, sem erro nenhum,
  numa ferramenta cujo lema é recusar-se a adivinhar. **Precisão fixa num
  formatador é uma aposta sobre valores que ainda não existem.** As casas saem
  do valor; e a guarda que isto pedia é barata — **releia o que formatou e
  exija que volte ao que era**, senão a tabela perde o número sem uma palavra.
- **⚠️ `open(..., "w")` TRUNCA ANTES DE O CONTEÚDO EXISTIR, e isso vale para
  todo arquivo gerado.** O `main()` do `gerar_mapa_iso.py` tem o comentário
  certo ao lado do SVG — gerar ANTES de abrir, "que trunca de imediato, e um
  erro deixaria o mapa vazio" —, e a tabela de âncoras ao lado NÃO tinha a mesma
  proteção: um `NameError` dentro de `tabela_ancoras()`, chamada de dentro do
  `json.dump()`, deixou o `.json` com **zero bytes** e o commit anterior por
  cima. É a regra "ao corrigir um, VARRA OS IRMÃOS" aplicada a dois `open()` no
  mesmo arquivo.
  ⚠️ **E VALE PARA O SCRIPT DESCARTÁVEL QUE EDITA UM ARQUIVO DO PROJETO.** Em
  14/09 um `io.open(p, "w", newline=...)` com o argumento mal escapado rebentou
  **depois** de truncar, e um arquivo versionado de 253 linhas ficou com ZERO
  bytes — salvo pelo `git checkout` só por já estar commitado. Edição em massa
  monta o texto todo, escreve num temporário e faz `os.replace`; nunca abre o
  original para escrita.
  ⚠️ **E O `os.replace` PERDE O MODO DO ARQUIVO** — é o preço do remédio acima,
  e cobrou-o na mesma tarde: o `capturar_evidencia.sh` reescrito assim ficou
  644, e a bateria morreu com código **126 em 0 s**, que não se parece nada com
  um erro de captura. Ao trocar um arquivo por um temporário, copie o modo
  (`os.chmod(tmp, os.stat(p).st_mode)`) antes do `replace`.
- **⚠️ RÉGUA QUE VARRE CÓDIGO LÊ O ARQUIVO INTEIRO, NUNCA LINHA A LINHA — e a
  que não o faz não REPROVA, escapa CALADA.** O `CLAUDE.md` já registava isto
  para o `grep` de facto em prosa; em 21/09 mordeu dentro da guarda escrita
  para o caçar. O bloco F9 varria linha a linha e achou **6 das 11** chamadas:
  o código deste repositório também quebra aos ~79 caracteres, e cinco delas
  têm a chamada numa linha e os argumentos na seguinte. As cinco não entravam
  na lista e não havia queixa nenhuma.
  ⚠️ **E QUEM AS APANHOU FOI A CONTA POR DOIS CAMINHOS**: quantas vezes o nome
  aparece no texto, contra quantos casos a expressão conseguiu ler, com a
  asserção a exigir que os dois números sejam iguais. É *"uma régua que
  responde à mesma pergunta por dois caminhos denuncia-se sozinha"* aplicada a
  uma VARREDURA — e é ela que faz uma chamada de forma nova reprovar em vez de
  ser ignorada. Sem ela, a versão errada dizia verde (`docs/decisoes/037`).
  ⚠️ **E A DEFINIÇÃO NÃO É UMA CHAMADA.** `func _abrir_painel(cena: PackedScene)`
  casa tão bem quanto uma chamada de verdade: a primeira versão do portão das
  capturas exigiu fotografia de um painel chamado `cena: PackedScene`. Quem
  varre CHAMADAS exclui a definição (`(?<!func )`), e lê o argumento com
  **parênteses equilibrados** — `[^)]*` para no primeiro fecho e parte ao meio a
  chamada que traz outra dentro (`docs/decisoes/039`).
  ⚠️ **E O ARGUMENTO PODE TER PARÊNTESES *E* ASPAS DENTRO.** `int(dia["servidos"])`
  parte as duas expressões óbvias: a que casa a primeira string a seguir ao
  parêntesis lê `"servidos"` como argumento, e a que proíbe parênteses salta a
  chamada inteira. O que se casa são os ÚLTIMOS argumentos antes do fecho.
- **⚠️ QUEM LÊ UM RESULTADO DE UMA LISTA QUE CRESCE LÊ POR IDENTIDADE, NUNCA
  POR ÍNDICE.** A conclusão do simulador tirava o "jogar mal" de
  `resultados[size - 1]`, o que era o Descuidado enquanto os perfis eram três;
  com o Antecipado no fim (12/09) passou a ser ele, e a Leitura publicou 80%
  onde a tabela, duas linhas acima, media 37,3% — com os dois vereditos que
  dependem do número a dispararem ao contrário do que ela mede. Não dá erro
  nenhum, e o índice continua válido. **Índice é posição; papel é identidade**,
  e num `Array` de resultados só a segunda sobrevive à lista crescer ou a ser
  reordenada. Recuse identidade ausente E duplicada: escolher o primeiro de dois
  homónimos é decidir por posição outra vez. E a identidade não se inventa —
  aqui é o NOME, porque o despejo JSON e o `projetar_parcelas.py` já o usavam
  (`docs/decisoes/030`).
  ⚠️ **E VEREDITO NUM RELATÓRIO É POLÍTICA, e não cai quando a decisão que o
  sustentava é substituída.** No mesmo arquivo, *"o ERRO NÃO CUSTA, é este o
  sintoma de 'fácil demais'"* acima de 50% sobreviveu quinze dias à `005`, que
  substituiu a fantasia de sobrevivência por *"a decisão errada custa TEMPO e
  OPORTUNIDADE, não a partida"* — e nenhum limiar novo foi escrito para o lugar
  do velho. É a irmã de "número em pixel escrito à mão envelhece calado", com um
  JULGAMENTO em vez de um número, e é pior: o número errado lê-se como número,
  o veredito errado lê-se como conclusão. Limiar sem decisão viva a segurá-lo
  sai, e no lugar fica a descrição factual.
  ⚠️ **E CONCLUSÃO QUE VIVE DENTRO DE QUEM A PRODUZ NÃO SE PROVA.** A razão de
  nenhuma das seis suítes poder ter apanhado aquilo: a frase morava num
  `SceneTree` que roda 4 perfis × 600 partidas antes de chegar a ela, e isso não
  se alimenta com fixture. Separá-la num arquivo de aritmética pura custou umas
  linhas e é o que torna o bloco T7 possível — e ela devolve LINHAS em vez de
  imprimir, porque o que se tem de provar é o TEXTO final: neste projeto a
  formatação já engoliu um número sozinha (o `0.` do `JUROS_POR_TURNO`).
- **`destino[chave] += x` num Dictionary CRIA a chave em silêncio.** É a irmã
  do `.get(chave, omissão)` acima, do outro lado: ali um erro de digitação vira
  número plausível na LEITURA, aqui vira dinheiro escrito numa chave que a soma
  da receita não lê — e some sem erro nenhum. Aconteceria em 06/09 se um motivo
  novo se prendesse a uma estrutura sem linha na contabilidade; a linha chama-se
  como a estrutura de propósito, e o bloco T5l tranca que toda estrutura que
  paga tenha a sua.
- **⚠️ ADIAR UM LANÇAMENTO PARA DEPOIS DE UMA DECISÃO ABRE UMA SAÍDA POR
  RESPOSTA, e a que não se escreveu fica órfã.** A revisão externa de 12/09
  achou um defeito verdadeiro — o boletim da semana 4 fechava ANTES de o Sr.
  Ribeiro receber, e escondia a maior despesa da semana —, e o conserto adiou
  o fecho para o `pay_debt()`. Só que a fase `debt_payment` tem DUAS portas:
  quem paga e quem não pode pagar. Pelo lado da derrota o fecho nunca
  acontecia — `semana_atual` chegava ao fim da partida com meia semana dentro,
  `historico_semanas` ficava com TRÊS entradas em vez de quatro e o boletim
  não abria —, e **as cinco suítes passavam**, porque a asserção que veio com
  o conserto provava o adiamento só pelo lado de quem PAGA. Ao mover trabalho
  para depois de uma decisão, conte as RESPOSTAS e feche em todas; e a guarda
  que fecha é a própria FASE que adiou, nunca uma aproximação dela — assim ela
  também torna o fecho idempotente de graça.
- **⚠️ `is_inside_tree()` NÃO PROVA QUE O NÓ NÃO FOI MANDADO EMBORA.** O
  `queue_free()` marca o nó e só o tira da árvore no fim do frame, então um
  painel já condenado responde "estou cá" a quem perguntar assim. Uma asserção
  nova de 13/09 usava isto para provar que a tela ficava aberta e PASSOU com o
  defeito posto — quem reprovava era a asserção do texto ao lado, e sem ela o
  defeito passava inteiro. A pergunta que distingue é a da FILA:
  `is_queued_for_deletion()`.
- **Teste que JOGA fixa a semente.** `new_game()` chama `_spawn_boats()`, que
  tem 30% de abrir contra-oferta — e nessa fase o `advance_turn()` retorna
  CALADO. Um bloco de teste que avance o turno logo a seguir reprova em cerca
  de 3 de cada 10 corridas por uma razão que nada tem a ver com o que ele
  testa. Teste intermitente no CI é pior do que teste nenhum: ensina a ignorar
  vermelho.
  ⚠️ **E FIXAR A SEMENTE NO TOPO DO BLOCO NÃO CHEGA: o ESTADO dela anda com
  quem a usa.** Em 06/09 acrescentaram-se 1.500 sorteios ao meio de um bloco de
  teste, e o `new_game()` de um bloco POSTERIOR — que passava havia semanas —
  passou a calhar numa contra-oferta, onde `comprar_estrutura()` recusa calado.
  Nada mudou nesse bloco; mudou o que veio antes. Todo bloco que jogue resolve
  a oferta pendente antes de contar com o estado (`if GS.phase ==
  "rival_offer": GS.resolve_rival_offer(true)`), em vez de confiar na semente
  de quem o precede.
- Comentário explica **por que**, e de preferência conta o que se tentou antes
  e não funcionou. O repositório inteiro é escrito assim; siga.
- Nada de emoji na interface — os ícones vivem em `art/icones/` e são
  registrados em `scripts/Icones.gd`.
- `.gd.uid` e `.import` **entram no Git** (o `.gitignore` explica por quê).
