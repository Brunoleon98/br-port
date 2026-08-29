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

**O porto abre parado.** 1 doca, 1 trabalhador, R$3.250 em caixa e cinco
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

`docs/BLOCO5_PROMPTS_BLENDER_RICO.md` responde, com medição e imagem, se dá
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
- **A chip da doca cobre o meio do convés.** É a tensão de sempre: o passo
  vertical entre docas é 180px e o píer ocupa ~155, então não cabe empilhar.
  A saída real é repensar ONDE a informação da doca mora. **Piorou um pouco**
  com o guindaste novo, que é mais alto e passa por trás da chip.
- **O retrato ilustrado do trabalhador** no cartão é de outra leva e de outra
  linguagem visual que o resto.

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

---

## 6. Como abrir a conversa nova

Cole isto:

> Continuando o BR Port. Leia `docs/BLOCO5_BRIEFING_CONTINUACAO.md` e depois
> `docs/ESTADO_DO_PROJETO.md`. A direção de arte (isométrico) e a economia das
> estruturas já estão decididas e medidas — não reabrir sem rodar o simulador.

E diga o que quer: subir a arte no Blender (§3A0 — tem prompts prontos), o
refino visual da §3A, mais lugares para gastar (§3C), ou outra coisa.

---

*BR Port · Briefing de continuação do Bloco 5 · Fase 4*
