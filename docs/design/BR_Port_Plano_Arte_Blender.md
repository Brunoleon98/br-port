# Bloco 7 — Plano para levar a arte ao nível da referência

> Escrito em 30/08/2026, depois de olhar as cinco imagens de referência
> (`docs/design/referencias/`) e de rodar o Blender e o Godot dentro da sessão
> para medir, em vez de estimar.
>
> **A pergunta que este documento responde:** o que falta para o jogo parecer
> aquilo, quanto disso o Blender por script alcança, e o que é preciso
> aprender ou registrar para lá chegar.

---

## 1. A primeira coisa a dizer: o que a referência é

As cinco imagens são **concept art**, quase certamente saídas de um gerador de
imagem. Isso não as desqualifica — pelo contrário, elas fazem muito bem o
trabalho de concept art, que é **fechar uma direção**. Mas muda o que se pode
esperar delas:

- **O que elas decidem, e vale seguir:** o arco de crescimento (vila → cidade
  → porto industrial), a paleta tropical quente, a densidade de objeto, o
  enquadramento afastado, o peso da interface.
- **O que elas NÃO são:** um alvo de produção reproduzível peça a peça. Uma
  imagem gerada não tem folha de sprite por trás, não tem estados (ruína ×
  consertado), não registra em cima do mapa, e não repete o mesmo prédio duas
  vezes igual. É por isso que este projeto já perdeu **duas levas de sprite**
  (`docs/arquivo/BLOCO4_PACOTE_SPRITES.md`) e acabou gerando por script.

O alvo realista, portanto, não é "reproduzir a imagem". É: **chegar ao ponto
em que alguém que viu a referência reconhece o jogo como sendo aquilo**. A
§3 diz o quanto disso é alcançável e por onde.

---

## 2. A distância, medida

Foi medida com o Blender e o Godot rodando, não no olho.

| Frente | Referência | Jogo hoje | Quem resolve |
|---|---|---|---|
| **Objetos por recorte de 200×200px** | 6–12 | 1–3 | Blender + gerador de mapa |
| **Peças por prop** | dezenas, com ferragem e abertura | 2 a 42 (mediana 19) | Blender |
| **Enquadramento** | um distrito | três berços | gerador de mapa (`MEIA_LARG`) |
| **Contorno de silhueta** | sim, suave | não (Freestyle testado e rejeitado) | Blender, com outra técnica |
| **Oclusão de ambiente** | em toda fresta | só a sombra de contato | Blender |
| **Água/areia** | tropical quente, com praia | mar frio, sem areia | gerador de mapa (constantes) |
| **Rosto de personagem** | sim | não | textura — **não é geometria** |
| **Chrome da interface** | gradiente, sombra, cor por botão | chapado navy/creme | tema do Godot — **não é Blender** |

A contagem de peças por prop, hoje (`tools/gerar_props_iso.py`):

```
pier_ampliado 112 · guindaste_lanca 59 · pier_construido 53 · escritorio 42
galpao 39 · galpao_velho 38 · barco_grande 33 · barco_medio 29
barco_pequeno 24 · coqueiro_copa 19 · pier_vazio 8 · trabalhador 5
escritorio_ruina 5 · coqueiro_tronco 2 · conteiner 2 · caixote 2
boia 2 · marcador 2
```

**A cauda é o problema, não a cabeça.** O píer e o guindaste já estão densos;
contêiner, caixote, boia e marcador têm duas peças cada e ocupam boa parte da
tela num pátio cheio. É lá que está o ganho barato.

---

## 3. O que o Blender por script alcança — e o que não alcança

### Alcança, e é só trabalho

1. **Densidade.** É um laço. Foi o ganho desta rodada: o kit de detalhe
   (`na_face`, `moldura`, `janela`, `porta`, `telhado_duas_aguas`,
   `corrimao`, `escotilhas`) levou o galpão de 4 para 39 peças e o cargueiro
   de 12 para 33, e o custo por prop novo cai a cada peça de kit que entra.
2. **Ferragem e abertura.** Corrimão, escada, vigia, calha, moldura, trilho,
   corrente, defensa. Tudo primitiva composta.
3. **Material com textura procedural.** Ripa de madeira, corrugado de
   contêiner, fiada de telha, ferrugem escorrida, cal descascada — nós de
   ruído/onda/voronoi. O projeto já usa `material_gasto`; falta a família de
   padrões dirigidos.
4. **Oclusão de ambiente e luz quente.** O Cycles já está lá; é ajuste de
   parâmetro e um passe de AO.
5. **Contorno de silhueta.** O Freestyle foi testado e **rejeitado com razão**
   (fecha o vazado da treliça, engorda peça pequena). A saída não é insistir
   nele: é fazer o contorno **no compositor**, a partir dos buffers de
   profundidade e normal, onde a espessura pode depender da distância e o
   vazado não fecha. Isto é conhecimento novo — ver §5.
6. **Props que faltam.** Caminhão, empilhadeira, poste, cabeço avulso, pilha
   de caixotes, silo, pórtico, vagão, toldo de comércio. Cada um é meia hora
   de kit.

### Não alcança por script, e é honesto dizer

1. **Rosto.** Um trabalhador com cara a 40px é textura pintada num plano, não
   geometria. Caminho: gerar uma folha de rostos por gerador de imagem (onde
   perspectiva não importa, como já se faz com os retratos) e aplicá-la como
   material num plano da cabeça.
2. **A pincelada.** A referência tem variação de mão — telha que não repete,
   parede com mancha que conta uma história. Ruído procedural chega perto e
   não chega lá. Já registrado em `docs/arquivo/BLOCO5_PROMPTS_BLENDER_RICO.md`: *"o
   volume, a luz, o desgaste e a densidade de peça, sim; a pincelada, não."*
3. **Composição.** A referência tem um pátio ARRUMADO por alguém — fileiras
   que fazem sentido, circulação, um caminhão parado onde faria falta. Isso é
   decisão de layout, e continua sendo trabalho de quem desenha o mapa.

**Teto realista:** ~80% da leitura da referência, com o resto vindo de
textura pintada por cima da geometria do Blender. É o mesmo caminho que os
jogos com essa cara usam de verdade.

---

## 4. Ordem de execução

Ordenada por **ganho visível ÷ custo**, e não por gosto. Cada etapa é
verificável — o teste de design e a folha de contato dizem se ficou.

### Etapa 1 — Paleta e enquadramento (barato, muda tudo)
- Água e areia tropicais no dicionário `C` de `gerar_mapa_iso.py`; acrescentar
  faixa de praia entre a água rasa e o cais.
- Reavaliar `MEIA_LARG`/`MEIA_ALT`: a referência mostra um distrito. Baixar a
  escala mostra mais porto pela mesma tela, e **muda a projeção**, portanto
  exige regerar props E rodar o teste de design (que é justamente o que
  garante que os dois voltam a bater).
- **Mede-se por:** captura antes/depois lado a lado.

### Etapa 2 — A cauda dos props (barato, muda muito)
- Contêiner: corrugado, cantoneiras, portas, marcação. 2 → ~14 peças.
- Caixote: ripas, cinta, marca estampada. 2 → ~10.
- Boia e marcador: corrente, argola, faixa refletiva. 2 → ~6.
- Props novos: caminhão, empilhadeira, poste (o `poste_de_luz` do kit já
  existe e ainda não é usado), cabeço avulso, pilha de caixotes.
- **Mede-se por:** `folha_de_contato` dos props, e contagem de peças.

### Etapa 3 — Contorno pelo compositor
- Passe de normal + profundidade, detecção de borda no compositor, espessura
  proporcional à profundidade, composição por cima do beauty.
- **Mede-se por:** o guindaste. Se a treliça continuar vazada, funcionou.

### Etapa 4 — Materiais dirigidos
- Família de padrões: ripa, corrugado, fiada de telha, ferrugem que escorre
  de cima para baixo, cal descascada nas quinas.
- **Mede-se por:** o galpão a 100% e a 25% — padrão que só funciona de perto
  não serve.

### Etapa 5 — Personagem com rosto
- Folha de rostos por gerador de imagem, aplicada num plano da cabeça.
- **Mede-se por:** o trabalhador no tabuado, a 22px, no jogo rodando.

### Etapa 6 — Interface encorpada (NÃO é Blender)
- Gradiente e sombra nos `StyleBoxFlat` do tema, cor por botão na barra
  inferior, contador vermelho nos botões do trilho esquerdo.
- **Mede-se por:** o teste de design (que já cobre alvo de toque e
  sobreposição) mais uma captura.

---

## 5. A pergunta do conhecimento de Blender

**Sim, precisa — mas não do jeito que a pergunta sugere.** O que falta não é
"o Claude saber mais Blender em geral". O Blender genérico ele sabe. O que se
perde entre uma conversa e a seguinte é o **conhecimento ESPECÍFICO DESTE
PROJETO**, que é caro de redescobrir e já foi redescoberto mais de uma vez:

- a projeção (60°/45°, `ortho_scale`, altura em pixels do mapa e não em
  unidades do Blender);
- a inversão de sinal em `pos()`, que já pôs um prop 40px fora do lugar;
- a regra de a escala de ruído ser relativa ao tamanho da peça;
- o azimute próprio da sombra de contato (250°, e não o do mapa);
- que o Freestyle foi testado e rejeitado, e por quê;
- que só as faces `+x` e `-y` são visíveis;
- que `--import` é obrigatório num clone novo;
- que o Blender roda aqui via `pip install bpy` e o Godot via download direto.

Isso hoje está espalhado por comentários de código e por três documentos de
briefing. Um comentário só é lido por quem abre aquele arquivo.

**A providência concreta é `CLAUDE.md` na raiz do repositório** — que o Claude
Code carrega sozinho em toda sessão, sem ninguém pedir. Ele foi criado nesta
rodada com exatamente essas regras e com os comandos que funcionam. É a
diferença entre "leia estes três documentos primeiro" e não precisar dizer
nada.

O passo seguinte, quando o pipeline de props crescer mais, é uma **skill** em
`.claude/skills/` para o fluxo de arte (gerar → folha de contato → conferir
projeção → pôr no jogo → capturar). Ainda não vale: uma skill compensa quando
o fluxo repete muitas vezes na mesma sessão, e hoje o `CLAUDE.md` chega.

---

## 6. O que NÃO fazer

Registrado porque cada um destes já custou tempo neste projeto:

1. **Encomendar sprite a gerador de imagem para o cenário.** Duas levas
   perdidas. O gerador não erra o desenho, erra o ÂNGULO, e ângulo errado não
   se conserta rodando no Godot. Retrato em painel, sim; prop no mapa, não.
2. **Mexer na projeção sem rodar o teste de design.** `MEIA_LARG`,
   `ROT_X`/`ROT_Z` e `ESCALA_ORTO` são um contrato entre três arquivos.
3. **Perseguir a pincelada com nó de ruído.** Tem teto, e o teto já foi
   medido em `docs/arquivo/BLOCO5_PROMPTS_BLENDER_RICO.md`.
4. **Densificar sem olhar o resultado no jogo.** Prop bonito na folha de
   contato e ilegível a 25% é trabalho jogado fora — foi o que aconteceu com
   a primeira tentativa de desgaste, que virou lixa.
