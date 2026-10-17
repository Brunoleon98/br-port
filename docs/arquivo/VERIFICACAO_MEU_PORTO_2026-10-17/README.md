# Meu porto agora — verificação da retomada

Recorte autorizado em 17/10/2026, decisão `125`, PR #140 em rascunho.
Bruno informou que o Claude trabalha no visual. `Main.gd`, `Main.tscn` e
`GameState.gd` não são alterados por esta entrega.

## O que foi construído

Continuar e Carregar abrem a mesma consulta, depois de uma carga válida e
antes de criar o porto. Ir ao porto segue à cena existente; Voltar ao início
e Voltar do aparelho dispensam a consulta. Nova partida conserva a abertura.
Não há atalhos, preferências, recomendações ou histórico novo.

O conteúdo lê as consultas e os dados do jogo: dinheiro por `moeda()`, obra
por `prazo_da_obra()` / `dias_restantes_da_obra()`, serviço pela duração e
progresso contratados e `receita_da_doca()`, cobrança pelas funções da
parcela, meta por `progresso_da_meta()`. A obra ainda não concluída não
conta como infraestrutura. Conquista permanece jogo livre.

A cobrança pendente mostra o dia e a semana fechados, pois o contador
interno já aponta ao seguinte antes da decisão. Recibo antecipado continua
quitado; a parcela seguinte é futura. Sem cobranças na Fase 2.

## Limite da consulta

A carga pedida pelo jogador é uma ação anterior à observação; os testes
comparam a consulta depois dela. A inicial consulta primeiro a validade do
espaço, sem apagar, e usa o resultado booleano de `load_game()`, sem recorrer
ao fallback de partida nova do `usar_espaco()`. Um espaço que ficou inválido
entre a lista e o toque mostra indisponibilidade, sem começar outro porto.
As funções existentes de carregamento e salvamento não foram refeitas.

## Como reproduzir

Godot na versão de `.godot-version` (4.6.3 nesta entrega); importar antes de
testar. As seis suítes e seus marcadores são os de
`.github/workflows/testes.yml`. O T27 vive em
`brport_vs/tests/casos_meu_porto.gd`, chamado pelo `run_tests.gd`, com bandeira
final de execução. Usa partidas semeadas e caixa de bancada para alcançar
as fases; isso não é medição de balanceamento nem playtest humano.

Além dos textos, o T27 confere entrega real do serviço e conclusão real da
obra. Fotografa variáveis do estado, RNG, bytes/mtime dos arquivos e estado
do registro; um destino de save ausente denuncia até regravar o mesmo JSON
no mesmo segundo. Consulta visual é exercida também com registro armado.
As duas portas, o Voltar, entrada real com decisões pendentes e as duas
aberturas de partida nova têm percurso próprio.

Os defeitos persistem no catálogo oficial, ids `retomada-*` da decisão 125:

```sh
python3 tools/conferir_mutantes.py --godot "$G"
tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"
python3 tools/conferir_cobertura_paineis.py /tmp/fotos
```

A bateria inclui capturas próprias por `capturar_meu_porto.gd`: Fase 1,
Fase 2, jogo livre, encerrada e indisponível, com início/fim da leitura.
Ela joga até os estados e abre o painel pela inicial. A régua de contraste
inclui resumo nas duas fases e indisponibilidade; o T27 mede o painel real.

No Windows, Python é chamado com `-X utf8`; o executável usado está em
`C:/Users/bruno/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
O Godot local está em
`C:/Users/bruno/Downloads/Godot_v4.6.3-stable_win64.exe/Godot_v4.6.3-stable_win64_console.exe`.
Logs e wrappers locais ficam em `.evidencias/meu-porto-agora/`, com perfis
isolados por APPDATA/LOCALAPPDATA. A bateria Windows reaplica o tamanho da
janela por wrappers fora do projeto, conforme a regra de captura; isso não
altera o viewport do jogo nem prova tamanho físico no telefone.

## Estado das verificações

Em conclusão: a bateria completa e o catálogo do CI precisam ser lidos no
head final do PR. Resultados e capturas selecionadas serão reunidos aqui
depois de conferidos. A primeira fumaça local reprovou três formas de
concordância nos textos novos; elas foram corrigidas sem relaxar o F9, e a
verificação específica passou. O T27 passou após a correção.

Leitura por pessoa nova, teste físico no telefone, A4 e caderno permanecem
pendentes. A decisão 107 continua separada, sem publicação autorizada.
O `Safe save failed` histórico continua sem causa isolada. A pesquisa e os
pacotes anteriores de ajuda/cancelamento, inclusive `.evidencias/`, ficam
preservados. Não foi feito merge.
