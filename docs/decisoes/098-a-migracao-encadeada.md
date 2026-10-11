# 098 — O save sobe por degraus, e a 14 é o piso

**11/10/2026.** Base `7881c28` (o PR #121, o fecho do M8, fundido); 098 livre
conferida na main pelo GitHub, sem PR aberto do Codex. É o **M10** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), destravado no arranque desta sessão
pela resposta do Bruno ao **D5**.

## As duas respostas do Bruno

**D5 — a política de save a partir do primeiro build público: a migração
encadeada** (a recomendada). Cada versão nova traz o degrau que lê a
anterior; um save de exemplo por versão prova os degraus; só é recusado o que
nenhum degrau lê — e a pergunta dizia-o: da 13 para baixo. As outras opções
eram a mesma coisa com a exportação `.brport-save` do GDD (umas duas
sessões, com tela), a recusa até ao A8 e decidir depois.

**D6 — publicar o build Web atual no Pages, no lugar do protótipo: sim.** É o
M11, o seguinte da fila. O CI publica o `brport-web` da `main`; a fonte do
Pages passa a «GitHub Actions», que é configuração do repositório e só o
Bruno a muda. Registado aqui porque foi respondido junto; a decisão do como
é a do M11.

E, para o caso de a fila parar, o recorte da frente 5 que ele escolheu é o
**tutorial curto** — com a pergunta de quem guia, porque o GDD pede o
Toninho, que o jogo não tem.

## O que mudou

**No `GameState`:**

- `SAVE_VERSAO_MINIMA = 14`, o piso, ao lado da `SAVE_VERSION` (também 14).
- `_save_aceite()` confere que a `versao` é um número inteiro e entrega o
  save à **cadeia** antes de qualquer recusa; depois dela, uma pergunta só
  decide a versão: o que sai tem de estar na corrente. Ela recusa as duas
  pontas — o que vem de baixo do piso volta vazio da cadeia, e o que vem do
  futuro atravessa-a sem degrau e chega com a versão dele.
- `cadeia_de_migracao(dados, alvo, passo)`, estática: copia o save uma vez,
  sobe degrau a degrau, escreve ela própria a `versao` de cada degrau e
  devolve `{}` se algum não souber ler.
- `_migrar_um_passo(de, dados)`: os degraus. Nenhum ainda — o primeiro entra
  como `14: return _de_14_para_15(dados)`.

**`tests/saves/v14.json`** — o save de exemplo da 14, gravado pelo jogo.
**`tools/gravar_save_de_exemplo.gd`** grava o da versão corrente: semeia,
joga e pára no primeiro dia em que o save tem tudo o que o `load_game()`
trata à parte (dia 30 — obra do pátio a meio, um barco ao largo e dois
atracados, a primeira parcela quitada, píer 2 e armazém prontos, quatro
semanas fechadas e a quinta a meio, recordes e os dois nomes). Duas corridas
deram o mesmo arquivo ao byte. Não substitui um exemplo existente sem
`--refazer`, e o de uma versão que já chegou à main não se refaz: é o registo
do que ela gravava.

**O F21 do `teste_fumaca`:** um exemplo por versão, do piso à corrente, e
nenhum fora (nem de nome que não seja `vNN.json`); cada um diz a versão do
nome dele e carrega; o porto de um exemplo antigo chega com os dois nomes; o
exemplo corrente traz os campos cheios (a lista é a `faltas()` da ferramenta,
chamada sobre o estado carregado) e **volta igual depois de carregado e
regravado**; e a cadeia, com degraus de mentira.

**Os testes que tratavam «a versão anterior» como recusada** — o F3, o F16 e
o T14 — passam a usar o piso − 1: com a 15, a 14 sobe pela cadeia.

## Porquê assim

**A cadeia corre DENTRO do `_save_aceite()`, antes das recusas.** É o que
mantém «tudo o que recusa vem antes de tudo o que escreve»: ela lê e copia,
não escreve no estado vivo nem no disco, e o que entrega passa por TODAS as
recusas como se a corrente o tivesse gravado. O `resumo_do_espaco()`, que usa
as mesmas recusas, mostra o porto já migrado sem o gravar.

**O piso não se confere no `_save_aceite()`.** Quem recusa a 13 é a cadeia,
que não tem o degrau; uma segunda guarda seria a regra em dois sítios, onde o
defeito numa delas não reprova (`testes-e-guardas.md`). O piso existe para o
F21 saber que exemplos exigir — e o F3 reprova o dia em que alguém escrever o
degrau da 13 sem descer o piso, porque a 13 deixa de ser recusada (medido,
mutante 20).

**A cadeia escreve a `versao`, e não o degrau.** Um degrau que se esquecesse
devolveria um save da 15 a dizer 14, e o degrau seguinte seria outra vez o
14→15.

**Um exemplo JOGADO, e não um dicionário escrito à mão.** O exemplo responde
«o que é que esta versão grava?», e a pergunta nova do F21 — a ida e volta —
só morde num save de verdade e com os campos cheios: com o exemplo pobre, o
`load_game()` podia esquecer a obra e a ida e volta passava (mutante 5).

## Os mutantes

Vinte, cada um aplicado com a contagem conferida e desfeito por cópia com o
hash conferido; o fumaça passou antes, depois dos mutantes da 15 e no fim.

| # | Defeito | Reprova |
|---|---|---|
| 1–3 | o `load_game()` esquece a obra, a semana a meio ou os recordes | a ida e volta e a lista dos campos cheios do F21 — e cada um já tinha guarda noutra suíte: a obra no T15 do `run_tests`, a semana no bloco do autosave dele, os recordes no F15. Nas outras quatro suítes, nada |
| 4 | o exemplo pobre (sem obra) | só a lista dos campos cheios |
| 5 | o exemplo pobre **e** o `load_game()` a esquecer a obra | só a lista: a ida e volta passa, porque não há obra para perder |
| 6 | sobe a 15 sem exemplo nem degrau | falta o exemplo da 15; o da 14 é recusado |
| 7 | sobe a 15 com o exemplo, sem degrau | o da 14 é recusado, e só ele |
| 8 | **sobe a 15 com o exemplo e um degrau** (o controle) | nada — `FUMACA OK` |
| 9 | o 8 sem a chamada da cadeia no `_save_aceite()` | o da 14 é recusado |
| 10 | o 8 com um degrau que perde o nome do cais | o porto da 14 chega sem os dois nomes |
| 11 | **hoje**, sem a chamada da cadeia | **nada** — sem degrau, ela não muda o que o jogo faz |
| 12 | sem a pergunta da versão depois da cadeia | o F3: o save do futuro entra |
| 13 | a cadeia sem a cópia | a origem tocada |
| 14 | a cadeia sem escrever a versão | a versão 14 que ela devia entregar |
| 15 | a cadeia com `<=` | 32 asserções: nenhum save carrega |
| 16 | a cadeia a seguir depois do degrau que recusa | o degrau que não sabe ler |
| 17 | um exemplo da 13 na pasta | o exemplo morto, e a 13 recusada |
| 18 | um `v14.json.bak` na pasta | o nome que não é de exemplo |
| 19 | o `v14.json` regravado a dizer 15 | a versão do nome, e o carregamento |
| 20 | um degrau da 13 sem descer o piso | o F3 e o F16: a 13 deixa de ser recusada |

**O que a ida e volta acrescenta não é nenhum destes três** — é perguntar
por TODOS os campos de uma vez, incluindo o próximo que o `save_game()`
ganhar sem ninguém escrever o bloco dele. **O 11 é o ponto cego, e é sabido:** a chamada da cadeia só tem quem a veja
quando houver um degrau — o 9 prova que, nesse dia, o exemplo da 14 a vê. O
**5** é a razão de o exemplo ser jogado até ter tudo, e de a lista ser
conferida: a ida e volta sozinha só prova os campos que o exemplo traz.
A lista é conferida sobre o estado CARREGADO, e por isso acende também nos
mutantes 1–3; a mensagem dela diz as duas causas.

**A classificação da tabela dos números.** O primeiro comentário do piso
citava «o GDD promete…», e o gerador deu-o como «GDD 7»: basta a palavra. O
comentário foi reescrito e a armadilha está na `economia.md`.

## O que fica de fora

- **A exportação `.brport-save`** que o GDD promete: o Bruno escolheu a
  migração sem ela.
- **Guardar o arquivo original antes do primeiro autosave migrado.** Um degrau
  com defeito que entregue um porto válido mas errado é gravado por cima do
  original no primeiro lance. A cópia seria barata, mas hoje não há degrau,
  e código que nada exercita apodrece; é proposta para a primeira subida, onde
  se pode medir.
- **O save do futuro** (um build mais velho depois de um mais novo) continua
  recusado e apagado ao carregar, como antes. Só o Web volta atrás de versão,
  e só se a publicação recuar.
- **O M9** continua à espera da primeira subida de save (D1b); com a cadeia,
  o `upgrade_purchased` pode sair num degrau em vez de recomeçar a partida.
