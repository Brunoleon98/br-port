# Falas e lojas da Fase 1 — revisão para leitura

Documento de trabalho sobre a implementação local da decisão `146`, no
commit `2056dad`. Bruno escolheu **mais vínculo com os personagens** como
prioridade desta revisão. **Chave e almoço foram aceitos em 25/10/2026 e
aplicados ao jogo**, com a redação final abaixo. Em 30/10, Bruno aceitou a cena
do Mané sem entregas fixas e o elogio ao bom contrato sem previsão financeira;
escolheu também aviso da Cida no patamar baixo de reputação (`147`). Em 31/10,
aceitou o envelope, o retorno às lojas e os reencontros abaixo, aplicados
localmente. Demais trechos continuam propostas. Após o #156, a cor do HUD foi integrada.

## Diagnóstico da primeira implementação

A tabela registra a leitura inicial do commit `2056dad`. A situação atual das
cenas e os ajustes aplicados estão na tabela de leitura e nas notas abaixo.

O arco já mostra a falta do Seu Maneco, sobretudo na caneca e no café. Falta
mostrar melhor a relação que está nascendo entre a equipe e quem assumiu o
cais. Nas cenas atuais, os personagens frequentemente lembram o avô enquanto
o protagonista apenas escuta. A revisão pode dar ao jogador um lugar nas
pequenas rotinas: receber a confiança do Toninho, dividir uma preocupação com
Cida, sentar para almoçar e conhecer Mané pelo que ele faz hoje.

| Prioridade | Evidência na primeira implementação | Revisão proposta |
|---|---|---|
| 1 — Aproximação no presente | Chave, recibo, café e visitas voltam ao avô. A cena do almoço termina numa piada sobre a forma da mesa. | Preservar caneca/café; usar chave e almoço para incluir diretamente a chefia na vida da equipe. |
| 1 — Compra com motivo humano | O catálogo começa por «Desbloqueia a conversa». Vê-se nas fotos `mercado.png` e `delivery.png` da verificação. | Apresentar primeiro o café e a refeição para dividir; manter em seguida a consequência narrativa, preço e compra única. |
| 1 — Continuidade | A chave fala em esperar o galpão ficar seguro, mas sua condição só exige passagem de semanas; o armazém pode já estar pronto. A cena do Mané menciona entregas fixas e conta mensal. | Usar texto da chave que sirva antes/depois da obra e retirar a promessa de uma rotina de cobranças que a loja não implementa. |
| 2 — Permanecer na loja | `PainelLojas._concluir_conversa()` volta à loja depois da visita gratuita, mas fecha o painel depois da cena comprada ou lida no arquivo. | Ao terminar, voltar ao lugar de onde a cena foi aberta. A compra fica visível na loja; o arquivo mostra a cena como lida. |
| 2 — Distinguir os encontros | As duas visitas usam «Uma conversa na cidade»; Mané pode parecer uma visita física igual à do Mercado. | Mercado como encontro no estabelecimento; Delivery como contato por telefone. Seu Biu é o pescador encontrado ali, sem apresentá-lo como dono do mercado. |

Referências verificadas: `brport_vs/scripts/Narrativa.gd`, linhas 744–804;
`brport_vs/scripts/VidaDoPorto.gd`, catálogo e `disponiveis()`;
`brport_vs/scripts/PainelLojas.gd`, `mostrar_loja()`, `_mostrar_fala()` e
`_concluir_conversa()`. Fotos e provas da versão atual em
`docs/arquivo/VERIFICACAO_HISTORIA_LOJAS_2026-10-24/README.md`.

## Leitura das cenas

| Cena | O que manter | O que revisar |
|---|---|---|
| A caneca que ficou | A caneca a mais, a borda lascada e «não tá ocupando tanto espaço assim». O gesto sustenta a ausência. | Manter nesta passagem. |
| A chave do galpão | Toninho entregar algo que estava sob sua guarda. | Aplicado: lembrança breve e oferta de ajuda, sem presumir o estado do galpão. |
| O nome no recibo | A cidade começar a reconhecer quem ficou. | Fazer o recibo aparecer de fato na conversa; Toninho se oferece para buscar o pão. |
| O envelope | A oferta antiga do Grupo Atlântico e a frase no verso. | Aceito em 31/10 e aplicado localmente: surpresa compartilhada e convite da Cida para ler junto. |
| Mais uma cadeira (`mesa`) | Mané aproximar cidade e cais. | Aplicado em 30/10: convite para sentar com a equipe, sem entrega fixa ou conta mensal. |
| Uma proposta informal | A simpatia interessada de Arlindo e «meu caro», escolha já registrada de Bruno. | Manter nesta passagem. É o contraponto à confiança da equipe; intensificar a ameaça não é a prioridade escolhida. |
| Café no cais | O café fraco para a conversa durar, a resposta seca de Cida e a garrafa que fica. | Manter nesta passagem. Já cumpre o objetivo de vínculo. |
| A mesa do cais | A compra resultar numa pausa compartilhada com a equipe. | Aplicado: Toninho reserva um lugar para a chefia e brinca com Cida. |

As condições, os ids persistentes e a ordem das cenas continuam os da `146`.
Esta revisão não propõe respostas escolhidas pelo jogador, pontos de amizade
ou outro sistema de relacionamento.

## Versões para comparar em voz alta

### A chave do galpão

**Toninho:** Olha, chefia... essa chave era do Seu Maneco. Do armário lá no galpão.

**Toninho:** Ficava comigo. Ele sempre dizia que eu ia perder.

**Cida:** E nunca precisou pedir duas vezes.

**Toninho:** Agora fica com você. Se precisar, me chama.

A confiança passa do avô para a chefia; Toninho continua por perto. A última
fala serve com o armazém pronto ou por reparar e não pede ao jogador uma ação
de abrir armário que o jogo não oferece. Na leitura, «E quando ele precisava,
já tava na mão dele» e «Se alguma coisa emperrar, me chama» foram simplificados
para as falas acima. Bruno respondeu «Ficou bom» à versão final desta cena e
do almoço; esse aceite não foi estendido às outras propostas.

### O nome no recibo

**Cida:** A moça da padaria perguntou em que nome põe o recibo do pão.

**Toninho:** Já esqueceu o Seu Maneco?

**Cida:** Não. Quer saber quem tá cuidando daqui agora.

**Toninho:** Pode pôr o da chefia. O pão eu busco.

O recibo ganha função na cena e o gesto do Toninho é concreto. A padaria
permanece parte do cotidiano narrado, sem criar produto ou cobrança novos.

### O envelope

Versão aceita por Bruno em 31/10/2026 («Ficou bom»), aplicada localmente:

**Toninho:** Achei esse envelope no armário do Seu Maneco, chefia. Tava no meio dos papéis.

**Cida:** Grupo Atlântico. Uma oferta antiga de compra. Pelo cais inteiro.

**Toninho:** Ele nunca me falou disso.

**Cida:** Pra mim também não.

**Toninho:** No verso tem letra dele: enquanto tiver quem volte, eu fico.

**Cida:** Deixa aqui na mesa, chefia. A gente lê junto.

A descoberta também mostra que Toninho e Cida não sabem tudo. A oferta é
antiga; o empréstimo atual para reconstruir continua sendo o contrato já
explicado no banco. Não se atribui o documento ao Arlindo nem se resolve o
mistério do Grupo Atlântico.

### Mais uma cadeira — antes A mesa da esquina

**Cida:** O Mané perguntou se ainda tem lugar pra ele quando passar no cais.

**Toninho:** Na mesa? Achei que ele só vinha dar palpite.

**Cida:** Disse que tá cansado de conversar com a gente só na hora de entregar.

**Toninho:** Então manda trazer a cadeira da esquina. A que não balança.

O título aplicado em 30/10 é **Mais uma cadeira**, mantendo o id `mesa`. O convite
aproxima Mané; não representa uma encomenda nem uma assinatura de entregas.

### A mesa do cais — depois de comprar o almoço

**Cida:** O Mané mandou a comida. Esses papéis podem esperar um pouco.

**Toninho:** Senta aqui, chefia. Deixei esse canto pra você.

**Cida:** E esse prato aí é meu, Toninho.

**Toninho:** Eu tava guardando, Cida. Vai que alguém pega.

O cuidado da Cida aparece na pausa; o Toninho reserva um lugar para o jogador.
A brincadeira é pequena e cabe numa intimidade de trabalho. Nenhuma fala
afirma que o jogador já comprou café ou concluiu outra cena.

### Seu Biu no Mercado

**Biu:** Seu avô escolhia o café pelo cheiro. O preço ele perguntava depois.

**Biu:** Senta um pouco. Quero ver se você também esquece de perguntar.

A primeira fala preserva a lembrança; a segunda abre espaço para conhecer quem
chegou. Uma apresentação curta, fora da fala, pode situar Seu Biu como o
pescador que para no mercado. Seu Biu não vira comerciante por aparecer ali.

### Mané no telefone

**Mané:** Pode ligar. Pedido ou conversa, eu atendo.

**Mané:** Se eu demorar, é a mão na panela. Não é má vontade.

Mané oferece contato antes de vender. A comida e a disponibilidade dele
aparecem na mesma voz, sem repetir mais uma lembrança do avô.

## Como as lojas podem apresentar as compras

Os preços continuam os do catálogo; os valores abaixo servem para comparar a
redação da tela atual, não para criar outra fonte de preço no jogo.

| Elemento | Texto proposto |
|---|---|
| Apresentação do Mercado | Café para levar ao cais. Seu Biu costuma parar por aqui na volta da pesca. |
| Kit de café — descrição | Para preparar um café e dividir com a equipe no cais. |
| Kit de café — consequência | Inclui a cena Café no cais. Compra única, sem bônus de operação. |
| Botão | Comprar kit por R$180 |
| Apresentação do Delivery | Uma refeição do Mané para dividir com o pessoal do cais. Dá para conversar antes de pedir. |
| Almoço — descrição | Um almoço para a equipe fazer uma pausa e comer junto. |
| Almoço — consequência | Inclui a cena A mesa do cais. Pedido único, sem cobrança recorrente. |
| Botão | Pedir almoço por R$240 |
| Contato do Delivery | Ligar para Mané |
| Título da conversa do Delivery | Uma ligação para Mané |
| Almoço já comprado | Almoço pedido. A conversa está na História do porto. |

A confirmação conserva preço, dinheiro que sobra e saída sem comprar. Café e
almoço são opcionais; o benefício continua sendo narrativo, sem aumentar
produção ou reputação. A consequência aparece antes da confirmação, mesmo
quando a descrição fica mais natural.

## Percurso de leitura e retorno

Na versão anterior, a visita gratuita termina na loja. A compra bem-sucedida abre
a cena imediatamente; tanto «Concluir conversa» quanto «Ler depois» fecham o
painel. Para encontrar o item comprado, é preciso abrir o app novamente. Uma
cena escolhida no arquivo também fecha o app ao terminar. Esses caminhos foram
conferidos no código; não foram classificados como perda de compra ou save.

O retorno aceito por Bruno em 31/10 e aplicado localmente é:

| Entrada | Depois da última fala | Ao interromper |
|---|---|---|
| Visita gratuita | Voltar à mesma loja | Voltar à mesma loja |
| Compra na loja | Marcar a cena como lida e voltar à mesma loja, com item comprado visível | Voltar à loja; preservar a compra e a cena por ler |
| História do porto | Marcar como lida e voltar ao arquivo, com «Reler» | Voltar ao arquivo; conservar a pendência |
| Convite do boletim | Marcar como lida e voltar ao boletim | Voltar ao boletim; conservar a pendência |

«Voltar ao porto» continua sendo a saída explícita do app. «Fechar o boletim»
continua primeiro no boletim; esta revisão não recoloca a história antes da
ação habitual, cuja ordem já foi provada na entrega da `146`.

O painel guarda a origem durante a conversa, sem campo novo no save. Os
botões indicam o destino: mercado, delivery, histórias ou boletim. O retorno
ao boletim já existia e foi preservado. T34 percorre os botões reais, incluindo
interrupção na última fala sem concluir, releitura, compra e retomada.

## Reencontros aceitos em 31/10

As primeiras visitas permanecem. Comprar sem concluir a cena não antecipa o
reencontro; as variantes consultam as leituras já salvas da própria loja.

Depois de concluir **Café no cais**:

**Seu Biu:** E o café lá no cais, chefia? O pessoal gostou?

**Seu Biu:** Se o Toninho disser que tá forte, manda ele tomar mais devagar.

Depois de concluir **A mesa do cais**:

**Mané:** E o almoço, chefia? Deu pra sentar com o pessoal?

**Mané:** Espero que o Toninho tenha respeitado o prato da Cida.

São falas de visita, não alterações das cenas de almoço/Mané já aceitas.
Nenhum bônus, resposta selecionável, entrega recorrente ou nova cobrança.

## O que esta revisão já permite avaliar

A leitura da chave, do almoço e do envelope foi aceita por Bruno. A continuação pode usar
essas cenas como referência para o restante: a equipe acolher quem joga, cada
voz continuar reconhecível e o humor parecer uma conversa. O aceite das outras
cenas continua aberto; suíte verde não resolve gosto de escrita.

A implementação da `146` recebeu as falas aceitas da chave e do almoço;
provas em `docs/arquivo/VERIFICACAO_FALAS_2026-10-25/README.md`. A `147` aplica
a cena do Mané, o elogio e o aviso ao entrar no patamar baixo de reputação;
provas em `docs/arquivo/REPUTACAO_E_FALAS_2026-10-30/README.md`. Preços, save,
condições dos capítulos continuam iguais; o retorno do painel foi atualizado.
As capturas da entrega anterior não representam os textos novos. Telefone e
as propostas restantes continuam por conferir; catálogo precisará ser visto
no painel real em Padrão/Maior quando for integrado.
