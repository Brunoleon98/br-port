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

### 🐛 Bugs a corrigir, ainda abertos

| O quê | Onde vive |
|---|---|
| **Escritório em cima da rua** e outros objetos fora do lugar | `gerar_mapa_iso.py` / `Main.tscn` — é posicionamento, e o teste de design não o pega porque confere ordem de profundidade, não sobreposição de prédio com via |

### 🎨 Arte — entra na fila do plano de arte

- Pedras chapadas, sem profundidade
- Vegetação pobre e casas mal distribuídas → **isto encontra a leitura de
  composição das referências**, que já diz para consultar mapas de cidades
  portuárias reais (`docs/design/referencias/README.md`)
- Animações mais fluidas, e novas: coqueiro, ondas, caminhão a andar na estrada
- Sprite do trabalhador refeito → **é a Etapa 5** do plano de arte

### 🖥️ Interface — itens novos, sem gate

- Layout das opções abaixo do mapa
- Alerta de trabalhador não alocado mais visível
- Tocar nos itens do HUD abre detalhe (dinheiro → resumo do ganho de ontem e o
  projetado para hoje)
- Calendário nos dias, com eventos sinalizados
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
