# Partidas do playtest (A7)

As partidas REAIS do A7 — as três do Bruno e as de quem nunca viu o jogo —,
uma por arquivo `.jsonl`, como o jogo as grava (`brport_vs/autoload/Registro.gd`).
Nasceu no M11 da revisão de 09/10 (`docs/decisoes/099`). As partidas que o CI
grava para provar o leitor não vêm para aqui: são de máquina, e esta pasta é
de gente.

## Como uma partida chega aqui

1. No jogo, **Pausa → Ajustes → «Copiar registro da partida»**, ao fim da
   partida — ou **Ajustes** na tela inicial, logo depois de «Salvar e sair»,
   que copia a última jogada nesta sessão.
   No telefone é a única porta, porque o `user://` do Android é privado da
   aplicação (`docs/decisoes/006`).
2. Colar num arquivo novo desta pasta, com o nome
   `AAAA-MM-DD_quem_N.jsonl` — `quem` é `bruno`, `pessoa-a`, `pessoa-b`…,
   **nunca o nome de quem jogou**; `N` conta as partidas dessa pessoa nesse
   dia. Várias partidas coladas no mesmo arquivo separam-se sozinhas, porque
   cada `"e":"abriu"` começa uma.
3. Commitar.

## Anónimas, e porquê

O registro não carrega o nome do jogador — só se o campo ficou em branco e
quantas letras tinha (`jogador_anonimo`, `jogador_letras`) —, e o
`teste_registro.gd` tranca isso (R5, `006`). O nome do PORTO entra inteiro: é
escolha de jogo. O nome do arquivo segue a mesma regra, e é o único sítio
onde ela depende de quem o escreve.

## Como se lê

```sh
python3 tools/ler_registros.py --pasta playtest
```

Espera `LEITURA OK`. O leitor corre o autoteste antes, resume as partidas e
põe o jogador MEDIDO ao lado dos perfis que o simulador supõe. Com a pasta
vazia, diz «Nenhuma partida encontrada» e sai com código 1.

O FPS e o aquecimento não se gravam aqui: medem-se no telefone, à mão, com o
build do Pages (`https://brunoleon98.github.io/br-port/`). O que o contêiner
mede por quadro — chamadas de desenho, nós, o custo de cada `_process` — sai
de `brport_vs/tools/medir_desempenho.gd`.
