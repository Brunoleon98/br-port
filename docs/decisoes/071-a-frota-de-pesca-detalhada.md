# 071 — A frota, primeira passagem: os três barcos de pesca detalhados

**27/09/2026 · frente 4 do A5, família frota** — escolhida pelo Bruno depois
dos camiões (`070`). Ele respondeu ao escopo antes do desenho, e a leitura foi
aceite na quinta candidata.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O que a família faz com os 9 cascos | **Detalhe nos 9**, sem armadores e sem barcos de trabalho novos |
| Por onde começar | **Os 3 de pesca**: o porto em ruínas só recebe pesqueiro |
| Que marcas | **As quatro**: defensas e amarração, nome e bandeira, equipamento da função, desgaste |
| 1.ª candidata | **Ajustar**: bloco laranja perdido na traineira, rede do arrasteiro (e mudá-la de lugar), pneus como mancha, escorrido forte no amarelo, nome como barra, bote pequeno demais |
| 2.ª | **Ajustar**: «mais realista», a posição das bandeiras, pneus a mais no arrasteiro, saco como mancha, a rede da traineira volta a cinzento |
| 3.ª | **Ajustar**: o saco ainda lê mal, o tambor verde forte, a balsa como balão, sem pneus no bote |
| 4.ª | **Ajustar**: o saco lê como pedra, a balsa grande no teto, a bandeira do bote grande |
| 5.ª | **Aceito** |

## O que ficou, e porquê cada peça tem a forma que tem

Tudo sai de `marcas_de_pesca()` em `gerar_props_iso.py`, com o porte `k` do
`escalar_par`: a GRAMÁTICA é partilhada e as posições são de cada barco.

- **Pneus de defensa como ANEL** (`anel()`, um toro): o disco escuro lia-se
  como mancha; o furo mostra a faixa por trás, e é o furo que diz «pneu».
  Três na traineira e três no arrasteiro; **nenhum no bote**, onde a 44 px eram
  pontos soltos.
- **Nome** — letras espaçadas na proa, que seguem a curva do costado
  (`no_costado()`). A 0,06 de passo liam-se como uma barra; a 0,10–0,20, como
  marcas. **O bote não tem**, pela mesma razão dos pneus.
- **Bandeira** num pau próprio na POPA, no quarto que se vê: é onde o pavilhão
  vai num barco. A do teto da cabine e a do topo do pórtico foram recusadas.
  O bote leva-a a 0,74 em vez do seu 0,62 (3 px não se liam; 0,90 era grande).
- **Amarração**: rolo de cabo e cabeços na proa. O cabo ATÉ ao píer não entra
  no prop — o barco chega a deslizar e balança, e um cabo preso ao casco
  chegaria esticado a apontar para o ar. É da família da animação.
- **Desgaste** no MATERIAL da faixa (`material_escorrido` com a cor dela
  levada ao escuro), e não ferrugem, que continua a ser marca da classe de
  carga. As caixas de 0,026 da primeira candidata tinham 1 px e não se viam;
  no amarelo a regra da cor ao escuro dava o sujo mais forte da frota, e o
  escorrido dele é mais claro (`escorrido_amarelo`).
- **Traineira**: o bloco laranja da proa saiu (a `boia_p`, lida como erro); a
  cabine ganhou fita de vidro e teto (era um bloco sem janela), a salva-vidas e
  uma balsa pequena com cintas escuras (com cintas laranja lia-se como balão);
  a rede é cinzenta, agora em malha, com as cortiças amarelas na borda.
- **Arrasteiro**: portas de arrasto no pórtico; a rede ENROLADA no tambor em
  nylon verde escuro e pouco saturado (o verde vivo competia com o pórtico); o
  SACO cheio pendurado do cadernal, comprido, em malha de losangos sobre o
  prateado do peixe; a balsa com berço no teto da casa do leme.

## O saco, forma a forma

| Forma | O que se leu |
|---|---|
| cone de `corda` no arco (o de hoje) | funil |
| três lobos verdes no convés de popa | tapado pelo tambor e pelo pórtico: o `-x` é o fundo da imagem |
| sacola com gomos à frente do tambor | «saco verde como mancha», um arbusto |
| pera com cintas horizontais no arco | um pinheiro enfeitado |
| gargalo e bola prateados, malha de Voronoi | «lê como pedra» |
| **gargalo e corpo comprido, malha de losangos** | **aceite** |

Duas lições saem daqui. **A malha irregular num volume redondo é a textura de
um calhau**; a rede ESTICADA pelo peso é regular (`material_malha_losango`).
E **a coordenada `Object` de um material lê a malha ANTES do `scale`**: a esfera
de raio 1 esticada a 0,16 pintava losangos seis vezes mais finos do que o
pedido, e o saco saiu granulado sem um erro. O `bola()` aplica a escala na
malha; o `CLAUDE.md` (Arte) leva a regra.

## Medido

- **Controle**: os três de hoje renderizados pelo gerador antes de mexer deram
  Δ zero contra os do jogo (`comparar_props.py`); e a versão final, depois de
  limpar o código morto, deu Δ zero contra a candidata aceite.
- **D29**: a linha de fundo mede o mesmo antes e depois — 50% na traineira e
  53% no arrasteiro, teto 62%. Nenhuma peça nova desce abaixo do casco.
- **As seis suítes** verdes; a bateria de capturas sem erro, e a folha `frota`
  mostra os três novos com os cargueiros iguais.
- **`.pck` +3.632 bytes (+0,027%)**, pelos três atlas (+3,5 KB).

## O que fica para a passagem seguinte

Os **três médios** e os **três grandes**, com a mesma gramática onde ela
servir — e é escolha do Bruno se começam juntos.
