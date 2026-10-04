# BR Port — prompt para a próxima conversa (depois das telas narrativas)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 04/10 `b`. A sessão de 04/10, no Claude Code,
trabalhou na branch `claude/compassionate-bardeen-ujk7my`, a partir da `main`
com o PR #104 fundido, e o **PR #105** foi aberto no fecho. Fez a **segunda
parte da melhoria de design**, as telas narrativas (`082`):

1. **As conversas falam como no celular.** O Sr. Ribeiro, o Arlindo e a Dona
   Cida no boletim têm o balão da pessoa (os tons do celular), o retrato numa
   placa do mesmo matiz, a fala longa partida em balões seguidos, um rabicho
   a apontar para a cara e a fala em Open Sans Regular (`ui/fontes/`). O
   celular ficou no seminegrito, a pedido do Bruno. O título do Arlindo é
   «Arlindo — Porto Farol».
2. **O fim da Fase 1 é uma entrada do diário** em duas páginas, «Porto Mirim,
   quarta semana»: o «—» da peça é a virada da folha (a da tela de nomes, que
   passou para o andaime), e a segunda página leva colado o recibo da parcela
   com o carimbo «PAGO». O texto da peça não mudou.
3. **As guardas**: o **D44** (novo), o **D22** reescrito e o F10/F14 pelo
   caminho das duas páginas; dez defeitos injetados, cada um reprovado na
   guarda certa. As seis suítes, a cobertura dos painéis, as guardas do CI e o
   escopo de cor passaram.

**Aceite do Bruno no fecho**: as conversas na segunda passagem, o fim de fase
na terceira.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #105 foi fundido.** Se não foi, a `main` não
  tem as conversas novas nem o diário do fim. Arquivos tocados: o
  `PainelNarrativo.gd`, a `TelaNomes.gd`, o `EndGame.gd`, o
  `CounterOfferPanel.gd`, o `DebtPaymentPanel.gd`, o
  `PainelBoletim.gd`, o `PainelMensagens.gd`, a `FolhaDoCaderno.gd`, a
  `Narrativa.gd`, o tema, as duas ferramentas de captura, o
  `capturar_evidencia.sh`, o `run_tests.gd`, o `teste_design.gd`, o
  `teste_fumaca.gd`, o `CLAUDE.md`, a `/arte`, o plano, o estado e a `082`.
  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `083`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, a melhoria
de design continua pela pergunta do ESCOPO das partes que faltam**: o mapa e
os props, ou o design de jogo, com a recomendada primeiro e dizendo porquê
(`/arte`, §8). Não escolha por ele.

Ficam em aberto, atrás dela:

- **A cobertura do `teste_design` depende do save no disco** (`081`).
- **A máquina do contêiner**, no nível 3.
- **A frente 5**: as obras e mais de um trabalhador por píer.

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4) — agora também «Porto Mirim, quarta
  semana», «Virar a página», o recibo e «Arlindo — Porto Farol» (`082`);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Uma função nova na classe base com o nome de uma função de uma filha
  deixa a filha sem compilar, e o `run_tests` imprimiu o marcador verde na
  mesma (`CLAUDE.md`, «Estilo de código»; `082`).
- ⚠️ A letra padrão do Godot tem um peso só, a seminegrita; peso diferente é
  arquivo de fonte numa variação do tema (`CLAUDE.md`, «Interface»; `082`).
- ⚠️ A correção escrita numa opção do veredito é hipótese até ele ver a foto:
  o remate descido ao pé leu-se «isolado», e quem resolveu o vazio foi uma
  peça que diz alguma coisa (`/arte`, §8; `082`).
- ⚠️ Um rótulo com quebra automática pede milhares de pixels ao
  `get_combined_minimum_size()` antes de um passe de layout; a página mede-se
  pela pauta (o comentário do D22 em `brport_vs/tests/teste_design.gd`; `082`).
