# 006 — O registro de partida não carrega o nome de quem jogou

**Data:** 02/09/2026 · **Item:** B7 (metade de máquina do A7)

## A decisão

O `.jsonl` que o jogo grava a cada partida **não contém o nome do jogador**.
Contém, no lugar dele, a FORMA da escolha: se o campo ficou em branco e quantos
caracteres tinha. O nome do PORTO entra inteiro.

## Por quê

O A7 manda entregar o jogo **"a duas pessoas que não conhecem o jogo, sem
explicar nada"**. E o registro sai do telefone pela área de transferência,
colado numa conversa — é a única porta que ele tem, porque `user://` no Android
é privado da aplicação e não há cabo no meio.

Somando as duas coisas: o campo "seu nome" de um jogo que se empresta a
conhecidos recebe, quase sempre, o nome real de alguém que não pediu para o ver
publicado. Guardá-lo não acrescenta nada à leitura — nenhuma pergunta do
playtest é sobre quem é a pessoa — e cria uma obrigação que ninguém quer ter.

**Mas o campo em branco é dado, e dos bons.** A narrativa tem variante sem
vocativo justamente porque o nome pode não vir (ver `Narrativa.gd`), e saber com
que frequência alguém pula esse campo diz algo sobre a tela de abertura que
nenhuma outra medida diz. Daí `jogador_anonimo` e `jogador_letras`: a forma da
escolha sobrevive, a pessoa não.

O nome do porto é o oposto: é escolha de JOGO, irrevogável por desenho (GDD 7),
e ler cinco portos batizados lado a lado é leitura de playtest de verdade.

## O que a tranca

`tests/teste_registro.gd`, bloco R5 — o nome do jogador não pode aparecer no
arquivo, o do porto tem de aparecer, e os dois caminhos (campo preenchido e
campo em branco) são conferidos. O defeito foi injetado e reprovou.
