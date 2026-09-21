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
