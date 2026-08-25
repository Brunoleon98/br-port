# BR Port — Guia do Bloco 1
**Semanas 1–6 · Setup + Godot + Frontload da Escrita**

> Abrir este arquivo no início de cada semana. Saber exatamente o que fazer antes de sentar na frente do computador economiza 30min de aquecimento mental.

---

## O que significa "concluir o Bloco 1"

Ao final da semana 6, três coisas precisam ser verdade:

1. **Você consegue criar uma cena nova, adicionar um sprite e fazer ele reagir a um clique.** Sem copiar tutorial — de cabeça.
2. **Uma build vazia (projeto zerado, sem assets do jogo) roda no seu celular Android.**
3. **Todos os textos do VS estão rascunhados** num arquivo separado (o Arquivo de Frontload).

Esses três critérios, não mais.

---

## Estrutura de cada semana

| Bloco | Quando | Tipo |
|---|---|---|
| **6h pesadas** | Fim de semana (sábado OU domingo) | Godot — código, setup, prática |
| **2h leves** | Qualquer noite da semana | Escrita — texto do jogo no Arquivo de Frontload |

As 2h leves não são opcionais. A escrita frontloadada agora significa que você não vai parar a produção no Bloco 4 pra escrever diálogo.

---

## Antes de começar: configurações de uma vez só

Quando o Godot abrir pela primeira vez:

1. **Versão:** confirme que é Godot 4.x (não 3.x). A tela inicial mostra a versão no título. Se for 3.x, desinstala e baixa o 4.x estável em godotengine.org.
2. **Renderer:** ao criar o projeto, escolha **Compatibility** (não Forward+ nem Mobile). Compatibility exporta pra Android, WebGL e desktop sem drama extra.
3. **Nome do projeto:** `brport_vs` — sem espaço, sem acento.
4. **Pasta:** cria uma pasta `brport` no desktop ou em Documentos. O projeto fica dentro dela.

---

## Semana 1 — Godot existe, e agora?

### 6h pesadas — Fim de semana

**Meta:** entender o que é uma cena, o que é um node, e rodar seu primeiro projeto sem copiar de tutorial.

**Passo a passo:**

**Hora 1 — Leitura sem mexer em nada**
Acesse: https://docs.godotengine.org/en/stable/getting_started/introduction/index.html
Lê as seções "Introduction to Godot" e "Key concepts". Não pula. Não é longo. Entender o modelo mental de cenas/nodes/signals agora economiza 10h de debug depois.

**Hora 2–4 — Tutorial oficial**
Siga o tutorial "Your First 2D Game":
https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html

Faça literalmente tudo que está escrito — não "mais ou menos". Se travar num passo, lê o erro em voz alta antes de buscar no Google. 80% dos erros de Godot se resolvem lendo a mensagem de erro inteira.

**Hora 5–6 — Experimento próprio**
Fecha o tutorial. Cria uma cena nova (não o projeto do tutorial). Adiciona um `Node2D` como raiz, adiciona um `ColorRect` como filho, muda a cor pra algo que você escolha. Adiciona um script GDScript e faz o ColorRect mudar de cor quando você clica nele.

Se conseguir fazer isso sem abrir tutorial: semana 1 concluída.
Se não conseguir: volta ao tutorial, relê a seção de scripts e sinais.

> **Dica de estúdio:** a tentação de "customizar o tutorial" é grande. Resiste. O tutorial oficial do Godot é bem feito porque ensina o modelo mental correto, não só o código. Seguir direto é mais rápido que seguir e adaptar ao mesmo tempo.

### 2h leves — Qualquer noite

**Tarefa:** Escreva a **1ª página do Diário do Porto** no Arquivo de Frontload.

A voz é do protagonista, primeira pessoa, semana 1 do jogo. Tom: incerteza com leveza. Não precisa ficar perfeito — fica pronto. Veja o rascunho no Arquivo de Frontload e ajuste pro seu gosto.

---

## Semana 2 — GDScript de verdade

### 6h pesadas — Fim de semana

**Meta:** entender variáveis, funções, condicionais e signals. Usar isso num projeto que você criou do zero.

**Passo a passo:**

**Hora 1–2 — Referência de GDScript**
Lê: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html

Foca nestas seções:
- Variáveis (`var`, tipos)
- Funções (`func`, `_ready`, `_process`)
- Condicionais (`if`, `elif`, `else`)
- Signals — emitir e conectar

**Hora 3–6 — Mini-projeto: carta clicável**

Cria um projeto novo (não o do tutorial). Objetivo: uma tela com um retângulo que, quando clicado, mostra um texto diferente a cada clique — simula o "abrir carta" do Boletim da Dona Cida.

Componentes:
- `Node2D` raiz
- `ColorRect` (o envelope)
- `Label` (o texto, começa invisível)
- Script com: variável de estado (`aberto = false`), signal de input, lógica de mostrar/esconder o Label

Se isso funcionar, você dominou o loop básico de interação do BR Port.

### 2h leves — Qualquer noite

**Tarefa:** Escreva os **3 Boletins da Dona Cida** (resultado ruim, neutro, excepcional) no Arquivo de Frontload. Os rascunhos já estão lá — ajuste o tom pra parecer com a Cida que você imagina.

---

## Semana 3 — Touch, mobile e a cena que responde ao dedo

### 6h pesadas — Fim de semana

**Meta:** adaptar input pra touch. Fazer algo responder ao toque no celular (simulado no editor por enquanto).

**Passo a passo:**

**Hora 1 — Input no Godot**
Lê: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html

Foco em:
- `InputEventMouseButton`
- `InputEventScreenTouch` ← esse é o touch real do mobile
- A diferença entre `_input()` e `_unhandled_input()`

**Hora 2–4 — Mini-projeto: drag-and-drop simples**

O drag-and-drop de trabalhadores é o coração do BR Port. Começa a entender agora.

Cria um projeto novo. Objetivo: um retângulo que você pode arrastar pela tela com o mouse/dedo.

Usa:
- `_input(event)` para detectar clique/toque
- Variável `arrastando = false`
- `global_position` pra mover o node

Quando o retângulo seguir o mouse ao arrastar e soltar quando você solta o botão: meta atingida.

**Hora 5–6 — Simular touch no editor**

No Godot, vá em: **Project → Project Settings → Input Devices → Pointing**
Marque **"Emulate Touch from Mouse"**.

Rode o projeto de drag-and-drop. Agora o mouse simula um dedo. O comportamento deve ser o mesmo. Se funcionar: você tem o fundamento do sistema principal do jogo.

### 2h leves — Qualquer noite

**Tarefa:** Escreva os **6–8 comentários curtos da Dona Cida** (loop gameplay) no Arquivo de Frontload. São linhas de 1–2 frases que aparecem durante o jogo. Pensa em cada situação (reputação subindo, caixa baixo, contrato perdido, etc.) e escreve o que a Cida diria.

---

## Semana 4 — Git, GitHub e o projeto real

### 6h pesadas — Fim de semana

**Meta:** criar o repositório real do BR Port no GitHub. Nunca mais perder trabalho.

**Passo a passo:**

**Hora 1 — .gitignore do Godot**

Cria a pasta do projeto real: `brport_vs` (separado dos experimentos das semanas anteriores).

No GitHub, cria um repositório privado chamado `brport-vs`.

Cria um arquivo `.gitignore` na raiz do projeto com este conteúdo mínimo para Godot:
```
.godot/
*.import
export_presets.cfg
android/
```

Isso evita commitar arquivos temporários que o Godot regenera automaticamente.

**Hora 2 — Primeiro commit**

Pelo terminal (ou GitHub Desktop se preferir):
```bash
git init
git add .
git commit -m "setup inicial do projeto brport_vs"
git branch -M main
git remote add origin [URL do seu repo]
git push -u origin main
```

Confirma que o repositório no GitHub mostra os arquivos.

**Hora 3–6 — Setup de export Android**

Esta é a parte mais chata do Bloco 1. Faz agora enquanto você ainda tem paciência.

Siga o guia oficial passo a passo:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

O que você vai precisar instalar (se não tiver):
- **Android Studio** (instala e aceita os SDKs que ele pede)
- **Java JDK 17** (o Godot 4 exige JDK 17, não outra versão)

No Godot, depois de configurar:
- Editor → Export → Add → Android
- Gera a keystore de debug (o Godot tem um botão pra isso)
- Exporta o APK

**Instala o APK no seu celular e abre.** Se abrir uma tela preta (projeto vazio): sucesso. Se der erro: lê a mensagem e busca exatamente o erro no Google — erros de export Android são específicos e bem documentados.

> **Aviso de estúdio:** setup Android é irritante na primeira vez. Reserva as 4h pra isso. Não é bug seu — é o ecossistema Android sendo Android. Uma vez configurado, nunca mais precisa fazer isso.

### 2h leves — Qualquer noite

**Tarefa:** Escreva as **linhas de negociação do Arlindo** no Arquivo de Frontload. São 5–8 linhas para a tela de contra-oferta — o que Arlindo diz quando o cliente considera a proposta dele, quando o jogador contra-oferece, e quando ele perde/ganha.

---

## Semana 5 — WebGL e o jogo no navegador

### 6h pesadas — Fim de semana

**Meta:** export WebGL funcionando. Projeto vazio abrindo no navegador. Entender cenas múltiplas e transição entre elas.

**Passo a passo:**

**Hora 1–2 — Export WebGL**

Siga: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html

O que é necessário:
- No Godot, vá em **Editor → Export → Add → Web**
- Exporta pra uma pasta local
- Abre o arquivo HTML num servidor local (o Godot tem um botão "Run in Browser" — usa ele)

**Importante:** WebGL não abre direto pelo sistema de arquivos. Precisa de servidor HTTP. O botão "Run in Browser" do Godot cuida disso. Se quiser testar manualmente: `python -m http.server 8000` na pasta do export e acessa `localhost:8000` no browser.

**Hora 3–6 — Cenas múltiplas e SceneTree**

O BR Port tem múltiplas telas (12 no VS). Você precisa saber mudar de cena.

Lê: https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html

Mini-projeto: cria 3 cenas simples (Tela A, Tela B, Tela C). Cada uma tem um botão que leva pra próxima. A Tela C volta pra Tela A.

Usa `get_tree().change_scene_to_file("res://tela_b.tscn")`.

Quando você conseguir navegar entre as 3 cenas sem travar: fundamento das telas do VS entendido.

### 2h leves — Qualquer noite

**Tarefa:** Escreva o **diálogo do Sr. Ribeiro** (cena de parcela) no Arquivo de Frontload. São 4–6 linhas para a visita dele na semana 4 do jogo. Tom: formal, mas humano. Ele foi amigo do avô.

---

## Semana 6 — O critério de conclusão

### 6h pesadas — Fim de semana

**Meta:** construir a cena de conclusão do Bloco 1. De memória, sem tutorial.

**A cena:**

Cria uma cena nova no projeto `brport_vs` (não num projeto de experimento). Ela deve ter:

1. Um fundo colorido (ColorRect ocupando a tela toda)
2. Um sprite (pode ser um retângulo colorido diferente — sem arte ainda)
3. Um Label com o texto "Toque pra interagir"
4. Quando o sprite é tocado/clicado: o Label muda o texto e o sprite muda de cor

Adiciona essa cena ao repositório:
```bash
git add .
git commit -m "cena de conclusão do Bloco 1"
git push
```

Exporta pra Android. Instala no celular. Toca o sprite. Se funcionar: **Bloco 1 concluído.**

**Hora 5–6 — Revisão do Arquivo de Frontload**

Lê tudo que você escreveu nas 2h leves das semanas anteriores. Ajusta o que soar errado. Não precisa ficar perfeito — precisa estar presente e coerente.

### 2h leves — Qualquer noite

**Tarefa:** Escreva a **narração de fim de Fase 1** no Arquivo de Frontload. São 10–15 linhas para a cena estática que aparece depois da Parcela 3 paga. Tom: contemplativo, brasileiro, sem exagero dramático.

---

## Checklist de conclusão do Bloco 1

Marca cada item quando for verdade — não antes.

- [ ] Consigo criar uma cena nova com sprite e script do zero, sem tutorial
- [ ] Entendo a diferença entre `_ready()` e `_process()` e sei quando usar cada um
- [ ] Drag-and-drop básico funciona (retângulo segue o mouse/dedo)
- [ ] Transição entre cenas funciona com `change_scene_to_file`
- [ ] Build Android instalada e rodando no celular (projeto vazio ou cena de conclusão)
- [ ] Export WebGL funcionando no browser
- [ ] Repositório GitHub com todos os experimentos e a cena de conclusão
- [ ] Arquivo de Frontload completo com todos os rascunhos de texto

**Quando todos marcados:** pronto pra começar o Bloco 2 — o loop core com placeholder.

---

## Se travar

**Sintoma:** erro de GDScript que não entendo.
→ Copia a mensagem de erro exata no Google. Adiciona "Godot 4" na busca. A documentação oficial e o fórum do Godot (forum.godotengine.org) resolvem 90% dos casos.

**Sintoma:** export Android falhando.
→ Lê a mensagem de erro completa no painel "Output" do Godot. Geralmente é Java JDK na versão errada ou SDK path mal configurado.

**Sintoma:** não consigo fazer algo que o tutorial mostra.
→ Versão do Godot. O tutorial pode ser de 4.0 e você estar no 4.3 (ou vice-versa). Confere a versão no topo da documentação.

**Sintoma:** semana perdida por vida pessoal.
→ Não recompõe. A regra do plano é clara: aceita a perda e continua no ritmo. Tentar repor cria burnout, não progresso.

---

*BR Port · Bloco 1 · Fase 4 · Versão 1.0*
