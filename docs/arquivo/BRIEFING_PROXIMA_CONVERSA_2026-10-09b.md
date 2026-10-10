# Próxima conversa — 09/10/2026 (b)

Recorte `087`: obras dos três reparos da Fase 1, branch
`codex/frente-5-obras-reparos`, a partir da main `f5f88b5`. PRs #108 e #109
confirmados como fundidos antes de começar; nenhum PR aberto em conflito.
Bruno escolheu obras e aprovou prazos, funcionamento e Save 14 com “sim”.
Estado, decisão, medição, plano e este briefing entram no mesmo commit.

## Prompt inteiro para colar

```text
Você é o Codex no repositório Brunoleon98/br-port.

Leia AGENTS.md, o CLAUDE.md inteiro, docs/ESTADO_DO_PROJETO.md, a §7 do plano
v3, as decisões 085, 086 e 087 e o guia BR_Port_Metodo_Balanceamento_Economia.md.
Atualize a main pelo GitHub e confira PRs abertos antes de editar, preservando
o trabalho local. A 085 foi fundida no PR #108 e a 086 no #109; confira.
A 087 está na branch codex/frente-5-obras-reparos; confira seu PR e seu merge
antes de começar outro recorte. Trabalhe em nova branch codex/<tema> da main
atualizada, com um recorte por PR. A próxima decisão era 088; confira novamente
antes de usar.

Bruno escolheu obras dos reparos da Fase 1 e aprovou a proposta completa com
“sim”: píer 2 em dois dias, armazém em dois, pátio em três; uma obra por vez,
sem retirar trabalhadores dos píeres, custo pago ao iniciar e capacidade/renda
só ao concluir. A obra guarda id, início e conclusão. São dias jogados; nada
avança com o aplicativo fechado. Dia 1 + dois dias fica pronto no dia 3.
Serviços e fechamento semanal usam o porto antigo; depois a conclusão libera
benefícios para o novo dia, inclusive no vencimento. Decisões, pagamento da
parcela e carregamento não passam dias. Obra que excederia o fechamento do dia
84 é recusada sem cobrar. Cancelamento/reembolso não fazem parte da 087.
HUD e Construir mostram andamento; a Dona Cida reage ao concluir. Preserve a arte.

Save 14 autorizado explicitamente nessa proposta: retoma a obra sem cobrar
de novo; partida nova limpa-a. Saves 13 e anteriores são recusados antes de
aplicar qualquer campo, sem migração. Consulta preserva o arquivo; carregamento
descarta o incompatível. Partidas antigas precisam recomeçar. T14 retoma as
três cobranças reais; T15 cobre dias, pagamento único, efeitos adiados,
retomada, fecho semanal/vencimento e compara todo o estado persistido antes
e depois da recusa, inclusive obra. Não reaproveite a autorização do Save 14
para outra mudança de versão: AGENTS.md exige pedido explícito.

A captura do balanço encontrou oferta do Arlindo sorteada ao pagar por cima
da resposta do Ribeiro. T16 cobre resposta → boletim → oferta nesse caminho;
a oferta habitual mantém prioridade sobre boletim comum. Preserve a regra
restrita em Main.gd e a explicação na decisão 087/CLAUDE.md.

Mantenha a 085: 12 semanas de 7 dias, cobranças 28/56/84, crédito inicial
R$400 mil e três parcelas iguais de R$140 mil, R$20 mil de juros totais.
Antecipar abate só juros da janela. R$530 mil na primeira foi substituído
por Bruno e não é requisito. Píer 2 abre no início, armazém no dia 8, pátio
no dia 29 após a primeira cobrança paga. Até dois píeres. Preços intactos
na 086 e na 087, valores/prazos na tabela gerada e taxas/medição no CLAUDE.md.
O pátio concluído dobra a renda dos píeres; só o adicional de contêiner
aguarda clientes futuros.

Mantenha a 086: aparelho aprovado de madeira durante toda a Fase 1;
intermediário reservado à Fase 2. Reparos não promovem o guindaste. A base
da máquina é parte do PNG do píer: preserve o conjunto n1 aprovado com
madeira e a capacidade dos dois píeres. Bancadas futuras usam metadado
efêmero restrito a --script, limpo em partida nova e carregamento válido,
sem entrar no save. Recusa não limpa a bancada nem altera o estado vivo.

As medições da 087 estão em
docs/arquivo/MEDICOES_OBRAS_FASE_1_2026-10-09.json: 600 partidas por perfil,
semente 20260825, antes/depois das três cobranças reais, P10/P50/P90 com n,
desbloqueios e dias de pagamento/conclusão. Paridade exata de dez partidas
por perfil com/sem autosave, incluindo obras. A base refeita é idêntica à
medição final da 086 em
docs/arquivo/MEDICOES_GUINDASTES_FASE_1_2026-10-08.json. Não use propostas
descartadas do arquivo da 085 nem o projetor das Fases 2/3 para validar a Fase 1.

Escolha com Bruno o próximo recorte testável da frente 5, lendo o GDD antes
de definir duração e progressão. Crédito opcional, cancelamento de trabalho,
guindastes/progressão e obras das fases futuras, tutorial e mais trabalhadores
por píer seguem pendentes. Carros e imóveis são futuros; não fixe preços
nem implemente-os nesta frente sem novo escopo. Um recorte por PR.

⚠️ Economia — `CLAUDE.md` e `docs/design/BR_Port_Metodo_Balanceamento_Economia.md`: crédito
não é lucro, patrimônio não é caixa e receita do porto não é dinheiro pessoal.
Tarifas por tonelada/metro/hora não certificam contratos sem essas quantidades;
preços atuais são ficcionais.
⚠️ Medição — decisões 085/086/087 e /balancear: medir cada uma das três
cobranças reais, com desbloqueios, P10/P50/P90 e tamanho da amostra; obras
separam pagamento e conclusão. O projetor das Fases 2/3 não valida a Fase 1.
⚠️ Jogador — `CLAUDE.md`: proteja arquivos do jogador, use perfil isolado e
sentinela; nunca rode capturas junto das suítes. No Windows confira o tamanho
720×1280 do PNG e o conteúdo LF de Narrativa.gd, pois CRLF impede a virada
das duas páginas.
⚠️ Fecho — /fechar-sessao: execute as verificações exigidas, atualize os
documentos e o briefing no mesmo commit; publique a branch e abra o PR.
Inclua o prompt inteiro da próxima conversa em bloco copiável na resposta final.
```
