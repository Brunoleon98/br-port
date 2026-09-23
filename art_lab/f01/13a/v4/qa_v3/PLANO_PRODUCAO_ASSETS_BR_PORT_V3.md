# BR Port — Plano de Produção de Assets F1–F5 · V3

**Versão:** 3.0 — qualidade visual e trabalho em paralelo  
**Data:** 23/09/2026  
**Projeto:** `Brunoleon98/br-port`  
**Base histórica V2:** `398b8b316ec5a033463dad74d182cc74657a3ba9`  
**Evidência local desta revisão:** `art/f01-galpao`, commit `cc36166a262a751494ca3ccd25f1359f77b18fc1`, com alterações 13A não commitadas nos dois mapas e no gerador. O estado atual do GitHub não foi consultado e pode ser diferente.  
**Engine:** Godot 4.6+ · GDScript · renderer Compatibility  
**Alvo principal:** mobile retrato, Android/iOS; expansão futura para PC  
**Substitui como plano de trabalho de arte:** `PLANO_PRODUCAO_ASSETS_BR_PORT_V2.md`  
**Preserva como registro:** planos V1/V2, conceitos aprovados e decisões canônicas do código. Esta revisão não aplica mudanças ao GitHub.

---

## 1. Objetivo e diagnóstico desta revisão

Produzir assets bonitos, coerentes entre si e legíveis no mapa F1. A referência aprovada define a direção artística; o contrato do jogo define escala, câmera, consumo e desempenho. Ambos devem funcionar na mesma peça.

**A frente de assets trabalha em paralelo à frente de código no GitHub.** Ela entrega fontes, renders, demonstrações, testes e instruções de integração. O mantenedor do código integra após conferir compatibilidade com o commit de destino.

### Falhas observadas e correções

| Achado | Consequência | Correção obrigatória |
|---|---|---|
| 13A foi reconstruído com lobos extrudados que lembram blocos; os detalhes adicionados não resolveram completamente a diferença de linguagem. | Um SVG tecnicamente válido pode continuar distante do conceito. | Julgar forma, volume e material antes de insistir no mesmo método. Reprovar o desenho quando o defeito de base permanece. |
| Recorte usado como referência contém tronco e copas vizinhas; as candidatas foram ampliadas independentemente. | Comparação favorece uma leitura errada de escala e identidade. | Identificar exatamente o componente desejado, declarar recorte/máscara, mostrar família completa e comparação na mesma escala. |
| Métricas de ocre, tamanho ou quantidade de pixels foram apresentadas como progresso visual. | Números podem crescer sem melhorar a arte. | Usar métricas como diagnóstico. Beleza exige revisão explícita com critérios e exemplos. |
| Forma e posição dos arbustos usam o mesmo RNG local. | Acrescentar faces/folhas desloca instâncias posteriores. | RNG independente por identidade e por canal: posição, forma e animação. Testar custo variável da forma. |
| PNG isolado não reproduz exatamente a primeira instância do mapa. | A peça aprovada pode ser diferente da que foi mostrada no contexto. | Exportar a mesma instância identificada e usar os mesmos parâmetros na ficha, render e cena. |
| PNG, mapa SVG e montagens estáticas foram tratados de modo pouco claro. | Prévia pode parecer asset consumido ou captura real. | Declarar papel, origem, método de render, escala e hash de cada arquivo. |
| Trabalho foi feito diretamente no checkout de galpão, em gerador compartilhado. | Risco de conflito e sobrescrita da frente de código. | Trabalhar em laboratório isolado; entregar pacote de integração fixado em uma base. |
| Manifest local usa `production` para itens em uso com gates abertos. | Uso no jogo pode ser confundido com qualidade final aprovada. | Manter compatibilidade do manifest legado e acrescentar um dossiê de qualidade externo; migração só na frente de código. |
| V2 ainda pede estado “em obra” e reabre decisões já resolvidas. | Produção de estados sem mecânica e repetição do Lote 0. | Atualizar catálogo, próxima ação e estado real; consultar decisões 034–036 do checkout. |

A V3 do 13A continua **em revisão e exige retrabalho artístico**. A comparação recente não prova equivalência com o conceito. Os números 01–15 e mangue/água/pedras V8 continuam aprovados como conceitos, conforme o prompt V16; isto não aprova suas versões de produção.

---

## 2. Decisões obrigatórias

1. A direção vigente é **2D isométrica com volume low-poly e câmera fixa**. Modelos 3D e SVG procedural são meios de produção já presentes; o meio é escolhido pela qualidade visual, reprodução e custo no consumidor real.
2. O estilo é **tropical brasileiro, limpo, vibrante e cheio de personalidade**, traduzido para o pipeline isométrico atual.
3. A antiga orientação top-down/64 px do GDD congelado está superada pelo contrato espacial atual. Não misturar convenções.
4. Não usar contorno preto, Freestyle ou filtro de borda. Essas soluções já foram testadas e rejeitadas.
5. Silhuetas serão separadas por valor, contraluz, oclusão, material e espaço negativo.
6. A paleta tropical governa o mundo; o azul-marinho `#1A3A5C` permanece como base do HUD.
7. Imagens geradas são referências até passarem por preparação, proveniência, exportação e testes do consumidor. Não promover uma imagem a asset pronto apenas porque foi gerada ou aprovada em prancha.
8. Preservar o consumidor de animação existente durante a primeira prova visual. Skeleton2D é uma evolução a validar para personagens, não uma condição para desenhar todo asset. Partes móveis, Tween e estados entram apenas onde exista uso real; quadro a quadro continua exceção justificada.
9. O trabalho começa pelo Vertical Slice da F1, sem refazer o projeto.
10. F2–F5 ficam como catálogo e especificação até o Kit F1 passar pelos gates técnicos, visuais e mobile.
11. A frente de arte avança em paralelo ao Claude Code, mas não altera economia, save, viewport, projeção, `# TUNING:` ou baselines protegidos dentro de uma entrega puramente visual.
12. Integração só ocorre para assets comprovadamente consumidos pelo jogo.
13. Preservar a arquitetura atual do HUD nesta frente. Mudanças de UI exigem inspeção do consumidor e tarefa própria. Tipografia legível e alvos de toque devem ser testados no dispositivo, com unidades lógicas e escala declaradas; 12/44 px do V2 são metas internas iniciais, não garantia de tamanho físico.

### Paleta do mundo

| Papel | Cor |
|---|---|
| Azul Oceano | `#2B7FBF` |
| Laranja Porto | `#E8621A` |
| Verde Mangue | `#3A9E52` |
| Areia Quente | `#E8C97A` |
| Vermelho Casco | `#C43030` |
| Branco Espuma | `#F0F0E8` |
| Roxo Noite | `#3D2A6E` |
| Cinza Concreto | `#7A7A72` |
| Base do HUD | `#1A3A5C` |

F1 usa versões mais gastas e menos saturadas. F5 usa contraste industrial mais forte, sem abandonar a mesma família cromática.

---

## 3. Contrato espacial e técnico

| Item | Regra vigente |
|---|---|
| Projeção | isométrica 2:1 |
| Câmera Blender | ortográfica, `ROT_X = 60°`, `ROT_Z = 45°` |
| Escala de desenho | `MEIA_LARG = 30`, `MEIA_ALT = 15` |
| Escala em tela | meia-largura de 20 px após `ZOOM = 2/3` |
| Célula projetada | losango de 40 × 20 px em tela |
| Quadro lógico do prop | 512 × 512 |
| PNG de props existentes | preservar contrato 768 × 768 quando usado; não impor canvas desse tamanho a toda folha/tile |
| Viewport do jogo | 720 × 1280, retrato |
| Área atual do mapa | 720 × 720 coordenadas lógicas; janela local observada 720 × 660 |
| Origem | ponto de contato com chão, água ou base da estrutura |
| Profundidade | ordenação coerente com posição no mapa e `z_index` |
| Gerador por família | props: `gerar_props_iso.py`; terreno/vila: `gerar_mapa_iso.py`; confirmar consumidor antes da escolha |
| Destino atual | `brport_vs/art/props/` |
| Fonte de verdade | scripts reproduzíveis; `.blend` não é versionado |
| Saída versionada | PNG consumido pelo Godot + manifest + cena/teste |

### Regras para partes móveis

- pivô e origem documentados;
- repouso coincidente com o asset estático;
- pausa e retomada sem acumular posição;
- pegada lógica imutável durante a animação;
- partes fora da tela param ou reduzem atualização;
- cópias iguais não se movem em sincronia artificial;
- rotação 2D não pode quebrar a perspectiva isométrica;
- quando a transformação revelar perspectiva incorreta, usar poses renderizadas limitadas e aprovadas.

---

## 4. Governança da arte em paralelo ao GitHub

### Responsabilidades

| Frente de assets | Frente de código/integração |
|---|---|
| Interpreta referência, produz a peça, fontes reproduzíveis, variantes e provas. | Confirma consumidores, cena, estados, rotas, colisões e importação. |
| Trabalha em pasta própria ou branch/worktree exclusivo de arte. | Controla merges, migração de manifests e testes no commit de destino. |
| Entrega pacote versionado e lista exata de mudanças propostas. | Resolve conflitos, faz capturas reais e aplica o pacote depois dos gates. |

### Abertura de cada fatia

1. Fixar `base_commit`, versão do contrato espacial e hashes dos arquivos lidos. Um checkout local antigo não representa automaticamente o GitHub atual.
2. Registrar `asset_id`, revisão, proprietário, consumidor previsto, arquivos de entrada, saídas e arquivos de integração possivelmente afetados.
3. Usar laboratório isolado: `art-lab/f01/<asset_id>/<revisao>/`. Se for necessário experimentar o gerador compartilhado, usar cópia/worktree isolado ou adaptador em memória.
4. Nunca sobrescrever fonte, mapa ou manifesto da outra frente para preparar uma prévia. Arte pode avançar até `review` enquanto integração/mobile estão pendentes.
5. Registrar um congelamento curto somente dos arquivos afetados no momento da integração; não bloquear todo o desenvolvimento.

### Handoff verificável

- `README`: peça, propósito, estado, instruções e limitações.
- Fonte reproduzível e comando de exportação, dependências/versões e parâmetros.
- Original/referência, hashes, proveniência e autorização/licença registrada.
- Saídas de jogo com destino proposto; previews separadas e explicitamente identificadas.
- Âncora, pegada, câmera, estados, seeds por identidade, unidades e orçamento.
- Antes/depois sobre a mesma base e render; provas de falha dos testes relevantes.
- Relatório de qualidade e gates pendentes. Aprovações vinculadas ao hash da candidata.
- Patch proposto pequeno ou instruções de integração; nunca entregar mapa completo antigo para sobrescrever o atual.
- Conferência do hash da base no destino. Em divergência, adaptar sobre a base atual e repetir somente as provas afetadas.

**Checkout desta sessão:** existem mudanças locais anteriores em `tools/gerar_mapa_iso.py` e nos dois mapas. Preservar esse WIP e isolá-lo antes de novos ajustes. A auditoria V3 não remove, faz commit ou publica essas mudanças.

São de alto conflito: `Main.tscn`, `Main.gd`, geradores de props/mapa, manifests, baselines e import presets. Alterações de economia, save, número de docas, rotas e `# TUNING:` continuam fora de uma fatia de arte.

---

## 5. Auditoria do estado atual

### 5.1 Assets existentes e aproveitáveis

- Píeres: `pier_vazio`, `pier_n1`, `pier_n2`, `pier_n3`.
- Guindaste: `lanca_n1`, `lanca_n2`, `lanca_n3`, `guincho`.
- Estruturas: `galpao_velho`, `galpao`, `escritorio_ruina`, `escritorio`, `doca_concreto`.
- Pesca: bote, traineira e arrasteiro.
- Comércio: barcos médios e grandes para carga geral, contêiner e granel.
- Veículos: caminhões por tipo de carga em duas orientações, empilhadeira.
- Props: barreira, boia, bote, cabeço, cone, marcador, pallet, pilha de caixotes, pneus, postes.
- Personagem operacional: trabalhador.
- Vegetação: tronco e copa do coqueiro separados.
- Fauna: gaivota, maria-farinha, tartaruga-verde, cachorro caramelo, quero-quero e capivara.
- Ambiente: mapa SVG, água em camadas, espuma e vias.

### 5.2 Animações existentes que devem ser preservadas

- chegada e balanço do barco;
- boia subindo e descendo;
- copa do coqueiro com rajadas assíncronas;
- caminhões percorrendo estrada e acessos de doca;
- movimento sutil da lança;
- movimento básico de trabalho;
- ondas/espuma por camadas;
- ciclos procedurais de fauna.

### 5.3 Arte ainda não aprovada para o mapa principal

Os PNGs de casa costeira, mercado, arbusto e tiles em `art/brp/` pertencem à cena de teste. A casa focal desenhada pelo gerador SVG é outra saída, consumida no mapa e ainda em revisão técnica. Mangues norte/sul também têm consumidores observados. Conferir a identidade da saída, sem inferir integração por nome parecido.

---

## 6. Identidade, consumidor e dossiê de qualidade

### Manifest do jogo e dossiê de arte

O manifesto de produção existente continua obedecendo ao seu schema real: por exemplo, `output` é lista e o método estático é `static`. Não copiar o exemplo incompatível do plano V2. A frente de arte não migra esse schema silenciosamente.

O pacote de arte acrescenta um **dossiê próprio**, com:
- `asset_id`, revisão e estado artístico: concept / blockout / review / approved_for_integration / superseded;
- `integration_status`: not_integrated / prototype / integrated;
- `release_ready`: resultado explícito dos gates, nunca inferido de “production” no manifest legado;
- base do código, hash da fonte candidata e hash de cada exportação;
- referência exata, região de interesse, interpretação e desvios aceitos;
- consumidor real ou destino de teste; estados e controlador quando existir;
- pegada, âncora, câmera, unidades, escala lógica, raster e dispositivo;
- fonte/receita, seeds e IDs estáveis;
- evidências por teste, método de captura e plataforma;
- revisão humana por critério, observações e aprovação de Bruno para aquela revisão.

### Regras

Um nome de script de teste não é prova de execução. Uma prévia não é a saída consumida. Uma imagem estática montada não é captura do Godot. Um asset já em uso pode continuar com qualidade pendente.

Só declarar `release_ready` quando os gates aplicáveis estiverem atendidos, com evidência e hash atuais. `N/A` exige justificativa por família, como ausência de animação em uma moita estática. Nunca converter “não executado” em “aprovado”.

---

## 7. Estado das decisões e do catálogo

### Decisões observadas no checkout local

A decisão 034 resolve as questões do Lote 0: oficina N1 prevista na F2 e expansão na F3; três berços comerciais, um inicialmente ativo; vagas de pescadores são sistema separado; cidade estática no gerador; noite/clima após o kit visual. F2–F5 continuam condicionadas a consumidores.

A decisão 035 mantém a casa focal no gerador SVG. A 036 preserva galpão em ruína/recuperado; compra instantânea não consome arte “em obra”. Conferir novamente no commit que receberá a integração, sem reabrir escolhas por falta de contexto.

### Aprovações visuais

- Conceitos 01–15 aprovados conforme V16. Casas em orientações e vias/calçadas são 08/09, já incluídas nessa rodada; aprovação conceitual não comprova módulos prontos.
- Mangue/água/pedras V8: direção conceitual aprovada.
- Arbusto 13A V3: candidato em revisão, com falhas técnicas e diferença artística ainda relevantes.
- Não criar estados ou animações adicionais só para completar uma prancha.
- Não recomeçar o Lote 0 nem ignorar conceitos aprovados. Fazer apenas a atualização de compatibilidade e das provas faltantes.

---

## 8. Leitura da imagem-conceito

### 8.1 Elementos aproveitados

| Grupo | Elementos | Tradução para produção |
|---|---|---|
| Água e costa | profundidade, espuma, rocha, praia, mangue | mapa + máscaras + módulos estáticos |
| Vila | casas térreas, muros, cercas, postes, estrada | gerador + poucas variações controladas |
| Porto inicial | galpão, escritório, cais, píer, grua | reaproveitar/refinar e criar só estados necessários |
| Operação | caminhão, empilhadeira, caixas, pallets, contêiner | variantes ligadas ao tipo de carga |
| Embarcações | pesca, trabalho e comércio | frota atual + famílias exigidas por sistemas futuros |
| Navegação | boias, defensas, cabeços e luzes | kit modular |
| Natureza | coqueiros, arbustos, mangue, aves | variedade de silhueta com animação leve |

### 8.2 Ajustes para celular

- reduzir microdetalhes invisíveis na escala real;
- preservar áreas livres para docas, trabalhadores e rotas;
- repetir módulos com 2–4 variações de cor/desgaste;
- separar casco/água/cais por espuma, valor e sombra;
- evitar textura ruidosa;
- manter F1 modesta: uma grua principal, pouca carga e construções pequenas;
- usar a meta inicial de 44 unidades lógicas para toque e verificá-la no aparelho, mesmo quando o sprite for menor.

---

## 9. Catálogo F1–F5

Legenda: `E` existente; `R` refinar; `N` novo; `V` variante; `B` bloqueado até consumidor/decisão.

### 9.1 F1 — O que o avô deixou

| Asset/família | Estado | Função/estados | Animação | Prioridade |
|---|---:|---|---|---:|
| Costa, água e espuma | R/V | ambiente base | partículas/máscaras | P0 |
| Mangue modular | R | remates norte/sul observados; reconstruir a direção V8 | estático nesta fatia | P1 |
| Casa costeira | R/N | 1 módulo aprovado | estático | P1 |
| Mercado de peixe | B | depende da decisão da cidade | porta/toldo opcional | P2 |
| Galpão | E/R | ruína, recuperado | troca de estado existente | P0 |
| Escritório | E/R | ruína, operacional | luz/porta apenas se consumidas | P1 |
| Píer original | E/R | vazio, N1–N3 conforme decisão | troca de estado | P0 |
| Doca básica | E/R | livre, ocupada, trabalhando | Tween/realce | P0 |
| Grua enferrujada | E/R | idle, working | camadas/Tween | P0 |
| Pesca | E/R | 3 portes | Tween + esteira leve | P0 |
| Cargueiros | E/R | médio/grande × 3 cargas | Tween + fumaça compatível | P1 |
| Caminhões | E/R | 4 cargas × 2 direções | rota por Tween | P0 |
| Empilhadeira | E/R | vazia/com pallet | rota + garfo em camada | P1 |
| Props de carga | E/R/V | combinações limitadas | estático | P1 |
| Sinalização | E/R/V | dia/noite se houver sistema | boia/luz | P1 |
| Trabalhador | E/R | facing usado pela doca | consumidor atual; rig em fatia própria | P0 |
| Fauna | E/R | espécies já integradas | procedural existente | P2 |

### 9.2 F2 — Porto com identidade própria

| Estrutura/família | Estado | Assets associados | Animação | Gate |
|---|---:|---|---|---|
| Posto de abastecimento | N/B | tanque, bomba, tubo, mangueira | bomba/luz | sistema de abastecimento |
| Câmara frigorífica | N/B | caixas térmicas, pallets, condensador | ventilador/vapor | carga refrigerada |
| Segundo píer | N/B | defensas, cabeços, acesso | construção/ocupação | expansão funcional |
| Área coberta de carga | N/B | toldo, pallets, sinalização | bandeirola opcional | fluxo de carga |
| Escritório administrativo | N/B | placas e mobiliário visível | luz/porta | contratos/administração |
| Oficina naval N1 | N/B | cavaletes, ferramentas, solda | porta/faísca | decisão F2/F3 |
| Calçadão/orla | N/B | bancos, postes, comércio | ambiente leve | cidade integrada |

### 9.3 F3 — Porto regional

| Estrutura/família | Estado | Assets associados | Animação | Gate |
|---|---:|---|---|---|
| Terminal de passageiros | N/B | ferry, bagagem, passarela | porta/fluxo | transporte de passageiros |
| Armazém climatizado | N/B | carga e condensadores | ventiladores | armazenagem avançada |
| Torre de controle N1 | N/B | radar, antenas, balizas | radar/luz | rotas regionais |
| Manutenção naval N2 | N/B | guincho, peças de casco | solda/ponte | expansão da oficina |
| Memorial do avô | N/B | peças narrativas | troca de estado | arco do memorial |
| Placa oficial | N/B | bandeira/sinalização | bandeira em camada | avanço da fase |

### 9.4 F4 — Porto nacional

| Estrutura/família | Estado | Assets associados | Animação | Gate |
|---|---:|---|---|---|
| Terminal de contêineres | N/B | contêiner normal/reefer, carreta | fluxo operacional | carga de contêiner |
| Aduana | N/B | cancela, inspeção, placas | cancela/luz | fiscalização |
| Plataforma de granel | N/B | moega, silo, correia, tubos | correia/poeira | granel |
| Torre de controle N2 | N/B | radar ampliado | radar/baliza | avanço da torre |
| Alojamento | N/B | módulos e sinalização | luzes | tripulação |
| Pórtico de contêiner | N/B | trolley, spreader, cabos | camadas/Tween | terminal ativo |
| Heliponto | N/B | luzes e helicóptero opcional | luz/rotor sob evento | uso real confirmado |
| Pátio modular | N/B | pilhas 25/50/100% | troca discreta | ocupação de carga |

### 9.5 F5 — Grande porto e estaleiro

| Estrutura/família | Estado | Assets associados | Animação | Gate |
|---|---:|---|---|---|
| Doca seca | N/B | portão, bombas, nível visual | estado/camadas | reparo/construção naval |
| Navio em construção | N/B | quilha, blocos, casco, acabamento | troca discreta/faísca | obra naval |
| Pórtico pesado | N/B | trolley, cabo e carga | camadas/Tween | estaleiro ativo |
| Oficina industrial | N/B | portas, exaustão, solda | camadas/partículas | montagem |
| Almoxarifado | N/B | peças e pallets | troca discreta | logística industrial |
| Área industrial modular | N/B | pavimento, vias, cercas e utilidades | ambiente leve | expansão separada aprovada |
| Terminal especializado | N/B | família definida pela função | conforme função | mecânica aprovada |
| Canal profundo | N/B | boias e balizamento | água/boia | dragagem/rota oceânica |
| Draga | N/B | tubos/flutuadores | lança/sedimento | operação de dragagem |
| Farol renovado | N/B | lente, feixe, baliza | luz/feixe | marco visual/narrativo |
| Rebocador de apoio | N/B | cabos e defensas | chegada/balanço | apoio ao estaleiro |

### 9.6 Cidade e narrativa

Produzir apenas quando a cena/interação estiver confirmada:

- casa do protagonista;
- mercado de peixe;
- Bar do Mané;
- Banco de Porto Mirim;
- Memorial do avô;
- Porto Farol/farol rival;
- hotelaria e aeroporto apenas como contexto tardio, sem gestão ativa.

---

## 10. Arquitetura de animação

### 10.1 Métodos permitidos

| Código | Método | Uso |
|---|---|---|
| `T` | Tween/AnimationPlayer | posição, rotação, escala e opacidade |
| `L` | camadas/partes móveis | máquinas rígidas e portas |
| `R` | rig/Skeleton2D | personagens e partes articuladas |
| `P` | partículas/shader/máscara | água, espuma, fumaça, poeira e faísca |
| `S` | troca discreta | construção, ocupação e níveis |
| `X` | exceção pré-renderizada | apenas quando a perspectiva não funciona por transformação |

`X` exige justificativa e aprovação. Não é solução padrão.

### 10.2 Máquina de estados visual

Modelo de referência para consumidores futuros. Implementar apenas os estados já usados pelo sistema receptor; não criar `starting`, `stopping` ou `disabled` por obrigação desta tabela.

| Estado lógico | Visual | Entrada | Saída |
|---|---|---|---|
| `idle` | repouso | estrutura disponível | trabalho iniciado |
| `starting` | arranque curto | evento de serviço | arranque concluído |
| `working` | ciclo operacional | serviço ativo | concluído/cancelado |
| `stopping` | retorno controlado | fim do serviço | repouso |
| `disabled` | parado + sinal visual | bloqueio real | reativação |

Regras:

- gameplay emite eventos; a arte reage;
- animação nunca decide resultado;
- fim visual não bloqueia o turno;
- pular/desativar animação não muda o gameplay;
- retorno a `idle` é idempotente;
- estrutura só trabalha quando o sistema correspondente estiver ativo.

### 10.3 Exemplos de eventos

- doca iniciou serviço → grua `starting` → `working`;
- doca concluiu serviço → grua `stopping` → `idle`;
- reparo naval iniciou → oficina acende + faíscas em pulsos;
- fluxo de contêiner iniciou → pórtico move trolley/spreader;
- câmara fria ativa → ventiladores e vapor leve;
- construção concluída → troca `obra` → `pronta` com feedback curto.

### 10.4 RNG visual e determinismo

- não usar RNG de `GameState` para efeitos;
- usar RNG separado por ID estável de instância e canal (posição, forma, animação); acrescentar sorteios em um canal não desloca os outros;
- capturas CI fixam a semente visual;
- visuais ligados/desligados precisam produzir o mesmo resultado econômico;
- um mutante que troca o RNG visual pelo econômico deve reprovar.

### 10.5 Personagens

Na fatia futura de rig, o trabalhador pode passar a usar partes e Skeleton2D, depois de validar o ganho sobre o consumidor atual. Partes previstas:

- cabeça/rosto;
- tronco;
- braços/antebraços;
- mãos/ferramenta;
- pernas/pés;
- capacete/acessório;
- sombra separada.

Estados previstos dessa fatia, condicionados ao consumidor:

1. `idle`;
2. `work_load`;
3. transição curta entre os dois.

`walk`, `talk`, `work_repair`, `tired` e quatro direções só entram quando houver consumidor real. O Kit F1 usa o facing exigido pela doca atual.

### 10.6 Efeitos ambientais

- água: gradiente e máscaras em tempos diferentes;
- espuma: pulsos locais, nunca toda a costa sincronizada;
- barcos: esteira apenas em movimento;
- fumaça: apenas em embarcação/máquina compatível;
- construção: poeira curta sem bloquear input;
- oficina: faíscas em pulsos;
- noite futura: emissivos discretos e balizas;
- low-end: reduzir emitters, mantendo Tweens essenciais.

---

## 11. Estados por tipo de asset

Não aplicar nove estados a toda estrutura.

| Tipo | Estados mínimos |
|---|---|
| Estrutura herdada F1 atual | ruína, recuperada; obra somente com consumidor futuro |
| Estrutura nova simples | pronta; ghost/obra somente se existirem colocação ou construção |
| Estrutura com upgrade | níveis usados; ghost/obra condicionados à mecânica real |
| Máquina operacional | idle, working; disabled somente se houver regra |
| Estrutura narrativa | estados pedidos pelo arco |
| Pátio/carga | ocupação discreta 25/50/100% quando útil |

Regras:

- “danificada” só existe com causa, efeito e reparo;
- “selecionada” usa shader/decal/ícone, nunca PNG duplicado;
- nível precisa alterar silhueta, equipamento, ocupação ou altura; cor sozinha não basta;
- ghost válido/inválido combina forma, símbolo e cor.

---

## 12. Mobile, memória e desempenho

Um PNG RGBA 768×768 representa aproximadamente 2,25 MiB sem compressão. Cinquenta e um assets desse tamanho representariam cerca de 115 MiB se todos estivessem residentes sem compressão/descarregamento. O valor real depende da importação e do carregamento, mas impede criar um PNG grande para cada estado sem orçamento.

### 12.1 Baseline antes do Kit F1

Medir:

- FPS mediano e pior frame relevante;
- tempo de abertura da cena;
- memória total e de textura, quando disponível;
- nós de desenho ativos;
- partículas simultâneas;
- tamanho do APK e `.pck` Web;
- tempo de importação e carregamento.

### 12.2 Gate provisório por lote

- nenhuma regressão superior a 10% em frame, carga ou memória sem justificativa e aprovação;
- Samsung A23 3 GB como aparelho de entrada;
- 30 FPS estáveis como piso no aparelho de entrada;
- 60 FPS como alvo em aparelho intermediário;
- partículas, sombras e animações ambientais com modo reduzido;
- animações fora da tela param;
- assets F2–F5 não carregam na F1 sem necessidade;
- limites definitivos substituem os provisórios após a primeira medição real.

### 12.3 Toque e acessibilidade

- alvo inicial de toque 44 unidades lógicas, validado fisicamente no aparelho; declarar escala e densidade;
- hitbox independente do alfa do PNG;
- seleção por decal + ícone + modulação;
- estados não dependem apenas de verde/vermelho;
- oclusão de unidade interativa exige transparência, prioridade ou reposicionamento;
- leitura testada em coordenadas lógicas e em captura física do aparelho. Uma imagem de 720 px exibida pelo chat com redimensionamento não comprova tamanho físico.

---

## 13. Importação, proveniência e ciclo de vida

### 13.1 Presets de importação

Definir e documentar presets para:

- mapa/SVG;
- prop estático;
- parte móvel;
- retrato;
- partícula/máscara;
- ícone de UI.

Cada preset decide filtro, compressão, mipmap, repetição, memória e compatibilidade mobile. Não depender de configuração manual arquivo a arquivo.

### 13.2 Proveniência

Registrar:

- prompt e prompt negativo de conceito gerado;
- imagem/referência usada;
- ferramenta e data;
- licença/posse;
- hash do original;
- transformações aplicadas;
- responsável pela aprovação.

Serviço pago exige autorização prévia e teto de gasto. Credenciais nunca entram em arquivo, argumento, log ou conversa.

### 13.3 Ciclo de vida

- renomear migra consumidores e manifest no mesmo PR;
- asset substituído vira `deprecated`, histórico ou removido com destino explícito;
- não manter duas fontes vivas para a mesma saída;
- rollback restaura script, saída, cena e manifest juntos;
- `.blend` continua fora do Git; scripts são a fonte reproduzível.

---

## 14. Pipeline que protege a qualidade visual

### A — Brief de uma peça

Escolher o componente exato da prancha e três a cinco traços essenciais: silhueta, relação de massas, material, luz e papel no mapa. Incluir exemplos de erro. Fixar o tamanho pretendido ao lado de casa, rua e cais. Se a referência for um agrupamento, decidir se a peça é o grupo ou um componente; não trocar essa interpretação durante a execução.

### B — Prova de linguagem

Fazer um estudo curto na câmera e escala corretas. Aprovar forma e volume antes de adicionar detalhes. Se o método produz blocos onde a referência exige folhas orgânicas, testar outra construção de superfície, outra modelagem ou render. Uma comparação “menos ruim que a anterior” não encerra o gate.

Depois de duas iterações que mantêm o mesmo defeito estrutural, parar o acréscimo de detalhes e rever o método. Podem existir experimentos internos; apresentar uma candidata consolidada por vez a Bruno.

### C — Material e detalhe útil

Hierarquia de detalhes:
1. massa/silhueta e encaixe;
2. planos de luz/sombra e identidade do material;
3. poucos detalhes característicos que sobrevivem à escala;
4. microdetalhes somente quando demonstrado seu benefício.

Testar contraste no fundo real. Usar desgaste localizado e ligado à função. Mais polígonos, cores ou folhas não é critério de avanço.

### D — Ensaio contextual isolado

Mostrar a mesma revisão/instância em:
- enquadramento completo da F1;
- três locais representativos, incluindo um caso de oclusão e uma área de contraste difícil;
- dois estados do cenário, se o consumidor os usa;
- densidade baixa e composição prevista para a família;
- escala lógica real e recorte ampliado identificado.

Comparar com a base sem deslocar câmera, objetos, luz ou HUD. Só pedir avaliação estética depois de corrigir sobreposição em portas, vias, docas e pontos de interação.

### E — Exportação e entrega artística

Fonte e saídas precisam reproduzir a mesma instância mostrada na folha. Conferir alfa, limites, cores, sombra, orientação, revisão e nomes. JPG é prévia opaca para Android; PNG/SVG são classificados como referência, representação ampliada ou saída de jogo. Assinar os arquivos com hashes no pacote.

### F — Integração pela frente de código

Conferir base atual, aplicar a mudança pequena, respeitar fontes canônicas e consumidores. Fazer import/captura de runtime com preset real e reexecutar provas afetadas. A captura estática permite avançar a revisão artística, mas G6 permanece pendente.

### G — Aceite e publicação

Bruno avalia a revisão exata já demonstrada. A integração final depende também do gate mobile. Arquivar motivos da aprovação, falhas e desvios aceitos. Mudanças posteriores de forma, escala, material, luz ou contexto invalidam as respectivas provas.

---

## 15. Gates com critérios visuais e técnicos

| Gate | Critério de saída | Evidência necessária |
|---|---|---|
| G0 — Decisão | componente da referência, função e consumidor claros | brief com região marcada, IDs, estados e base |
| G1 — Forma | silhueta, proporção e volume corretos | escala compartilhada, vista isolada e três posições |
| G2 — Visual | linguagem orgânica/industrial apropriada, luz/material coerentes e boa composição | comparação justa + revisão por critério, sem defeito crítico |
| G3 — Animação | estados corretos, sem atravessamentos, drift ou quebra de perspectiva | sequência temporal e teste de transição; N/A justificado para estáticos |
| G4 — Reprodutibilidade | forma não desloca posição nem altera simulação | hashes + seeds isoladas + injeção de sorteios + teste de gameplay na integração |
| G5 — Mobile | custo e legibilidade no alvo | captura física, carga/memória/frame antes/depois no mesmo cenário |
| G6 — Integração | saída correta realmente aparece e preserva interação | runtime no commit receptor, masks/oclusão, cenas e estados relevantes |
| G7 — Ferramentas | testes detectam defeitos e evidências correspondem à revisão | resultados legíveis, testes negativos, hashes e logs |
| G8 — Humano | Bruno aprova a revisão apresentada | decisão registrada com arquivo/hash e contexto |

**A revisão artística de G2 reprova se:** forma parece um objeto errado; peça fica colada/flutuando; orientação/luz diverge; perde identidade na escala de uso; chama atenção além de sua função; prejudica a leitura de casas, vias ou operação. Um único defeito crítico impede avanço. Não usar média de notas para compensar um defeito desses.

A opinião do gerador é uma autoavaliação. Não apresentá-la como aprovação independente. Bruno fecha G8. Métricas de paleta, erro de pixel, SSIM, similaridade de IA ou área ocupada nunca substituem essa decisão.

### Execução de testes

Exigir relatório com PASS / FAIL / PENDING / N/A justificado. Logs devem registrar execução concluída, artefatos esperados e ausência de erros relevantes. Testar ao menos um defeito introduzido para cada guarda crítica nova. Não atualizar baseline para tornar o resultado verde.

---

## 16. Lotes e ordem de trabalho revisados

O Lote 0 já tem decisões e contratos no checkout observado. Atualizá-lo por diferença de base, sem recomeçar toda a etapa.

1. **Piloto 13A:** corrigir o brief, a linguagem visual e o acoplamento de RNG no laboratório isolado; prova artística antes da integração.
2. **Ambiente F1:** aplicar a direção V8 no gradiente, raízes e pedras com módulos/gerador compatíveis. Água e areia derivam da mesma costa. Provar remates, transições e recortes.
3. **Estruturas F1:** estados usados de galpão, escritório, grua, píer e doca; preservar contratos existentes.
4. **Operação F1:** barcos, trabalhador, caminhão e cargas com fluxo visual legível.
5. **Animação F1:** somente consumidores existentes; pausar, retomar, sair da tela e variar carga.
6. **Polimento e mobile:** começa com medidas básicas em cada piloto; não deixar todas as decisões de escala/desempenho para o fim.
7. **F2–F5:** catálogo condicionado ao consumidor; repetir os gates aplicáveis.

Variantes de casa (08) e vias/calçadas (09) continuam no catálogo aprovado conceitualmente. Produção modular vem depois da prova de família, sem alterar as rotas funcionais. Noite/clima, redesign do HUD e novas mecânicas exigem tarefas próprias.

---

## 17. Kit mínimo de prova

Entregar progressivamente:

1. um asset estático de ambiente com referência e identidade bem definidas;
2. uma casa e um remate costeiro coerentes com o mapa;
3. galpão apenas em ruína/recuperado;
4. um conjunto operacional píer/grua/barco/trabalhador usando os estados atuais;
5. fonte, exportação, parâmetros e provas por peça;
6. captura contextual no Godot e medição mobile antes de liberar para produção.

Não exigir simultaneamente mudança de rig, nova animação, várias orientações e nova integração para aprovar a linguagem de uma moita. A versão do trabalhador em Skeleton2D é uma fatia posterior, se o consumidor e o ganho a justificarem.

---

## 18. Matriz de testes a acrescentar

| ID | Teste e modo de executar | Reprova quando | Execução nesta revisão |
|---|---|---|---|
| Q01 | Identidade: hashes de referência, fonte, candidato e evidências | arquivo ausente/trocado ou aprovação de outra revisão | Implementado no kit isolado |
| Q02 | Referência: componente marcado, contexto completo, crop sem ambiguidade | árvores/partes vizinhas são julgadas como se fossem o asset | Revisão manual: pendente para 13A |
| Q03 | Forma: comparar silhueta sem cor, proporções e planos de volume | arbusto lê como pilha de blocos; barco perde casco; casa perde orientação | Revisão manual de 13A: retrabalho recomendado |
| Q04 | Material/luz: cor e tons de cinza no fundo real, sombra de contato | flutuação, sombra incompatível ou material sem leitura | Protocolo definido; nova candidata deve fornecer provas |
| Q05 | Escala: base/candidata com a mesma transformação e referência de tamanho | “1:1” sem unidades; candidato normalizado independentemente para parecer semelhante | Metadados adicionados; dispositivo pendente |
| Q06 | Composição: três locais, densidade prevista, sem seleção/destaque artificial | repetição em carimbo, excesso de ruído ou perda da hierarquia do porto | Protocolo definido; captura runtime pendente |
| Q07 | Áreas protegidas: máscara independente de portas, rotas, docas/interações | qualquer nova cobertura proibida ou geometria deslocada | Guarda de máscara implementada; máscara real pendente |
| Q08 | Exportação: alpha, limites e fundos claro/escuro/texturizado | fundo opaco indevido, borda cortada, halo ou sombra duplicada | Alpha/canvas automatizados; halo exige inspeção |
| Q09 | Costura: repetir e combinar módulos/orientações/transições | emenda reta indevida, escala quebrada ou interseção impossível | Aplicável a vias/costa; N/A ao arbusto isolado |
| Q10 | RNG: acrescentar sorteios à forma; comparar IDs e posições | detalhe desloca instâncias, animação ou simulação | Detectou falha atual; proposta isolada passa |
| Q11 | Instância: exportar a mesma seed/parâmetros da cena | specimen e objeto no mapa divergem sem declaração | Passou na primeira instância atual; a ordem de sorteios ainda é frágil, repetir após cada revisão |
| Q12 | Estados/oclusão temporal: início, ciclo, fim, pausa e reload | atravessamento, drift, perspectiva quebrada ou estado inexistente | Frente de código; N/A estático justificado |
| Q13 | Runtime/mobile: capturar e medir nas mesmas condições | regressão fora do orçamento ou detalhe ilegível no dispositivo | Pendente; imagem Inkscape não fecha este teste |
| Q14 | Entrega: PNG/SVG de uso, JPG opaco individual e links reais | preview passa por asset, revisão errada ou arquivo não abre | Arquivos classificados; confirmação Android depende de Bruno |
| Q15 | Paralelismo: conferir base/hash e propriedade antes de aplicar | mudança sobrescreve o código atual ou baselines da outra frente | Política e verificação de fonte fixada no kit |

### Critérios por família

- **Vegetação:** folhagem com escala e contorno orgânicos, variação controlada, contato com solo, densidade sem tapar a vila; raízes de mangue apenas no contexto costeiro.
- **Casas:** volumes e telhado coerentes, portas acessíveis, sombras na direção comum; nova orientação exige reconstrução, não giro do bitmap.
- **Vias/calçadas:** largura e elevação coerentes, T/cruzamento/curvas e acessos sem costura; colisão/rotas pertencem à integração.
- **Costa:** continuidade da linha de água, fade das bordas, raízes assentadas, pedras pequenas irregulares e ausentes da entrada dos píeres.
- **Barcos/máquinas:** casco/equipamento reconhecíveis a 1:1 lógico, cabo/âncora sob gravidade visual correta, partes móveis com pivô real.
- **Fauna/trabalhadores:** escala em relação à casa, poses reconhecíveis e contraste sem ampliar o animal para resolver detalhe.

A suíte entregue cobre guardas de arquivo, evidência, máscara e RNG. Ela **não implementa captura Godot, medição física ou uma decisão automática de beleza**.

---

## 19. Riscos e mitigação

| Risco | Sinal | Mitigação |
|---|---|---|
| Escopo explodir | muitos estados sem consumidor | matriz por função + G0 |
| Arte órfã | PNG sem cena exportada | manifest + varredura G6 |
| Conflito com Claude | mesmos geradores/cenas alterados | propriedade de arquivos + PR pequeno |
| Simulação mudar | resultados diferentes com efeitos | RNG visual + G4 |
| Mobile degradar | stutter, memória e carga | baseline + G5 |
| Perspectiva quebrar | peça gira “achatada” | camadas limitadas ou exceção X |
| Cena perder legibilidade | objetos encobrem docas/rotas | espaço negativo + oclusão/toque |
| Repetição artificial | cópias em sincronia | offsets determinísticos |
| Fase virar só recolor | mesma silhueta com outra cor | evolução de forma/equipamento |
| Baseline mascarar defeito | captura “aprovada” atualizada | proibir atualização sem causa comprovada |

---

## 20. Resultado esperado por fase

| Fase | Leitura visual imediata |
|---|---|
| F1 | cais herdado, gasto, pequeno e pessoal |
| F2 | porto local organizado, com serviços próprios |
| F3 | porto regional vivo, técnico e conectado |
| F4 | complexo nacional industrial, movimentado e regulado |
| F5 | grande porto costeiro capaz de construir e reparar navios |

O arco deve aparecer na silhueta, densidade, pavimentação, frota, organização e atividade das máquinas — nunca apenas em números maiores no HUD.

---

## 21. Próxima ação e prioridades

**P0 — antes de outra iteração de 13A**
1. Isolar o WIP de arte; confirmar base e dono dos arquivos da frente GitHub.
2. Selecionar a referência exata do arbusto e registrar os traços essenciais.
3. Refazer a construção de volume se a folhagem continuar parecendo blocos extrudados.
4. Separar RNG de posição e forma por ID; fazer a proposta passar no mutante antes de pedir integração.
5. Exportar a mesma instância na folha e no contexto. Entregar uma candidata revisada, sem reabrir aprovação conceitual.

**P1 — integração**
Produzir máscaras e capturas do Godot no commit receptor; resolver o status de qualidade em dossiê compatível com o manifest legado; validar mobile.

**P2 — demais melhorias**
Reconciliar estados do catálogo, organizar presets por família, revisar módulos de vias e orientações de casas, reduzir canvases somente após medição e usar variantes que melhorem a composição.

**Entrega desta revisão:** plano V3, relatório de auditoria, comparação visual anterior como evidência, contrato QA do 13A, script isolado e testes negativos. Os resultados com falha são preservados. Nenhum commit, PR ou alteração adicional no checkout compartilhado foi feito durante esta auditoria.

---
