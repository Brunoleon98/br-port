# BR Port — revisão dos recursos básicos

**15/10/2026.** Pedido do Bruno depois do recorte de cancelamento (`111`):
ver o que pode ter faltado na experiência básica, citando tela inicial e
como salvar. Inspeção do código atual e dos fluxos cobertos pelas suítes.
Não substitui o A7 no telefone nem autoriza implementar outra frente.

## Os dois exemplos já existem

| Recurso | Como o jogador chega | Fonte |
|---|---|---|
| Tela inicial | É a cena principal; oferece Nova partida, Ajustes e, com partida válida, Continuar e Carregar | `brport_vs/project.godot`, `brport_vs/scripts/TelaInicial.gd` |
| Salvar | Automático depois das ações; na pausa, **Salvar e sair** grava novamente e volta ao início | `brport_vs/autoload/GameState.gd`, `brport_vs/scripts/Main.gd`, `brport_vs/scripts/PauseMenu.gd` |
| Carregar e várias partidas | Três espaços; Continuar escolhe o mais recente | `brport_vs/scripts/PainelEspacos.gd`, `GameState.espaco_mais_recente()` |
| Evitar apagar sem querer | Substituir um espaço ocupado pede confirmação | `PainelEspacos._confirmar()` |
| Pausar e voltar | Pausa com Continuar, Ajustes, Salvar e sair; Voltar fecha painéis dispensáveis e abre a pausa no porto | `PauseMenu.gd`, `Main._notification()` |
| Aprender a primeira ação | Toninho ensina atracar e avançar no dia 1 | `TutorialDoToninho.gd`, decisão `101` |
| Ajustar som | Sliders de música e efeitos, acessíveis pelo início e pausa | `PainelAjustes.gd` |
| Entender dinheiro e objetivos | Toques no caixa e na meta; boletim semanal, calendário, mensagens e diário | Painéis do HUD e `Main.gd` |

Portanto, a revisão não pede reconstruir tela inicial ou criar outro sistema
de save. A questão que sobra é tornar o salvamento confiável e compreensível
para quem não conhece o projeto.

## Lacunas encontradas, na ordem sugerida para discutir

### 1. Saber se o salvamento funcionou

`GameState.save_game()` abre o arquivo com `FileAccess.WRITE`; se a abertura
falhar, sai sem avisar e sem devolver resultado. Também não confere erro após
escrever/fechar. `Main._sair_para_inicio()` chama essa função e troca de tela
incondicionalmente. A pessoa pode usar **Salvar e sair** sem receber retorno
de uma falha. Não se provocou falha no arquivo real do Bruno nesta revisão.

**Proposta:** devolver o resultado da gravação e mostrar falha com opção de
tentar novamente antes de sair. Mostrar onde/qual espaço foi salvo e que o
salvamento é automático. Essa confirmação deve refletir a escrita real,
inclusive no Web, e não apenas o toque no botão.

### 2. Distinguir espaço vazio de arquivo ilegível e oferecer recuperação

`resumo_do_espaco()` devolve `{}` tanto para arquivo inexistente quanto para
save recusado. O painel usa isso para escrever **Livre / Nenhum porto
guardado aqui**, e a tela inicial pode ocultar Carregar quando nenhum resumo
for válido. `load_game()` descarta o arquivo recusado; no arranque, a falta
de um save carregável leva a `new_game()`. Não existe cópia anterior ou fluxo
de recuperação nessa leitura/escrita. Uma falha de arquivo pode parecer
ausência de progresso, com risco de substituição sem reconhecer o problema.

**Proposta:** preservar/quarentenar arquivo ilegível, distinguir os estados
na interface e manter uma última cópia válida por espaço. Provar interrupção
de gravação, arquivo truncado e recuperação. Isso não reabre a recusa de
saves abaixo do piso da `098`; a distinção visual e a proteção do arquivo
são uma discussão separada da compatibilidade das regras.

### 3. Levar a partida para outro lugar ou guardar uma cópia

Os três espaços vivem em `user://`. Ajustes oferece **Copiar registro da
partida**, que exporta acontecimentos de playtest; esse texto não é um save
importável. Não há fluxo de exportar/importar progresso ou sincronizar
partidas entre Web, desktop e telefone nos menus inspecionados.

**Proposta:** começar por exportação/importação manual de um espaço, com
validação e confirmação antes de substituir; decidir depois se sincronizar
vale a complexidade. Requer teste de persistência no navegador e no telefone.

### 4. Consultar as instruções depois do primeiro dia

O tutorial é intencionalmente curto e só do dia 1 (`101`); não há entrada
**Como jogar** ou repetição dele nos menus inspecionados. Mensagens e diário
ajudam, mas não explicam como salvar, quais números do HUD são tocáveis ou
onde consultar uma dúvida a meio da partida.

**Proposta:** uma ajuda consultável pela pausa, curta e por assunto, que
aponte para as ações já existentes. Ensinar o salvamento automático e
retomar pelo Continuar resolve diretamente a dúvida citada pelo Bruno.
Não é reescrever o caderno do A4 nem ampliar o tutorial sem aceite.

## O que ainda precisa de gente

Ajustes hoje cobre som e registro; não oferece tamanho de texto. Os alvos
de toque e o contraste já têm guardas, mas conforto de leitura, descobrir
os toques do HUD, teclado móvel e confiança em salvar/retomar precisam do
telefone e de pessoas no A7. A correção de nomes (`107`) permanece separada,
sem publicação e sem confirmação de digitação no aparelho. A4, A6 e A8
continuam nos seus gates; não se fecham com esta inspeção.

A recomendação para uma próxima escolha é **confiabilidade e retorno do
save** (itens 1–2), seguida da ajuda consultável. É proposta de prioridade
para o Bruno, não uma nova fila aplicada ao projeto.
