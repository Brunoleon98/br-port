# Início e Configurações — verificação de 20/10/2026

Base remota: `f70b45c32db8d9c9556d81797e42a2471ccbefd9`, depois do
merge do #145 pelo Bruno. Trabalho novo na branch local
`codex/inicio-configuracoes`, decisão `132`. Sem novo PR ou publicação.
O verde remoto da base não aprova estas alterações.

## Defeito reproduzido e resultado

No Godot 4.6.3, o CheckButton ligado sob o ponteiro usa `hover_pressed`.
Antes, o estilo efetivo era `StyleBoxEmpty`, com letra branca sobre o
cartão branco. A preferência mudava; o controle é que desaparecia.
Depois, o tema fornece fundo opaco e indicador âmbar. Os contrastes medidos
foram 12,58:1 em normal, 9,64:1 em hover e 8,52:1 em pressed/hover_pressed.
As fotos registram o controle ligado e sob o ponteiro, além do desligado.

A inicial tem Continuar, Nova partida, Saves e Configurações nas duas
situações de disco. Sem partida, Continuar fica inativo e há explicação.
Saves abre o painel compartilhado dos três espaços. Configurações reúne
Ajustes, Como jogar e Versão e diagnóstico, nas mesmas cenas já existentes.
Fechar uma consulta devolve o mesmo menu; Voltar do aparelho fecha um nível.
A ajuda Salvar e retomar usa os nomes novos. A pausa conserva suas entradas.

## Guardas

`tests/casos_inicio_configuracoes.gd` (T30) tem bandeira final e é chamado
pelo `run_tests.gd`. Exercita as portas reais, as duas situações de disco,
duplicação, retorno, alvos de toque e preservação de partida/RNG/arquivos/registro.
A guarda de contraste lê os quatro estados efetivos do CheckButton,
incluindo o que faltava no percurso geral de normal/disabled.
O D33 também passa a visitar o novo painel de Configurações.

Cada defeito novo reprovou na exploração real, com base verde antes/depois:

| Defeito | Guarda declarada no run_tests |
|---|---|
| `inicio-movimento-sem-fundo` | T30: movimento hover_pressed tem fundo opaco e contraste AA |
| `inicio-consultas-sobrepostas` | T30: a consulta oculta o menu de Configurações |
| `inicio-consulta-sem-retorno` | T30: fechar a consulta devolve o mesmo menu visível |
| `inicio-continuar-sem-partida` | T30: Continuar só está habilitado quando há partida salva |
| `inicio-saves-sem-porta` | T30: Saves abre a lista compartilhada de espaços |
| `inicio-extras-na-inicial` | T30: início tem exatamente quatro entradas em ambas as situações |

Os 124 ids anteriores permanecem. São 123 entradas idênticas e uma
adaptação necessária: `movimento-duplica-ajustes` continua reinjetando a
duplicação e reprovando pela guarda original T29, contra a nova porta.
Com os seis novos, o catálogo tem 130 ids e 130 pares suíte/rótulo.

**Fecho local aprovado:** `MUTANTES OK` para os 130 ids exatos e todos os
130 pares suíte/rótulo confirmados nas reprovações reais. Bases verdes
antes/depois nas cinco suítes consumidoras; `asset_validator` também passou
antes/depois, completando as seis suítes e seus marcadores finais. Nenhum
`SCRIPT ERROR` ou `push_error` nas bases. Sentinela dos seis arquivos intacta.
Os 1.645 arquivos do jogo e alvos selados voltaram aos mesmos bytes; outra
comparação no fecho confirmou que não mudaram depois da execução.

## Fotos e fontes

A bateria completa produziu 107 PNGs 720×1280, cada um com log e marcador,
sem `SCRIPT ERROR`/`GDScript backtrace`. Cobertura aprovada: todos os 24
painéis abertos, 21 tempos e 12 caras declarados. Depois dela, mudaram só
comentários e o artigo Salvar e retomar; este recebeu foto complementar,
assim como a inicial vazia. As duas passaram nas mesmas verificações.
Foram inspecionadas inicial, Configurações, Saves, Ajustes ligado, inicial
vazia, artigo atualizado e a prévia da candidata. A inspeção não é aceite
no telefone. A bateria usa semente controlada, FPS 60 e contexto gráfico
virtual local, encerrado após as fotos.

As 109 fotos de produção ainda mostram o degradê. A ilustração foi testada
à parte, por troca de textura na ferramenta, sem alterar o recurso de produção.
Bruno gostou do estilo da v1 e pediu o porto ao fundo, como no jogo. A v2
atende a essa composição; sua foto de runtime foi apresentada, sem aceite
recebido. As fontes ficam no `art_lab/tela_inicial/v1/` e `v2/`, com README
e hashes. São PNG RGB opacos, nativos de 941×1672, sem redimensionamento
ou retoque posterior. A largura é inferior à proposta de 1080 do briefing
antigo; a prévia mostra o resultado real em 720×1280.

O conferidor de lote genérico acusa ausência de alfa/xadrez nessas imagens
opacas; o briefing pede fundo opaco e a inspeção não encontrou xadrez pintado.
Isso não é aceite de prop nem alteração da régua de projeção.
O celular ainda consome `TelaInicial.FUNDO`; uma integração só da inicial
deve preservar esse consumo, sem trocar o papel de parede por acidente.

## Continuidade

Logs, fotos e recibos locais em
`.evidencias/inicio-configuracoes/2026-10-20/`: `capturas-verificacao.json`,
`capturas-complementares/verificacao.json`, explorações, `mutantes-completo/`
e ferramentas locais de reprodução. Preservar esse acervo inteiro. Sua
montagem em outra sessão não é garantida. A consulta oficial do #145 ficou
em `.evidencias/texto-ajustavel/consulta-ci-2026-10-20/`; o acervo anterior
da bancada não estava montado neste ambiente e não foi dado por recuperado.

O #145 foi mesclado pelo Bruno. Testes `39361815077` e Captura
`39361815094` concluíram/success para a junção `bd804725d5e553153670a638f8628d0b6cdcbde0`,
com árvore igual à do head e da main resultante. Marcadores, 124 pares e
identidade exportada Web foram conferidos nos logs oficiais. A main
`f70b45c` também concluiu Testes `39367409196` e Captura `39367409279`/success.
Isso é o histórico da base; a entrega local ainda não tem CI próprio.
Na consulta final, as 270 refs/125 heads permaneciam idênticas, a main
continuava em `f70b45c` e não havia PR aberto. Essa consulta não reserva
números nem aprova uma integração futura.

Tamanho de texto global, acomodação e telefone continuam pendentes. A `131`
é bancada por `--script`, excluída dos exports. Não se escreve preferência
de texto nem se muda a gravação de movimento. Save, economia, RNG, duração,
dia, missão, meta e o visual do mapa não são alterados nesta entrega.

## Revisão da candidata v3

Bruno pediu subir o assunto para afastá-lo do menu, como na primeira imagem.
A v3 preserva o porto ao fundo e abre uma faixa de mar abaixo do navio.
Foi fotografada no jogo com título/cartão nas posições originais e
inspecionada em 720×1280: popa inteira acima do cartão, espaço de água entre
eles, título legível. Fonte RGB 941×1672 original em `art_lab/tela_inicial/v3/`.
Aceite da v3 ainda pendente; não entrou em `brport_vs/`.

Esta revisão mantém todos os arquivos do jogo, suítes, catálogo e workflow
idênticos aos de `9ebe192`. As seis suítes rodaram novamente, com marcadores
e sentinela intacta; a prova dos 130 pares permanece sobre o mesmo código.
A foto e os recibos adicionais ficam em `revisao-v3/` no acervo local.
O briefing `2026-10-20b` registra também o pedido do Bruno: resumo no fecho,
prompt completo somente quando solicitado.
