# 060 — Uma tela não é uma cara: a cobertura desce ao retrato

**24/09/2026 · item do briefing `24f`, «os tiros das caras sem foto».** Os
retratos de fala são nove — a Dona Cida séria, preocupada e contente; o Arlindo
a sorrir, na pressão e contrariado; o Sr. Ribeiro cordial, formal e grave —, e
a cobertura das capturas perguntava por PAINEL (`039`) e por TEMPO (`051`),
nunca por cara. O boletim é um painel de um tempo só, e a cara sai do TOM da
semana: a bateria mostrava a séria e dava-o por fotografado.

## O que se decidiu

1. **As duas ferramentas de captura imprimem `Retratos: <arquivo>`**, uma linha
   por cara do painel de CIMA (o de baixo fica atrás do escurecer e do cartão).
   A linha só sai depois de uma prova nos pixels (`tools/caras_na_foto.gd`),
   com três fotos: a que se grava; a mesma cena dois frames depois, sem mexer
   em nada — o RUÍDO, que na janela da cara tem de dar zero exato —; e a cena
   com as caras escondidas. Os pixels que mudam são a cara, e o mínimo é
   **4.695**, a meio entre o defeito (zero) e a menor cara medida (9.390).
2. **Quem é cara é o nome do arquivo (`retrato_*`), e não o registo.** O
   catálogo sai do `Retratos.gd`; se a ferramenta também lesse de lá, as duas
   fontes seriam uma. A convenção só falha para o lado vermelho.
3. **O `conferir_cobertura_paineis.py` lê o `POR_EXPRESSAO`** por chavetas
   equilibradas e exige cada cara nalgum log. Valor que não seja uma constante
   `preload` do mesmo arquivo reprova, dois nomes para um arquivo reprovam, e
   cara na foto que o registo não tem também — é um painel a carregar retrato
   por fora do ponto único.
4. **Três tiros, cada um pela porta do jogador**, e nenhum declara a cara — quem
   a diz é o log:
   - `boletim_ruim` — `ocioso`, o jogador que nunca aloca: o porto em ruínas
     fecha a semana 1 com **R$16.000 de prejuízo** (`primeira_ruim`, a
     preocupada). Turno 9.
   - `boletim_otimo` — `completo --boletim=2`: a semana 2 lucra **60%** mais do
     que a 1 (`otimo`, a contente). Turno 17.
   - `contraoferta_pressao` — `aposta=recusada` e «Manter»: a aposta falha e
     vem a última tentativa (a pressão). Tempo `rodada`.
5. **Três bandeiras, e cada uma prova que obteve o estado:** `ocioso` exige
   zero barcos servidos; `--boletim=N` exige o boletim da semana N sozinho por
   cima (a semana vem do resumo que o painel recebeu); `aposta=recusada`
   semeia o `_rng` justo antes do toque com a primeira semente cujo primeiro
   sorteio recusa a MAIOR das duas chances — o dado, não o resultado, que
   continua a sair do `negotiate_rival()`. Bandeiras que se desmentem
   (`ocioso alocar`, `limpo --boletim=`) reprovam.

## A medição

| | antes | depois |
|---|---:|---:|
| caras com foto | **6** de 9 | **9** de 9 |
| tiros | 32 | **35** |
| fotos antigas contra a `main` | — | **32 idênticas** byte a byte |
| duas corridas da bateria | — | **35 idênticas** byte a byte |
| ruído na janela de cada cara | — | **0** nas nove |
| pixels que cada cara muda | — | 9.390 (Cida preocupada) a 12.463 (Ribeiro cordial) |

## ⚠️ O que as medições mostraram

### A formal do Sr. Ribeiro já tinha foto

O briefing contava quatro caras sem foto, e eram três. A entrada do Sr. Ribeiro
mostra a cara de quem ACABOU de dizer o valor — `a_divida`, a formal —, e a
cordial só volta no segundo tempo. Quem lê pelo nome do tempo («entrada» soa a
cordial) conta errado; a linha `Retratos:` lê o nó.

### O porto completo não fecha a semana no vermelho sem ninguém a trabalhar

`completo ocioso` deu a séria: o aluguel dos píeres paga salários e manutenção.
Só o porto em ruínas chega à preocupada de quem não aloca — que é, de resto,
onde o principiante está.

### A contente pede histórico, e o porto em ruínas demora a chegar

O `otimo` compara com a média das semanas de antes: nunca é a semana 1. Com a
semente da bateria o porto completo chega a ele na semana 2 e o porto em ruínas
só na 3.

### A derivação do dado não é quem segura com a semente da bateria

Tirar a semeadura (T9) PASSOU: a semente fixa da ferramenta já calha numa
recusa. Medido com seis sementes: **sem** a derivação duas aceitavam a aposta e
o tiro ficava vermelho pelo `--tempo=rodada`; **com** ela as seis mostram a
pressão. Ela existe para o tiro não depender da sorte, e o comentário ao lado
diz que o mutante dela passa com esta semente.

### Um defeito latente no conferidor

Sem log nenhum, `cenas_fotografadas()` devolvia `0` onde se esperava um
conjunto, e o conferidor rebentava com `TypeError` em vez de dizer a frase que
tinha escrito. Reprovava na mesma — com pilha em vez de causa. Corrigido.

## Os mutantes

Cada um sozinho, originais por `cp`, base verde entre cada, código de saída
lido sem cano.

**O conferidor**, contra os logs da bateria:

| # | defeito | o que reprovou |
|---|---|---|
| C1 | o tiro da contente não existe | «a cara «cida/contente» não aparece em fotografia nenhuma». **O conferidor antigo passa** (`COBERTURA OK`) |
| C2 | `"seria": Retratos.CIDA_SERIA` | «entrada que esta ferramenta não sabe ler» |
| C3 | um log mostra `retrato_cida_zangada.png` | «que o POR_EXPRESSAO não registra» |
| C4 | o rótulo muda para `Caras:` | «nenhum log traz a linha `Retratos:`», e as nove |
| C5 | a tabela muda de nome | «não achei a tabela `POR_EXPRESSAO`» |
| C6 | a preocupada aponta para o PNG da séria | «apontam para o mesmo» |
| C7 | linha `Retratos:` sem arquivo | «linha que não se lê» |
| C8 | duas caras numa linha | «não sabe ler» |
| C9 | catálogo vazio | «não tem cara nenhuma», e as nove fora do registo |

**As ferramentas**, tiro a tiro:

| # | defeito | o que reprovou |
|---|---|---|
| T1 | a cara escondida na foto (`self_modulate.a = 0`) | «não chegou à foto: **0 px**» — nas duas ferramentas |
| T1c | *controle:* T1 sem o mínimo de pixels | **VERDE**, a publicar a cara com 0 px — quem segura é a prova |
| T2 | a cara pisca num tween em laço | «mexe-se sozinha (12.290 px sem esconder nada)» |
| T5 | o `ocioso` aloca na mesma | «`ocioso` e a partida serviu 6 barco(s)» |
| T5c | T5 sem essa guarda | verde no tiro, com a SÉRIA — e o conferidor reprova a preocupada. A guarda do tiro nomeia a causa |
| T6 | o `--boletim=` fecha também o da semana pedida | «a tela tem 0 painel(eis)» |
| T7 | o `--boletim=` não fecha os de antes | «o de cima … (semana 1)» |
| T8 | a semente derivada ACEITA a aposta | «esperava o tempo «rodada» e o painel está em «despedida»» |
| T9 | sem semear o dado | **VERDE** com esta semente — ver acima |

## O que fica de fora

- **A cobertura é por CARA, não por fala.** A séria vem do `neutro` e do
  `ruim_ribeiro`; só o primeiro tem foto. Fala nova que peça uma cara já
  fotografada não pede tiro.
- **A despedida de quem venceu o Arlindo** continua sem foto (`051`): a cara é
  o sorriso, que a abertura cobre.
- **O painel de baixo não conta**, e nenhuma foto de hoje tem dois com cara.
- **Uma cara com `visible = false` não é procurada** — some da contagem, e o
  conferidor reprova pelo lado seguro se for a única foto dela.
- **Nenhum telefone foi olhado.** As três fotos novas vão ao A5.
