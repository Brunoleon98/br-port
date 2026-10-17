# 123 — A vila humilde: seis casas, terreno com muro, igreja e praça da matriz

**17/10/2026 · item 2 da fila que o Bruno deu na `121`** — «melhorar as
estruturas da cidade». **Aceite na foto do jogo à quinta passagem**, com cada
volta pedida por ele no veredito. A vila continua ASSADA no SVG de
`tools/gerar_mapa_iso.py` (`022`): nenhuma linha de jogo mudou.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O escopo | **A vila inteira**, a recomendada: casas e os três lotes especiais numa passagem |
| O telhado | **Quatro águas**, a recomendada, contra «duas águas com empena» e «manter a tampa» |
| A sombra | **Projetada no chão**, a recomendada, na direção da das árvores |
| As fachadas | **Mais tons pastel**, a recomendada |
| A igreja | **Torre no eixo da fachada**, a recomendada |
| A praça | **Canteiros verdes e coreto**, a recomendada |
| As obras | **Tijolo à mostra**, a recomendada |

## As cinco passagens

1. **Telhado, sombra, cor, igreja, praça, obra.** Veredito «Ajustar»: tijolo
   que parecia telha, coreto pequeno, torre fina; no «Outro», *«veja quais
   detalhes pode melhorar… mais variações de casa… se necessário mova elas de
   lugar no mapa para dar mais espaço para terrenos e formas variadas,
   seguindo o padrão brasileiro»*.
2. **Seis formas e o terreno.** Quatro águas, empena, platibanda (casario
   geminado), alpendre, casa em L e sobrado; vão maior entre vizinhos, muro
   baixo e caixa-d'água. «Ajustar» em tudo o que a lista dizia (praça
   apertada, muro invisível, vila rala, sacada que parecia porta comprida) e,
   no «Outro», *«por enquanto faça casas mais humildes; em fases mais para
   frente casas melhores podem aparecer»*.
3. **A vila humilde.** O nível 1 passa a ser a meia-água de fibrocimento, a
   casinha de empena, a térrea de quatro águas, a de varanda e a em L, com
   reboco cru em parte das paredes; o casario e o sobrado passam a ser a
   MELHORIA do mesmo lote no nível 2 (`MELHORIA`, `forma_no_nivel`). «Ajustar»
   em tudo, e *«melhore alguns detalhes para deixar as casas mais ricas em
   detalhes, assim torna a cidade um pouco mais viva»*.
4. **O detalhe.** A cor de acento de cada casa (folhas da janela, porta e
   portão), o barrado, as fiadas na telha de barro, a moita florida, o caminho
   do portão à porta, a igreja recuada com adro, o fibrocimento só na
   meia-água. «Ajustar» em tudo, e *«melhore os detalhes das caixas da água, e
   tente encaixar melhor nas casas, faça esse mesmo ajuste de encaixe em
   outros detalhes»*.
5. **O encaixe.** A caixa-d'água assenta num murete cujos cantos seguem a
   água do telhado naquele ponto (`z_quatro_aguas`, `z_duas_aguas`,
   `z_meia_agua`), com frisos e tampa; bancos e postes na praça e no adro;
   moitas no quintal do lado, por trás do muro; acentos 20% menos saturados.
   **«Aceito».**

## O que ficou, e porquê

- **A forma de cada casa sai de um SACO embaralhado por fileira**, e o saco
  só serve os lotes que se veem. Sorteada casa a casa por peso, a casa em L —
  a mais larga, a que o fim do degrau e os vãos do pátio mais recusam —
  ficou de fora da tela duas vezes seguidas.
- **A parede, a caixa-d'água, o fibrocimento, o acento e o jardim saem de
  `Random` próprios**, pela ordem dos lotes: o `Random` da implantação
  (`_fileira`) e o das árvores (`vila`) não ganham sorteios a mais por causa
  de uma cor.
- **Lote colado à vizinha não é especial**, a igreja vai para o lote largo
  mais perto do meio da frente, e a **praça vai para uma esquina** (vão de
  0,7 do lado +my) bem dentro do quadro, a mais perto da igreja — a praça da
  matriz. Alarga para o vão da esquina (`planta_da_praca`).
- **O D24 mudou de alvo onde o desenho mudou**: a prova da igreja é a água
  +my da pirâmide (`telha_torre`, a única peça com essa cor) e a da praça a
  água pura do telhado de oito águas do coreto. A geometria de cada peça vive
  numa função só (`geometria_da_igreja`, `geometria_do_coreto`,
  `geometria_da_obra`), que o desenho, a prova e a guarda da torre leem.
- **Os níveis 2 e 3 geram, e não foram fotografados.** O jogo só mostra o
  nível 1; o 2 (casario e sobrado) e o 3 (prédios de quatro águas) ficam por
  olhar no dia em que uma fase os pedir.

## As provas

Dois defeitos novos no catálogo (`tools/mutantes.toml`), ambos no MAPA
GERADO, porque o executor troca texto e não regera nada: a pirâmide pintada
na telha das vizinhas e o coreto sem telhado. ⚠️ **O primeiro SOBREVIVEU à
estreia**: o `teste_design` lê a textura pelo cache do importador (de
propósito — o `_mapa_lido` explica), e o defeito trocado só no SVG nunca lá
chegava. O executor passou a reimportar quando o alvo tem `.import` ao lado,
e a desfazer a reimportação no fim (`testes-e-guardas.md`).

## O cão caramelo, que a vila nova pôs em cima de uma casa

A bateria do fecho deu a folha `props1` diferente da de antes: o chão debaixo
do cão caramelo passara de relvado (`#7b8f52`) a `#9faca1` — o muro e a
frente de uma casa da fileira de trás, que a implantação nova pôs onde o
cão passeava. Nenhuma guarda o viu: o D27 pedia só «verde dominante» no
pixel do cão, e o muro de uma casa verde-água passa nisso. O cão foi para
um relvado aberto a poucos metros (`Main.tscn`, (105, 190) → (78, 196)), e o
D27 passou a pedir o verde do RELVADO — `g − r` entre 8 e 35 e `g − b` de
pelo menos 35, a meio da banda entre o relvado medido (20 e 61) e o muro
(13 e 11), e acima da copa (81) — com o defeito no catálogo
(`fauna-cao-em-cima-da-casa`).

## Custo e estado

Os quatro mapas regerados, iguais ao byte numa regeração limpa (a espuma não
mudou); a tabela de âncoras publica a forma de cada lote (`casa`) e as provas
novas. Seis suítes verdes neste contêiner, a bateria inteira e o catálogo de
mutantes.
