---
name: balancear
description: Mede e ajusta a economia do BR Port com o simulador, e arrasta atrás o que a medição envelhece — a tabela dos números, o projetor das Parcelas, o CLAUDE.md e a decisão registrada. Acione com "balancear", "medir o balanceamento", "mexer nos preços", "mudar o valor do contrato/da parcela/do salário", "a economia está fácil/difícil demais", "reescalar os valores", ou antes de tocar em QUALQUER constante `# TUNING:` do GameState.gd. NÃO é para rodar o simulador só para ver — para isso rode a ferramenta direto.
---

# Balancear — BR Port

Mexer num número da economia é barato. O que é caro é o rasto: seis documentos
afirmam o balanceamento, o CI reprova quem os deixa envelhecer, e a taxa de
vitória é o número mais fácil de ler errado do projeto inteiro.

> **As FASES desta skill** (`docs/decisoes/016`; a tabela geral está no
> `CLAUDE.md`). Numa sessão de economia fica **mais em Opus** do que numa de
> arte, porque a taxa de vitória é o número mais fácil de ler errado do projeto
> — esta skill existe por causa disso.
>
> | # | Aqui é | Modelo |
> |---|---|---|
> | **F1** | escolher o item e DESENHAR a varredura: que `# TUNING:`, que intervalo, que semente, o que se segura fixo | **Opus** |
> | **F2** | rodar `simular_balanceamento.gd -- 600`, o ANTES | **Sonnet** |
> | **F3** | ler os perfis e a margem em regime, e dizer o que mudou de facto | **Opus** |
> | **F4** | escolher o valor novo | **Opus** |
> | **F5** | aplicar e remedir com a MESMA semente | **Sonnet** |
> | **F6** | asserção nova + defeito injetado, se apareceu | **Opus** |
> | **F7** | tabela dos números, projetor das Parcelas, os seis documentos, commit | **Sonnet** |
>
> ⚠️ **Medir é com `-- 600`.** As 30 do CI são fumaça e têm ±18 pontos de
> margem — comparar aquele número com estes é comparar sorteio.

**As regras do projeto estão em `CLAUDE.md` e carregam sozinhas.** Esta skill
não as repete — ela conduz a medição e garante que nada fica para trás.

---

## 0. Antes de mexer: qual é o alvo?

**"Melhor" não é um alvo; um número é.** Em `085`, Bruno recuperou a moeda
anterior à `084` e caixa R$400 mil. Depois substituiu a dívida: esse crédito
inicial deve ser devolvido em três parcelas menores e iguais, capital mais
juros. R$530 mil na primeira deixou de ser requisito; não reabra a origem.
Pediu coerência também com futuras expansões, carros e imóveis. Use
`docs/design/BR_Port_Metodo_Balanceamento_Economia.md`: separar crédito de
lucro, medir caixa livre e acessibilidade, e registrar o contrato financeiro.
O alvo de aprender e reconstruir (`005`) continua; as taxas atuais vivem só
no `CLAUDE.md`. Sensibilidades antigas não substituem medição neste calendário.
Quando a mudança do contrato libera caixa demais, medir o retorno dos serviços
separadamente dos custos dos reparos. A comparação com tarifas reais precisa
de unidades e rubricas equivalentes: bote não é navio comercial, turno não é
tonelada. Não chamar faixa ficcional de cotação auditada.

⚠️ **Quem separa os portos é expansão e margem em regime.** A fila (`083`)
ainda permite escolher o barco, e o `premio_da_escolha` medido continua no
projetor. Reescala preserva seus ratios; o novo valor da dívida é outro passo.

⚠️ **A parcela move quem está perto do limiar, não um perfil por definição.**
Não extrapole pontos por R$10.000 medidos na moeda antiga. O GDD congelado
converte-se no projetor por `ESCALA_MONETARIA_GDD`; a economia atual vem do
código. As Fases 2/3 projetadas não medem três cobranças dentro da Fase 1.

Desde `085`, medir a Fase 1 inteira exige contar quem chegou e quem pagou em
cada cobrança, o caixa antes da decisão e o saldo depois, incluindo o perfil
Antecipado. O prazo e os desbloqueios mudam a população que alcança o próximo
vencimento; não extrapole a primeira cobrança nem uma projeção de outra fase.
Ao comparar calendários, meça novamente também a primeira parcela. Proponha
valores novos ao Bruno depois da medição, com poucas opções e a recomendação
primeiro; não trate a exploração antiga R$30/45/60 mil como aceite.

A opção `--sem-save` usa o mesmo GameState, substituindo só persistência.
Antes de confiar na rodada rápida, compare os JSONs de uma amostra com e sem
autosave, com sementes iguais. A margem em regime soma de volta despesas de
obra e todas as parcelas; o prêmio da escolha deve vir dessa mesma semana.
Compare também P10/P50/P90 e o tamanho das amostras de caixa. Restaurar a
moeda não prova realismo nem estabilidade depois da última dívida. Quando
Bruno mudar o alvo ou a escala explicitamente, essa escolha substitui a
anterior; não repetir a pergunta já respondida nem renomear juros para cobrir
uma dívida cuja origem não foi definida.

⚠️ **O Ótimo está em 100% redondos**, e voltou lá com a trava de nível. Ele
esteve em 99,8% entre as duas passagens de 06/09 por uma razão diagnosticada
(levantar as sete estruturas num sorteio mau e chegar curto); um Ótimo abaixo
de ~99% é defeito, não sorteio.

Se o pedido implica outro alvo, **isso é decisão de design e não é sua**:
pergunte, e registre em `docs/decisoes/` antes de tocar em constante nenhuma.

---

## 1. Meça ANTES de mexer

A medição de partida é o que permite atribuir o efeito. Sem ela, no fim não se
sabe se o número mudou por causa da mudança ou por causa da amostra.

```sh
$G --headless --path brport_vs --script res://tools/simular_balanceamento.gd \
   -- 600 20260825 /tmp/antes.json | tee /tmp/antes.txt
```

**600, e a mesma semente.** É o que o `testes.yml` roda a cada push na
`main` e a cada PR (não ao empurrar a branch — `CLAUDE.md`). Uma rodada curta
é teste de fumaça: tem ±18 pontos de margem, e comparar 36,7% com 47,3% é
comparar sorteio. O próprio simulador avisa quando a amostra é curta demais.

**Medido em 02/09: as 600 partidas levam 26 segundos.** Esta skill dizia
"demora minutos" e mandava rodar em segundo plano; não é preciso. O custo nunca
foi o motivo de a medição ficar fora de cada PR — o motivo é o ruído, que um
número com ±4 pontos anexado a todo PR convida a ler como regressão.

Há também `.github/workflows/balanceamento.yml`, que roda estas mesmas 600 às
segundas e sob demanda (Actions → Balanceamento → Run workflow), e deixa a
leitura na página da corrida. **Ele não substitui esta skill:** ele mede o que
está na main, e o que se quer aqui é o antes/depois de uma constante que ainda
não foi empurrada.

---

## 2. Escala e RATIO são coisas diferentes, e a diferença é mensurável

A confusão mais cara desta ferramenta, e vale medi-la em vez de discuti-la:

- **Escala uniforme** (tudo × K) é **cosmética**. Medido em 02/09: multiplicar
  todo o dinheiro por 100 deixou todas as medianas exatamente ×100 (margem em
  regime R$2.943 → R$295.116). O jogo não muda.
- **Ratio** (uns sobem, outros não) **muda o jogo**. É aqui que a dificuldade
  se move.

**Se o pedido é "os valores são pequenos demais", faça os dois passos separados
e meça entre eles.** Foi o que permitiu provar que a reescala não tinha efeito
e atribuir tudo o que mudou aos ratios. Um passo só deixa os dois efeitos
misturados e sem forma de os separar depois.

⚠️ **A escala uniforme não é bit a bit idêntica**, e não é defeito: o RNG
sorteia de uma faixa mais fina (121 valores viram 12.001), então a mesma
semente dá uma amostra diferente. As MEDIANAS escalam exatamente; a taxa de
vitória oscila. Se ela oscilar muito, ver a seção 6.

---

## 3. Mexa, e meça outra vez

Uma coisa de cada vez, com a mesma semente. Guarde os resultados intermédios —
a decisão registrada quer a tabela de tentativas, não só a escolhida.

```sh
$G --headless --path brport_vs --script res://tools/simular_balanceamento.gd \
   -- 600 20260825 /tmp/depois.json | tee /tmp/depois.txt
grep -E 'Ótimo|Mediano|Descuidado' /tmp/depois.txt | head -3
```

**Os botões, por ordem de efeito:**

| Quero… | Mexo em |
|---|---|
| mover a taxa de vitória, e só ela | `PARCELA_AMOUNT` |
| separar melhor os perfis | `MAINTENANCE_WEEKLY` — custo fixo dói mais a quem tem pouca vazão |
| mudar o ritmo de expansão | os `custo` das `ESTRUTURAS` |
| mudar a receita | as faixas de contrato das `CLASSES_DE_NAVIO` — e desde a fila (`083`) é o botão que move o Mediano E o Descuidado |
| quantos barcos chegam e quanto esperam | `BOAT_ARRIVAL_CHANCE` (por lugar da fila) e `PACIENCIA_FILA` — ⚠️ medido na `083`: a grelha 0,5–0,9 × 1–3 deixou o Descuidado entre 50 e 58%, porque ele perde barco por esquecer o berço, e não por falta de barco ao largo |

⚠️ **A VARREDURA AUTOMÁTICA RESTAURA DE UMA CÓPIA PRISTINA, tirada UMA vez.**
Em 04/10 o script da varredura foi editado com uma corrida a meio: a corrida
seguinte guardou como «original» o `GameState.gd` ainda mutado (chegada a
0,9), devolveu-o a si mesmo, e o `cmp` do fim deu verde — o arquivo do jogo
ficou com o valor errado sem uma queixa. A cópia de partida tira-se antes da
primeira corrida, e cada corrida confere que o arquivo bate com ela ANTES de
mexer (`cmp`), e não só depois.

**Cuidado ao ENCARECER as estruturas.** Os perfis do simulador só compram
quando `caixa >= custo × folga` (Mediano 2×, Descuidado 4×). Se a primeira
estrutura ficar cara face ao caixa inicial, o cauteloso NUNCA constrói —
acumula, paga a parcela, e a dificuldade **inverte**: medido, o Descuidado a
51,7% contra o Mediano a 13,8%. Ordem invertida é sinal disto, não de a
economia estar difícil.

⚠️ **E isto é uma propriedade do CUSTO, não da razão `caixa / custo` —
não a extrapole para o `START_CASH` (`docs/decisoes/018`).** A tentação é ler a
inversão como um efeito da proporção entre os dois e prever a mesma coisa
baixando o caixa inicial. Medido em sete pontos dos 400.000 aos 150.000: **a
ordem nunca inverte.** São dois eixos — encarecer a estrutura mexe só em QUEM
CONSTRÓI; baixar o caixa mexe nisso **e** no nível absoluto contra a parcela, e
o segundo domina. O acumulador só ganha se tiver o que acumular.

⚠️ **E `caixa >= custo × folga` não faz penhasco nenhum numa partida de 32
turnos.** Ela responde pelo TURNO 1; quem decide é `caixa inicial + receita
acumulada`. Medido, a fração de partidas em que o Descuidado levanta o
escritório dos 400.000 aos 150.000 é `100 · 100 · 100 · 100 · 100 · 98 · 86` —
suave, sem degrau. Um limiar de compra só é penhasco quando o jogo acaba antes
de o perfil poupar a diferença.

---

## 4. O que a medição envelhece — e o CI cobra

Todos estes falham no CI se ficarem para trás. Rode na ordem:

```sh
# 1. As constantes que o Godot avalia de verdade
$G --headless --path brport_vs --script res://tools/despejar_constantes.gd \
   -- /tmp/constantes.json          # espera CONSTANTES OK

# 2. A tabela dos números, GERADA do GameState.gd
python3 tools/gerar_tabela_numeros.py --contra-godot /tmp/constantes.json
python3 tools/gerar_tabela_numeros.py --conferir --contra-godot /tmp/constantes.json

# 3. O projetor: o modelo ainda reconstrói a Fase 1 medida?
python3 tools/projetar_parcelas.py --medicao /tmp/depois.json \
   --constantes /tmp/constantes.json   # espera "calibrado"

# 4. As suítes — dois testes já reprovaram por dinheiro cravado
for t in tests/run_tests tests/teste_design tests/teste_audio \
         tests/teste_fumaca scripts/validation/asset_validator; do
  $G --headless --path brport_vs --script res://$t.gd
done
```

⚠️ **E SE UM EFEITO DEIXAR DE SER GLOBAL, O MODELO DO PROJETOR TEM DE APRENDER
ISSO.** Ele resume o jogo numa conta fechada, e uma conta fechada só sabe o que
lhe ensinaram: em 06/09 o bónus do armazém passou a depender do MOTIVO do
barco, e o modelo, que ainda o somava a tudo, saiu **15,7% acima do medido** no
Mediano e no Ótimo — o portão reprovou, com razão. É a irmã da armadilha que a
`007` registou com o `cais`: efeito novo que muda o barco médio sem nenhuma
constante de VALOR ter mudado. **Dois perfis fora e o terceiro dentro é o
modelo a ignorar uma compra**, não métrica.

⚠️ **E CONFIRA COM QUANTAS PARTIDAS ELE FOI ALIMENTADO.** O portão recusa-se a
calibrar abaixo de 100 — e recusa-se em voz alta, com a razão. Até 06/09 o CI
dava-lhe as 30 partidas de fumaça e ele reprovou um modelo CERTO: a margem em
regime de 30 partidas oscila ±6% a ±9% conforme a semente, mais do que a
tolerância de 5% contra a qual é comparada. Portão que compara contra um número
medido tem de saber quanto esse número se mexe sozinho.

**Se o projetor deixar de calibrar, leia o erro antes de mexer no modelo.** Um
perfil fora e dois dentro (0,1% e 0,5%) não é modelo partido — é a métrica: com
custo fixo grande, a margem de quem tem pouca vazão é a diferença pequena entre
dois números grandes, e um erro absoluto irrelevante vira percentagem enorme. O
portão já tem um piso absoluto de meio barco para isso, e diz quando passa por
ele. **Os três fora ao mesmo tempo é que é modelo partido.**

---

## 5. O rasto de prosa — é aqui que se falha

Números escritos à mão em texto envelhecem calados, e este projeto já os apanhou
em três sítios de uma vez. Procure e conserte:

| Onde | O quê |
|---|---|
| `GameState.gd`, cabeçalho `# ── TUNING` | o porquê dos preços; taxas atuais só no `CLAUDE.md` |
| `CLAUDE.md`, item 4 do "antes de fechar" | as taxas, a mediana, o alvo |
| `docs/ESTADO_DO_PROJETO.md` | o resumo da economia, nas primeiras linhas |
| `docs/decisoes/` | decisão nova com alvo e tentativas; tabelas antigas são histórico |
| `simular_balanceamento.gd` | avisos e comentários descrevem o perfil atual ou datam a medição histórica |
| `projetar_parcelas.py` | o bloco "Leitura" — imprime no CI a cada corrida — **e o MODELO, se o efeito de uma estrutura mudou de forma**. ⚠️ Ele lê a Fase 1 do CÓDIGO e as Fases 2/3 do GDD: se a faixa de contrato mudar, os três perfis reprovam de uma vez e isso NÃO é métrica |
| `gerar_tabela_numeros.py` | se entrou um `const` de dicionário: literal composto não vai à tabela sozinho, e some sem erro (foi o caso de `MOTIVOS` em 06/09) |
| `BR_Port_GDD_V7_ERRATA_ECONOMIA.md` | separa o histórico da moeda atual e aponta para a tabela gerada |
| `docs/design/BR_Port_GDD_V7.jsx` | congelado; o projetor converte pela `ESCALA_MONETARIA_GDD` |
| **`.claude/skills/`** | alvo e receita apontam para a medição no `CLAUDE.md`; quem muda uma receita procura também suas cópias |

Procure valores anteriores E atuais; um comentário histórico precisa dizer
que é histórico. A taxa atual não se replica em receitas.

```sh
rg -n '78,7|41,5|R\$629|538\.184|530\.000' CLAUDE.md brport_vs tools .claude docs
# os da medição ANTERIOR também, para achar o que ficou por mudar:
rg -n '80,2|37,3|R\$716|674\.019|30\.000|40\.000' CLAUDE.md brport_vs tools .claude docs
```

**Melhor que atualizar é DERIVAR.** Onde a prosa puder ler o número da medição
em vez de o ter escrito, faça isso — foi assim que o `projetar_parcelas.py`
deixou de imprimir "a Fase 1 mede 47%" no log do CI para sempre. E um bloco que
não ache o valor deve RECLAMAR, não calar-se: bloco silencioso é como o número
cravado volta sem ninguém reparar.

---

## 6. Ler o resultado sem se enganar

**A taxa de vitória não é o número que interessa** desde a decisão 005. Com a
dívida sem ameaçar, quase toda a gente paga — a diferença entre jogar bem e mal
aparece no PORTO: barcos atendidos e barcos por semana em regime. Quem olhar só
a taxa conclui que o jogo não tem dificuldade nenhuma.

**Aresta de faca.** Se a mediana de um perfil cair praticamente em cima da
parcela, a taxa dele fica hipersensível: qualquer reamostragem balança dez
pontos sem nada ter mudado. Sintoma: a taxa mexe muito e a mediana quase nada.
É desenho a corrigir, não ruído a tolerar — um jogador não deve estar num
cara-ou-coroa.

**Ordem invertida** (Descuidado acima do Mediano) é sempre o efeito da seção 3,
nunca uma economia "difícil".

---

## 7. Fechar

- A decisão em `docs/decisoes/`, com **a tabela das tentativas**, não só a
  escolhida — quem reabrir o assunto precisa de saber o que já foi medido.
- O `ESTADO_DO_PROJETO.md` em dia.
- Commit em inglês, com os números medidos na mensagem.
- Depois, `/fechar-sessao` para o resto do ritual.

## Falha segura

Se uma verificação reprovar, **não feche**. E não afrouxe o portão para passar:
o `TOLERANCIA` do projetor e o alvo da decisão existem para reclamar. Se um
deles estiver errado, conserte-o pela razão certa e escreva a razão — nunca
porque estava no caminho.
