# Próxima conversa — publicação do início/Configurações, 21/10/2026

Bruno pediu explicitamente abrir PR para as mudanças atuais da `132`.
Publicar na branch `codex/inicio-configuracoes`, sem merge. Esta entrega
contém quatro entradas, Configurações, contraste de movimento e candidatas
de arte; não integra o fundo v3 em produção nem o tamanho de fonte global.
Entregar resumo curto; prompt completo somente quando Bruno pedir.

Leia AGENTS.md, CLAUDE.md, regras gerais e dos arquivos envolvidos, estado,
§7 do plano, decisão `132` e a verificação de início/Configurações de 20/10.
O briefing de 20/10b registra a composição da v3 e os limites preservados.

Base conferida no início da publicação: main `f70b45c`, 270 refs/125 heads,
nenhum PR aberto. A branch remota ainda não existia. O pré-PR passou contra
essa base; não usar essa consulta como aprovação de integrações futuras.
Reconsultar refs, PRs e CI antes de nova alteração/publicação.

Os commits locais anteriores à publicação eram `9ebe192` (menu/contraste)
e `2faf50e` (v3 fora do pacote). O resguardo fica em
`refs/codex-backup/inicio-configuracoes-local-antes-publicacao-20261021`.
O conector Git Data pode gerar novos SHAs de commit por seus metadados;
árvores e blobs precisam continuar idênticos. Consultar o HEAD real da
branch/PR e o recibo local da publicação, sem confundir os hashes locais.

Acervo da publicação em
`.evidencias/inicio-configuracoes/publicacao-pr-2026-10-21/`.
Preservar também o acervo de 20/10 inteiro, candidatas v1/v2/v3, todas as
refs de backup, demais trabalhos e registros de worktrees. Não prometer
montagem em outra sessão. Não enviar recibos recusados sem a alteração já
registrada; nenhum perfil temporário faz parte desta publicação.

O código permanece o da prova local completa: 130 ids/pares confirmados,
bases verdes, seis arquivos de sentinela intactos e 1.645 arquivos selados
idênticos. Há 109 fotos de produção; a v3 recebeu foto separada e continua
em `art_lab/tela_inicial/v3/`. O jogo ainda mostra o degradê. Não afirmar
que a v3 ou a opção global de texto já foram implementadas no jogo.

Reconsultar o CI do HEAD remoto final e sua junção efetivamente testada.
O verde da main/#145 e as provas locais não substituem esse CI. Sem
recomendação de merge antes do resultado final aprovado. Nenhum merge
pelo Codex. A identidade exportada deve corresponder à junção testada.

Texto global, tamanho/acomodação e telefone permanecem pendentes. Se houver
integração futura da v3, preservar `TelaInicial.FUNDO`, consumido pelo
celular, e usar recurso separado na inicial. Preservar título/cartão.
Texto e movimento terão de coexistir no disco; não ampliar silenciosamente
o setter atual de movimento, que cria ConfigFile novo e grava só sua chave.

Claude segue no visual. Não editar MataNoMapa, seus testes, arte ou geradores
em paralelo; não reabrir aceites 114–116 ou resetar branches antigas de
movimento/diagnóstico. Sem merge, force ou push para main/Claude. Sem
alterações de save/SAVE_VERSION/migração, economia, RNG, duração, dia,
missão, meta, Engine.time_scale, autoload novo ou outra etapa da Fase 2.
Não apagar dados do navegador.

Priorizar o conector GitHub; o shell não alcança o proxy. Não repetir
tentativas sem necessidade nem contornar recusas. Aplicar `/fechar-sessao`
ao encerrar e entregar o resumo, guardando o prompt até Bruno pedir.
