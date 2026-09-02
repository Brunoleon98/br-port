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
| `HISTORICO.md` | 25/08–02/09 | O caminho do projeto bloco a bloco, e os defeitos que cada playtest achou. Saiu do `ESTADO_DO_PROJETO.md`, que o carregava junto com o estado atual |
| `BLOCO3_MARCO_INTERMEDIARIO.md` | 26/08 | O playtest humano de 5 partidas, a medição do balanceamento e a decisão de ajustar antes de ir para a arte |
| `BLOCO4_BRIEFING_VISUAL.md` | 27/08 | A ordem de trabalho da arte: style guide, mapa com placeholder, sprites |
| `BLOCO4_PACOTE_SPRITES.md` | 28/08 | O pacote de sprites que chegou sem canal alfa, o que entrou e o que não |
| `BLOCO4_GUIA_GERACAO_ASSETS.md` | 28/08 | Prompts de gerador de imagem para os assets daquela leva |
| `BLOCO4_PROMPTS_VISUAL_CHAPADO.md` | 28/08 | A direção topo-down, **superada** no mesmo dia pela isométrica |
| `BLOCO4_PROMPTS_ISOMETRICO.md` | 28/08 | A direção isométrica em prompts — superada por gerar os props **por script**, que é a regra de hoje |
| `BLOCO4_BRIEFING_CONTINUACAO.md` | 28/08 | Ponto de entrada do Bloco 4, com três caminhos que foram todos fechados |
| `BLOCO5_BRIEFING_CONTINUACAO.md` | 29/08 | Ponto de entrada do Bloco 5, e o histórico das três oscilações da direção de arte |
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
