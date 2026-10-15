# 108 — A medição completa da Fase 2: etapa 4 da `103`

**14/10/2026.** Base `92862ef`, merge do PR #130 confirmado no GitHub;
nenhum PR aberto e main com decisões até a `106`. A `107` está reservada
na branch local `codex/corrigir-nomes-web`; esta tarefa usa a `108` para
evitar colisão quando as duas forem integradas. Bruno retomou o A4 e depois
autorizou continuar partes que dispensassem sua revisão. O rascunho novo do
caderno foi apresentado na conversa, mas não aprovado nem aplicado.

## O que o simulador mede

O novo `tools/medir_fase_2.gd` herda as escolhas dos quatro perfis do
simulador da Fase 1. Joga desde o dia 1, paga as três parcelas e conserva
caixa, porto e calendário ao entrar no dia 85. Não injeta dinheiro nem
infraestrutura na passagem. Na Fase 2 tenta, nesta ordem, píer 2, pátio,
armazém, treliça, píer 3 e escritório, conservando a folga de compra de cada
perfil. A ordem é uma política de teste, não uma recomendação ao jogador.

Conta a meta pelo sinal real `fase_concluida(2)`, o cargueiro pelo contrato
efetivamente pago e cada obra pelo início e pela conclusão. A janela é de
**365 fechos a partir da entrada na Fase 2**, chegando ao dia 450 numa
partida sem quebra. Isso limita a observação, não cria prazo no jogo. Depois
da meta, continua em jogo livre até o fim da mesma janela.

O JSON guarda cada partida e seu resumo: entradas, perdas na Fase 1,
conquistas, quebras antes e depois da meta, censuras, travamentos, dias até
meta/cargueiro, caixa de entrada/na meta/mínimo/final, investimento, margem
operacional, piso e recuperações, sequência de reputação e marcos de obras.
Sem dívida na Fase 2, a margem operacional soma os investimentos de volta à
variação do caixa. Caixa na entrada inclui a trajetória anterior e não é
lucro da Fase 2. O mínimo abrange também o pagamento das obras.

Quem segue vivo sem conquistar até o fim fica **censurado**, não derrotado.
Os quantis de dias usam só quem conquistou; sem conquista, o resultado é
`null`, nunca zero. A leitura pura está em `leitura_fase_2.gd`. Travamento
ou sinal incoerente emite erro, recusado pelos comandos de CI.

## A referência medida

Godot **4.6.3**, **600 partidas por perfil**, semente **20260825**, mesma
política e sementes emparelhadas entre cenários. Todos os 600 de cada perfil
chegaram à Fase 2. No cenário atual, não houve quebra antes nem depois da
meta na janela, nem travamento.

| Perfil | Conquistaram / entraram | Dias P10 / P50 / P90, entre conquistas | Vivas sem meta ao fim |
|---|---:|---:|---:|
| Ótimo | 600 / 600 | 12 / 15 / 20 | 0 |
| Mediano | 600 / 600 | 22 / 36 / 54 | 0 |
| Descuidado | 12 / 600 | 335 / 345 / 362 | 588 |
| Antecipado | 600 / 600 | 29 / 41 / 57 | 0 |

**345 dias não é a mediana das 600 partidas do Descuidado.** É a mediana
das 12 conquistas observadas. Para esse perfil inteiro, a mediana do tempo
até a meta não foi alcançada na janela. Os perfis são políticas sintéticas;
suas frequências não estimam a distribuição de jogadores humanos.

O caixa mínimo mediano foi R$380.166, R$268.653, R$136.856 e R$267.607,
respectivamente. O Descuidado passou uma mediana de **342 dos 365 fechos**
abaixo do piso; nos outros perfis, zero. Sua folga de compra é quatro vezes
o preço: exige R$600 mil para iniciar o píer 2. Poupar assim adia a expansão,
e o ganho lento de reputação mantém os cargueiros suspensos. Não se alterou
o perfil para fazê-lo conquistar.

## Preços e patamares mantidos

A varredura muda uma família por vez, com 600 partidas por perfil em cada
cenário: cesta dos três preços a 50% e 150%, meta 70/90, piso 20/60,
reputação inicial 55/75 e obras mais curtas/longas. A cesta altera os três
preços conjuntamente; não permite atribuir seu efeito a uma compra isolada.
Resultados completos e parâmetros estão na evidência abaixo.

Na cesta pela metade, o Mediano foi de 36 para 23 dias de mediana; com
preços 50% maiores, para 68. O Descuidado conquistou em 228/600 e 0/600,
respectivamente. Mesmo a redução ampla não o tornou equivalente aos outros
perfis. Baixar só o piso para 20 deu 3/600 conquistas, conservando as medianas
dos outros três: acesso mais cedo também muda os barcos e sorteios que vêm
a seguir, e um patamar menor não garante progresso mais rápido.

Mantêm-se como **referência medida deste recorte**, encerrando o caráter de
preenchimento provisório das etapas 2–3:

| Item | Valor mantido |
|---|---:|
| Píer 3 | R$260 mil; 3 dias de obra |
| Escritório | R$80 mil; 2 dias de obra |
| Treliça | R$80 mil; 2 dias de obra |
| Reputação ao entrar | 65 |
| Piso para novos cargueiros | 40 |
| Meta de reputação | 80, durante 3 fechos consecutivos |

Esses preços conservam a escada já construída: o terceiro píer custa mais
que o segundo, e a treliça menos que o futuro pórtico. A cesta barata
inverte a primeira relação, e a cara elimina a segunda. O cenário atual
separa o ritmo dos perfis sem dívida nova e sem exigir a compra do
escritório para a meta. Não há alvo humano aprovado que justifique escolher
uma mediana diferente só por ser menor. Nenhum valor numérico do jogo mudou.

Há **pouca pressão financeira nas políticas medidas**: zero quebras em
2.400 partidas observadas não demonstra risco nulo nem estabilidade eterna.
A condição da `103` de todos os perfis conquistarem facilmente não ocorreu;
o Descuidado ficou quase todo sem meta. Continua valendo o jogo tranquilo
da `005`, em que erros podem custar tempo e oportunidade. Dívida, rival novo
ou pressão adicional exigem outra escolha do Bruno. A experiência de espera
e o ritmo percebido continuam para o A7; simulação não fecha gate humano.

## Verificação e continuação

O T23 separa as populações, inclusive conquista seguida de quebra, perda
anterior e censura. Controles que contavam conquista como censura e que
inventavam dia zero precisam reprovar; a fonte restaurada precisa passar.
Uma bancada adicional força caixa negativo e exercita a quebra real do
motor. Um conferidor Python independente recalcula os resumos a partir das
partidas, verifica dias e marcos, e rejeita dados adulterados.

Paridade com/sem autosave, paridade integral da Fase 1 com a `106`, tabela
de números, projetor e seis suítes ficam registrados em
`docs/arquivo/MEDICOES_FASE_2_2026-10-14/`. O CI comum exercita uma amostra
curta; o workflow de balanceamento mede 600 e guarda os dados completos.
Nenhuma tolerância foi alargada para aceitar a nova ferramenta.

A etapa 4 fecha a parte de máquina da progressão. O vertical slice ainda
espera A4 (leitura), A5 (arte pendente), A6 (escuta), A7 (pessoas e telefone)
e A8 (publicação). A prioridade do Bruno continua sendo terminar a Fase 1;
cancelamento, mais trabalhadores e crédito voluntário não começaram aqui.
