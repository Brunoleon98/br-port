# BR Port — Plano de Produção do Vertical Slice (Fase 2)
**Versão 1.0 · Entregável da Fase 2 do Roadmap v2.1**

> Este documento é o plano de produção do VS. Foi escrito uma vez e travado. Mudanças aqui significam re-abrir a fase. Pequenos ajustes vão pra "anotações de produção", não pra este doc.

---

## 1. Resumo executivo

**O que o VS é:** Fase 1 do JOGO (Ato 1 — Início), 15–25 min jogados, arte production-quality em flat design, publicado no itch.io (Android + WebGL).

**Quem produz:** dev solo iniciante em Godot, aprendendo no caminho com apoio de IA.

**Capacidade declarada:** 8h/semana (6h em bloco de fim de semana + 2h pingadas na semana).

**Janela de calendário alvo:** 44 semanas brutas (~10 meses) + buffer de 40% → **10–14 meses** entre o início da Fase 4 e o VS jogável publicado.

**Premissa central:** trabalho pesado (código, integração, debug) só nos blocos de fim de semana. As 2h pingadas na semana são pra trabalho leve (texto, prompts de IA, geração de SFX, planejamento da próxima semana).

**O que NÃO está neste plano:** decisões de polish, balanceamento fino, narrativa estendida. Tudo isso fica pra Fase 3 (GDD 7) ou pra dentro da produção, conforme o caso.

---

## 2. Premissas de calibração

Estimativas refletem:

- **IA já embutida na conta.** Escrita acelera 5–10×, código 2–3×, arte/áudio 3–8× (com atrito de integração comendo parte do ganho). As horas abaixo já consideram isso.
- **Stack:** Godot + IA (escrita: Claude; código: assistente de IA; arte: flat design gerado por IA; áudio: Suno + ElevenLabs/SFX guiados pelos guias do projeto).
- **Curva de Godot:** 30–50h de aprendizado embutidas no Bloco 1, não esticadas no calendário todo.
- **Buffer:** 40% em cima do bruto. Padrão pra primeiro projeto solo.
- **Regra de atraso:** se atrasar 2 semanas seguidas, **replanejar**, não acelerar. Acelerar queima motivação e produz dívida técnica.

---

## 3. Lista de assets consolidada

Replicada do GDD 6.5 com qualidade alvo e formato técnico anotados. Esta é a fonte da verdade da Fase 2 — o escopo não cresce daqui pra frente.

### Personagens (5 sprites + expressões)
| Asset | Variações | Uso |
|---|---|---|
| Dona Cida | sprite base + 3 expressões (neutro, satisfeita, preocupada) | Diálogo, boletim financeiro, ícone no indicador de reputação |
| Arlindo | sprite + anim leve (idle + reação) | Tela de contra-oferta |
| Sr. Ribeiro | sprite simples | Cena de parcela (só Fase 1) |
| Trabalhador genérico | 1 sprite em 2 variações de cor | Drag-and-drop |

### Cenário
| Asset | Variações |
|---|---|
| Píer | estado base + estado upgraded (mesma composição) |
| Barcos | 3 variações visuais (mesma mecânica) |

### UI — 12 telas production-quality
1. Boletim do dia (abertura de sessão)
2. Doca + drag-and-drop de trabalhadores
3. Fila de barcos/contratos
4. Tela de contra-oferta (3 presets + mood face)
5. Diálogo Dona Cida (3 variações de tom)
6. Boletim Financeiro semanal
7. Indicador de reputação Comercial (cor pulsante + ícone NPC)
8. Tela de construção/upgrade (só o upgrade da Fase 1)
9. Cena de parcela com Sr. Ribeiro
10. Diário do Porto (1 página inicial)
11. Cena de fim de Fase 1 (estática)
12. Pause / menu mínimo

### Áudio
- **~8 SFX core**: drag pega/solta, chegada de navio, parcela paga, alerta de tentativa final na contra-oferta, click de UI, transição de turno, reputação sobe, reputação cai.
- **1 loop de ambiente**: 1–2 min, água + gaivotas + rádio AM distante.
- **1 música-tema da Fase 1** via Suno. **Timebox: 1 dia**. Se não render, cai sem culpa pra só ambiente loop.

### Texto narrativo
- Boletim Dona Cida — 1 modelo + 3 variações tonais
- Comentários de Dona Cida no loop — ~6–8 linhas curtas
- Linhas de negociação do Arlindo — ~5–8 linhas
- Diálogo Sr. Ribeiro (cena de parcela) — ~4–6 linhas
- Narração de fim de Fase 1 — ~10–15 linhas
- 1 página inicial do Diário do Porto

---

## 4. Ordem de produção (5 blocos)

A ordem é sequencial nos blocos pesados. Frontload da escrita acontece em paralelo ao Bloco 1.

### Bloco 1 — Setup + curva de Godot + frontload da escrita
**Semanas 1–6 · ~48h**

- Instalação de Godot + setup do projeto
- Tutoriais essenciais (cenas, nodes, sinais, input mobile, GDScript básico)
- Setup de Git/GitHub privado
- Configurar export pra Android + WebGL — **testar build vazia em device real desde já**
- **Frontload da escrita (nas 2h da semana):** rascunho de todos os diálogos. Não precisa ficar perfeito — fica pronto pra iterar depois.

**Critério de conclusão:** consigo criar uma cena nova com sprite respondendo a um clique. Build vazia roda no celular. Texto bruto pronto em arquivo separado.

### Bloco 2 — Loop core com placeholder
**Semanas 7–16 · ~80h**

Sistema todo funcionando com retângulos coloridos no lugar de arte.

- Sistema de turno (alocação → docagem → receita)
- Drag-and-drop de trabalhadores
- Fila de barcos com tap pra detalhes
- Economia (caixa, parcela, upgrade único)
- Reputação Comercial (lógica numérica + UI placeholder)
- Contra-oferta com Arlindo (3 presets + mood face placeholder)
- Curva de pressão (parcela final mais pesada)
- Autosave local

**Critério de conclusão (= MARCO INTERMEDIÁRIO):** dá pra completar uma semana de jogo do início ao fim sem crash; drag-and-drop funciona; pelo menos 1 contra-oferta com Arlindo dispara e o cliente reage; parcela é cobrada e o caixa muda. **Arte ainda placeholder.**

### Bloco 3 — Marco intermediário: validar antes de gastar arte
**Semanas 17–19 · ~24h**

Confirmar que o loop não está fundamentalmente quebrado **antes** de produzir arte cara.

- Dev joga sozinho 2 dias seguidos. Anota o que incomoda.
- Entrega pra 1 pessoa de confiança jogar sem instrução. Observa o comportamento (não a opinião).
- Decide: avança pra arte final OU ajusta sistemas primeiro.
- Ajustes de sistema, se necessário — só corrigir o que estiver quebrado, não inflar escopo.

**Critério de conclusão:** decisão registrada — "loop pronto pra receber arte final" ou "preciso de mais X semanas de ajuste". Se ajuste necessário > 3 semanas, voltar e replanejar a Fase 2.

### Bloco 4 — Arte final + áudio + integração
**Semanas 20–34 · ~120h**

Ordem dentro do bloco:

1. **Style guide de flat design** (1 semana) — paleta, peso de linha, proporções. Sem isso, cada asset sai diferente.
2. **Sprites de personagem** (4–5 semanas) — Dona Cida primeiro (mais usada), depois Arlindo, Ribeiro, trabalhadores.
3. **Sprites de cenário** (2 semanas) — píer + barcos.
4. **UI das 12 telas** (5–6 semanas) — meta de uma tela por bloco de fim de semana. Agressiva, mas factível com IA.
5. **Áudio** (1 semana) — SFX em lote, ambiente loop, tentativa da música Suno (timebox 1 dia).
6. **Integração progressiva** — cada asset vai pro projeto assim que sai. Não acumula pro final.

**Critério de conclusão:** todas as 12 telas com arte final. Todos os personagens no jogo. Áudio integrado. Build roda no celular sem placeholder visível.

### Bloco 5 — Polish, bugs, build, publicação
**Semanas 35–44 · ~80h**

- Lista de bugs identificados nos blocos anteriores — fechar todos os bloqueantes
- Revisão final dos diálogos frontloadados no Bloco 1
- Cinemática de abertura placeholder (estática, simples)
- Testar em pelo menos 2 devices reais (iPhone + Android)
- Configurar página itch.io (descrição, screenshots, GIF curto)
- Upload da build Android (APK) + build WebGL
- Publicar

**Critério de conclusão da Fase 4 (não desta fase):** VS jogável publicado, URL pública no itch.io, dev jogou do início ao fim sem quebrar.

---

## 5. Cronograma resumido

| Bloco | Semanas | Horas | Foco |
|---|---|---|---|
| 1. Setup + Godot + frontload escrita | 1–6 | ~48h | Aprender + escrever texto bruto |
| 2. Loop core com placeholder | 7–16 | ~80h | Sistema todo funcionando feio |
| 3. Marco intermediário | 17–19 | ~24h | Validar antes de gastar arte |
| 4. Arte + áudio + integração | 20–34 | ~120h | Produção dos assets |
| 5. Polish, bugs, build, publicação | 35–44 | ~80h | Fechar e publicar |
| **Total bruto** | **44 semanas** | **~352h** | **~10 meses** |
| **Com buffer de 40%** | **~62 semanas** | **~490h** | **~14 meses** |

**Janela alvo da Fase 4: 10–14 meses de calendário.**

---

## 6. Estrutura da semana de trabalho

| Bloco | Horas | Tipo de trabalho |
|---|---|---|
| Fim de semana (sábado OU domingo) | 6h | **Pesado**: código, integração, debug, decisões de design |
| 2h pingadas na semana | 2h | **Leve**: texto, prompts de IA, geração de SFX, planejamento da próxima semana |
| **Total** | **8h/semana** | |

**Regras de proteção:**
- Se um fim de semana for atravessado pela vida e o bloco pesado for perdido, **não tentar repor com 12h na semana seguinte**. Aceitar a perda e seguir.
- Trabalho pesado fora do fim de semana só em exceção real — não vira hábito.
- Se cair sustentadamente abaixo de 6h/semana por 1 mês, **replanejar a janela total**, não tentar comprimir.

---

## 7. Marcos e checkpoints

| Marco | Semana | Critério |
|---|---|---|
| Fim do Bloco 1 | 6 | Build vazia roda no celular. Texto bruto pronto. |
| **MARCO INTERMEDIÁRIO** (fim do Bloco 2) | 16 | Loop core jogável end-to-end com placeholder. |
| Fim do Bloco 3 | 19 | Decisão registrada — avança ou ajusta mais. |
| Fim do Bloco 4 | 34 | Todos os assets integrados. |
| **FIM DA FASE 4** | 44 (bruto) / até 62 (com buffer) | VS publicado no itch.io. |

---

## 8. Riscos identificados e mitigações

| Risco | Prob. | Mitigação |
|---|---|---|
| Subestimação de tempo de Godot | Alta | Buffer de 40% no plano. Se Bloco 1 estourar 2 semanas, replanejar. |
| Frustração no debug (curva inicial) | Alta | Trabalho pesado só no fim de semana — vida durante a semana protegida. |
| Scope creep (feature nova durante produção) | Alta | Escopo travado no GDD 6.5. Ideias novas vão pra arquivo "ideias pós-VS". |
| Arte inconsistente entre telas | Média | Style guide ANTES de produzir qualquer sprite (início do Bloco 4). |
| Música Suno não rendendo | Média | Timebox de 1 dia. Fallback: só ambiente loop. Sem culpa. |
| Perda de motivação no meio do projeto | Alta | Marco intermediário (semana 16) existe pra dar sensação de "consegui algo jogável" antes da arte. |
| Vida pessoal cortar tempo disponível | Alta | Plano conta com 8h ideais e 6h reais de piso. Abaixo disso, replanejar janela. |
| IA não responder bem em código Godot (modelo treinado em pouco Godot) | Média | Combinar IA com documentação oficial. Não confiar 100% na primeira sugestão da IA. |

---

## 9. O que NÃO está neste plano (e por quê)

- **Marketing, devlog público, Discord pré-lançamento.** O VS é instrumento de validação interna, não produto pra vender. Comunicação externa só após Fase 6.
- **Localização.** VS sai só em PT-BR.
- **Acessibilidade completa.** Só fonte ajustável em 3 níveis, conforme GDD 6.5.
- **Beta fechado, QA externa formal.** Vem na produção full, não no VS. No VS são 1–3 pessoas testando informalmente após o marco intermediário.
- **Loja Steam, App Store, Google Play.** VS sai só no itch.io.

Tudo isso é deliberadamente cortado. Não é descuido.

---

## 10. Critério para fechar a Fase 2 (este documento)

- [x] Plano escrito (este doc)
- [x] Escopo do VS confirmado (GDD 6.5)
- [x] Capacidade declarada e calibrada (8h/sem, fim de semana pesado + 2h leves)
- [x] Cronograma de calendário registrado (44 semanas brutas, janela 10–14 meses com buffer)
- [x] Ordem de produção definida (5 blocos sequenciais + frontload paralelo no Bloco 1)
- [x] Marco intermediário com critério concreto (semana 16)
- [x] Riscos mapeados e mitigações associadas

**Próximo passo:** Fase 3 — atualizar GDD 6.5 → 7 incorporando as decisões desta fase, congelar antes da produção começar.

---

*BR Port · Plano de Produção do VS · Fase 2 entregue · Próxima: Fase 3 — GDD 7*
