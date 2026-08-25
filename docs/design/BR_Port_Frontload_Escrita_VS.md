# BR Port — Arquivo de Frontload da Escrita
**VS · Fase 1 do jogo completa (semanas 1–12)**

> Este arquivo é a fonte da verdade de todo o texto do VS. Produzido durante as 2h leves do Bloco 1. Não precisa ficar perfeito agora — precisa estar presente. Refinamento acontece durante o Bloco 5 (polish).
>
> **Tokens usados nos textos:**
> - `{portName}` → nome do porto escolhido pelo jogador (fallback: "Cais Mirim")
> - `{playerName}` → nome do protagonista escolhido pelo jogador
> - `[semana X]` → número da semana do jogo (preenchido pelo código)

---

## 1. Diário do Porto — 1ª Página

*Aparece na primeira abertura do Diário, semana 1 do jogo. Tom: primeira pessoa, incerteza com leveza.*

---

**Porto Mirim, Semana 1**

Nunca pensei que ia escrever nesse diário.

O avô escrevia aqui toda semana — vinte e três anos de {portName}, letra miúda, tinta azul.
Eu achava piegas.

Hoje abri a primeira página em branco.

O {portName} tem dívida, tem madeira podre no píer e tem um rival que sabe o meu nome antes de eu saber o dele direito.

Mas tem gente que acreditou o suficiente pra estar aqui na semana 1.
Dona Cida. Toninho. Zezão.

Talvez o avô soubesse o que tava fazendo quando deixou tudo isso pra mim.

Talvez.

---

*[Status do arquivo: rascunho — ajustar tom conforme a voz do protagonista for se definindo durante a produção]*

---

## 2. Boletim Financeiro da Dona Cida

*Aparece toda semana de jogo, no painel do Boletim Financeiro. A Dona Cida lê os números — o comentário dela muda conforme o resultado.*

### 2a. Estrutura visual (referência pro programador)

```
── BOLETIM FINANCEIRO ──────────────────────
  Semana [X] de 12

  RECEITAS
  Docagens:        R$ [valor]
  Armazém:         R$ [valor]
  Aluguel de píer: R$ [valor]
  ────────────────────────────
  Total:           R$ [valor]

  DESPESAS
  Salários:        R$ [valor]
  Manutenção:      R$ [valor]
  Parcela (se app):R$ [valor]
  ────────────────────────────
  Total:           R$ [valor]

  RESULTADO LÍQUIDO: R$ [valor]
  Semana anterior:   R$ [valor] ([↑/↓] X%)

  [Comentário da Dona Cida — ver abaixo]
────────────────────────────────────────────
```

### 2b. Variação 1 — Resultado negativo (ironia seca)

*Disparada quando resultado líquido < 0.*

> "Conseguimos a façanha de gastar mais do que ganhar. De novo.
> A semana anterior foi melhor — mas 'melhor' aqui é comparativo de 'ruim', então não comemora não.
> A parcela não vai ter dó."

### 2c. Variação 2 — Resultado neutro ou levemente positivo (frieza calculista)

*Disparada quando resultado líquido está entre 0 e +30% da média das semanas anteriores.*

> "Os números fecharam. Receita cobre despesas, sobrou margem.
> Nada extraordinário — mas porto que fecha no azul é porto que abre segunda-feira."

### 2d. Variação 3 — Resultado excepcional (rara comemoração)

*Disparada quando resultado líquido está acima de +30% da média das semanas anteriores.*

> "Chefia. Olha esse resultado.
> Não vou fazer festa — porque a parcela da próxima semana vai precisar desse dinheiro todo.
> Mas por hoje: bem feito."

---

*[Status: rascunho — o tom da Dona Cida pode ser calibrado depois do Marco Intermediário (Bloco 3), quando o loop tiver sendo jogado de verdade]*

---

## 3. Comentários da Dona Cida — Loop de Gameplay

*Linhas curtas que aparecem durante o jogo em reação a eventos. Exibidas como balão ou linha de texto junto ao ícone da Dona Cida.*

### Situações e linhas

| Situação | Linha da Dona Cida |
|---|---|
| Reputação subindo | "O pessoal tá falando bem do cais, chefia. Raro. Aproveita." |
| Reputação caindo | "Dois contratos recusados essa semana. Arlindo vai saber antes de nós." |
| Caixa perigosamente baixo | "A conta tá mais fina que folha de papel. A parcela não vai esperar." |
| Contra-oferta perdida pro Arlindo | "Perdeu pro Arlindo. Mas perdeu perdendo bem — não por desatenção." |
| Bom contrato fechado | "Esse contrato fecha o mês. Anota aí." |
| Início de semana nova | "Semana nova. Barcos na fila, caixa no limite. Dia típico." |
| Upgrade concluído | "Zezão terminou. Demorou o dobro do previsto, mas ficou bom." |
| Arlindo mencionado indiretamente | "O Porto Farol tá aceitando tudo que a gente recusa. Coincidência, chefia?" |

*[Status: rascunho — adicionar linhas conforme novos eventos forem surgindo no Bloco 2]*

---

## 4. Tela de Contra-Oferta — Linhas do Arlindo

*Aparece na tela de negociação quando o cliente considera a proposta do Porto Farol. O Arlindo aparece como rival visível.*

### Contexto técnico

- O jogador tem **2 tentativas** de contra-oferta (3 presets em botões)
- A mood face do cliente mostra: 2 tentativas = neutro | 1 restante = preocupado | 0 = saindo
- O Arlindo não fala diretamente com o jogador na tela — ele fala com o cliente, e o jogador ouve

### Abertura (Arlindo abordando o cliente)

> "{portName} fez uma proposta. Entendo. Mas eu consigo cobrir isso — e um pouco mais."

### Reações às contra-ofertas do jogador

**Se o jogador iguala o desconto máximo (preset "−15%"):**
> "Ficou nervoso, hein? Bom sinal."

**Se o jogador faz desconto intermediário (preset "−7%"):**
> "Metade do esforço. Respeito a tentativa."

**Se o jogador mantém o preço (preset "Manter"):**
> "Autoconfiante. Gosto. Autoconfiante não paga conta — mas gosto."

### Última tentativa (1 restante — mood preocupado)

*Linha do Arlindo pro cliente, não pro jogador:*

> "Minha oferta não expira, [cliente]. A paciência do senhor, sim."

### Arlindo vence (cliente vai pro Porto Farol)

> "Sempre bom fazer negócio. Boa sorte pro {portName}."

### Arlindo perde (jogador fecha o contrato)

*Linha do Arlindo olhando pro lado — indireta, não perde a compostura:*

> "Dessa vez não. Mas tem mais semanas pela frente, sobrinho."

---

*[Status: rascunho — "sobrinho" é forma genérica que o Arlindo usa com o protagonista independente de gênero. Revisar se for escolha de personagem feminina no VS]*

---

## 5. Cena de Parcela — Diálogo do Sr. Ribeiro

*Sr. Ribeiro aparece pessoalmente na semana 4 (Parcela 1 — R$ 8.000). Cena tensa, sem penalidade mecânica. Sprite simples + diálogo curto.*

### Entrada

> "Boa tarde, {playerName}. Rivaldo Ribeiro, Banco Porto Mirim.
> Fui amigo do seu avô — uns trinta anos, se não me engano.
> Vim pessoalmente porque o {portName} merece esse respeito."

### Apresentando a dívida

> "A Parcela 1 vence hoje: R$ 8.000. Tenho o documento aqui se quiser conferir.
> O Seu Maneco assinou isso. Agora é seu."

### Pagamento em dia

> "Perfeito. Eu sabia que dava.
> Guarda esse recibo — o banco não esquece quem paga em dia, e eu também não.
> Se precisar de fôlego em algum momento, me procura *antes* de ter problema. Não depois."

### Pagamento com 1 semana de atraso

> "Os juros já estão correndo — 5% ao dia. Não é punição, é contrato.
> Mas vim pessoalmente porque sei que é o primeiro mês.
> Uma vez eu deixo passar com uma conversa. Na segunda, o contrato fala por mim."

### Encerramento (em qualquer situação — após a Parcela 1)

> "Uma coisa antes de ir.
> O Seu Maneco me disse uma vez que o maior erro de um portuário é achar que pode resolver tudo sozinho.
> Se precisar de crédito pra crescer — e vai precisar — o banco existe pra isso.
> Não deixa chegar no desespero pra me ligar."

---

*[Status: rascunho — Parcelas 2 e 3 usam variações desta cena. No VS, o mesmo diálogo base com ajuste de valor e tom. Parcela 3 (R$ 24.000) tem a presença do "Sr. Abutre" mencionada — adicionar linha aqui se entrar no VS]*

---

## 6. Narração de Fim de Fase 1

*Cena estática após pagamento da Parcela 3 (semana 12). Narração em texto sobre a imagem do píer. Tom: contemplativo, sem exagero dramático.*

---

**FIM DA FASE 1**

Doze semanas.

Trinta e seis turnos de decisão.
Três parcelas.
E agora a última.

O {portName} respira.

Ainda tem dívida?
Tem.

Ainda tem Arlindo no horizonte?
Tem.

Mas o cais que o Seu Maneco deixou
ainda é nosso.

—

{playerName} olha pro píer.

A mesma madeira velha.
O mesmo cheiro de maresia.
Os mesmos trabalhadores que conhecem cada tábua podre de cor.

Mas tem alguma coisa diferente.

Não no píer.

Em quem tá olhando.

---

*[Status: rascunho — ritmo das quebras de linha é intencional (leitura pausada). Ajustar se a implementação usar animação de texto linha por linha — nesse caso, cada linha é um beat separado]*

---

## Status geral do arquivo

| Seção | Status | Semana de escrita |
|---|---|---|
| 1. Diário do Porto — 1ª página | Rascunho | Semana 1 |
| 2. Boletim Financeiro (modelo + 3 variações) | Rascunho | Semana 2 |
| 3. Comentários da Dona Cida (8 linhas) | Rascunho | Semana 3 |
| 4. Linhas do Arlindo (contra-oferta) | Rascunho | Semana 4 |
| 5. Diálogo Sr. Ribeiro (cena de parcela) | Rascunho | Semana 5 |
| 6. Narração de fim de Fase 1 | Rascunho | Semana 6 |

**Próximo uso deste arquivo:** Bloco 5 (semana 35+) — revisão e refinamento final antes da publicação.

---

*BR Port · Arquivo de Frontload da Escrita · Versão 1.0 · Bloco 1 da Fase 4*
