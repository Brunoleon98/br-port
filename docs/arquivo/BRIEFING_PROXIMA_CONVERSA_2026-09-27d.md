# BR Port — prompt para a próxima conversa (depois dos 32 camiões)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus no começo** — a conversa abre pela escolha do Bruno e pelo
desenho da frente escolhida (F1); o que for receita desce para **Sonnet**
(`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `27c`. A sessão de 27/09 trabalhou na branch
`claude/gallant-babbage-6jnqiy`, a partir da `main` com o PR #94 fundido, e
fez a passagem que a `069` deixara escrita: **as duas transportadoras no
jogo** (`070`).

1. **Os 32 camiões** (4 serviços × 2 empresas × 4 silhuetas) gerados pelo
   `gerar_brp.py porto`, com os 16 novos em atlas. A empresa 0 mudou com os
   detalhes aceites; a 1 escreve-se `caminhao_<serviço>_b<silhueta>`.
2. **`CAMINHOES` do `Main.gd` por empresa**, e a **vez de cada
   transportadora** (`_empresa_da_vez()`): um contador por serviço, sem
   sorteio — o `_rng` do jogo fica intocado.
3. **As guardas**: o D13 por empresa; o D35 com o chassi do bicudo, os navios
   de todos os motivos e meia hora de passagem antes das visitas; e a guarda
   nova, **as 32 chegam à rua**. Seis mutantes medidos na `070`.
4. **As folhas**: uma página de camiões por transportadora (`camioes`,
   `camioes_b`) e a quarta página dos props (75). `.pck` +109 KB (+0,82%).

O Bruno não pediu PR: o trabalho só existe na branch.

---

## 1. Comece pelo estado real

- Confira no GitHub se a `claude/gallant-babbage-6jnqiy` virou PR e se foi
  fundida. Se não foi, a branch da conversa seguinte parte dela (um ref de
  cada vez no `git fetch`, `CLAUDE.md`).
- Veja os PRs abertos do Codex antes de mexer no `Main.gd` ou no
  `teste_design.gd` (`AGENTS.md`).

## 2. A escolha é do Bruno

- As outras famílias da **frente 4**: frota, ruína e obras, animação (é nesta
  que carros e pessoas entram no mapa, `069`).
- A **frente 5** (o rumo além do VS) e o **galpão V3**, que só existe no
  `art_lab` (`docs/ESTADO_DO_PROJETO.md`, A5).

## 3. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`); a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ O `.import` de atlas copia-se INTEIRO do vizinho, com `path`,
  `group_file`, `valid` e `dest_files`: a forma cortada não escreveu atlas e
  pôs o `--import` em laço (`CLAUDE.md`, Arte, «E A FORMA É A INTEIRA»;
  `070`).
- ⚠️ Duas chaves que contam pelo mesmo relógio casam — a vez da empresa a
  `(j + voltas) % 2` prendia o pescado a uma transportadora (`CLAUDE.md`,
  Arte; o `_vez_da_empresa` do `Main.gd`; `070`).
- ⚠️ A guarda de alcançabilidade só é satisfazível se a fixture levar o
  estado à rua: a agenda do D35 traz todos os motivos, e a passagem pergunta
  onde a roda manda sozinha (`brport_vs/tests/teste_design.gd`,
  `D35_PASSAGEM`; `070`).
- ⚠️ Redirecionado, o `gerar_brp.py` não escreve nada até acabar: corra-o
  com `python3 -u` (`CLAUDE.md`, «Como rodar, aqui dentro»).
- ⚠️ Prop novo pode pedir uma página nova na folha dos props, e a ferramenta
  reprova até a chamada entrar (`tools/capturar_evidencia.sh`, o bloco das
  páginas).
