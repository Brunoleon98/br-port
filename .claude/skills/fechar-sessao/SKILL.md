---
name: fechar-sessao
description: Fecha uma sessão de trabalho no BR Port com o que a mudança exige — as suítes certas, a captura quando o visual mudou, a varredura do que se aprendeu, o ESTADO_DO_PROJETO.md em dia e o commit. Acione com "fechar a sessão", "fecha isso", "terminei", "pode commitar", "encerrar", "hora de fechar", ou antes de qualquer commit no fim de um bloco de trabalho. NÃO é para rodar teste no meio do caminho — para isso rode a suíte direto.
---

# Fechar sessão — BR Port

O ritual de fecho. Existe porque três coisas se perdem sempre no fim: uma
verificação que a mudança exigia e ninguém rodou, o `ESTADO_DO_PROJETO.md` a
envelhecer em silêncio, e uma lição que ficou só na conversa.

**As regras do projeto estão em `CLAUDE.md` e carregam sozinhas.** Esta skill
não as repete — ela só garante que foram cumpridas antes de fechar.

---

## 1. Descobrir o que mudou

O que mudou é que decide o resto. Rodar 600 partidas por causa de um typo em
documento é desperdício; não rodar por causa de um `# TUNING:` é negligência.

```sh
git status --short
git diff --stat $(git merge-base HEAD origin/main)..HEAD
```

**Numa sessão remota o `$G` já está pronto e o projeto já foi importado** —
quem faz isso é `.claude/hooks/session-start.sh`, e ele diz numa linha o que
deixou disponível. Se a primeira mensagem da sessão não trouxe essa linha, o
hook não correu: monte à mão pela receita do `CLAUDE.md`, que lê a versão de
`.godot-version` (num lugar só, e é lá que o CI também a lê).

```sh
G=~/godot-bin/Godot_v$(tr -d '[:space:]' < .godot-version)-stable_linux.x86_64
$G --headless --path brport_vs --import   # sem .godot a suíte falha com uma
                                          # pilha de "referenced non-existent
                                          # resource" que não tem nada a ver
                                          # com o que se está testando
```

## 2. A base: os cinco do Godot, sempre

São segundos cada um e o CI roda os cinco em todo push. Não há mudança neste
repositório barata o bastante para os pular.

```sh
for t in tests/run_tests tests/teste_design tests/teste_audio \
         tests/teste_fumaca scripts/validation/asset_validator; do
  $G --headless --path brport_vs --script res://$t.gd
done
```

Espera-se, na ordem: `TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`,
`FUMACA OK`, `ASSET OK`. O código de saída não chega: um erro de compilação do GDScript sai
com 0 sem rodar nada — é por isso que o CI também exige a linha final, e você
também deve.

## 3. O que só a sua mudança exige

| Se mexeu em… | Rode | Espera |
|---|---|---|
| preço ou constante `# TUNING:` | **a skill `/balancear`** — ela conduz a medição e o rasto | 100% / 79,5% / 35,7% ainda de pé |
| **qualquer `const` do `GameState.gd`** | o despejo + a tabela (abaixo) | `TABELA OK` |
| **a economia, de qualquer maneira** | `tools/projetar_parcelas.py` (abaixo) | o modelo ainda calibra nos 3 perfis |
| `tools/gerar_mapa_iso.py` | regerar os dois mapas (abaixo) | `git diff -- brport_vs/art` limpo |
| `tools/gerar_sons.py` | `python3 tools/gerar_sons.py brport_vs/audio/sfx` | `git diff -- brport_vs/audio` limpo |
| catálogo em `blender/` | `python3 blender/validate_brp_assets.py` | `BRP BLENDER OK` nas quatro categorias |
| **qualquer documento** | `python3 tools/conferir_docs.py` | `DOCS OK` |
| qualquer coisa visível | uma captura, e **olhar para ela** (seção 4) | — |

```sh
# Os dois mapas — o do porto e o do pátio. Regerar um só e esquecer o outro
# deixa a tabela de âncoras a descrever um porto que já não existe.
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  --sem-pavimento brport_vs/art/porto_mapa_iso.svg
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  brport_vs/art/porto_mapa_iso_patio.svg
git diff --stat -- brport_vs/art        # tem de sair vazio
```

```sh
# A tabela dos números é GERADA do GameState.gd. Mexer numa constante sem a
# regerar quebra o CI — e é de propósito: os números já viveram em dois sítios
# e divergiram uma vez, com registro na errata da economia.
$G --headless --path brport_vs --script res://tools/despejar_constantes.gd \
  -- /tmp/constantes.json
python3 tools/gerar_tabela_numeros.py --contra-godot /tmp/constantes.json

# E o modelo das Parcelas 2 e 3 tem de continuar a reconstruir a Fase 1 medida,
# senão não tem licença para falar das outras duas.
$G --headless --path brport_vs --script res://tools/simular_balanceamento.gd \
  -- 600 20260825 /tmp/medicao.json
python3 tools/projetar_parcelas.py --medicao /tmp/medicao.json \
  --constantes /tmp/constantes.json
```

**Sobre o simulador:** medir é com `-- 600`. As 30 partidas do CI são teste de
fumaça — provam que a ferramenta não quebrou junto com o `GameState` — e têm
margem de ±18 pontos. Comparar aquele número com os 79,5% é comparar sorteio; o
próprio simulador avisa quando a rodada é curta demais.

**Sobre o validador do Blender:** ele não roda no CI, e de propósito — precisa
do `bpy`, que são ~1 GB, e o que ele cobre (âncora, apoio ao solo, volume de
seleção) só existe com a cena montada. Se mexeu em catálogo, é na mão:
`pip install "bpy==4.5.0"` num Python 3.11.

## 4. Olhar, se o visual mudou

**Teste verde não prova que ficou bonito.** É a etapa que mais achado produz
por minuto gasto: das últimas rodadas saíram daqui uma pilha de caixotes que
virou massa marrom, um arbusto que era um balde, e rótulos enterrados debaixo
dos sprites — tudo com a suíte verde.

```sh
tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"   # as cinco de uma vez
```

São as mesmas cinco que o CI anexa a cada PR — a tela inicial, o porto
reconstruído, o boletim, o menu de pausa e a folha de ícones — e ele já diz na
página da corrida **qual** delas mudou. O que o CI não faz é julgar; olhar
continua a ser aqui.

Para um tiro só, à mão:

```sh
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --fixed-fps 60 --script res://tools/capturar_tela.gd -- 10 foto.png completo
```

⚠️ **Sem `--fixed-fps 60` a foto não se compara com nenhuma outra.** A semente
já é fixa, mas os tweens em laço andam por *delta*: medido, duas corridas do
mesmo código davam 1.030 pixels diferentes. Para olhar, tanto faz; para dizer
"mudou", faz toda a diferença.

Para uma cena que não seja a principal (uma bancada de teste, por exemplo),
`tools/capturar_cena.gd`, que só instancia e espera:

```sh
xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_cena.gd -- res://scenes/tests/AssetPlacementTest.tscn foto.png
```

⚠️ **Ao recortar a captura, some 62.** `MapaWrap` tem `offset_top = 62`: as
coordenadas que saem da projeção são do MAPA, não da tela. Três recortes já
foram parar no telhado ao lado do prop por causa disto.

## 5. Varredura do que se aprendeu

**Mexeu em documento? `python3 tools/conferir_docs.py`, e é menos de um
segundo.** Ele confere que as quatro camadas existem, que toda referência de
documento tem destino, que registro de sessão está em `docs/arquivo/` e no
índice de lá, e que o `ESTADO_DO_PROJETO.md` não voltou a inchar. O CI roda o
mesmo passo — descobrir aqui custa um segundo, descobrir lá custa uma corrida.

**É verificação, não escrita.** Quem trabalha escrevendo comentário à medida
que anda chega ao fim com quase tudo já registrado — medido numa sessão longa:
dez de doze lições já estavam no código ou em `docs/decisoes/`. A varredura
existe para as outras duas.

Percorra a conversa e, para cada coisa que se descobriu — uma armadilha, um
número medido, uma tentativa que falhou —, pergunte **onde isso está escrito**.
Se a resposta for "só aqui", ela se perde quando a conversa fechar.

Inclua nesta varredura **os documentos que a própria mudança envelheceu**. Esta
skill já apontou para um binário do Godot em `/tmp` numa versão que deixou de
ser a do CI, e ninguém a teria olhado se a varredura só procurasse lições
novas: quem muda uma receita tem de procurar quem a copiou.

| O que se aprendeu | Onde vive |
|---|---|
| Regra que vale sempre e para todos | `CLAUDE.md` — o único que carrega sozinho |
| Por que se decidiu assim | `docs/decisoes/NNN-titulo.md`, curto, uma por arquivo |
| Armadilha de uma função | Comentário nela, contando o que se tentou antes |
| Onde o projeto está hoje | `docs/ESTADO_DO_PROJETO.md` |

O que **não** merece registro: o que já está escrito, o que só vale para esta
mudança, e o que ninguém vai reler. Camada de documento é custo.

## 6. `ESTADO_DO_PROJETO.md` em dia

É o artefato crítico que **nenhum teste protege de verdade**. Ele envelhece
calado, e quando envelhece a sessão seguinte trabalha com uma fotografia errada
do projeto. Confira se ainda descreve o jogo depois desta sessão — o que existe,
o que é placeholder, o que ficou pendente.

⚠️ **Ele descreve o AGORA, e nada mais.** Em 02/09 ele tinha dobrado de tamanho
sem ninguém decidir, e por dentro contradizia-se: duas parcelas do Sr. Ribeiro
(R$8.000 e R$550.000) e três leituras do balanceamento, todas lidas como atuais,
porque o histórico tinha ficado a viver ao lado do estado. O caminho percorrido
vive agora em `docs/arquivo/HISTORICO.md` — **o que envelheceu desce para lá em
vez de ficar aqui com uma data ao lado.** O `conferir_docs.py` toca o alarme
quando o arquivo volta a crescer, mas o alarme não escreve o documento.

## 7. Commit

- Mensagem **em inglês**; código, comentário e documento em português.
- Diga o que mudou **e por quê**; se algo foi medido, ponha o número.
- Nada de identificador de modelo em commit, PR ou comentário.
- Só empurre para a branch designada da sessão, com `git push -u origin <branch>`.
- PR só se pedirem.

## Falha segura

Se uma verificação reprovar, **não feche**. Conserte, ou registre por escrito o
que ficou quebrado e por quê — um fecho com teste vermelho e sem nota é a forma
mais barata de a próxima sessão perder uma hora a descobrir sozinha.
