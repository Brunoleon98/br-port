# 147 — Aviso de reputação baixa e falas de Cida/Mané

30/10/2026. Ao tratar o primeiro parecer do revisor (`145`), Bruno escolheu:
em vez de comentar qualquer queda de reputação, Cida comenta quando ela está
baixa; pode haver alerta visual, como o indicador vermelho. Aceitou ajustar
«Esse contrato fecha a semana» e retirar a sugestão de entrega fixa/conta
mensal da cena do Mané.

## Regra e falas

O patamar baixo acompanha a classificação existente: Questionável ou
Desconhecido, abaixo de Confiável. Hoje isso corresponde a menos de 41, sem
criar corte econômico novo nem comparar o número arredondado do HUD.
`AvisoDeReputacao.baixa()` consulta o rótulo que o próprio GameState calcula.

Cida avisa uma vez por entrada no patamar baixo, inclusive ao abrir a partida
já baixa. Permanecer baixo não repete a fala; recuperar e cair de novo permite
outro aviso. As subidas de patamar mantêm o elogio. A memória fica na narradora
da sessão; não há campo novo no save. O id interno `reputacao_caiu` permanece
para os leitores existentes, agora com o gatilho restrito e sem atribuir causa.

Fala: «A fama do cais tá por baixo, chefia. Vamos caprichar nos próximos
serviços.» Bom contrato: «Esse valeu a conversa. Anota aí.»

A cena `mesa` passa a «Mais uma cadeira», mantendo o id salvo. Mané pede lugar
para sentar com o pessoal, e Toninho pede a cadeira que não balança. Tempo,
parcelas e condições continuam os mesmos. Café, almoço e compras permanecem
únicos, sem custo mensal. Nenhum preço, número econômico ou save foi alterado.

## Indicador e convivência com Claude

O HUD preserva número/classificação e usa âmbar no patamar saudável. O estilo
`TextoPilulaAlerta` oferece vermelho claro, com número e nome preservados;
`AvisoDeReputacao.atualizar()` escolhe o estilo baixo ou habitual.

Primeiro Bruno escolheu **aguardar o PR gráfico #156**, que alterava
`Main.gd` e `Main.tscn`. Depois informou «PR mesclado». Confirmado o merge em
`53b923b`, a branch incorporou a main e aplicou a linha do atualizador em
`_refresh_hud()`, sem pedir a autorização novamente. **A cor está integrada.**
O patch preparado está em
`docs/arquivo/REPUTACAO_E_FALAS_2026-10-30/integrar_indicador.patch`.

A prévia anterior chamava o atualizador só na ferramenta. As fotos finais e
o teste do HUD usam a integração real. Provas e histórico em
`docs/arquivo/REPUTACAO_E_FALAS_2026-10-30/README.md`.

O PR #156 também usa a decisão 144 e o briefing de 30/10 sem sufixo. Nossos
registros locais foram preservados com os números livres: história 146 e
briefing do revisor `30b`; os registros da arte e logs brutos não foram
reescritos. Enquanto aberto, o #156 foi conferido explicitamente em
`--outros`; depois do merge, sua cabeça está contida na base `53b923b`.

O preparador do revisor (`145`) inclui o predicado `AvisoDeReputacao` e a
chamada do HUD, para a próxima leitura contextual acompanhar texto, gatilho e
indicador em conjunto.

No fechamento de 31/10, incorporou-se também o PR #157 (`9c36e97`), que
reforça as bandeiras dos testes de design. Sem mudança de jogo nessa base;
o relatório completo de 259 defeitos na base do #156 foi preservado, e a
verificação final acompanha o catálogo ampliado, com 263.
