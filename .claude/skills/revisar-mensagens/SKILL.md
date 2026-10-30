---
name: revisar-mensagens
description: Revisa as mensagens do BR Port em contexto: voz, naturalidade, vínculo, clareza, repetição e verdade no estado em que aparecem. Produz relatório e sugestões, sem alterar as falas.
---

# Revisor de mensagens do BR Port

Acione quando Bruno pedir «revisar mensagens», «rodar o revisor» ou uma leitura
de tom/encaixe das falas. Funciona com o assistente da conversa, em Claude ou
Codex; não depende de outra API, chave paga ou serviço em segundo plano.

## Preparação

1. Leia `AGENTS.md`, o estado, a §7 do plano e a regra de narrativa. Respeite
   decisões e aceites já dados. O GDD é referência de voz, mas decisões mais
   recentes do Bruno prevalecem. A prioridade atual é vínculo com personagens.
2. Gere o contexto atualizado, sem executar ações do jogador:

   `python3 tools/preparar_revisao_mensagens.py --saida /tmp/brport-revisao`

3. Leia o manifesto JSON e o Markdown de fontes da pasta gerada. O catálogo vai
   inteiro, inclusive os textos locais de `fim_de_fase()`; os demais arquivos
   trazem funções relacionadas ou contexto integral explicitado no manifesto.
   Não considere todos os rótulos do jogo cobertos por isso.
4. Confira o SHA-256 das fontes contra a árvore atual antes de citar linhas;
   se mudou alguma, regenere. O commit sozinho não identifica texto sem commit.
   Se uma evidência exigir outro arquivo, abra-o e registre-o no relatório.

## Como revisar

Faça uma leitura editorial de verdade. O script prepara fontes; comprimento,
palavras-chave ou uma nota numérica não decidem se uma fala é agradável.

Para cada cena ou família de mensagens, registre:

- **Voz e naturalidade:** quem diria isso? A frase parece uma pessoa falando
  ou uma explicação do sistema? Regionalismo sem caricatura. Não uniformize
  Toninho, Cida, Ribeiro e Arlindo numa voz simpática genérica.
- **Vínculo:** há gesto, hábito, cuidado ou tensão que aproxima quem joga?
  Nem toda cena precisa falar do avô. Preserve o humor e as falas que funcionam.
- **Verdade:** siga a chamada real e a condição. Pergunte se a afirmação vale
  na primeira semana, com parcela antecipada, sem dinheiro, obra pronta/por
  fazer, leitura fora de ordem e retomada. Não invente resultados de simulação.
- **Promessa de jogo:** não oferecer benefício, cobrança recorrente, escolha
  ou interação que o código não implementa. Separe uma sugestão de assinatura
  na ficção de uma cobrança que de fato ocorreu no jogo.
- **Ritmo e repetição:** leia a cena completa, aberturas e despedidas; observe
  frases repetidas e frequência do gatilho. Texto em código não prova que o
  jogador o viu, nem que foi tapado. Sem medição, diga «frequência não medida».
- **Leitura:** avalie clareza e concisão; encaixe, retrato e corte só podem ser
  concluídos após captura real em Padrão/Maior. Sem captura, marque pendente.

Uma fala do rival pode ser desagradável e cumprir bem sua função. Procure
clareza e intenção; não retire todo conflito nem transforme Cida em cruel
para tornar uma piada mais forte.

## Relatório

Escreva um relatório em português, com data, branch/commit, hashes das fontes
analisadas, escopo explícito e lista do que ficou por ler. Identifique a skill
como método de revisão assistida; não atribua parecer a um segundo bot que
não foi executado. Distingua fonte de produção de proposta em documento.

Abra com os problemas que mais afetam a experiência. Cada apontamento traz:

| Campo | Conteúdo |
|---|---|
| Identidade | Cena/id ou função, arquivo e linha da versão analisada |
| Trecho atual | Citação exata, com contexto suficiente |
| Diagnóstico | Fato conferido no código, risco de interpretação ou opinião editorial |
| Prioridade | Alta, média ou baixa; razão concreta, sem nota global de qualidade |
| Evidência | Gatilho e estado conferidos; o que é desconhecido |
| Sugestão | Redação candidata ou ajuste de percurso; preserve o fato e a voz |
| Situação | Proposta, manter ou já aceito; nunca converter silêncio em aceite |

Inclua também o que **manter**, para não reescrever tudo por obrigação. Registre
individualmente cada cena/família analisada, inclusive as sem apontamentos.
Não anuncie «tudo revisado» por ter lido só algumas cenas. Sugestões não devem
inventar informação, dinheiro, prazo ou novos sistemas de relacionamento.

Confira contraprovas antes de concluir: um exemplo bom não vira problema
porque menciona o avô; crítica de Cida não é automaticamente falta de vínculo;
coerência entre duas frases não prova verdade no jogo.

## Limites de ação

Esta skill entrega parecer e redações candidatas. Alterar a fala exige um
pedido de implementação ou aceite do trecho dentro da tarefa; autorizações
já dadas continuam válidas. Não pedir aceite de novo para chave/almoço aceitos.
Não altera save, preços, gatilhos, arte ou testes para fazer um texto parecer
correto. Relatório editorial não substitui A4, playtest, suíte ou prova visual.

Ao fechar um bloco, aplique `/fechar-sessao`. Se persistir o relatório no
repositório, use `docs/arquivo/` e o índice; o contexto gerado pode ficar em
`/tmp`, sem duplicar todas as falas no Git.
