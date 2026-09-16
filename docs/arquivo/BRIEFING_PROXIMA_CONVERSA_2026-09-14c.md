# BR Port — briefing da próxima conversa

> Fechado em 14/09/2026, depois de o raster da água ser **construído, medido e
> rejeitado**. É o terceiro fecho deste dia; o `b` traz a alavanca A e o sem
> sufixo, as duas fatias do item 8. Ponto de entrada curto — o estado canónico
> continua em `docs/ESTADO_DO_PROJETO.md` e a ordem, na §7 do plano v3.

## O que acabou de acontecer, e o que ele NÃO deixou no jogo

`docs/decisoes/026`. **Nada do jogo mudou** — o gerador do mapa, os quatro SVG e
a tabela de âncoras estão byte a byte como na main. O que ficou foi a medição, e
uma régua com um modo novo.

O campo de cor da água era o que sobrava da alavanca A: um PNG de 720×720
embutido no SVG e esticado sobre o `viewBox` de 1080, **43% da janela**. Foi
levado para o espaço DESENHO e gerado a 1080 (2,25× os pixels), conferido contra
a força bruta byte a byte, e medido:

| | 720 | 1080 |
|---|---:|---:|
| pico da fronteira, na região do raster | 29,73 | **29,71** |
| px da janela que mudam acima do piso de Weber | — | **0,00%** |
| maior Δ de canal (RGBA) | — | **4/255**, e nenhum pixel chega a 6 |
| tempo de geração dos dois mapas grandes | 22,6 s | **40,8 s (1,8×)** |
| `.pck` | 4.415.176 B | **4.375.880 B (−39.296)** |

⚠️ **Resolução só se paga onde há FRONTEIRA para afiar.** Aquele raster não tem
nenhuma — é uma rampa contínua da distância à costa —, e tudo o que tem traço
naquela água é vetor, que já ganhou na alavanca A. *"43% da janela"* e *"2,25×
de pixels"* são verdade e não querem dizer nada.

E o `.pck` ENCOLHER é o outro achado: o pacote leva o `.ctex` e **nunca o SVG**,
e o campo nativo comprime melhor do que o mesmo campo ampliado por bilinear.
Dado melhor, resultado invisível — não paga trinta segundos de CI por push.

## O que ficou no repositório

1. **`medir_resolucao_mapa.gd` ganhou o modo de DOIS ARQUIVOS** — dois SVG à
   mesma escala, em vez do mesmo arquivo a duas escalas. O modo de um arquivo
   reproduz os números publicados na `025` ao ponto (17,29 → 26,38, +52,6%).
2. **A tabela de custo da `025` §5 fechou**, com o APK e o `brport-web` lidos
   dos artefatos do CI do PR 51 contra a corrida da base: **APK +413.696 B
   (+1,31%)** e **Web +412.320 B (+0,98%)**. O `.pck` medido à mão previu o Web
   a 80 bytes e o APK a 1.456.

## O A5 tem instrumento desde 14/09 — falta olhar

A metade de máquina do gate está feita: a bateria foi corrida nos **30 pontos**
da história em que um merge tocou em arte (02/09 → hoje), com o `.godot` apagado
e reimportado em cada um, e daí saem **128 pares antes/depois** mais 14 fotos que
nasceram pelo caminho. O que mudou em cada ponto sai do hash de cada PNG, não do
olho de ninguém. A página está em <https://claude.ai/artifact/8k28N6G5ALgU3rSkQaVWxu>;
o veredito de cada quadro é guardado, e **lê-se de volta com `read_db` na
coleção `veredito`** — é assim que a resposta dele entra na fila em vez de se
perder na conversa.

## O que espera o Bruno, e nenhuma sessão destrava

- **A5** — olhar. A página está montada; falta a metade dele;
- **A4** — reler em voz alta o texto que mudou desde 13/09;
- **A6** — ouvir os 14 efeitos. Este contêiner não tem placa de som;
- **A1/A7** — jogar outra vez, e a ORDEM do resto da fila.

## Os itens abertos, e todos são escolha dele

1. **A alavanca B da resolução** — props a 512 → 768. É uma sessão inteira só
   para a mecânica (releva de 25 props, manifest, pivô da lança, validador), e
   ⚠️ **é aqui que a armadilha da constante em pixel vale de verdade**, ao
   contrário da A: os props são desenhados nas unidades da saída.
2. **O detalhe que a resolução PAGA** — a tabela da Etapa 7 do plano de arte:
   comércios na vila, corrugado do contêiner, cabine dos camiões, ferrugem do
   pesqueiro. **Resolução sozinha compra nitidez, não detalhe**, e a alavanca A
   comprou nitidez. São cinco ou seis sessões.
3. **O tronco do coqueiro** — índice 0,491, três na tela. Curvar o EIXO curvaria
   a silhueta, e isso não foi medido. Sessão pequena.
4. **`doca_concreto` não está no jogo** — referido só por um teste não exportado.
   Ou entra no mapa, ou sai do catálogo.
5. **A rua parou em 1,8** — alargá-la empurra o `RUA_RECUO` e o enquadramento
   inteiro (`012`). Sessão própria.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md e
docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-14c.md.

A resolução do MAPA está fechada nos dois sentidos e não se reabre: a alavanca A
entrou (`025`), o raster da água foi construído a 1080 e REJEITADO por não mudar
um pixel acima do piso de Weber (`026`), e a alavanca C não dá um pixel. Não
refaça nenhuma das três.

O item desta sessão é: <escolher da lista do briefing>.
```
