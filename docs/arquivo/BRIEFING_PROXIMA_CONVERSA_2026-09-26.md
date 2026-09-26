# BR Port — prompt para a próxima conversa (depois do aceite da família do sistema)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para a primeira mensagem, que é uma escolha do Bruno entre
frentes e o desenho da que ele escolher (F1); o que for receita desce para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `25g`. A sessão de 26/09 trabalhou na branch
`claude/eager-wright-5kh2g8`, a partir da `main` com o PR #89 fundido, e
fechou a **terceira família da frente 3 do A5 — o sistema** —, em quatro
passagens, com o aceite «feche a família» na quarta (`066`). **O PR não foi
aberto** (o Bruno não o pediu), logo o CI ainda não correu sobre este
trabalho.

1. **Tela inicial** como cena principal, com fundo provisório em degradê e o
   nome em texto; **três espaços de save** — o 1 é o `savegame.json` de
   sempre, sem migração, e o `SAVE_VERSION` ficou em 9.
2. **Pausa curta** (Continuar, Ajustes, Salvar e sair) e a tela **Ajustes**
   com o volume e o registro da partida, aberta pelas duas portas.
3. **O celular** com moldura, a hora do aparelho sobre o papel de parede, o
   widget do dia com a fita dos dias, um ícone com cor por app e os fechados
   com um selo de cadeado.
4. O **F16** do `teste_fumaca` tranca os espaços e a pausa; o **F2b** os
   ícones do cabeçalho; a régua do contraste lê um contorno opaco como o fundo
   da letra, com cinco controles no D33. Balanceamento intocado (100 / 80,2 /
   37,3).

---

## 1. Comece pelo estado real

- Confira no GitHub se há PR aberto da `claude/eager-wright-5kh2g8`. Se não
  houver, pergunte ao Bruno se o abre: a `066` só existe nesta branch, e uma
  decisão nova numerada a partir da `main` colidiria.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).
- O CI só corre em PR e na `main` (`CLAUDE.md`, «Como rodar, aqui dentro»):
  a primeira corrida sobre este trabalho é a do PR — leia-a, e o antes/depois
  do `captura.yml`, antes de contar com o verde.

## 2. O que está com o Bruno

- **O fundo e o logotipo da tela inicial**, no ChatGPT, pelos pedidos prontos
  de `art_lab/tela_inicial/BRIEFING.md`. Quando chegarem, a integração é a §3
  do `art_lab/README.md`: trocar o `FUNDO` de `TelaInicial.gd` (muda a tela
  inicial e o papel de parede do celular) e pôr o logotipo no lugar do nome, e
  ele aceita na foto do jogo.

## 3. O que o Bruno escolhe a seguir

Sem fila ordenada, a ordem é dele (§A5 do plano v3). Pergunte com opções:

- **O resto da frente 3** — as telas de texto: o diário, as mensagens e a tela
  de nomes. Os pedidos dele estão no plano v3, §A5.
- **Frente 4** — mapa, frota e animação, no Blender.
- **Frente 5** — o rumo além do VS: mexe em `GameState`, balanceamento e
  `SAVE_VERSION`; decisão de rumo.
- **Frente 6** — a folha de contato dos props.
- E os gates dele: o galpão V3 (recuperar ou refazer, `art_lab/`), a leitura
  em voz alta do A4 e a escuta do A6 (`docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ A pergunta que sai no mesmo bloco da prancha pode voltar sem resposta
  («Recebeu resposta»): foram 2 de 5, e o diagnóstico «mandei num bloco
  sozinho» era falso; o remédio é a pergunta sozinha outra vez (`/arte`, «O
  veredito na conversa»).
- ⚠️ No veredito de uma passagem, os defeitos que se veem na prancha vão como
  opções de seleção múltipla, e ele completa no «Outro» (`/arte`, «O veredito
  na conversa»).
- ⚠️ Texto sobre uma ilustração vive numa peça opaca, leva contorno opaco de
  `CONTORNO_MIN` px ou fica `fora` com motivo (`CLAUDE.md`, «Interface»;
  `contraste_ui.gd`).
- ⚠️ Os limiares de uma regra que o jogo só monta do lado que passa provam-se
  com controles sintéticos: sem eles, apagar a largura mínima e a opacidade
  deixava tudo verde (`066`; `_d33_contorno` em `tests/teste_design.gd`).
- ⚠️ O ícone `doca` é traço claro e some no selo do cabeçalho; o F2b mede a
  mediana dos pixels contra o selo (`CLAUDE.md`, «Interface»).
- ⚠️ Ler um espaço de save usa as mesmas recusas do `load_game()` e não apaga
  nada (`CLAUDE.md`, «Save»; `066`).
