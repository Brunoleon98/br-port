# Próxima conversa — 23/10/2026

Continuar BR Port em `br-port/`. A integração do RB5 está pronta localmente
na branch `codex/rb5-texto-global`; publicação não está autorizada.
A tarefa seguinte é a que Bruno indicar, sem reabrir a escolha já aceita
nem iniciar outra frente por inferência.

## Ler primeiro

- `AGENTS.md`, `CLAUDE.md` e `.claude/rules/gerais.md`, especialmente Ambiente;
- regras de interface, GDScript, testes/guardas e captura;
- `docs/ESTADO_DO_PROJETO.md` e §7 do plano v3;
- decisões `131`, `134` e `135`;
- `docs/arquivo/VERIFICACAO_RB5_2026-10-23/README.md` e seu recibo;
- `/fechar-sessao` ao encerrar, sem imprimir prompt completo na resposta salvo pedido.

## Aceite e entrega local

Bruno aprovou «Três colunas com +25% (recomendado)». Não perguntar de novo.
Padrão/Maior nos Ajustes de início/pausa; três colunas roláveis na operação,
Construir/Menu/Avançar fixos; painéis, caderno, campos e celular acompanham.
A preferência de texto coexiste com a de movimento no mesmo ConfigFile;
cada setter carrega o arquivo antes de escrever sua chave.

Seis suítes com os marcadores finais; 158 mutantes, todos os pares declarados,
bases antes/depois verdes e restauração exata; sentinelas dos seis arquivos
do jogador intactas. 84 percursos de captura do Maior, 86 PNGs e cobertura conferida. Padrão na
inicial, HUD e celular idêntico ao byte à main. Chromium por toque: quatro
pares texto/movimento, reinício real e save/registro com bytes e mtime intactos.
O arrasto/tap é provado pela GUI nativa. No Web, um arrasto por toque
moveu a barra do porto sem alterar save/registro, após fechar a proposta
pendente no perfil de teste. Telefone físico e publicação continuam pendentes.

O pacote local Web foi exportado quando HEAD era `bf9be01` com árvore
modificada, usando runtime oficial 4.6.3 da main; o recibo identifica fonte/PCK.
Não é resultado de CI do commit local posterior, de junção ou publicação.
O aviso can_process na nova partida foi reproduzido igual no pacote da main.

## Repositório e preservação

Base `ed2c770b105fecb4c9750e5e0fca64735fae97e1`. Consultadas 274 refs remotas:
127 heads e 147 refs de PR; nenhum PR aberto. Os 127 heads coincidem com as refs
locais. Git fetch estava indisponível; conector e comparação registrados.
Antes de editar/pedirPR, reconsultar base, refs, PRs eCI e preservar o trabalho.

Branches preservadas: `codex/rb5-acomodacao-texto` em `bf9be01`,
`codex/fechamento-fundo-inicial-v3` em `c7767d2`, `codex/fundo-inicial-v3`
em `d54eda8` e `work` em `0cd4ca3`, além das três refs `codex-backup` existentes.
Um worktree; não resetar nem apagar branches/acervos. `.evidencias/` fica fora
dos commits. Logs/fotos das passagens anteriores são históricos, não prova
para fonte diferente. Não prometer arquivos montados em outra sessão.

⚠️ A regra de reutilizar autorizações fica em `AGENTS.md`, `CLAUDE.md` e
`.claude/rules/gerais.md`, Ambiente: leitura, edição, testes, capturas,
documentação e commits locais estão autorizados; a permissão de publicar o
fundo no #147 não autoriza publicar o RB5. Não repetir o aceite da mesma v3.

⚠️ Suítes, capturas e mutantes compartilham ferramentas e não correm em
paralelo (`CLAUDE.md`, Como rodar). Usar `.godot-version` e perfis isolados.
O executor reinjeta defeitos temporariamente; aguardar fim e restauração
antes de editar, capturar ou commitar. Arte importada exige restaurar cache
se o executor foi interrompido (`.claude/rules/testes-e-guardas.md`).

⚠️ A decisão `135` e os comentários dos helpers guardam as lições de reflow:
botão em HBox precisa de largura; consulta com rolo expansível não recebe
outro rolo por fora; abrir direto em Maior também se testa. Getters de seleção
só com has_selection (`.claude/rules/gdscript.md`). Leitura inicial do app
pertence ao próprio app, não ao restauro da troca de tamanho.

## Limites vigentes

Fundo v3 aceito e publicado no #147, mesclado por Bruno; main/Pages ed2c770
conferidos no fechamento anterior. Sem merge pelo Codex. A arte continua
RGB opaca 941×1672, SHA256 c8dd35c73b11a13da9d3f773ba916cce10b9307c8d7d1addb79faf9571e7ec6f,
exclusiva da inicial; celular preserva o degradê. Não regenerar.

Não mexer em Mata, testes, arte ou geradores do Claude, nem reabrir 114–116.
Sem force, push para main/Claude, merge pelo Codex, alteração de save,
SAVE_VERSION/migração, economia, RNG, serviço/dia/missão/meta, projeção ou
viewport. Sem Engine.time_scale, autoload novo ou outra etapa da Fase 2.
Não apagar dados do navegador. RB6 no telefone e aceite visual continuam
pendentes. Acervos antigos não montados não foram recuperados por inferência.
