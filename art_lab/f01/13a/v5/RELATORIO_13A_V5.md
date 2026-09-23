# BR Port F1 — 13A V5 · revisão da estrutura das folhas

**23/09/2026 · candidata em revisão · `ready_for_release=false`.** A V4 foi rejeitada visualmente por Bruno: parecia um aglomerado mal feito em vez da vegetação do conceito. A V5 responde a essa crítica. Não houve edição, commit, push ou PR no checkout do jogo.

## O que mudou

Removi a silhueta contínua da V4. A V5 desenha **três rosetas desiguais de folhas largas**, cada uma com miolo sombreado e folhas facetadas que apontam em direções diferentes. A roseta central é um pouco mais alta; a lateral direita, menor e oblíqua. Dois planos ocres nascem do ramo esquerdo. Sombras e ramos são locais a cada grupo, sem extrusão vertical.

No mapa lógico, o espécime V4 media aproximadamente **19 × 16 px** e a V5 mede **20 × 12 px**. A V5 lê como arbusto baixo e separado em folhas na ampliação. A diferença do conceito continua real: a referência possui volumes mais cheios e densidade mais natural; a V5 pode parecer ornamental ou rarefeita no tamanho de uso. **Aprovação estética: PENDING.** Não apresento a V5 como equivalente ou integrada.

As pranchas `13a_v5_comparacao_conceito_v4_v5.jpg` e `13a_v5_tres_posicoes.jpg` apresentam o grupo original, o componente marcado, V4/V5 na **mesma escala lógica**, ampliação e três lugares do mapa. `13a_v5_mapas_v4_v5.jpg` mostra as duas versões inteiras. Todas são rasterizações **Inkscape**, sem cena Godot ou aparelho.

## Resultado técnico

| Prova | Resultado | Evidência/limite |
|---|---|---|
| Forma isolada, fonte e dois SVGs | **PASS** | Hashes em `qa_v5.json`; PNG RGBA de 256 × 256 com margem alfa. |
| Cinco âncoras V4 → V5 | **PASS** | Idênticas; semente de posição por identidade preservada. |
| 100 sorteios extras da forma | **PASS** | Nenhuma das cinco âncoras da V5 se moveu. |
| Instância isolada | **PASS** | Mesmo trecho SVG da primeira instância nos dois mapas V5. O PNG não é textura consumida pelo jogo. |
| Tabela de âncoras do jogo | **PASS** | Mesmo SHA-256 da V4 e do checkout base: `e3bc81b8762263c163786f2c756d1906b54bc1bc9f5f4b8d982a2998388aa683`. |
| Áreas protegidas no mapa/pátio | **PASS limitado** | Máscara projetada das faixas de via, cotovelos, acessos, lotes e áreas de píeres da geometria do jogo, independente da imagem de diferença. **0 pixels alterados dentro da máscara** nos dois estados. O mapa mudou em 979 pixels por estado; contagem não atesta beleza, rota animada ou clique. |
| Godot, Samsung A23, revisão humana e costa V8 | **PENDING** | Ambiente sem Godot/aparelho; Bruno ainda não avaliou a V5; V8 depende da 13A. |

**Verificador V5:** 14 PASS, 0 FAIL, 4 PENDING. Os 14 testes negativos do QA V3 passaram na rodada anterior; seu relatório V3 permanece no pacote para auditoria histórica. O resultado estático não libera a peça.

## Passagem para o código

Base local auditada: branch `art/f01-galpao`, commit `cc36166a262a751494ca3ccd25f1359f77b18fc1`, com alterações V3 anteriores em `tools/gerar_mapa_iso.py` e nos dois mapas. O gerador V3 de entrada tinha SHA-256 `e4c3d35e86f9f37e444a7f08ae51e7e64ebe09385a19bd9f9d126949df66e499`. V4 e V5 foram criadas **fora do checkout**. O patch `13a_v5_proposta.patch` foi conferido com `git apply --check` contra esse estado e contém a forma V5 e a separação do RNG. As decisões canônicas 034–036 permanecem.

No destino, confirmar branch, diferenças locais, consumidores e hashes. Adaptar o patch se o gerador mudou; regenerar os dois estados, testar proteção, design e cena real. Não copiar os mapas completos do pacote sobre arquivos mais recentes. Só registrar aprovação vinculada aos hashes da revisão avaliada. A transição mangue/água/pedras V8 começa depois que a 13A funcionar visualmente no mapa e na cena.
