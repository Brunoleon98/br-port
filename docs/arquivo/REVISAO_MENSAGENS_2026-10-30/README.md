# Primeiro parecer do revisor de mensagens

30/10/2026, decisão `145`. Revisão assistida feita nesta conversa pela skill
`revisar-mensagens`, sem executar outro bot ou serviço externo. Fonte de
produção: árvore após incorporar `origin/main` em `0a2e16f`, HEAD `d606b8f`,
branch `codex/revisor-de-mensagens`. Árvore com o revisor ainda por commitar;
hashes e trechos do pacote em `manifesto.json`. O relatório não foi aplicado
às falas.

## Parecer

Caneca, café, chave e almoço dão bons momentos de intimidade. Preservaria
essas cenas. Os problemas mais relevantes são **atribuir uma causa que o
gatilho não garante** e **sugerir uma rotina de compras que não existe**.
Naturalidade melhora quando a frase oferece um gesto ou uma opinião do
personagem, em vez de explicar a mecânica ou o que o painel acabou de mostrar.

### R1 — Cida pode culpar uma recusa por outra perda de reputação

**Prioridade alta; relação entre texto e gatilho conferida no código.**
`CIDA_LINHAS.reputacao_caiu`, `Narrativa.gd:158`:

> Andaram recusando contrato, chefia. Arlindo vai saber antes de nós.

`NarradoraDaCida._cida_reputacao()`, linhas 165–180, escolhe a fala ao cair de
faixa; não consulta a causa da queda. `GameState.cancelar_servico()`, linha
1606, também chama `_change_reputation()` com perda. Assim, atravessar uma
faixa por cancelamento pode disparar uma frase sobre recusar contratos.
O próprio comentário de `Narrativa.gd:155` já distingue queda de faixa e
recusas, mas a redação ainda afirma uma causa específica.

Não foi simulada uma partida nesta revisão; o achado é a ausência dessa
garantia no caminho de código. Não se mediu quantas vezes isso aparece.

**Candidata:** «A cidade comenta, chefia. O Arlindo anota.» Mantém a pressão
social e a voz prática sem dizer qual ação causou a queda. Outra solução seria
variar pelo motivo da queda, mas isso ampliaria a lógica; não é necessário
para melhorar a frase. **Situação: proposta.**

### R2 — A cena do Mané sugere uma conta recorrente

**Prioridade alta; risco de interpretação, não cobrança indevida comprovada.**
`HISTORIA_DO_PORTO.mesa`, `Narrativa.gd:771–774`:

> O Mané perguntou se já pode pôr o nome do nosso cais na lista das entregas fixas.
>
> Pois é. Quem entra nela ganha um lugar na cidade. E uma conta no fim do mês.

O capítulo exige passagem de semanas e duas parcelas quitadas
(`VidaDoPorto.disponiveis()`); não exige comprar almoço. O catálogo oferece
um almoço único, sem recorrência. A conversa não cria uma assinatura, mas a
combinação «fixas»/«conta no fim do mês» pode levar o jogador a esperar outra
despesa. Este apontamento reconfirma a revisão anterior.

**Caminho candidato:** usar o convite do Mané para dividir a mesa, como na
proposta «Mais uma cadeira» do documento de revisão. O convite aproxima as
pessoas sem anunciar uma compra futura. **Situação: proposta, ainda sem aceite.**

### R3 — «Fecha a semana» pode soar como uma previsão financeira

**Prioridade média; risco de interpretação de uma hipérbole.**
`CIDA_LINHAS.bom_contrato`, `Narrativa.gd:173`:

> Esse contrato fecha a semana. Anota aí.

`NarradoraDaCida._cida_contrato()`, linhas 104–111, lê o valor no quarto
superior da faixa da classe do navio. Não lê o resultado acumulado da semana,
salários, obras ou parcela. É plausível como elogio coloquial; o problema é
ser lido como informação útil sobre as contas num jogo de gestão.

**Candidata:** «Esse valeu a conversa. Anota aí.» Preserva a aprovação curta
da Cida e não garante saldo ou resultado. Não se concluiu que a semana fica
negativa em toda ocorrência nem se mediu frequência. **Situação: proposta.**

### R4 — O envelope interrompe a descoberta para explicar o contrato

**Prioridade média; opinião editorial e continuidade.**
`HISTORIA_DO_PORTO.envelope`, `Narrativa.gd:764–768`:

> A dívida antiga é uma história. O empréstimo que fizemos pra reconstruir é outra. Não mistura os papéis.

Separar os contratos é correto; a versão atual apenas muda bruscamente da
descoberta para uma explicação dirigida ao jogador. A chave abre um armário,
mas o envelope é achado «atrás dos livros do galpão», sem situar o armário.

**Candidata para a reação da Cida:** «Deixa aqui na mesa. A gente olha o resto
junto.» A oferta deve continuar explicitamente antiga para não reescrever o
empréstimo atual. A versão completa já proposta no documento de revisão faz
essa ligação. **Situação: proposta.**

**Limite adicional:** o arquivo das histórias permite ler qualquer capítulo
disponível; não exige ter lido a chave antes do envelope. Antes de fortalecer
uma referência à cena anterior, conferir também a leitura fora de ordem.
Não se recomenda bloquear leitura sem uma decisão de experiência própria.

### R5 — O catálogo vende primeiro o acesso à conversa

**Prioridade média; opinião editorial sobre a motivação da compra.**
`VidaDoPorto.PRODUTOS`, linhas 7–10:

> Desbloqueia a conversa Café no cais. Compra única; sem bônus de operação.

O efeito está claro e verdadeiro, mas a descrição deixa o café em segundo
plano. A compra pode ser um gesto com a equipe antes de ser uma entrada do
catálogo de cenas.

**Candidata:** «Para preparar um café e dividir com a equipe no cais.
Inclui a cena Café no cais. Compra única, sem bônus de operação.» O almoço
pode seguir a mesma estrutura. Conservar preço, saldo restante e consequência
na confirmação. O texto maior precisa de captura antes de integrar.
**Situação: proposta.**

### R6 — A piada do Mané ocupa o encontro inteiro

**Prioridade baixa; opinião editorial.** `VISITAS_AS_LOJAS.delivery`,
`Narrativa.gd:802`:

> Entrega no cais? Sei o caminho de olhos fechados. Seu Maneco me ensinou a não ir de olhos fechados.

A repetição pode funcionar como humor falado, mas, numa visita de duas falas,
domina o primeiro contato e oferece pouca relação com o novo responsável.

**Candidata:** «Pode ligar. Pedido ou conversa, eu atendo.» A resposta sobre
a mão na panela do rascunho pode completar a voz de quem cozinha e conversa.
Não se assume que humor leve deva desaparecer do Mané. **Situação: proposta.**

## Cobertura editorial desta rodada

| Unidade analisada | Parecer | Situação |
|---|---|---|
| `caneca` | O hábito e a borda lascada sustentam a ausência; manter o remate curto. | Manter |
| `chave` | A chave passa confiança, e Toninho oferece ajuda. Serve com obra pronta ou por fazer. | Já aceito por Bruno; manter |
| `recibo` | A cidade começa a reconhecer o cais, mas o recibo do título não aparece na fala. Prioridade baixa: considerar a versão que menciona o recibo. | Proposta anterior continua aberta |
| `envelope` | Pista relevante, com interrupção explicativa e referência a outra cena que pode não ter sido lida. | R4 |
| `mesa` | Bom elo com Mané; promessa de entrega fixa precisa de revisão. | R2 |
| `arlindo` | Simpatia com interesse e a disputa pelo nome na placa cumprem a função do rival. Não suavizar só para torná-lo agradável. | Manter nesta rodada |
| `cafe` | A conversa durar por causa do café fraco dá afeto e humor sem discurso. | Manter |
| `almoco` | Reservar um canto à chefia inclui quem joga; a brincadeira do prato cabe na equipe. | Já aceito por Bruno; manter |
| Visita ao Mercado | Lembrança concreta funciona, mas a segunda fala ainda olha só para o avô. A proposta de convidar a sentar pode aproximar o protagonista. | Proposta anterior continua aberta |
| Visita ao Delivery | A primeira piada domina o contato curto. | R6 |
| Descrição do café | Efeito verdadeiro, motivação do gesto pouco presente. | R5 |
| Descrição do almoço | Mesma questão do café; preservar pedido único e ausência de recorrência. | R5 |
| Cida: `reputacao_caiu` | A causa afirmada não é garantida pelo gatilho compartilhado. | R1 |
| Cida: `bom_contrato` | O elogio pode ser lido como previsão do resultado semanal. | R3 |
| Arlindo: abertura da negociação | «Querido» não foi tratado como erro: o comentário da fonte registra sua manutenção deliberada; «meu caro» substituiu o parentesco de «sobrinho». | Contraprova; manter |

## O que não se pode concluir deste parecer

O preparador reuniu 31 fontes em 70 trechos, mas este relatório **não afirma
ter revisado editorialmente as 31 fontes inteiras**. Ficaram para outras
rodadas: diário inicial, boletins, demais linhas do loop, tutorial, Ribeiro,
demais falas da negociação, encerramentos e mensagens operacionais completas.
Os modelos locais de `fim_de_fase()` e `fim_da_fase_2()` estão no pacote;
presença no pacote não equivale a leitura aprovada.

Foram usados `Narrativa.gd`, `VidaDoPorto.gd`, `PainelLojas.gd`, convite do
`PainelBoletim.gd`, conexão de história no `Main.gd`, gatilhos da narradora e
funções de capítulos, compra, cancelamento e reputação do `GameState.gd`, além
da regra de narrativa, guia de vozes e revisão anterior. Referências são às
linhas da árvore e hashes registrados, não a um export publicado.

Não houve novo playtest, medição de frequência ou captura nesta rodada.
Naturalidade é julgamento editorial; os riscos apontados não são defeitos
de cobrança demonstrados. As capturas anteriores da chave/almoço continuam
válidas para aqueles textos, mas não provam o encaixe das candidatas novas.
Nenhuma fala ou mecânica foi alterada por este parecer.
