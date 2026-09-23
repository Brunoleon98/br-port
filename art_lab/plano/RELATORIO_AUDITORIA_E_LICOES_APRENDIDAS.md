# BR Port — passagem completa para auditoria independente

**Data do registro:** 23/09/2026. **Escopo:** trabalho de arte desta conversa após o prompt V17; piloto de arbusto 13A V4/V5 e grupo completo de vegetação F1 V1/V2/V3. **Nenhuma candidata foi aprovada para integrar ou liberar.** Os conceitos 01–15 e a direção de mangue/água/pedras V8 tinham aprovação **conceitual** anterior, não aprovação técnica do código. Esta passagem não altera o projeto.

## Resumo executivo e decisões de Bruno

1. A auditoria do 13A V3 identificou falha real: o RNG compartilhado movia âncoras quando a forma consumia mais números aleatórios. Resultado histórico: **12 PASS, 1 FAIL, 2 PENDING, 1 REVIEW, 2 INFO; `ready_for_release=false`**. Os 14 testes do verificador passaram, o que não muda a falha da candidata.
2. Foi desenhada uma **13A V4** com folhas em massas superpostas, correção proposta de RNG por identidade e canal e mapas isolados. Resultado laboratorial: **12 PASS, 0 FAIL, 4 PENDING**. Bruno a considerou visualmente um aglomerado, distante do conceito.
3. A **13A V5** separou folhas em rosetas, preservando a correção de RNG. Resultado: **14 PASS, 0 FAIL, 4 PENDING**. Não houve aprovação estética. Essa linha é um *arbusto individual* com cinco instâncias propostas no gerador.
4. Bruno pediu para usar o **grupo inteiro do conceito**, e não tomar um recorte da vegetação frontal como se representasse toda a composição. Foi criada outra linha, **grupo F1 V1**, que inclui duas árvores, arbustos dianteiros, ramos e sombra numa única textura PNG/SVG. QA próprio: **6 PASS, 0 FAIL**, 2.462 pixels alterados na prévia estática, zero na máscara protegida. Bruno disse que o estilo destoava do jogo.
5. O **grupo F1 V2** diminuiu e clareou as formas para combinar com o mapa. QA: **7 PASS, 0 FAIL**, 598 pixels alterados, zero protegidos. Bruno preferiu a versão anterior; a V2 simplificou demais e deixou os arbustos repetitivos.
6. O **grupo F1 V3** retomou a estrutura da V1, alterou o intervalo dos verdes, compactou ramos laterais e testou 82 × 52 pixels no mapa. QA corrigido: **7 PASS, 0 FAIL**, 1.621 pixels alterados, zero protegidos. **A opinião de Bruno sobre a V3 ainda não foi dada.** Há diferença visível para o conceito: folhagem continua geométrica e a ligação com o chão poderia ser mais orgânica.

**Duas linhas separadas:** `13a/v4` e `13a/v5` são propostas de código/gerador de um arbusto baixo; `vegetacao_grupo/v1..v3` são sprites independentes do conjunto inteiro, apenas sobrepostos em imagens estáticas. Um PNG do grupo **não aparece** no gerador nem na cena Godot; não confundir QA do grupo com QA da 13A. Nenhum mapa do laboratório substituiu mapas do jogo.

## Estado real do checkout e proveniência

- Checkout local examinado: `/workspace/scratch/312fe57af6bb/br-port`, branch `art/f01-galpao`, HEAD `cc36166a262a751494ca3ccd25f1359f77b18fc1`.
- Antes das iterações, já havia alterações sem commit em `tools/gerar_mapa_iso.py`, `brport_vs/art/porto_mapa_iso.svg` e `brport_vs/art/porto_mapa_iso_patio.svg`. Inspeção final ainda mostra os mesmos três caminhos; diff local: 486 linhas adicionadas no total. **Estas mudanças são anteriores, não autoria destas iterações.** O arquivo `evidencias_git/repo_wip_preexistente.patch` é só uma fotografia para auditoria, não um patch para aplicar.
- Trabalho novo ficou em `art_lab/f01/13a/v4`, `art_lab/f01/13a/v5` e `art_lab/f01/vegetacao_grupo/v1..v3`, fora do checkout. V4/V5 contêm patches de **proposta**, não aplicados. Não houve commit, push, PR ou verificação do estado remoto GitHub.
- Decisões canônicas 034–036 foram preservadas; cópias dos documentos estão no pacote. O trabalho de mangue/água/pedras V8 **não foi iniciado nesta conversa** porque faltam validação visual e técnica da vegetação. A referência conceitual V8 está incluída só como contexto.
- Godot não estava disponível neste ambiente (`godot` e `godot4` ausentes). Todas as vistas de mapa são rasterização Inkscape ou sobreposição SVG de PNG existente, **nunca captura runtime**. Não houve teste no Samsung A23/aparelho alvo.

## Inventário e reprodução

| Linha | Arte/fonte principal | Prévias e técnica | Situação |
|---|---|---|---|
| Histórico 13A V3 | `referencias/BR_PORT_QA_ASSETS_V3.zip`; `referencias/13a_arbusto_baixo_v3.png` | Contrato, evidências, `qa_assets.py` e 14 testes no ZIP; replay em `13a/v4/qa_v3_replay.json` | Falha de RNG; apenas histórico. |
| 13A V4 | `13a/v4/arbusto_v4.py.txt`, `13a_v4_instancia_1.svg/png` | `13a_v4_proposta.patch`, gerador cópia, dois SVGs e PNGs do mapa, máscara, `qa_v4.json`, pranchas | Candidata rejeitada visualmente pelo usuário; não integrada. |
| 13A V5 | `13a/v5/arbusto_v5.py.txt`, `13a_v5_instancia_1.svg/png` | `13a_v5_proposta.patch`, gerador cópia, dois SVGs e PNGs do mapa, máscara, `qa_v5.json`, pranchas | Técnica de laboratório estável; estética pendente; não integrada. |
| Grupo F1 V1 | `vegetacao_grupo/v1/vegetacao_grupo_f1_v1.svg/png`, `build.py` | Comparação com conceito completo, três posições, mapa estático, `qa_grupo.json` | Bruno preferiu V1 à V2, mas antes disse que destoava do jogo. |
| Grupo F1 V2 | `vegetacao_grupo/v2/vegetacao_grupo_f1_v2.svg/png`, `build.py` | V1/V2 na mesma escala, três posições, `qa_v2.json` | Direção visual rejeitada pelo usuário. |
| Grupo F1 V3 | `vegetacao_grupo/v3/vegetacao_grupo_f1_v3.svg/png`, `build_source.py` | V1/V3 na mesma escala (82 × 52), três posições, `qa_v3.json` | Candidata atual, sem parecer visual do usuário. |

O `manifest_sha256.json` no pacote lista **cada arquivo empacotado**, tamanho e SHA-256. Os ZIPs de entrega individuais anteriores permanecem disponíveis separadamente; este pacote contém as fontes, relatórios e saídas úteis, evitando ZIP dentro de ZIP. O plano de produção V2 e o prompt V17 foram citados no início, mas **não estavam materializados neste workspace**; usar as versões da conversa/biblioteca se forem necessárias para auditoria literal. O plano V3, ficha F1, relatório V3, prompt V16 e conceito visual estão incluídos.

### Comandos locais de reprodução

Após extrair o pacote, a árvore `art_lab/...` conserva a estrutura relativa. Do diretório raiz extraído, com Pillow e Inkscape instalados:

```bash
python -m unittest discover -s art_lab/f01/13a/v4/qa_v3/tests -p 'test_qa.py' -q
python art_lab/f01/13a/v4/qa_v4.py
python art_lab/f01/13a/v5/qa_v5.py
python art_lab/f01/vegetacao_grupo/v1/qa_grupo.py
python art_lab/f01/vegetacao_grupo/v2/qa_v2.py
python art_lab/f01/vegetacao_grupo/v3/qa_v3.py
```

**Nota de reprodução:** alguns scripts de QA do laboratório assumem arquivos de entrada e caminhos relativos de uma árvore completa; verificar/ajustar caminhos no ambiente do Claude sem alterar a evidência original. As somas documentadas são resultados desta execução, não promessa de portabilidade irrestrita. A suíte de 14 testes e os QA V4/V5 e dos grupos V1/V2/V3 foram reexecutados nesta passagem e passaram; saídas literais em `RESULTADOS_TESTES_REEXECUTADOS.txt`. Execute `python verificar_manifesto.py BR_PORT_AUDITORIA_ARTE_2026-09-23.zip` para conferir SHA-256 e tamanhos do pacote sem extrair.

## Lições aprendidas e falhas a não repetir

1. **Aprovação do conceito não libera um asset.** O desenho do conceito, a peça isolada, a escala no mapa, a renderização no Godot e o comportamento no aparelho são provas diferentes. Registrar a revisão e o hash de cada aceite.
2. **Fixar o alvo visual antes de desenhar.** O recorte anterior de 13A continha árvores e troncos; julgá-lo como "arbusto" confundiu componente e composição. Mostrar sempre o conceito inteiro e marcar qual parte se pretende produzir. Grupo completo e arbusto individual são entregas diferentes.
3. **Preservar forma, não apenas paleta.** A V2 ficou tecnicamente mais próxima da cor do mapa, mas perdeu densidade e hierarquia da V1. A preferência explícita de Bruno por V1 é restrição canônica para a próxima iteração. Não tomar mais facetas, desgaste ou variação de tom por correção de silhueta.
4. **Comparar nas mesmas condições.** V1 vs V2 e V1 vs V3 foram colocadas na mesma posição e escala nas pranchas. Escalas/recortes da comparação histórica da V3 não provam fidelidade. Mostrar tamanho de uso, ampliação e contexto completo.
5. **A arte em uso exige julgamento humano.** O grupo V1 pareceu destoar; a V2 perdeu qualidade; a V3 permanece sem aceite. Os números de pixels e PASS de QA não atribuem nota estética. Evitar declarar sucesso por exportar PNG/SVG válido.
6. **RNG de forma não pode mover a âncora.** O V3 histórico falhou: o consumo extra de sorteios deslocou instâncias 2, 3 e 5 de cinco. V4/V5 propõem sementes por identidade e canais `posição`/`forma`, ensaiadas com 100 sorteios adicionais. Revalidar no checkout real ao integrar.
7. **A máscara de proteção é necessária, mas parcial.** Derivá-la da geometria de lotes, vias, acessos e píeres, independentemente do retângulo de diferenças. Zero pixels na máscara não demonstra ausência de sobreposição com árvores/casas, cliques, rotas animadas ou ordenação de camadas. Três posições exploratórias não são decisões de placement.
8. **Verificador correto pode validar uma candidata ruim.** Os 14 testes do `qa_assets.py` verificam a lógica do verificador. A candidata original continuou com 1 FAIL. Não somar as contagens de QA diferentes como um único resultado.
9. **Nome do teste deve corresponder à condição real.** Os QA dos grupos V1/V2 diziam “RGBA” mas faziam `convert('RGBA')` antes de avaliar ou apenas verificavam dimensão. Os PNGs originais foram inspecionados e são RGBA; o teste da V3 foi corrigido para verificar `raw.mode` e tamanho. V1/V2 permanecem como registros históricos com essa limitação explícita.
10. **Não confiar em transparência pedida a um gerador.** Uma tentativa de cutout por ImageGen foi descartada: pixels longe do sujeito vieram com alfa 253/255 (halo verde quase opaco). Ela está em `experimentos_descartados/` como evidência, **não é asset**. Os PNGs vetoriais finais têm cantos alfa zero.
11. **Preservar WIP antes de aplicar patch.** O checkout já continha mudanças nos três arquivos do mapa/gerador. Os patches V4/V5 são apenas passagem para o código; a integração deve inspecionar branch, diff, consumidores e decisões 034–036 e regenerar ambos os mapas sem sobrescrever trabalho mais recente.
12. **Uma montagem não é captura do jogo.** Sem Godot/aparelho, manter `ready_for_release=false`, ainda que raster, alfa, âncoras e máscara passem. V8 permanece adiada até haver vegetação estável visual e tecnicamente.

## Perguntas objetivas para Claude

1. Os SVGs e PNGs de V1/V3 preservam leitura orgânica do **grupo completo** do conceito no tamanho real? Apontar diferenças de silhueta, volumes, faces, densidade, solo e cor; dizer expressamente se o ganho da V3 frente à V1 é substancial. Não pressupor aprovação da V3.
2. A V2 realmente perde a qualidade que Bruno preferiu na V1? Registrar critérios visuais reproduzíveis em vez de citar apenas preferência.
3. Os patches V4/V5 se aplicariam com segurança ao checkout *atual* sem apagar o WIP? Validar consumidores, seeds, IDs, flags de geração, portas/vias/lotes e os dois mapas. Não aplicar/commitar durante uma auditoria somente de leitura.
4. Quais testes são prova direta, quais são proxy parcial e quais têm rótulo enganoso? O cálculo da máscara é independente o suficiente? Há buracos que permitem dano em casas, árvores ou rotas?
5. Se Godot e aparelho estiverem disponíveis, como comparar em `Main.tscn` sem confundir captura runtime com imagem estática? Relatar o que ficou PENDING se não houver acesso.
6. Indicar a menor mudança concreta para uma V4 do **grupo** que preserve o que Bruno preferiu na V1, e o gate visual/técnico a satisfazer antes da costa V8.

**Instrução de auditoria:** tratar tudo como material de revisão. Não afirmar que uma candidata está integrada, aprovada esteticamente ou pronta para release. Preservar mudanças locais e registrar novas evidências por hash.
