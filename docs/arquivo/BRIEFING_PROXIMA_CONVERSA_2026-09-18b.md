# BR Port — prompt para a próxima conversa (A4 + R5)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
anexe este arquivo. Não é preciso anexar o histórico da conversa anterior.

**São DUAS atividades, e a ordem entre elas importa** — a primeira é do Bruno e
leva minutos; a segunda é uma sessão inteira. A razão de não as trocar está
escrita na §2.

**Modelo:** a A4 não precisa de decidir nada de código e corre em **Sonnet**.
O R5 abre em F1 e pede **Opus**. Se for fazer as duas na mesma conversa, comece
em Sonnet e anuncie a subida antes de entrar no R5.

**Situação da entrega anterior:** o **R4 fechou** no PR #58, fundido, com os
três checks verdes — incluindo o simulador de 600 partidas por perfil e a
bateria das 16 capturas. `docs/decisoes/033`.

⚠️ **E A BRANCH JÁ ESTÁ NA MAIN, desta vez.** A regra do `CLAUDE.md` — *"PR
fundido não quer dizer branch fundida"* — continua a valer e é por isso que
está escrito aqui: `claude/practical-hawking-yodqtg` foi avançada para
`origin/main` (`398b8b3`) no fim da sessão, e `git log --oneline
origin/main..HEAD` saiu **vazio**. Confira na mesma antes de reapontar; o que
se poupa é a dúvida, não a conferência.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o que há de local contra o
  remoto **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`, que é a fila em vigor.
  Para o R5, a origem é `docs/REVISAO_GERAL_2026-09-17.md` **§2.2**, e o que a
  sessão do R4 já mediu está em `docs/decisoes/033`.
- ⚠️ **O teto do `ESTADO_DO_PROJETO.md` subiu para 28.000 em 18/09**, por
  decisão do Bruno e ao terceiro toque; ele está em **26.863 bytes**, com
  ~1.100 de folga. A ordem escrita continua a valer — histórico desce,
  duplicação vira ponteiro, e só então se sobe o teto outra vez.
- ⚠️ **E o `tools/conferir_docs.py` reprova mais do que referências partidas.**
  Ele confere as suítes contra o `testes.yml`, os mapas contra o comando, uma
  contagem de partidas que o comando não roda, e um segundo endereço para as
  taxas do balanceamento. Rode-o antes de se surpreender no CI.

---

## 2. Atividade A — a leitura em voz alta (gate A4). **Faça esta primeira.**

**Por que primeira:** o R5 mexe em COMO estas mesmas linhas aparecem, e vai
medir quantas delas o jogador lê. Se um texto mudar a meio do R5, a medição
move-se por baixo dele. Ler antes custa minutos; ler depois custa a medição.

O R4 pôs cinco falas novas ou mudadas no jogo. **Duas o Bruno já escolheu; três
são propostas por aprovar.** Um predicado verde não aprova uma frase — é o que
o `CLAUDE.md` regista sobre *"porto que fecha no azul abre segunda-feira"*,
apanhada à segunda frase da primeira leitura em voz alta.

| Fala | Quando dispara | Texto |
|---|---|---|
| `upgrade_pronto` | ao comprar qualquer estrutura | *"Zezão terminou. Ficou bom — e olha que eu duvidei."* (escolhida) |
| `semana_nova_fila_curto` | vira a semana, com barco à espera e caixa abaixo de meia parcela | *"Semana nova. Barcos na fila, caixa no limite. Dia típico."* (escolhida) |
| `semana_nova_fila_folgado` | vira a semana, barco à espera, caixa folgado | *"Semana nova. Barcos na fila e dinheiro no caixa. Aproveita."* (escolhida) |
| `semana_nova_parado_curto` | vira a semana, cais vazio, caixa curto | *"Semana nova. Cais parado e a parcela correndo. Não gosto disso."* (escolhida) |
| `semana_nova_parado_folgado` | vira a semana, cais vazio, caixa folgado | *"Semana nova. Tudo quieto por enquanto, chefia."* (escolhida) |
| `caixa_baixo_quitado` | o caixa cruza para baixo de meia parcela **com a parcela já paga** | *"Caixa raspando, chefia. Ao menos o Sr. Ribeiro já tá pago."* — **PROPOSTA** |
| `arlindo_primeira` | a PRIMEIRA oferta do rival, antes de existir qualquer recusa | *"O Porto Farol tá de olho no que passa por aqui, chefia."* — **PROPOSTA** |

**Como conduzir:** apresente uma fala de cada vez, com o estado em que ela sai,
e espere a reação. Não agrupe — a lista inteira de uma vez é o que faz uma
leitura virar aprovação por cansaço. O texto vive em `scripts/Narrativa.gd`,
tabela `CIDA_LINHAS`; a expressão de cada uma vive na tabela `EXPRESSOES`, no
mesmo arquivo, e **fala nova sem cara reprova o bloco F7 do `teste_fumaca`**.

⚠️ **E RELER O QUE MUDOU DESDE 13/09 É PARTE DESTE GATE.** A primeira leitura
aconteceu nesse dia e as sete notas dela estão fechadas; o que entrou depois
nunca foi lido em voz alta. O `ESTADO_DO_PROJETO.md` regista isto na linha do
A4.

Se o Bruno trocar um texto: mexa só na `CIDA_LINHAS`, rode as seis suítes, e
**refaça a bateria de capturas** — cinco delas mostram a faixa de mensagem, e
uma fala nova muda a foto.

---

## 3. Atividade B — o R5 da §7.1: a fila de mensagens

O que a §7.1 promete, na íntegra:

> **R5 — fila não é troca de ordem.** Registrar as duas fontes e arbitrar a
> prévia, sem copiar do áudio o descarte de perdedores. FIFO comum, prioridade
> para a próxima apresentação e coalescência apenas por duplicata semântica;
> mensagens diferentes da mesma compra não se fundem. Recuperação em memória
> da sessão, sem migrar save. Medir onde cabe consultar o histórico; não ocupar
> o mapa nem escolher o retrato do rodapé ainda pendente do Bruno. Retenção e
> tempo de exibição precisam de F1: velocidade de leitura focada não prova
> leitura incidental mobile. Mutantes: perder a segunda entrada, interromper a
> atual antes do mínimo, agrupar textos diferentes. Gate: texto recuperável,
> legível e toque mínimo de 44 px na convenção do projeto.

### O que o R4 já mediu, e que o R5 herda

⚠️ **Isto é medição, não previsão** — mas foi medida no commit `1bf0ea8`.
Reconfira no seu HEAD antes de agir.

**O problema que o R4 resolveu:** o sinal narrativo saía uma linha ANTES do
`message.emit` da mesma chamada, e os dois escreviam no mesmo `Label`. Hoje o
`_cida()` escreve por `call_deferred`, de modo que a fala entra no fim do frame
— **e o preço é o inverso: agora é a mensagem do SISTEMA que fica por baixo.**
Mostrar as duas é exatamente o que o R5 existe para fazer.

**O que continua invisível, e por outra razão.** Medido em cinco sementes,
partidas inteiras, depois da correção:

| fala | vista | por que não |
|---|---|---|
| `caixa_baixo` | 0 | perde para outra fala da Cida escrita DEPOIS dela na mesma ação |
| `caixa_baixo_quitado` | 0 | idem |
| `reputacao_caiu` | 0 | idem |
| `reputacao_subiu` | 6 | idem, em parte |
| `bom_contrato` | 37 | idem, em parte |
| `upgrade_pronto` | 33 | — |
| `semana_nova` (4 variantes) | 15 | — |
| `arlindo_*` (2 variantes) | 42 | — |

**Uma só pressão de "Avançar dia" pode escrever no `Label` até CINCO vezes**, e
o jogador vê a última. A ordem real dentro de `advance_turn()`:
`contrato_fechado` (por barco servido) → `cash_changed` → o fecho da semana
(`cash_changed` + `message`) → `semana_fechada` (abre o Boletim) →
`turn_advanced` → `_check_end()` → `_spawn_boats()` → `rival_offer_triggered`.

### O que é F1 nesta sessão, e não se decide sozinho

- **Retenção e tempo de exibição.** A §7.1 diz com todas as letras que precisam
  de F1, e diz porquê: *"velocidade de leitura focada não prova leitura
  incidental mobile"*. Não herde um número de outro projeto; desenhe a medição.
- **A prioridade entre as duas fontes.** Hoje quem chega por último ganha. FIFO
  puro entrega a mensagem do sistema primeiro e a fala depois; prioridade pela
  próxima apresentação entrega outra coisa. É decisão, e a medição acima é o
  ponto de partida dela.
- **Onde cabe consultar o histórico.** A §7.1 proíbe ocupar o mapa e proíbe
  escolher o retrato do rodapé, que continua pendente do Bruno.

### Armadilhas que o R4 mediu e que mordem aqui

- ⚠️ **`await process_frame` RETOMA ANTES DO FLUSH DA FILA ADIADA.** Ele volta
  no início do frame seguinte, e o que foi posto em `call_deferred` naquele
  frame ainda não correu. **São dois `await`**, e está escrito no `CLAUDE.md`
  com a medição ao lado. A régua de medição do R4 caiu neste buraco e devolveu
  **zero em todas as falas** — que se lê como "não acontece nada".
- ⚠️ **RÉGUA NOVA QUE DEVOLVE ZERO EM TUDO pergunta-se primeiro se consegue
  devolver outra coisa.** É a irmã de *"receita derivada que não casa nada dá um
  verde de graça"*, com frames no lugar do `grep`.
- ⚠️ **`_process` de um `SceneTree` que devolve `true` mata a árvore no fim do
  frame**, e o `await` nunca volta: a suíte imprime o marcador com o bloco
  inteiro por correr. O `teste_fumaca` já devolve `false`; quem escrever
  ferramenta nova precisa de saber.
- ⚠️ **TELA NOVA É OVERLAY, NUNCA FASE DO `GameState`.** Uma fase a mais fez 24
  de 30 partidas não terminarem, e o CI passava. Se o histórico de mensagens
  virar uma tela, ela é overlay — e o balanceamento medido fica intocado por
  construção, não por cuidado.
- ⚠️ **O PREDICADO DE UMA FALA LÊ-SE ONDE ELA É ESCRITA.** Se a fila adiar a
  apresentação, o que a fala AFIRMA pode deixar de ser verdade quando ela
  aparece. Medido no R4: `docas_esperando()` dá zero no instante do
  `turn_advanced` e barco à espera em 148 de 310 um instante depois. **Uma fila
  que atrase a apresentação tem de responder por isto** — é o defeito que o R4
  acabou de fechar, do outro lado.

### Prova mínima

O bloco **F8** do `teste_fumaca.gd` já pergunta *"a fala foi VISTA?"* e tem seis
mutantes. O R5 herda-o e tem de o manter verde **com outro significado**: hoje
"vista" é "sobrou no `Label`"; com fila, é "chegou a ser apresentada". Se a
definição mudar, a guarda muda com ela — e o defeito injetado também.

Os mutantes que a §7.1 nomeia, cada um separado e com controle positivo verde
entre eles: **perder a segunda entrada**; **interromper a atual antes do
mínimo**; **agrupar textos diferentes**.

### Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`. A recuperação é **em memória da sessão**: a §7.1
  diz "sem migrar save", e isso quer dizer que o `SAVE_VERSION` não se toca.
- Não ocupe o mapa, e não escolha o retrato do rodapé — é do Bruno.
- Não mexa em gerador cuja saída o CI compara byte a byte para calar uma falha.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 4. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. Atualize a §7.1 só até a fase comprovada,
e o `ESTADO_DO_PROJETO.md` dentro do teto.

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner" — e o export do APK, que este
contêiner não consegue medir, só corre a partir daí. O PR só se abre a pedido.
