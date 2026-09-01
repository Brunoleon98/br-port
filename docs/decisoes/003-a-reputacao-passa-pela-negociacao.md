# 003 — A reputação ganha efeito pela NEGOCIAÇÃO

**Data:** 01/09/2026 · **Decisão de:** Bruno · **Estado:** fechada

> Esta é a decisão que o Plano v3 marca como **bloqueante**: enquanto ela não
> fosse tomada, os itens 5 a 15 da fila ficavam parados. Estava anotada como
> pendência em três documentos diferentes desde o Bloco 3 — que costuma ser
> sinal de item que ninguém quer abrir.

---

## O problema

A Reputação Comercial existe, move-se, tem cinco faixas qualitativas e aparece
na HUD. E **não faz absolutamente nada.** É rótulo. O GDD 7 lista-a como
sistema IN do Vertical Slice, então ou ela passa a ter efeito mecânico ou o VS
sai com um sistema que o documento promete e o jogo não entrega.

## A decisão

**A reputação atua na NEGOCIAÇÃO.** Reputação alta faz o cliente do Arlindo
aceitar pagar o preço cheio com mais frequência.

Em termos de código: a reputação passa a modular `RIVAL_KEEP_CHANCE` (e,
provavelmente, `RIVAL_HALF_CHANCE`) em vez de estes serem constantes fixas.

## Por que este caminho, e não os outros dois

Havia três, e são diferentes de verdade:

| Caminho | O que muda | Risco para a economia medida |
|---|---|---|
| Preço | reputação alta → barco vale mais | Direto e forte. Mexe nos 100/47/0 na hora |
| Frequência | reputação alta → chega mais barco | Mexe na VAZÃO — e vazão é exatamente a alavanca que fez a economia da Fase 1 fechar, com 8 turnos/semana. Torcê-la de novo é torcer o que já foi medido |
| **Negociação** | reputação alta → o cliente aceita pagar cheio mais vezes | **O escolhido** |

Duas razões, e a primeira é de design, não de aritmética:

1. **É a única que faz a reputação aparecer no momento em que o jogador está a
   decidir.** As outras duas atuam pelas costas — o barco já vale mais, o barco
   já chegou, e o jogador não vê a reputação a fazer nada. Na contra-oferta há
   um botão, uma aposta e uma consequência; é ali que uma reputação boa se
   sente como recompensa por ter jogado bem.
2. **É a que menos ameaça o que já foi medido.** A contra-oferta é um evento de
   30% dos turnos com barco, sobre um barco de cada vez. Preço e vazão
   multiplicam a receita inteira; esta empurra uma probabilidade dentro de um
   sistema que já é decisão de verdade.

Há uma terceira razão, que é bónus: o botão "Manter preço" já foi reparado uma
vez no Bloco 3 justamente para deixar de ser jogada morta. Ligar a reputação a
ele dá-lhe uma segunda vida — segurar o preço passa a ser a jogada de quem
construiu reputação para isso.

## Como se mede se ficou bom

Não é opinião: é o simulador, 600 partidas por perfil, antes e depois.

- **Os três perfis continuam separados.** Se o Descuidado passar a ganhar, ou o
  Mediano a perder sempre, a alavanca ficou grosseira demais.
- A linha de base a bater é a medida em 01/09/2026, na semente 20260825:
  **100% / 47,3% / 0%**, com a mediana do jogador mediano em **R$7.950** contra
  uma parcela de R$8.000.
- Medir é com `-- 600`. As 30 do CI são fumaça e têm margem de ±18 pontos.

Vale lembrar o que já está registado no `CLAUDE.md`: mexer nas constantes
`# TUNING:` obriga também a regerar `docs/design/BR_Port_Numeros_Fase_1.md`,
senão o CI reprova.

## O que esta decisão NÃO decide

O tamanho do efeito. Quanto é que 100 de reputação vale contra 0 é `# TUNING:`,
sai da medição e não de discussão — e é a parte que a máquina faz sozinha.

---

*BR Port · decisão 003 · destrava os itens 5 a 15 da fila do Plano v3.*
