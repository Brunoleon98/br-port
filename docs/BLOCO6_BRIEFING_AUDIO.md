# BR Port — Briefing para continuar (Bloco 6): ÁUDIO

> Documento de entrada para a próxima conversa. Escrito em 29/08/2026.
>
> **Leia este primeiro.** Depois `docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md`
> (os prompts de geração já estão prontos lá) e só então
> `docs/BLOCO5_BRIEFING_CONTINUACAO.md` para o resto do estado.

---

## 0. ESTADO — o encanamento está FEITO (30/08)

O que este briefing pedia na §6 foi executado, e é o que está no jogo hoje:

| Pedido | Onde ficou |
|---|---|
| Buses `Musica` e `SFX` | `brport_vs/audio/default_bus_layout.tres` |
| Autoload tocador | `brport_vs/autoload/Audio.gd` |
| Ouvinte único de `message` | `Audio._ao_mensagem` — cobre os 13 pontos |
| Anti-empilhamento | prioridade por frame + espera mínima por som |
| Sons de rascunho | `tools/gerar_sons.py` → 10 WAV, 320 kB |
| Sliders de volume | `PauseMenu.gd`, gravados em `user://audio.cfg` |
| Clique em botão | `node_added` liga sozinho em todo `BaseButton` |
| O que dá para verificar | `tests/teste_audio.gd`, no CI |

**O que FALTA:** a música (as 8 camadas do guia), o ambiente de porto, o loop
do guindaste, e a troca dos efeitos de rascunho pelos reais. Nada disso muda
código — é trocar arquivo por arquivo na pasta `audio/sfx/`, mantendo o nome.

O resto deste documento continua válido como levantamento e como registro do
raciocínio.

---

## 1. O ponto de partida, sem rodeio

**O jogo é mudo. Zero.** Não é "tem pouco áudio": não existe um `AudioStream`,
um `AudioStreamPlayer`, um arquivo `.ogg`/`.wav`, nem uma linha de configuração
de áudio no `project.godot`. Medido:

```
$ grep -rl "AudioStream\|AudioServer" brport_vs --include=*.gd --include=*.tscn
(nada)
$ find brport_vs -iname "*.ogg" -o -iname "*.wav" -o -iname "*.mp3"
(nada)
```

O único autoload é o `GameState`. Não há bus de áudio, não há mixer, não há
volume nas opções.

Isso é bom: começa-se do zero, sem desfazer nada.

---

## 2. A ARMADILHA QUE MUDA COMO SE TRABALHA

**O contêiner não tem placa de som.** O Godot cai no driver mudo:

```
libpulse.so.0: cannot open shared object file
ALSA lib confmisc.c:855:(parse_card) cannot find card '0'
WARNING: All audio drivers failed, falling back to the dummy driver.
```

Isto não é um detalhe de ambiente, é a regra do bloco inteiro. Em arte havia o
lema *"teste verde não prova que ficou bonito"* e a saída era o
`capturar_tela.gd`. **Em áudio não há equivalente: ninguém aqui consegue ouvir
nada.** Quem julga se o som presta é o Bruno, e mais ninguém.

O que ainda dá para verificar aqui, e deve ser verificado sempre:

| Verificável por máquina | Só o Bruno julga |
|---|---|
| o arquivo importa sem erro | se soa bem |
| o `AudioStreamPlayer` existe e tem stream | se está alto demais |
| o sinal certo dispara o método certo | se cansa depois de 20 turnos |
| o bus existe e a rota está certa | se combina com o jogo |
| duração, taxa de amostragem, tamanho | se a mixagem está equilibrada |
| não toca dois sons no mesmo frame por engano | |

**Regra prática:** nunca escrever "o som ficou bom" num commit. Escrever "o som
toca no evento X, dura Y ms, roteado no bus Z" — que é o que dá para provar.

---

## 3. O que JÁ está pronto (não refazer)

`docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md`, 360 linhas, já traz:

- **Prompt de identidade** para colar no início de qualquer sessão de Suno ou
  ElevenLabs (universo sonoro brasileiro, instrumental, sem voz).
- **8 camadas musicais** com prompt pronto e BPM: porto ocioso (P6), contrato
  em andamento (P5), prazo crítico (P4), leilão (P3), tema do protagonista
  (P2), crise total (P1), tema do rival, e festa de São Pedro.
- **SFX por bloco** com prompt e duração alvo: UI (click 0,15 s / success
  0,4 s / error 0,3 s), economia (money, alert), navios (arrive, depart),
  operações (guindaste).
- **Convenções de nome**: `mus_[contexto]_[variante]_v[n].ogg` e
  `sfx_[categoria]_[nome]_v[1-3].wav`.
- Tabela de iteração para quando o Suno devolve algo genérico.

**O que o guia NÃO cobre, e é justamente o trabalho da próxima conversa:** nada
de engenharia. Ele não diz onde no código o som toca, nem como o Godot organiza
os buses, nem o que acontece quando dois sons disparam juntos.

---

## 4. O mapa evento → som, tirado do código (não inventado)

### 4.1 O achado que economiza a maior parte do trabalho

`GameState` já emite **um sinal único para toda mensagem de UI**, e ele já vem
classificado:

```gdscript
signal message(text: String, kind: String)
```

Os `kind` em uso hoje, contados no arquivo: **5 `"good"`, 6 `"warn"`,
2 `"bad"`** e alguns `""`. Isso mapeia quase 1:1 nos três sons de UI do guia:

| `kind` | som do guia | exemplos reais no código |
|---|---|---|
| `"good"` | `sfx_ui_success` | trabalhador alocado, barco fechado, estrutura pronta, parcela paga |
| `"warn"` | `sfx_ui_error` | doca vazia, doca já ocupada, resolva o rival primeiro |
| `"bad"` | `sfx_ui_error` (mais grave) | cliente foi embora, caixa insuficiente |
| `""` | `sfx_ui_click` | trabalhador liberado |

**Um único ouvinte de `message` cobre 13 pontos do jogo.** É por aí que se
começa: dá som a quase toda a interface com um `connect` só, em vez de espalhar
`play()` por sete scripts.

### 4.2 Os outros sinais, e o som que cada um pede

Todos já existem em `brport_vs/autoload/GameState.gd`:

| Sinal | Som | Observação |
|---|---|---|
| `cash_changed` | `sfx_ui_money` | **só quando sobe.** Tocar moeda ao gastar é o erro clássico |
| `boats_spawned` | `sfx_ship_arrive` | já existe animação de chegada deslizando em `Dock.gd` — sincronizar |
| `turn_advanced` | — | provavelmente nada; o dia passa muito |
| `rival_offer_triggered` | `sfx_ui_alert` + tema do rival | o único momento em que a música devia mudar |
| `debt_due` | `sfx_ui_alert` | momento de maior tensão do jogo |
| `game_over(won)` | vitória / derrota | dois sons distintos, e é onde o tema do protagonista (P2) cabe |
| `reputation_changed` | — | cuidado: dispara junto com outros; som aqui vira sobreposição |
| `roster_changed` | — | idem |
| `phase_changed` | troca de música | é o gancho natural para a camada musical |

### 4.3 Fora do `GameState`

- **18 pontos de `pressed`** nos scripts (`_on_*_pressed` e `pressed.connect`).
  O guia pede pitch shift ±5% no click para não cansar — vale um helper único
  em vez de configurar botão a botão.
- **Guindaste operando**: `Dock.gd` já anima a lança (`_mostrar_lanca`). O
  `sfx_crane_operate` é loop de 3 s e devia acompanhar essa animação, não o
  turno.
- **Barco balançando / água**: não há ambiente nenhum hoje. É o que dá
  "presença" ao porto e não está no guia como camada separada — decidir se
  vira faixa de ambiente ou parte da música ociosa.

---

## 5. Decisões de engenharia a tomar (nenhuma está tomada)

1. **Buses.** Mínimo: `Master` → `Musica` e `Master` → `SFX`, para o volume
   ficar separado nas opções. Isso é `default_bus_layout.tres`, que hoje não
   existe.
2. **Onde mora o tocador.** Um autoload `Audio.gd` ao lado do `GameState`, com
   `tocar_sfx(nome)` e `trocar_musica(camada)`, é o que evita `AudioStreamPlayer`
   espalhado por cena. Segue o mesmo espírito do `Icones.gd`, que já centralizou
   os ícones e funcionou.
3. **Polifonia e anti-empilhamento.** Vários sinais disparam no mesmo frame
   (avançar o dia emite `turn_advanced`, `boats_spawned`, `cash_changed` e
   `message` de uma vez). Sem uma regra, isso vira um estouro. Decidir:
   prioridade, ou janela mínima entre sons iguais.
4. **Formato.** O guia pede OGG 96 kbps para mobile. Confirmar que o Godot 4.6
   importa como esperado e qual o peso total.
5. **Volume e o menu de pausa.** `PauseMenu.tscn` já existe e é o lugar óbvio
   para os dois sliders.
6. **Música com o jogo pausado.** Decidir se a trilha continua no menu.

---

## 6. A recomendação forte: sons de rascunho ANTES dos sons reais

Suno e ElevenLabs são serviços web que **o Bruno usa à mão** — nenhuma sessão
aqui consegue chamá-los. Se a engenharia esperar pelos arquivos, a próxima
conversa fica bloqueada logo no começo.

A saída é gerar **placeholders sintetizados por script** (um seno com envelope
já serve: click, success, error, money, alert) e construir todo o encanamento
em cima deles — bus, autoload, ligação com os sinais, anti-empilhamento,
sliders de volume. Quando os WAV do Suno/ElevenLabs chegarem, é só trocar
arquivo por arquivo, sem tocar em código.

Isso também dá algo que dá para verificar por máquina: com placeholder de
duração conhecida, dá para afirmar "toca 0,15 s no evento X" e provar.

> `numpy` já está instalado no `~/bpy-venv` desta sessão, e escrever WAV em
> Python puro é o módulo `wave` da biblioteca padrão. Não precisa de
> dependência nova.

---

## 7. Como abrir a conversa nova

Cole isto:

> Continuando o BR Port, e agora quero focar em ÁUDIO. Leia
> `docs/BLOCO6_BRIEFING_AUDIO.md` e depois
> `docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md`.
>
> Lembre que este contêiner não tem placa de som — você não consegue ouvir
> nada, então verifique o que é verificável (o arquivo importa, o sinal
> dispara, o bus está certo) e não afirme que ficou bom.
>
> Comece pelo encanamento com sons de rascunho sintetizados, como diz a §6:
> bus de Música e SFX, um autoload `Audio.gd`, e o ouvinte único de
> `message(text, kind)` que já cobre 13 pontos da interface. Os arquivos reais
> do Suno/ElevenLabs eu trago depois.

---

## 8. O que NÃO é deste bloco

Para não misturar: o Bloco 5 deixou pendências de arte que continuam abertas e
**não devem entrar aqui** —

- a segunda metade do Prompt C (prédios, barcos e convés do píer ainda são a
  geometria antiga);
- a chip da doca cobrindo o convés, que piorou com o guindaste novo;
- o retrato ilustrado do trabalhador, de outra linguagem visual.

Estão descritas em `docs/BLOCO5_BRIEFING_CONTINUACAO.md` §3 e em
`docs/BLOCO5_PROMPTS_BLENDER_RICO.md`.

---

## 9. Ferramentas (as de sempre)

| Ferramenta | O que faz |
|---|---|
| `brport_vs/tests/run_tests.gd` | 54 asserções. Roda a cada mudança. |
| `brport_vs/tools/simular_balanceamento.gd` | **Antes de mexer em qualquer preço.** Determinístico por semente. |
| `brport_vs/tools/capturar_tela.gd` | PNG do jogo. 3º argumento `completo` fotografa o porto reconstruído. |
| `tools/gerar_mapa_iso.py` | Mapa isométrico, duas saídas (terra batida e pavimentado). |
| `tools/gerar_props_iso.py` | Props em Blender. Confere a própria projeção ao fim. |

O Blender entra como biblioteca, e o contêiner é efêmero — reinstala a cada
sessão (`~950 MB`):

    python3 -m venv ~/bpy-venv && ~/bpy-venv/bin/pip install "bpy==4.5.13"

**Para áudio isso não é necessário.**

---

*BR Port · Briefing de áudio do Bloco 6 · Fase 4*
