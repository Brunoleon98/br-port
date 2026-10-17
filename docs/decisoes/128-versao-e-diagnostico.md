# 128 — Versão e diagnóstico, primeiro recorte do RB8

**17/10/2026.** Bruno escolheu a opção 1 apresentada pelo Codex: identificar
o build real e permitir copiar um diagnóstico com prévia. Informou que o
Claude está parado. Main conferida: `0ce0421`, nenhum PR aberto; o pré-PR
confirmou 128 livre. Reserva na branch `codex/versao-diagnostico` e em PR
rascunho, antes da implementação.

## O que entra

- Uma consulta compartilhada pelo início e pela pausa. Fechar e Voltar do
  aparelho devolvem à origem; abrir duas vezes não empilha cópias.
- Identificação do jogo pelo commit que produziu o pacote. O CI gera essa
  informação antes do export; uma cópia local sem identificação diz isso,
  e uma árvore modificada não se apresenta como o commit intacto.
- Diagnóstico mínimo: identificação do build, motor, plataforma e método
  de renderização. O texto completo fica à vista antes de copiar.
- Cópia somente pelo botão, com resultado honesto quando a área de
  transferência não estiver disponível. Sem envio automático.

O diagnóstico não consulta partidas, nomes, caminhos locais, identificadores
do aparelho, save nem registro. Não acrescenta gravação ou preferências.
Abrir, copiar e fechar preservam estado, RNG e arquivos do jogador.

## Limites e prova

Este é o recorte de versão e diagnóstico, não a implementação inteira do
RB8: créditos/licenças e inclusão opcional do registro ficam fora desta
entrega. A exportação do registro existente continua nos Ajustes.
Não se cria número de lançamento novo: o commit identifica a versão de
desenvolvimento. A versão 0.1.0 do preset Android não muda.

Casos próprios T28 devem provar as duas portas, o Voltar, a prévia igual
ao texto copiado, a cópia por ação explícita, a indisponibilidade da área
de transferência e a preservação da partida e dos arquivos. O gerador
de identificação precisa ser exercitado contra um repositório de teste,
inclusive árvore modificada. Defeitos representativos permanecem no
catálogo oficial. Captura e contraste cobrem a consulta e seu retorno.

Leitura física no telefone e o aceite visual são do Bruno. Esta decisão
não reabre a ajuda, a retomada, a Fase 2 ou as pendências de salvamento.
