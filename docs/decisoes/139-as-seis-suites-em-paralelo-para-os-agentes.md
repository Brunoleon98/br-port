# 139 — As seis suítes em paralelo para os agentes

**24/10/2026, na conversa da `138`.** Fechadas as lacunas, o Bruno perguntou
se os testes ficavam mais rápidos depois do PR; não ficam — a `138`
acrescenta prova —, e das duas opções que a `137` deixou de fora a
recomendação foi esta, e não a outra. Ele: *«pode fazer isso depois de
terminar as atividades ainda pendentes»*.

## O que se escolheu, e o que não

- **As seis suítes ao mesmo tempo, cada uma com o seu `user://`:**
  `python3 tools/correr_suites.py --godot "$G"`, que espera `SUITES OK`. A
  `137` tinha medido 118 → 56 s; hoje, emparelhado e em duas voltas, **99,3 e
  102,8 s em série contra 53 e 50 s** — metade do tempo de cada vez que um
  agente corre o fecho.
- **Parar a suíte quando a guarda declarada reprova (−24% por mutante) não
  entrou.** No CI os mutantes deixaram de ser o caminho crítico do PR, que
  hoje é a «Evidência visual»; no contêiner pouparia ~7 min por catálogo
  inteiro; e mexia no executor — ler a saída enquanto corre e matar o Godot
  a meio —, além de tirar ao `--explorar` a lista completa do que reprovou.

## Como, e por que é seguro

- **A lista e o marcador de cada suíte são os do executor de mutantes**
  (`SUITES`, `MOTOR`), que os confere contra o `testes.yml` antes de correr
  (`032`). O atalho não tem lista própria.
- **O julgamento é o do CI:** o código de saída, o marcador e nenhum `SCRIPT
  ERROR` nem `at: push_error (`.
- **Cada suíte tem o seu `user://`, numa pasta que começa vazia** — a mesma
  condição do executor de mutantes. Partilhado, era o defeito da `069`. No
  CI elas continuam em série, e uma dependência de ordem entre suítes
  continua a ser dele apanhar.
- **O tempo de cada suíte é o do fim dela.** A primeira versão media até à
  vez de ser esperada, e o `teste_audio` de meio segundo saiu com os 50 s do
  `teste_design` que vinha antes — apanhado na primeira corrida de verdade.

## O defeito injetado

O `--autoteste` faz de Godot com um motor falso, em segundos, e o CI corre-o
(`ATALHO PROVADO`, ao lado do autoteste do executor): as seis verdes dão
`SUITES OK`; a suíte sem marcador, a que sai com 1 e a que imprime `SCRIPT
ERROR` reprovam. E cada defeito que o atalho podia ter é reinjetado por
troca de função — o código de saída ignorado, o marcador não conferido, o
`SCRIPT ERROR` não conferido e o `user://` partilhado —, e o caso que o vê
dá o contrário do que espera. A primeira versão do autoteste comparava ao
contrário e deu os três primeiros por «não vistos»: foi a prova de que a
troca de função muda mesmo o resultado.

## As receitas

O `CLAUDE.md` (o bloco «Como rodar»), o `AGENTS.md`, o `/fechar-sessao`, o
`/balancear` e o hook de arranque passaram a apontar para o atalho; o
`CLAUDE.md` ficou mais curto, com uma linha de exemplo para correr uma suíte
só. O hook só vale a partir da `main`.
