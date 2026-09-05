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
   **E confira que a base está LIMPA antes de injetar o defeito seguinte.** No
   mesmo dia, o `git checkout` que devolvia o arquivo entre um defeito e outro
   restaurou a versão anterior ao trabalho inteiro — e os três testes seguintes
   relataram, contentes, a mesma falha herdada. Nenhum deles provou nada. Entre
   um defeito e o próximo, rode o validador uma vez e exija que ele PASSE; e
   guarde o original com `cp`, nunca com `git`, que não sabe o que ainda não foi
   commitado.
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
`ZOOM=2/3`, câmera do Blender a `ROT_X=60°`, `ROT_Z=45°`, `ESCALA_ORTO`
derivada delas.

- **São DOIS espaços desde 05/09, e a fronteira é `tela()`.** O mapa DESENHA a
  30 num quadro de 1080 e o `viewBox` do SVG entrega 720 — a câmera é o `ZOOM`,
  e o `MEIA_LARG` efetivo é 20. Quem desenha fala DESENHO; a tabela de âncoras,
  o `Main.tscn`, o `Main.gd`, o manifest BRP e o teste de design falam TELA.
  **A razão de não escrever 20 na constante:** altura, naquele arquivo, é
  PIXEL — o `ALT_CAIS`, as paredes da vila, a largura de cada traço —, e baixar
  só o `MEIA_LARG` encolheria a PLANTA deixando as ALTURAS paradas, com o porto
  esticado 1,5× para cima e nenhuma das cinco suítes a lê-lo. Escala-se no
  GRUPO, que é a mesma regra dos props.
- **O prop não tem `viewBox`: quem o encolhe é o `ortho_scale`, e só ele.** O
  `z()` continua na escala de DESENHO de propósito — o fator de altura e o
  `ortho_scale` cancelam-se, e mexer nele levantaria cada prop 1,5×. Afastar
  uma câmera não estica o que ela filma.
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
- **O quadro de todo prop tem 512 e o centro dele é a origem do mundo.**
  Posicionar um prop na cena é subtrair meio quadro, não acertar no olho.
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
- **E o estado ANTES não pode partilhar as peças do estado DEPOIS.** O
  `galpao_velho` reusava a lista de paredes do `galpao` — plinto, caixa branca
  limpa, portão fechado, calha e três janelas de vidro — e trocava só a cor do
  telhado. O porto abria "em ruínas" com um galpão de paredes novas, e a
  queixa que isso gerou foi "as construções parecem avançadas para um porto
  inicial". A regra certa já estava escrita ao lado, no comentário do
  escritório: **a ruína não é o prédio pintado de velho, é MENOS prédio** —
  parede caída, vidro nenhum, meio telhado. Partilhar peças entre dois estados
  poupa render e custa a leitura, que é o que o estado existe para dar.
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
  contrário. Ao acrescentar um prop, acrescente também quem o mostra — e a
  asserção de que ele chega à tela.
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
- **E caixa alinhada aos eixos de um GRUPO tem quinas que não existem.** Ao
  medir a projeção peça a peça a resposta bateu com o render; medindo pela
  caixa do grupo, ela juntava o `x` de um braço com o `y` de uma bota e o `z`
  do capacete e errava por 17px. Caixa de grupo serve para saber se algo cabe
  num sítio; não serve para dizer o que a câmera vê.
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
  **E o letreiro deixou de carregar a geometria dele na cena** (05/09): ele
  mede a chapa pelo texto e planta o mastro no telhado, pelos dois estados do
  prédio (`scripts/Letreiro.gd`). Os offsets cravados que ele tinha traziam a
  placa mais larga do que o prédio que nomeia e uma delas a pairar — os dois
  são a mesma coisa que este arquivo repete sobre altura e sobre cor: número
  em pixel escrito à mão envelhece calado quando o que ele descreve muda de
  tamanho.
- **Encolher um prop escala-se no GRUPO, nunca reescrevendo as literais.**
  Porta contra parede, janela contra porta, beiral contra telhado: são trinta
  números e trinta chances de um ficar por escalar. E cada objeto UMA vez —
  `galpao` e `galpao_velho` partilham as paredes de propósito, então escalar
  grupo a grupo passaria duas vezes nas peças comuns e elas sairiam a `k²`,
  sem erro nenhum a apontá-lo.
- **Rodar um prop 90° manda metade dos detalhes para a face que a câmera não
  vê.** Só `+x` e `-y` são visíveis. Rodar o caminhão para o eixo da estrada
  punha o para-brisa a olhar certo e a janela lateral para `-x` — invisível, e
  ninguém notaria no render, só na silhueta chapada. Prop que muda de eixo
  RECONSTRÓI-SE com os detalhes repostos nas faces visíveis.
- **Prop que a captura não vê é prop que ninguém revê.** A travessia do
  caminhão nasceu com um desvanecer de 1,1 s no INÍCIO do ciclo, e as cinco
  fotos do CI assentam em poucos frames: o caminhão saía invisível de todas
  elas. Animação nova começa no estado VISÍVEL, e o desvanecer vai no fim.
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
- **Comentário que explica como a constante ao lado apodrece é um pedido para
  ela ser derivada.** O `VILA_VAZIOS` — onde os prédios do pátio tapam a vila
  — eram dois intervalos escritos à mão com vinte linhas a avisar que
  envelheciam calados, e envelheceram. Hoje saem de `vaos_da_vila()`, e a
  derivação achou o que a versão à mão escondia: a coluna da tela não chega,
  porque um prédio tapa para CIMA e só até à altura do sprite dele.
- **Escala de ruído é relativa ao tamanho da peça.** Numa longarina de 0,045
  o número 14 dá uma marca; numa parede de 3 unidades dá setenta, e a parede
  vira lixa.
- **Recuar um contorno para DENTRO não é `costa_deslocada` com o sinal
  trocado.** Aquele empurra cada vértice na diagonal (+d em mx, −d em my), o
  que serve para uma faixa de água; ao longo de um MURO isso desloca também o
  `my`, e a linha recuada sai adiantada da original. Ao fazer a praia de 04/09
  a crista ficou 1,3 unidade à frente da linha de água e abriu-se um triângulo
  de **água funda dentro da terra**, no fim do cais. Recuo é pela normal de
  cada segmento, e cada quina leva o remate que pede: chanfro onde a terra
  abraça a quina, cruzamento das duas linhas onde ela é uma ponta.
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

**Meça antes de codar, e o custo de medir quase nunca é o que se supõe.** Três
vezes em dois dias a suposição estava errada e nas três para o lado caro: a
barra de reputação que se ia afinar já estava saturada no teto; as 600 partidas
que se evitavam por "demorarem minutos" levam 26 segundos; e a `/arte` foi
adiada por "precisar de 1 GB de `bpy`" quando metade das etapas não precisa de
Blender nenhum e o conferidor de lote precisa de `numpy` + `pillow`, que
instalam em 8. Rodar a ferramenta antes de decidir é mais barato do que
discutir o que ela diria.

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
- **Autoload novo nasce DESLIGADO, e quem o liga é o JOGO.** Um autoload
  carrega também em `--script` — é por isso que a suíte pega o `GameState` por
  `root.get_node()`. Logo, tudo o que ele faça por omissão acontece TAMBÉM
  durante as 600 partidas × 3 perfis do simulador e durante as cinco suítes. O
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
- **Teste que JOGA fixa a semente.** `new_game()` chama `_spawn_boats()`, que
  tem 30% de abrir contra-oferta — e nessa fase o `advance_turn()` retorna
  CALADO. Um bloco de teste que avance o turno logo a seguir reprova em cerca
  de 3 de cada 10 corridas por uma razão que nada tem a ver com o que ele
  testa. Teste intermitente no CI é pior do que teste nenhum: ensina a ignorar
  vermelho.
- Comentário explica **por que**, e de preferência conta o que se tentou antes
  e não funcionou. O repositório inteiro é escrito assim; siga.
- Nada de emoji na interface — os 20 ícones vivem em `art/icones/` e são
  registrados em `scripts/Icones.gd`.
- `.gd.uid` e `.import` **entram no Git** (o `.gitignore` explica por quê).
