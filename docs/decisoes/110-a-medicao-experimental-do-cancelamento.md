# 110 — A medição experimental do cancelamento de serviço

**15/10/2026.** Bruno autorizou **seguir com a medição** depois da proposta
`109`. Isso autoriza avaliar suas regras candidatas; não é aceite de custos,
interface ou subida de save. O jogo continua sem cancelamento disponível.

**Continuação:** o aceite posterior do Bruno e a integração no jogo estão
na `111`, com paridade contra esta bancada. Esta decisão conserva a medição
experimental e seus limites.

Base remota conferida: `82a9df0`, PR #131 fundido, nenhum PR aberto. A `109`
estava no commit local `8cdcddd`; a medição parte dele, na branch
`codex/medir-cancelamento-servico`. A `107` permanece em outra branch local.
Main até a `108`, `109` reservada localmente, próximo número livre: **110**.

## O desenho da medição

A bancada herda `medir_fase_2.gd`, que herda o simulador da Fase 1. São
**600 partidas por perfil**, semente **20260825**, desde o dia 1, pagando as
três cobranças reais, sem injetar dinheiro ou estruturas na passagem. A
janela é de **365 fechos na Fase 2**, nunca prazo do jogo. Continua depois
da meta; separa conquista, quebra antes/depois dela e censura.

`estado_cancelamento_experimental.gd` herda o GameState atual e acrescenta
apenas a ação necessária à bancada: sai o barco iniciado, aplica multa e
perda de reputação, conta a perda e libera trabalhador/doca. Usa o fecho,
as receitas, a missão, o piso e as chegadas do motor original. Não substitui
nenhuma dessas regras. A multa descontada no caixa já está na margem
operacional: não se soma de volta como investimento.

**Não é implementação do produto.** Não há entrada pela interface, novo
campo no save, migração, boletim de multa ou evento no Registro do jogo.
O diário experimental sai apenas no JSON da medição. O autosave opcional
escreve o formato atual exclusivamente na pasta de ferramentas; sua
comparação testa execução com/sem persistência, não retomada ou migração
da futura funcionalidade. O autoload e todas as constantes reais ficam
intactos. O identificador do barco no código é `id`, corrigido na proposta;
`uid` no JSON experimental é a cópia desse identificador, não campo novo
no barco do jogo.

## Políticas e varredura, fixadas antes de rodar

Todas preservam construção, negociação e escolha normal dos perfis. Só
tentam trocar na Fase 2, **depois** de preencher as vagas livres, quando
não há berço livre, existe serviço iniciado e há alternativa pronta na
fila. No máximo uma troca por dia, usando `atracar()` real em seguida.
Não conhecem chegadas futuras nem descartam barco sem substituto.

| Política | Quando cancela |
|---|---|
| Nenhuma | Nunca; controle exato contra a main |
| Taxa | Se `(receita nova − multa) / duração nova` supera `receita antiga / dias restantes` |
| Valor | Se `receita nova − multa` supera a receita antiga, ignorando o tempo |
| Uma | Na primeira oportunidade da partida, apenas uma vez, mesmo sem vantagem |
| Impulsivo | Em 25% dos dias elegíveis, mesmo sem vantagem; sorteador separado |

«Receita» inclui adicionais de estruturas; a multa incide só no preço
acordado. Dias já operados são custo passado: a política de taxa compara
os dias que ainda faltam. A política de valor é intencionalmente míope.
Na Uma e na Impulsivo escolhe-se o melhor par pela taxa, mas ignora-se se
ela seria positiva; não se inventa um adversário que procura a pior troca.
As frequências dessas políticas não representam comportamento humano.

O candidato é **5 pontos e 10%**. As cinco políticas são medidas com ele.
Na política de taxa, varia-se uma família por vez: reputação **0 / 2,5 /
8**, conservando multa de 10%; multa **0 / 5 / 20%**, conservando perda de
cinco pontos. Um controle adicional retira ambos os custos. A referência
main e os doze cenários experimentais totalizam **31.200 partidas** na
amostra principal; controles menores não entram nesse total.

## Como ler

- Compara-se a main com a bancada sem ação campo a campo, além de seus
  resumos: se não forem iguais, não se atribui diferença ao cancelamento.
- Sementes e índices emparelham partidas. Depois de uma troca, fila,
  reputação e sequência de sorteios podem divergir: a diferença final mede
  **a política inteira**, não um efeito isolado de cada cancelamento nem
  o mesmo conjunto futuro de navios. Os quatro perfis e sua identidade
  permanecem iguais entre cenários.
- Quantis de tempo até meta só incluem conquistas. As diferenças de tempo
  emparelhadas só incluem pares em que ambos conquistaram. Para caixa e
  atividade, a população é a de entradas na Fase 2.
- «Receita abandonada» soma o que os contratos interrompidos pagariam se
  concluídos. Não é perda líquida contra a referência: a doca atende outros
  barcos depois. As multas são despesas efetivas, separadas desse valor.
- A bancada conta oportunidades, dias abaixo do piso, cancelamentos,
  multas, caixa mínimo/final, margem, serviços e meta. O mínimo inclui o
  instante posterior à multa, antes de eventual recuperação no fecho.
- Poucas oportunidades no Descuidado não provam que a ação seja segura
  para alguém que cancela muito: esse perfil demora a ampliar o porto e
  quase não recebe serviços longos. Nenhuma política modifica seu perfil
  para produzir um resultado desejado.

## Resultado do candidato: cinco pontos e 10%

As 600 partidas de cada perfil entraram na Fase 2. Não houve quebra antes
ou depois da meta nem travamento em nenhum cenário. A bancada sem ação
reproduziu **60.000 campos das 2.400 partidas da main**, mais todos os
resumos, sem diferença.

| Perfil | Meta: controle → candidato, de 600 | Mediana até a meta: controle → candidato | Mediana de cancelamentos em 365 fechos | Mediana de multas pagas |
|---|---:|---:|---:|---:|
| Ótimo | 600 → 600 | 15 → 17 | 21 | R$21.188 |
| Mediano | 600 → 600 | 36 → 43 | 23 | R$22.570 |
| Descuidado | 12 → 6 | 345 → 352 | 0 | R$0 |
| Antecipado | 600 → 600 | 41 → 50 | 22 | R$22.212 |

**352 dias descreve apenas seis conquistas do Descuidado.** As outras
594 partidas terminaram vivas sem meta; só 122/600 cancelaram algum
serviço. A mediana zero de cancelamentos não prova que cancelar não custe:
a maioria desse perfil quase não teve onde usar a ação. Nos outros três,
todas as 600 partidas cancelaram.

Não confundir diferença de medianas com mediana da diferença emparelhada.
Entre pares em que ambos conquistaram, a mediana do atraso foi **0 / 4 /
19 / 7 dias** (Ótimo / Mediano / Descuidado / Antecipado), com n =
600 / 600 / **4** / 600. O conjunto de conquistas do Descuidado mudou; por
isso nem seis nem doze podem ser usados como denominador desse último
cálculo.

| Perfil | Variação emparelhada do caixa final P10 / P50 / P90 | Mais caixa que o controle |
|---|---:|---:|
| Ótimo | −R$131.511 / +R$28.881 / +R$197.139 | 353/600 |
| Mediano | −R$134.416 / +R$47.005 / +R$238.758 | 395/600 |
| Descuidado | −R$1.022 / R$0 / R$0 | 57/600 |
| Antecipado | −R$134.820 / +R$44.156 / +R$216.054 | 367/600 |

O caixa final é o do fim da janela, inclusive jogo livre depois da meta.
**Não é caixa na conquista nem lucro de uma troca isolada.** A dispersão
inclui os caminhos futuros que divergem após a decisão; não se promete
ganho por cancelar. A mediana do caixa mínimo ficou em R$380.340,
R$268.452, R$136.856 e R$267.892. Na amostra, não surgiu pressão de
insolvência. Isso não prova risco nulo em qualquer partida ou horizonte.

## Tentativas: mediana de dias entre conquistas

As colunas Ótimo e Mediano têm 600/600 conquistas em todos os cenários.
O Antecipado também, salvo a linha de oito pontos. A última coluna mostra
a população do Descuidado; suas medianas de tempo não entram nesta tabela
para não fazer seis conquistas parecerem o perfil inteiro.

| Cenário | Ótimo | Mediano | Antecipado | Metas do Descuidado / 600 |
|---|---:|---:|---:|---:|
| Controle, sem cancelar | 15 | 36 | 41 | 12 |
| Taxa, candidato 5 pontos / 10% | 17 | 43 | 50 | 6 |
| Valor, candidato | 21 | 51 | 58 | 2 |
| Uma troca, candidato | 18 | 41 | 45 | 8 |
| Impulsivo, candidato | 20 | 57 | 66 | 4 |
| Taxa, 0 pontos / 10% | 15 | 31 | 35 | 12 |
| Taxa, 2,5 pontos / 10% | 16 | 36 | 42 | 9 |
| Taxa, 8 pontos / 10% | 18 | 53 | 63 (599/600) | 3 |
| Taxa, 5 pontos / 0% | 18 | 46 | 52 | 5 |
| Taxa, 5 pontos / 5% | 17 | 46 | 51 | 5 |
| Taxa, 5 pontos / 20% | 16 | 41 | 49 | 8 |
| Taxa, sem ambos os custos | 15 | 30 | 34 | 14 |

Com oito pontos, a partida restante do Antecipado ficou viva sem meta,
não perdeu. A perda de reputação é a consequência que mais separou o ritmo
da meta neste desenho. A multa em dinheiro pesou menos na solvência,
mas mudou quais trocas passaram pelo critério da política.

**Mais barato não foi sempre mais rápido.** No Mediano, retirar a multa
e manter cinco pontos aumentou os cancelamentos de **13.613 para 17.420**
nas 600 partidas: a política passou a aceitar mais substituições e a pagar
mais vezes com reputação. Sua mediana foi de 43 para 46 dias. Com multa de
20%, foram 10.229 cancelamentos e 41 dias. Comparar custos sem contar as
ações teria atribuído o efeito à família errada.

## Controles e encaminhamento

O conferidor Python independente recalculou os resumos e cada evento.
Adulterações de multa, população, nota da alternativa e quantil foram
recusadas, e a evidência original passou entre os controles. A bancada
de estado cobre saldo negativo com recuperação e quebra no fecho real,
fila cheia, desconto do rival, arredondamento, granel a meio, outra doca,
trabalhador liberado, repetição, clamp e marcos. Quatro defeitos semânticos
— multa ausente, reputação ausente, trabalhador preso e perda duplicada —
reprovaram por asserções, sem erros de script; a fonte restaurada passou
depois de cada um. A amostra de paridade com/sem autosave tem oito partidas,
60 fechos por entrada e 16 cancelamentos: JSONs integrais iguais.

As seis suítes passaram no Godot 4.6.3, com marcadores finais e sem erro de
script/`push_error`; a tabela de 54 constantes e a calibração do projetor
também passaram, e cinco arquivos da sentinela permaneceram intactos no
perfil isolado. Nenhuma fonte do jogo ou simulador original mudou.

**Limitação do ambiente:** a importação imprimiu `ERROR: Safe save failed`
ao fechar um arquivo, inclusive pelo helper seriado do CI e numa repetição
com `--verbose`. O motor retornou zero e as suítes passaram, mas isso não
torna a importação limpa. O log não identificou o arquivo; a causa não foi
isolada. A execução detalhada também registra `EditorSettings: Save OK!`,
por isso não se atribui o aviso a uma configuração específica sem prova.
Os três logs ficam no pacote; não se declara essa verificação sem avisos.

**Recomendação: manter 5 pontos e 10% como candidato para o aceite.** Na
bancada existe uma escolha entre caixa e tempo: a troca criteriosa pode
melhorar o caixa, enquanto o compromisso quebrado custa progressão; uma
política impulsiva piora esse custo. Oito pontos ampliaram o atraso sem
resolver uma pressão financeira que não apareceu; 2,5 quase preservaram
o ritmo do controle. Não há alvo humano aprovado que justifique escolher
uma dessas alternativas só por alcançar a meta mais cedo. Isso é uma
recomendação fundamentada nas políticas testadas, não certificação de
diversão ou de equilíbrio contra toda estratégia possível.

Os dados completos, resumos, logs e controles estão em
`docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/`. A implementação na
interface, a contabilidade no boletim, o registro e o save 18 com migração
continuam **pendentes de aceite**. Depois de implementados, precisam de
paridade com esta bancada e provas de interface/persistência próprias.
Trabalhadores extras, crédito voluntário, obras e A4 ficam fora; a correção
móvel continua separada.
