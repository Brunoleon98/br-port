# BR Port — Bloco 3: marco intermediário

> Validar que o loop não está quebrado **antes** de gastar semanas produzindo
> arte em cima dele.
>
> **Critério de conclusão** (Plano de Produção, Bloco 3): uma decisão registrada
> — *"loop pronto para receber arte final"* ou *"preciso de mais X semanas de
> ajuste"*. Se o ajuste necessário passar de 3 semanas, voltar e replanejar a
> Fase 2.

Este documento tem três partes: o que a **medição** já respondeu, como conduzir
o **playtest humano**, e onde **registrar a decisão**.

---

## Parte 1 — O que a medição já diz

> 📌 **Esta parte é o diagnóstico de ANTES do ajuste.** Ela está preservada
> como está porque é o raciocínio que levou à decisão registrada na Parte 3 —
> e porque o playtest humano confirmou cada achado dela. Para os números de
> hoje, ver a Parte 3.

### A pendência anterior estava mal lida

O handoff registrava *"o jogo está provavelmente fácil demais — ~63% de
vitória"*. Esse número saiu da suíte de testes, que joga **perfeito**: aloca
todo trabalhador em todo barco, todo turno, e sempre iguala a oferta do rival.
Ninguém joga assim. E com 40 partidas a margem de erro é de ±15 pontos — na
prática, "63%" e "47%" são a mesma medida.

O simulador (`brport_vs/tools/simular_balanceamento.gd`) refaz a conta com três
perfis de jogador e amostra grande. **3.000 partidas por perfil, semente 20260825:**

| Perfil | Como joga | Vitórias | Caixa no vencimento (mediana) | Barcos perdidos |
|---|---|---|---|---|
| **Ótimo** | aloca tudo, sempre iguala o rival | **58,5%** ± 1,8 | R$ 8.188 | 0,0 |
| **Mediano** | deixa uma doca passar às vezes, recusa o rival às vezes | **7,2%** ± 0,9 | R$ 6.634 | 4,0 |
| **Descuidado** | perde barco com frequência, recusa mais do que aceita | **0,1%** | R$ 4.689 | 8,3 |

O diagnóstico muda de figura: **o jogo não está fácil demais.**

### Os quatro achados

**1. Está no fio da navalha, não fácil.**
Jogando perfeito, o caixa mediano no vencimento é R$ 8.188 contra os R$ 8.000
exigidos — **2% de folga**. Quem joga certo ganha pouco mais que cara-ou-coroa
(58%), e quem decide não é o jogador: é o sorteio dos barcos daquela partida.

**2. Um jogador normal não ganha.**
7% para o perfil mediano. Bastam ~4 barcos perdidos em 12 turnos para a partida
virar impossível — e esse é o comportamento esperado de alguém aprendendo a
interface na primeira partida, que é exatamente quem vai jogar no seu playtest.

**3. Não dá para quebrar — a derrota por caixa é código morto.**
Em 9.000 partidas simuladas, **nenhuma** terminou por caixa negativo. A conta
explica: com 2 trabalhadores o píer paga R$ 240/semana e os custos somam
R$ 230 — o caixa sobe sozinho, sem atender barco nenhum. A única forma de perder
é o portão da parcela no turno 12. Ou seja, das duas condições de derrota do
sistema, só uma existe de verdade.

**4. A contra-oferta do Arlindo não é uma decisão.**
Nada no jogo lê `reputation` além do rótulo na HUD e da tela final — ela não
afeta valor de barco, chegada, custo nem o final. Como igualar custa 15% do
barco e recusar perde o barco inteiro, **igualar é sempre a jogada certa**. A
tela existe, o cliente reage, mas não há trade-off: tem um botão certo e um
errado. Isso é decisão de design (GDD), não de balanceamento — mas é a coisa
mais importante para observar no playtest: veja se o testador percebe que é
sempre igualar, e em quantos turnos.

### Se for ajustar: o que cada alavanca faz

Medido com 800 partidas por perfil, mudando **uma** constante por vez.

> ✅ **Resolvido de outro jeito.** Nenhuma destas duas alavancas foi a escolhida.
> O playtest e a revisão do GDD mostraram que a correção certa era uma terceira:
> **aumentar os turnos por semana**, o que deixou os barcos voltarem para a
> faixa do GDD. As tabelas abaixo ficam como registro do que foi considerado.

**Alavanca A — valor da parcela** (`PARCELA_AMOUNT`)

| Parcela | Ótimo | Mediano | Descuidado |
|---|---|---|---|
| R$ 8.000 *(hoje)* | 57% | 8% | 0,1% |
| R$ 7.000 | 91% | 35% | 2% |
| R$ 6.500 | 97% | 55% | 6% |
| R$ 6.000 | 99% | 74% | 13% |

**Alavanca B — chance de chegada de barco por doca** (`BOAT_ARRIVAL_CHANCE`)

| Chegada | Ótimo | Mediano | Descuidado |
|---|---|---|---|
| 0,75 *(hoje)* | 57% | 8% | 0,1% |
| 0,85 | 92% | 23% | 0,2% |
| 0,95 | 99,8% | 59% | 1,6% |
| 1,00 | 100% | 75% | 4% |

As duas resolvem o teto, mas têm sabores diferentes: **A afrouxa o portão para
todo mundo** (o descuidado também passa a ganhar às vezes), enquanto **B
recompensa quem presta atenção** — chegam mais barcos, mas alguém precisa
alocar trabalhador neles, e o descuidado continua perdendo.

Repare também na sensibilidade: R$ 8.000 → R$ 7.000 leva o jogo perfeito de 57%
para 91%. Um portão único de tudo-ou-nada num instante só é sempre assim —
perto do limiar, vira sorteio. Se isso incomodar, a correção não é achar o
número mágico e sim mudar o formato (parcelar em dois pagamentos, avisar o
valor com antecedência, permitir adiantamento). **Isso é decisão sua, e é
justamente o tipo de coisa que o Bloco 3 existe para decidir.**

> ⚠️ A simulação mede o sistema, não a pessoa. O perfil "Mediano" é um modelo de
> como alguém erra, não um jogador real. Jogue e observe alguém jogando **antes**
> de mexer em qualquer número — é para isso que serve a Parte 2.

---

## Parte 2 — O playtest

### 2.1 Você jogando (2 sessões, dias diferentes)

Jogue partidas inteiras sem mexer no código. Anote **enquanto joga**, não
depois — o que incomoda some da memória em cinco minutos.

- Em que turno você percebeu que ia perder (ou ganhar)? Ainda dava para reagir?
- Teve algum turno em que você não teve decisão nenhuma para tomar?
- A tela do Arlindo: você chegou a pensar antes de clicar, ou já era automático?
- O que você quis fazer e o jogo não deixou?

### 2.2 A pessoa de confiança (1 pessoa, sem instrução)

O plano é explícito: **observar o comportamento, não colher a opinião.**

**Regras para você:**

1. **Não explique nada.** Entregue com uma frase só: *"Você administra um porto
   pequeno. Vê o que dá."* E cale a boca.
2. **Não socorra.** Se travar, deixe travar. Só intervenha depois de ~2 minutos
   parado, e anote o minuto exato em que isso aconteceu.
3. **Não defenda o jogo.** Se a pessoa reclamar, anote e siga. Discutir contamina
   o resto da sessão.
4. **Anote o que ela FAZ, não o que ela diz.** "Clicou três vezes no trabalhador
   antes de arrastar" vale mais que "achei legal".

**O que observar em específico** (são os pontos onde este loop pode estar
quebrado):

| Momento | Pergunta a responder observando |
|---|---|
| Primeiros 30s | Ela descobre o drag-and-drop sozinha? Quanto tempo leva? |
| Primeiro turno | Ela entende que "Avançar dia" é o que faz o jogo andar? |
| Tela do Arlindo | Ela lê ou clica no primeiro botão? Volta a pensar na 2ª vez? |
| Barco perdido | Ela percebe que perdeu um barco — e por quê? |
| Semana 2–3 | Ela sabe quanto precisa juntar e quanto falta? |
| Upgrade | Ela vê que existe? Compra? Entende o que comprou? |
| Vencimento | A derrota (ou vitória) faz sentido para ela, ou parece aleatória? |

**Folha de sessão** (copie para um arquivo e preencha):

```
Testador: ______________   Data: ____/____/______   Duração: ______ min
Resultado: ( ) venceu   ( ) perdeu — caixa no vencimento: R$________

Minuto | O que ela fez / onde travou
-------|--------------------------------------------------
       |
       |
       |

Descobriu o drag-and-drop sozinha?   ( ) sim, em ____s   ( ) não, precisei falar
Entendeu o prazo da parcela?         ( ) sim   ( ) não   ( ) só no fim
Pensou na tela do Arlindo?           ( ) sim   ( ) clicou direto
A derrota/vitória fez sentido?       ( ) sim   ( ) achou aleatória

Três coisas que ela fez e eu não esperava:
1.
2.
3.
```

**Só no fim**, depois de fechar o jogo, três perguntas — nesta ordem:

1. "Me conta o que você estava tentando fazer." *(antes de qualquer opinião)*
2. "Teve algum momento em que você não sabia o que fazer?"
3. "Se fosse continuar jogando, o que você ia querer fazer diferente?"

---

## Parte 3 — A decisão · **REGISTRADA em 26/08/2026**

### O playtest que decidiu

**Bruno, 5 partidas completas, 25–26/08/2026.**

| # | Caixa no vencimento | Atendidos | Perdidos | Resultado |
|---|---|---|---|---|
| 1 | R$ 6.509 | 15 | 0 | perdeu |
| 2 | R$ 7.010 | 18 | 2 | perdeu |
| 3 | — | 20 | 0 | **venceu** |
| 4 | R$ 7.490 | 21 | 0 | perdeu |
| 5 | **R$ 7.999** | 22 | 0 | perdeu — **por R$ 1** |

**1 vitória em 5.** E em 4 das 5 partidas ele não perdeu nenhum barco, ou seja,
jogou no nível do perfil "Ótimo" da simulação. A partida 5 terminou a um real
da parcela.

Isso fechou a questão que a Parte 1 tinha deixado em aberto: o problema não
era o jogador, era o sistema. A simulação já dizia 58% para jogo perfeito; o
humano confirmou ao vivo, e o "R$ 7.999" é a demonstração mais limpa possível
de que o resultado estava sendo decidido pelo sorteio dos barcos.

### O que o playtest apontou além da dificuldade

1. **"Manter preço" não era uma decisão.** O jogador relatou: *"ao deixar o
   cliente impaciente eu igualava o preço para não perder ele"*. A leitura
   estava correta — o código não tinha sorteio nenhum: apertar "Manter preço"
   duas vezes **sempre** perdia o barco. Confirma o achado 4 da Parte 1, com a
   causa exata.
2. **Partidas curtas demais.** *"foi bem rápido terminar as partidas"* — 12
   turnos.
3. **Visual aquém do protótipo HTML**, com o pedido de melhorá-lo antes da arte
   final, para facilitar o encaixe.
4. **Sensação de que o VS é pequeno**, mais protótipo que vertical slice.

### DECISÃO: **B — ajustar antes de ir para a arte final**

**Estimativa: dentro de 1 semana** (bem abaixo do limite de 3 semanas que
obrigaria a replanejar a Fase 2).

O que foi ajustado — e por que cada um era "consertar o que está quebrado", não
inflar escopo:

| Ajuste | Por que era obrigatório |
|---|---|
| **8 turnos/semana** (era 3) | Sem isso a parcela só cabia inflando o barco para fora da faixa do GDD. Resolve junto a queixa de partida curta. |
| **Barcos de volta a R$ 80–300** | Voltam à faixa que o GDD define para a Fase 1. Elimina o desvio que estava registrado como dívida conhecida. |
| **Contra-oferta com os 3 presets do GDD** | O painel implementado não era o que o GDD especifica, e uma das opções era matematicamente impossível de dar certo. Isso é um defeito, não um ajuste de gosto. |
| **Errata da economia do GDD** | A aritmética do GDD não fechava nem a Parcela 1. Deixar passar faria o mesmo erro reaparecer na Fase 2. |
| **UI em cenas `.tscn`** | A interface era construída por código imperativo. Encaixar arte por cima disso no Bloco 4 exigiria reescrevê-la de qualquer forma — fazer agora é mais barato que fazer depois. |

**Resultado medido depois do ajuste** (2.000 partidas por perfil):

| Perfil | Antes | Depois |
|---|---|---|
| Joga perfeito | 58,5% | **99,7%** |
| Joga mediano | 7,2% | **63,8%** |
| Joga mal | 0,1% | **0,7%** |
| Folga no vencimento (jogo perfeito) | 2% | **20%** |

### Sobre "parece mais protótipo que vertical slice"

A percepção está certa sobre o estado de hoje, e o plano concorda com ela: o
que falta para virar VS — Dona Cida, a cena do Sr. Ribeiro, Diário do Porto,
áudio, narrativa e arte — é exatamente o conteúdo dos Blocos 4 e 5. O Bloco 2
entrega o esqueleto de sistemas, e é o esqueleto que o Bloco 3 valida.

Vale registrar a proporção, porque ela é real: o VS cobre a **Parcela 1 de 3**
do Ato 1, e o Ato 1 é **1 de 5 fases** do jogo. É pequeno de propósito — a
função dele é provar que o loop funciona antes de a produção cara começar.

### Próximo passo

**Bloco 4 — arte final + áudio + integração**, com a ressalva de que a UI já
foi migrada para cenas, então a integração de arte começa de uma base melhor
do que o plano original previa.

---

## Rodar o simulador

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tools/simular_balanceamento.gd -- 800
```

O último número é a quantidade de partidas por perfil (800 dá margem de ~±3
pontos; 3.000 dá ~±1,8). Um segundo número fixa a semente.

As partidas são determinísticas: **mude uma constante `# TUNING:` em
`autoload/GameState.gd`, rode de novo com a mesma semente e compare.** Trocar
duas constantes ao mesmo tempo não diz qual das duas causou a diferença.

E rode os testes antes e depois de mexer em qualquer coisa:

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tests/run_tests.gd
```

---

*BR Port · Bloco 3 — marco intermediário · Fase 4 (Produção do VS)*
