# BR Port — prompt para a próxima conversa (depois do aceite dos painéis do HUD)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para a primeira mensagem, que é uma escolha do Bruno entre
frentes e o desenho da que ele escolher (F1); o que for receita desce para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `25f`. A sessão de 25/09 à noite trabalhou na branch
`claude/upbeat-fermi-ywyogh`, **sem PR aberto** (só se o Bruno pedir), e fechou
a **segunda família da frente 3 do A5**: os painéis que abrem por um toque no
HUD — dinheiro do dia, docas, reputação, calendário e parcela —, em duas
passagens, com o aceite «ficou bom» na segunda (`065`).

1. **Recordes da partida** no dinheiro do dia (melhor dia, mais barcos num
   dia, maior negócio, melhor semana), escolha do Bruno. Entram no save:
   **`SAVE_VERSION` 9**, e o save que ele tem no desktop é descartado uma vez
   quando abrir esta versão.
2. **Docas** com o que cada berço vai pagar (bónus incluído), o tipo de
   trabalho e a perda da doca sem trabalhador; **reputação** em três eixos, a
   de hoje como Comercial e a Comunitária e a Imprensa trancadas.
3. A segunda passagem deu a barra do HUD a cada número que anda para uma meta
   (a escada de barras, o trabalho de cada doca, o prazo, ontem contra o
   melhor dia).
4. O **F15** do `teste_fumaca` confere cada número contra o jogo; 13 defeitos
   injetados, 13 reprovações. Balanceamento intocado (100 / 80,2 / 37,3).

---

## 1. Comece pelo estado real

- Confira no GitHub se a branch `claude/upbeat-fermi-ywyogh` virou PR e se foi
  fundida. Se não foi, a `065` só existe nela, e uma decisão nova numerada a
  partir da `main` colidiria.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).
- O CI não correu nada desta branch: ele só corre em PR e na `main`
  (`CLAUDE.md`, «Como rodar, aqui dentro»). O verde é o do contêiner.

## 2. O que o Bruno escolhe a seguir

Sem fila ordenada, a ordem é dele (§A5 do plano v3). Pergunte com opções:

- **O resto da frente 3** — as telas de texto (diário, mensagens, nomes) ou o
  sistema (pausa com «salvar e sair», menu-celular). Os pedidos dele para cada
  uma estão no plano v3, §A5, «A segunda família da frente 3 fechou».
- **Frente 4** — mapa, frota e animação, no Blender.
- **Frente 5** — o rumo além do VS: mexe em `GameState`, balanceamento e
  `SAVE_VERSION`; decisão de rumo.
- **Frente 6** — a folha de contato dos props.
- E os gates dele: o galpão V3 (recuperar ou refazer, `art_lab/`), a leitura
  em voz alta do A4 e a escuta do A6 (`docs/PROTOCOLO_DE_ESCUTA.md`).

## 3. Lições desta sessão — onde vivem

- ⚠️ A prancha e a pergunta vão no MESMO bloco de chamadas; mordeu duas vezes
  com a regra lida, e «Recebeu resposta?» é o sinal de que a pergunta não
  chegou (`/arte`, «O veredito na conversa»).
- ⚠️ O dia só fecha na virada SEGUINTE, porque o `pay_debt()` escreve a
  parcela no `dia_anterior` depois dela: recorde gravado na virada punha o dia
  32 sem a parcela (`065`; comentário do `_recordes` no `GameState.gd`).
- ⚠️ Somar a doca parada ao «a receber» só diverge com uma doca com gente ao
  lado de outra sem, e foi esse caso que o apanhou (`065`, «A guarda»).
- ⚠️ Um painel que rebenta a meio passa pela guarda que lê o que ele escreveu
  antes; quem o denunciou foi o `SCRIPT ERROR` no log (`065`, e a varredura
  das suítes no CI, `031`).
- ⚠️ Toda fixture que joga resolve a oferta do rival antes de avançar: o
  `advance_turn()` saiu calado no terceiro dia do barco longo (`CLAUDE.md`,
  «Teste que JOGA fixa a semente»).
- ⚠️ `%s` depois de preposição não monta a contração: saiu «pesar em a
  cidade» (comentário do `EIXOS_TRANCADOS` em
  `brport_vs/scripts/PainelReputacao.gd`).
- ⚠️ O F9 exige toda palavra da forma plural no plural, logo o verbo fica
  FORA do `concordar()` (comentário do `_tarja()` em
  `brport_vs/scripts/PainelDocas.gd`).
