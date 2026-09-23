# 035 — A casa costeira F1 fica no gerador do mapa

**21/09/2026.** A primeira casa com identidade costeira brasileira entra como
um lote focal da vila de nível 1. O estado continua `review`: esta decisão
fecha arquitetura e consumidor, não a aprovação visual nem o gate mobile.

## Três caminhos foram comparados

| Caminho | Consumidor e profundidade | Custo e evolução | Decisão |
|---|---|---|---|
| PNG modular no gerador | Exigiria o SVG referenciar ou incorporar raster e reconciliar dois pipelines para manter a ordenação entre casas e árvores. | Preserva módulos, mas aumenta a superfície de exportação e não traz variedade enquanto existe uma única casa. | Não agora. |
| Nós modulares no `Main` | O `Main` consome, mas a textura ficaria acima do mapa inteiro; oclusão correta exigiria separar o mapa em camadas. | Acrescenta nós e textura 768×768 a uma cena mobile por uma casa sem interação. | Rejeitado. |
| Refinar um lote no gerador | Usa o consumidor real já existente (`Main.tscn`), a projeção e a fila de profundidade da vila. | Custo incremental pequeno, geração determinística e evolução futura pelos níveis da própria vila. | **Escolhido.** |

O PNG `art/brp/casa_costeira.png` permanece estudo na cena de teste. Ele não é
promovido silenciosamente a produção e não foi apagado: o artefato de jogo é a
casa desenhada nos dois SVGs do mapa por `tools/gerar_mapa_iso.py`.

## Contrato visual e técnico

- um único lote focal, escolhido deterministicamente entre casas visíveis da
  fileira da frente;
- mesma pegada, base, projeção, luz e ordenação das casas que já existiam;
- telhado cerâmico em duas águas, madeira simples, janela e desgaste localizado;
- sem contorno preto, sem novo comércio, praça, igreja ou variante;
- sem alteração de economia, save, viewport, interação ou progressão;
- D24 publica lote, ponto e cor exclusiva e precisa reprovar se o desenho sumir.

A injeção de defeito desligou só o desenho especial, regenerou os mapas e fez
D24 encontrar **0 px** de `telha_f1_luz` onde o mínimo era 41. Restaurado o
ramo, a mesma prova encontrou 422 px e a suíte voltou a `DESIGN OK`.

O pacote Android exportado passou de 6.341.048 para 6.345.064 bytes: **+4.016
bytes**, sem nó ou textura separados. É uma medida de tamanho, não substitui a
medição de frame e memória no aparelho.

## Refinamento pedido na revisão

A segunda passada não aumentou a pegada nem criou outra casa. Ela acrescentou
capas de cumeeira e testeira no beiral, juntas largas de telha, sombra sob o
beiral, manchas de chuva e uma trinca curta, grade simples nas janelas, duas
travessas na porta e um único vaso de barro com três folhas. Linhas usam cores
do próprio material; nenhuma vira contorno preto.

D24 ganhou uma prova independente para a cor exclusiva da cumeeira. Com o
desenho saudável encontrou 6 px exatos onde o mínimo escalado era 5. Na
injeção de defeito, trocar somente as capas pela cor comum do telhado produziu
0 px e encerrou com um problema de design; restaurada a cor, voltou a passar.
O refinamento acrescentou 2.880 bytes ao pacote anterior: 6.345.064 para
6.347.944 bytes, ainda sem nó ou textura separados.

## O que permanece aberto

G2, G5 e G8 continuam abertos. Em particular, uma captura real do runtime e a
medição no Samsung A23 3 GB ainda são necessárias antes de `production`. A
prancha desta rodada é rasterização estática dos SVGs porque o ambiente não
ofereceu servidor X para a captura supervisionada do Godot.
