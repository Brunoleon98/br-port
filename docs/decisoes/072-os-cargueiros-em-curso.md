# 072 — A frota, segunda passagem: os seis cargueiros (em curso)

> **Fechada pela `073`** (28/09): a baleeira foi para o convés de
> embarcações, a bandeira saiu dos nove navios, e os nove estão no jogo.

**27–28/09/2026 · frente 4 do A5, família frota** — depois dos três de pesca
(`071`), o Bruno escolheu **os 6 cargueiros juntos** (médio e longo curso, cada
um em carga geral, contêiner e granel). A passagem ficou em curso: cinco
candidatas, a quinta no gerador e **nenhuma no jogo** — os PNGs de
`art/props/barco_{medio,grande}_*` são os de antes desta decisão.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| Como seguir | **Os 6 juntos** — partilham casco, superestrutura e chaminé |
| 1.ª candidata | **Ajustar**: «partes do navio para fora do casco, em mais de um modelo»; o radar lê como gancho; pontos soltos na proa; a linha de água não se vê |
| 2.ª | **Ajustar**: «mais realista»; ainda há partes fora do casco; a baleeira pequena |
| 3.ª | **Ajustar**: «os botes de salvamento estão presos nas janelas»; o pau da frente estranho; a baia de proa esquisita; **a bandeira para o mastro** |
| 4.ª | **Ajustar**: a baleeira ainda nas janelas; a bandeira colada à chaminé; os paus-de-carga finos |
| 5.ª | **Fechar a conversa**, e duas ordens para a seguinte: **a baleeira vai para um lugar mais realista** (no teto da cabine não é), e **a bandeira do Brasil sai de todos os navios, os de pesca aceites incluídos** |

## O que a quinta candidata tem (no gerador)

`marcas_de_carga()` em `gerar_props_iso.py`, iguais nos seis cascos:

- **Sem pneus** — navio grande encosta nas defensas do cais.
- **Nome** na faixa da proa, rente (`letras_rentes`): a 0,012 de espessura as
  letras liam-se como blocos brancos em pé na borda.
- **Âncora** no escovém, rente e escura, com o rasto de ferrugem por baixo;
  cada peça pede o costado À SUA altura (`no_casco`), porque ele é inclinado.
- **Marcas de calado** brancas junto à roda de proa e à popa.
- **Molinete** numa peça clara, com a amarra até à borda — molinete de dois
  tambores e cabeços soltos liam-se como «pontos soltos».
- **Radar** em cúpula branca num pedestal — o mastro com a caixa ao lado lia-se
  como um gancho.
- **Linha de água antivegetativa** entre 0 e 0,24, afastada do casco por uma
  folga FIXA além da proporcional: a 1,2% da meia-boca, junto à roda a folga ia
  a zero e saíam dentes vermelhos e azuis.
- **Asas do passadiço** até perto da borda, e a **fila de janelas** da
  acomodação.
- **Baleeira** laranja num berço no teto, a ré — **recusada**, ver abaixo.
- **Bandeira** num mastro de sinais à frente do teto — **sai**, ver abaixo.

E o convés de carga deixou de passar da borda:

- a boca das tampas de porão e das baias de contêiner sai de `meia_carga(x)`,
  a meia-boca da amurada no sítio de cada peça — as da proa passavam da borda
  desde 07/09, e ninguém o perguntava;
- o **longo curso contêiner** leva contêineres de 20 pés (`comp=0.54`): as
  quatro baias de 40 passavam da proa, e a de proa numa fila só lia-se como
  uma torre;
- o **longo curso granel** passa a `passo=0.55`;
- os **paus-de-carga** nascem no pé do mastro e sobem a 55° (0,11 de secção),
  o da frente a abrir só 16° — articulados a meio do mastro, o da frente
  acabava fora da proa; virado para trás, lia-se como uma barra solta.

## A baleeira, posição a posição

| Posição | O que se leu |
|---|---|
| encostada à parede, a meio | uma faixa laranja pintada na parede |
| com dois turcos de pé | uma cara: «1 1» sobre um sorriso |
| afastada, a 0,13 da parede | passava da borda do casco |
| maior, a meio da parede | «presa nas janelas» |
| à ré e mais baixa | «presa nas janelas» outra vez |
| no teto, num berço | «não é realista» |

A pergunta que fica para a conversa seguinte é **onde ela vai num cargueiro
destes**. Pendurada na parede, cai sempre sobre janelas; no teto, não é o
sítio dela. As saídas que se veem daqui: uma **superestrutura em dois níveis**,
com a baleeira no convés de embarcações do nível de baixo, ao lado do de cima;
ou a **baleeira de queda livre** numa rampa na popa — com a nota de que o `-x`
é o fundo da imagem, e a popa fica atrás da superestrutura.

## Como se mediu

`tools/conferir_casco.py` (novo) monta o prop e mede, peça a peça, o quanto cada
vértice passa da meia-boca do casco. Nasceu porque o olho não chegou: a amarra
(0,075) e o pau da frente da carga geral (0,022) só a medição os apanhou. Na
quinta candidata os seis dão **«tudo dentro»**. Nos três de pesca aparecem o que
sai de propósito — pneus, motor de popa, portas de arrasto, o pau da traineira —
e a bandeira, que sai na conversa seguinte.

Os três de pesca aceites continuam iguais no gerador: Δ 0 contra os do jogo
(`comparar_props.py`) depois de toda esta passagem.
