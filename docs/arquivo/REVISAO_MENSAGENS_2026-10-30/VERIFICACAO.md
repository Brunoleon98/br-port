# Verificação do revisor

30/10/2026; decisão `145`. O preparador é uma ferramenta local da skill;
não é uma régua de aprovação da escrita nem um novo gate do CI.

## Preparador

`python3 tools/testar_preparar_revisao_mensagens.py`: seis casos verdes.
Cobrem preservação de texto local e constante com numeração literal esperada;
função chamadora com sua condição; recusa de fonte obrigatória ausente;
repetibilidade e sensibilidade do hash a edição; conteúdo/modo do arquivo;
e falha injetada em `os.replace` que preserva o destino e remove o temporário.
São exemplos de regressão do gerador de contexto, não testes do gosto das
mensagens ou novos guardas de comportamento do jogo.

`python3 tools/preparar_revisao_mensagens.py --saida /tmp/brport-revisao-mensagens`:
31 fontes, 70 trechos, com o catálogo completo. Hashes SHA-256 das fontes e
do método conferidos contra a árvore; manifesto guardado nesta pasta.
O pacote de fontes fica em `/tmp`, sem repetir o catálogo inteiro no Git.
O relatório declara as 15 unidades efetivamente lidas; não promete cobertura
editorial de todo o pacote.

## Jogo e documentação

Godot 4.6.3 da `.godot-version`, `--headless --fixed-fps 60`, um perfil de
ferramenta por suíte. Importação antes da execução. Logs em
`/tmp/brport-revisor-suites` nesta máquina:

| Suíte | Marcador | Tempo nesta corrida |
|---|---|---|
| run_tests | TODOS OS TESTES PASSARAM | 22 s |
| teste_design | DESIGN OK | 58 s |
| teste_audio | AUDIO OK | 1 s |
| teste_fumaca | FUMACA OK | 21 s |
| teste_registro | REGISTRO OK | 1 s |
| asset_validator | ASSET OK | 20 s |

`SUITES OK`: seis suítes em 58 s. Despejo/tabela: `CONSTANTES OK` e
`TABELA OK`, mesmas 56 constantes, tabela sem diff. O `GameState` desta
sessão mudou somente referências de decisão em comentários. O teste T32
mudou apenas essa referência em comentário. Nenhuma lógica de alvo ou suíte
foi alterada pelo revisor; não se atribui uma nova execução dos 239 mutantes
da base a esta sessão. O pré-PR conferiu o catálogo contra os alvos, sem órfãos.

`DOCS OK`, diff sem erros de espaços e `COLABORACAO OK` contra `origin/main`
em `0a2e16f` conferidos no fecho. As decisões antigas de história e os
briefings foram renumerados preservando os da main. A parte gráfica não foi
editada nesta entrega, além de incorporar a main.

Sem nova imagem, export ou CI remoto desta entrega. As seis suítes respondem
por regressão do jogo, não pela qualidade literária do parecer. Sugestões
continuam por ler/aceitar; o revisor não aplica alterações automaticamente.
