---
paths:
  - "brport_vs/project.godot"
  - "brport_vs/export_presets.cfg"
  - "brport_vs/COMO_RODAR.md"
  - "brport_vs/tools/medir_vram.gd"
  - "brport_vs/tools/medir_desempenho.gd"
  - ".github/workflows/**"
  - ".godot-version"
  - ".gitattributes"
  - ".claude/hooks/**"
---

# Regras — plataforma: Godot, export e pacote

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## O pacote (de «Como rodar»)

**Mas o `.pck` mede-se aqui, e sem template nenhum** — é o que responde "quanto
custa isto ao pacote?" sem esperar uma corrida do CI:
`$G --headless --path brport_vs --export-pack Android /tmp/brport.pck`. O APK e
o `brport-web` continuam a ler-se dos artefatos, e o **antes** costuma já estar
lá: a última corrida do `main` mediu-os no commit que a branch tem por base.
⚠️ **E «LER DOS ARTEFATOS» QUER DIZER O BRUNO, OU O LOG.** O conector do
GitHub devolve o endereço de download, mas o blob
(`*.blob.core.windows.net`) responde 403 pelo proxy desta sessão (`142`, o
relatório de uma fatia de mutantes). Daqui lê-se o log do job, pela cauda;
o que só está no artefato pede-se a ele, ou mede-se de novo aqui.

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

**E o custo por quadro também**, com a mesma receita e o
`medir_desempenho.gd`, que espera `DESEMPENHO MEDIDO`: chamadas de desenho,
nós, tweens e o `_process` de cada script pela chamada direta, na abertura e
no save de exemplo. ⚠️ **O tempo de quadro do motor não se lê aqui** — sob
`xvfb-run` ele inclui o desenho por software, em `--headless` o laço dorme —, e
o FPS mede-se no telefone (`099`).

## O Web, provado aqui (`099`)

**A identificação do build é gerada antes do export** (`128`), por
`tools/gerar_identificacao_build.py`; o recurso ignorado pelo Git entra nos
pacotes. Não copie um SHA para o código: identifique a árvore exportada e
marque modificações. O editor ignora esse recurso, que pode ser sobra de
outro export. O job confere a identificação dentro do `.pck`, contra o Git.
Em PR, esse SHA é o da junção testada pelo CI, que pode diferir da cabeça
da branch; na publicação do Pages é o commit exportado da main.

**O Pages publica o Web da `main` verde**, e o link é o que se manda a quem
vai testar; o protótipo HTML da raiz passou a `/prototipo/`. ⚠️ Só corre com a
fonte do Pages em «GitHub Actions», que é configuração do repositório.
⚠️ **O build é de fio único, e é isso que o deixa caber no Pages**, que não
manda COOP/COEP: um `variant/thread_support=true` no preset Web pede
`SharedArrayBuffer`, que sem esses cabeçalhos não existe.

**E prova-se aqui, sem telefone:** dos templates bastam os `web_*` (85 MB
dos 815 do `.tpz`, extraídos para
`~/.local/share/godot/export_templates/<versão>.stable/`); serve-se a pasta
com `python3 -m http.server`, que não manda cabeçalho nenhum, e abre-se no
Chromium do contêiner pelo Playwright global (`NODE_PATH=$(npm root -g)`, com
`--use-angle=swiftshader` para o WebGL). O console diz `single-threaded`, e um
`self.crossOriginIsolated` a falso com o jogo a chegar à partida é a prova de
que o Pages o serve.

## Chaves e export do Godot (de «Como rodar»)

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

⚠️ **No CI, importe por `tools/importar_para_ci.py`, inclusive a base do PR.**
No PR #130, o Godot 4.6.3 abortou com sinal 11 ao importar Patrick Hand na
base, depois de toda a captura do HEAD passar; repetir passou. O padrão está
no [bug de fontes paralelas do motor](https://github.com/godotengine/godot/issues/111039).
O helper escreve `editor/import/use_multiple_threads=false` no
`project.godot` só durante o import, recusa uma chave já escrita e devolve-o
byte a byte mesmo se o motor falhar. Não muda a versão do Godot, os scripts
de captura da base nem as guardas. Não substitua por um retry que dependa
de sorte.
⚠️ **E O `override.cfg` NÃO CHEGA AO `--import`.** Até 18/10 a chave ia
nele: um `--script` lia-a a falso, que foi a prova da `106`, e o import
continuou PARALELO — a fonte saía seis vezes nas linhas de reimport, contra
uma com a chave no `project.godot` —, e a base do PR #144 caiu duas vezes
nela. Chave de import prova-se no LOG do import, não numa leitura do motor
noutro modo; `tools/testar_importar_para_ci.py` tranca o sítio dela.
