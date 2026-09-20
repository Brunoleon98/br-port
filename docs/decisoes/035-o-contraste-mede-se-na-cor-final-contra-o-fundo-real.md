# 035 — O contraste mede-se na cor FINAL, contra o fundo REAL

**20/09/2026 · R6 da §7.1 do plano v3 · origem: revisão externa de 17/09 (§2.4)**

## O defeito

`RotuloSecao/colors/font_color` era o neutro do jogo — `0,51/0,6/0,706` —, que
foi calibrado para a barra ESCURA. Sobre o cartão branco dos painéis ele mede
**2,93:1**, abaixo até do corte de texto GRANDE da WCAG (3,0), e estes rótulos
têm 13 px, que pedem 4,5.

Foi a **quarta** vez que esta cor mordeu sobre branco — calendário em 03/09,
painel Construir em 06/09, menu-celular em 13/09 — e a primeira em que ela
chegou lá pelo **tema** em vez de por um script. A revisão de 17/09 nomeou
quatro sítios de chamada. Medidos, eram **nove painéis**.

## O que a medição achou, e que a revisão não nomeava

`tools/medir_contraste_ui.gd` percorre **19 estados** de painel e mede **214
textos**. Antes de se mexer em nada: **22 reprovavam o AA**, e não eram um
defeito repetido — eram **quatro**.

| Causa | Quantos | Onde |
|---|---|---|
| `RotuloSecao` **2,93:1** @13px | 18 | Nomes, Calendário, Docas, Reputação, Caixa, Boletim, contra-oferta, Sr. Ribeiro, e todo `secao()` do andaime |
| `font_placeholder_color` **2,70:1** @16px | 1 | a sugestão do campo, na tela dos nomes |
| override âmbar **2,39:1** | 2 | o dia de hoje no calendário; a faixa atual na reputação |
| `COR_AVISO` **3,18:1** @13px | 1 | o convite a quitar a parcela, no HUD |

**A sugestão do campo foi o QUINTO endereço do mesmo neutro**, e nenhuma das
quatro vezes anteriores o citava — porque ela não é um rótulo, é um
`placeholder`, e a tela dos nomes abre com os dois à vista.

⚠️ **E "o painel é branco" não é uma resposta.** A mesma variação mede
**5,46:1** no cartão, **5,03:1** no balão da fala (`#f0f6ff`) e **5,27:1** no
creme da faixa de mensagem. O neutro media 2,93 no cartão e **2,70** no campo.
É por isso que a régua compõe o fundo alfa sobre alfa até ao primeiro opaco, em
vez de comparar contra uma cor escrita à mão.

## A decisão

Três cores, todas no **tema** — nenhuma escrita à mão:

- `RotuloSecao` → `0,35/0,42/0,50` — **5,46:1** no branco, 5,03:1 no balão.
- `LineEdit/colors/font_placeholder_color` → a mesma — **5,03:1** no campo.
- `RotuloAlerta`, variação nova → o âmbar do tema escurecido, **5,06:1**.

E o motivo do bloqueio sai de dentro do botão desligado (abaixo).

## ⚠️ Escurecer o âmbar custa a separação que ele existe para dar

Varrido no matiz do âmbar de marca (H 39,8°, S 0,928), contra o cartão branco:

| V | hex | vs branco | vs o navy à volta |
|---|---|---|---|
| 0,878 (o de marca) | `#e09a10` | **2,39:1** | 5,27:1 |
| 0,65 | `#a6720c` | 4,18:1 — ainda reprova | 3,01:1 |
| **0,58** | **`#94660b`** | **5,06:1** | **2,49:1** |
| 0,52 | `#855b0a` | 6,00:1 | 2,10:1 |

**Nenhum âmbar ganha o branco E o navy ao mesmo tempo.** O que passa o portão
perde mais de metade da separação contra o texto navy vizinho — e isso está
medido e é aceite de propósito, porque **o que separa este âmbar do navy é o
MATIZ e não o valor**: estão a ~180° um do outro, e este projeto já pagou para
aprender que a telha nunca se separou do chão pelo valor (`CLAUDE.md`, Arte).
Confirmado na captura dos dois painéis.

O corte foi para o **meio** da banda útil e não para a ponta: 0,58 deixa 0,56
de folga sobre o corte de 4,5, e 0,62 — que ainda passa, a 4,53 — estaria a
três centésimos dele.

Quem quiser a separação de volta **não muda a cor: muda a MASSA** — âmbar de
FUNDO com texto navy, que o `BotaoPrimario` já faz e que mede 5,27:1. Isso é
mudança de leiaute, fica registado e não se fez aqui.

## ⚠️ A isenção do texto inativo estava a engolir o motivo do bloqueio

A WCAG 1.4.3 isenta o texto de um componente **inativo**, e a isenção é
legítima. O painel Construir escrevia a explicação **dentro** do botão
desligado — `btn.text = ... else impedimento` —, e ela saía a **2,16:1**: uma
régua correta dava-a por isenta com razão, e o jogador ficava sem a ler. O
cabeçalho do próprio painel diz a intenção com todas as letras: *"POR QUE não
dá, quando não dá. Um botão apagado sem explicação faz o jogador achar que o
jogo travou."*

E **não se conserta acrescentando uma linha**: o cartão já crescia até ~920 px
numa tela de 1280, com o "Fechar" rente à borda. Conserta-se **tirando** — um
botão que não se pode premir é um convite falso, e o que a estrutura bloqueada
tem a dizer é uma frase. O cartão ficou **60 px mais curto**.

O Sr. Ribeiro é o caso do outro lado e fica como está: ali o rótulo inativo
descreve a AÇÃO ("Pagar R$530.000") e o motivo vive ao lado ("Caixa:
R$1.000"), que agora se lê a 5,46:1.

## A guarda: D33, e o motor partilhado

`scripts/validation/contraste_ui.gd` é o motor, com **dois** consumidores: a
ferramenta imprime a tabela, o D33 do `teste_design.gd` reprova. **Um arquivo
só**, porque regra duplicada nunca reprova — e aqui seria pior do que o
costume: a ferramenta diria verde de uma medição e o CI de outra.

O que o D33 acrescenta ao que já havia:

1. **O percurso deriva do disco.** Painel novo que ninguém acrescente reprova.
2. **O fundo REAL**, composto alfa sobre alfa até ao opaco, com o `modulate`
   aplicado ao texto e ao fundo por cadeias separadas.
3. **Composição não resolvida é PENDÊNCIA.** Onde o que está por trás é
   desconhecido — o cartão da doca tem alfa 0,96 sobre o mapa — a medição dá as
   DUAS pontas do intervalo, e se elas discordarem sobre passar, reprova. Não
   se escolhe a ponta que convém.
4. **O rótulo inativo tem de descrever a AÇÃO**, e a pergunta deriva do próprio
   percurso: a forma do rótulo tem de aparecer VIVA nalgum estado. "Pagar R$…"
   aparece; "Precisa antes de: …" só existe bloqueada.
5. **O percurso declara quantos estados tem** (19), que é a regra da folha de
   contato com um estado no lugar da página.

**Os três blocos antigos ficam.** O D19 confere que ACHA o fundo do cartão, o
D23 mede a LARGURA que o menu custou ao rodapé, o D32 o alvo de toque da faixa
— coisas que o D33 não pergunta.

## Os mutantes

Seis, cada um sozinho, com a base exigida VERDE entre eles e a cópia guardada
com `cp` e não com `git`:

| # | Defeito | Resultado |
|---|---|---|
| M1 | par abaixo do limite num painel nunca coberto (Docas) | reprovou — **e o D19, o D23 e o D32 não o veem** |
| M2 | override ruim com o tema certo | reprovou, a 2,39:1 |
| M3 | estado excluído do percurso | reprovou: 18 estados, foram 19 |
| M4 | painel em disco fora do percurso | reprovou, nomeando o arquivo |
| M5 | o motivo de volta para dentro do botão inativo | reprovou nos três cartões |
| M6 | a própria régua avariada (diferença no lugar da razão) | a calibração reprovou-a antes da auditoria |

⚠️ **E O M1 PRECISOU DE SEGUNDA TENTATIVA.** A primeira ACRESCENTAVA um
parágrafo ao painel, e quem reprovou foi o bloco das Docas a dizer que o painel
não mostrava "Docas" — a guarda de contraste nunca chegou a ser exercida. Um
defeito de COR mexe só na cor: é a regra do `CLAUDE.md` sobre conferir QUAL
guarda está a segurar a asserção, com um painel no lugar de uma doca.

## O que fica de fora, dito

- **O `COR_PASSADO` do calendário é `0,35/0,42/0,52`** e a variação é `0,50` —
  duas grafias quase iguais da mesma cor. Passa o portão (5,42:1); unificá-las
  é do R7, que é quem trata dos overrides.
- **Ficam 18 `add_theme_color_override`** (eram 21). Todos passam o portão
  medido; o R7 é quem decide o que migra.
- **7:1 não foi usado como portão** — a ficha do R6 chama-lhe referência
  ampliada opcional, e não garantia sob sol. O portão é o AA.
