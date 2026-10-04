# BR Port — prompt para a próxima conversa (depois do rodapé escuro)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 04/10. A sessão de 04/10, no Claude Code,
trabalhou na branch `claude/happy-meitner-fggj5d`, a partir da `main` com o PR
#103 fundido, e não abriu PR. Fez a **primeira parte da melhoria de design**,
o HUD e os painéis (`081`):

1. **O rodapé é escuro, e só o «AVANÇAR DIA» é âmbar cheio.** O botão
   desligado, a faixa de mensagem e o cartão da parcela mediam 13 a 18:1
   contra o fundo, mais do que o primário (7,38); hoje medem ~1,2. A linha da
   parcela diz o valor de HOJE, o mesmo da tarja do painel, e aparece onde a
   porta abre.
2. **Os trabalhadores ocupam as colunas das docas**, em cartão escuro com o
   retrato numa placa clara; a coluna sem trabalhador mostra a vaga («chega
   com o píer»). O selo «Escolhido» passou ao âmbar de marca.
3. **O Construir veste as famílias de 25/09**: cabeçalho com selo, tarja com o
   dinheiro e o nível, uma linha por estrutura com o botão compacto, e as
   construídas no fim. E o «—» saiu das docas sem barco.
4. **As guardas**: o **D43** (novo) e o D12, D19, D32 e D41 reescritos; dez
   defeitos injetados, cada um reprovado na guarda certa. As seis suítes, a
   cobertura dos painéis, as guardas do CI e o escopo de cor passaram.

**Aceite do Bruno no fecho**, sobre a prancha da `main` contra a segunda
passagem, sem nenhum dos três ajustes oferecidos.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se a branch `claude/happy-meitner-fggj5d` virou PR e se
  foi fundida.** Se não foi, a `main` não tem o rodapé escuro. Arquivos
  tocados: o tema, o `Main.tscn`/`Main.gd`, o cartão do trabalhador e a vaga,
  o `UpgradePanel.gd`, o `DocaCartao.gd`, o `teste_design.gd`, o
  `teste_fumaca.gd`, a folha dos trabalhadores, o `CLAUDE.md`, a `/arte`, o
  plano, o estado e a `081`. Se a tarefa tocar neles, diga-o ao Bruno antes de
  editar.
- Veja os PRs abertos. A próxima decisão livre é a `082`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, a melhoria
de design continua pela pergunta do ESCOPO das partes que faltam**: o mapa e
os props, as telas narrativas, ou o design de jogo, com a recomendada
primeiro e dizendo porquê (`/arte`, §8). Não escolha por ele.

Ficam em aberto, atrás dela:

- **A cobertura do `teste_design` depende do save no disco**: o D14 conferiu
  179 casas com o porto completo e 77 em ruínas. A suíte devia montar o estado
  que quer.
- **A máquina do contêiner**, no nível 3.
- **A frente 5**: as obras e mais de um trabalhador por píer. Mexe no
  `GameState`, no balanceamento e no `SAVE_VERSION` — e nas colunas dos
  trabalhadores, que hoje são as três das docas.

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Um `Label` com quebra automática ao lado de uma coluna que expande fica
  com largura quase zero, e a palavra desenha-se por cima do vizinho; passou
  duas vezes com as suítes verdes (`CLAUDE.md`, «Interface»; `081`).
- ⚠️ O estado desligado escolhe-se contra o fundo onde o botão vive, e a
  hierarquia mede-se: o D43 exige que nada do rodapé que não seja o primário
  passe o contraste dele (`CLAUDE.md`, «Interface»; `081`).
- ⚠️ O `_main` do `teste_design` herda o save da ferramenta anterior, e a
  cobertura das guardas que o leem muda com isso (`CLAUDE.md`, regra 6;
  `081`).
- ⚠️ «Tentar novamente» é o mesmo sinal que «Mande pergunta»; e um «Ajustar»
  com «veja pontos de melhoria e faça» é licença para ir além das opções e
  mostrar no fim (`/arte`, §8).
