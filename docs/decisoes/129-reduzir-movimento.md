# 129 — Reduzir movimento, primeiro recorte do RB6

**18/10/2026.** Bruno escolheu a opção 2, RB6. Meu porto agora (RB2) já
está na main. Base conferida: `56b3983`, merge do #142; nenhum PR aberto.
Claude inicialmente informado como parado; terreno e vegetação continuam na frente dele
(`126`, item 1), sem aceite da `127`. Esta entrega não redesenha arte.

## Recorte autorizado

Preferência de apresentação “Reduzir movimento” nos Ajustes, acessível pelo
início e pela pausa, lembrada após reiniciar e independente dos três espaços.
Ausência ou valor inválido conserva o movimento atual. O inventário do código
precede qualquer alteração: separar decoração de sinais de operação,
resultados e ações. A escolha alcança elementos abertos e criados depois.

Sem `Engine.time_scale`, alteração de serviço, dia, economia, RNG, missão,
meta ou conteúdo do save. Persistência pelo ArmazemLocal, separada entre
jogador e ferramentas; sem função nova de save da partida, migração ou
mudança de SAVE_VERSION. Ações não podem esperar animação suprimida.

## Reserva e prova prevista

Branch `codex/reduzir-movimento`, PR rascunho antes da implementação.
Decisão 129 e nome de briefing de 18/10 conferidos nos ramos publicados;
T29 livre no catálogo atual. Testes próprios,
defeitos no catálogo oficial preservando as 97 provas existentes, seis
suítes, sentinela, capturas inspecionadas e comparação temporal controlada.
Não se promete desempenho sem medição. Telefone e aceite visual são do Bruno.

A tentativa de fetch pelo shell não alcançou o proxy e uma permissão de rede
ficou pendente; a sincronização prosseguiu pelo conector GitHub, com objetos
conferidos por SHA. Não se reaproveitou a branch encerrada do #142.

## Inventário antes de alterar o movimento

| Fonte na main | Papel | Tratamento do RB6 |
|---|---|---|
| `Main`: espuma, coqueiros, boias, luzes e balanço dos barcos ao largo; `MataNoMapa`: rajadas | Fundo, sem efeito no jogo | Pose fixa dos ciclos explicitamente registrados; mata pela API pública, sem editar a frente visual |
| `Fauna`: aparição, travessia, fuga e gestos | Fundo com toque e som | Pose inteira no habitat; toque e som preservados |
| `TrafegoDeCamioes`: travessia e visita ao berço | Travessia sem serviço é fundo; visita coordena carga/operador | Ocultar apenas tráfego sem visita; manter visitas e callbacks |
| `Dock`: balanço/chegada/partida do casco e varredura ociosa da lança | Apresentação de ocupação | Estado final imediato; casco e ocupação continuam legíveis |
| `Dock`: trabalhador/guincho/carga/empilhadeira; `ObraNoMapa`: dias de obra | Operação e progresso | Preservados, com cartões, prazos e avisos |
| `BarcoFila`, `DocaCartao`, `Dock`, tutorial: pulsos de escolha | Informação acionável | Realce fixo, sem apagar seleção nem alvo de toque |
| `Main`: contagem do caixa e ganho que sobe | Resultado | Caixa final imediato; ganho fixo pelo mesmo tempo de leitura |
| `PainelNarrativo`: virada da folha, usada nos nomes e fim de fase | Transição com callbacks de navegação | Saltar desenho intermediário e concluir a cadeia; mudança a meio também conclui |

Durante a reconferência apareceu o WIP visual `67b2641` em
`ccr-d445dbad-nogxh2`. Bruno confirmou: **o Claude segue no visual; manter
essa divisão**. Não editar `MataNoMapa.gd`, seus testes, arte ou geradores.
O PR #143 reserva esta entrega; nenhum aceite visual é inferido dele.

## Contratos da implementação

`PreferenciasDeApresentacao` guarda somente `apresentacao.cfg`, pelo
ArmazemLocal; não acrescenta autoload nem consulta a partida. O leitor
aceita apenas booleano. Uma falha de escrita mantém a escolha na sessão e
os Ajustes informam que não conseguiram lembrá-la. A sentinela passa a
incluir esse arquivo, sem retirar nenhum dos anteriores.

O jogo relê sua preferência ao iniciar. Ferramentas derivam a apresentação
padrão, sem herdar a escolha de outra captura; o RB6 aplica explicitamente a
variante que está medindo. A prova de reinício lê o mesmo arquivo/leitor em
processos distintos. Essa separação foi necessária: uma preferência de
ferramenta deixada ligada fez as guardas antigas de movimento reprovarem a
apresentação reduzida como se fosse a padrão. Não se alteraram suas guardas
nem os testes visuais do Claude para esconder essa diferença.

`MovimentoDeFundo` recebe só ciclos decorativos inventariados; a espera do
resultado e a navegação não entram nele. A virada da folha conserva o tween
retornado e seu callback; escolher redução a meio completa a cadeia. A
viagem sem serviço fica oculta, com a visita operacional e sua coordenação
mantidas. Sem afirmação de ganho de desempenho.

## Verificação

As seis suítes locais passaram com seus marcadores, sem SCRIPT ERROR.
O T29 tem arquivo próprio e bandeira de conclusão. A exploração oficial
reprovou 17 defeitos novos pelas guardas declaradas depois da medição, com
base verde antes/depois; o catálogo contém 114 defeitos, preservando os 97
anteriores. O resultado integrado do HEAD é o job oficial do CI do PR.

Reinício é exercitado em processos de ferramenta e numa aplicação mínima
sem `--script`, usando os scripts reais e o singleton da UI. Sentinela de
seis arquivos intacta. Fotos, parâmetros e limites de reprodução estão em
`docs/arquivo/VERIFICACAO_REDUZIR_MOVIMENTO_2026-10-18/README.md`.
As capturas desenhadas vêm do CI, por falta de xvfb local; o artefato
pequeno `brport-rb6` permite baixar e inspecionar os pares antes do fecho.
Telefone e aceite visual continuam pendentes do Bruno.
