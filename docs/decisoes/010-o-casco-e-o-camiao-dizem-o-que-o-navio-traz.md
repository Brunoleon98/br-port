# 010 — O casco e o camião dizem o que o navio traz

**07/09/2026.** Os dois itens de arte que sobraram do pedido de 05/09 e que a
decisão `009` deixou prontos para desenhar. As palavras do Bruno ao abrir a
sessão:

> *"Hoje há três cascos, um por classe, e os dois cargueiros carregam as mesmas
> caixinhas coloridas. Quero que o casco diga o que o navio traz"* e *"hoje é UM
> caminhão em laço, com duas silhuetas só porque a rua vira. Quero carreta
> porta-contêiner, basculante de granel, baú de armazenagem e caminhão de peixe
> — e mais de um na estrada ao mesmo tempo."*

Nada aqui encosta na economia: nenhuma constante `# TUNING:` foi tocada e o
balanceamento medido continua **100% / 80,2% / 37,3%**, com a parcela em
R$530.000. A `/balancear` não correu, e de propósito.

---

## A decisão, em três partes

### 1. O casco sai do par (CLASSE, MOTIVO) — a classe dá o porte, o motivo dá o convés

Desde `008` o jogo sabe por que cada navio veio; desde `009` sabe qual o porto
consegue receber. O desenho não dizia nem uma coisa nem outra: os dois
cargueiros levavam as mesmas quatro caixinhas coloridas. É o buraco do
`barco_medio` com o sinal trocado — ali o prop existia e não chegava à tela,
aqui a MECÂNICA existia e não chegava ao desenho.

| | Armazenagem | Contêiner | Granel |
|---|---|---|---|
| **Cargueiro** | paletes + paus-de-carga | pilha alinhada, 3 baias × 2 andares | 4 porões + 1 guindaste |
| **Navio de longo curso** | paletes + paus-de-carga | pilha alinhada, 4 baias × 3 andares | 5 porões + 2 guindastes |
| **Pesqueiro** | o mesmo casco de sempre | — | — |

**O casco NÃO se refaz por serviço: refaz-se o CONVÉS.** Um porta-contêineres e
um graneleiro do mesmo porte têm o mesmo costado, e o que os separa é o que
está em cima. Seis cascos independentes seriam seis geometrias a divergir — a
razão de o `_pecas_do_caminhao` existir, aplicada aos navios.

**E cada serviço tem GRAMÁTICA própria, não cor própria.** Repintar as mesmas
caixas de três cores daria três navios com o mesmo desenho e três etiquetas; é
a regra que o armazém em ruína pagou em 05/09. São três vocabulários
diferentes: a GRADE alinhada com guias de célula, a TAMPA de porão sobre
braçola, o PALETE solto com pau-de-carga aberto sobre o costado. A 97px o que
se lê é a gramática, não o tom.

### 2. O pesqueiro tem um casco só, e isso é afirmação

Ele chega com `pescado` ou com `armazenagem` — o mesmo peixe indo para o
mercado ou para a câmara do armazém. **O destino da carga muda; o barco não.**

A tabela escreve a mesma textura duas vezes em vez de ter uma exceção em
código, porque é isso que a deixa percorrível. E o D17 passou a exigir
**partilha total ou nenhuma**: uma classe declara um casco por motivo, ou um só
para todos. Dois motivos a partilhar um desenho enquanto outros não é
copiar-colar, e numa tabela as duas coisas leem-se igual — exigir 1 ou N é o
que as separa.

### 3. O camião que passa é a carga da DOCA DO MESMO ÍNDICE

Três docas, três camiões, um para um. A carga que sai do berço sai também pela
rua, e quem olha para uma coisa vê a outra.

**Sem sorteio nenhum, e é decisão e não preguiça.** O `RandomNumberGenerator` do
jogo é o mesmo que o simulador usa; um enfeite a gastar sorteios mexeria na
sequência que as 600 partidas por perfil medem — a armadilha que o `Registro`
já tinha registado ao nascer desarmado. Doca vazia ou por construir cai no que
o PORTO consegue receber, pelos motivos das classes já destravadas: o porto em
ruínas manda peixe e carga geral pela estrada, o porto de nível 3 manda
contêiner. **A estrada conta a mesma história que o cais.**

E os três repartem o ciclo por conta própria — a espera de arranque é
DERIVADA do comprimento da rota e da velocidade, não escrita à mão. A estrada
visível é um terço da rota, então três camiões todos à vista ao mesmo tempo
estão por construção amontoados: sem a repartição ver-se-iam os três de
enfiada e depois quarenta e sete segundos de rua vazia.

---

## O que NÃO se fez, e por quê

**Nenhum casco novo por CLASSE.** O cargueiro e o navio de longo curso
continuam com o mesmo costado de 97px e separam-se pela superestrutura, pela
fileira de vigias e por quanto levam em cima. Alargar o casco do maior é
mexer na pegada dele contra o píer, e isso é outra sessão.

**Nenhum camião de reparo nem de combustível.** Seriam os motivos que `008`
deixou de fora por serem Fase 2. Quatro motivos, quatro camiões: a tabela é a
mesma, e o dia em que a oficina existir o camião dela entra sozinho.

**Nenhuma mudança de rota.** A escada da rua é a mesma de 05/09; o que mudou foi
quantos a percorrem e o que levam.

---

## O que passou a ser verificável

- **D17** percorre `CLASSES_DE_NAVIO[classe]["motivos"]` e exige casco para cada
  par, partilha total ou nenhuma dentro da classe, nenhum casco atravessando
  duas classes, e desenhos distintos entre arquivos distintos.
- **D13** percorre `GameState.MOTIVOS` e exige camião para cada motivo, a
  silhueta certa do EIXO e da CARGA em cada trecho, os três nós na cena, cada um
  num trecho reto e inteiro dentro do quadro, e oito desenhos distintos.
- **`folha_frota.gd`** desenha a frota inteira numa folha de contato, que entrou
  nas capturas do CI. Ela existe por uma falha medida: as cinco fotos de jogo
  mostraram DOIS dos seis cascos, porque quem escolhe o que atraca é o sorteio
  da partida.

As nove asserções novas foram provadas com defeito injetado, uma a uma, com a
base conferida limpa entre cada.
