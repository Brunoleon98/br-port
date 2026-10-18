# 129 — Reduzir movimento, primeiro recorte do RB6

**18/10/2026.** Bruno escolheu a opção 2, RB6. Meu porto agora (RB2) já
está na main. Base conferida: `56b3983`, merge do #142; nenhum PR aberto.
Claude informado como parado; terreno e vegetação continuam na frente dele
(`126`, item 1), sem aceite da `127`. Esta entrega não redesenha arte.

## Recorte autorizado

Preferência de apresentação “Reduzir movimento” nos Ajustes, acessível pelo
início e pela pausa, lembrada após reiniciar e independente dos três espaços.
Ausência ou valor inválido conserva o movimento atual. O inventário do código
precede qualquer alteração: separar decoração de sinais de operação,
resultados e ações. A escolha alcança elementos abertos e criados depois.

Sem `Engine.time_scale`, alteração de serviço, dia, economia, RNG, missão,
meta ou conteúdo do save. Persistência pelo ArmazemLocal, separada entre
jogador e ferramentas; sem função nova de save da partida, migração ou
mudança de SAVE_VERSION. Ações não podem esperar animação suprimida.

## Reserva e prova prevista

Branch `codex/reduzir-movimento`, PR rascunho antes da implementação.
Decisão 129 e briefing `BRIEFING_PROXIMA_CONVERSA_2026-10-18.md` conferidos
nos 122 ramos publicados; T29 livre no catálogo atual. Testes próprios,
defeitos no catálogo oficial preservando as 97 provas existentes, seis
suítes, sentinela, capturas inspecionadas e comparação temporal controlada.
Não se promete desempenho sem medição. Telefone e aceite visual são do Bruno.

A tentativa de fetch pelo shell não alcançou o proxy e uma permissão de rede
ficou pendente; a sincronização prosseguiu pelo conector GitHub, com objetos
conferidos por SHA. Não se reaproveitou a branch encerrada do #142.
