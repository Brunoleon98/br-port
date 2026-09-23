# Prompt para Claude — auditoria dos assets BR Port

Audite o pacote `BR_PORT_AUDITORIA_ARTE_2026-09-23.zip` e, se tiver acesso, o checkout do projeto `Brunoleon98/br-port`. Leia primeiro `RELATORIO_AUDITORIA_E_LICOES_APRENDIDAS.md`, `manifest_sha256.json`, o plano V3, a ficha F1 e os relatórios das versões. Verifique os hashes do manifesto antes de tirar conclusões.

Separe duas linhas de trabalho: **13A V4/V5** (arbusto individual e patch proposto para o gerador) e **grupo completo F1 V1/V2/V3** (PNG/SVG independentes, ainda não consumidos pelo jogo). A referência é `referencias/13_arbustos_vegetacao_baixa_mangue_v4.png`; marque visualmente o grupo inteiro superior esquerdo. A comparação antiga do 13A é só registro histórico. O usuário considerou V4 de 13A um aglomerado, disse que o grupo V1 destoava do mapa, achou a V1 melhor que a V2 e ainda **não avaliou a V3 do grupo**.

Faça uma auditoria crítica e reproduzível:

1. Compare conceito inteiro, alvo marcado, V1/V2/V3 no mesmo tamanho de uso e zoom, e pelo menos três lugares do mapa. Avalie silhueta, volume, detalhe, paleta, escala, contato com solo e coexistência com casas, vias e árvores. Diga o que falta à V3 e se ela realmente melhora sobre V1.
2. Revise os resultados e os scripts de QA. Diferencie PASS de evidência limitada, FAIL histórico da V3 de 13A e PENDING. Confirme a correção da checagem do modo RGBA da V3 do grupo e registre o rótulo fraco dos testes V1/V2. Não converta sucesso do verificador em aprovação estética.
3. Examine os patches V4/V5 sem aplicá-los automaticamente. Se usar o checkout, confira branch, HEAD, diff não commitado, consumidores e decisões 034–036. Teste conceitualmente RNG por identidade/canal e proteção de áreas pela geometria do jogo. Não sobrescreva o WIP nem substitua os dois mapas gerados pelo pacote.
4. Se houver Godot e aparelho alvo, capture `Main.tscn` e documente runtime e desempenho; caso contrário, marque PENDING. O pacote só traz rasterizações e montagens estáticas.
5. Aponte erros adicionais do processo e proponha a menor próxima iteração visual do **grupo**, preservando o que Bruno preferiu na V1. Costa/mangue/pedras V8 só depois de estabilizar a vegetação.

Entregue tabela por candidato com **PASS, FAIL, PENDING, grau de evidência, arquivo/hash e ação recomendada**. Termine com lista de correções prioritárias. **Não afirme aprovação ou integração, não faça push nem PR nesta auditoria.**
