# PR #148 — limite de tempo do job de mutantes

Bruno informou um problema no PR. A consulta ao GitHub mostrou o workflow
Testes `40009772197` cancelado e Captura `40009772213` com sucesso,
ambos no head `5608871ec7945910a09f877b207281fa683e2a2a`.
Os logs oficiais confirmam checkout da junção
`abaae0b6c2720c226cf76f069a0b3a1cce9d923b`, sobre a main `ed2c770`.

## Causa e correção

O job «Defeitos já provados» `120606846893` começou às 19:14 UTC e foi
cancelado às 20:44 UTC, no teto de 90 minutos do workflow. O executor já
havia detectado 155 dos 158 defeitos, cada um com a guarda declarada, sem
FURADO. Faltavam `texto-captura-fila-antiga`,
`texto-botao-horizontal-sem-largura`, `texto-consulta-nasce-sem-leitura`
e as bases do fim. Não houve `MUTANTES OK` nem conferência final da sentinela;
esse resultado remoto permanece incompleto.

Em `.github/workflows/testes.yml`, somente o teto total desse job passa de
90 para 120 minutos, com o motivo medido no comentário. Isso deixa margem
para os casos restantes e as bases finais. Não reduz o catálogo, não salta
guardas, não muda o limite por execução do motor e não altera o jogo.
Os 158 pares e a restauração já provados localmente continuam sendo provas
locais, e não substituem a nova corrida remota.

## O que os outros logs oficiais confirmaram

- Godot headless `120606847004`: os seis marcadores finais das suítes,
  `DOCS OK` e as sentinelas dos seis arquivos do jogador intactas.
- Export `120606846632`: APK e Web concluídos; identificação gerada e
  conferida para a junção `abaae0b6`, além de `COPIA WEB PROVADA`.
  Publicação no Pages foi pulada, como esperado em PR. Os binários não foram
  baixados nem inspecionados nesta consulta.
- Evidência visual `120606846659`: `COBERTURA OK` para junção e base,
  sentinela intacta na captura da junção e artefato anexado. Esta consulta
  confirmou o log e o estado; não substitui inspeção das imagens do artefato.

## Verificação da correção e continuidade

`GUARDAS OK`, `DOCS OK` e o pré-PR verificam esta alteração do workflow.
Os arquivos do jogo e o catálogo seguem nos mesmos bytes das provas locais
e dos jobs concluídos. A nova corrida do head corrigido precisa terminar
com `MUTANTES OK` para os 158 pares, bases finais e sentinela intacta.
Consultar os IDs e o checkout desse head; não reutilizar os resultados de
`5608871` como se pertencessem ao commit posterior.

O fetch normal trouxe uma branch concorrente `ccr-cce8964c-k07qy0`, sem
outro PR aberto nesta consulta. Ela ocupa a decisão `136` e o briefing `23c`.
O pré-PR sinalizou sobreposição anterior em Main e nos documentos de fecho;
esta correção não altera Main, os testes ou o catálogo. Preservar essa
branch e rever as sobreposições se ela for publicada ou mesclada.
Sem merge pelo Codex, force, push para main/Claude ou atualização do Pages.
