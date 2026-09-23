# BR Port — prompt para a próxima conversa · V16

Continue o trabalho visual da **F1** a partir deste estado. Leia este registro e confira os arquivos reais antes de editar ou gerar algo. Uma prancha aprovada é **referência conceitual**: não é sprite pronto, tile testado, animação ou asset integrado ao Godot.

## Fechamento desta sessão

- **13 — arbustos e vegetação baixa:** Bruno avaliou `13_arbustos_vegetacao_baixa_previa_v4.jpg` e respondeu **“Ficou bom”**. Registrar **aprovação conceitual da V4**, sem reabrir esse número por falta de aprovação. Arquivos finais em `Jogo - BR Port`: `13_arbustos_vegetacao_baixa_mangue_v4.png` e `13_arbustos_vegetacao_baixa_previa_v4.jpg`. A prancha reúne seis variações de vegetação baixa e passagem para mangue jovem; nenhuma variante individual foi escolhida para produção ou testada na escala real.
- **01–12:** aprovados conceitualmente conforme `PROMPT_BR_PORT_PROXIMA_CONVERSA_V13.md`; para a capivara, a referência final é a cena em escala pequena de `12_capivara_conceito_v3.png`.
- **14 — postes e cercas:** V2 aprovada conceitualmente. `14_postes_cercas_conceito_v2.png` e `14_postes_cercas_previa_v2.jpg`.
- **15 — barreiras e cones:** V2 aprovada conceitualmente. `15_barreiras_cones_conceito_v2.png` e `15_barreiras_cones_previa_v2.jpg`.
- **Mangue, água e pedras do cais:** V8 aprovada conceitualmente. `MANGUE_AGUA_PEDRAS_F1_V8_CONCEITO.png` e `MANGUE_AGUA_PEDRAS_F1_V8_PREVIA.jpg`. A pendência de harmonizar a água com a vegetação foi resolvida **no conceito**, ainda não no mapa do jogo.
- A prévia JPG da vegetação 13 foi apresentada em link individual e exibida nesta sessão. Bruno não relatou falha de exibição. Nenhum arquivo do repositório foi editado, nem houve commit, push ou PR nesta sessão.

## Verificação do projeto nesta sessão

O checkout `/workspace/scratch/312fe57af6bb/br-port` existia na branch `art/f01-galpao`, com worktree limpo e último commit **local** `cc36166 Refine the F1 warehouse states`. Esse caminho e estado podem mudar: confirme novamente. Não presuma que o commit esteja publicado no GitHub.

- `tools/gerar_mapa_iso.py`: a vegetação de solo é desenhada por `vegetacao_do_solo()` no próprio SVG do mapa; o gerador também controla gradiente costeiro, praia, pedras e enrocamento. A V4 e a V8 **não** preservam posições ou máscaras técnicas desse gerador.
- `brport_vs/scenes/Main.tscn`: consome `f01_mangue_norte.svg` e `f01_mangue_sul.svg`, além dos PNGs `poste.png`, `poste_luz.png`, `barreira.png` e `cone_transito.png`.
- `brport_vs/scripts/Main.gd`: anima a oscilação luminosa de nós `PosteLuz`; o poste e a luminária são partes separadas. Preserve esse contrato se uma variante vier a substituir o poste atual.
- `blender/brp_porto.py` e `tools/gerar_props_iso.py` foram localizados. A presença de PNGs em `brport_vs/art/props/` não comprova que uma nova variante conceitual esteja integrada.
- Consulte também o plano `PLANO_PRODUCAO_ASSETS_BR_PORT_V2.md` e os consumidores e testes atuais. O plano pede consumidor, fonte reproduzível, pegada, âncora, estados, escala, prova no mapa e gates de desempenho antes de promover qualquer peça a produção.

## Próxima tarefa recomendada

Os números 01–15 da rodada conceitual estão aprovados. **Inicie a passagem conceito → asset da F1**, começando por uma ficha curta e verificável da vegetação 13 e da interface mangue/água/pedras V8. Para cada peça candidata, registre:

1. variante escolhida e função visual no mapa; se a escolha não puder ser inferida da aprovação da prancha, apresente uma proposta concreta e peça a decisão de Bruno;
2. consumidor real (gerador SVG ou nó/cena Godot), fonte reproduzível, área/pegada, âncora e ordem de desenho;
3. tamanho legível a **1:1 na tela móvel**, relação com casa, rua, cais e fauna, e proteção de portas, rotas, docas e pontos de interação;
4. estados e animação **somente se houver consumidor**; evidência de captura no mapa F1 e teste de costura/oclusão;
5. impacto em desempenho, plano de validação e arquivos que outra frente de trabalho poderia estar editando.

Para a V8, trate a imagem como direção de **gradiente, cor da água, transição das raízes e forma de enrocamento pequeno e irregular**. Reconstrua no gerador e prove no mapa; não copie a composição como textura sobreposta nem afirme que a água já foi corrigida no jogo.

Se Bruno pedir mais conceitos em vez de produção, siga a direção dele. Faça **uma candidata por vez**, com PNG conceitual e JPG opaco individual, nomes versionados e links separados para Android. Aguarde a avaliação antes de avançar para outra imagem.

## Limites

- F1: vila costeira brasileira pequena e cais herdado; isometria fixa 2:1, volume low-poly, desgaste localizado e leitura em celular. Sem contorno preto, texto dentro da arte ou microdetalhe que desapareça na escala real.
- Não trate a aprovação de conceito como autorização para alterar economia, save, quantidade funcional de docas, rotas ou arquitetura de cidade. Não faça commit, push, PR ou merge em nome de uma aprovação de prancha.
- Registre no próximo fechamento os nomes reais dos novos arquivos, decisões explícitas, pendências técnicas e eventuais problemas de exibição.
