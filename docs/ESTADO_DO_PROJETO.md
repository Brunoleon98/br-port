# BR Port — Estado do Projeto

> Resumo de onde o projeto está. Serve para retomar o trabalho numa conversa
> nova sem precisar reexplicar tudo.
>
> **Última atualização:** 29/08/2026 (Bloco 4 — camada de ícones fechada: o
> HUD não usa mais emoji; direção de arte decidida como isométrica, ainda não
> integrada)
>
> 👉 **Vai retomar o trabalho? Comece por `docs/BLOCO5_BRIEFING_CONTINUACAO.md`.**

---

## O jogo hoje, em três linhas

**O porto abre em ruínas.** 1 doca, 1 trabalhador, R$3.250 e cinco estruturas
para consertar — píeres 2 e 3, armazém, pátio e escritório. Comprar cada uma
muda o mapa: o pátio sai de terra batida para asfalto com carga, os prédios
saem de ruína para telhado novo.

**Economia medida em 600 partidas por perfil:** ótimo 100% · mediano 47% ·
descuidado 0%. A mediana do mediano fecha em R$7.945 contra uma parcela de
R$8.000. Mexer em preço sem rodar `simular_balanceamento.gd` quebra isto.

**Não se arrasta trabalhador a cada turno:** há "Alocar todos" e
toque-para-alocar, com o arrasto ainda funcionando.

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

3. ✅ **Pacote de sprites tratado** (28/08) — os PNGs vieram **sem canal alpha**
   (o quadriculado que parece transparência estava pintado nos pixels);
   `tools/preparar_sprites.py` conserta isso e é para ser reusado a cada leva
   nova. Análise do pacote em `docs/BLOCO4_PACOTE_SPRITES.md`.
   ⚠️ Desses 5 PNGs, **só `trabalhador.png` continua carregado pelo jogo** — o
   resto ficou para a migração isométrica, porque em cima de um mapa topo-down
   eles eram erro de perspetiva.
4. ✅ **Mapa virou a tela do jogo** (28/08) — docas são 3 vagas fixas sobre os
   píeres, e "Ampliar píer" acende a terceira.
5. ✅ **Camada de ícones fechada** (29/08) — os 20 ícones da interface são SVG
   em `art/icones/`, registrados em `scripts/Icones.gd`. **Nenhuma tela do jogo
   usa emoji.** São vetor chapado, não isométrico: ícone de HUD é interface e
   precisa se ler a 19px, o que o estilo isométrico não entrega nesse tamanho —
   então esta camada NÃO muda quando o mapa migrar.

Faltam os itens 6–7 do plano: áudio e integração progressiva.

🔄 **Direção de arte: ISOMÉTRICA (decidida 28/08) — decisão fechada.** Ela
oscilou três vezes na sessão (3/4 ilustrado → chapado topo-down → isométrico);
o histórico e o porquê estão na §2 do briefing de continuação, para não voltar
atrás de novo.

**O jogo em produção JÁ É isométrico** (29/08) e continua com as 33 asserções
passando. `Main.tscn` roda sobre `porto_mapa_iso.svg` com os props de
`tools/gerar_props_iso.py` — píer nos dois estados, barcos, cenário. O que
destravou foi gerar por script em vez de por prompt: num plano isométrico
nenhum eixo é horizontal (ambos a 26,57°), e o ângulo deixou de ser uma coisa
que alguém acerta para ser uma conta que não pode sair errada.

Continuam com gerador de imagem só os **retratos** (Arlindo, Sr. Ribeiro), onde
a perspectiva não importa porque vivem em painel.

👉 **Para retomar, o ponto de entrada é `docs/BLOCO4_BRIEFING_CONTINUACAO.md`**
— estado atual, decisões fechadas e os caminhos que restam (o dos ícones foi
fechado em 29/08).
`docs/BLOCO4_BRIEFING_VISUAL.md` continua válido como registro das decisões
sobre a imagem de referência original (turnos mantidos, R$ e não $, retrato).

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.6+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `brport_vs/tests/run_tests.gd` | 33 asserções de regressão |
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo da interface** — paleta do protótipo HTML, cantos, botões, estilos de doca e trabalhador, e (Bloco 4) os tokens do mapa (água, escritório, zona de espera) |
| `brport_vs/scenes/*.tscn` | As telas como árvore de nós (não são mais montadas por código) — `Main.tscn` tem a seção "Porto" com o mapa do porto |
| `docs/design/BR_Port_Style_Guide_Flat_Design.md` | Paleta, peso de linha, espaçamento e proporções canônicas para toda arte futura |
| `brport_vs/art/sprites/` | Sprites prontos (trabalhador, cargueiro, barco de pesca, caminhão, guindaste) |
| `brport_vs/art/icones/` | **Os 20 ícones da interface**, em SVG chapado |
| `brport_vs/scripts/Icones.gd` | Registro dos ícones + helpers de rótulo e botão — o único lugar que sabe qual arquivo é qual ícone |
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs gerados por IA e redimensiona — rodar a cada leva nova |
| `docs/BLOCO4_GUIA_GERACAO_ASSETS.md` | Prompts de gerador (retratos) + o que o píer construível exige |
| `docs/BLOCO4_BRIEFING_CONTINUACAO.md` | **Ponto de entrada para retomar** — estado, decisões fechadas, 3 caminhos possíveis |
| `docs/BLOCO4_PROMPTS_ISOMETRICO.md` | **Prompts do visual escolhido** — isométrico, orientação obrigatória, animação e evolução por Fase |
| `docs/BLOCO4_PROMPTS_VISUAL_CHAPADO.md` | Superado — versão topo-down, mantida pelo registro |
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo |
| `tools/gerar_props_iso.py` | Gera os props isométricos (píer, barcos, guindaste, coqueiro, galpão, cenário) em Blender por script, na projeção do mapa. Confere a própria projeção ao fim |
| `docs/BLOCO4_PACOTE_SPRITES.md` | O que do pacote de sprites/mockups entrou, o que não entrou e por quê |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade |
| `brport_vs/tools/capturar_tela.gd` | Tira um PNG do jogo rodando, sem abrir o editor |
| `brport_vs/tools/folha_icones.gd` | Folha de contato dos ícones nos 3 fundos da interface, a 19px e ampliado — **rodar a cada ícone novo** |
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

### O que já é arte de verdade, e o que ainda é placeholder
**O mapa do porto é a tela do jogo** (`Main.tscn`): água, cais, armazém, pátio
de contêineres, caminhões estacionados e coqueiros, tudo em vetor chapado visto
de cima. As docas são **3 vagas fixas sobre os píeres** — quantas
existem vem de `GameState.docks`, e "Ampliar píer" acende a terceira, que até
lá mostra as estacas velhas sob contorno tracejado.

A interface **não é montada por código**: vive em cenas `.tscn` com um tema
(`ui/tema_brport.tres`). Trocar arte é editar cena e tema, não reescrever
script.

**Os ícones do HUD já são arte de verdade** (29/08): 20 SVGs em `art/icones/`,
todos conferidos a 19px sobre os três fundos que a interface tem (pílula
escura, cartão branco, botão navy) com `tools/folha_icones.gd`. Cada um foi
colorido para o fundo onde cai — dois não são reaproveitáveis em qualquer
lugar, e o cabeçalho de `Icones.gd` diz quais e por quê.

As **estruturas trocam de textura, não de nó** — o prop ocupa o mesmo quadro
nos dois estados, então o prédio não salta ao ser consertado. Mesma razão que
fez o píer partilhar geometria entre vazio e construído.

O cenário usa os props: **coqueiros low-poly** (que oscilam, copa e tronco em
peças separadas), **guindaste** nas docas construídas (a lança varre), **carga
no convés** e **boias + marcador** na Zona de Espera. Os coqueiros chapados
saíram do SVG do mapa — `gerar_mapa_iso.py --sem-coqueiros` — pela mesma razão
que os píeres: o que se mexe não pode estar assado no fundo.

Continuam **sem uso** `galpao` e `galpao_velho` (os prédios do mapa já fazem
esse papel) e as versões avulsas de `caixote`/`conteiner` (foram assadas no
píer).

Os **3 barcos do GDD** existem (pesqueiro, cargueiro médio e grande), e o
pesqueiro tem casco próprio — não é o mesmo casco com carga trocada. O
**trabalhador aparece de pé no tabuado** quando alocado, e mexe-se enquanto a
operação corre.

Ainda é placeholder o **retrato ilustrado do trabalhador** no cartão da
fileira, que é de outra leva e de outra linguagem visual.

A **Zona de Espera é só visual**: os barcos ancorados são decorativos e não
representam fila de verdade — barcos continuam nascendo direto nas docas.
Torná-la mecânica muda o balanceamento medido (ver o aviso em
`BLOCO4_BRIEFING_VISUAL.md`).

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
