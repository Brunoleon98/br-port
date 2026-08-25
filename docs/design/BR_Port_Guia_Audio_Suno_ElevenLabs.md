# BR Port — Guia de Produção de Áudio
## Suno (música) + ElevenLabs (SFX)

---

## ANTES DE COMEÇAR: Prompt de Identidade

Cole este bloco no início de qualquer sessão nova no Suno ou ElevenLabs. Ele ancora o "universo sonoro" do jogo e evita resultados genéricos.

```
Context: Audio for a premium Brazilian port management mobile game set in a fictional coastal town called Porto Mirim. The sound world is warm, human, and distinctly Brazilian — drawing from regional styles like forró, baião, choro, MPB, samba, carimbó, ciranda, and maracatu depending on mood and context. Music is always instrumental (no vocals, no lyrics). Audio should feel grounded and cinematic — never generic or international.
```

---

## PARTE 1 — SUNO: Trilha Musical

### Como gerar no Suno
1. Acesse **suno.com** → **Create** → **Custom**
2. Cole o **Prompt de Identidade** acima no campo de descrição
3. Logo abaixo, adicione o prompt específico da camada
4. Marque **Instrumental** ou inclua `no vocals, no lyrics` no prompt
5. Gere **3–4 versões**, escolha a que termina de forma mais limpa para loop
6. Download em **WAV** → converta para **OGG 96kbps** (mobile) ou **128kbps** (PC) com Audacity ou ffmpeg

> **Naming convention:** `mus_[contexto]_[variante]_v[número].ogg`
> Exemplo: `mus_ocioso_calmo_v1.ogg`

---

### Camadas Musicais por Prioridade

#### P6 — Porto Ocioso (faixa base)
Estado: porto sem contratos urgentes, jogador explorando ou construindo.

```
Calm Brazilian instrumental, sparse choro guitar and cavaquinho, distant triangle and zabumba pulse, open harbor atmosphere, northeast Brazil coastal town, warm and unhurried, 68 BPM, lo-fi texture, background music, ends cleanly for looping, no vocals, no lyrics
```

**Dica:** esta é a faixa que toca mais tempo. Se soar "demais", adicione `very sparse`, `understated`, `ambient`.

---

#### P5 — Contrato em Andamento
Estado: trabalho acontecendo, ritmo normal de operação.

```
Upbeat Brazilian instrumental, baião groove, pandeiro rhythm, cavaquinho lead melody, zabumba pulse, focused and industrious, sunny coastal port, 100 BPM, medium energy, rhythmic forward momentum, loop-friendly, no vocals, no lyrics
```

---

#### P4 — Prazo Crítico (30min–2h de jogo)
Estado: contrato com prazo apertado, tensão crescendo sutilmente.

```
Moderately tense Brazilian instrumental, staccato strings over baião rhythm, triangle accents accelerating, cavaquinho in minor variation, northeast Brazil, 108 BPM, building unease, subtle urgency, loop-friendly, no vocals, no lyrics
```

---

#### P3 — Leilão / Alta Urgência
Estado: leilão ativo com prazo crítico ou contrato quase vencendo.

```
Urgent Brazilian instrumental, frevo-inspired brass accents, driving zabumba and triangle, fast and competitive, high tension, 128 BPM, percussive and intense, forward drive, loop-friendly, no vocals, no lyrics
```

---

#### P2 — Tema do Protagonista (cutscene/narrativa)
Estado: momento emocional importante — backstory, primeira grande conquista, créditos.

> ⚠️ Esta faixa **não aparece no gameplay**. A raridade preserva o impacto.

```
Heartfelt Brazilian cinematic theme, nylon string viola caipira solo lead, light MPB orchestral strings, emotional and optimistic, coastal Brazil sunset, 82 BPM, memorable melodic theme, cinematic quality, no vocals, no lyrics
```

---

#### P1 — Crise Total
Estado: tempestade, falência iminente, rival agindo criticamente.

```
Dramatic Brazilian orchestral instrumental, full maracatu percussion ensemble, brass stabs, urgent strings, tribal and powerful, crisis energy, 138 BPM, cinematic climax, intense and relentless, no vocals, no lyrics
```

---

#### Tema do Abutre (Rival)
Estado: rival aparece em cena ou age contra o jogador.

```
Sinister Brazilian instrumental villain theme, dark choro in minor key, slightly detuned cavaquinho, creeping bass line, unsettling rhythm, scheming and menacing, 88 BPM, tense and shadowy, no vocals, no lyrics
```

---

#### Festa de São Pedro (evento sazonal)
Estado: único momento em que a música para de ser ambiente e vira performance.

```
Joyful Brazilian ciranda instrumental, acoustic accordion and triangle, fast and celebratory, coastal folk festival energy, communal and festive, 148 BPM, full arrangement, energetic performance feel, no vocals, no lyrics
```

---

### Stinger de Crise (corte imediato < 1s)
O Suno não é ideal para stingers curtos. Use o ElevenLabs para isso:

```
Single dramatic brass chord sting, orchestral, sharp attack, very short decay, 0.8 seconds, crisis alert sound, Brazilian brass ensemble character
```

> Naming: `mus_stinger_crise_v1.wav`

---

### Tabela de Iteração — Suno

| Problema | O que adicionar ao prompt |
|---|---|
| Resultado genérico/internacional | Especifique instrumentos: `zabumba drum`, `sanfona accordion`, `cavaquinho` |
| Muito agitado para o contexto | Adicione `restrained`, `understated`, `background texture` |
| Não faz loop bem | Adicione `ends cleanly for looping`, `circular structure` |
| Sem identidade brasileira | Adicione estilo regional explícito: `baião`, `choro`, `maracatu` |
| BPM errado | Especifique com número: `exactly 100 BPM` |
| Vocals aparecem | Adicione `purely instrumental`, `no singing`, `no human voice` |

---

## PARTE 2 — ELEVENLABS: Efeitos Sonoros (SFX)

### Como gerar no ElevenLabs
1. Acesse **elevenlabs.io** → **Sound Effects**
2. Cole o prompt do SFX desejado
3. Gere **3–5 variações** por SFX
4. Baixe as **3 melhores** como WAV (o GDD pede 3 variantes para SFX de alta frequência)
5. Para SFX de UI com pitch shift no Godot, uma variante já basta

> **Naming convention:** `sfx_[categoria]_[nome]_v[1-3].wav`
> Exemplo: `sfx_ui_click_v1.wav`, `sfx_ui_click_v2.wav`, `sfx_ui_click_v3.wav`

---

### BLOCO A — Feedback de Interface (UI)

Estes três sons ensinam o jogador sem texto. São os mais importantes do jogo.

---

#### sfx_ui_click — Neutro / Confirmação simples
Duração alvo: **0.15s**

```
Short dry wood tap, clean single click, crisp and immediate, no reverb, no tail, UI button press, 0.15 seconds
```

> Gere 3 variantes (v1, v2, v3). No Godot, o pitch shift ±5% fará o resto.

---

#### sfx_ui_success — Confirmação positiva / Ação bem-sucedida
Duração alvo: **0.4s**

```
Two ascending notes, major third interval, small bell and pizzicato cavaquinho string pluck, bright and warm, positive feedback, 0.4 seconds, no reverb
```

---

#### sfx_ui_error — Erro / Ação bloqueada
Duração alvo: **0.3s**

```
Single descending dull thud, low wooden knock, muted and non-aggressive, soft impact, error or blocked action, 0.3 seconds, no reverb, never harsh
```

---

### BLOCO B — Feedback de Economia

---

#### sfx_ui_money — Moeda / Receita recebida
Duração alvo: **0.5s**

```
Two or three coins dropping into a wooden chest, bright jingle, warm acoustic, reward sound, 0.5 seconds, satisfying clink, no reverb
```

---

#### sfx_ui_alert — Alerta de urgência
Duração alvo: **0.4s**

```
Sharp triangle bell strike, Brazilian percussion, metallic ring, single hit with short decay, urgent and clear, 0.4 seconds, alarm tone
```

---

### BLOCO C — Porto: Navios

---

#### sfx_ship_arrive — Navio chegando
Duração alvo: **2s**

```
Deep ship horn single long blast, distant harbor, foghorn quality, reverb of open water, nautical atmosphere, 2 seconds
```

> SFX raro — uma variante basta (raridade evita fadiga auditiva).

---

#### sfx_ship_depart — Navio partindo
Duração alvo: **1.5s**

```
Ship horn two short blasts, medium distance, maritime departure signal, slight fade at end, harbor ambient reverb, 1.5 seconds
```

> Uma variante basta.

---

### BLOCO D — Porto: Operações

---

#### sfx_crane_operate — Guindaste operando
Duração alvo: **3s (para loop)**

```
Industrial port crane mechanical sound, steel cable under tension, slow rhythmic metallic pull, heavy machinery ambience, harbor dock, 3 seconds, loopable, industrial atmosphere
```

> No Godot, este som será usado em loop enquanto o guindaste estiver ativo.

---

#### sfx_build_start — Construção iniciada
Duração alvo: **0.5s**

```
Construction site start sound, first hammer strike on wood, brief burst of activity beginning, 0.5 seconds, energetic and purposeful
```

---

#### sfx_build_complete — Construção concluída
Duração alvo: **0.8s**

```
Satisfying construction completion sound, wooden knock followed by a small bright chime, warm and rewarding, 0.8 seconds, achievement feel
```

---

### BLOCO E — Porto: Pessoas e Contratos

---

#### sfx_worker_assign — Trabalhador designado
Duração alvo: **0.3s**

```
Short paper stamp on clipboard, crisp and bureaucratic, assignment confirmed, 0.3 seconds, office atmosphere, dry sound
```

---

#### sfx_contract_accept — Contrato aceito
Duração alvo: **0.6s**

```
Pen signing paper, confident quick stroke, followed by a brief positive chime, agreement sealed, 0.6 seconds, purposeful
```

---

#### sfx_contract_deliver — Contrato entregue
Duração alvo: **0.8s**

```
Official stamp on document, deep satisfying thud, followed by two ascending chime notes, delivery confirmed, 0.8 seconds, accomplished
```

---

### Tabela de Iteração — ElevenLabs

| Problema | O que mudar no prompt |
|---|---|
| Som muito longo | Adicione `brief`, `short`, especifique duração em segundos |
| Tom agressivo demais | Adicione `soft`, `gentle`, `non-aggressive`, `muted` |
| Muito reverb/eco | Adicione `dry`, `close mic`, `no reverb`, `anechoic` |
| Som genérico/digital | Especifique material físico: `wooden`, `metal`, `rope`, `paper` |
| Clicks indesejados no loop | Gere 3 variações e escolha a com fade natural no começo e fim |
| Muito grave (some no speaker de celular) | Adicione `bright`, `mid-range focus`, `clear transient` |

---

## PARTE 3 — Pós-Produção

### Ferramentas (gratuitas)
- **Audacity** — normalizar volume, cortar silêncio, exportar OGG/WAV
- **ffmpeg** (linha de comando) — conversão em lote para build

### Targets do GDD
| Tipo | Formato final | Loudness |
|---|---|---|
| Trilhas musicais (mobile) | OGG Vorbis 96kbps | -16 LUFS integrado |
| Trilhas musicais (PC/Steam) | OGG Vorbis 128kbps | -16 LUFS integrado |
| SFX curtos (< 1.5s) | WAV 44.1kHz 16-bit | -12 a -6 dBFS de pico |
| SFX médios (1.5–5s) | OGG Vorbis 192kbps | -12 a -6 dBFS de pico |
| Masters (arquivo original) | WAV 44.1kHz 24-bit | — |
| True Peak máximo | — | -12 dBFS |

### Teste obrigatório antes de aprovar qualquer áudio
1. Exporte o mix em **mono** (pan law -3dB)
2. Teste a **30% de volume** num speaker de celular barato ou iPhone SE
3. Critérios de aprovação:
   - Todos os SFX de gameplay são **inteligíveis**
   - O leitmotif é **reconhecível**
   - Nenhuma frequência crítica fica abaixo de 200Hz (speakers de celular não reproduzem)
   - Os três sons de feedback (click/sucesso/erro) são **distinguíveis entre si** sem contexto visual

---

## RESUMO — O que produzir no MVP

| # | Arquivo | Ferramenta | Variantes |
|---|---|---|---|
| 1 | `mus_ocioso_v1.ogg` | Suno | 1 |
| 2 | `mus_contrato_v1.ogg` | Suno | 1 |
| 3 | `mus_prazo_critico_v1.ogg` | Suno | 1 |
| 4 | `mus_leilao_v1.ogg` | Suno | 1 |
| 5 | `mus_protagonista_v1.ogg` | Suno | 1 |
| 6 | `mus_crise_v1.ogg` | Suno | 1 |
| 7 | `mus_stinger_crise_v1.wav` | ElevenLabs | 1 |
| 8 | `mus_abutre_v1.ogg` | Suno | 1 |
| 9 | `sfx_ui_click_v[1-3].wav` | ElevenLabs | **3** |
| 10 | `sfx_ui_success_v1.wav` | ElevenLabs | 1 |
| 11 | `sfx_ui_error_v1.wav` | ElevenLabs | 1 |
| 12 | `sfx_ui_money_v1.wav` | ElevenLabs | 1 |
| 13 | `sfx_ui_alert_v1.wav` | ElevenLabs | 1 |
| 14 | `sfx_ship_arrive_v1.wav` | ElevenLabs | 1 |
| 15 | `sfx_ship_depart_v1.wav` | ElevenLabs | 1 |
| 16 | `sfx_crane_operate_v1.wav` | ElevenLabs | 1 |
| 17 | `sfx_build_start_v[1-3].wav` | ElevenLabs | **3** |
| 18 | `sfx_build_complete_v1.wav` | ElevenLabs | 1 |
| 19 | `sfx_worker_assign_v1.wav` | ElevenLabs | 1 |
| 20 | `sfx_contract_accept_v1.wav` | ElevenLabs | 1 |
| 21 | `sfx_contract_deliver_v1.wav` | ElevenLabs | 1 |

**Total MVP: 23 arquivos** (8 músicas + 15 SFX)
