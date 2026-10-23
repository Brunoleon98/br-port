# 134 — Acomodar o texto maior antes de escolher o RB5

**22/10/2026.** Bruno escolheu continuar o item 1 apresentado: preparar
propostas de acomodação e comparações para avaliar o texto maior; só depois
implementar o tamanho escolhido. É a continuação da bancada da `131`.
Na continuação, Bruno aprovou **«Três colunas com +25% (recomendado)»**.
O aceite define o modo Maior do RB5: fonte a 1,25 da base, três cartões lado
a lado e operação rolável, com Construir, Menu e Avançar dia fixos. O modo
Padrão conserva a apresentação anterior. A implementação global segue o
recorte de `docs/RECORTE_TEXTO_AJUSTAVEL_2026-10-19.md`.

A main de partida é `ed2c770`, #147 mesclado por Bruno. Nenhum PR aberto
na consulta; a branch de fechamento anterior e seus commits locais foram
preservados. A conferência pós-merge do fundo terminou: logs oficiais,
132 ids/pares de mutantes, sentinelas e pacote do Pages conferidos.

O aumento sozinho fazia a fila sobrepor a mensagem e cortava conteúdo.
Sem mudar mapa, viewport ou enquadramento, a bancada compara duas propostas:

- **Colunas:** três docas e três barcos lado a lado; valor em linha própria
  quando presente, texto com quebra e área de operação rolável.
- **Lista:** os mesmos cartões ocupam a largura disponível e seguem em
  sequência vertical. Ganham largura e exigem mais rolagem.

Nas duas, Construir, Menu e Avançar dia ficam fora da rolagem, com alturas
derivadas da fonte e do estilo. A faixa superior conserva todas as pílulas,
ícones e Pausar; margens internas menores acomodam +50%. O mapa mantém seu
retângulo. Padrão permanece exatamente na apresentação da main.

O primeiro raster denunciou um botão Pausar fora da janela em +50% que a
régua de glyphs não detectava: botão só de ícone não é texto. A medição da
proposta conserva também retângulos e mínimos de todos os controles fixos.
Não se promove a régua da bancada a prova integral de interação.

As propostas só montam instâncias por `--script`, excluídas do export.
Não alteram Main.tscn, cartões de produção, tema, save ou preferências.
O movimento reduzido é aplicado em memória; não se amplia seu setter nem se
acrescenta a preferência de texto antes de provar sua convivência no disco.

Capturas reais, medidas, reprodução e limites em
`docs/arquivo/ACOMODACAO_TEXTO_2026-10-22/README.md`. O comparador preserva
os PNGs e permite olhar início/fim da rolagem em +25% e +50%.
O aceite da proposta não substitui as provas de interação da integração nem
a conferência no telefone.
Nenhuma autorização de publicação desta entrega foi presumida.
