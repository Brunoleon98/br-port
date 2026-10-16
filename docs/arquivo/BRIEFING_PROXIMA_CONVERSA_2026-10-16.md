# BR Port — Publicação de Como jogar/glossário no PR #134

**16/10/2026.** Pedido explícito de Bruno: criar PR e fechar a sessão.
Autorização registrada na `116`. O PR #134 publica a ajuda do commit
`28838f1`, junto dos fechos de definição e aceite. O fecho documental segue
na mesma branch; nenhum código de jogo mudou nesta etapa de publicação.
O PR permanece aberto, sem merge autorizado. Main conferida em `f03302d`.

Aplicado `.claude/skills/fechar-sessao/SKILL.md`: estado, §7 do plano,
recorte e decisão atualizados; provas anteriores preservadas. Documentos
e hashes foram reconferidos; seis suítes e capturas são as da mesma fonte
verificada na `115`. Consultar o CI do último head após este fecho.
Leitura por pessoa nova e telefone permanecem pendentes. A pasta local
`.evidencias/` e a branch da `107` permanecem separadas e preservadas.

A varredura não identificou regra geral nova: os resultados e limites da
implementação já estão na `115` e no pacote de verificação; a mudança de
autorização está na `116`. A limitação histórica da importação permanece
explicitamente aberta nesses destinos. O próximo número livre era `117`.

Prompt para colar:

```text
Continuando o BR Port no repositório br-port/. Leia AGENTS.md,
docs/ESTADO_DO_PROJETO.md, §7 de
docs/design/BR_Port_Plano_v3_Claude_Code.md, decisões 109–116,
docs/RECORTE_COMO_JOGAR_GLOSSARIO_2026-10-15.md e
docs/arquivo/VERIFICACAO_COMO_JOGAR_2026-10-15/README.md;
use 103 e 108 como contexto. Confira main remota, PRs abertos, CI do último
head e o próximo número livre antes de editar.

Bruno aprovou a definição na 114, autorizou implementar na 115 e pediu
“Crie PR e feche a sessão” em 16/10/2026 (116). A ajuda foi implementada
no commit 28838f1 e publicada no PR #134:
https://github.com/Brunoleon98/br-port/pull/134
Branch codex/implementar-como-jogar, com o fecho documental posterior
na mesma branch. O PR foi aberto contra main f03302d e não foi fundido
neste fecho. Não reabra os aceites já dados. A publicação não equivale a
merge nem a aceite de leitura ou telefone. Reconfira o estado real
do PR e o CI do último head antes de recomendar merge; não o funda sem
autorização. O próximo passo é revisar o PR e conduzir leitura e telefone
com Bruno; não começar outra funcionalidade por conta própria.

A última main conferida era f03302d, merge do PR #133. Seu head 9dc0732
e o merge passaram em Testes e Captura; o Pages do merge passou.
#131 foi fundido em 82a9df0 e #132 em b142b80. Só #134 ficou aberto
na publicação. A main tinha decisões até a 112; 113–116 estão na branch
do PR. O próximo número livre era 117; confira novamente.

Confira git status/log e commits fora da main antes de reapontar:
os fechos 71613f6 e 3236d0a foram preservados e integram o PR.
Preserve a branch anterior codex/implementar-cancelamento-servico e
.evidencias/ não rastreada, inclusive .evidencias/implementar-como-jogar/.
Preserve codex/corrigir-nomes-web (107, commit local 0a0ab5c) separada:
sem autorização de publicação e sem teste de digitação no telefone.

Como jogar está na inicial (entre Carregar e Ajustes, ou entre Nova partida
e Ajustes sem save) e na pausa (entre Continuar e Ajustes). Continuar mantém
o destaque. PainelComoJogar.tscn/.gd e ConteudoComoJogar.gd compartilham
seis assuntos e glossário. Artigo volta ao índice; índice volta à origem,
mantendo a pausa. Botões e Voltar do aparelho seguem esse percurso,
inclusive no fim da partida. Consulta preserva partida, RNG, save e registro.
Números vêm das regras reais. O texto do autosave é:
“O jogo faz gravações automáticas durante a partida.”
Não repete tutorial, cria resumo de retomada nem funções novas de salvamento.

Provas locais preservadas: seis suítes no Godot 4.6.3 com marcadores
finais e critérios do CI, T25 com 352 verificações, seis defeitos
semânticos rejeitados com restauração e controle saudável entre eles.
F16 exige listas exatas e pedido da ajuda; F19 sem isenção nova.
Contraste: 713 textos/39 estados, zero reprovação/pendência.
Guardas de UI/CI, DOCS OK e cinco arquivos da sentinela passaram,
esta também após as fotos. Bateria: 85 PNGs, COBERTURA OK,
21 painéis e 16 tempos. Dez imagens da ajuda foram olhadas:
seis pelas portas reais e quatro quadros em SubViewports, incluindo
fim do glossário. São diagnósticos de proporção, não teste físico no telefone.
Logs, receitas, tentativas e hashes estão no pacote de verificação 115;
os 70 hashes do manifesto e fontes foram reconferidos antes da publicação.
O fecho de publicação altera só documentação; confira o CI do head final.

Os avisos locais de encerramento e da fumaça permanecem nos logs.
A importação histórica com Safe save failed continua sem causa isolada;
não a declare limpa ou resolvida. Leitura por pessoa nova, telefone,
A4 e caderno reescrito continuam sem aceite.

Cancelamento já está na main (111, implementação 5353644): barco iniciado
sai definitivamente; doca e trabalhador livres no mesmo dia; sem parcial;
−5 de reputação e multa de 10% do acordo sem bônus, arredondada para cima.
Saldo negativo permitido até o fecho; save 18 migra 17→18,
registro 5 e contas integrados. Preserve
docs/arquivo/VERIFICACAO_CANCELAMENTO_2026-10-15/ e
docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/.
GameState, economia, versão do save, viewport e sementes não mudaram na ajuda.

Preserve docs/PESQUISA_RECURSOS_BASICOS_2026-10-15.md e
docs/REVISAO_RECURSOS_BASICOS_2026-10-15.md: propostas, fontes, inventário
e falhas de save continuam úteis. Publicá-los não autorizou implementar
a lista. Resumo de retomada continua a sugestão seguinte, sem aceite.
Tela inicial, autosave, três espaços, pausa e Salvar e sair já existem.
A ajuda não promete escrita verificada, exportação ou recuperação do save.

Não é cancelamento de obras nem nova etapa da Fase 2. Mais trabalhadores
e crédito voluntário ficam para depois; tutorial e segunda chance já feitos.
Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da próxima
conversa em bloco copiável, como exige AGENTS.md. Avise se ficar perto
do limite de contexto.
```
