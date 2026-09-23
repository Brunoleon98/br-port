# BR Port — auditoria da produção de assets, 23/09/2026

**Resultado:** o arbusto 13A V3 continua em revisão. O plano V3 foi corrigido para pedir uma prova artística justa e uma prova de integração separada. Esta entrega é um laboratório de qualidade em paralelo ao código; não é um pacote de produção admitido no jogo.

## Evidência da candidata 13A

| Verificação | Resultado | Consequência |
|---|---|---|
| Contrato e imagens com SHA-256; PNG RGBA e margens transparentes; mapas 720 × 720 | Passou | Evidências íntegras e formato básico verificável. |
| Alterações entre prévias Inkscape V2 e V3 | 927 pixels, caixa x=50–175, y=30–181 | Quantifica a diferença estática; sem máscara independente não prova que portas, vias e acessos estejam intactos. |
| Forma e posição no gerador | **Falhou:** mutação no custo de sorteios da forma deslocou as instâncias 2, 3 e 5 de cinco âncoras | Separar RNG por identidade/canal e testar a preservação de âncoras antes de regenerar o mapa. A afirmação anterior de posições fixas foi corrigida na ficha. |
| Reprodução de seis versus sete lobos | Âncoras 2, 3 e 5 mudam | Esta é uma reconstrução do V2 a partir do código visto na conversa, não uma cópia autenticada do gerador antigo. |
| PNG isolado versus primeira instância atual | **Passou** para a saída SVG atual | Embora o mapa faça um sorteio de posição antes da forma, o SVG coincidiu neste estado. Repetir o teste após alterações; não presumir estabilidade. |
| Proposta isolada de RNG por identidade | Passou com 1.000 sorteios extras na forma | Demonstra o comportamento do laboratório; o jogo ainda usa o gerador acoplado. |
| Referência e qualidade artística | **Retrabalho** | O recorte inclui árvore e tronco vizinhos; os lobos `com_saia` leem como blocos de volume. Mais facetas e pixels coloridos não resolvem esse problema. |
| Máscara de áreas protegidas; captura Godot; dispositivo; avaliação humana | **Pendentes** | Sem prova de interação, enquadramento e leitura no aparelho. Esta máquina não dispõe de executável Godot para a captura requerida. |

O resultado completo está em `results/13a_auditoria.json`: **12 PASS, 1 FAIL, 2 PENDING, 1 REVIEW, 2 INFO; `ready_for_release=false`**. A suíte de 14 testes do próprio verificador passou. `REVIEW` também marca seis entradas do manifesto existente como `production` com `open_gates`: não se deve interpretar o uso no projeto como liberação de qualidade.

## Erros de planejamento corrigidos

| Erro do V2 ou da prova anterior | Correção no plano V3 |
|---|---|
| Catálogo pedia estados “em obra” do galpão/escritório apesar das decisões locais 034–036 para compra instantânea. | Preservar ruína e recuperado, só criar estado adicional com consumidor e decisão novos. |
| Exemplo de manifesto incompatível: `output` string, método divergente. | Respeitar o schema atual: `output` lista, `static` para os casos existentes. |
| Aumento de detalhes e métricas de pixel pareciam medir proximidade com o conceito. | Comparação da mesma forma e escala, crítica de silhueta/material/luz, três locais no mapa e revisão humana específica. |
| Referência do arbusto misturava plantas e os candidatos foram normalizados independentemente. | Isolar ou marcar o componente da prancha e alinhar transformação, escala e contexto antes de julgar semelhança. |
| “1:1” sem distinguir desenho, mapa lógico e tela física. | Registrar 1080 → 720, área visível 720 × 660, ampliação do PNG e captura real em dispositivo. |
| Mudança da forma alterava posições pelo RNG compartilhado. | Identidades estáveis e streams separados para posição, forma e animação; mutante testa consumo adicional. |
| SVG/PNG válidos e bbox do diff poderiam ser usados como aceite. | Exigir máscara de exclusão para zonas protegidas, captura em Godot, passagem mobile e liberação humana com hash da revisão. |
| Skeleton2D obrigatório antes de provar consumo. | Rig somente quando estado, animação e controlador reais o exigirem. |

## Próxima iteração concreta

1. Marcar explicitamente o arbusto baixo na referência, mantendo uma vista do contexto completo; gerar comparação com a mesma escala lógica e sombra/câmera.
2. Redesenhar a massa foliar da 13A sem as faces verticais rígidas; testar silhueta sem cor e leitura nas três posições previstas. Guardar a candidata anterior para comparação.
3. No gerador do projeto, separar posição e forma por ID; estabilizar as cinco âncoras, testar a mudança de custo do desenho, regenerar ambos os SVGs e comparar com uma máscara independente de portas, vias, docas e rotas.
4. Capturar a cena em Godot com HUD, oclusão e interação; validar escala e desempenho em aparelho alvo. Anexar evidências com SHA-256 ao contrato antes de mudar gates para `pass`.

As etapas 3–4 são um contrato de passagem à frente do GitHub: devem ser aplicadas pelo responsável pelo código sobre um checkout atualizado e avaliadas antes de commit/PR. Nesta auditoria não houve commit, push ou mudança adicional no checkout compartilhado. O estado do remoto não foi verificado.
