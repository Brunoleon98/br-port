# BR Port — Estado do Projeto

> Resumo de onde o projeto está. Serve para retomar o trabalho numa conversa
> nova sem precisar reexplicar tudo.
>
> **Última atualização:** 27/08/2026 (Bloco 4 iniciado — style guide de flat
> design e estrutura do mapa do porto com placeholder)

---

## Onde estamos no roadmap

**Fase 4 — Produção do Vertical Slice**. O **Bloco 2 (loop core)** está entregue
e o **Bloco 3 (marco intermediário) está FECHADO** — playtest humano feito,
decisão registrada, ajustes aplicados.

As Fases 1–3 já foram concluídas antes: o protótipo HTML de diagnóstico foi
jogado e aprovado (Playtest V3 ✅ GO) e o **GDD 7 está congelado** como fonte da
verdade (`docs/design/BR_Port_GDD_V7.jsx`).

**Decisão do Bloco 3 (26/08):** *ajustar antes de ir para a arte* — e os
ajustes já foram feitos, dentro de 1 semana. O registro completo, com as 5
partidas do playtest e o raciocínio, está em
`docs/BLOCO3_MARCO_INTERMEDIARIO.md`, Parte 3.

**Bloco 4 — arte final, áudio e integração — está EM ANDAMENTO.** Os dois
primeiros itens da ordem de trabalho (`docs/BLOCO4_BRIEFING_VISUAL.md`) saíram
em 27/08:

1. ✅ **Style guide de flat design** —
   `docs/design/BR_Port_Style_Guide_Flat_Design.md`. Paleta de UI (já
   validada) + paleta nova de mapa/cenário, peso de linha, espaçamento,
   proporções canônicas e convenção de cor por estado.
2. ✅ **Estrutura do mapa do porto com placeholder** — a antiga fileira
   "Docas" virou um mapa visto de cima (`Main.tscn`, seção "Porto"):
   Escritório (terreno) | Docas (dinâmico, 2–3 conforme upgrade) | Zona de
   Espera, sobre um fundo de água. Ainda formas simples — valida a leitura
   espacial antes de encomendar sprite.

Faltam os itens 3–7 do plano: sprites de personagem, sprites de cenário, UI
das 12 telas, áudio, integração progressiva.

👉 **Se você vai continuar o visual, leia antes
`docs/BLOCO4_BRIEFING_VISUAL.md`.** Ele traz decisões já tomadas sobre a
imagem de referência (mapa do porto visto de cima, turnos mantidos, arte pelo
style guide do GDD) e a lista do que NÃO seguir dessa imagem.

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `brport_vs/tests/run_tests.gd` | 19 asserções de regressão |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta do protótipo HTML, cantos, botões, estilos de doca e trabalhador, e (Bloco 4) os tokens do mapa (água, escritório, zona de espera) |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem a seção "Porto" com o mapa do porto |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows) |
| `docs/BLOCO3_MARCO_INTERMEDIARIO.md` | Medição do balanceamento + roteiro do playtest + onde registrar a decisão |
| `docs/design/` | GDD 7, Roadmap, Plano de Produção, guias, Validation Guide |
| `index.html` (raiz) | O protótipo HTML original, já validado |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Drag-and-drop de trabalhadores para as docas
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas qualitativas)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- Parcela única de R$ 8.000 ao Sr. Ribeiro, vencendo na semana 4
- Upgrade único (ampliar píer: +1 doca, +1 trabalhador)
- Autosave local a cada turno

### O que é placeholder de propósito
**A arte** — ainda são formas e emoji, sem sprite nenhum. Mas a interface
**não é mais montada por código**: desde o Bloco 3 ela vive em cenas `.tscn`
com um tema (`ui/tema_brport.tres`) que carrega a paleta do protótipo HTML.
Trocar placeholder por arte final no Bloco 4 é editar cena e tema, não
reescrever script.

Desde o Bloco 4, as docas moram num **mapa do porto visto de cima**
(Escritório | Docas | Zona de Espera), não mais numa fileira de cartões —
mas ainda com retângulos coloridos, não sprite. A Zona de Espera é **só
visual** por enquanto: mostra um marcador decorativo, não representa uma
fila de verdade (barcos continuam nascendo direto nas docas — ver o aviso
em `BLOCO4_BRIEFING_VISUAL.md` antes de torná-la mecânica).

Continuam para depois: áudio, Diário do Porto, cena narrativa de fim de Fase 1
e a lista "VS — OUT" do GDD.

---

## Balanceamento — resolvido no Bloco 3

O jogo **estava no fio da navalha**, não fácil como o handoff dizia. O playtest
humano confirmou: 5 partidas, 1 vitória, e uma delas perdida por **R$ 1**
(R$ 7.999 contra R$ 8.000) — jogando bem, sem perder barco.

A causa não era o valor do barco: era a **vazão**. Com 3 turnos por semana, a
parcela só cabia inflando o barco para R$ 240–760, fora da faixa do GDD.

**Correção aplicada:** 8 turnos por semana, barcos de volta a **R$ 80–300**
(a faixa que o GDD define para a Fase 1).

| Perfil | Antes | Depois |
|---|---|---|
| Joga perfeito | 58,5% | **99,7%** |
| Joga mediano | 7,2% | **63,8%** |
| Joga mal | 0,1% | **0,7%** |
| Folga no vencimento | 2% | **20%** |

A dívida técnica registrada antes — "valores de barco acima do GDD" — **não
existe mais**.

### Achados de design que vieram junto

- **A contra-oferta do Arlindo virou uma decisão de verdade.** O botão "Manter
  preço" não tinha chance nenhuma de dar certo — apertar duas vezes sempre
  perdia o barco. Agora os 3 presets são os do GDD ("Igualar −15%" / "Cortar
  metade −7%" / "Manter preço"), os dois últimos são apostas reais, e igualar
  depois de insistir custa 28% em vez de 15%.
- **A economia do GDD não fechava.** Erro de aritmética no próprio GDD: o
  modelo da Fase 1 acumulava R$ 1.480 em 4 semanas contra uma parcela de
  R$ 8.000. Corrigido, com registro em
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. **As Parcelas 2 e 3 seguem
  não verificadas** — vale checar antes de codar a economia da Fase 2.
- **Ninguém quebra por caixa.** O píer sozinho paga os custos, então a derrota
  por caixa negativo continua sendo código morto: a única forma de perder é o
  portão da parcela. Fica anotado, não foi mexido.
- **A reputação ainda não afeta nada** mecanicamente — só o rótulo na HUD.
  Decisão de design em aberto para a produção full.

Para medir qualquer mudança: constantes marcadas `# TUNING:` no topo de
`brport_vs/autoload/GameState.gd`, e o simulador mede o efeito em segundos.

---

## Histórico de correções relevantes

O primeiro playtest humano (25/08) encontrou dois bugs sérios, ambos corrigidos:

1. **Jogo travava** depois de aceitar a oferta do rival — o botão "Avançar dia"
   ficava desabilitado para sempre. Era ordem de emissão de sinais; hoje toda
   troca de fase passa por um ponto único que avisa a interface.
2. **O mesmo trabalhador podia ser alocado em várias docas** ao mesmo tempo,
   multiplicando receita de graça. Hoje é bloqueado, e tocar na doca libera o
   trabalhador (para desfazer arrasto errado).

Lição registrada: a verificação automatizada agora **instancia a cena real** e
checa o estado dos botões. A versão anterior só chamava a lógica direto, e por
isso não pegou nenhum dos dois.

Segunda lição, do dia 25/08: **um harness que joga perfeito não mede
dificuldade.** A taxa de vitória de ~63% que constava aqui vinha da suíte de
testes jogando sem errar uma vez sequer — o que descrevia o teto do jogo, não a
experiência de quem pega no controle pela primeira vez. Medir dificuldade exige
simular também o jogador que erra, e com amostra grande o bastante para a
margem de erro não engolir a conclusão. Daí o
`tools/simular_balanceamento.gd`.

---

## Como retomar numa conversa nova

Comece a conversa apontando este arquivo. Algo como:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md`. Quero trabalhar em X."

Para rodar os testes antes e depois de mexer no código:

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tests/run_tests.gd
```

Espera-se `TODOS OS TESTES PASSARAM` e código de saída 0.

E para medir o efeito de qualquer mudança de balanceamento (800 partidas por
perfil de jogador, ~10 segundos):

```
Godot_v4.6.3-stable_win64.exe --headless --path brport_vs --script res://tools/simular_balanceamento.gd -- 800
```
