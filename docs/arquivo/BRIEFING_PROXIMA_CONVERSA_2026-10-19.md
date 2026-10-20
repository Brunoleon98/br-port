# Próxima conversa — bancada RB5, 19/10/2026

Bruno escolheu definir o recorte de tamanho de texto ajustável e depois
autorizou executar a bancada (`131`). É a frente atual do Codex.
Não pedir outra escolha geral. Prompt apenas no fim real da conversa.

## O que existe e o que ainda depende dele

Branch `codex/bancada-texto-ajustavel`, baseada na main remota
`fc052032ea796060eea803d46f413ccdb0b14bf1` (#144, mesclado pelo Bruno).
O Codex não fez merge. Sem publicação ou PR autorizado nesta etapa.
Não reutilizar as branches encerradas de reduzir movimento ou diagnóstico.

Recorte funcional proposto em `docs/RECORTE_TEXTO_AJUSTAVEL_2026-10-19.md`;
razões na `131`; medições, imagens e reprodução em
`docs/arquivo/VERIFICACAO_TEXTO_AJUSTAVEL_2026-10-19/README.md`.
São Padrão/+25%/+50%, nos Ajustes do início/pausa, Glossário e interface
do porto, com um caso de doca longa. Bancada por `--script`, excluída dos
exports: não há opção global nem persistência de tamanho no jogo.

Em +25%, a fila invade a faixa de mensagem em 11 unidades; as docas do caso
longo crescem de 692 para 736. Em +50%, a invasão é 27, o valor da fila sai
54 unidades da janela e a barra das docas longas chega a 797. As fotos
confirmam texto coberto/cortado. Nos Ajustes os controles ficam visíveis;
o último trecho do Glossário é alcançado por rolagem.
Bruno ainda precisa escolher tamanho e acomodação e testar no aparelho.
Não iniciar redesenho do HUD ou a entrega global a partir dessas medidas.

## Provas e ambiente

Foram 18 processos headless e duas baterias gráficas de 18 processos cada,
com semente 42, FPS fixo 60 e janela 720×1280. As duas baterias produziram
21 PNGs idênticos por bytes e pixels, com 18 manifestos e resumo idênticos;
estes também coincidiram com a execução headless. Estado e parâmetros são
iguais entre os três fatores. Estado, RNG, arquivos e registro não mudam
ao ampliar; reaplicar não acumula e retornar a 1 restaura os tamanhos base.

A solicitação gráfica anterior foi interrompida sem execução; após Bruno
pedir continuar, a autorização da plataforma passou. Usou-se Xorg virtual
local, sem escuta TCP, encerrado pelo PID. Não houve rejeição automática.
Permissões e montagem de arquivos precisam ser conferidas na nova sessão;
não presumir que persistem nem contornar recusa.

Calibração da régua em `tests/casos_bancada_texto.gd`, chamada pelo teste de
design com bandeira final. Quatro `texto-bancada-*` no catálogo oficial:
ampliação ignorada, escala acumulada, caixa cega e janela cega. Rótulos
declarados vieram da exploração real; bases verdes antes/depois.
Os 120 anteriores continuam idênticos, inclusive os 17 `movimento-*`.
O job oficial da main levou 58min18s; o teto do job vai de 60 para 90 min
para comportar a expansão, preservando o cálculo dos tetos por suíte.

**Fecho local aprovado:** `MUTANTES OK` para os 124 ids exatos, cada par
suíte/rótulo declarado confirmado nas reprovações reais; bases verdes antes
e depois. As seis suítes têm seus marcadores finais, sem SCRIPT ERROR ou
push_error; as cinco bases finais mais o asset_validator posterior completam
o conjunto. Sentinela dos seis arquivos intacta. Recibos e logs acompanham
o README da verificação. Esse resultado local não substitui o CI de um PR.

## Continuidade e limites preservados

Preservar `.evidencias/` inteira e `refs/codex-backup/`. As evidências novas
ficam em `.evidencias/texto-ajustavel/bancada-2026-10-19/`: capturas, repetição,
logs, relatórios de mutantes, continuidade e comparador HTML independente.
Se esse acervo local não estiver montado, não o dar por recuperado ou apagado.

Main: Testes `39180551837`, Captura `39180551839` e Balanceamento
`39254893265` concluídos/success. O catálogo oficial da main confirmou os
120, com bases verdes e seis arquivos de sentinela intactos. Esse CI não
aprova o novo commit local. Reconsultar refs/PRs/CI e repetir o pré-PR
imediatamente antes de qualquer publicação autorizada; nenhum número futuro
está reservado. Na consulta das 124 heads, o maior número era 130 e não havia
briefing de 19/10; a `131` desta bancada ainda não foi publicada.

Claude permanece no visual. Não editar MataNoMapa, seus testes, arte ou
geradores em paralelo; o RB6 usa a API pública `nos()`/`rajadas()`.
Telefone e aceite visual RB6 pendentes; vegetação tem o aceite da `130`.
Não iniciar estradas ou outra frente. RB2, diagnóstico e Como jogar já estão
implementados. Não reabrir aceites 114–116. A4/caderno/leitura/telefone e
`Safe save failed` sem causa continuam separados.

Não alterar save, SAVE_VERSION, migração, economia, RNG, dia, duração de
serviço, missão, meta ou conteúdo. Sem autoload novo, novos trabalhadores,
crédito voluntário, cancelamento de obras ou outra etapa da Fase 2.
As preferências futuras de texto e movimento precisam coexistir no disco:
o método atual de movimento cria ConfigFile novo e grava só sua chave;
não estender isso silenciosamente. A bancada não escreve nenhuma delas.
