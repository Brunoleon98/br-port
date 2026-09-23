# BR Port F1 — 13A V4 · revisão visual e técnica

**Data:** 23/09/2026. **Estado:** candidata em revisão, `ready_for_release=false`. Nenhum arquivo foi aplicado ao repositório, commitado, enviado ou integrado ao Godot.

## Base e alvo

- Checkout examinado: `art/f01-galpao` em `cc36166a262a751494ca3ccd25f1359f77b18fc1`. O worktree já tinha modificações em `tools/gerar_mapa_iso.py` e nos dois SVGs. O gerador tinha SHA-256 `e4c3d35e86f9f37e444a7f08ae51e7e64ebe09385a19bd9f9d126949df66e499`.
- As variantes V2/V3 continuam preservadas. A V4 usa a moita frontal do grupo superior esquerdo de `13_arbustos_vegetacao_baixa_mangue_v4.png` como direção. A região laranja da prancha é uma interpretação visual; as copas vizinhas ainda a ocultam parcialmente. A referência não informa escala técnica.
- Consumidor previsto: os dois SVGs gerados por `tools/gerar_mapa_iso.py`, dentro do mapa de `Main.tscn`. O PNG isolado nesta entrega serve somente para examinar uma instância. Decisões 034–036 continuam válidas.

## Mudança artística

O desenho V4 troca as saias verticais rígidas por oito massas foliares sobrepostas, bordas curvas com algumas pontas e três alturas. Duas aberturas escuras distinguem folhas da frente e de trás. A escala lógica do mapa permaneceu próxima da V3: caixa alfa isolada de aproximadamente **18 × 14 px** na V3 contra **19 × 16 px** na V4, na transformação de desenho 1080 → mapa 720. São medidas do espécime, não notas de qualidade.

Na prancha 1:1, a V4 deixa de se ler como um bloco tão uniforme. Na ampliação, ainda parece uma pequena moita compacta; a referência tem profundidade, folhas mais numerosas e grupos laterais mais soltos. A folha seca ocre da V4 é discreta demais para reproduzir o contraste quente do conceito. A primeira posição fica visualmente próxima de uma casa e exige avaliação de oclusão no jogo. **Aprovação estética de Bruno: PENDING.**

## Implementação proposta, isolada

- `arbusto_v4.py.txt` contém a função nova; `build.py` exige o hash exato do gerador V3, copia apenas a cena para a pasta de laboratório e gera os dois mapas em `v4/`. `13a_v4_proposta.patch` mostra somente a alteração proposta do gerador; deve ser adaptada no checkout alvo caso ele tenha mudado. Não use os mapas completos do pacote para sobrescrever o projeto.
- As cinco identidades são `f01_13a_1_0` a `f01_13a_2_1`. SHA-256 de identidade + canal gera RNGs distintos para **posição** e **forma**. A V4 move pouco algumas âncoras em relação à V3, mas o aumento de 100 sorteios na forma não desloca nenhuma das cinco na V4.
- O espécime `13a_v4_instancia_1.svg/png` foi gerado com o ID e a semente da primeira instância. Seu trecho SVG coincide textualmente nos **dois** mapas V4. Isto não significa que o PNG seja textura consumida pelo Godot.
- A geração V3 com `--sem-pavimento --sem-predios --sem-pieres` e `--sem-predios --sem-pieres` reproduziu byte a byte os SVGs existentes, antes de alterar a cópia isolada. A tabela de âncoras da V4 manteve o mesmo SHA-256 do checkout: `e3bc81b8762263c163786f2c756d1906b54bc1bc9f5f4b8d982a2998388aa683`.

## Testes executados

| Verificação | Estado | Evidência e limite |
|---|---|---|
| 14 testes do `qa_assets.py` V3 | **PASS** | `unittest`: 14/14; os casos negativos rejeitam evidência, máscara e revisão inadequadas. |
| Auditoria original V3 repetida | **FAIL** para posição | 12 PASS, 1 FAIL, 2 PENDING, 1 REVIEW, 2 INFO; falha do RNG compartilhado reproduzida. Esse relatório é histórico da V3. |
| PNG V4, fonte e saídas com SHA | **PASS** | PNG RGBA 256 × 256 com transparência; hashes em `qa_v4.json`. |
| RNG real da V4 | **PASS** | Cinco âncoras idênticas antes/depois de 100 sorteios extras por forma. |
| Espécime e mapa | **PASS** | Mesmo trecho SVG da instância 1 nos dois mapas e repetição determinística. |
| Mapa de terra e pátio | **PASS** | Ambos 720 × 720. Diferença de 1.048 pixels cada, bbox `[48,29,178,181]`. Contagem é diagnóstico, não qualidade. |
| Portas, lotes, vias, acessos, docas | **PASS limitado** | Máscara independente do diff, projetada de `faixas`, `cotovelos`, `acessos`, `lotes`, `lotes_reservados` e centros/raízes de píeres da tabela de geometria do jogo, somada a margens. Protege 137.831 de 518.400 pixels; **zero pixels alterados dentro dela** em ambos os mapas. Não testa rota animada ou clique em runtime. |
| Captura da cena no Godot | **PENDING** | Godot não instalado neste ambiente; todas as imagens do pacote são rasterizações Inkscape, sem HUD, mangues da cena, interação ou oclusão dinâmica. |
| Samsung A23 3 GB e aprovação visual | **PENDING** | Sem aparelho ou julgamento de Bruno da V4. |
| Transição V8 mangue/água/pedras | **PENDING** | Direção conceitual já aprovada. O mapa V4 não alterou costa, água ou pedras; avançar depois do julgamento visual e integração técnica do 13A. |

**Resultados da V4:** 12 PASS, 0 FAIL, 4 PENDING, `ready_for_release=false`. O resultado não autoriza promover a candidata a asset integrado.

## Arquivos de revisão

- `13a_v4_comparacao.jpg`: grupo de referência, região marcada, V3/V4 no tamanho lógico 1:1 e ampliação **2,7×**. O recorte da referência foi ajustado para caber na prancha e não é comparado pixel a pixel.
- `13a_v4_tres_posicoes.jpg`: três lugares no mapa com janelas idênticas antes/depois em tamanho lógico 1:1 e ampliação **2,44×**; ponto laranja indica a âncora no chão, que pode ficar escondida pela construção.
- `13a_v4_mapas_antes_depois.jpg`: 720 × 720 por estado, comparação estática completa.
- `mascara_geometria_protegida.png` e `qa_v4.json`: máscara e resultado reprodutível.

## Passagem à frente de código

1. Conferir branch, `git status`, diferenças locais, decisões 034–036 e consumidores no destino. Não aplicar o patch ou substituir mapas quando o gerador ou a cena divergirem dos hashes auditados; adaptar a alteração mantendo o WIP existente.
2. Aplicar apenas o pequeno patch no gerador, manter RNG por identidade/canal e regenerar os **dois** estados com os flags registrados. Conferir SHA da tabela de âncoras, cinco âncoras, máscara protegida e testes de design do projeto.
3. Capturar `Main.tscn` no Godot com mangues, HUD e interação, medir oclusão do primeiro arbusto e custo no A23. Registrar imagens/medidas da revisão aprovada por hash; só então decidir integração e liberação.
4. Depois do aceite da 13A, reconstruir V8 no gerador e nos mangues norte/sul apenas se necessário; comparar praia, cais, raízes de píer e pontas do mapa antes/depois, preservando enrocamento e rotas.
