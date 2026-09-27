# 070 — As duas transportadoras no jogo: os 32 camiões e a vez de cada uma

**27/09/2026 · frente 4 do A5, família escala e camiões** — a passagem que a
`069` deixou escrita em «O que fica para a passagem seguinte». O desenho foi
aceite pelo Bruno na quarta candidata; o que se decidiu aqui é como ele entra
no jogo, e é decisão de código (F1/F6), não de arte.

## O que entrou

- **Os 32 PNGs** — 4 serviços × 2 empresas × 4 silhuetas (`my`, `mx` e as duas
  do retorno) —, gerados de uma vez pelo `gerar_brp.py porto` (20 min neste
  contêiner, a montagem do estúdio incluída). O
  `_registrar_caminhoes()` percorre `MARCA_DA_EMPRESA` (`""` e `"_b"`): a
  empresa 0 guarda os dezasseis nomes de sempre, a 1 escreve-se
  `caminhao_<serviço>_b<silhueta>`. A empresa 0 MUDOU — os detalhes da `069`
  valem para as duas —, e por isso não havia controle de Δ zero a repetir.
- **Os 16 `.import` novos em `texture_atlas`**, e os atlas em
  `art/props/_atlas/`. O validador passou a contar 97 assets e 90 em atlas.
- **`CAMINHOES` do `Main.gd` por empresa**: `motivo → [empresa 0, empresa 1]`,
  cada uma com as quatro silhuetas. `silhueta_do_trecho()` recebe a empresa
  **sem valor por omissão** (a `047`: o argumento com omissão é o que ninguém
  passa). A empresa escolhe-se com a carga, à entrada do mapa, e não muda até
  à volta seguinte (`_empresa_na_estrada`, `_empresa_do_retorno`).

## A chave: a vez de cada transportadora, por serviço

`_empresa_da_vez(motivo)` guarda um contador por serviço e devolve-o módulo o
número de empresas: a primeira viagem de pescado é da 0, a segunda da 1, e
assim por diante. **Sem sorteio**, pela razão da carga e dos rostos (`059`): o
`_rng` do `GameState` é o que o simulador mede. O balanceamento fica intocado
por construção — o `Main.gd` não é carregado pelo simulador, e a chave não lê
nem avança gerador nenhum.

**Por serviço, e não por camião**, e é medido. A roda do retorno escolhe a
carga por `(j + voltas) % motivos`; uma vez por camião que seguisse a mesma
conta — `(j + voltas) % 2` — casaria com ela no porto em ruínas, que tem dois
motivos: o pescado do retorno saiu sempre da empresa 0 (M2, abaixo).
`voltas % 2` sozinho passou (M2b), com os dois camiões em contrafase — uma
propriedade de haver dois, e não da chave. O contador por serviço alcança as
duas empresas em qualquer porto por construção.

## As guardas

- **D13 §4 e §f por empresa**: cada trecho pede a silhueta da empresa pedida,
  da linha dela na tabela, e o §f confere o NOME pelo padrão do gerador (a
  segunda fonte). «As 16 silhuetas entram em campo» nos dois sentidos, e «os
  32 camiões têm desenhos distintos».
- **A ré, nos dois sentidos**, lê a empresa do camião que encostou.
- **D35, o chassi por empresa** (`D35_CHASSI[motivo][empresa]`, com o capô de
  0,40 nos três médios da 1), na pegada do trânsito e na curva aberta do D13.
- **D35, as 32 chegam à rua** (a guarda nova): a textura de cada nó, a cada
  passo, tem de cobrir as 32. Para isso a agenda de visitas passou a trazer
  **todos os motivos do jogo** — com os do porto em ruínas a carreta e o
  basculante nunca passavam, e a guarda não era sequer satisfazível — e o
  andar ganhou **meia hora de passagem** antes das visitas (docas vazias, a
  roda sozinha), onde se pergunta que cada serviço levou as duas empresas nos
  dois sentidos. O D35 passou de 3.600 a 5.400 s de jogo, e o teste de design
  de ~9,6 s a ~12,7 s (emparelhado, duas voltas de cada).

## Os defeitos injetados

Base verde entre cada um; originais por `cp`.

| mutante | o que reprovou |
|---|---|
| M1 a vez devolve sempre 0 | **só** as duas guardas novas: 16 silhuetas nunca vistas, e a passagem |
| M2 a vez do retorno a `(j + voltas) % 2` | **só** a passagem (`retorno\|pescado` só com a 0) — as visitas desfazem o par, e a guarda das 32 passa |
| M2b a vez do retorno a `voltas % 2` | nada — e é verdade: os dois camiões cobrem as duas empresas em contrafase |
| M3 os trechos esquecem a empresa | a ré (encostado e retomada) e as duas guardas novas |
| M4 a linha da empresa 1 do granel copia a da 0 | o §4 e o §f (14 de 16 silhuetas vistas em cada), os desenhos distintos e o nome pedido no §f |
| M5 a vez partida só no granel | a guarda das 32, que nomeia as quatro do granel B. Com a agenda antiga ela reprovava por outra razão: a carreta e o basculante nunca chegavam à rua |
| M6 um bicudo de capô 0,80 | a curva aberta do D13, com a armazenagem da empresa 1. Sem o laço por empresa, **verde** — é o laço que o mede |

## O custo, medido

- **`.pck` +109.336 B** (13.392.768 → 13.502.104): **+0,82% do `.pck`, ~+0,27%
  do APK** (40,47 MB no artefato da `main` em `af10a59`). O delta do `.pck` é o
  do APK (`029`). Os atlas novos pesam 89,5 KB em disco.
- O `BERCO_RECUO` continua certo: quem mais avança à frente da âncora em `mx`
  é o porta-contêiner, 28,7 px nas duas empresas; o bicudo avança menos (20 a
  23,3 px), porque o capô é baixo.

## As folhas

A dos camiões tem **uma página por transportadora** (`camioes 1 2` e `camioes
2 2`; o `capturar_evidencia.sh` tira `camioes` e `camioes_b`), e reprova se as
páginas pedidas não forem as empresas da tabela. O catálogo dos props põe as
duas empresas no mesmo nó.

## O que fica de fora

- Pôr carros e pessoas no mapa é da família da animação (`069`).
- A empresa não tem nome nem logótipo; o que a distingue é a cor da cabine, a
  faixa e o modelo, como o Bruno escolheu.
