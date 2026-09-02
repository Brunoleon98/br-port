# BR Port — Briefing para continuar (Bloco 5)

> Documento de entrada para a próxima conversa. Escrito em 29/08/2026.
>
> **Leia este arquivo primeiro, depois `docs/ESTADO_DO_PROJETO.md`.**
> Substitui o `BLOCO4_BRIEFING_CONTINUACAO.md`, cujos três caminhos foram
> todos fechados.

---

## 1. O que mudou nesta sessão

O jogo saiu de "administrar um porto pronto" para **"levantar um porto em
ruínas"**, e isso mexeu em tudo ao mesmo tempo: arte, interface, economia.

**O porto abre parado.** 1 doca, 1 trabalhador, R$400.000 em caixa e cinco
estruturas para consertar. O mapa começa com **pátio de terra batida, armazém
com telhado furado e escritório em ruína**; comprar cada estrutura muda o
mapa. O estado "porto completo" é o que a sessão anterior tinha como estado
único.

**Não se arrasta mais trabalhador a cada turno.** Há "Alocar todos" (serve o
barco mais caro primeiro) e toque-para-alocar. O arrasto continua.

**O porto se mexe.** Barcos balançam e chegam deslizando, copas de coqueiro
oscilam, lanças de guindaste varrem, e a doca que espera trabalhador pulsa.

**O terreno e a água deixaram de ser chapados.** A margem ganhou rampa de
profundidade, enrocamento e espuma; o pátio ganhou manchas, cascalho e mato (ou
remendo de asfalto, rachadura e faixa, quando pavimentado); o cais ganhou junta
de dilatação. Quatro coisas se aprenderam aqui, e valem para o resto da arte:

1. **Faixa de profundidade tem de SEGUIR a costa.** A costa é em degraus (ver
   §4). Elipse solta na água ignora isso e nunca lê como praia — lê como
   mancha. O helper `costa(de, ate)` devolve os pontos de uma faixa que
   acompanha os degraus, e é dele que sai o baixio inteiro.
2. **Perto tem contorno, longe não.** Pôr o mar aberto também como faixa em
   degraus cortava a água ao meio numa diagonal reta que parecia falha de
   desenho. Raso é aresta dura; fundo é degradê.
3. **Faixa uniforme não vira pedra, vira listra.** O enrocamento começou como
   uma tira cinza chapada com seixos regulares e leu como sujeira pintada no
   muro. O que faz o olho ler enrocamento é o CONTORNO irregular: pedras de
   tamanhos diferentes, encavaladas.
4. **Espuma é quantidade, não espessura.** Linha contínua ao longo do cais lê
   como arame; quebrar em `stroke-dasharray` só troca o arame por faixa de
   rodovia. Manchas de tamanho e opacidade irregulares é o que lê como
   arrebentação.

O mato passou pelo mesmo: três riscos retos saindo de um ponto liam como SETAS
verdes espalhadas pelo chão. Folha curva, baixa, fina e várias juntas — mato
aparece em moita, e é a moita que o olho reconhece.

---

## 2. A economia — MEDIDA, não estimada

| Perfil | Taxa | Caixa no vencimento (mediana) |
|---|---|---|
| Ótimo | 100,0% | R$10.223 |
| Mediano | 47,0% | R$7.945 |
| Descuidado | 0,0% | R$5.107 |

600 partidas por perfil. A mediana do mediano fecha em **R$7.945 contra uma
parcela de R$8.000** — é para ficar nessa margem.

> Estes números **substituem** os da tabela anterior (99,8% / 50,5% / 0%). Não
> houve mudança de preço: o simulador é que semeava o gerador DEPOIS de
> `new_game()`, e `new_game()` já sorteia a mão inicial de barcos. A abertura
> de toda partida vinha do gerador não semeado, e duas rodadas seguidas sem
> tocar em nada davam medianas diferentes. Corrigido; agora repete idêntico.
> O mediano continua no fio da navalha, só que meio ponto do outro lado.

### As cinco estruturas

| Estrutura | Custo | Efeito |
|---|---|---|
| Reconstruir o Píer 2 | R$900 | +1 doca, +1 trabalhador |
| Reconstruir o Píer 3 | R$1.600 | +1 doca, +1 trabalhador (exige o Píer 2) |
| Consertar o armazém | R$1.100 | +20% no valor de cada barco |
| Pavimentar o pátio | R$700 | dobra a renda semanal do píer |
| Reformar o escritório | R$500 | −50% nos salários da semana |

**O que se aprendeu afinando isto**, e vale para qualquer preço futuro:

1. **O teto de receita da Fase 1 é ~R$10.000 em 32 turnos.** A parcela come
   R$8.000. Sobra pouco: o conjunto das estruturas não pode passar de ~R$5.000
   sem o caixa inicial subir junto. A primeira tentativa pôs R$7.900 e o jogo
   ficou **0% para todos os perfis**.
2. **Uma estrutura que não se paga em 32 turnos é uma armadilha.** O escritório
   começou cortando manutenção (R$30/semana): pouparia R$18 e custava R$900.
   Passou a cortar SALÁRIO, que é o custo que cresce com o porto.
3. **Proporção, não escala.** O problema dos preços antigos não era o R$ ser
   baixo — era um píer custar R$400 enquanto um barco paga R$80–300, ou seja
   UM barco comprava um píer. Hoje o Píer 2 custa ~5 barcos.
4. **Mexer em `START_CASH` ou em qualquer custo SEM rodar
   `tools/simular_balanceamento.gd` quebra isto.** É determinístico por
   semente: dá para comparar antes/depois sem ruído.

---

## 3. O que fica para a próxima conversa

### A0) Subir a arte no Blender — **tem documento próprio, e já foi executado**

`docs/arquivo/BLOCO5_PROMPTS_BLENDER_RICO.md` responde, com medição e imagem, se dá
para chegar ao nível de uma arte de porto ilustrada usando o Blender por
script. Resumo: **o volume, a luz, o desgaste e a densidade de peça, sim; a
pincelada, não.**

Quatro dos cinco prompts daquele documento **já foram rodados** (ver a §2.5 de
lá, que traz as cinco correções que só apareceram ao executar):

- **A — luz, chanfro, desgaste:** feito. Rig de três pontos, `BEVEL` em toda
  malha, `material_gasto()`.
- **B — sombra de contato:** feito. Passe separado, composto em numpy dentro do
  Blender, com azimute PRÓPRIO (250°) — no azimute do mapa a sombra cai atrás
  do prop e não se vê.
- **C — geometria:** feito **só no guindaste**. Prédios, barcos e píer por
  fazer, e é aí que está o próximo ganho grande.
- **D — contorno:** testado e **rejeitado**. Fecha o vazado da treliça e
  engorda os props pequenos. Fica a flag `--contorno`, desligada.
- **E — água em Blender:** não iniciado. Continua sendo decisão do Bruno.

O lote inteiro de props leva **54 s** para regerar.

### A) O refino visual que ficou pendente

- ~~A lança do guindaste varre para o lado errado~~ — **resolvido** ao refazer
  o guindaste. O gerador do mapa já imprimia a conta: entre o centro do píer e
  a âncora do barco há Δmx = 0 e Δmy = +2,8, ou seja o barco encosta no FLANCO,
  não na ponta. A lança agora varre para −Y local, atravessando o convés.
- ~~A chip da doca cobre o meio do convés~~ — **resolvido em 30/08**, e pela
  saída que este parágrafo já apontava: repensar ONDE a informação da doca
  mora. Ela deixou de morar no mapa. A doca agora tem duas metades —
  `Dock.tscn` (píer, barco, guindaste, trabalhador, sobre o mapa) e
  `DocaCartao.tscn` (valor, turnos, trabalhador, numa barra alinhada logo
  abaixo do mapa) — e é o `Main` que sabe que as duas são a mesma doca. O
  mapa ficou sem nenhum retângulo de interface em cima, e os três alvos de
  toque saíram da diagonal para uma fileira, que é mais fácil de acertar com
  o polegar. O píer no mapa continua sendo alvo de arrasto: quando há
  trabalhador escolhido, ele ACENDE (modulate no sprite) em vez de ganhar
  uma moldura.
- **O retrato ilustrado do trabalhador** no cartão é de outra leva e de outra
  linguagem visual que o resto.
- ~~As faixas claras que atravessavam o pátio~~ — **resolvido em 30/08.** Não
  eram desenho: eram a margem de meia unidade em `my` que sobrava entre um
  degrau e o seguinte, e por isso iam dar na água sem levar a lugar nenhum. O
  pátio passou a ocupar o degrau inteiro e no lugar delas entrou uma malha
  viária de verdade — rua paralela ao cais, calçada, faixa tracejada e um
  acesso curto ligando a rua a cada berço.
- ~~O enrocamento cruzava a raiz do píer~~ — **resolvido em 30/08.** As pedras
  param onde o tabuado começa (`PIER_FOLGA`): ninguém joga pedra na frente da
  entrada de um píer, e a faixa cruzando ali fazia as pedras lerem como se
  estivessem por cima dele.

### A VILA — o que ficou pronto e o que falta

Atrás da rua há agora uma **fileira de casas**, e ela tem um caminho de
crescimento embutido: `--nivel-vila=N` no gerador do mapa. Nível 1 (o que
está no jogo) é casa térrea de telha de barro; 2 é sobrado; 3 é prédio. Só a
altura, o telhado e o número de linhas de janela mudam — a implantação é a
mesma, então a cidade cresce PARA CIMA no mesmo lote, que é o que se vê numa
cidade portuária de verdade.

Duas coisas para quem for subir a Fase:

1. **O nível 3 ainda lê como casa alta, não como prédio.** Implantação de
   1,35 × 1,1 com 56px de altura é uma torre estreita. Crescer de verdade
   pede FUNDIR LOTES — dois vizinhos viram um prédio — e isso é mudança em
   `lotes_da_vila()`, não em `VILA_NIVEIS`.
2. **A vila é assada no SVG, não é prop.** Prop é para o que troca de estado
   dentro de uma partida. A vila troca entre Fases, que é fronteira de
   conteúdo: subir o nível é regerar os dois mapas, não mexer no jogo. Se um
   dia a cidade crescer DURANTE a partida, aí sim ela vira prop.

### B) Props gerados e ainda sem uso

`caixote` e `conteiner` avulsos (foram assados no píer). Tudo o resto está em
uso.

### C) Perguntas de design em aberto

- **Os valores são "realistas" o bastante?** Ficaram em proporção (um píer vale
  ~5 barcos, o porto inteiro ~R$4.800 contra uma parcela de R$8.000), mas na
  escala narrativa do GDD — não na escala de um porto real, que seria milhões.
  Subir a escala exige reescrever a economia inteira do GDD, não só estes
  números.
- **Mais lugares para gastar?** Hoje são cinco. Candidatos naturais:
  contratar trabalhador avulso, comprar um barco próprio, seguro contra o
  rival.
- **A reputação continua sem efeito mecânico** — só o rótulo na HUD.

---

## 4. Ferramentas (não refazer)

| Ferramenta | O que faz |
|---|---|
| `tools/gerar_mapa_iso.py` | Mapa isométrico. Flags: `--sem-pieres`, `--sem-coqueiros`, `--sem-predios`, `--sem-pavimento`. O jogo usa duas saídas: terra batida e pavimentado. |
| `tools/gerar_props_iso.py` | Props em Blender por script. Confere a própria projeção ao fim. |
| `tools/preparar_sprites.py` | Conserta o alpha de PNG gerado por IA. Só faz falta para o gerador de imagem. |
| `tools/demo_guindaste_rico.py` | Demonstração, fora do jogo: o mesmo guindaste no pipeline de hoje e num mais rico. Base dos prompts de `BLOCO5_PROMPTS_BLENDER_RICO.md`. |
| `tools/gerar_props_iso.py --contorno` | Contorno Freestyle. **Testado e rejeitado** nesta escala — ver §2.5 daquele documento antes de reabrir. |
| `brport_vs/tools/simular_balanceamento.gd` | **Roda antes de mexer em qualquer preço.** |
| `brport_vs/tools/folha_icones.gd` | Folha de contato dos ícones nos 3 fundos. |
| `brport_vs/tools/capturar_tela.gd` | PNG do jogo rodando. Terceiro argumento `completo` compra todas as estruturas antes de montar a cena, para fotografar o mapa pavimentado. **Teste verde não prova que ficou bonito.** |

**O Godot RODA no contêiner destas sessões, e isto vale mais do que parece.**
Duas rodadas de trabalho visual foram feitas às cegas por falta desta linha:

    curl -sSL -o godot.zip https://github.com/godotengine/godot/releases/download/4.6.1-stable/Godot_v4.6.1-stable_linux.x86_64.zip
    unzip -q godot.zip && chmod +x Godot_v4.6.1-stable_linux.x86_64

São 70 MB e leva segundos. Depois:

    ./Godot... --headless --path brport_vs --import            # UMA VEZ por clone
    ./Godot... --headless --path brport_vs --script res://tests/run_tests.gd
    xvfb-run -a ./Godot... --path brport_vs --resolution 720x1280 \
      --rendering-driver opengl3 --script res://tools/capturar_tela.gd -- 12 foto.png completo

O `--import` não é opcional: num clone novo não existe a pasta `.godot`, e sem
ela a suíte falha com uma pilha de `referenced non-existent resource` que não
tem nada a ver com o que se está testando. O `xvfb-run` só é preciso para a
captura (que exige contexto gráfico); teste e import rodam sem tela.

O Blender entra como biblioteca Python, sem interface:

    python3 -m venv ~/bpy-venv && ~/bpy-venv/bin/pip install "bpy==4.5.13"

São ~950 MB e o contêiner é efêmero — reinstala a cada sessão.

---

## 5. Armadilhas medidas (não supostas)

As do Bloco 4 continuam válidas (ver `BLOCO4_BRIEFING_CONTINUACAO.md` §5).
As novas:

1. **Uma constante de balanceamento repetida num teste quebra ao afinar.**
   O teste do armazém fixava "+15%"; subir para 20% na afinação o partiu.
   Derive o esperado da constante.
2. **Testes que assumem a base do jogo quebram quando a base muda.** Com
   `DOCKS_BASE` de 2 para 1, metade da suíte caiu. Quem precisa de N docas
   pede N docas (`_garantir(docas, trabalhadores)`).
3. **O gerador de mapa trunca o SVG antes de gerar o conteúdo** — já corrigido,
   mas o Godot gravou `valid=false` no `.import` do arquivo vazio e **manteve
   o veredito depois de o arquivo voltar**. Apagar o `.import` força a
   reimportação.
4. **Semear o gerador DEPOIS de `new_game()` não semeia nada.** `new_game()`
   já chama `_spawn_boats()`, então a mão inicial saía do `_rng.randomize()`
   do `_ready`. O simulador fazia exatamente isso e dava medianas diferentes
   entre duas rodadas idênticas. Corrigido — agora repete igual. Quem for
   semear qualquer coisa: **antes** de montar o estado, nunca depois.
5. **Duas lajes que encostam no mesmo `my` deixam meio pixel de fundo entre
   elas**, e na tela isso vira uma linha escura pontilhada atravessando o
   cais. A constante `COSTURA` estica um triz o degrau de trás, que o da
   frente cobre.
6. **Save sem versão é uma bomba-relógio.** `DOCKS_BASE` foi de 2 para 1 e o
   save gravado antes continuou a ser carregado: o jogador ficava com duas
   docas de graça, `estruturas` vinha vazia (a chave nem existia naquela
   versão), o painel continuava a oferecer os píeres 2 e 3, e comprar os dois
   levava o porto a **4 docas num mapa que só desenha 3** — a quarta recebia
   barco e nunca aparecia. Hoje há `SAVE_VERSION`, save de outra versão é
   descartado, e `_reconciliar_roster()` deriva docas e trabalhadores do que
   está construído em vez de os tratar como contador solto.
7. **Contagem que a tela mostra tem de ser regra do jogo.** `VAGAS_NO_MAPA`
   vivia no `Main.gd`, então nada impedia o estado de passar do que a tela
   sabe desenhar — e passou. Virou `GameState.BERCOS_NO_MAPA`.
8. **Num plano isométrico, ordem de nó É profundidade.** O trabalhador era o
   último filho de `Dock.tscn` e por isso era desenhado por cima do cabo e do
   moitão do guindaste, que estão à frente dele no mundo. Parecia pendurado no
   ar. Sempre que um prop novo entrar numa cena, ele vai onde o `mx+my` dele
   manda.
9. **O que acompanha a costa tem de virar a esquina junto com ela.** O
   enrocamento era espalhado degrau por degrau, cada um ao longo do seu
   próprio `borda`, e nas quinas da escada as pedras caíam dentro do degrau
   seguinte — na tela, cascalho pintado em cima do concreto do cais. Agora a
   costa é um CONTORNO explícito (`contorno_costa`/`costa_deslocada`), com os
   espelhos dos degraus incluídos, e tudo o que a acompanha anda por ele com a
   normal apontando para o mar.
11. **Tudo o que vive em terra tem de ser medido A PARTIR DO CAIS.** A rua e
   as casas nasceram em `mx` absoluto e ficavam a 4 unidades da água no
   primeiro degrau e a 16 no último — no ecrã, saíam pela esquerda antes do
   terceiro. O cais avança 4 por degrau; o que não avança com ele sai do
   enquadramento. Os contêineres do pátio tinham o mesmo defeito e dois deles
   caíam dentro da rua nova.
12. **Ordem dos nós de cenário também é profundidade.** Os coqueiros vinham
   todos depois dos prédios e apareciam por cima do armazém estando atrás
   dele; o escritório, mais distante, tapava o armazém. Intercalados por
   `mx+my` crescente, cada um cai no seu lugar.
13. **A ferramenta de captura mentia sem dar erro.** `new_game()` tem 30% de
   abrir oferta do rival, e com o jogo em `rival_offer` toda compra é
   recusada — a foto do porto "completo" saía do porto EM RUÍNAS, com o nome
   certo e sem uma linha de aviso. Resolve a oferta antes de comprar e agora
   grita (`push_error`) se alguma compra falhar.
14. **O ThorVG não desenha `<text>`.** Texto escrito com fonte num SVG sai
   vazio dentro do Godot. Os números de doca pintados no cais são polígonos de
   estêncil (`DIGITOS` em `gerar_mapa_iso.py`) por causa disso — e o estêncil
   ainda ficou mais parecido com tinta de piso do que uma fonte ficaria.

---

## 5.5. O próximo bloco é ÁUDIO

`docs/design/BR_Port_Plano_Audio.md` é o documento de entrada da próxima conversa.
Resumo: **o jogo é mudo — zero arquivos, zero `AudioStream`, zero bus** — e o
contêiner não tem placa de som, então nenhuma sessão consegue ouvir o que
produz. Quem julga o som é o Bruno.

O que já está pronto é o guia de geração
(`docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md`, com os prompts de Suno e
ElevenLabs); o que falta é toda a engenharia. O maior achado do levantamento:
o sinal `message(text, kind)` do `GameState` já vem classificado em
good/warn/bad e **cobre 13 pontos da interface com um ouvinte só**.

As pendências de arte da §3 continuam abertas e NÃO entram no bloco de áudio.

---

## 6. Como abrir a conversa nova

Cole isto:

> Continuando o BR Port. Leia `docs/arquivo/BLOCO5_BRIEFING_CONTINUACAO.md` e depois
> `docs/ESTADO_DO_PROJETO.md`. A direção de arte (isométrico) e a economia das
> estruturas já estão decididas e medidas — não reabrir sem rodar o simulador.

E diga o que quer: subir a arte no Blender (§3A0 — tem prompts prontos), o
refino visual da §3A, mais lugares para gastar (§3C), ou outra coisa.

---

*BR Port · Briefing de continuação do Bloco 5 · Fase 4*
