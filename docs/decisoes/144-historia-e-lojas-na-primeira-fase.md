# 144 — A história e as primeiras lojas da Fase 1

24/10/2026. Bruno pediu avançar a história da primeira fase enquanto o Claude
trabalha na parte gráfica e implementar lojas. Confirmou que elas devem ter
visitas/conversas e compras; escolheu **Mercado e Delivery primeiro, ligados à
história**. Autorizou explicitamente o save **18→19 com migração que preserve
o progresso**. Recorte em `docs/RECORTE_HISTORIA_LOJAS_FASE_1.md`.

## História jogável

Seis cenas acompanham as semanas: a caneca do Seu Maneco, a chave do galpão,
o primeiro recibo, o envelope do Grupo Atlântico, a mesa da esquina e a
aproximação interessada do Arlindo. Textos em `Narrativa.gd`, condições em
`VidaDoPorto.gd`; nenhuma fala fica somente escrita, sem uma porta no jogo.

As cenas exigem tempo e progresso reais. A parcela antecipada não encerra o
mês; o envelope exige o armazém pronto. A pista vem do segredo do avô no GDD;
o empréstimo atual para reconstruir não é reescrito como dívida herdada.

O boletim semanal oferece ler o próximo capítulo. A escolha abre uma conversa
por cima dele, sem adicionar estados de turno nem empilhar telas sozinhas.
O app Lojas também abre o arquivo para ler depois ou reler. Uma cena só é
marcada como concluída no fim; «Ler depois» conserva a pendência. A primeira
página e o fechamento da fase continuam disponíveis nos lugares de sempre.

## Mercado e Delivery

O Mercado da Praça tem uma visita com Seu Biu. O Delivery do Mané tem uma
conversa própria. Sem retratos novos nesta entrega; as cenas do arco usam os
rostos existentes de Toninho, Cida e Arlindo. Visitas locais podem ser repetidas;
as cenas do arco também entram no histórico da sessão do celular.

Primeiro catálogo: kit de café por R$180 e almoço para a equipe por R$240,
cada um comprado uma única vez. Liberam respectivamente «Café no cais» e
«A mesa do cais». São compras narrativas: o catálogo explica o efeito antes
da confirmação, sem prometer bônus de operação, status ou estresse. Não há
gasto automático nem requisito novo de fase. Carros, imóveis, outras lojas e
um catálogo de efeitos operacionais ficam para recortes posteriores.

A confirmação mostra preço e saldo restante. A lógica recusa repetição,
produto desconhecido, dinheiro insuficiente e decisão pendente. Saldo, direito
ao item e despesa são alterados juntos antes dos sinais. A despesa aparece no
dia, projeção e semana, sem sair novamente ao avançar. Os preços são escolhas
ficcionais deste catálogo, não cotações de mercado.

## Save e colaboração

A versão 19 guarda `vida_do_porto` com compras e cenas lidas, mais a rubrica
`lojas` nas contas. A 18 recebe os campos vazios por degrau; saldo, nomes,
docas, obras e fase continuam. Exemplos 14–18 intactos; a 19 é gravada jogando,
com compras e leituras reais. Estado truncado, ids desconhecidos, duplicatas
ou capítulo impossível são recusados antes de aplicar campos.

Sem mapa, props, projeção ou enquadramento nesta entrega. Abertura do app e
convite do boletim são a integração pequena no `Main`; os arquivos novos
concentram catálogo e telas. Na consulta inicial, não havia PR aberto do outro
agente. O número livre 140 foi conferido contra `origin/main` atualizado.

## Verificação

O T32 entra pelo celular, visita as duas lojas e usa os botões de compra,
cancelamento e conversa; confere débito, retomada, isolamento de espaços e
condições das cenas. Nove defeitos novos no catálogo provam cobrança, direito,
migração, conclusão de leitura, gatilhos e confirmação. O percurso de contraste
inclui catálogo, lojas, falta de dinheiro, confirmação e conversas.

Medição, fotos, resultados das suítes e limites estão em
`docs/arquivo/VERIFICACAO_HISTORIA_LOJAS_2026-10-24/README.md`.
O aceite da escrita e o teste no telefone continuam com Bruno.

## Revisão de 25/10

Bruno priorizou mais vínculo com os personagens e aceitou a leitura final da
chave e do almoço («Ficou bom»). As duas versões foram integradas: Toninho
oferece ajuda ao entregar a chave e reserva um lugar para a chefia no almoço,
com a brincadeira do prato da Cida. O restante de
`docs/REVISAO_FALAS_LOJAS_FASE_1.md`, incluindo o retorno das lojas, continua
proposta. Não se alteraram gatilhos, preços, save ou arte.

A decisão, criada como 140 quando o número estava livre, foi renumerada para
141 com `tools/renumerar_decisao.py`: o mobiliário da rua chegou à main como
140 no PR #152. A branch incorporou `origin/main` em `3de1526`, preservando a
frente gráfica e os dois registros. Provas desta revisão em
`docs/arquivo/VERIFICACAO_FALAS_2026-10-25/README.md`.
