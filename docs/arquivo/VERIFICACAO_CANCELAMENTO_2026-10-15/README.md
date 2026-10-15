# Verificação do cancelamento integrado — 111

15/10/2026, Godot 4.6.3, base main b142b80. Entrega local em
`codex/implementar-cancelamento-servico`; não foi publicada.

`paridade.json` comprova a comparação integral de 600 partidas por perfil,
semente 20260825 e 365 fechos, nas cinco políticas de custos aprovados:
12.000 partidas de produção, contra a bancada atual E o arquivo selado da
110. Com/sem autosave: oito partidas e seus eventos integrais. Não é nova
escolha de custos ou uma estimativa de comportamento humano.

`partidas.zip` contém todos os dados da produção, a amostra de autosave,
a Fase 1 e as constantes. As referências originais permanecem em
`../MEDICOES_CANCELAMENTO_2026-10-15/partidas.zip`. `verificacoes.zip`
contém logs das seis suítes, os controles de oito defeitos semânticos,
restauração depois de cada um, paridade, calibração, sentinela e capturas.
O comparador também foi controlado com JSON igual, campo e partida removidos,
perfil e multa alterados e booleano substituído por número.
`verificacao.json` guarda resultados e hashes das fontes verificadas.

As fotos jogam desde o dia 1 até um cargueiro iniciado e abrem o fluxo real.
Somente a variante negativa força caixa zero para mostrar o aviso; o estado
é informado à HUD. O painel de contas mostra a multa já paga, sem redebito.
São capturas do Godot no Windows; não substituem o A7 no telefone.

A importação imprimiu `Safe save failed` e não é considerada limpa: a causa
e o arquivo não foram isolados, como na 110. As suítes passaram com seus
marcadores, códigos zero e sem `SCRIPT ERROR` ou `push_error`. O APK/Web
destas alterações não foram verificados por CI: não há PR novo. Testes,
Captura e Pages verdes conferidos pertencem ao merge do PR #132.

Para reproduzir a paridade e os defeitos injetados, em série:

```sh
python3 tools/verificar_integracao_cancelamento.py --godot /caminho/godot --saida /tmp/paridade --partidas 600 --janela 365
python3 tools/testar_integracao_cancelamento.py --godot /caminho/godot --saida /tmp/injecoes
```

O segundo comando modifica temporariamente a fonte da ação e restaura os
bytes originais entre os controles e ao sair. Não correr junto de suítes,
capturas ou outra ferramenta Godot. Os controles são de máquina; A4 e A7
continuam pendentes, e a branch de nomes 107 permanece separada.
