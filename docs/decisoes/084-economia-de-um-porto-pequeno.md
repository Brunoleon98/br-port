# 084 — Economia de um porto pequeno, sobre a fila no fundeadouro

**07–08/10/2026 · retomada da primeira entrega financeira da frente 5**

## O pedido e a base

Bruno autorizou a frente 5 e pediu parcelas menores para um porto iniciante
caindo aos pedaços. A entrega de 02/10 — moeda ×0,1, caixa R$40 mil e primeira
parcela R$30 mil — ficou local: GitHub recusou a publicação com 403.

O briefing retomado pede publicar essa entrega antes da próxima etapa. Entre
as sessões, a main integrou a animação, as telas e a fila no fundeadouro
(PR #106, `083`). A decisão `075` foi usada para o trabalhador e o save 10
para a fila. Publicar a branch antiga sobre a base de setembro traria conflitos
e reutilizaria um número de save com interpretação diferente.

Esta entrega foi reaplicada à **main bab640fdbe9d5565fb0f087a1a013763d9e174ae**:
fila, escolhas, animações e redução de contratos da `083` foram preservadas.
O registro financeiro passa a **084** e o save a **11**. A escolha de manter
R$530 mil feita na `083` é histórica: a retomada atual do Bruno pede R$30 mil.

## A escolha financeira

Toda a moeda **×0,1** primeiro: caixa, receitas de contratos/píer, salários,
manutenção e sete construções. Depois a primeira parcela baixa de R$53 mil
para **R$30 mil**. Cadência, sementes, probabilidades, capacidades, percentuais,
escolha de barco e paciência da fila ficam na regra atual.

| Item | Main atual | Entrega |
|---|---:|---:|
| Caixa inicial | R$400.000 | R$40.000 |
| Primeira parcela, semana 4 | R$530.000 | **R$30.000** |
| Pesqueiro | R$9.000–20.000 | R$900–2.000 |
| Cargueiro | R$16.000–36.000 | R$1.600–3.600 |
| Longo curso | R$40.000–63.000 | R$4.000–6.300 |
| Salário por trabalhador/semana | R$6.000 | R$600 |
| Manutenção por semana | R$40.000 | R$4.000 |
| Renda por vaga de píer/semana | R$5.000 | R$500 |
| Píer 2 / Píer 3 | R$150.000 / R$260.000 | R$15.000 / R$26.000 |
| Armazém / pátio / escritório | R$180.000 / R$115.000 / R$80.000 | R$18.000 / R$11.500 / R$8.000 |
| Guindaste / cais reforçado | R$120.000 / R$150.000 | R$12.000 / R$15.000 |

São preços **adaptados ao jogo**, não tarifas portuárias auditadas nem um
orçamento de engenharia. A reescala mantém os ratios do caixa da `018` e dos
contratos da `083`; a primeira dívida muda sua acessibilidade de propósito.

## Medição na fila atual

Godot **4.6.3**, 600 partidas por perfil, semente **20260825**, no jogo
completo. A main reproduziu a medição da `083`; o intermediário só reescalado
separa o efeito dos sorteios inteiros do efeito de reduzir a parcela.
Os JSONs completos, com o histórico de 02/10 separado, estão em
`docs/design/medicoes/084-economia.json`.

| Cenário | Parcela | Ótimo | Mediano | Descuidado | Antecipado |
|---|---:|---:|---:|---:|---:|
| Main com fila | R$530.000 | 100,0% | 78,7% | 41,5% | 78,7% |
| Só escala ×0,1 | R$53.000 | 100,0% | 80,3% | 45,7% | 80,3% |
| **Entrega** | **R$30.000** | **100,0%** | **100,0%** | **100,0%** | **100,0%** |

A escala preserva ratios, mas muda os sorteios inteiros e arredondamentos;
não promete os mesmos resultados bit a bit. A parcela menor é o segundo
passo e torna a primeira cobrança acessível.

A mediana do Mediano no vencimento, antes de pagar, passou de **R$629.683**
para **R$63.873**. Com R$30 mil, os quatro perfis pagaram em todas as 600
partidas. Essa cobrança passa a permitir aprender e reconstruir; a diferença
continua no porto construído e na margem em regime:

| Perfil final | Mediana no vencimento | Margem em regime/semana |
|---|---:|---:|
| Ótimo | R$108.077 | R$54.828 |
| Mediano | R$63.873 | R$45.405 |
| Descuidado | R$52.359 | R$9.593 |

A margem do Ótimo continua cerca de **5,7×** a do Descuidado. A mediana no
vencimento do Antecipado é zero porque ele paga antes em todas as partidas,
não porque acabou sem caixa. Caixa inicial maior que a parcela permite quitar
logo e sacrificar capital de reconstrução; o desconto e esse compromisso já
eram regras existentes, e o perfil Antecipado mede esse caminho.

## O que não passou a existir nesta entrega

O VS ainda termina na primeira parcela, ao fim de quatro semanas. As três
cobranças dentro da Fase 1, desbloqueios, obras, empréstimo, cancelamento,
guindastes por fase, tutorial e mais trabalhadores por píer continuam no
item 5 da §7 do plano v3.

R$30/45/60 mil foi uma extensão **exploratória da base de setembro**, sem fila,
novos desbloqueios, save ou interface. Seus resultados de 02/10 ficam como
histórico no JSON; R$45/60 mil não são valores implementados nem validados
para a fila atual. A tentativa R$20/30/40 mil não produziu resultado completo
no teto de 180 s e não é evidência.

## Compatibilidade e ferramentas

- **Save 11** recusa a versão 10 da fila antes de aplicar estado: caixa,
  barcos ao largo/atracados, contabilidade e recordes usam a moeda antiga.
  A versão 10 local de 02/10 também é incompatível. Sem migração.
- **GDD congelado** convertido por `ESCALA_MONETARIA_GDD = 0.1`; a Fase 1 e
  parcela vêm do código, e o `premio_da_escolha` da fila continua no projetor.
  Fases 2/3 do GDD e três cobranças dentro da Fase 1 são perguntas diferentes.
- O projetor descreve os multiplicadores por passagem; um multiplicador de
  dívida maior não prova pressão quando ainda sobra dinheiro.
- As montagens F10/F11 e os tiros de recusa dão caixa insuficiente de forma
  explícita: a semente antiga pode pagar depois do ajuste. A régua F14 limita
  a barra a 0–100%, inclusive com caixa negativo. Nenhuma regra de pagamento
  foi modificada para satisfazer os testes.

## Validação da entrega atual

Godot **4.6.3**, após importar o projeto da main atualizada:

- Seis suítes: `TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`,
  `FUMACA OK`, `REGISTRO OK`, `ASSET OK`; nenhuma com `SCRIPT ERROR` ou
  chamada a `push_error`.
- `CONSTANTES OK` e `TABELA OK`: 51 constantes conferidas contra Godot.
- Projetor calibrado: Ótimo 0,0% e Mediano 2,1% de erro. O Descuidado tem
  6,5%, mas passa pela tolerância absoluta já existente: desvio de R$622,
  inferior a meio barco (R$1.012). Não passou pelo limite relativo de 5%.
- `DOCS OK`, `GUARDAS OK`; JSONs consolidados idênticos às saídas brutas.
- Código do `GameState` comparado à main sem comentários: fora os preços,
  a primeira parcela, a escala do GDD e a versão do save, é idêntico.

A evidência foi refeita na base atual; o verde de 02/10 não é usado como
validação desta versão. Capturas e suítes foram executadas em sequência,
com a sentinela do jogador no mesmo `user://` das ferramentas.

**58 capturas, `COBERTURA OK`**, cada PNG com seu log e sem erro de script.
Foram olhadas as telas de início, boletim, diário, construção, parcela,
cobrança paga/recusada e recibo de fim de fase: preços e textos cabem.
**`SENTINELA INTACTA`** no fim: cinco arquivos do jogador, byte a byte.

O fecho local é de **08/10**. CLI/API e conector GitHub recusaram criar a
branch com **403 — Resource not accessible by integration**. Leitura funciona;
escrita e PR continuam pendentes. O patch e as evidências desta base substituem
os artefatos de 02/10; nenhuma mudança foi publicada na main.
