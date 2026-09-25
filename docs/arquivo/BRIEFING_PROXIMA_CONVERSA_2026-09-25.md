# BR Port — prompt para a próxima conversa no Claude (25/09/2026)

Cole o texto abaixo numa nova conversa com o Claude que tenha acesso ao mesmo
repositório local. Este briefing registra esta sessão; as lições duráveis estão
em `CLAUDE.md` e em `docs/design/BR_Port_Referencias_Interface_Gestao.md`.

---

Quero continuar a melhoria da interface do BR Port, jogo mobile de gestão de
porto em Godot 4.6. Leia primeiro `AGENTS.md`, `CLAUDE.md`,
`docs/ESTADO_DO_PROJETO.md` e a seção 7 de
`docs/design/BR_Port_Plano_v3_Claude_Code.md`. Leia também
`docs/design/BR_Port_Referencias_Interface_Gestao.md`, que guarda as fontes,
decisões de tradução e o incidente operacional desta rodada.

Minha avaliação é: ficou melhor, mas pode melhorar ainda mais. Continue a
frente 3 do A5, começando pelos quatro painéis já trabalhados: boletim da Dona
Cida, contra-oferta, cobrança do Sr. Ribeiro e balanço. Use críticas e
comentários de jogadores de jogos de gestão comparáveis como referência de
legibilidade, informação contextual e economia de cliques; verifique fontes
novas se forem necessárias. Não copie arte nem disposição proprietária, não
invente mecânicas e não transforme as cartas narrativas em dashboards. Guarde
as novas lições no lugar permanente adequado, não apenas no próximo briefing.

Estado concreto que você encontrará se estiver no mesmo checkout local:

- Branch `codex/interface-personagens-v1`, com dois commits de interface além
  da `main`: `31b6502` (hierarquia e estados dos painéis) e `5703972` (dados
  de decisão contextuais). O fechamento adicionou apenas documentação.
- Os quatro painéis receberam cabeçalhos e hierarquia visual consistentes.
  Na cobrança, a tarja mostra quanto falta ou quanto sobrará. Na
  contra-oferta, os três botões têm duas linhas e mostram custo/certeza ou
  chance calculada por `GameState._chance_com_reputacao()`.
- A pesquisa com Mini Metro, Against the Storm e Port Royale 4, incluindo
  documentação oficial, crítica e comunidade, e o que foi ou não adotado,
  está em `docs/design/BR_Port_Referencias_Interface_Gestao.md`.
- A `main` remota estava em `5b698cd4f7410f56848b605ad9d62979e1cb5fb3`
  quando foi conferida em 25/09/2026. A branch de trabalho é local: não houve
  push nem PR, pois a revisão automática bloqueou publicar alterações no
  repositório público sem minha autorização explícita. Não tente contornar
  esse bloqueio. Se trabalhar noutro ambiente e a branch não existir, peça-me
  uma forma autorizada de levar o patch; não presuma que ela esteja no GitHub.

Prioridade de segurança antes da próxima verificação visual: as ferramentas
`brport_vs/tools/capturar_cena.gd` e `capturar_tela.gd` chamam
`GameState.clear_save()`; algumas suítes de teste também o fazem. Nesta rodada,
uma captura no Windows substituiu `user://savegame.json` do perfil desktop por
uma partida nova (turno 1, R$400.000, nomes vazios). Não havia backup prévio
feito nesta sessão, então não presuma que o progresso anterior é recuperável.
Não execute capturas nem essas suítes no perfil normal. Primeiro encontre e
implemente um isolamento verificável do `user://` para testes/capturas, ou
reforme as ferramentas para preservar o save inclusive quando houver falha;
preserve o arquivo que existe agora. Explique o risco e a solução antes de
voltar a gerar evidência visual.

Verificação feita nesta rodada: o `--headless --import --quit` do Godot passou;
`tools/conferir_escopo_ui.py` deu `ESCOPO UI OK`; `git diff --check` estava
limpo. Quatro suítes e o validador de assets passaram antes do segundo commit,
mas não foram repetidos depois dele pelo risco ao save. O teste de fumaça
mostrou dois problemas preexistentes, iguais na `main`. `conferir_docs.py`
terminou com 18 problemas preexistentes, também iguais na `main`. Não trate
essas verificações parciais como aceite visual. As capturas iniciais de
`ribeiro.png` e `contraoferta.png` ficaram fora do repositório, em
`C:\Users\bruno\.codex\visualizations\2026\09\25\01a0d5f3-63a0-7921-815b-c4dec79575c3\interface-referencias-comparacao\`;
se não estiverem acessíveis, peça-as a mim ou gere novas somente após o
isolamento seguro do save.

Depois disso, inspecione a interface em 720×1280 e proponha/aplique uma
próxima iteração pequena e coerente. Verifique texto, contraste, alvos de
toque, estados antes/depois da escolha e correspondência de números com a
lógica real. Não altere economia, progressão ou dados de `# TUNING` apenas
para melhorar a aparência. Mostre-me evidência comparável e peça meu veredito
visual; não marque a frente como aceita por conta própria. Documente testes
executados, limites e qualquer problema herdado. Não publique a branch nem
abra PR no repositório público sem autorização explícita.

---

Nota desta sessão: o procedimento `/fechar-sessao` foi seguido até onde era
seguro. O `git fetch origin main` falhou por rede local, mas a referência da
`main` foi conferida por leitura no GitHub e corresponde ao `origin/main`
local. As suítes e capturas ficaram pendentes pela ameaça concreta ao save.
