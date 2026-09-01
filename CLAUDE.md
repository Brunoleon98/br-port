# BR Port — instruções do projeto

Jogo mobile de gestão de porto. Godot 4.6 + GDScript, retrato 720×1280, em
português do Brasil. O código, os comentários, os documentos e os nomes de nó
são em português — commits e PRs em inglês.

> Ponto de entrada para entender o estado: `docs/ESTADO_DO_PROJETO.md`.
> O que fazer a seguir, e quem faz o quê: `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
> Para retomar o trabalho: `docs/BLOCO5_BRIEFING_CONTINUACAO.md`.
> Para a arte: `docs/BLOCO7_PLANO_ARTE_BLENDER.md`.
> Contrato da projeção e pipeline de assets: `docs/BRP_SPATIAL_CONTRACT.md`.

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
$G --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_tela.gd -- 12 foto.png completo

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
3. Mexeu em QUALQUER `const` do `GameState.gd`? Regere a tabela dos números —
   `despejar_constantes.gd` + `tools/gerar_tabela_numeros.py --contra-godot`,
   espera `TABELA OK`. Ela é gerada do código, e o CI reprova se envelhecer:
   os números já viveram no GDD e nas constantes ao mesmo tempo, e divergiram.
4. Mexeu em preço ou constante `# TUNING:`? `tools/simular_balanceamento.gd`.
   O balanceamento medido é 100% / 47% / 0% por perfil, com a mediana do
   jogador mediano em ~R$7.950 contra uma parcela de R$8.000. Mexer sem medir
   quebra isso.
   **Medir é com `-- 600`.** As 30 partidas que o CI roda são teste de fumaça
   (provam que a ferramenta não quebrou junto com o `GameState`) e têm margem
   de ±18 pontos — comparar aquele número com estes 47% é comparar sorteio.
   O próprio simulador avisa quando a rodada é curta demais para medir.
5. Mexeu no visual? **Tire uma captura e olhe.** Teste verde não prova que
   ficou bonito. E ao recortar a captura para conferir um detalhe, lembre que
   **o mapa não começa no topo da tela**: `MapaWrap` tem `offset_top = 62`, e
   as coordenadas que saem da projeção são do MAPA. Somar os 62 é a diferença
   entre olhar o prop e olhar o telhado ao lado dele — três recortes já foram
   ao lugar errado por causa disto.
6. Escreveu um validador e ele **passou de primeira**? Desconfie. Injete o
   defeito que ele deveria pegar e veja-o reprovar antes de confiar nele. Um
   validador que nunca reprovou nada não é um validador — e, na primeira vez
   que se fez isto aqui, quem estava furado era o teste, não o validador.
   **E confira que o defeito injetado pegou.** Dois já não pegaram: um usou uma
   variável de ambiente que a sessão já trazia definida, e outro quebrou o
   GDScript de tal jeito que o passo anterior falhou calado e reaproveitou o
   arquivo da corrida antiga. Nos dois casos o validador "passou" sem nunca ter
   visto defeito nenhum — que é pior do que não o ter testado, porque agora há
   confiança.

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

### Interface

- Nada de interface pousa sobre o mapa. Uma doca tem duas metades:
  `Dock.tscn` (cenário) e `DocaCartao.tscn` (texto e alvo de toque).
- Alvo de toque mínimo 44px. O teste de design cobre.
- Dinheiro sai por `GameState.moeda()` — separador de milhar, um lugar só.
- O tema (`ui/tema_brport.tres`) é o ponto único de estilo. Script não pinta
  cor na mão.

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
- Comentário explica **por que**, e de preferência conta o que se tentou antes
  e não funcionou. O repositório inteiro é escrito assim; siga.
- Nada de emoji na interface — os 20 ícones vivem em `art/icones/` e são
  registrados em `scripts/Icones.gd`.
- `.gd.uid` e `.import` **entram no Git** (o `.gitignore` explica por quê).
