---
name: balancear
description: Mede e ajusta a economia do BR Port com o simulador, e arrasta atrás o que a medição envelhece — a tabela dos números, o projetor das Parcelas, o CLAUDE.md e a decisão registrada. Acione com "balancear", "medir o balanceamento", "mexer nos preços", "mudar o valor do contrato/da parcela/do salário", "a economia está fácil/difícil demais", "reescalar os valores", ou antes de tocar em QUALQUER constante `# TUNING:` do GameState.gd. NÃO é para rodar o simulador só para ver — para isso rode a ferramenta direto.
---

# Balancear — BR Port

Mexer num número da economia é barato. O que é caro é o rasto: seis documentos
afirmam o balanceamento, o CI reprova quem os deixa envelhecer, e a taxa de
vitória é o número mais fácil de ler errado do projeto inteiro.

**As regras do projeto estão em `CLAUDE.md` e carregam sozinhas.** Esta skill
não as repete — ela conduz a medição e garante que nada fica para trás.

---

## 0. Antes de mexer: qual é o alvo?

**"Melhor" não é um alvo; um número é.** O alvo em vigor está em
`docs/decisoes/005` e é **tranquilo**: a dívida deixou de ser o motor, e quem
discrimina os jogadores é o porto que eles conseguem levantar.

| Perfil | Alvo |
|---|---|
| Ótimo | 100% |
| Mediano | ~80% — ganha com folga |
| Descuidado | ~31% — perde a maioria, sem ser garantido |

⚠️ **O número do Descuidado desceu de ~35% para 31,0% em 05/09**, e não por um
preço ter mudado: os dois upgrades de guindaste e cais (`docs/decisoes/007`)
deram mais uma coisa para comprar, e quem compra mal compra tarde. Nenhum ponto
do varrimento o recupera sem custar o Mediano. **Trazê-lo de volta é decisão do
Bruno** — o botão seria a `PARCELA_AMOUNT`, e é outra medição.

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

**600, e a mesma semente.** As 30 partidas que o `testes.yml` roda a cada push
são teste de fumaça: têm ±18 pontos de margem, e comparar 36,7% com 47,3% é
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
| mudar a receita | as quatro `BOAT_VALUE_*` |

**Cuidado com a proporção entre `START_CASH` e a primeira estrutura.** Os
perfis do simulador só compram quando `caixa >= custo × folga` (Mediano 2×,
Descuidado 4×). Se a primeira estrutura ficar cara face ao caixa inicial, o
cauteloso NUNCA constrói — acumula, paga a parcela, e a dificuldade **inverte**:
medido, o Descuidado a 51,7% contra o Mediano a 13,8%. Ordem invertida é sinal
disto, não de a economia estar difícil.

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

# 4. As cinco suítes — dois testes já reprovaram por dinheiro cravado
for t in tests/run_tests tests/teste_design tests/teste_audio \
         tests/teste_fumaca scripts/validation/asset_validator; do
  $G --headless --path brport_vs --script res://$t.gd
done
```

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
| `GameState.gd`, cabeçalho `# ── TUNING` | as taxas e a mediana, logo acima das constantes |
| `CLAUDE.md`, item 4 do "antes de fechar" | as taxas, a mediana, o alvo |
| `docs/ESTADO_DO_PROJETO.md` | o resumo da economia, nas primeiras linhas |
| `docs/decisoes/005` | o alvo, e a tabela das tentativas |
| `simular_balanceamento.gd` | o aviso de amostra curta cita as taxas |
| `projetar_parcelas.py` | o bloco "Leitura" — imprime no CI a cada corrida |
| `BR_Port_GDD_V7_ERRATA_ECONOMIA.md` | o fecho da pergunta cita as taxas |
| `docs/design/BR_Port_GDD_V7.jsx` | faixas de contrato e parcelas, se a escala mudou |
| **`.claude/skills/`** | **as duas skills afirmam as taxas** — esta, no alvo da §0, e a `/fechar-sessao`, na coluna "espera" da tabela dela. Foram esquecidas em 05/09 e apanhadas pela varredura da própria `/fechar-sessao`: quem muda uma receita tem de procurar quem a copiou, e a receita copiou-se a si mesma |

O grep abaixo achou os oito na última vez; se achar menos, alguém renomeou
alguma coisa e a lista é que envelheceu.

```sh
grep -rn '79,5\|31,0\|R\$796\|56,2' --include=*.md --include=*.gd --include=*.py .
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
