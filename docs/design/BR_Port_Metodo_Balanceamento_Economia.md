# Método de balanceamento da economia do BR Port

**Pesquisa e proposta de trabalho: 08/10/2026.** Pedido do Bruno na frente 5:
manter uma escala monetária que também comporte expansões, carros e imóveis.
As constantes atuais vivem no `GameState.gd`, a tabela é gerada e as taxas
atuais vivem somente no `CLAUDE.md`. Este guia orienta próximas decisões;
não aprova preços, sistemas futuros nem uma tabela de tarifas reais.

## O que as fontes ensinam

Dan Hart apresenta um modelo com todas as entradas e saídas de recursos,
uma unidade monetária comum e perfis de atividade por tempo ou nível. O
processo continua após o lançamento com observação e ajustes. É um estudo
de jogos sociais; aqui aproveitamos a modelagem, sem importar seus objetivos
de monetização. [Balancing Your Game Economy, GDC 2011, slides 24–28](https://media.gdcvault.com/gdconline11/Dan_Hart_VirtualItemsSummit_BalancingYourGame.pdf).

Vili Lehdonvirta compara custos pela possibilidade de ajuste, aceitação do
jogador e efeito entre jogadores pobres e ricos. Mostra custos de posse e
simulação do gasto a partir do comportamento esperado. Uma compra grande
ocasional e uma despesa semanal têm efeitos diferentes. [Economic Balancing
and Improved Monetization Through Clever Sink Design, GDC 2014, slides
2, 10, 20–23](https://media.gdcvault.com/GDC2014/Presentations/Lehdonvirta_Vili_Economic_Balancing_and.pdf).

Pfau e Seif El-Nasr combinam opiniões dos jogadores e dados de partidas na
pesquisa sobre balanceamento de Guild Wars 2. A experiência desejada precisa
orientar a interpretação dos números. O estudo não determina taxas de vitória
ou preços para um jogo de porto. [On Video Game Balancing: Joining Player-
and Data-Driven Analytics, 2023](https://arxiv.org/abs/2308.07576).

**O método abaixo é uma adaptação nossa para o BR Port**, e não uma receita
atribuída a essas fontes. A simulação existente é o instrumento principal;
o playtest humano verifica compreensão, ritmo e prazer das escolhas.

## 1. Definir o que se quer antes do preço

Registrar, na decisão do recorte, o estágio do porto, os desbloqueios reais,
o calendário e o público esperado. A fantasia vigente é aprender e reconstruir
(`005`), com espaço para escolhas, não maximizar a chance de perder o cais.
Uma mudança desse alvo precisa ser escolhida pelo Bruno.

Para cada compra, definir sua função: aumentar produção, economizar despesas,
dar conforto, expressar identidade ou marcar progresso. Um carro pessoal e um
caminhão de operação não recebem o mesmo retorno só porque ambos são veículos.
Não inventar rendimento automático para justificar o preço de um bem pessoal.

## 2. Conservar moeda, tempo e contabilidade

Usar reais nominais e distinguir dia, semana e fase. Um salário semanal de
R$6 mil é R$24 mil em quatro semanas; chamar isso de salário mensal não muda
o desembolso. A escala ×10 por si só preserva proporções e não cria realismo.
Sorteios inteiros e arredondamentos podem mudar uma reescala, portanto medir.

Separar no relatório:

- Receita bruta de contratos e píer.
- Despesa operacional: salários, manutenção e futuros custos de operação.
- Investimento: compra ou reparo de uma estrutura.
- Financiamento: crédito recebido, principal amortizado e encargos.
- Caixa disponível, obrigações futuras e patrimônio.

Crédito aumenta caixa e dívida, não lucro. Comprar um ativo reduz caixa;
patrimônio, caixa e receita são números diferentes. Um porto avaliado em
milhões não torna disponíveis milhões para pagar a parcela amanhã.

O contrato de crédito precisa dizer quanto foi recebido em dinheiro, se houve
refinanciamento de dívida anterior, o principal total, o total nominal das
parcelas e o abatimento por antecipação. Não atribuir a diferença toda a juros
se ela também contém dívida herdada. Não criar esse passivo por conta própria
para fazer uma parcela caber: a origem é decisão de design.
O abatimento de antecipação deve devolver encargos que não correram, com
limite coerente: um contrato comum não pode cobrar menos que o principal só
porque aplicou uma percentagem de desconto sobre a parcela inteira. Se houver
subsídio ou perdão do principal, isso precisa de outra decisão explícita.

## 3. Mapear entradas, saídas e efeitos sobre a renda

| Movimento | Entrada/saída | O que medir |
|---|---|---|
| Contrato de barco | Entrada operacional | Valor, tempo de berço, motivo, desconto, fila |
| Vaga alugada do píer | Entrada operacional recorrente | Vagas, receita semanal e bônus do pátio |
| Salário/manutenção | Saída operacional recorrente | Custo por semana e reserva para operar |
| Estrutura | Saída de investimento | Primeiro dia de compra, prazo de retorno e nova vazão |
| Empréstimo | Entrada de financiamento | Principal, dinheiro liberado, prazos e custo total |
| Parcela | Saída de financiamento | Caixa antes, pagamento, saldo depois e antecipação |
| Futuro carro pessoal | Compra e possíveis custos de posse | Objetivo de tempo, reserva restante, uso ou prestígio |
| Futuro imóvel | Compra e possíveis custos/receitas | Capital necessário, manutenção, aluguel líquido e revenda |

Carros e imóveis nesta tabela são requisitos para um recorte futuro, não
funcionalidades entregues nem preços aprovados. Uma futura revenda devolve
moeda: verificar o ciclo compra–renda–revenda para impedir arbitragem sem risco.

## 4. Escolher âncoras e medir acessibilidade

Uma âncora é uma relação que se quer preservar: semanas de renda líquida para
um reparo, reserva após a parcela ou estágio em que se pode comprar um carro.
Quando um preço de mercado for usado como referência, guardar fonte, data,
região, condições e se é novo/usado. Converter para uma categoria ficcional
sem fingir que uma referência valida todos os bens do catálogo.

Contas úteis para comparar propostas:

```text
margem operacional = receitas operacionais − despesas operacionais
caixa após pagar = caixa antes da decisão − valor efetivamente pago
reserva de operação = despesas recorrentes do horizonte escolhido
caixa livre = caixa − reserva de operação − obrigações próximas reservadas
semanas para comprar ≈ preço / margem líquida poupável por semana
retorno incremental ≈ custo do ativo / aumento de margem causado pelo ativo
```

As duas últimas são aproximações. Retorno só existe se o ativo realmente
muda a renda; margem negativa não dá um prazo finito. Para um armazém que
desbloqueia barcos ou bônus, medir novamente os barcos e a fila em vez de
multiplicar a receita antiga. Usar caixa livre também evita chamar de
«acessível» um carro que consome a reserva da próxima parcela.

## 5. Proteger a progressão futura

Manter uma moeda nominal comum facilita comparar um reparo, um carro e uma
casa. Isso não obriga o jogador a pagar todos pela mesma conta: a separação
entre caixa do porto e dinheiro pessoal é uma decisão pendente. Quando a
vida pessoal entrar, definir retirada/pró-labore, reserva da empresa e
custos pessoais antes de calibrar o catálogo. Não financiar um imóvel com
receita bruta de contratos contada como lucro pessoal.

Preços altos de uma fase futura não corrigem sozinhos uma fase inicial que
acumula caixa ilimitado. Medir também semanas depois da última compra e da
última dívida. Dívida encerrada é uma mudança estrutural de fluxo; projetar
outros custos, objetivos e riscos antes de prometer estabilidade eterna.
Em um jogo com preços fixos, sobra de caixa pode eliminar escolhas sem haver
inflação de preços de mercado. Identificar qual dos dois problemas ocorreu.

## 6. Protocolo de uma sessão de economia

1. Atualizar main, conferir PRs e ler o estado e a decisão financeira atual.
2. Congelar perfis, semente, calendário, desbloqueios e definições das métricas.
3. Medir a base com 600 partidas por perfil e semente 20260825. Rodada curta
   verifica execução; não substitui evidência de balanceamento.
4. Alterar uma família de parâmetros por vez. Separar reescala, calendário,
   novos desbloqueios, preços e mudança de contrato financeiro.
5. Medir cada cobrança real: alcançaram, pagaram, perderam, anteciparam,
   caixa na decisão e saldo depois. Mostrar o tamanho da amostra: sobreviventes
   da terceira cobrança não representam todos os jogadores iniciais.
6. Comparar distribuição de caixa, margem por semana, compras e tempo de
   acesso. A mediana sozinha esconde quem ficou sem capital para reconstruir.
7. Escolher o candidato pela experiência desejada e medir outras sementes
   quando a proposta depende de poucos casos perto do limiar. Guardar a base
   de comparação com a mesma semente para atribuir o efeito.
8. Fazer playtest humano para verificar se o crédito, os bloqueios e o custo
   de oportunidade foram compreendidos. Bots não validam essa compreensão.
9. Salvar JSON bruto, versão do Godot, commit de origem, parâmetros e limitações.
10. Fechar pela skill `/balancear` e pelo ritual `/fechar-sessao`: tabela,
    projetor, suítes, capturas em sequência, sentinela, documentos e PR.

`--sem-save` só acelera a bancada depois da comparação campo a campo com
autosave. O projetor das Fases 2/3 verifica seu modelo; ele não demonstra que
as três cobranças da Fase 1 são pagáveis. Save com nova forma ou interpretação
exige nova versão, recusa antes de aplicar e nenhuma migração (`CLAUDE.md`).

## Ficha para um futuro recorte

```text
Bem ou sistema:
Fase e primeiro dia em que pode aparecer:
Função para o jogador:
Conta que paga (porto/pessoal — se aplicável):
Preço e custos recorrentes:
Referência externa, data e adaptação ficcional (se houver):
Entrada de caixa ou benefício econômico real:
Meta de semanas para adquirir / reserva após comprar:
Efeito sobre contratos, vazão, outras compras e obrigações:
Perfis, sementes e número de partidas:
Distribuição de caixa e primeiro dia de compra:
Hipóteses que ainda exigem implementação ou playtest:
Escolha do Bruno e decisão que a registra:
```

Este guia deve ser usado ao planejar expansões, crédito opcional e bens
pessoais, junto do GDD e da §7 do plano v3. Resultados de uma Fase 1 com dois
píeres não validam a economia de uma cidade ou um mercado de imóveis inteiro.

## Referências de serviços e crédito — consulta de 08/10/2026

Na [tabela oficial de Paranaguá, Portaria 319/2024](https://www.portosdoparana.pr.gov.br/sites/portos/arquivos_restritos/files/documento/2024-12/TABELA%20TARIF%C3%81RIA%202025%20-%20PARANAGU%C3%81.pdf),
a acostagem de longo curso até 48 horas custa R$0,94 por metro/hora, com
mínimo de R$1.183,10. A infraestrutura terrestre custa R$5,82 por tonelada
de carga geral ou R$73,77 por contêiner cheio. O armazém de carga nacional
diversa cobra R$0,31 por tonelada/dia no primeiro período, com mínimo
de R$324. São rubricas distintas, não uma cotação de operação completa.
O [índice oficial](https://www.portosdoparana.pr.gov.br/Operacional/Pagina/Tabela-de-Tarifas-Portuarias)
informa mudança do acesso aquaviário para concessionária em 31/07/2026;
não somamos a antiga Tabela I para fabricar um total atual.

Exemplos nossos, com quantidades hipotéticas: 100 m × 24 h × R$0,94 =
R$2.256 de acostagem; 1.000 t × R$5,82 = R$5.820 de infraestrutura terrestre;
100 contêineres × R$73,77 = R$7.377. Não incluir trabalho, rebocador,
praticagem ou armazenagem nessa conta sem orçamento específico.

**Conclusão para o jogo:** contratos de milhares/dezenas de milhares podem
representar um lote agregado, mas a tabela não certifica nossas faixas.
BR Port não define toneladas, contêineres, comprimento ou horas de cada
contrato; seus turnos medem trabalho e não são toneladas. Para validar preço
unitário, acrescentar esses metadados num recorte próprio e comparar rubricas
equivalentes. O pesqueiro de bote é especialmente incerto: não usar tarifa
de navio comercial como prova de preço de desembarque artesanal. Os preços
da `085` são adaptação ficcional medida, não valores reais homologados.

O [BNDES explica a composição do crédito para pequenas e médias empresas](https://www.bndes.gov.br/wps/portal/site/home/financiamento/produto/bndes-credito-pequenas-e-medias-empresas):
custo financeiro, remuneração do BNDES e taxa negociada com o agente.
Uma componente isolada não é o custo total. Não importamos uma taxa anunciada
como se fosse oferta ao porto do jogo.

Na `085`, R$400 mil recebidos e três boletos de R$140 mil fecham R$420 mil:
R$20 mil de juros, 5% do capital no total, **não 5% por mês**. A amortização
de parcelas iguais equivale aproximadamente a 2,48% por período de 28 dias.
Juros arredondados de R$9.919 / R$6.693 / R$3.388 somam R$20 mil; o capital
de R$130.081 / R$133.307 / R$136.612 soma R$400 mil. Antecipar devolve apenas
a fração dos juros da janela correspondente aos dias restantes. É um contrato
ficcional simplificado, sem IOF, tarifas ou CET de uma operação real; a taxa
foi escolhida para o ritmo do jogo, não validada como cotação de banco.
