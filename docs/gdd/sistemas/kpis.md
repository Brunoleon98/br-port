<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📊 Métricas de Sucesso, Plano de QA e Compliance

O que significa sucesso comercial, como o jogo é testado antes do lançamento, e como a privacidade do jogador é tratada.

## 🎯 KPIs de sucesso comercial

**Critério mínimo (sobrevivência)** — 5.000 cópias vendidas em 6 meses pós-lançamento. Cobre custos diretos de produção de um dev solo (~12 meses de trabalho). Sem isso, o projeto não se paga e o estúdio precisa repensar estratégia. Esse é o piso de não-falência.

**Critério bom (continuidade)** — 20.000 cópias em 12 meses. Financia DLC de história + DLC de cenário e mantém o estúdio ativo. Justifica continuação do BR Port como franquia.

**Critério excelente (escala)** — 50.000+ cópias em 12 meses. Permite contratação parcial (artista contratado, músico contratado), lançamento Steam ampliado e segundo título da casa. Esse é o cenário 'sucesso de público'.

**Métricas de engajamento** — D1 retention ≥ 40%. D7 ≥ 20%. D30 ≥ 10% (premium mobile, sem ads, retenção baixa é normal). Sessão média ≥ 12 min. Campanha completa em ≥ 30% dos jogadores que abrem mais de 3 vezes. Funil de conversão da demo: 8% mínimo (demo grátis → compra).

**Review score** — Steam ≥ 85% positivo em 100+ reviews. App Store ≥ 4.3 estrelas. Google Play ≥ 4.2 estrelas. Reviews públicas são vetor crítico de descoberta orgânica em premium mobile.

## 🧪 Plano de QA pré-lançamento

**QA interno — designer + 2–3 voluntários** — Durante toda a produção. Foco em: bugs bloqueadores, balanceamento por playtest, leitura de UX em devices reais. Cada build importante (fim de fase de produção) tem ciclo de 3–5 dias de teste antes de avançar.

**Beta fechado — 50–100 testadores** — 3 meses antes do lançamento. Recrutados via mailing list e Discord. NDA leve (sem stream antes do release). Foco em: viabilidade do tutorial sem ajuda, retenção D1–D7 simulada, identificação de softlocks no Ato 3.

**Beta aberto — 1 mês antes (opcional)** — Decisão a tomar quando o jogo estiver pronto: vale mais o burburinho de beta aberto ou o impacto do lançamento surpresa? Depende de quanto polish foi conseguido até lá.

**Devices de teste — lista mínima** — iOS: iPhone SE (3ª geração), iPhone XR, iPhone 14. Android: Samsung A23 (3GB RAM), Samsung A53, Motorola G34 (mercado brasileiro popular). Mínimo cobre 80% do mercado-alvo. Cada release final testado em todos os 6 antes do envio às lojas.

**Cronograma de QA vs release** — Code freeze 4 semanas antes do release. 2 semanas de QA intensivo dedicado. 1 semana de soak test (jogo rodando 24h em loop com bot simulando ações). 1 semana de buffer para submissão às lojas (Apple costuma demorar 3–7 dias de aprovação).

## 🔒 Compliance — LGPD e GDPR

**Política de privacidade explícita** — Tela acessível em Configurações + link na loja. Descreve: que dados são coletados (sessão, crash reports, analytics opcional via Firebase), por quanto tempo são retidos, com quem são compartilhados (Firebase = Google), direitos do titular (deletar conta, exportar dados, opt-out).

**Opt-in para analytics** — Na primeira abertura, o jogador escolhe se aceita compartilhar dados de uso anônimos. Default: opt-out. Sem analytics, o jogo funciona idêntico — o jogador não perde nada. Decisão revogável a qualquer momento em Configurações.

**Sem coleta de dados pessoais por padrão** — Nenhum dado pessoal (email, nome real, localização) é coletado para gameplay. Login com Google Play ou Apple ID é só para sincronização — nada é enviado para o estúdio. Dados de pagamento ficam exclusivamente nas plataformas.

**LGPD (Brasil) e GDPR (UE)** — Conformidade desde o lançamento. Política de privacidade em PT-BR e EN-US. Botão 'Solicitar exclusão de dados' em Configurações funcional desde o dia 1.

**Sem coleta de dados de menores** — Classificação etária 12+. Sem chat in-game, sem login social além de Google/Apple, sem coleta de dados que identifiquem menor de idade. Conforme COPPA (EUA) e LGPD (Brasil).


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
