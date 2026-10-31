# Próxima conversa — reputação e vínculo com os personagens

31/10/2026. Branch `codex/revisor-de-mensagens`, main incorporada em
`9c36e97` (#157, reforço de testes), após integrar o gráfico #156. História local é
146, revisor é 145, retorno da revisão é 147; gráfico do barco é 144.

## Entrega

Cida avisa uma vez ao entrar/abrir no patamar baixo de reputação. Recuperar e
cair novamente permite novo aviso. HUD vermelho abaixo de Confiável, com
número/classificação preservados; volta ao âmbar ao recuperar. Integração de
uma linha no Main, aplicada somente depois do merge gráfico, como Bruno pediu.

Elogio de bom contrato: «Esse valeu a conversa. Anota aí.» Cena `mesa` agora
«Mais uma cadeira», aproximando Mané da equipe sem entrega fixa ou conta
mensal. Condições dos capítulos, preços e save não mudaram. Chave/almoço
seguem aceitos e aplicados. Outros trechos e retorno das lojas são propostas
em `docs/REVISAO_FALAS_LOJAS_FASE_1.md`.

A decisão 147 registra gatilhos, falas e espera/integração do HUD. Provas
visuais e limites em `REPUTACAO_E_FALAS_2026-10-30/README.md`: HUD real, aviso
pela fila normal e cena do Mané em Padrão/Maior. Telefone pendente.

## Verificação

Na base com #156, seis suítes aprovadas em 179 s e catálogo completo de
259 mutantes aprovado. A espera no chat foi interrompida, mas o processo
terminou normalmente. Após incorporar #157, as seis suítes passaram em 65 s;
catálogo de 263 em conclusão, atualizar antes do commit.
Sete defeitos novos explorados e detectados pela guarda específica,
incluindo a remoção da linha do HUD. Preparador do revisor inclui o novo
predicado e o consumidor no Main.

Bruno perguntou «Vai abrir um novo PR?» em 31/10. A entrega segue para um
PR em rascunho com a verificação pendente explícita, incluindo os commits
anteriores da história e do revisor. Conferir PR/CI antes de recomendar merge;
não reiniciar a branch a partir da main, que ainda não contém esta entrega.

## Continuação

Bruno prioriza vínculo com os personagens. Próxima leitura possível: envelope,
descrições das compras e retorno das lojas. Essas propostas ainda exigem
leitura/aceite; não aplicar como se já tivessem sido aprovadas.

O revisor é acionado pelo chat, com recomendações oportunas, conforme a skill
`.claude/skills/revisar-mensagens/SKILL.md` e decisão 145. Recomendar nova
rodada agora faz sentido porque mudaram texto e gatilho; ainda não foi feita
uma segunda revisão contextual. A ferramenta preparar fontes não equivale ao
parecer editorial.

## Prompt para colar

```text
Retome /workspace/br-port na branch codex/revisor-de-mensagens.
Leia AGENTS.md, docs/ESTADO_DO_PROJETO.md e as decisões 145, 146 e 147.
O PR gráfico #156 está incorporado. Aviso da Cida, HUD vermelho e falas aceitas foram aplicados localmente.
Confira docs/arquivo/REPUTACAO_E_FALAS_2026-10-30/README.md.
Minha prioridade é vínculo com os personagens. Envelope e retorno das lojas ainda são propostas.
Vamos continuar a revisão contextual; a parte gráfica segue com Claude.
```
