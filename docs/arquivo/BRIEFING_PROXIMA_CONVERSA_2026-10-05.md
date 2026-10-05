# BR Port — prompt para a próxima conversa (depois da fila no fundeadouro)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 04/10 `c`. A sessão de 04–05/10, no Claude Code,
trabalhou na branch `claude/brave-bell-xwg7h5`, a partir da `main` com o PR
#105 fundido, e o **PR #106** foi aberto no fecho. Fez a **terceira parte da
melhoria de design**, o design de jogo: a fila no fundeadouro (`083`).

1. **Atracar passa a ser a escolha.** Os barcos esperam ao largo — três
   lugares, dois dias de paciência —, e tocar num atraca-o no primeiro berço
   livre com o trabalhador do píer. O que não for chamado vai embora e custa
   reputação; a oferta do Arlindo cai no barco que chega. Saíram o «Alocar
   todos», a fileira dos trabalhadores, a seleção e o arrasto. `SAVE_VERSION`
   10.
2. **O balanceamento voltou ao alvo pelos contratos.** A fila facilitava (o
   controle deu 100 / 100 / 55,8); as faixas de contrato a 0,72 dão **100 /
   78,7 / 41,5**, com a parcela em R$530.000 por escolha do Bruno. O projetor
   das parcelas passou a multiplicar pelo `premio_da_escolha` medido.
3. **A tela** levou quatro passagens: os cartões «Ao largo» com os cascos na
   mesma escala, o retrato do trabalhador a 52 px no cartão da doca, os
   textos reescritos («Doca 1 livre — escolha quem atraca», «parte amanhã»,
   «aguarda mais 1 dia», «vai embora hoje»), a vaga tracejada, e o 3.º barco
   no mapa, acima e à direita.
4. **As guardas**: T4d, T5h, o F3 da fila, o D9 reescrito, o D18 a medir as
   funções dos cartões; onze defeitos injetados, cada um reprovado na guarda
   certa — um deles só depois de a guarda ser refeita (`083`). As seis
   suítes, a cobertura dos painéis, as guardas do CI e o escopo de cor
   passaram.

**Aceite do Bruno no fecho**, na quarta passagem.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #106 foi fundido.** Se não foi, a `main` não tem
  a fila. Arquivos tocados: o
  `GameState.gd`, o `Main.gd` e o `Main.tscn`, o `DocaCartao`, o `Dock.gd`, o
  `BarcoFila` (novo, em `scenes/fila/`), o `CounterOfferPanel.gd`, o
  `Registro.gd`, o tema, o simulador e o projetor, as ferramentas de captura
  e de gravação, as quatro suítes de lógica, o `contraste_ui.gd`, o
  `CLAUDE.md`, a `/arte`, a `/balancear`, o plano, o estado e a `083`. Se a
  tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `084`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, a melhoria
de design continua pela pergunta do ESCOPO do que falta**: o mapa e os props
(o mar aberto à direita, a máquina do contêiner do nível 3, os três guindastes
sobrepostos), ou outra parte do design de jogo, com a recomendada primeiro e
dizendo porquê (`/arte`, §8). Não escolha por ele.

Ficam em aberto, atrás dela:

- **O barco a deslizar do fundeadouro ao berço** — o alcance que o Bruno
  deixou para a passagem seguinte da fila (`083`).
- **A cobertura do `teste_design` depende do save no disco** (`081`).
- **A frente 5**: as obras e mais de um trabalhador por píer.

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4) — agora também os da fila e da doca
  (`083`);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Trocar o verbo do jogo deixa os laços que jogam a jogar nada, verdes:
  quem joga conta o que jogou, e quem reconhece um painel pelo nome de uma
  propriedade perde-o quando ela muda (`CLAUDE.md`, «Estilo de código»).
- ⚠️ Com os berços ocupados pelos seus, «a equipe do píer» e «o primeiro
  livre» dão sempre o mesmo; só um trabalhador fora do sítio as separa, e a
  primeira versão da guarda passou com o defeito posto (`083`).
- ⚠️ O formato de um texto também não se copia para o teste: os cartões
  escrevem por funções que o D18 chama (`CLAUDE.md`, «Interface»; `083`).
- ⚠️ A varredura automática restaura de uma cópia pristina tirada uma vez, e
  confere-a ANTES de cada corrida (`/balancear`, §3).
- ⚠️ Chegada e paciência não movem a linha; com a fila, quem move os dois
  perfis são os contratos (`/balancear`, §3; `083`).
- ⚠️ Sem a segunda pergunta, a das opções que você vê na prancha, o
  «Ajustar» chega vazio (`/arte`, §8).
- ⚠️ `pgrep -f <padrão>` num laço de espera casa o próprio shell e nunca
  acaba (`CLAUDE.md`, «Como rodar, aqui dentro»).
