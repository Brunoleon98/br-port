# Arquivo — o que aconteceu, e onde ficou registrado

Estes documentos **não estão obsoletos: estão terminados.** São o registro das
sessões que já fecharam — o que se tentou, o que se mediu, o que se decidiu e
por quê.

**Nada aqui se apaga.** Metade das armadilhas caras deste projeto está
registrada nestas páginas, e é por estarem registradas que não se repetiram: o
xadrez de transparência pintado nos pixels, o lote de arte em outra projeção, o
porto com 4 docas num mapa que desenha 3, o Freestyle que fechava o vazado da
treliça.

**Mas nada aqui descreve o jogo de hoje.** Um documento desta pasta que
contradiga o `ESTADO_DO_PROJETO.md` está errado por construção — ele descreve o
jogo do dia em que foi escrito, e é essa a função dele. Quem quiser saber como
o jogo está agora lê o ESTADO; quem quiser saber por que ele ficou assim lê
aqui.

## As quatro camadas, para saber quando NÃO vir a esta pasta

| Camada | Onde | Responde |
|---|---|---|
| Regras | `CLAUDE.md`, na raiz | O que nunca se faz aqui — e é o único que carrega sozinho |
| Estado | `docs/ESTADO_DO_PROJETO.md` | Como o jogo está hoje |
| Rumo | `docs/design/BR_Port_Plano_v3_Claude_Code.md` | O que vem a seguir, e quem faz o quê |
| Decisões | `docs/decisoes/NNN-*.md` | Por que se decidiu assim, uma por arquivo |

## O que há aqui

| Documento | Data | O que registra |
|---|---|---|
| `PLAYTEST_01_ANALISE.md` | 02/09 | **A primeira jogada no telefone** — a devolução do Bruno na íntegra e a triagem dela. Fechou o gate A1, e trouxe o bug que travava 30% das instalações novas no dia 1 |
| `PLAYTEST_02_ANALISE.md` | 06/09 | **A segunda jogada**, depois dos três níveis, da trava e da frota por serviço. 25 itens; quatro defeitos MEDIDOS (o cone no meio do asfalto, os seis blocos de cor chapada do pátio, os acessos que acabam no nada, e o camião do tamanho do escritório) e três coisas que não são melhorias — um segundo jogo, quatro decisões reabertas e uma pergunta de escala |
| `HISTORICO.md` | 25/08–13/09 | O caminho do projeto bloco a bloco, e os defeitos que cada playtest achou. Saiu do `ESTADO_DO_PROJETO.md`, que o carregava junto com o estado atual |
| `BLOCO3_MARCO_INTERMEDIARIO.md` | 26/08 | O playtest humano de 5 partidas, a medição do balanceamento e a decisão de ajustar antes de ir para a arte |
| `BLOCO4_BRIEFING_VISUAL.md` | 27/08 | A ordem de trabalho da arte: style guide, mapa com placeholder, sprites |
| `BLOCO4_PACOTE_SPRITES.md` | 28/08 | O pacote de sprites que chegou sem canal alfa, o que entrou e o que não |
| `BLOCO4_GUIA_GERACAO_ASSETS.md` | 28/08 | Prompts de gerador de imagem para os assets daquela leva |
| `BLOCO4_PROMPTS_VISUAL_CHAPADO.md` | 28/08 | A direção topo-down, **superada** no mesmo dia pela isométrica |
| `BLOCO4_PROMPTS_ISOMETRICO.md` | 28/08 | A direção isométrica em prompts — superada por gerar os props **por script**, que é a regra de hoje |
| `BLOCO4_BRIEFING_CONTINUACAO.md` | 28/08 | Ponto de entrada do Bloco 4, com três caminhos que foram todos fechados |
| `BLOCO5_BRIEFING_CONTINUACAO.md` | 29/08 | Ponto de entrada do Bloco 5, e o histórico das três oscilações da direção de arte |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-13.md` | 13/09 | Fecho da areia/fauna e prompt pronto para o primeiro recorte orgânico da costa |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-14.md` | 14/09 | Fecho das duas fatias do item 8 — a costa das pontas e o casco dos barcos — e o que sobrou dele |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-14b.md` | 14/09 | Fecho da alavanca A da resolução — o mapa a entregar os 1080 do arquivo — e o raster da água que sobrou |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-14c.md` | 14/09 | O raster da água construído a 1080, medido e REJEITADO — e a tabela de custo da `025` fechada com o APK e o Web |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-16.md` | 16/09 | A trilha de arte e a folha dos props — as duas metades de máquina do gate A5 — e a folha C, que é a sessão seguinte |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-18.md` | 18/09 | Fecho do R2 e do R3 da §7.1 — a evidência do CI a responder por erro e por turno, e o texto a responder pela fonte que a máquina corre — e o prompt do R4 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-20.md` | 20/09 | Fecho do R5 da §7.1 — a faixa de mensagem com fila, e as duas vozes a chegarem — mais a segunda leitura em voz alta (A4), e o prompt do R6 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-20b.md` | 20/09 | Fecho do R6 da §7.1 — o contraste medido na cor final contra o fundo real, 22 reprovações em 19 estados e hoje zero — e o prompt do R7 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21.md` | 21/09 | Fecho do R7 da §7.1 — o escopo da cor da UI: a superfície eram 34 e não 18, sete migraram e 27 ficaram declarados por (arquivo, receptor, propriedade) — e o prompt do R8 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21b.md` | 21/09 | Fecho do R8 da §7.1 — a concordância de plural: os três sítios nomeados eram oito, zero leva plural, e as guardas T9 e F9 são cegas ao defeito uma da outra — e o prompt do R9 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21c.md` | 21/09 | Prompt de um item FORA da §7.1 — os cinco painéis sem foto nenhuma, o `PainelCaixa` que não é capturável, e a guarda da bateria que não apanharia o erro dele |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21d.md` | 21/09 | Fecho das capturas E do portão de cobertura — os cinco painéis eram sete (são 15 e não 13), 24 tiros com `COBERTURA OK`, a varredura pergunta pela ORIGEM do erro e cada tiro tem teto de tempo — e a fila de volta ao R9 |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21e.md` | 21/09 | Fecho do R9 e da §7.1 INTEIRA — o sinal dos sons medido sem ouvir (true peak, descontinuidade, espectro), dois alertas por aritmética e o resto descritor, o protocolo de escuta entregue ao Bruno — e a fila ordenada a acabar |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-21f.md` | 21/09 | Fecho da 1ª LEVA das cores de UI — a barra escura inteira para o tema (27 chamadas em 19 locais → 17 em 11), com os valores intactos: as linhas do D33 idênticas e as 24 fotos byte a byte. E dois achados — o registro não diz quem CONSOME a peça, e cena que não carrega era invisível às duas réguas |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-22.md` | 22/09 | Fecho da 2ª LEVA das cores de UI — a faixa de mensagem inteira para o tema (17 em 11 → 11 em 8). E NÃO foi migração de valores: a régua nunca drenava a fila, logo três dos quatro estados do rótulo nunca tinham sido medidos, e o âmbar de marca reprovava a 3,07:1 sobre o creme. O percurso vai a 22 estados com `acao_vista`, e as 24 fotos nunca mostram a faixa colorida |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23.md` | 22/09 | Fecho das LEVAS 3 e 4 das cores de UI — o cartão da doca e o verde do Construir para o tema (11 em 8 → 1 em 1), as duas migração de VALORES. A 3ª achou uma CHAVE MORTA no percurso do D33 (a oferta do rival montava-se num campo que ninguém lê) e o X6 da `042` vivo em produção; a 4ª, que o PISO de uma contagem passava e que o `acao_vista` não serve a painel. Resta a borda do `Worker.gd`, que pede régua nova |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23b.md` | 22/09 | Fecho da 5ª e ÚLTIMA leva das cores de UI — a borda âmbar do trabalhador selecionado para o tema (1 em 1 → **ZERO**, lista de exceções vazia). É a única que nem o D33 nem as 24 fotos alcançavam: borda não é texto, e nenhum tiro selecionava trabalhador. Trouxe o **D34** (proveniência: o nó veste o RECURSO do tema, não um duplicado) e o **25º tiro**. Achados: asserção relacional contra o estado errado deixava passar o canal da cor, e uma borda tem DUAS adjacências (7,37:1 por fora, 2,24:1 por dentro) |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23c.md` | 22/09 | Triagem dos 11 órfãos de arte (`046`): saíram os 2 SVG de píer, superados por props PNG do mesmo nome; **ficaram os 9** que servem a bancada `AssetPlacementTest` e têm condição de regresso escrita (reabrir a `001`). «Órfão» e «apagável» são duas perguntas, e o relatório só faz a primeira. Medido: disco não é pacote (687 KB → 282 KB no `.pck`), o export não faz tree-shaking, e apagar um dos nove reprova o `asset_validator` |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23d.md` | 23/09 | A rua FICA em 1,8 (`047`): a janela que aperta é em `my` e o `RUA_RECUO` não a toca — o briefing errou o mecanismo. A mão dupla que faltava: dois camiões sobem pela faixa de dentro, de costas, com 8 silhuetas `_retorno`. A assinatura do D13/D17 não fazia a média que dizia; as folhas de contato passaram a 4 (frota, camiões, props 1–3) |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23e.md` | 23/09 | A saída de ré do berço ganhou guarda (`_d13_saida_de_re`, adenda da `047`): o D13 anima a saída pelo caminho do jogo e anda o tween com `custom_step`. Cinco mutantes; o M3 achou que o ramo `de_re` da `silhueta_do_trecho()` também não tinha guarda — função com guarda não é ramo com guarda. No A4 o Bruno decidiu: "caixa" → "dinheiro" (8 sítios), resultado → lucro/prejuízo (T10), "barcos esperando", e o vencimento diz hoje/amanhã/daqui a N (a conta estava um dia adiantada; T11). E o boletim MEDIDO: 2.005 afirmações falsas em 4.000 → 0, régua no CI; o Sr. Ribeiro deixou de perdoar quem perde o porto (`048`) |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23f.md` | 23/09 | O quadro dos props (`049`): os 60 de mapa importam pelo `texture_atlas`, a moldura sai da VRAM e a margem repõe os 768 — nenhum nó, âncora ou manifest mexido, sem `bpy`. VRAM em jogo 235,68 → 64,04 MB, `.pck` −17,4%. Os retratos ficam (atlas de 1024, 26% pior). Um `AtlasTexture` por cima de outro não compõe: as folhas gravaram quadros vazios com "Folha salva em", e hoje provam que esconder a peça muda a foto. Sete mutantes |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23g.md` | 23/09 | O âmbar da seleção (`050`): a troca «livre → escolhido» passou a ler-se pela COR num SELO em âmbar escuro no rótulo "Escolhido" (3,86 a partir do parado, 4,74 do livre, texto a 5,06). Nenhuma cor de borda servia — os vizinhos estão a 5,05:1 e o âmbar já estava no ótimo, 2,25 —, a troca que o jogador vê é PARADO → escolhido (1,33), e o cartão inteiro escuro engolia o retrato. A régua do contraste passou a ler o fundo de um `Label`; o reset do selo prova-se no segundo toque, porque a alocação recria os cartões. Oito mutantes |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23h.md` | 23/09 | Um painel não é uma tela (`051`): a resposta do Sr. Ribeiro ganhou foto, e a cobertura das capturas desceu ao TEMPO de cada painel — sete tempos em três painéis, seis com foto e o balanço do fim de fase DECLARADO pela regra do zero. Bateria a 30 tiros, com o toque pelo botão e o tempo conferido. As fotos novas acharam a despedida do Arlindo a dizer «Cliente ouvindo a proposta» com o negócio fechado; o F10 do fumaça achou o nome de 24 letras sem espaço a sair do cartão (`_SMART`). O «Pagar» fora da fase não pagava. Vinte e um mutantes e quatro controles |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23i.md` | 23/09 | A mão direita e o cruzamento (`052`): o retorno passou a encostar nos berços, e a pergunta revelou que os camiões andavam pela ESQUERDA na tela — a projeção espelha o chão — e que as duas rotas se cruzavam em dez pontos, com 27 a 72 sobreposições à vista por meia hora. A mão é a direita; quatro regras sem ninguém parado na rua (trava do berço, cedência na boca, previsão nas curvas, arranque espaçado); a curva aberta corta o chanfro em diagonal. O D35 anda uma hora de jogo e varre 3.080 entradas na rua contra uma simulação à parte. Dezassete mutantes, dezasseis a reprovar |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23j.md` | 23/09 | O balanço, o nome longo e o chanfro (`053`), as três opções de uma vez: o balanço do fim de fase tem foto de uma partida JOGADA e paga pelo botão, e a última lacuna declarada saiu (31 tiros); o F10 mede o diário com o nome de 24 letras, e um catálogo lido da `Narrativa.gd` reprova frase com nome que ninguém mediu; o chanfro passou de 0,9 a 0,60, derivado da curva e do porta-contêiner, cuja carroçaria saía 0,207 do asfalto (D13 §7j). A foto nova mostrou o boletim e o fim de fase por cima da resposta do Sr. Ribeiro — pergunta para o Bruno |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23k.md` | 23/09 | As telas do fim em fila (`054`), resposta do Bruno à pergunta que a foto do balanço deixou: o `Main` passou a abrir o Sr. Ribeiro, o boletim da semana 4 e o fim de fase um de cada vez, pela ordem em que chegam — nos três caminhos do fim, sem tocar no `GameState`. O F11 do fumaça percorre-os pelos botões e exige cada tela sozinha; o tiro `balanco` passou de 3 painéis a 1. Sete mutantes: a fila ligada ao `fechou` passa nas suítes e só a captura a apanha, com o turno preso sem painel |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23l.md` | 23/09 | A página do A5 refeita até ao #75: a trilha correu nos 48 pontos, e cada uma das 31 fotos aparece contra a primeira vez que foi tirada, com Bom/Não e nota por quadro guardados na coleção `veredito`. O passo a passo virou lista (274 imagens não cabem numa página) e as imagens vão em WebP sem perdas. O Bruno julgou os 31 quadros na mesma conversa — 31 «Não», nenhum a regressão —, triados em seis frentes no §A5 do plano; a conversa seguinte audita o plano de assets que ele fez com o ChatGPT |
| `BRIEFING_PROXIMA_CONVERSA_2026-09-23m.md` | 23/09 | A frente 1 do A5, escolhida pelo Bruno: o calendário mostra na grelha os ícones da legenda (D36), o título do fim diz «Primeira parcela paga», o Arlindo diz «meu caro». E a auditoria do pacote do ChatGPT; a conversa seguinte escolhe entre as frentes 2–6 |
| `AUDITORIA_ARTE_CHATGPT_2026-09-23.md` | 23/09 | O pacote de vegetação F1 do ChatGPT auditado contra a `main`: feito sobre o PR #58 num checkout que o GitHub não conhece, com decisões 034–036 que colidem em número; a V5 do arbusto aplica e passa o teste de design sem ele a ver, e em runtime são cinco cópias de 20 px, duas meio tapadas por prédios. Tabela por asset, e o que o plano dele afirma que o repositório desmente. No mesmo dia, a pedido do Bruno, o material passou a viver em `art_lab/` para as duas frentes trabalharem juntas |
| `BLOCO5_PROMPTS_BLENDER_RICO.md` | 29/08 | Os prompts do enriquecimento dos props em Blender |
| `BRP_IMPLEMENTATION_NOTES.md` | 31/08 | O que foi e o que NÃO foi feito no pipeline Blender → Godot |
| `BRP_VALIDATION_REPORT.md` | 31/08 | Os resultados medidos daquele pipeline |
| `BRP_EXPORT_MANIFEST.md` | 31/08 | O formato do manifest de export |
| `BRP_ASSET_INVENTORY.json` | 31/08 | O inventário daquele lote. Nenhuma ferramenta o lê — é registro |

## Dois que NÃO vieram para cá, e por quê

Os antigos briefings do Bloco 6 (áudio) e do Bloco 7 (arte em Blender) não
eram registro: são o plano operativo dos itens **A6** e **A5** da fila, que
ainda não aconteceram. Passaram para `docs/design/BR_Port_Plano_Audio.md` e
`docs/design/BR_Port_Plano_Arte_Blender.md` — perderam o prefixo do bloco, que
era o que os fazia parecer sessão encerrada, e ficaram ao lado do plano que
servem.

É também a razão de a regra ser **por função e não por nome**: um documento vem
para cá quando conta o que aconteceu, não quando o título começa por `BLOCO`.
