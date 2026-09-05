---
name: arte
description: Conduz uma etapa de arte do BR Port — mexer na paleta ou no enquadramento do mapa, engordar props no Blender, contorno, materiais, rosto de personagem ou o chrome da interface — e arrasta atrás o que a mudança envelhece: os dois mapas, a tabela de âncoras, o teste de design, a captura e o rasto de prosa. Acione com "arte", "mexer na paleta", "trocar as cores do mapa", "engordar os props", "o mapa está sem graça", "aproximar/afastar a câmera", "MEIA_LARG", "Etapa 1/2/3/4/5/6 do plano de arte", "deixar a interface mais encorpada", ou antes de tocar em QUALQUER cor do dicionário `C` de gerar_mapa_iso.py ou em geometria de gerar_props_iso.py. NÃO é para tirar uma captura só para ver — para isso rode `tools/capturar_evidencia.sh` direto.
---

# Arte — BR Port

Trocar uma cor é uma linha. O que é caro é tudo o resto: dois mapas e uma
tabela de âncoras que o CI compara, um teste de design que existe para pegar
props e chão a divergirem, e — a parte que mais falha — **julgar se ficou bom**,
que não é a mesma pergunta que "passou".

**As regras do projeto estão em `CLAUDE.md` e carregam sozinhas.** Esta skill
não as repete: ela conduz a ordem, e trava nos pontos onde o olho engana.

O alvo escrito é `docs/design/BR_Port_Plano_Arte_Blender.md` (as seis etapas,
ordenadas por ganho ÷ custo) e `docs/design/referencias/README.md` (a leitura
das imagens, com a tabela de paleta AMOSTRADA delas).

---

## 0. Qual etapa, e ela precisa do Blender?

**Duas das seis não precisam**, e isso decide o custo da sessão inteira:

| Etapa | O que é | Blender? |
|---|---|---|
| 1 — Paleta e enquadramento | dicionário `C` e `MEIA_LARG` de `gerar_mapa_iso.py` | **a paleta não**; o enquadramento sim |
| 2 — A cauda dos props | contêiner, caixote, boia: 2 peças → dezenas | sim |
| 3 — Contorno pelo compositor | normal + profundidade, borda no compositor | sim |
| 4 — Materiais dirigidos | ripa, corrugado, ferrugem que escorre | sim |
| 5 — Personagem com rosto | folha de rostos num plano da cabeça | textura, não geometria |
| 6 — Interface encorpada | `ui/tema_brport.tres` e as cenas | **não** |

Sem Blender, a sessão roda inteira no que o hook de arranque já deixou pronto.
Com Blender, o primeiro passo é `pip install "bpy==4.5.0"` num Python 3.11 —
~1 GB e minutos, e é honesto dizer isso antes de prometer a etapa.

**Há um terceiro caso, e ele é barato.** `tools/conferir_lote_de_arte.py`
precisa de `numpy` e `pillow`, que NÃO vêm no contêiner e **não são o `bpy`**:
medido, `pip install numpy pillow` leva ~8 segundos. Quem vir o
`ModuleNotFoundError` e concluir "isto precisa de Blender" adia uma ferramenta
que custa nada.

⚠️ **`MEIA_LARG` não é uma constante, é um contrato.** Mudá-lo muda a projeção,
e então `gerar_props_iso.py`, `gerar_mapa_iso.py` e `Main.tscn` deixam de
concordar. Obriga a regerar TODOS os props (Blender) e a reconciliar o teste de
design. É a metade cara da Etapa 1 — separe-a da paleta e faça numa passagem
só dela.

---

## 1. Meça o estado atual ANTES de mexer

```sh
tools/capturar_evidencia.sh brport_vs /tmp/antes "$G"
```

Guarde essa pasta. É contra ela que tudo se compara, e é ela que responde
"ficou melhor?" — pergunta que a memória responde sempre que sim.

**Para paleta, meça também os NÚMEROS**, não só a foto. Luminância relativa
(`0.2126·R + 0.7152·G + 0.0722·B`) de cada tom da rampa, e a AMPLITUDE entre a
ponta escura e a clara. Guarde os valores; a §3 diz por quê.

---

## 2. Mexa — e a fonte dos valores não é o gosto de quem mexe

A tabela de paleta do `docs/design/referencias/README.md` traz os valores
**amostrados das imagens de referência**. Use-os. Inventar cor num projeto que
tem alvo escrito é trocar uma decisão registrada por uma preferência.

⚠️ **As imagens de referência podem não estar no repositório.** O README avisa
no topo quando não estão — elas chegaram por anexo de conversa, e anexo não vira
arquivo no disco. Se a etapa exigir *olhar* a referência (onde cabe uma praia,
qual o enquadramento), e ela não estiver lá, **pare e peça as imagens** em vez
de adivinhar. A leitura escrita cobre paleta e estilo; não cobre composição.

---

## 3. ⚠️ Trocar o MATIZ e esquecer o VALOR achata a imagem

A armadilha mais cara desta skill, e ela **passa na captura inteira**.

Medido em 02/09, na Etapa 1: a água foi de mar frio a turquesa tropical com os
dois valores amostrados nas duas pontas da rampa de profundidade. Ficou bonita
de cor e **chapada**:

| | antes (mar frio) | só o matiz | corrigido |
|---|---:|---:|---:|
| Amplitude da rampa (luminância) | 89,7 | **67,3** | 99,4 |
| Contraste da espuma (Weber) | 0,57 | **0,46** | 0,56 |

Duas coisas a levar daqui:

- **A amostragem vale ONDE foi feita.** A referência enquadra a água rasa junto
  ao cais; o nosso mapa tem muito mais água funda do que ela mostra. Pôr o valor
  "funda" amostrado na nossa água funda comprimiu a rampa em 25%. A correção foi
  manter as pontas amostradas na faixa que a referência enquadra e **estender a
  rampa para baixo no mesmo matiz**.
- **Contraste que o olho vê é RAZÃO, não diferença.** A espuma manteve quase a
  mesma diferença absoluta de luminância e perdeu um quinto do contraste
  percebido, porque o fundo ficou mais claro. Traço claro sobre água escura
  contrasta; sobre água clara, não.

**Meça a amplitude depois de mexer e compare com a de antes.** Se caiu, a
imagem achatou, por mais bonita que a cor esteja.

---

## 4. Regere o que a mudança envelheceu

```sh
# Os DOIS mapas — o do porto e o do pátio. Regerar um só deixa a tabela de
# âncoras a descrever um porto que já não existe.
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  --sem-pavimento brport_vs/art/porto_mapa_iso.svg
python3 tools/gerar_mapa_iso.py --sem-pieres --sem-coqueiros --sem-predios \
  brport_vs/art/porto_mapa_iso_patio.svg

# Props, se mexeu neles (precisa de bpy). Ele CONFERE A PRÓPRIA PROJEÇÃO ao
# fim e diz "ok — os PNGs caem no mapa em escala 1:1". Se disser FALHOU, os
# props deixaram de falar a mesma língua do mapa: pare aqui.
python3 tools/gerar_props_iso.py brport_vs/art/props [prop ...]

$G --headless --path brport_vs --import   # o Godot precisa reimportar o SVG
```

**Mexeu só em COR? A tabela de âncoras tem de sair idêntica.** É a prova de que
a projeção não foi tocada:

```sh
git diff --stat -- brport_vs/art/porto_mapa_ancoras.json   # vazio = certo
```

---

## 5. Olhe — e olhe AMPLIADO

```sh
tools/capturar_evidencia.sh brport_vs /tmp/depois "$G"
for f in inicio meio porto boletim pausa icones; do
  cmp -s /tmp/antes/$f.png /tmp/depois/$f.png && echo "$f igual" || echo "$f MUDOU"
done
```

`icones.png` **tem de ficar igual** numa mudança de mapa — a folha de contato
não desenha cenário. Se ela mudou, a mudança vazou para onde não devia.

⚠️ **A captura inteira mente por omissão.** A água achatada da §3 passou por ela
sem levantar suspeita; o que a denunciou foi o recorte:

```sh
$G --headless --path brport_vs --script res://tools/recortar_captura.gd -- \
  /tmp/depois/porto.png /tmp/recorte.png X Y LARG ALT 3
```

Recorte a mesma janela no antes e no depois e ponha os dois lado a lado. **Ao
recortar um PROP, some 62** ao Y — `MapaWrap` tem `offset_top = 62` e as
coordenadas da projeção são do MAPA. Para painel de interface não há offset.

Para a Etapa 2 (props) a medida é a **contagem de peças** por prop, e a tabela
de referência do plano de arte tem os números de hoje. Para a Etapa 6, o
`teste_design` mais a captura.

---

## 6. As suítes, e o que só esta mudança exige

Os cinco do Godot são base e rodam sempre. O que a arte acrescenta:

| Se mexeu em | Rode | Espera |
|---|---|---|
| qualquer coisa do mapa ou dos props | `tests/teste_design.gd` | `DESIGN OK` |
| o manifest ou o catálogo `blender/` | `blender/validate_brp_assets.py` — **precisa de `bpy`**, que ele importa via `brp_studio` | `BRP BLENDER OK` |
| arte que veio de FORA | `tools/conferir_lote_de_arte.py PASTA` — precisa de `numpy` e `pillow`, ~8 s | alfa de verdade e base a 26,57° |
| qualquer documento | `tools/conferir_docs.py` | `DOCS OK` |

O conferidor de lote pede a **pasta** como argumento e não tem padrão. Rodado
contra os props gerados por script ele diz "sem apoio plano para medir" na
maioria — é esperado: poste e trabalhador não têm base plana, e a ferramenta
existe para lote EXTERNO, onde o ângulo da base é justamente o que engana.

O `asset_validator.gd` (`ASSET OK`) já é um dos cinco e cobre o lado do Godot:
quadro, alfa, recorte e a projeção do manifest contra as âncoras.

---

## 7. O rasto de prosa

A etapa fica **meio feita** se só o código mudar:

| Onde | O que atualizar |
|---|---|
| `docs/design/BR_Port_Plano_Arte_Blender.md` | a etapa, com o que ficou E o que NÃO ficou, e por quê |
| `docs/design/referencias/README.md` | a tabela de paleta descreve "o projeto hoje" — se mudou, diga |
| `docs/ESTADO_DO_PROJETO.md` | o que é arte de verdade e o que ainda é placeholder |
| `CLAUDE.md` | só o que vale SEMPRE — armadilha nova de arte entra aqui |

**Diga o que não fez, e por quê.** Em 02/09 a faixa de areia da Etapa 1 ficou
de fora porque a costa do mapa é cais de pedra de ponta a ponta e as imagens de
referência não estavam no repositório. Registado nos dois documentos, isso é
uma decisão; não registado, seria um esquecimento que a sessão seguinte repete.

---

## 8. O gate é do Bruno, e o CI já o preparou

**A entrega da arte não é o commit — é ele olhar.** O workflow `captura.yml`
anexa a cada PR as seis imagens do antes E do depois e diz qual mudou, no
resumo da corrida e no log. Isso existe para a olhada custar um zip em vez de
uma sessão.

Escreva no PR **o que medir na imagem**, não só o que foi feito: "a rampa de
profundidade voltou" é uma afirmação que ele pode conferir; "ficou melhor" não.

---

## Falha segura

- O gerador de props diz `FALHOU — a projeção não bate` → **pare**. Props e
  mapa divergiram, e seguir produz arte que não assenta no chão.
- `git diff` sujo nas âncoras depois de mexer só em cor → algo mudou geometria
  sem querer. Ache antes de continuar.
- Sem as imagens de referência e a etapa precisa de composição → peça as
  imagens. Adivinhar composição já custou duas levas de sprite a este projeto.
