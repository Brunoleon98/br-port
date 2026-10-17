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

No código `9d32562`, as seis suítes locais terminaram com os seis marcadores
esperados, saída zero e sem `SCRIPT ERROR` ou `push_error`. T27 e F9 também
passaram isoladamente. Documentos, guardas de CI e escopo de UI passaram.
As sentinelas das suítes e da captura preservaram os cinco arquivos do
jogador byte a byte. `resultados.json` e os logs acompanham este pacote.

O contraste mediu 746 textos em 42 estados: zero reprovações AA, zero
pendências, três isenções existentes. A bateria completa gerou 93 PNGs;
`COBERTURA OK` confirmou os painéis, estados e expressões exigidos. As sete
capturas próprias anexas foram olhadas em 720×1280, incluindo as duas pontas
do resumo longo da Fase 2 e os botões fixos. Isso não é teste físico.

A primeira fumaça local reprovou três formas de concordância nos textos
novos; foram corrigidas com `Narrativa.concordar`, sem relaxar o F9. A
primeira captura de partida encerrada revelou promessas de obra e receita
futuras: o conteúdo foi corrigido e ganhou guarda e mutante. Os registros
anteriores continuam em `.evidencias/meu-porto-agora/rodada-inicial/` e
`antes-correcao-encerrada/`, sem substituir a prova final.

A prova oficial integral é executada pelo job **Defeitos já provados** do
[CI do código 9d32562](https://github.com/Brunoleon98/br-port/actions/runs/39060600574).
No instante de selar estes logs locais, o catálogo ainda executava; Captura,
Godot headless e Export estavam verdes. Este pacote local não afirma
`MUTANTES OK`: o relatório dos 83 defeitos, incluindo os 13 `retomada-*`,
deve ser lido no artefato `brport-mutantes` do CI. A exploração local duplicada
foi interrompida ainda na base, sem defeito aplicado; confirmou-se a fonte
igual ao HEAD. Ela não conta como prova de guarda. O veredito do HEAD final
fica nas verificações e na descrição do [PR #140](https://github.com/Brunoleon98/br-port/pull/140),
que permanece em rascunho. Pages é pulado em PR por projeto.

## Colaboração e limite da entrega

A main conferida permanece `01ba125`, já incorporada à branch. Contra ela,
o pré-PR passou sem traceback (`colaboracao-base.log`). Esse comando foi
executado com lista vazia de outros ramos, portanto seus números livres não
valem como reserva global e ele não dá aceite à junção com o Claude.

O PR #141 (`origin/claude/terreno-vegetacao-m22sp1`, `9178b28`) publicou depois
outra decisão 125 e alterações em cinco arquivos que o #140 já havia mudado:
estado, índice do arquivo, plano, captura e catálogo. A comparação real
`--outros origin/claude/terreno-vegetacao-m22sp1` acusou conflito no catálogo,
nos documentos e na decisão; depois terminou com `TOMLDecodeError` ao ler o
catálogo de uma junção com marcadores de conflito. O log integral
`colaboracao-com-141.log` registra a falha; não há aceite contra esse PR.

Bruno respondeu **“Deixe como está”** à proposta de renumerar e ajustar só
as nossas linhas compartilhadas. Por isso não se refazem esses arquivos nem
se muda a numeração. A colisão fica pendente de decisão posterior, sem merge.
O estado e o índice já alterados antes do #141 são preservados; este fecho e
o prompt ficam no pacote próprio já indexado, em vez de abrir novo briefing
e editar novamente o índice compartilhado. A decisão própria 125 registra
esse limite. Terreno e vegetação do #141 não receberam aceite nesta sessão.

Leitura por pessoa nova, teste físico no telefone, A4 e caderno permanecem
pendentes. A decisão 107 continua separada, sem publicação autorizada.
O `Safe save failed` histórico continua sem causa isolada. A pesquisa e os
pacotes anteriores de ajuda/cancelamento, inclusive `.evidencias/`, ficam
preservados. Não foi feito merge.

## Prompt completo da próxima conversa

```text
Continuando o BR Port no repositório br-port/. Retome “Meu porto agora”, RB2,
na branch codex/meu-porto-agora e no PR #140, que deve continuar em rascunho.
Leia AGENTS.md vigente, CLAUDE.md, .claude/rules/gerais.md,
docs/ESTADO_DO_PROJETO.md, §7 do plano e
docs/arquivo/VERIFICACAO_MEU_PORTO_2026-10-17/README.md. Leia a decisão própria
docs/decisoes/125-meu-porto-agora.md e as regras dos arquivos envolvidos.

Bruno autorizou o resumo antes de entrar no porto: Continuar e Carregar
carregam o espaço válido e mostram fase/dia/semana, caixa, obra, serviços,
cobrança aplicável e meta existente. Ir ao porto segue ao fluxo existente;
Voltar ao início e Voltar do aparelho fecham a consulta. Nova partida segue
direto. Sem atalhos, recomendações, histórico paralelo ou novos objetivos.
A consulta depois da carga preserva estado, RNG, save e registro. Fase 2
sem dívida/prazo; jogo livre sem novo objetivo; recibo quitado continua
quitado; cobrança pendente mostra o dia fechado; partida encerrada não
promete conclusão ou receita futuras.

Código em ConteudoMeuPorto.gd, PainelMeuPorto.gd/tscn, integração pequena na
TelaInicial.gd, T27 em casos_meu_porto.gd e capturar_meu_porto.gd. Não foram
alterados Main.gd, Main.tscn ou GameState.gd. Seis suítes locais, T27/F9,
contraste, cobertura e sentinelas passaram; consulte os logs e o CI do HEAD
atual antes de afirmar resultado do catálogo de defeitos ou da entrega final.
Sete capturas próprias foram olhadas; bateria completa com 93 PNGs.

Main conferida durante a sessão: 01ba125 (merge #139). Atualize remotos,
confira git status/log, commits locais fora da main, PRs e CI atuais. Preserve
trabalho existente. Rode conferir_colaboracao.py com Python -X utf8 no
Windows; não aceite marcador com traceback. Reconheça o código de saída.

O PR visual #141 do Claude, branch claude/terreno-vegetacao-m22sp1, publicou
outra decisão 125 e colide com #140 no catálogo e documentos de fecho. O
pré-PR real contra #141 terminou com TOMLDecodeError após apontar conflitos;
só a comparação separada contra main passou. Bruno respondeu “Deixe como
está” à proposta de renumerar e ajustar nossas linhas compartilhadas.
Não renumere nem altere esses arquivos ou integre #141 sem nova orientação.
Não use o número livre da checagem sem outros ramos como reserva global.
O Claude continua no visual; terreno e vegetação ainda não têm aceite.
Confira sua frente atual com Bruno se não estiver visível. Não edite em
paralelo arquivos alterados por PR dele.

Preserve .evidencias/ inteira, inclusive implementar-como-jogar/ e
publicacao-pr-134.json, pesquisa e pacotes selados de cancelamento e ajuda.
Preserve codex/implementar-cancelamento-servico,
codex/implementar-como-jogar e codex/corrigir-nomes-web. A última guarda a
decisão 107 e o commit local 0a0ab5c, sem autorização de publicação nem teste
de digitação no telefone. Como jogar já está na main; não reabra 114–116.
Leitura por pessoa nova e telefone continuam pendentes, assim como aceite
do A4 e do caderno reescrito. Safe save failed histórico sem causa isolada.

Não acrescente trabalhadores, crédito, cancelamento de obras, funções novas
de salvamento ou outra etapa da Fase 2. Não faça merge. Ao encerrar aplique
/fechar-sessao conforme as mudanças efetivas e entregue novamente o prompt
completo copiável. Avise se ficar perto do limite de contexto.
```
