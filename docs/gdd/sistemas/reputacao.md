<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# ⭐ Sistema de Reputação

Três eixos independentes — Comercial, Comunitária e Imprensa. Cada um na escala 0–100, com leitura qualitativa para o jogador.

## ⭐ Como a reputação funciona

**Três eixos independentes** — O jogador vê três medidores: Comercial (afeta contratos e clientes), Comunitária (afeta cidade e finais), Imprensa (afeta cobertura da Bela). Eles não somam — conversam.

**Escala 0–100 em cada eixo** — O número existe para cálculos. O jogador lê como faixa qualitativa: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. A mudança de faixa é anunciada por linha de diálogo do NPC relevante.

**Reputação define quem te procura** — Clientes premium aparecem em Comercial 80+. Vaquinha desbloqueada em Comunitária 70+. Bela compartilha pistas de investigação em Imprensa 80+.

## ⚓ Eixo Comercial — clientes e contratos

**0–30 — Cais marginal** — Só contratos de baixo valor. Arlindo intercepta os bons. Sr. Ribeiro recusa renegociar dívida abaixo de 25.

**31–60 — Porto funcional** — Contratos regulares disponíveis. Clientes locais recorrentes.

**61–80 — Porto respeitado** — Clientes de frete regional aparecem. Negociação fica favorável ao jogador.

**81–100 — Referência comercial** — Contratos exclusivos de longa duração. Clientes corporativos. Atenção do Grupo Atlântico.

## 🏘️ Eixo Comunitário — cidade e câmara

**Abaixo de 40** — Comunidade se afasta. Final E disponível, Final B bloqueado. Câmara não ouve o jogador no Ato 3.

**70–84 — Vaquinha possível** — Em crise de dívida, pescadores e Dona Cida iniciam vaquinha. Arrecadação proporcional à reputação. Câmara municipal começa a ouvir.

**85+ — Cidade defende o porto** — Pescadores defendem ativamente em eventos públicos. Câmara vota com o jogador. Final B disponível em condições plenas. Final A acessível com aliança Arlindo.

## 📰 Eixo Imprensa — Bela

**Abaixo de 40** — Bela investiga o porto. Matérias negativas frequentes. Acima de 20 ainda há diálogo, abaixo de 20 ela publica negativo toda semana.

**65+ — Aviso antecipado** — Bela avisa antes de publicar algo delicado. Janela para o jogador agir.

**80+ — Pistas de investigação** — Bela compartilha pistas das três investigações independentes (origem do dinheiro do Atlântico, ligação de Arlindo com a prefeitura, dívidas reais do avô). Vira aliada narrativa.

**Mentira descoberta** — −15 a −30 pontos de uma vez. Recuperar leva semanas. Custo da disciplina honesta.

## 📊 Tabela base de ganho e perda

| | |
|---|---|
| **Cumprir contrato** | +1 a +5 Comercial (proporcional ao valor) |
| **Falhar contrato** | −3 a −8 Comercial + −2 a −4 Imprensa |
| **Boato de rival ativo** | −1 a −3 / dia Comercial até resolver |
| **Missão de NPC cumprida** | +3 a +8 no eixo do NPC (Comunitária ou Imprensa) |
| **Demolir construção histórica** | −5 fixo Comunitária |
| **Festa de São Pedro presente** | +3 a +6 Comunitária |
| **Carga ilegal descoberta** | −5 a −15 Comercial + −5 a −10 Imprensa |
| **Promessa cumprida a NPC** | +1 a +4 no eixo do NPC |
| **Promessa quebrada a NPC** | −2 a −6 no eixo do NPC |
| **Mentira descoberta pela Bela** | −15 a −30 Imprensa + −5 Comercial |

## ⚡ Interação entre eixos

**Imprensa alta amplifica Comercial** — Reputação com Bela alta + matéria positiva publicada = +1 na Comercial por duas semanas. A imprensa vira marketing orgânico.

**Comunitária baixa enfraquece a equipe** — Comunitária abaixo de 35 = Arlindo recruta funcionários do porto com mais facilidade. A cidade se afasta e os trabalhadores também.

**Comercial baixa fecha o banco** — Comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida. Sem opção financeira de emergência.

**Os eixos não somam** — Não existe 'reputação total'. Cada decisão e cada final lê os eixos relevantes separadamente. O jogador pode ser referência Comercial e Questionável Comunitário ao mesmo tempo — e isso conta.

## ✅ Decisões de design fechadas

**🎯 Três eixos visíveis** · Comercial · Comunitária · Imprensa, 0–100 cada

Três medidores independentes na escala 0–100. Cada um responde a tipos de ação diferentes. O jogador vê os três como descrições qualitativas: 0–20 'Desconhecido', 21–40 'Questionável', 41–60 'Confiável', 61–80 'Respeitado', 81–100 'Referência'. Sem setores invisíveis — a leitura é por eixo.

**⚓ Eixo Comercial** · Define contratos disponíveis

Afeta quais contratos chegam e a que preço. Acima de 60: clientes de frete regional aparecem. Acima de 80: contratos exclusivos de longa duração. Abaixo de 30: só contratos de baixo valor, Arlindo intercepta os bons. Aumenta com contratos cumpridos, estrutura mantida. Diminui com atrasos, reclamações públicas, carga avariada.

**🏘️ Eixo Comunitário** · Define alianças e finais

Afeta vaquinha, finais e voto da câmara. Acima de 70: vaquinha possível, Final A acessível com aliança Arlindo. Acima de 85: pescadores defendem o porto. Abaixo de 40: Final E disponível, Final B bloqueado. Aumenta com aluguel justo, Festa de São Pedro, defesa do mangue. Diminui com despejo, corrupção descoberta.

**📰 Eixo Imprensa (Bela)** · Define cobertura e acesso a info

Afeta cobertura semanal e acesso antecipado. Acima de 65: Bela avisa antes de publicar algo delicado. Acima de 80: compartilha pistas das investigações. Abaixo de 40: ela investiga o porto. Mentira descoberta reseta 15–30 pontos de uma vez.

**📋 Tabela base de ganho/perda** · Escala proporcional 0–100

Cumprir contrato: +1 a +5 Comercial. Falhar: −3 a −8 Comercial + −2 a −4 Imprensa. Missão NPC cumprida: +3 a +8 no eixo do NPC. Boato rival: −1 a −3/dia Comercial. Demolir histórica: −5 Comunitária. Festa de São Pedro: +3 a +6 Comunitária.

**📉 Decaimento passivo leve** · −0,5/dia após 5 dias sem ação no eixo

Cada eixo decai 0,5/dia se ficar 5+ dias sem ação relevante. Teto de decaimento passivo: −10 por eixo. Eventos negativos ativos adicionam −1/dia enquanto vigentes. A cidade duvida, mas não esquece.

**⚡ Interação entre eixos** · Os eixos conversam, não somam

Bela alta + matéria positiva = +1 Comercial por 2 sem. Comunitária <35 = Arlindo recruta funcionários mais fácil. Comercial <25 = Sr. Ribeiro recusa renegociar dívida. Mentira descoberta pela Bela = perda compartilhada Imprensa+Comercial.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
