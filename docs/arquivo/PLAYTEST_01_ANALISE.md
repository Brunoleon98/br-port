# Playtest 1 — a primeira jogada no telefone (02/09/2026)

**O gate A1 fechou aqui.** O APK foi instalado num telefone e jogado; esta
página é a devolução do Bruno, transcrita do PDF que ele mandou, mais a triagem
que se fez dela.

O documento original é `Análise 1 - 02/09.pdf`. **O PDF não entrou no
repositório** — ele chegou por anexo de conversa, e anexo não vira arquivo no
disco do contêiner. O que segue é o texto integral, extraído.

---

## O que o Bruno escreveu, na íntegra

### 1

> Acho que nessa tela inicial poderia mudar o termo piegas pois não é tão
> usado, além disso é estranho o porto ter dívida mas o jogador começar com
> 400.000.
>
> Por fim, fala que o porto tem madeira podre mas está novinho, logo pode criar
> um Sprite do porto caindo aos pedaços e colocar um upgrade para reformar,
> sendo que sem a reforma o píer pode ter um debuff.
>
> Além disso o guindaste do píer pode ter versões diferentes para poder ter
> upgrades e passar melhor a evolução dele.
>
> O mesmo vale para outras estruturas que podem ter versões mais precárias com
> debuff no início que após reforma e upgrades tiram o debuff e melhoraram os
> bônus delas.
>
> Inclusive alguns navios pode ter necessidades, daí caso o porto não tenha
> algum dos requisitos o navio pode ignorar parar lá.
>
> E em relação aos navios podem ter várias versões deles como no GDD, dando
> foco nos menores no início e depois focando em navios maiores e mais
> lucrativos com o porto aumentando e melhorando suas estruturas.
>
> Lógico que para fazer tudo isso será necessário mudar a economia, daí teria
> que testar cenários com capital inicial menor, e menos lucratividade devido
> ao estado péssimo do porto, fazendo com que precisasse de mais rodadas, por
> exemplo.

### 2

> O porto segue com bugs visuais, tem o escritório em cima da rua e outros
> objetos.
>
> As pedras no Porto poderiam ter uma profundidade ao invés de serem chapadas.
>
> A vegetação é bem pobre, e as casas poderia ser melhor distribuídas, para
> isso pode consultar mapas de cidades portuárias de diversos tamanhos para se
> inspirar e criar o mapa a medida que ele evolui.
>
> Também pode deixar animações mais fluidas, e novas animações, para o
> coqueiro, ondas e até fazer o caminhão andar pela estrada.
>
> Não tinha percebido mas aconteceu um bug que travou o passar do dia, veja
> isso pois parece que a oferta do rival no primeiro dia travou o turno mesmo
> com o navio ocupando o píer.

### 3

> Seria bom melhorar o layout de opções que fica abaixo do mapa, inclusive o
> Sprite do trabalhador pode ser refeito para ficar mais de acordo com o design
> do jogo.
>
> Além disso, o alerta de trabalhador não alocado pode ser mais visível.
>
> Pode haver a opção de pagar a dívida antes do tempo.
>
> Pode ter um espaço do HUD onde ficaram as futuras partes, com mapa da cidade,
> lojas e etc.
>
> Inclusive ao clicar nos itens da parte superior poderiam abrir mais
> informações sobre eles, por exemplo no dinheiro poderia abrir o resumo do
> ganho no dia anterior e o projetado naquele dia, caso algum serviço acabei
> naquele dia.
>
> Nos dias poderia abrir um calendário, inclusive lá pode ficar sinalizado
> alguns eventos.
>
> E em relação a reputação, ela poderia começar mais baixa já que é alguém
> pouco conhecido na região.

---

## A triagem

### ✅ Corrigido na mesma sessão — o bug que trava o jogo

> "a oferta do rival no primeiro dia travou o turno mesmo com o navio ocupando
> o píer"

**Reproduzido, causa encontrada e trancado por teste** (`teste_fumaca.gd`,
bloco F6). O mecanismo, e ele não dava erro nenhum:

1. `GameState._ready()` chama `new_game()` → `_spawn_boats()`, que tem **30%**
   de pôr a fase em `rival_offer` e emitir `rival_offer_triggered`;
2. isso corre no AUTOLOAD, **antes de o `Main` existir** para escutar o sinal;
3. `Main._ready()` via `precisa_dos_nomes()` e fazia `return`, saltando o bloco
   que reabre o painel da fase;
4. fechada a abertura, a fase continuava `rival_offer` sem painel nenhum — e o
   `advance_turn()` retorna CALADO fora de `"playing"`.

**Trinta por cento das instalações novas travavam no dia 1**, e a primeira
jogada num telefone encontrou-o. É a irmã de cena da regra "tela nova é overlay,
nunca fase do `GameState`": as duas produzem um jogo preso sem uma linha de erro.

### ✅ Corrigido na mesma sessão — o escritório em cima da rua

> "tem o escritório em cima da rua e outros objetos fora do lugar"

**Não era um prop mal posto: era um prédio que não cabia no pátio.** Medido:

| | largura em `mx` | ocupava | pátio disponível |
|---|---:|---|---:|
| Escritório | 2,76 | 2,82 → 5,58 | **1,68** |
| Armazém | 3,76 | 6,32 → 10,08 | **1,68** |

O escritório entrava 0,20 no asfalto; o armazém 0,70 — mais de metade da
largura da rua — e ainda passava 0,08 da beira do cais, pendurado sobre a água.

O `teste_design` não pegava por duas razões, e as duas foram fechadas: o bloco
D2 filtrava `Coqueiro*Tronco` e ignorava todo o resto do cenário, e conferia a
**âncora**, que é um ponto. Ponto nenhum pega uma pegada larga demais.

A correção foi alargar o pátio — `RUA_RECUO` de 4,3 para 6,8, o que o leva de
1,68 para 4,18 — recuando a vila junto (`VILA_RECUO` 6,0 → 8,5) para ela não
ficar debaixo do passeio. Os prédios, o caminhão, o cone, o poste e a barreira
foram reancorados, e a ordem dos irmãos reordenada porque `mx+my` mudou.
**Custo medido:** dois lotes da vila saíram do quadro, de 11 para 9.

O D2 agora varre o cenário inteiro, mede a pegada por **interseção de
intervalos** em todo degrau que ela toca, e reprova prop de silhueta grande sem
pegada declarada. Três defeitos injetados, três reprovações.

### 🐛 Bugs a corrigir, ainda abertos

Nenhum dos relatados. O "e outros objetos fora do lugar" foi coberto pela mesma
varredura: o D2 passou a conferir os 22 props de terra do cenário, e não um.

### 🎨 Arte — entra na fila do plano de arte

- Pedras chapadas, sem profundidade
- Vegetação pobre e casas mal distribuídas → **isto encontra a leitura de
  composição das referências**, que já diz para consultar mapas de cidades
  portuárias reais (`docs/design/referencias/README.md`)
- Animações mais fluidas, e novas: coqueiro, ondas, caminhão a andar na estrada
- Sprite do trabalhador refeito → **é a Etapa 5** do plano de arte

### 🖥️ Interface — itens novos, sem gate

- Layout das opções abaixo do mapa
- ~~Alerta de trabalhador não alocado mais visível~~ — **feito em 03/09.** O
  aviso existia só do lado da DOCA (borda âmbar, "sem trabalhador"); o lado que
  resolve dizia "Livre" em cinzento. Agora o cartão do trabalhador tem estado
  próprio (`TrabParado`, fundo âmbar) e a linha acima dele conta: "2
  trabalhadores parados — 2 docas esperando". Os três sinais (rótulo, cartão,
  botão) saem da mesma varredura, `GameState.trabalho_parado()`.
  O tom do cartão foi escolhido por LUMINÂNCIA e não por matiz: os três cartões
  de hoje vivem entre 0,853 e 0,933, e um creme de 0,902 leria como mais um
  irmão. O âmbar do tema como TEXTO ali dava 2,98:1 e reprovava a WCAG — por
  isso o sinal é o fundo.
- ~~Tocar nos itens do HUD abre detalhe (dinheiro → resumo do ganho de ontem e
  o projetado para hoje)~~ — **feito em duas partes.** O dinheiro em 03/09
  (`GameState.dia_atual` / `dia_anterior` são a mesma contabilidade de
  `semana_atual`, só que por dia; "ontem" é histórico e só se lê, "hoje" é uma
  SIMULAÇÃO de `advance_turn()` — `projecao_do_dia()` — que não mexe em nada).
  Os outros três chips (dia, reputação, docas) em 03/09 também, mais abaixo.
- ~~Calendário nos dias, com eventos sinalizados~~ — **feito em 03/09, e junto
  com o item acima**: tocar no dia e o calendário são a mesma pergunta, e
  viraram um painel só. `GameState.calendario()` devolve, por dia, se é hoje,
  se já passou, se fecha semana ou se é o vencimento da parcela — os únicos
  três eventos que o jogo sabe de antemão. A oferta do rival fica de fora de
  propósito: é sorteada por barco, não por dia, e marcá-la seria inventar uma
  certeza que o jogo não tem.
  Tocar na reputação abre a escada de patamares e o que sobe/desce cada um,
  lido direto das constantes (nunca escrito à mão, para não poder divergir).
  Tocar nas docas mostra quantos berços faltam e o que destrava o próximo,
  reaproveitando o mesmo texto que o botão de construir já usa
  (`impedimento_estrutura()`), em vez de escrever uma segunda explicação.
- Espaço no HUD reservado para o que vem depois (mapa da cidade, lojas)

### 💰 Economia e narrativa — NÃO se mexe sem medir

Três itens que tocam a economia medida, e por isso passam obrigatoriamente
pelo `/balancear` (100% / 79,5% / 35,7% é o que está em vigor):

- **A contradição do caixa:** o porto tem dívida mas o jogador começa com
  R$400.000. É coerência de narrativa E de economia ao mesmo tempo.
- **Capital inicial menor + menos lucratividade** pelo estado do porto, com
  mais rodadas para compensar.
- **Reputação a começar mais baixa** — `REPUTATION_START` é 65,0 hoje, e é
  constante `# TUNING:`. O argumento é bom: o jogador é alguém pouco conhecido
  na região.

### 🏗️ Desenho de sistema — maior que uma sessão

- Estruturas em versões precárias com **debuff**, que a reforma tira
- Guindaste com versões por upgrade
- Navios com **requisitos**: sem eles no porto, o navio não para
- Navios em várias versões, dos menores aos maiores, à medida que o porto cresce

Isto é o arco de crescimento que as cinco imagens de referência descrevem, e
casa com o que elas mostram. **É escopo de Fase 2 em diante**, e a pergunta da
economia da Fase 2 continua adiada por decisão (ver `ESTADO_DO_PROJETO.md`).

### ✏️ Escrita

- "termo piegas" na tela inicial — trocar
- "madeira podre mas está novinho": a fala contradiz o que a tela mostra. Ou a
  fala muda, ou o porto ganha o sprite em ruínas que ela descreve.

Os dois vivem em `scripts/Narrativa.gd`, e o segundo espera o gate A4 (ler as
falas em voz alta).
