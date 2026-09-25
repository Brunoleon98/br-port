# BR Port — prompt atualizado após o merge (25/09/2026)

Este prompt substitui o de `BRIEFING_PROXIMA_CONVERSA_2026-09-25.md` para
abrir a próxima conversa no Claude. O primeiro briefing permanece como
registro do estado anterior ao PR; as lições duráveis estão em `CLAUDE.md` e
`docs/design/BR_Port_Referencias_Interface_Gestao.md`.

---

Quero continuar a melhoria da interface do BR Port, jogo mobile de gestão de
porto em Godot 4.6. Comece pela `main` atual. Leia `AGENTS.md`, `CLAUDE.md`,
`docs/ESTADO_DO_PROJETO.md`, a seção 7 de
`docs/design/BR_Port_Plano_v3_Claude_Code.md` e
`docs/design/BR_Port_Referencias_Interface_Gestao.md`. Confira PRs abertos
antes de mexer em arquivos compartilhados.

O PR [#86](https://github.com/Brunoleon98/br-port/pull/86), com a primeira
passagem de interface da frente 3 do A5, já foi mergeado na `main` pelo commit
`19a339a0a88caf89a23ad19e09ec46b1e7042413`. Não procure a mudança numa
branch local nem tente abrir novamente esse PR. Ela reorganizou o boletim da
Dona Cida, a contra-oferta, a cobrança do Sr. Ribeiro e o balanço; a cobrança
mostra quanto falta ou quanto sobrará, e a contra-oferta mostra preço/certeza
ou a chance efetiva calculada com reputação. A pesquisa com Mini Metro,
Against the Storm e Port Royale 4, com fontes oficiais, crítica e comunidade,
e os limites do que foi adotado estão no documento de referências acima.

Minha avaliação continua: ficou melhor, mas pode melhorar ainda mais.
Continue esses quatro painéis com uma próxima iteração pequena e coerente,
inspirada por boas interfaces de jogos de gestão. Busque ou verifique novas
referências se ajudarem; não copie arte ou disposição proprietária, não
invente mecânicas e não transforme as cartas narrativas em dashboards.
Verifique texto, contraste, alvos de toque, estados antes/depois da escolha e
se preços e probabilidades exibidos correspondem à lógica real. Não altere
economia, progressão ou constantes `# TUNING` para resolver aparência.

Antes de qualquer captura ou suíte que limpe dados, resolva um risco concreto:
`brport_vs/tools/capturar_cena.gd` e `capturar_tela.gd` chamam
`GameState.clear_save()`; algumas suítes também o fazem. Numa captura desta
rodada, o `user://savegame.json` do desktop Windows foi substituído por uma
partida nova (turno 1, R$400.000, nomes vazios). Não havia backup anterior
feito na sessão. Preserve o save que existe agora. Não rode essas ferramentas
no perfil normal até isolar o `user://` de modo verificável ou garantir que as
ferramentas preservem o save mesmo quando falharem. Explique a solução e os
limites antes de voltar a gerar evidência visual. A ocorrência completa está
em `docs/design/BR_Port_Referencias_Interface_Gestao.md`.

As verificações da passagem anterior foram parciais: importação headless do
Godot, `tools/conferir_escopo_ui.py` e `git diff --check` passaram; quatro
suítes e o validador de assets passaram antes do segundo commit de interface,
mas não foram repetidos depois pelo risco ao save. O teste de fumaça tinha
dois problemas preexistentes iguais na `main`; `conferir_docs.py` apontava 18
ocorrências preexistentes. Reavalie o estado atual, sem chamar isso de aceite
visual. As duas capturas iniciais, `ribeiro.png` e `contraoferta.png`, ficaram
fora do repositório em
`C:\Users\bruno\.codex\visualizations\2026\09\25\01a0d5f3-63a0-7921-815b-c4dec79575c3\interface-referencias-comparacao\`.
Se não estiverem acessíveis, peça-as a mim ou gere novas somente depois do
isolamento seguro do save.

Depois, avalie a interface em 720×1280, aplique a iteração, mostre evidência
comparável e peça meu veredito visual. Não marque a frente como aceita por
conta própria. Registre fontes, decisões, lições e limites no lugar permanente
adequado, além do briefing. Trabalhe numa branch nova a partir da `main` e
siga as regras do repositório para entregar mudanças por PR; não empurre
diretamente para a `main`.
