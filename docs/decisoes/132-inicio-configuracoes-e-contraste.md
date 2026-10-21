# 132 — Quatro entradas no início e movimento legível sob toque

**20/10/2026.** Bruno relatou que o controle de Reduzir movimento quase
desaparecia ao selecionar e pediu quatro botões na tela inicial:
Continuar, Nova partida, Saves e Configurações, reunindo ali as consultas.
Também pediu substituir o fundo provisório por uma imagem do porto.

O defeito do controle foi reproduzido no Godot 4.6.3: o CheckButton ligado
sob o ponteiro usa `hover_pressed`. Sem esse estilo no tema, o motor fornece
StyleBoxEmpty e letra branca sobre o cartão branco. Não era falha ao gravar
a preferência. O tema passa a definir os estados do controle, com fundo
navy e indicador âmbar; uma guarda própria mede inclusive `hover_pressed`.
O percurso geral de contraste mede normal/disabled e não cobria esse estado.

A inicial conserva quatro entradas também sem save. Continuar fica inativo
nessa situação, com explicação em texto vivo. Saves abre o mesmo painel dos
três espaços; não cria funções novas de save. Configurações reúne Ajustes,
Como jogar e Versão e diagnóstico nas mesmas cenas já usadas pela pausa.
Ao abrir uma consulta, o menu é ocultado; Voltar fecha só a consulta e
devolve o mesmo menu. A pausa conserva suas entradas atuais.

O T30 vive em arquivo próprio, com bandeira final. Exercita as duas situações
de disco, as portas reais, duplicação, retornos, alvos e preservação de
partida/RNG/arquivos/registro. O mutante `movimento-duplica-ajustes` conserva
seu defeito e sua guarda, adaptados à nova forma de abrir o painel; nenhum
defeito anterior é removido. Os novos defeitos ficam no catálogo oficial.

O fundo usa o gerador de imagem escolhido na `066`, com candidatas no
`art_lab/tela_inicial/`. Bruno gostou do estilo da v1 e pediu colocar o porto
ao fundo, como no jogo, em vez da lateral. A v2 conserva o estilo e muda
essa composição. Bruno pediu depois subir o assunto para deixar mar livre
entre o navio e o menu, como na primeira imagem. A v3 aplica esse ajuste e
foi fotografada no jogo, com os controles nas mesmas posições.
O aceite da foto de runtime ainda precisa ser registrado;
o papel de parede do celular e um novo logotipo não foram incluídos.

O botão global de tamanho de texto ainda não existe: a `131` era bancada
por `--script`, excluída do export. Bruno permitiu dividir as atividades em
outras conversas. Tamanho preferido, acomodação do HUD e implementação
global/persistente do RB5 ficam para um recorte próprio, sem preferência
predefinida tomada como aceite. Texto e movimento terão de coexistir no disco.

Base remota conferida: `f70b45c` (#145, mesclado por Bruno), CI próprio e
pós-merge verdes. Nenhum merge pelo Codex. Não se alteram save, economia,
RNG, dia, duração de serviço, meta, arte do mapa ou o trabalho visual do Claude.

Em 21/10 Bruno pediu abrir PR para esses commits. A publicação inclui o
menu, o contraste e as candidatas no art_lab, sem integrar a v3 em produção
ou implementar texto global. O CI do PR deve aprovar sua própria junção;
as provas locais e o CI da base não o substituem.
