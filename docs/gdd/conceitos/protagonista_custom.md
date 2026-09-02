<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🎨 Nome & Aparência do Protagonista

> Identidade visual e o nome que a cidade vai conhecer

*O nome do porto é o nome do seu legado. A roupa que você usa fala antes de você falar.*

**📛 Nome do porto e do personagem** — Na primeira tela do jogo, o jogador define dois nomes: o seu (exibido em diálogos e documentos) e o nome do Cais — que substitui 'Cais Mirim' em toda a interface. NPCs adotam o nome escolhido naturalmente. Toninho sempre chama de 'chefia'. Dona Cida usa o nome formal. Zezão raramente usa — e quando usa, é importante. O nome do porto aparece na placa do galpão, nos contratos impressos e na manchete do jornal de Bela quando o porto recebe reconhecimento.

**📝 Convenção do GDD: 'Cais Mirim' é placeholder** — Em todo o GDD e nos diálogos pré-escritos, 'Cais Mirim' aparece como nome-padrão de referência. Na implementação, esse string é tratado como variável substituível pelo nome escolhido pelo jogador na primeira tela. Tecnicamente: usar um único token (ex.: {portName}) em todos os textos de UI e diálogo, com 'Cais Mirim' como fallback exibido apenas se o jogador deixar o campo em branco. Manchetes da Bela, contratos, placa do galpão, finais ('o [nome do cais] permanece independente') — todos usam o mesmo token. Nenhuma referência ao porto deve ficar hardcoded em texto.

**👤 Aparência — partes personalizáveis** — Tom de pele (escala ampla representando a diversidade do litoral brasileiro), tipo e cor de cabelo, olhos, sobrancelhas, boca e formato de rosto. Gênero masculino ou feminino, como já definido. Todas as opções são geradas em Flat Design vetorial consistente com o estilo visual do jogo. A silhueta do protagonista é robusta — adequada para trabalho portuário, não estereotipada.

**👕 Roupas e impacto narrativo** — Três registros de vestimenta com variações de cor: Trabalho (camiseta, bermuda, bota — o cotidiano do porto), Social (camisa, calça — para visitas à prefeitura, reuniões, eventos do setor) e Formal (terno, gravata — para negociações com o Grupo Atlântico e cerimônias de prestígio). O jogo detecta o contexto e NPCs comentam quando o protagonista aparece fora do registro esperado: Dona Cida: 'Chefia, o senhor vai assim mesmo pra reunião com a Dra. Patrícia?' O Grupo Atlântico responde diferente conforme a apresentação visual.

**🔄 Quando e como trocar** — Roupas trocadas livremente entre turnos, sem custo. Mas roupas formais precisam ser adquiridas — aparecem como item narrativo, não como loja separada. O terno do avô é encontrado no galpão velho durante o tutorial. Usá-lo numa reunião importante gera uma linha de Toninho que é um dos momentos mais emotivos do early game.

**🎭 Impacto real nas interações** — Terno numa reunião com o Abutre: ele observa que o protagonista 'se preparou' — resposta ligeiramente diferente. Camiseta: 'Conheço esse tipo — acredita que honestidade vale mais que aparência.' Arlindo comenta se o jogador aparece sempre no mesmo registro — a falta de adaptação social incomoda quem nasceu negociando. Bela nunca comenta a aparência diretamente. Ela escreve sobre o que a aparência revela sobre caráter.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
