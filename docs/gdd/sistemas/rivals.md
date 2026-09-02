<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# ⚔️ Sistema de Rivalidade

A IA rival age continuamente. O jogador pode ignorar, reagir ou contra-atacar — cada escolha tem consequência.

## 🤖 Como a IA rival age

**Roubo de contratos** — Rivais fazem lances em leilões e podem oferecer preços menores para atrair clientes fixos.

**Boatos e reputação** — Rivais podem espalhar rumores que reduzem sua reputação na cidade temporariamente.

**Expansão territorial** — Se o jogador demora a crescer, rivais constroem estruturas que bloqueiam rotas valiosas.

**Escalada gradual** — Capitão Arlindo age nas fases 1-3. Sr. Abutre (Atlântico S.A.) entra na fase 4 com poder corporativo.

## 🛡️ Como o jogador reage

**Intervenção em leilão** — Ao detectar lance rival, jogador pode pausar e superar a oferta antes do prazo.

**Contra-reputação** — Missões com NPCs (ex: Bela a repórter) podem reverter boatos e gerar PR positivo.

**Aliança estratégica** — Certos rivais menores podem virar parceiros se o jogador os ajuda em momentos críticos.

**Sabotagem passiva** — Preços mais baixos e prazos mais curtos drenam a clientela rival sem confronto direto.

## 📊 Rivalômetro

**Medidor por rival** — Cada rival tem uma barra de ameaça (baixa / média / crítica). Quanto mais ignora, mais cresce.

**Eventos de crise** — Quando a barra atinge crítico, surge um evento especial — ex: Arlindo compra o melhor contrato da semana.

**Resolução narrativa** — Cada rival tem um arco: derrotá-lo desbloqueia cenas e bônus permanentes.

## ✅ Decisões de design fechadas

**📡 Aviso de ação rival** · Proporcional ao Rivalômetro

Baixo = sem aviso. Médio = sinal vago ('Arlindo está se movimentando...'). Crítico = aviso claro com janela de reação.

**🤝 Aliança entre rivais** · Evento narrativo único

Cena exclusiva na transição para a Fase 4. O jogador pode impedir via missão com a Bela. Se não intervir, agem juntos por período limitado.

**💀 Eliminação de rival** · Narrativa, não mecânica

Arlindo para de agir ativamente quando derrotado e pode virar aliado. Abutre nunca é eliminado — a corporação é grande demais.

**⚓ Arco do Arlindo** · Aliado por escolha, com custo

Proposta de parceria após Fase 3. Aceitar = bônus permanentes + custo de reputação com NPCs desconfiantes. Recusar = rivalidade até a Fase 4.

**🔴 Rivalômetro no HUD** · Aparece só após descoberta do rival

No início do jogo, o Rivalômetro não existe no HUD. Os primeiros ataques de Arlindo parecem azar — contratos perdidos sem explicação, fornecedores que somem. Quando o jogador percebe o padrão e descobre que é Arlindo (gatilho narrativo, ~semana 3–4 do Ato 1, dependendo das ações), Toninho ou Bela apresentam o conceito de rivalidade e o ícone do Rivalômetro aparece pela primeira vez. A partir daí: ícone compacto por rival, muda de cor (verde → amarelo → vermelho). Tocar expande o painel completo. Sempre visível depois desse momento, nunca intrusivo.

**🤖 IA dos rivais** · Script + gatilhos reativos

Sequência base predefinida por fase. Comportamentos do jogador disparam reações cirúrgicas — ex: dominar leilões por 3 dias aciona campanha de boatos.

**🔍 Espionagem via Bela** · Missões pagas com a repórter

A Bela pode ser contratada para investigar rivais por custo em reputação ou dinheiro. Retorna inteligência acionável. Disponível a partir da Fase 2.

**⚠️ Crítico ignorado** · Escalada em 3 atos

1º → rival fecha melhor contrato da semana. 2º → boato derruba reputação por 5 dias. 3º → evento narrativo obrigatório com penalidade permanente.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
