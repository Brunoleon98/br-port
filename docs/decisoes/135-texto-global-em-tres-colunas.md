# 135 — Texto global com três colunas e +25%

**22/10/2026.** Bruno aprovou a proposta da `134`: **«Três colunas com +25%
(recomendado)»**. O recorte de implementação continua o de
`docs/RECORTE_TEXTO_AJUSTAVEL_2026-10-19.md`. Esse aceite não autoriza publicar
automaticamente outra entrega nem repete o aceite da v3 da inicial.

O RB5 passa a ter Padrão e Maior nos mesmos Ajustes do início e da pausa,
com exemplo e aplicação na sessão. Maior arredonda cada fonte a partir de
sua base multiplicada por 1,25. Padrão restaura fontes e composição anteriores.
Logotipo e arte do mapa conservam suas medidas.

`TextoDaInterface` pertence à tela, sem autoload: observa novos controles,
troca o tema por uma cópia com os mesmos papéis e escala separadamente os
overrides explícitos. Escalar só o tema deixaria o HUD pequeno; escalar também
a letra herdada duplicaria o fator. A base de cada override fica no nó, para
não acumular a ampliação ao reaplicar. Sinais de texto e movimento são distintos.

`AcomodacaoDoPorto` conserva os mesmos cartões e sinais. Docas, fila, mensagem
e cobrança passam a uma área vertical com indicação de rolagem. Valores têm
linha própria quando presentes, inclusive depois de uma atracação; Construir,
Menu e Avançar ficam fixos. Voltar ao Padrão devolve os nós aos pais e medidas
originais. Mapa, projeção e viewport não mudam.

O gesto do rolo distingue arrastar de tocar antes da GUI. Doca nessa área só
age ao soltar um toque; um arrasto não libera nem atraca barco. Fora do rolo
o gesto anterior permanece. Teclado, campos e sinais dos controles continuam
nos mesmos nós.

Cartões altos e páginas do caderno podem rolar no Maior. O celular conserva
o aparelho e o papel de parede: seus apps usam duas colunas com rolagem;
a conversa conserva a janela rolável existente. Envolver a janela expansível
da conversa em outro rolo a faria encolher, por isso só a tela de apps recebe
esse envoltório. A mesma cautela vale para as consultas com ScrollContainer
expansível: envolver o VBox inteiro num segundo rolo zerava a leitura na
abertura direta em Maior. Testar só a troca a partir do Padrão assentado
não reproduzia isso; o percurso agora também abre todos os estados diretamente
com o tamanho maior.

A fita dos 84 dias pedia 389 px só entre traços e espaços: o Padrão medido
ocupava 473×680, e a barra de rolagem elevava a largura a 481 no Maior.
No Maior, a separação entre semanas/dias diminui, conservando os 84 traços,
e os offsets devolvem o aparelho aos 400×680 previstos, centralizado. No
Padrão voltam os espaços e a geometria efetivamente medidos antes da troca.
Diminuir o mínimo dos filhos não encolhe sozinho um Control que já cresceu.

Como `_input` recebe o gesto antes da GUI, o rolo do porto também verifica
se há painel visível por cima. O escurecimento de um modal só poderia bloquear
o toque na etapa seguinte; interceptar antes disso roubaria sua rolagem.

`MemoriaDeLeitura` guarda caractere e distância da dobra, em vez de reutilizar
pixels de outra quebra de linhas. A ajuda também usa essa referência ao
reabrir um artigo. O layout espera os contentores assentarem antes de devolver
leitura, foco e cursor; notificações intermediárias não cancelam esse restauro.

O restauro da leitura só pertence à troca explícita de tamanho. Aplicá-lo
na montagem de qualquer nó roubava a posição inicial da conversa, que deve
mostrar a última mensagem. Um cartão que precisou do teto antes de obter
largura também precisa recalcular sua altura quando as linhas assentam;
guardar o teto deixava uma faixa branca abaixo do Voltar.

O botão ao lado de uma coluna expansível conserva sua largura de texto:
quebrá-lo eliminava esse mínimo e a coluna tomava todo o espaço. A captura
do Construir no porto inicial revelou a ação comprimida, embora os rótulos
passassem pela régua. A guarda agora mede a ação montada. A ferramenta de
captura jogada também procura o cartão da fila depois do reparent, em vez
de depender do caminho direto antigo.

Os limites da seleção de LineEdit só são consultados quando existe seleção.
Sem ela, o Godot escreve erro C++ com backtrace, sem SCRIPT ERROR; a prova
confere esse rastro e o comportamento do foco/cursor.

Cada setter de apresentação carrega o ConfigFile existente e escreve a sua
chave. Assim conserva a outra escolha e chaves desconhecidas. Ausência ou
tamanho inválido usa Padrão; ler não cria arquivo. Falhar ao gravar conserva
a escolha da sessão e informa que não foi possível lembrá-la. A apresentação
continua fora dos espaços de save, via ArmazemLocal.

A integração local foi concluída em 23/10 na branch
`codex/rb5-texto-global`, descendente da main `ed2c770`. A branch da bancada
`codex/rb5-acomodacao-texto` e o fechamento anterior ficam preservados.
As provas estão em `docs/arquivo/VERIFICACAO_RB5_2026-10-23/README.md`:
seis suítes, 158 pares de mutantes, 84 percursos de captura (86 PNGs),
cobertura e Padrão comparado com a main. O Web local provou os quatro pares
de preferências após reinício e o arrasto por toque com partida preservada.
Depois do fechamento local, Bruno autorizou: «Pode seguir com o PR caso não
tenha achado erros». A conferência continuou verde e o PR #148 foi aberto
em 23/10. CI remoto desta integração e teste físico no telefone continuam
pendentes, sem merge ou atualização do Pages. O registro em
`docs/arquivo/VERIFICACAO_RB5_2026-10-23/PUBLICACAO.md` distingue esse envio
das provas locais e da main publicada.
