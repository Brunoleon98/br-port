# Auditoria BR Port — por onde começar

1. Leia `RELATORIO_AUDITORIA_E_LICOES_APRENDIDAS.md`.
2. Rode `python verificar_manifesto.py BR_PORT_AUDITORIA_ARTE_2026-09-23.zip` ou confira `manifest_sha256.json` manualmente: cada item tem `arquivo_zip`, `sha256` e `bytes`.
3. Use `PROMPT_AUDITORIA_CLAUDE_BR_PORT.md` como instrução para Claude.
4. Inspecione os materiais em `referencias/`, `art_lab/f01/13a/` e `art_lab/f01/vegetacao_grupo/`.
5. `evidencias_git/repo_wip_preexistente.patch` documenta mudanças que já existiam no checkout; não é uma proposta para aplicar.
6. `experimentos_descartados/` contém uma tentativa com halo quase opaco. Não a trate como asset.

Nenhuma candidata foi integrada ou aprovada visualmente. O pacote foi montado em 23/09/2026, sem alterar o checkout do jogo.
