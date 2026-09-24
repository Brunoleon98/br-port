# Capitão Arlindo no kit afinado — v1 a v6

**Estado: ✅ v6 ACEITA pelo Bruno na foto do jogo (24/09), e já no jogo.**
O construtor é o `arlindo()` de `blender/brp_retratos.py` (com a `ARLINDO`),
as três caras estão na `_CARAS` de `blender/brp_porto.py`, e os PNG em
`brport_vs/` saíram do estúdio iguais à candidata (0 pixels diferentes). Com
ele saiu o kit de caixas dos retratos de fala. A decisão é a `056`.

**Base:** `main` em `5276efa`, mais os checkpoints `05b63dd` (a cabeça
parametrizada) e `4d25614` (o Sr. Ribeiro).

## O que se pediu

O último dos três no kit afinado, com a SUA forma — plano de arte P2, «de
ângulos» — e o que a identidade de caixas já tinha decidido: o boné de capitão
NAVY (branco some no balão claro), o emblema na frente do boné, o bigode e a
gola aberta.

## As seis voltas

| | o que mudou | o veredito do Bruno |
|---|---|---|
| **v1** | maxilar em V, boné oitavado alto, bigode em divisa, patilhas em bico, gola aberta, dragonas; o sorriso de dentes com os olhos abertos | ajustar tudo: boné (tampo grande, oitavado, pala chapada), rosto (queixo pontudo, bigode pequeno, olhos, barba), expressões, camisa (V de gravata, dragonas, bolsos, cor) |
| **v2** | boné redondo e mais pequeno, pala maior (subida 5 para não tapar a sobrancelha), queixo menos pontudo, barba por fazer, camisa `azul`, gola larga com carcela, dragonas finas, sorriso com os olhos a sorrir | ajustar tudo: boné «estranho», barba pesada, bigode a sumir nela, nariz grande; expressões ainda a ler mal; gola navy como babeiro |
| **v3** | boné 12° PARA TRÁS, friso na pala e cordão, barba cinzenta mais leve, nariz menor, olhos maiores; as três caras tiradas das FALAS | ajustar: «parece meio careca»; copa «lata», emblema «fivela», pala solta; queixo «mais fino que os outros»; tirar a barba; «refinar as expressões»; botões «mais estilosos» |
| **v4** | calote de cabelo, queixo alargado (104), sem barba, bigode em tufos, copa alta e mole a 5°, pala nascida da curva da faixa, âncora, rugas por expressão, botões de latão, gola marcada | ajustar: cabelo «capacete», bigode, «colar azul» no pescoço, riscas das dragonas, bolsos |
| **v5** | cabelo em três camadas (calote escura, fios em camadas, franja), bigode de cinco tufos a alternar tom, dragonas com barras largas, bolsos com botão | ajustar: «ainda aparece linha azul no pescoço», cabelo em lâminas, bigode «pente» |
| **v6** ✅ | o tampo do tronco dentro do pescoço (era ele o aro azul), cabelo em três camadas coladas em tons próximos, bigode uniforme e cheio com as pontas a descer | **aceite** |

## O que cada volta ensinou

Em comentário no código, junto da linha que corrige. As que valem além dele:

1. **A pala maior desce sobre as sobrancelhas**: avançar é descer na imagem,
   e quem a pôs de volta acima foi subir o BONÉ inteiro, não encolhê-la. E
   **o boné 12° para trás virou o tampo para longe da câmera** e subiu a pala
   — a geometria da câmera a resolver duas queixas de uma vez.
2. **Haste e cepo sozinhos são uma CRUZ**: o que faz a âncora é o U largo dos
   braços, virado para cima.
3. **O friso por cima da pala cobria-a toda** e ela lia como vidro; por baixo
   dela, só a borda sai.
4. **Um tom contrário a alternar lê como pente** (no bigode) e como lâminas
   (no cabelo): o fio desenha-se pela SOMBRA entre placas do mesmo tom.
5. **O «colar azul» era o tampo do tronco**, 5 px mais largo do que o pescoço
   — tirar o pé de gola, que se supôs ser ele, não o tirou. Quando uma
   correção não muda a queixa, a peça é outra (a regra da `quadrada_v2`).
6. **As caras saem da FALA que acompanham**: a pressão («A paciência do
   senhor, sim») é um meio sorriso frio, e não um franzido — «sempre sorrindo
   quando ataca», diz o guia de voz.

## A prova no jogo

Numa cópia da árvore (`git archive 5276efa`), com SÓ os três PNG trocados e o
`--import`, os dois tiros da bateria que o mostram — `contraoferta` (a
abertura, sorriso) e `contraoferta_fim` (a despedida de quem perdeu,
contrariado) —, com os argumentos do `capturar_evidencia.sh`: os dois mudam
só dentro da caixa do retrato. ⚠️ **A pressão não tem tiro na bateria** (a
última tentativa); viu-se na prancha das três caras.

## Arquivos

| Pasta | O que há |
|---|---|
| `v1/`–`v5/` | o script do candidato (as caras de cada volta), a prancha do jogo (hoje × vN) e a das três caras. ⚠️ O script corre contra o estúdio de HOJE, não o daquela volta: não refaz a vN |
| `v6/` | o script, a prancha do jogo, a das três caras e as fotos do jogo da contraoferta e da despedida. Os PNG são os de `brport_vs/art/props/retrato_arlindo_*.png` |
