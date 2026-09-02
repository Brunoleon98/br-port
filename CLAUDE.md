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
> Dois documentos de trabalho não são camada e continuam onde a mão os
> alcança: `docs/BRP_SPATIAL_CONTRACT.md` (o contrato da projeção) e
> `docs/design/BR_Port_Plano_Arte_Blender.md` (o caminho medido da arte).
> `tools/conferir_docs.py` tranca isto no CI, e espera `DOCS OK`.

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
$G --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_tela.gd -- 12 foto.png completo

tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"   # as cinco de uma vez

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

⚠️ **Valor de Godot 3 numa chave de Godot 4 não dá erro — dá outra coisa.**
`window/handheld/orientation="portrait"` é sintaxe da 3; na 4 a chave é um enum
INTEIRO, e o exportador faz `int()` dela. `int("portrait")` é **0**, que é
PAISAGEM: o APK saiu deitado enquanto o projeto se dizia retrato havia cinco
blocos, e nenhuma das cinco suítes lia aquela linha. Ao conferir uma chave de
`project.godot`, confira o **TIPO** e não só o valor — e desconfie de toda
string numa chave que a documentação da 4 descreve como enum.

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
3. Mexeu em QUALQUER `const` do `GameState.gd`? Regere a tabela dos números —
   `despejar_constantes.gd` + `tools/gerar_tabela_numeros.py --contra-godot`,
   espera `TABELA OK`. Ela é gerada do código, e o CI reprova se envelhecer:
   os números já viveram no GDD e nas constantes ao mesmo tempo, e divergiram.
4. Mexeu em preço ou constante `# TUNING:`? `tools/simular_balanceamento.gd`.
   O balanceamento medido é **100% / 79,5% / 35,7%** por perfil, com a mediana
   do jogador mediano em R$685.271 contra uma parcela de R$550.000. Mexer sem
   medir quebra isso.
   **O alvo é TRANQUILO, e é decisão registrada** (`docs/decisoes/005`): a
   dívida deixou de ser o motor. Os 100% / 47% / 0% que este arquivo afirmou
   até 02/09 eram a fantasia de sobrevivência que essa decisão substituiu — são
   história, não meta. Quem discrimina os jogadores agora é **o porto que
   conseguem levantar**: o Ótimo atende 46,3 barcos, o Descuidado 12,5.
   **Medir é com `-- 600`.** As 30 partidas que o CI roda são teste de fumaça
   (provam que a ferramenta não quebrou junto com o `GameState`) e têm margem
   de ±18 pontos — comparar aquele número com estes é comparar sorteio.
   O próprio simulador avisa quando a rodada é curta demais para medir.
5. Mexeu no visual? **Tire uma captura e olhe.** Teste verde não prova que
   ficou bonito. O CI já anexa as cinco a cada PR (artefato `brport-captura`) e
   diz na página da corrida qual mudou — mas dizer que mudou não é dizer que
   ficou bom, e essa parte continua a ser de quem olha.
   **Captura só se compara com semente E passo de tempo fixos.** É o que o
   `tools/capturar_evidencia.sh` faz, e as duas fazem falta: com a semente
   sozinha, duas corridas do MESMO código davam 1.030 pixels diferentes,
   porque os tweens em laço andam por *delta* e não por frame. Quem tirar a
   captura à mão sem `--fixed-fps 60` tem uma foto para olhar, não uma para
   comparar.
   E ao recortar a captura para conferir um detalhe, lembre que
   **o mapa não começa no topo da tela**: `MapaWrap` tem `offset_top = 62`, e
   as coordenadas que saem da projeção são do MAPA. Somar os 62 é a diferença
   entre olhar o prop e olhar o telhado ao lado dele — três recortes já foram
   ao lugar errado por causa disto.
6. **Captura de painel sem tema é uma fotografia mentirosa.** No jogo quem
   aplica o tema é o `_abrir_painel()`; cena instanciada solta nasce com o
   cinzento padrão do Godot. O `capturar_cena.gd` já o aplica, e também chama
   `setup()` com os argumentos extra — sem isso os painéis que dependem dele
   saem VAZIOS e a captura passa por "a cena abre" sem mostrar nada.
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
   **E o defeito pode pegar e o teste passar na mesma.** Aconteceu em 02/09:
   tirar `tests/*` do filtro de export não reprovou nada, porque o teste
   perguntava `contains("tests/*")` e o `scenes/tests/*` que ficou no arquivo
   contém essa string. Num arquivo de configuração, `contains()` quase nunca é
   a pergunta que se quer fazer — separe a lista e compare ITEM a item. Vale a
   mesma desconfiança ao ler chave de config: uma linha dentro de um
   COMENTÁRIO satisfaz uma busca no arquivo inteiro.

---

## As regras que já custaram trabalho

### Projeção isométrica — é um contrato entre três arquivos

`tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py` e `brport_vs/scenes/Main.tscn`
têm de concordar. As constantes: `MEIA_LARG=30`, `MEIA_ALT=15` (razão 2:1),
câmera do Blender a `ROT_X=60°`, `ROT_Z=45°`, `ESCALA_ORTO` derivada delas.

- **Altura é em PIXELS DO MAPA**, não em unidades do Blender. A conversão está
  em `z()` num lugar só. Ignorar isso põe um píer 2,4× mais alto que o cais
  desenhado ao lado.
- **`pos()` inverte o sinal de Y.** No Blender a direita da tela é (+X, +Y);
  no mapa o `+my` puxa para a ESQUERDA. Um prop simétrico não denuncia a
  diferença — o primeiro assimétrico saiu 40px fora.
- **O quadro de todo prop tem 512 e o centro dele é a origem do mundo.**
  Posicionar um prop na cena é subtrair meio quadro, não acertar no olho.
- **Só as faces `+x` e `-y` são visíveis** por esta câmera. Detalhar as outras
  é render que ninguém vê.
- **Ordem de nó É profundidade.** Quem tem `mx+my` maior está mais perto da
  câmera e tapa quem tem menor. Vale em `Dock.tscn` e em `MapaWrap/Cenario`.
  O teste de design confere isto.
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
- **Asset novo sai de `blender/gerar_brp.py`**, que partilha a câmera e o kit
  com `gerar_props_iso.py`. Nada de um segundo estúdio ao lado.
- **Prop no cenário nunca sai de gerador de imagem.** Duas levas perdidas: o
  gerador não erra o desenho, erra o ÂNGULO, e ângulo errado não se conserta
  rodando no Godot. Retrato em painel, sim; prop no mapa, não.
- **O que troca de estado numa partida não pode estar assado no fundo.** Píer,
  armazém, escritório e pátio são props ou mapas alternativos. A vila é a
  exceção, e de propósito: ela troca entre FASES, não entre turnos.
- **Escala de ruído é relativa ao tamanho da peça.** Numa longarina de 0,045
  o número 14 dá uma marca; numa parede de 3 unidades dá setenta, e a parede
  vira lixa.
- **Freestyle foi testado e REJEITADO** — fecha o vazado da treliça e engorda
  peça pequena. Contorno, se voltar, vem pelo compositor (profundidade +
  normal), não por Freestyle.
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

### Narrativa

- **Todo texto de fala vive em `scripts/Narrativa.gd`**, como o ícone vive no
  `Icones.gd`. Fala espalhada por painel é o que aconteceu com os emojis, e
  trocar um custava caçar string por string em sete scripts.
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
- Nada de interface pousa sobre o mapa. Uma doca tem duas metades:
  `Dock.tscn` (cenário) e `DocaCartao.tscn` (texto e alvo de toque).
- Alvo de toque mínimo 44px. O teste de design cobre.
- Dinheiro sai por `GameState.moeda()` — separador de milhar, um lugar só.
- O tema (`ui/tema_brport.tres`) é o ponto único de estilo. Script não pinta
  cor na mão.

---

## O que cabe numa sessão

Uma sessão que tenta fazer tudo entrega tudo pela metade, e a seguinte não sabe
o que ficou por acabar. Meia página para evitar isso.

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

**Meça antes de codar, e o custo de medir quase nunca é o que se supõe.** Duas
vezes em dois dias a suposição estava errada e nos dois casos para o lado caro:
a barra de reputação que se ia afinar já estava saturada no teto, e as 600
partidas que se evitavam por "demorarem minutos" levam 26 segundos. Rodar a
ferramenta antes de decidir é mais barato do que discutir o que ela diria.

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
- **O autoload não resolve pelo nome dentro de um `class_name`.**
  `GameState.x` funciona num script de cena, que o Godot compila com os
  autoloads já registrados; NÃO funciona dentro de uma classe alcançada a
  partir de um script de `--script`, que é compilada antes disso. O erro sai
  como *"Compile Error: Identifier not found: GameState"* e derruba a suíte
  inteira, não só a linha culpada. Busque pela árvore —
  `Engine.get_main_loop().root.get_node("GameState")` — e escreva o tipo à mão
  no que vier de lá. É a irmã da regra acima, e tem a mesma origem: a suíte
  roda o jogo POR FORA.
- Comentário explica **por que**, e de preferência conta o que se tentou antes
  e não funcionou. O repositório inteiro é escrito assim; siga.
- Nada de emoji na interface — os 20 ícones vivem em `art/icones/` e são
  registrados em `scripts/Icones.gd`.
- `.gd.uid` e `.import` **entram no Git** (o `.gitignore` explica por quê).
