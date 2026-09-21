# BR Port — protocolo de escuta (A6)

> **Este documento é para o Bruno, e é o único gate deste projeto que nenhuma
> sessão consegue passar.** O contêiner de desenvolvimento não tem placa de
> som: ninguém que escreveu estes sons os ouviu, e nenhuma das seis suítes
> pode dizer se eles prestam.
>
> O que a máquina já respondeu está em `tools/medir_audio.py` (marcador
> `SINAL OK`, no CI). O que sobra está aqui, e sobra de propósito.

---

## 1. Por que existe um protocolo, em vez de "ouve aí e diz"

Porque "achei estranho" não se corrige. As três perguntas abaixo saem da §7.1
do plano e foram escolhidas por serem **acionáveis**: cada resposta aponta para
uma constante, um arquivo ou uma decisão de desenho.

| Pergunta | O que ela decide |
|---|---|
| **Reconhecimento** — dá para dizer o que aconteceu sem olhar a tela? | o timbre do som, em `tools/gerar_sons.py` |
| **Dominância** — algum som se impõe ou some ao lado dos outros? | o nível relativo, e a `prioridade` no `Audio.gd` |
| **Fadiga** — depois de vinte turnos, algum incomoda? | a `espera` mínima, e se o som deve existir |

⚠️ **Nenhuma delas é "ficou bom".** Se a resposta for "não gostei", ela não diz
o que mudar — e a sessão seguinte vai adivinhar. As três acima dizem.

---

## 2. Como ouvir, para que duas escutas se comparem

1. **No telefone-alvo**, não no computador nem no fone. O alto-falante de um
   telefone é o que vai tocar isto, e é ele que decide metade do resultado (ver
   §4, que é o achado desta medição).
2. **Volume FIXO.** Abra o menu de pausa, ponha os dois cursores — Música e
   SFX — numa posição e **não lhes toque mais**. Eles ficam em
   `user://audio.cfg` e sobrevivem entre partidas. Anote a posição.
3. **Duas passagens, nesta ordem, e elas não se misturam:**
   - **Isolado** — um som de cada vez, sem jogo por trás. Responde
     *reconhecimento*.
   - **Em contexto** — jogando uma partida inteira. Responde *dominância* e
     *fadiga*, e só ela: um som isolado nunca cansa.
4. **Num sítio silencioso.** Estes sons vão de −1,7 a −8,9 dBTP; num ambiente
   ruidoso os quatro mais baixos (mar, gaivota, areia, mergulho) desaparecem
   por causa do quarto, não do arquivo.

---

## 3. A tabela, com o que a máquina já sabe

Medido por `python3 tools/medir_audio.py`. **Nada aqui é julgamento** — é o que
procurar.

| som | quando toca | dBTP | <500 Hz | o que a medição sugere procurar |
|---|---|---:|---:|---|
| `ui_click` | todo botão | −5,4 | 0% | fadiga: é o que mais toca |
| `ui_success` | ação deu certo | −1,7 | 0% | é o mais alto do jogo, com `vitoria` |
| `ui_warn` | não deu, sem gravidade | −2,8 | **99%** | ⚠️ **§4** — sobrevive ao alto-falante? |
| `ui_error` | caixa insuficiente, cliente foi | −3,1 | **88%** | ⚠️ §4 |
| `moeda` | caixa SOBE | −4,1 | 0% | reconhecimento: soa a dinheiro? |
| `alerta` | oferta do rival, parcela | −2,8 | 0% | dominância: tem de furar o resto |
| `navio_chega` | barco atraca | −3,4 | **100%** | ⚠️ **§4** — o caso extremo |
| `construir` | estrutura pronta | −2,2 | **92%** | ⚠️ §4 |
| `vitoria` / `derrota` | fim de jogo | −1,7 / −2,6 | 0% / **80%** | os dois distinguem-se? |
| `amb_mar` | a cada 6,5–9,5 s | −7,7 | 36% | fadiga: é o que mais repete |
| `fauna_gaivota` | a cada 42–72 s | −6,8 | 0% | dominância: some no mar? |
| `fauna_areia` / `mergulho` | toque na fauna | −8,9 / −7,3 | 15% / **72%** | são os mais baixos do jogo |

---

## 4. ⚠️ O achado desta medição, e é o que muda a escuta

**Seis dos catorze sons têm a maior parte da energia abaixo de 500 Hz** — e um
alto-falante de telefone começa a perder o grave mais ou menos aí. A energia
existe no arquivo e pode não sair do aparelho.

O caso que mais salta é o **aviso**. O `sfx_ui_warn` é feito de duas notas de
triângulo, **392,00 Hz (sol) e 329,63 Hz (mi)** — está escrito no gerador —, e
a régua mede **99% da energia abaixo de 500 Hz**, com centroide em 356 Hz. É o
som que avisa o jogador de que a ação não deu, e ele mora inteiro na faixa que
o telefone entrega pior.

O `sfx_navio_chega` é o extremo: fundamental de **116 Hz**, centroide medido
**138 Hz**, 100% abaixo de 500.

⚠️ **E ISTO NÃO É UM VEREDITO.** Ninguém aqui mediu o alto-falante do seu
telefone, e "perde o grave" não é o mesmo que "não se ouve": o ouvido
reconstrói a fundamental a partir das harmónicas. Pode estar perfeito. **A
pergunta é só esta, e só o seu ouvido a responde:**

> No telefone, com o volume que você fixou, **o aviso e o apito de navio
> chegam?** Ou ficam finos, sumidos ou abafados ao lado do clique e do
> sucesso, que não têm nada abaixo de 500 Hz?

Se a resposta for "somem", o conserto é conhecido e barato: subir uma harmónica
no gerador, não subir o volume. Se for "chegam", esta secção morre e fica o
registo de que se perguntou.

---

## 5. O teto que a soma diz, e o que ela não diz

Os dois buses (`Musica`, `SFX`) estão a **0 dB e sem efeito** — conferido pela
ferramenta, e é isso que autoriza somar. Três vozes (`VOZES = 3`) no pior
alinhamento possível dariam **+7,68 dBTP**.

⚠️ **Isso é um TETO aritmético, não uma previsão.** A mix real tem a fase de
cada som, o instante em que cada um entra e o volume que você escolheu — e o
`Audio.gd` só deixa UM pedido vencer por frame, de modo que três a coincidir
exige um som longo ainda a soar quando dois outros começam. **Se estourar, você
ouve; se não estourar, a soma não prova que nunca estoura.** É o que dá para
dizer sem ouvir.

---

## 6. O que anotar — e é curto de propósito

Para cada som que der problema (os outros não precisam de linha):

```
som:            sfx_ui_warn
passagem:       isolado | em contexto
o que ouvi:     "fica abafado, quase não separa do mar"
qual das três:  reconhecimento | dominância | fadiga
```

E uma linha no fim, para o conjunto:

```
volume fixado em:   Música __ / SFX __
telefone:           ____________________
depois de 32 turnos, o que incomodou:  ____________________
```

⚠️ **Registe também o que estava BOM**, e não só o que falhou. Sem isso a
sessão seguinte não sabe o que não pode estragar — e neste projeto já houve
correção que só se pagou porque alguém tinha escrito o que já funcionava.

---

## 7. Depois da escuta

As respostas entram como itens próprios, um por sessão, e cada uma diz que
constante mexe:

- **reconhecimento** → o desenho do som, em `tools/gerar_sons.py`. ⚠️ O CI
  compara os WAV byte a byte com o gerador: muda-se o gerador e regeram-se os
  arquivos, nunca o contrário.
- **dominância** → `prioridade` na tabela `SONS` do `Audio.gd`, ou o ganho do
  som no gerador.
- **fadiga** → `espera` na mesma tabela, ou a frequência do evento que o
  dispara.

E o que a máquina volta a conferir sozinha, a cada corrida: `SINAL OK` (true
peak e estalo) e `AUDIO OK` (o encanamento). Nenhum dos dois diz que os sons
são bons — continua a ser você.
