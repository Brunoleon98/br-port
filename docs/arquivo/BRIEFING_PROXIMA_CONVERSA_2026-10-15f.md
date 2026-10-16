# BR Port — Como jogar/glossário implementado localmente

**15/10/2026.** Bruno autorizou implementar após a definição da `114`;
a `115` registra o aceite específico e a entrega. Conteúdo compartilhado,
duas portas, navegação e preservação da partida foram implementados.
Estado, plano e recorte foram atualizados. Publicar outro PR segue sem autorização.

Main reconferida no fecho em `f03302d`, sem PR aberto. PR #133 fundido;
Testes e Captura verdes no head `9dc0732` e no merge, Pages verde.
PRs #131 e #132 seguem fundidos em `82a9df0` e `b142b80`.
A branch `codex/implementar-como-jogar` conserva os fechos locais
`71613f6` e `3236d0a`; a anterior e a de nomes `0a0ab5c` foram preservadas.
Decisão seguinte: `116`, a reconferir. Fecho local, sem push ou PR novo.

Aplicado `.claude/skills/fechar-sessao/SKILL.md`: seis suítes passaram no
Godot 4.6.3 com marcadores finais e critérios do CI; T25 final passou com
352 verificações. Seis mutantes semânticos foram rejeitados, com fonte
restaurada e controle saudável entre eles. O F16 foi alinhado às listas
aprovadas, e o F19 não ganhou isenção; fumaça e T25 foram repetidos e passaram.
Contraste: 713 textos/39 estados, zero reprovações/pendências.
UI, guardas do CI, documentos e sentinela passaram, esta também após as fotos.

Bateria com 85 PNGs e `COBERTURA OK`: 21 painéis e 16 tempos fotografados.
Foram olhadas dez imagens da ajuda: seis pelas duas portas reais e quatro
quadros de prova de proporção/fim da rolagem em SubViewports. Não são telefone.
Logs, receitas, imagens, tentativas e hashes ficam em
`docs/arquivo/VERIFICACAO_COMO_JOGAR_2026-10-15/`.
O estado ficou em 29.976 bytes, sem aumentar teto.
Estudos, pacotes do cancelamento e GameState permaneceram intactos.

A lição específica de sair da árvore durante a espera do layout está
comentada em `brport_vs/scripts/PainelComoJogar.gd`, na restauração da leitura.
O cabeçalho segue a família existente, com contraste medido. Os avisos locais
ficaram nos logs; não se declara a importação histórica com `Safe save failed`
diagnosticada ou resolvida. Leitura, telefone e A4 continuam pendentes.
Este head local não tem CI novo; não houve publicação nem recomendação de merge.

Prompt para colar:

```text
Continuando o BR Port no repositório br-port/. Leia AGENTS.md,
docs/ESTADO_DO_PROJETO.md, §7 de
docs/design/BR_Port_Plano_v3_Claude_Code.md, decisões 109–115,
docs/RECORTE_COMO_JOGAR_GLOSSARIO_2026-10-15.md e
docs/arquivo/VERIFICACAO_COMO_JOGAR_2026-10-15/README.md;
use 103 e 108 como contexto. Confira main remota, PRs abertos e
o próximo número livre antes de editar.

Bruno aprovou a definição na 114 e depois respondeu “Sim” à autorização
específica de IMPLEMENTAR Como jogar/glossário, registrada na 115.
A implementação está concluída localmente. Não reabra o aceite do recorte
nem a autorização de implementar. Publicar outro PR NÃO foi autorizado.
O próximo passo depende do Bruno: revisar a ajuda, conduzir leitura por
pessoa nova/teste no telefone e decidir se autoriza publicação em novo PR.
Não presuma aceite humano nem autorização de publicação.

Branch atual: codex/implementar-como-jogar, com fecho em commit local,
descendente de f03302d e dos fechos 71613f6 e 3236d0a. Nenhum push ou PR novo.
A branch anterior codex/implementar-cancelamento-servico e seus fechos foram
preservados. Confira git status/log e commits fora da main antes de reapontar.
Preserve .evidencias/ não rastreada; os lançadores e os logs desta entrega
ficam em .evidencias/implementar-como-jogar/.

A main reconferida continua f03302d, merge do PR #133. Seu head 9dc0732
e o merge passaram em Testes e Captura; o Pages do merge passou.
#131 foi fundido em 82a9df0 e #132 em b142b80. Não havia PR aberto no fecho.
A main contém decisões até a 112; 113, 114 e 115 estão locais.
O próximo número livre depois da 115 era 116; confira novamente.
O novo head local não tem CI remoto; confira o CI se um PR for autorizado.

Como jogar está na inicial (entre Carregar e Ajustes, ou entre Nova partida
e Ajustes sem save) e na pausa (entre Continuar e Ajustes). Continuar mantém
o destaque. PainelComoJogar.tscn/.gd e ConteudoComoJogar.gd compartilham
seis assuntos e glossário. Artigo volta ao índice; índice volta à origem,
mantendo a pausa. Botões e Voltar do aparelho seguem esse percurso,
inclusive no fim da partida. A consulta preserva estado, RNG, save e registro.
Números vêm das regras reais. O texto do autosave é:
“O jogo faz gravações automáticas durante a partida.”
Não repete tutorial, cria resumo de retomada nem funções novas de salvamento.

Verificação local: seis suítes com marcadores finais e critérios do CI,
T25 final com 352 verificações, seis defeitos semânticos rejeitados com
restauração e controle saudável entre eles. F16 exige as listas exatas e
o pedido da ajuda; F19 segue sem isenção nova. Contraste: 713 textos em
39 estados, zero reprovação/pendência. Guardas de UI/CI, DOCS OK e os cinco
arquivos da sentinela passaram, esta também após as capturas.
Bateria: 85 PNGs, COBERTURA OK, 21 painéis e 16 tempos fotografados.
Dez imagens da ajuda foram olhadas: seis pelas portas reais e quatro quadros
de prova em SubViewports, incluindo fim do glossário. Estes quadros não são
teste no telefone. Pacote, logs, receitas e hashes estão na verificação 115.

Os logs preservam avisos locais de encerramento e os avisos conhecidos
da fumaça. A limitação histórica Safe save failed da importação continua
sem causa isolada; não a declare resolvida ou limpa. O pacote distingue
as tentativas iniciais das verificações finais aprovadas.

Cancelamento já está na main (111, implementação 5353644): barco iniciado
sai definitivamente; doca e trabalhador livres no mesmo dia; sem parcial;
−5 de reputação e multa de 10% do acordo sem bônus, arredondada para cima.
Saldo negativo permitido até o fecho; save 18 migra 17→18, registro 5 e contas
integrados. Preserve docs/arquivo/VERIFICACAO_CANCELAMENTO_2026-10-15/ e
docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/. GameState, economia,
versão do save, viewport e sementes não mudaram na ajuda.

Preserve docs/PESQUISA_RECURSOS_BASICOS_2026-10-15.md e
docs/REVISAO_RECURSOS_BASICOS_2026-10-15.md: propostas, fontes, inventário
e falhas de save continuam úteis. Publicá-los não autorizou implementar
a lista. Resumo de retomada continua a sugestão seguinte, sem aceite.
A ajuda não promete escrita verificada, exportação ou recuperação do save.

Não é cancelamento de obras nem nova etapa da Fase 2. Mais trabalhadores
e crédito voluntário ficam para depois; tutorial e segunda chance já feitos.
A4 e caderno reescrito seguem sem aceite. Preserve codex/corrigir-nomes-web
(107, commit local 0a0ab5c) separada: sem autorização de publicação e sem
teste de digitação no telefone. Ao encerrar, aplique /fechar-sessao e entregue
o prompt completo da próxima conversa em bloco copiável, como exige AGENTS.md.
```
