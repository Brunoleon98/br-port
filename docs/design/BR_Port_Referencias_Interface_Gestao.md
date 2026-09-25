# Interface de gestão — referências, tradução e lições (25/09/2026)

Pesquisa para a segunda passagem da primeira família da frente 3 do A5:
boletim, contra-oferta, cobrança e balanço. Os exemplos são **referências de
decisão e leitura**, não moldes gráficos a copiar. Uma crítica ou comentário
de jogador é evidência daquele uso, não prova de consenso.

| Fonte | O que se observou | Tradução para o BR Port |
|---|---|---|
| [Mini Metro — apresentação do designer na GDC](https://www.gamedeveloper.com/design/video-behind-the-minimalistic-visual-design-of-i-mini-metro-i-) | O designer começa por perguntar de que trata o jogo; a interface reduzida precisa transmitir a informação que move a decisão. | Manter o cartão como carta de personagem, sem transformá-lo num painel de gráficos. Separar ação e consequência em linhas que caibam no telefone. |
| [Against the Storm — comentário de jogador na Steam](https://steamcommunity.com/app/1336490/discussions/2/3487502140237787226/) | Um jogador elogia informação acessível com poucos cliques e pouco ruído; o desenvolvedor responde que sugestões da comunidade inspiraram recursos de UX. | Mostrar a quantia que falta ou sobrará na própria cobrança, sem pedir ao jogador que subtraia o caixa do valor da parcela. |
| [Against the Storm — atualização 1.7 do estúdio](https://eremitegames.com/quality-of-life-update-1-7/) | Estatísticas foram colocadas tanto durante a partida quanto no resultado, com contexto para números de produção. | Preservar as métricas reais do balanço e os preços/chances na decisão; não inventar indicadores só para preencher espaço. |
| [Against the Storm — discussão de recursos na Steam](https://steamcommunity.com/app/1336490/discussions/0/3728449612307599623/) | Jogadores divergem sobre o HUD permanente, mas concordam que precisar abrir outras telas repetidamente para conferir recursos é incômodo; um deles nota que o número junto do evento já ajuda. | Dado contextual no painel da escolha, não mais uma pílula fixa no HUD. |
| [Port Royale 4 — crítica da Prima Games](https://primagames.com/featured/port-royale-4-review) | O crítico aponta que oferta/rota e insuficiência de recursos ficam em painéis separados, exigindo memória e idas e vindas. | Nunca esconder disponibilidade ou efeito de um botão num painel distante. |
| [Port Royale 4 — avaliações de jogadores na Steam](https://steamcommunity.com/app/1024650/reviews/?browsefilter=toprated&l=english) | Há tanto elogio às janelas maiores e legíveis quanto crítica à quantidade de abre-e-fecha. Não é um veredito único. | Ampliar o alvo de toque da contra-oferta e organizar as três opções em duas linhas, sem acrescentar outra etapa. |

## O que entrou nesta passagem

1. **Cobrança:** a tarja informa `Faltam R$… para pagar` quando não há caixa ou
   `Depois de pagar: R$…` quando há. O valor devido continua na fala e no
   botão. Depois da escolha, a tarja muda para `Parcela quitada` ou `Parcela
   não paga`. É informação de decisão, não um número repetido.
2. **Contra-oferta:** três botões com alvo de 58 px, ação na primeira linha e
   preço/certeza ou chance na segunda. A chance impressa chama
   `GameState._chance_com_reputacao()`, a mesma conta do sorteio; antes
   mostrava a constante de base mesmo quando a reputação mudava a probabilidade.
3. **Sem nova janela:** o mapa, os retratos, as falas, a economia, as escolhas
   e o tema anterior continuam. A referência foi traduzida para o espaço de
   420 px do cartão, não copiada como HUD de jogo de PC.

## O que não entrou — e por quê

- Gráfico no boletim: o GDD define uma carta da Dona Cida, não um dashboard.
- Barra permanente de recursos: o Vertical Slice tem poucos recursos e o
  número importante já cabe no cartão onde se decide.
- Cor de botão para dizer `seguro`/`aposta`: o texto diz isso sem depender só
  de cor; pintar uma opção como a `correta` enviesaria a escolha.
- Estatísticas ou sistemas de outros jogos sem equivalente no BR Port.

## Terceira passagem (25/09) — a consequência antes da escolha

A referência que decidiu esta passagem é a mesma da crítica de *Port Royale 4*
acima — **não esconder o efeito de um botão** —, agora aplicada ao efeito de
FALHAR: a contra-oferta não dizia que uma aposta recusada encarece o igualar
de −15% para −28%, nem que a recusa na última rodada entrega o barco ao Porto
Farol. O que entrou, com o porquê e as medições, está em
`docs/decisoes/062-a-promessa-do-painel.md`:

1. **Contra-oferta:** a linha do cliente diz o que acontece se ele recusar; os
   botões alinham à esquerda com a segunda linha paralela (valor · certeza ou
   chance); no fim, «Fechado por R$…».
2. **Cobrança:** a tarja leva por baixo as duas parcelas da conta («Você tem
   R$… · a parcela é R$…»), e depois da escolha o dinheiro que ficou ou o que
   faltou. A linha cinzenta solta saiu.
3. **Boletim:** a comparação com a semana anterior entra na tarja do
   resultado, como linha de apoio.
4. **Balanço:** «Disputas com o rival: N ganhas · M perdidas» no lugar de
   «Ofertas do rival igualadas», que contava também as apostas ganhas.

Procurou-se uma segunda fonte para «mostrar a consequência antes da ação» — o
postmortem de design de *Into the Breach* na GDC 2019 — e o proxy desta sessão
bloqueou as três páginas; **não entra como evidência**. Continua de fora o que
a segunda passagem rejeitou: cor para «seguro»/«aposta», valor esperado ao
lado das opções (seria dizer ao jogador qual escolher) e indicadores novos.

## Lição operacional desta rodada

**Resolvida pela `docs/decisoes/061`:** toda ferramenta e suíte grava hoje em
`user://ferramentas/`, e o CI prova-o com uma sentinela no lugar do jogador. O
relato abaixo fica como registo do incidente.

`brport_vs/tools/capturar_cena.gd` chama `GameState.clear_save()` e depois
`new_game()`. No desktop, `user://savegame.json` usa a pasta persistente do
projeto; [a documentação do Godot](https://docs.godotengine.org/en/4.6/tutorials/io/data_paths.html)
explica esse caminho. Portanto a ferramenta de captura **não é segura no perfil
de uso normal**: pode substituir uma partida real. Capturas extras foram
interrompidas ao descobrir isso. Antes de voltar a usá-la, isolar o `user://`
de modo verificável ou reformar a ferramenta para preservar o save em saídas
normais e anormais. Uma cópia só em memória não basta se o processo falhar.
Após as capturas desta rodada, o save desktop tinha horário da captura e
registrava uma partida nova (turno 1, R$400.000, nomes vazios). Não havia cópia
prévia feita por esta sessão; não assumir que o progresso anterior é recuperável.

As capturas de entrada feitas antes da descoberta estão fora do repositório,
em `.codex/visualizations`. Os estados com reputação extrema não foram
fotografados; a equivalência da chance é estabelecida pelo uso da mesma função,
não por uma captura desses estados.
