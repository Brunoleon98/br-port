# BR Port F1 — ficha de passagem do conceito ao mapa · V1

**Estado em 23/09/2026:** candidata 13A comparada com a prancha conceitual e refinada na **V3** para revisão nos SVGs do mapa; V8 permanece direção conceitual ainda não reconstruída no jogo. Bruno pediu uma comparação entre a versão produzida e o conceito, sem ainda aprovar o resultado visual.  
**Base conferida em 23/09/2026:** checkout `art/f01-galpao`, commit local `cc36166`; há alterações não commitadas em `tools/gerar_mapa_iso.py` e nos dois SVGs do mapa. Conferir esse estado novamente antes de editar. O GitHub remoto não foi consultado.

## Decisão visual proposta — primeira candidata

**13A — arbusto baixo compacto:** reconstruir o volume de folhas arredondadas do agrupamento **superior esquerdo** de `13_arbustos_vegetacao_baixa_mangue_v4.png`, isolando a parte baixa e dispensando as árvores altas. Usar verde de copa, uma face sombreada e poucos planos iluminados, com desgaste muito discreto. Função: quebrar os tufos repetidos na transição entre a mata e os fundos dos lotes da vila. É uma proposta para Bruno escolher; a aprovação da prancha V4 não identificou esta variante como a preferida para produção.

| Contrato da candidata 13A | Proposta verificável |
|---|---|
| Consumidor | `tools/gerar_mapa_iso.py` → `vegetacao_do_solo()` → SVGs do mapa consumidos por `brport_vs/scenes/Main.tscn`. Sem PNG ou nó novo para esta primeira prova. |
| Fonte | Função procedural determinística no gerador; conceito V4 serve de referência de forma, não de textura a colar. Semente visual local para não deslocar a distribuição existente de árvores, pedras ou objetos. |
| Pegada e âncora | Inicialmente cerca de **0,35 × 0,30 unidade de mundo**; âncora no centro do contato com o solo, altura visual aproximada de **5–8 px de tela** acima do chão. Ajustar por captura. |
| Escala a 1:1 | Meta inicial de **12–18 px de largura e 9–14 px de altura no mapa exibido**. O losango de uma célula mede 40 × 20 px; comparar com a casa focal, a largura da rua, o cais e a capivara pequena aprovada. Eliminar detalhes que não sobrevivam à escala real. |
| Ordem e oclusão | Inserir entre moitas e capim na passagem `vegetacao_do_solo()`, no solo atrás da vila e antes de `vias()` e `vila()`. Ordenar a partir do pé no mundo; não pintar por cima de telhados, portas ou calçadas. |
| Proteções | Primeira prova apenas na faixa atrás dos lotes; manter fora das vias, acessos de casa, rota de caminhões, píeres, cabeços, áreas de interação e costa. Uma futura variante de restinga ou mangue jovem exige posição e prova próprias. |
| Estados e animação | Somente estático. O mapa SVG não possui controlador de estado para moitas. |
| Prova para avançar | Uma candidata por vez; captura da cena F1 e recortes 1:1 em três posições (junto da mata, atrás do lote e numa transição limpa), conferência de costura entre degraus e oclusão diante das casas. Bruno avalia no tamanho de uso. |

## Interface mangue, água e pedras — V8

**Direção aprovada:** `MANGUE_AGUA_PEDRAS_F1_V8_CONCEITO.png` orienta a passagem de azul aberto para água rasa esverdeada junto das raízes, a faixa úmida irregular e pedras pequenas em grupos que terminam nas praias. A composição inteira da imagem não fornece coordenadas, máscaras nem escala utilizável pelo jogo.

| Contrato da V8 | Aplicação e prova |
|---|---|
| Consumidores | Água, praia e enrocamento vêm de `tools/gerar_mapa_iso.py` nos SVGs do mapa. Mangues norte e sul são `brport_vs/art/blockout/f01_mangue_norte.svg` e `f01_mangue_sul.svg`, consumidos pelos nós `MapaWrap/Ambiente/MangueNorte` e `MangueSul` em `Main.tscn`. |
| Fonte e integração | Manter `linha_costeira()` como fonte comum para cor, areia e espuma. Afinar `agua_costeira_gradiente()`, cores `C[...]` e, se a captura exigir, os dois SVGs do mangue; não sobrepor um recorte da prancha V8. A cor local `#46aa9f` dos mangues será comparada com o baixio `#57c6dc` e a água rasa `#3fb6cf` do mapa antes de escolher valores novos. |
| Pegada e âncora | Costa gerada por distância à linha existente; não mudar `DEGRAUS`, `PIERES` ou a pegada do cais. Mangues continuam nas áreas atuais **192 × 120 px**; nós em (428, 0) e (8, 506) no espaço de tela. A alteração da água tem como referência a costa, não uma âncora de sprite. |
| Ordem e oclusão | Gradiente de água abaixo de solo e cais; mangues na camada `Ambiente` do `MapaWrap`, respeitando alfa das margens. As raízes devem terminar visualmente no baixio sem invadir via, casa, píer ou espaço funcional da doca. |
| Estados e animação | Cor e enrocamento estáticos. Espuma já possui camadas próprias; nenhuma animação nova sem consumidor. |
| Prova para avançar | Captura anterior e posterior da F1 nas duas pontas, no encontro cais/praia, na raiz dos píeres e em vista completa. Inspecionar costura de cor, margem alfa dos mangues, pedras sobre água/concreto e legibilidade a 1:1. Só ajustar pedras se a captura localizar o defeito. |

## Validação e limites

1. Congelar uma captura e medidas de base antes da alteração. O mapa é desenhado em 1080 × 1080, exibido em coordenadas 720 × 720, com janela visível de 720 × 660; comparar no espaço **tela**, com importação real no Godot.
2. Gerar os dois estados do mapa exigidos pela cena e verificar reprodução determinística; conferir que a distribuição dos elementos existentes não foi deslocada e que os testes de design e de registro continuam válidos.
3. Medir mudança de tamanho dos SVGs, carga/importação e frame/memória. O gate mobile do plano requer prova em aparelho de entrada, Samsung A23 3 GB; sem essa prova, o resultado fica em `review`.
4. Áreas de possível conflito com outra frente: `tools/gerar_mapa_iso.py`, os SVGs gerados do mapa, `f01_mangue_norte.svg`, `f01_mangue_sul.svg`, `Main.tscn`, testes de design e baselines. Confirmar donos e mudanças atuais antes da edição. Não alterar economia, save, rotas nem quantidade funcional de docas.

## Comparação conceito → V2 → V3

Referência específica: folhagem frontal do **grupo superior esquerdo** da prancha V4. O recorte do conceito também contém parte do tronco e da copa de árvores vizinhas; não pode servir como máscara pixel a pixel de um arbusto isolado. A folha `13a_comparacao_conceito_v2_v3.jpg` apresenta o recorte, as duas candidatas e ambos os mapas rasterizados em 1:1.

| Critério | V2 | V3 | Relação com o conceito |
|---|---|---|---|
| Silhueta | Contorno baixo, quase uma barra de volumes iguais | Centro mais alto, laterais assimétricas e base em pequenas folhas escuras | A frente do grupo tem alturas e massas variadas. |
| Folhagem | Verde relativamente uniforme, interior pouco profundo | Interior mais escuro, faces claras mais largas e um tufo ocre localizado | Recupera a separação de valor e o detalhe quente sem recortar a imagem conceitual. |
| Pegada visual a 1:1 | Aproximadamente 16,8 × 11,5 px | Aproximadamente 18,5 × 13,7 px | A V3 ainda cabe como vegetação baixa perto da casa e da mata; valores projetados da caixa alfa do PNG isolado, conferidos na prévia estática. A posição de algumas instâncias mudou, conforme a auditoria posterior. |
| Cor ocre na forma isolada | 0% dos pixels sólidos | 5,7% dos pixels sólidos | Medida HSV da renderização ampliada. Não é uma pontuação de similaridade com o conceito. |

## Resultado da prova 13A V3

- Fonte alterada: `tools/gerar_mapa_iso.py`, função `arbusto_baixo_f1()`, com semente local e cinco instâncias propostas na faixa natural. A V3 usa volumes baixos e assimétricos, um miolo escuro, facetas claras e folhas secas localizadas. A função de âncora, a cena e o controlador não mudaram; a posição de instâncias posteriores pode mudar quando a forma consome um número diferente de sorteios.
- Saídas regeneradas: `brport_vs/art/porto_mapa_iso.svg` e `brport_vs/art/porto_mapa_iso_patio.svg`. O PNG transparente `13a_arbusto_baixo_v3.png` representa a forma ampliada para revisão e **não é a textura consumida pelo jogo**. `13a_arbusto_baixo_previa_v3.jpg` mostra o mapa estático em 1:1 e dois recortes 3× com os mangues existentes sobrepostos.
- Testes realizados: Python compilou; os dois SVGs são XML válido de 720 × 720; o mapa de terra batida foi regenerado e comparado byte a byte; `git diff --check` não apontou problemas. A rasterização da V3 alterou 927 pixels visíveis em relação à V2, confinados à faixa de vegetação (x=50–175, y=30–181 na prévia de 720 × 720). Cada SVG gerado aumentou cerca de 19 KB em relação ao commit de base. As imagens foram rasterizadas com Inkscape, sem captura de execução no Godot. A prova em runtime, desempenho no Samsung A23 e aprovação de Bruno permanecem abertos. Estado `review`.

**Próxima decisão:** Bruno comparar a V3 com o conceito no tamanho apresentado. Se aprovada, prosseguir com uma reconstrução pontual da interface V8, conferindo antes os arquivos de alto conflito. Se pedir ajuste, revisar a mesma candidata antes da V8.

## Adendo de auditoria — 23/09/2026

A sonda reprodutível do pacote `BR_PORT_QA_ASSETS_V3` mostrou que trocar o consumo de RNG da forma desloca três das cinco instâncias, contrariando as afirmações anteriores de posição fixa. A reconstrução de seis lobos por instância produziu x diferentes nas instâncias 2, 3 e 5 em relação aos sete lobos atuais; essa reconstrução parte do código apresentado na conversa, não de um arquivo V2 preservado. O PNG isolado coincidiu exatamente com a primeira instância atual no teste de SVG, mas essa coincidência não garante estabilidade quando a ordem ou o número de sorteios mudar.

A comparação da prancha anterior usou um recorte que inclui partes de árvores vizinhas e escalas normalizadas separadamente. Ela não prova proximidade visual. A geometria `com_saia` ainda faz as copas parecerem blocos extrudados. Estado do 13A: **retrabalho artístico e técnico antes de integração**; gates de Godot, aparelho e revisão humana permanecem abertos. A auditoria estática mediu 927 pixels alterados numa prévia Inkscape de 720 × 720; esse número não é uma prova de ausência de invasão de portas ou rotas.
