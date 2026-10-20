# RB5 — tamanho de texto ajustável: recorte e bancada

**19/10/2026 (`131`). Bancada autorizada; percentual e acomodação pendentes.**
Bruno escolheu definir o recorte do RB5 e depois autorizou seguir com o plano
da bancada. O plano compara +25%/+50% antes da entrega funcional completa.
Não há autorização de publicação, merge ou redesenho do HUD por inferência.
As medições e fotos estão em
`docs/arquivo/VERIFICACAO_TEXTO_AJUSTAVEL_2026-10-19/README.md`.

Base consultada: main remota fc052032ea796060eea803d46f413ccdb0b14bf1
(#144 mesclado pelo Bruno). Testes 39180551837 e Captura 39180551839
concluídos/success. O catálogo combinado foi conferido em log oficial:
120 ids, todos os pares suíte/rótulo declarados, bases antes/depois verdes
e sentinela de seis arquivos intacta. Nenhum PR aberto na consulta.
Todas as 268 refs remotas foram consultadas, incluindo 124 heads.

## 1. O que a pessoa ganha

Escolher letras maiores antes de começar ou durante a partida, continuar
lendo todos os textos funcionais e conseguir realizar as mesmas ações.
A escolha vale neste aparelho e é lembrada após reiniciar.
O modo Padrão conserva a apresentação atual.

O primeiro recorte tem **dois modos: Padrão e Maior**. Não inclui fonte
personalizada, escala contínua, zoom do mapa, modo de alto contraste ou
mudanças no texto das falas e das regras.

## 2. Onde e como ajustar

Nos mesmos Ajustes acessíveis pelo início e pela pausa, na seção
Apresentação:
- rótulo “Tamanho do texto”;
- escolha explícita entre “Padrão” e “Maior”, com estado selecionado legível
  e alvos de toque de pelo menos 44 unidades lógicas;
- exemplo curto identificado como exemplo, com uma frase e um valor,
  para enxergar o efeito antes de voltar ao jogo;
- mudança aplicada ao selecionar, sem exigir reiniciar ou carregar a partida.

Os próprios Ajustes acompanham o tamanho escolhido. O controle para voltar
a Padrão e o botão Voltar continuam alcançáveis no modo Maior.
O Voltar do aparelho conserva a origem: Ajustes → pausa ou tela inicial.
Não haverá contagem regressiva, nova confirmação modal ou saída automática.

A escolha não deve reabrir cenas do jogo, refazer a carga ou disparar ações.
Painéis já montados e os criados depois recebem a mesma preferência.
Ao ajustar, manter o assunto aberto, a leitura em posição equivalente e
o conteúdo digitado; não restaurar uma rolagem por pixels antigos se a
nova quebra de linhas deslocou o trecho.

## 3. Cobertura da entrega funcional

A opção se apresenta como tamanho do texto do jogo. Portanto não se dá o
RB5 por implementado ampliando apenas os Ajustes ou a fonte padrão do tema.

| Área | O que precisa acompanhar a escolha |
|---|---|
| Início, pausa, confirmação e escolha de espaços | Rótulos, avisos, botões, resumo de cada espaço e ações completas |
| HUD e operação | Caixa, dia, reputação, docas; cartões das docas e da fila; progresso, requisitos, valores, nomes e instruções |
| Rodapé | Mensagens, pendentes, cobrança/meta, Construir e Avançar dia |
| Consultas | Como jogar/glossário, Meu porto agora, diagnóstico, caixa, calendário, reputação, docas e meta |
| Decisões | Construir, contraproposta, cobrança, cancelamento e confirmações, em todas as suas respostas |
| Leitura e entrada | Diário, mensagens, boletins, nomes, abertura, tutorial e encerramentos de fase |
| Resultado transitório | Ganho monetário e avisos funcionais: continuam legíveis, sem reduzir sua duração |

**Ficam fora da ampliação:** arte do porto, props, retratos, ícones,
logotipo decorativo, tinta de piso e elementos gráficos sem função de texto.
Isso não isenta um rótulo só por ele estar sobre o mapa: o ganho é informação.
Não se alteram viewport, projeção, enquadramento ou geometria do mapa para
fazer caber a interface.

Nomes, valores e textos continuam integrais. Não resolver falta de espaço
apagando conteúdo, trocando valor por reticências, encolhendo silenciosamente
a letra selecionada ou escondendo uma ação.

## 4. Como o espaço deve funcionar

No modo Maior, a interface pode quebrar linhas e redistribuir texto e
controles dentro das suas áreas. Painéis usam altura calculada e, quando
necessário, rolagem vertical com indicação de conteúdo adicional.
Não pode haver rolagem horizontal necessária para ler texto corrente.

Ações para confirmar, cancelar, fechar e retornar continuam acessíveis;
o texto não se desenha fora do cartão ou por cima dos botões. Leitura longa
pode rolar; a navegação deve deixar claro como chegar ao restante.

A hierarquia atual continua: Avançar dia é a ação principal; custos,
progresso, bloqueios e resultados não perdem destaque nem contraste.
Preservar as cores e fontes já escolhidas. Não transformar tudo no mesmo
tamanho nem alterar só o corpo, deixando os controles pequenos.

O HUD merece uma prova específica antes de prometer o modo Maior:
tem uma faixa superior de altura fixa e cartões em três colunas.
A solução precisa manter o mapa atual e todas as ações funcionais.
Se isso não couber no protótipo com o ganho escolhido, registrar a medida
e rever o desenho com Bruno; não reduzir o mapa ou ocultar números por conta
própria. Não há aprovação antecipada de um redesenho do HUD neste documento.

## 5. Quanto aumentar: escolha depois da prova

Os dois modos estão propostos; o multiplicador do Maior ainda não está
medido nem escolhido pelo Bruno. Não anunciar “25% maior”, “150%” ou
conformidade de acessibilidade sem essa prova.

Para a futura bancada, comparar **+25% e +50% como candidatos de medição**,
com arredondamento consistente a partir do tamanho base de cada papel.
Esses percentuais não são valores aprovados para entrega.
A comparação precisa mostrar o jogo e os piores casos, não apenas uma frase
solta nos Ajustes. Se nenhum candidato satisfizer leitura e encaixe, levar
o resultado ao Bruno sem declarar o recorte pronto para implementar inteiro.

O modo Padrão deve reproduzir os tamanhos atuais. Voltas Padrão → Maior →
Padrão → Maior não podem acumular escala.

## 6. Preferência e proteção do RB6

Preferência de apresentação por aparelho, no armazenamento de apresentação,
fora dos três espaços da partida e pelo ArmazemLocal.
Proposta de valor lógico: padrao ou maior, validado estritamente.
Ausência ou valor inválido usa Padrão; ler não cria arquivo.

Falha ao gravar deixa a escolha em vigor na sessão e mostra:
“Não foi possível lembrar a escolha. Ela vale nesta sessão.”
Não dizer que persistiu apenas porque o botão foi acionado.

**Tamanho do texto e Reduzir movimento são independentes.**
Mudar um conserva o outro em memória, no arquivo e após reiniciar,
nos quatro pares possíveis. Usar o mesmo arquivo não permite sobrescrever
a outra escolha.

A fonte atual precisa de ajuste antes de compartilhar novas chaves:
PreferenciasDeApresentacao.definir_reduzir_movimento() cria um ConfigFile
novo e grava somente reduzir_movimento. Acrescentar a chave de texto
sem resolver essa escrita faria uma escolha apagar a outra no disco.
Isto é risco da expansão proposta, não defeito demonstrado do RB6 atual.

Preservar a API pública e o significado do sinal de movimento que os
componentes já escutam; não tratar tamanho de texto como movimento.
Ferramentas comuns continuam na apresentação padrão. Capturas e sondas
aplicam explicitamente a variante que medem.

Sem autoload novo, funções novas de save da partida, migração,
SAVE_VERSION, leitura de dados adicionais do jogador ou envio de dados.
Não modificar economia, RNG, dia, duração de serviço, missão ou meta.

## 7. O que foi conferido no código

Na definição, 28 fontes/regras foram conferidas por SHA de blob contra a
main fc05203, sem usar a ref local antiga como base. Antes da bancada, a
main foi sincronizada por objetos conferidos por SHA e criou-se a branch
nova `codex/bancada-texto-ajustavel`, a partir dela.

| Fonte | Fato observado | Consequência para a proposta |
|---|---|---|
| PainelAjustes.gd | Uma tela serve início/pausa; a preferência de movimento já fica em Apresentação | Acrescentar o ajuste na mesma porta, conservando retorno e acesso |
| tema_brport.tres | Papéis têm tamanhos próprios, inclusive caderno e celular | Preservar a hierarquia e calcular o Maior por papel |
| Main.tscn, DocaCartao.tscn | Vários tamanhos estão definidos nas cenas; o HUD tem áreas fixas | Aumentar só default_font_size não cobre a interface nem prova encaixe |
| PainelNarrativo.gd | Há cartão ajustado ao conteúdo e cálculo de altura com espaçamento | Medir de novo a altura com a fonte efetiva; mudança de tamanho precisa reorganizar conteúdo |
| PainelComoJogar.gd | Leitura rolável, assunto/foco/posição restaurados após o layout | Conservar a leitura ao mudar tamanho; não depender dos pixels antigos |
| PainelMeuPorto.gd | Resumo rolável e botões fora da leitura | Preservar as duas ações e todos os estados do resumo |
| PainelCelular.gd | O aparelho tem proporção escolhida, área recortada e conteúdo interno | Reorganizar a leitura dentro dele; não aumentar toda a arte do telefone |
| PreferenciasDeApresentacao.gd | ConfigFile novo grava só movimento; ferramentas começam no padrão | Provar convivência das duas preferências e isolamento |

A tabela registra leitura de fonte. A bancada posterior produziu medições
e capturas reais: +25% já sobrepõe a fila à mensagem; +50% também corta
conteúdo à direita. A prova e seus limites estão no README citado acima.
Não houve teste de interação ou aceite no telefone.

## 8. Provas exigidas da implementação futura

1. **Persistência e independência:** processos distintos de ferramenta e de
   aplicação sem --script; todos os pares texto/movimento, alteração em
   qualquer ordem, ausência, valor inválido, falha de escrita e reinício.
2. **Aplicação real:** mudar no início e na pausa, leitura imediata nos
   Ajustes, interface já aberta e elementos posteriores; voltar a Padrão
   restaura os tamanhos base sem acumular escala.
3. **Navegação e estado:** retorno, Voltar do aparelho, assunto e leitura,
   campos digitados, callbacks de folhas e decisões; snapshot de partida,
   RNG, bytes/mtime dos arquivos protegidos e registro. Só a preferência
   pode mudar por causa do ajuste.
4. **Piores casos reais:** valores e nomes compridos, situações de cobrança,
   obra, serviço, Fase 2 e jogo livre; colunas e maior rótulo obtidos da UI,
   não de uma frase mais curta inventada no teste. Incluir SHA completo e
   marca de modificado no diagnóstico e nomes sem espaços no caderno.
5. **Leiaute e contraste:** glyphs/texto dentro da área, ações e toque mínimo,
   conteúdo inteiro alcançável, contraste e hierarquia preservados. Janela
   720×1280 e alturas lógicas já exercitadas nas suítes; conforto físico
   continua sendo prova no telefone.
6. **Capturas controladas:** Padrão/Maior no mesmo estado e parâmetros,
   duas entradas dos Ajustes, HUD, cartões, leitura longa e decisões.
   Caso explícito com movimento reduzido ligado, sem herdar preferências
   deixadas por outra ferramenta. Inspecionar fotos; CI verde não é aceite.
7. **Guardas que viram catálogo:** arquivo próprio para o bloco novo e
   bandeira final; defeitos reais para escala ignorada em cenas, corte de
   texto, ação fora de alcance, aplicação tardia, reset acumulado e uma
   preferência apagando a outra. Reprovar pela guarda declarada, não por
   erro de compilação. Não reservar número de teste ou decisão agora.
8. **Regressão:** seis suítes com seus marcadores, sentinela dos seis
   arquivos, catálogo da main e desta bancada preservado, com alvos atualizados
   quando necessário e os novos defeitos acrescentados; catálogo integrado completo, não
   apenas os casos novos. Padrão mantém a referência visual atual.

## 9. Ordem de execução e autorização

Bruno autorizou a bancada abaixo. Ela permanece separada da implementação
funcional completa; o aumento sozinho não acomodou a interface atual.

Primeiro, uma bancada pequena e reversível para escolher o Maior: os Ajustes,
um artigo longo, o HUD e o cartão de doca mais apertado, com +25%/+50% como
candidatos. Medir corte/ações e apresentar no telefone.
Isso evita escolher um multiplicador em todos os painéis antes de saber
se ele resolve a leitura. A bancada não é uma opção global pronta.

Depois do tamanho e da acomodação aceitos, estender à cobertura da §3,
integrar persistência com o RB6 e executar as provas da §8.
A entrega funcional do RB5 só fecha quando a cobertura estiver completa.
Não prometer uma sessão para toda a implementação: ela toca os andaimes,
cenas fixas, caderno/celular e provas de persistência.

Antes de qualquer alteração rastreada: conferir novamente main, todos os
ramos/PRs/CI e arquivos de conflito; partir da main remota atual em branch
codex/ nova, publicar apenas quando autorizado e repetir o pré-PR imediatamente
antes da publicação. Não reutilizar branches encerradas.
Não reservar número de decisão ou nome de briefing futuro.

Claude continua na frente visual. Não editar MataNoMapa, seus testes,
arte ou geradores em paralelo. Se o Claude passar a tocar Main/tema/andaime,
ajustar a divisão antes de editar esses arquivos.

## 10. Fora deste recorte e pendências preservadas

Não ampliar para RB3/RB4/RB7, novas funções de save, trabalhadores,
crédito voluntário, cancelamento de obras ou etapa da Fase 2.
Não reimplementar RB2, diagnóstico ou Como jogar.
A confiabilidade do save e o Safe save failed histórico continuam separados.
Não reabrir conteúdo ou aceites de A4/Como jogar, nem apagar dados de navegador.
Não confundir esta proposta com aceite visual do RB6; telefone e aceite
do RB6 continuam pendentes. A vegetação tem o aceite próprio da decisão 130.

## Revisão que cabe ao Bruno

A proposta a revisar é: **dois modos Padrão/Maior, nos Ajustes do início e
pausa, preferência por aparelho independente do RB6 e cobertura funcional
da interface inteira; escolher a ampliação em uma bancada antes da
implementação completa, preservando o mapa e as ações.**

A bancada foi autorizada e executada. Continuam pendentes a escolha do
percentual e o aceite da acomodação; a implementação funcional completa
precisa ser autorizada a partir dessa prova. Telefone, leitura e interação
não recebem aceite pelas medições do contêiner.
