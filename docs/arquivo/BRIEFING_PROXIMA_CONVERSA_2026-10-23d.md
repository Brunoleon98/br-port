# Próxima conversa — correção do timeout do PR #148

Continuar BR Port em `br-port/`, somente o fechamento do RB5 no
[PR #148](https://github.com/Brunoleon98/br-port/pull/148), branch
`codex/rb5-texto-global`, base main `ed2c770`. Bruno autorizou publicar o PR
e informou o problema de CI. Correções dessa entrega e push normal ao mesmo
PR continuam autorizados. Sem merge pelo Codex ou outra frente.

Ler `AGENTS.md`, `CLAUDE.md`, Ambiente em `.claude/rules/gerais.md`, regras
de plataforma e testes/guardas, estado, §7 do plano e decisão `135`.
O diagnóstico está em
`docs/arquivo/VERIFICACAO_RB5_2026-10-23/CI_TIMEOUT.md`.

## Problema corrigido, resultado remoto ainda por conferir

No head `5608871`, Testes `40009772197` foi cancelado porque o job de
mutantes atingiu 90 minutos após detectar 155/158 defeitos, sem FURADO.
Faltaram três e as bases finais; não houve MUTANTES OK remoto.
O limite total passa para 120 minutos. Fontes, catálogo, guardas e limites
por execução permanecem iguais. Conferir a nova corrida do head corrigido
e registrar os marcadores finais, todos os pares e a sentinela.

Os logs oficiais do head anterior confirmam as seis suítes, DOCS OK e
sentinelas; exports APK/Web com identificação da junção `abaae0b6`; Captura
`40009772213` com cobertura e sentinela. O artefato visual e os binários não
foram baixados nesta consulta. Não transferir esses resultados para outro
head. O recibo local mantém a identidade exportada antes do commit.

⚠️ A distinção entre head, junção testada e build publicado está em
`.claude/rules/plataforma.md` e na decisão `135`. Um PR não altera o Pages;
main publicada segue `ed2c770`. Teste físico no telefone continua pendente.

## Preservar antes de editar

Fetch normal trouxe `origin/ccr-cce8964c-k07qy0`, que ocupa a decisão `136`
e o briefing `23c`. O pré-PR avisa sobreposição anterior em Main e nos
documentos de fecho; esta correção mexe somente no workflow e documentação.
Não editar a frente concorrente. Reconsultar refs, PRs e CI antes de novo
trabalho; preservar branches, backup refs, worktrees e `.evidencias/`.

⚠️ Suítes/capturas/mutantes não correm em paralelo (`CLAUDE.md`, Como rodar).
A interrupção de mutantes pode deixar cache importado alterado; restaurar
o import antes de reutilizar aquela cópia (`.claude/rules/testes-e-guardas.md`).
Não repetir o catálogo local apenas para aumentar o orçamento do CI: a fonte
do jogo não mudou. Não usar o catálogo local como verde remoto.

Permanecem os limites do RB5: sem alterações de save/SAVE_VERSION, economia,
RNG, dia/serviço/missão/meta, mapa/Mata, projeção/viewport, autoload ou outra
etapa da Fase 2. Preservar fundo v3 e celular. Não apagar dados do navegador.
Aplicar `/fechar-sessao`; prompt copiável só quando Bruno pedir.
