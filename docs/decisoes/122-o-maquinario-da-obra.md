# 122 — O maquinário da obra: rolo, bate-estaca e munck

**16/10/2026 · item 1 da fila que o Bruno deu na `121`** — «melhorar o design
do maquinário de obra (o rolo compactador do pátio)». **Em produção: aceite
na foto do jogo, com uma correção pedida e feita** (a linha amarela, abaixo).

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O escopo | **As três obras**, contra «só o canteiro do pátio» (a recomendada) e «pátio com uma segunda máquina»: a `121` tinha escolhido andaime e material, sem máquina, no píer e no armazém, e agora cada obra tem a sua |
| O rolo | **Tambor à mostra**, a recomendada: o círculo do tambor de perfil, em aço escuro |
| A brita | **Refazer com grão**, a recomendada |
| A máquina do píer | **Balsa na ponta**, a recomendada: guindaste de esteiras sobre balsa, do lado do mar |
| A máquina do armazém | **Caminhão munck**, a recomendada, do lado do cais |
| O veredito | «Ajustar»: só a linha amarela solta numa cena da balsa — «corrija isso e na próxima sessão pode seguir para melhorar construções» |

Sem pessoas, como na `121`: a obra é contratada e não tira trabalhadores.

## O que cada obra mostra, dia a dia

| Obra | Dia 1 | Dia 2 | Dia 3 |
|---|---|---|---|
| **Píer 2** | a torre do bate-estaca de pé sobre o par de estacas da ponta, que ainda sobe acima das outras, sem travessa nem longarina; duas estacas novas deitadas na balsa | o par cortado e travado, a torre deitada na balsa e a lança a trazer um fardo de ripas, suspenso sobre a água | — |
| **Armazém** | o munck com a carroceria cheia de zinco a descer um fardo para o deck | a lança subida por cima do terço do telhado que falta, o fardo acima da cumeeira | — |
| **Pátio** | o rolo novo junto do avental e dois montes de brita | o rolo na frente do asfalto e um monte | o rolo do lado da rua |

## O que a foto pediu

- **O rolo lia como empilhadeira.** A chapa amarela do garfo, na face `+x`
  (a que a câmera vê de lado), tapava o círculo do tambor, e o capô fundia-se
  com o chassi. O garfo passou a braço estreito, o tambor ficou escuro com o
  aro claro, o capô ganhou grade e escape, e o teto da cabine encolheu.
- **A brita lia como pedra facetada, depois como chapéu, depois como disco.**
  Nove lados davam facetas; uma coroa redonda num cone largo desenhava a aba;
  e na rampa real (~35°) a câmera a 60° achatava-a numa tampa clara. Ficou um
  cone liso de 24 lados mais íngreme do que o real, com um segundo encostado:
  a encosta com sombra é o que diz volume.
- **O bate-estaca lia como escavadeira.** Com a lança de 2,1 a torre mal
  subia acima do tabuado; com 3,0 a torre vertical é a silhueta, como o mastro
  do n1. A lança tem o mesmo comprimento nos dois dias e a altura da ponta
  sai dele.
- **O fardo do dia 2 sumia contra o tabuado**, madeira sobre madeira; foi
  para cima da água, com cintas da cor da corda.
- **O munck nascia debaixo do coqueiro.** Com o guindaste atrás da cabine, a
  lança curta do dia 1 ficava na ponta da frente da imagem, tapada pela copa
  e pelo pórtico do barco da doca 2; na traseira ela cruza o avental claro.
- **A linha amarela** era o braço de 0,045 do guindaste ao pé da torre, solto
  sobre a água. Saiu: a torre pende da ponta da lança.

## Escalas

O rolo e a brita pela régua da pessoa (`069`), como antes. O munck pela
régua do CAMIÃO: as medidas do `_pecas_do_caminhao()` antes do
`ESCALA_CAMINHAO`, num grupo que encolhe com o prédio pela `ESCALA_PREDIO` —
o mesmo 0,72. Pela régua da pessoa ele sairia 1,6 vezes a largura dos camiões
da rua, e o olho compara camião com camião. A balsa pela escala do píer.

## Como se fotografou

A `prancha_prop.gd` não alcança nenhum dos sete quadros: joga 16 turnos à
espera do prop, e o pátio só abre depois da primeira cobrança. A ferramenta
nova `brport_vs/tools/capturar_obra.gd` monta a obra no quadro pedido, com os
vizinhos de uma partida semeada, e troca a textura de um nó por uma candidata
lida do arquivo.

## Custo e estado

Sete PNG regerados, nenhum novo; nenhuma linha de jogo mudou, logo o D45 e os
sete mutantes `obra-*` continuam a valer como estavam. Seis suítes verdes
neste contêiner, a bateria inteira com `COBERTURA OK` e a página de escala
sem transbordar; a ferramenta nova reproduz ao pixel a foto do rascunho que
serviu ao veredito.
