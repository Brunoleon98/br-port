# BR Port — prompt para a próxima conversa (depois da virada do dia)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 03/10. A sessão de 03/10 (tarde), no Claude
Code, trabalhou na branch `claude/dazzling-ritchie-gpdfka`, a partir da
`main` com o PR #100 fundido. Fechou **a transição entre turnos**, a outra
metade do item 4 (`078`):

1. **Ao tocar em «Avançar dia», o barco servido parte**: sai pela faixa do
   berço, ao longo do píer, de proa para o mar, e só então o seguinte entra
   de ré pelo mesmo lado. 0,8 s cada, opaco a não ser na ponta de fora.
2. **O dinheiro conta** do valor antigo ao novo em 1,2 s, e o cartão da
   parcela conta junto. Só o botão arma a contagem.
3. **O que cada doca rendeu sobe do barco** como «+R$», no verde do dinheiro,
   com contorno navy.
4. **Um toque a meio acaba a virada** e vira o dia seguinte.
5. **O `GameState` não mudou uma linha**: é a tela a alcançar o estado.
6. **No jogo:**
   - as seis suítes estão verdes, e o **D41** reprovou os oito defeitos
     injetados;
   - a bateria dá `COBERTURA OK`, com um tiro novo, o `virada`; as outras
     fotos saem iguais às de antes;
   - o `.pck` cresceu 3.424 bytes contra a `main` (+0,024% do `.pck`).

Teve dois GIFs: o primeiro voltou «Ajustar» com quatro defeitos, o segundo
«Aceito». A branch virou o PR #101.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #101 (`claude/dazzling-ritchie-gpdfka`) foi
  fundido.** Se não foi, a `main` ainda não tem a virada. Arquivos tocados:
  - `brport_vs/scripts/Dock.gd` e `brport_vs/scripts/Main.gd` (a troca de
    barco, a contagem e o «+R$»);
  - `brport_vs/scenes/Main.tscn` (a camada `MapaWrap/Ganhos`) e
    `brport_vs/ui/tema_brport.tres` (a variação `GanhoNoMapa`);
  - o D41 do `teste_design.gd`;
  - `brport_vs/tools/capturar_tela.gd`, `tools/capturar_evidencia.sh` e
    `tools/trilha_de_arte.py`.

  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `079`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha.** Em aberto, para ele escolher:

- **O degrau 3:** pallets e empilhadeira no nível 3. A empilhadeira do pátio
  está fora da régua da pessoa (47 px de altura, contra 37 do camião). O
  contêiner do nível 2 fica na pilha à espera dele.
- **A frente 5**, o rumo além do VS: as obras e mais de um trabalhador por
  píer. Mexe no `GameState`, no balanceamento e no `SAVE_VERSION`, e é
  decisão de rumo.

Família nova de arte começa por perguntar o ESCOPO, com opções e a
recomendação primeiro (`/arte`, §8).

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Código que nunca correu esconde o defeito dele: a chegada deslizante do
  barco estava escrita e não disparava (0 de 21), e o rumo dela atravessava
  o píer (`CLAUDE.md`, «Arte», ao lado da regra do estado que não existe;
  `078`).
- ⚠️ A pergunta ao Bruno que descreve o estado de hoje mede-o antes: a de
  escopo dizia que o barco já deslizava (`/arte`, §8; `078`).
- ⚠️ Opções de ajuste com a correção escrita na descrição: ele marcou as
  quatro, e a passagem seguinte foi aceite; a de várias saídas foi uma
  pergunta sozinha com prévia em ASCII (`/arte`, §8).
- ⚠️ O «+R$» é a exceção registada a «nada de interface pousa sobre o
  mapa»: dura 1,2 s e não recebe toque (`CLAUDE.md`, «Interface»; `078`).
- ⚠️ A captura conclui a virada antes da foto, como um segundo toque, e só o
  tiro `virada` a mostra a meio; concluída, a foto do `porto` deu o mesmo
  md5 de antes (`brport_vs/tools/capturar_tela.gd`,
  `tools/capturar_evidencia.sh`; `078`).
- ⚠️ A primeira vista animada passou verde enquanto o teste alocava antes de
  abrir: quem aloca encosta o barco, e era essa guarda que segurava a
  asserção (`brport_vs/tests/teste_design.gd`, D41; `CLAUDE.md`, regra 7).
- ⚠️ Um sub-bloco sem bandeira abortou e a suíte disse `DESIGN OK`: cada
  sub-bloco do D41 tem a sua (`brport_vs/tests/teste_design.gd`, D41;
  `CLAUDE.md`, «Estilo de código»).
- ⚠️ A ferramenta e a suíte partilham `user://ferramentas/`: não corra a
  bateria de capturas em paralelo com as suítes (`CLAUDE.md`, «Como rodar,
  aqui dentro»).
