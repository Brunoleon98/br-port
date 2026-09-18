# 032 — A lista vive no workflow, e o texto responde por ela

**18/09/2026 · R3 da §7.1 do plano v3 · achado pela revisão externa de 17/09 (§2.6 e §2.7)**

## O defeito

Nada aqui estava partido. Toda referência resolvia, todo arquivo existia, as
seis suítes passavam. O que apodreceu foram **afirmações** — texto verdadeiro
no dia em que foi escrito e falso hoje, num repositório cuja maquinaria de
conferência inteira pergunta *"existe?"* e nenhuma peça perguntava *"ainda é
verdade?"*.

| Onde | Dizia | Era |
|---|---|---|
| `CLAUDE.md`, o hook, as três skills, o `COMO_RODAR` | **cinco** suítes | **seis** — o `teste_registro` entrou no CI em 02/09 e não era citado em nenhum dos seis |
| `CLAUDE.md` (o arquivo que carrega sozinho) | "as 30 partidas que o CI roda" | **600** desde 05/09 |
| `/fechar-sessao`, o ritual de fecho | regerar **dois** mapas | o CI regera **quatro** |
| `balanceamento.yml`, no resumo publicado toda segunda | alvo 100% / 79,5% / 35,7% | não é medido desde 12/09 |
| `simular_balanceamento.gd`, `teste_registro.gd` | 100% / 79,5% / 31,0% | idem |
| `gerar_tabela_numeros.py` → `BR_Port_Numeros_Fase_1.md` | "as 30 partidas que o CI roda" | a mentira era **regerada** a cada corrida, num arquivo que o CI compara byte a byte |

## A decisão, em duas frases

**A lista vive no workflow.** Onde o número informa e pode ser derivado, ele é
derivado: o hook e a §2 do `/fechar-sessao` montam a lista das suítes lendo o
`testes.yml`, e deixaram de a ter escrita.

**Onde não pode ser derivado, o texto responde por ela.** `tools/conferir_docs.py`
ganhou quatro perguntas, todas contra a fonte que a máquina corre — não contra
uma lista nova neste arquivo, que seria trocar um manifesto por outro.

E uma regra de triagem que vale para toda a varredura: **contagem que INSTRUI
confere-se; contagem que NARRA fica.** O `grep` por "cinco suítes" dá dezenas de
acertos, e quase todos são história verdadeira — *"nenhuma das cinco suítes lia
aquela linha"* descreve o que aconteceu naquele dia. Corrigi-los seria reescrever
o registo para ficar verde.

## As quatro perguntas novas

1. **Toda suíte que o CI roda está nomeada no `CLAUDE.md`.** Suíte omitida é
   suíte que ninguém roda à mão.
2. **Os mapas que o CI regera são os que o ritual manda regerar.** Eram quatro
   contra dois.
3. **Nenhum texto vivo diz um número de partidas que o comando não roda.**
4. **As taxas medidas do balanceamento têm UM endereço vivo** — o `CLAUDE.md`.
   Em código (`.yml`, `.gd`, `.py`) a régua é mais apertada: ali um triplo ou é
   o de hoje ou não se escreve.

## O que a guarda achou que a varredura não achou

A revisão listou três sítios com o triplo. A minha varredura à mão achou mais
dois. **A guarda achou sete**, e o sétimo é o que justifica tê-la escrito:

```
100,0% / 80,2%
/ 37,3%
```

⚠️ **UM NÚMERO PARTIDO POR UMA QUEBRA DE LINHA ESCAPA A TODO `grep` DE LINHA.**
Este repositório quebra a prosa aos ~79 caracteres, de modo que qualquer facto
de vários tokens pode ficar a cavalo de duas linhas — e aí `grep -n` não o vê,
por mais certo que o padrão esteja. A régua tem de ler o arquivo INTEIRO com
`\s*` a atravessar a quebra. Foi assim que este sítio sobreviveu a uma revisão
externa e a uma varredura minha, nos dois casos feitas com `grep`.

E a mesma correção apanhou `100,0%` contra `100%`: **uma vírgula a mais abria um
segundo endereço sem a guarda ver**, e por isso ela compara normalizado.

## A correção que foi um verde de graça

⚠️ Vale a pena escrever porque aconteceu **dentro da própria sessão que
escreveu a regra**. O bloco do `/fechar-sessao` que regera os mapas foi
consertado primeiro por DERIVAÇÃO: um `grep` sobre o `testes.yml` a extrair os
comandos. Corrido, ele casou **zero** comandos — no workflow eles estão
partidos por continuações `\` —, nada foi regerado, o `git diff` saiu vazio e
isso leu-se como sucesso.

**Receita derivada que não casa nada não reprova.** É a regra da amostra vazia
(`031`) com a roupa de um bloco de shell, e o sintoma é o pior que há: silêncio.
Conte o que a derivação achou antes de acreditar no silêncio dela. A lista dos
quatro mapas voltou a ser explícita, e quem a prende ao workflow é a pergunta 2
acima — duas fontes, em vez de uma derivação frágil.

## Medido, e não suposto

Revalidei as cinco contagens do baseline da revisão contra a fonte executada,
em vez de as herdar: **6 suítes, 4 mapas, 16 capturas, 600 partidas por perfil,
14 efeitos** (e 23 ícones). Todas confirmam. Duas afirmações que a revisão
listava já não existiam — os letreiros no `ESTADO_DO_PROJETO.md` e os "dez
rascunhos" do A6 —, o que é o outro lado de *"revalidar, não herdar"*.

E duas que a revisão **não** listou saíram da minha varredura: o `CLAUDE.md` a
dizer que o CI roda 30 partidas, e o `teste_registro.gd` a falar de "600
partidas × 3 perfis" quando os perfis são quatro desde 12/09.

## Os mutantes

Cinco, cada um sozinho, com controle positivo verde entre eles:

| Defeito | Quem reprovou |
|---|---|
| sétima suíte no CI sem o texto saber | a pergunta 1 |
| quinto mapa no CI sem o ritual saber | a pergunta 2 |
| o comando passa a rodar 30 e o texto fala de 600 | a pergunta 3 |
| um segundo endereço vivo para o triplo de hoje | a pergunta 4 |
| um triplo VELHO num workflow, como o que foi publicado duas semanas | a pergunta 4b |

## O que fica de fora, de propósito

- **A pergunta 3 é um fio de armar, não uma cerca.** Ela só dispara sobre a
  frase "N partidas … CI"; depois desta sessão nenhum texto vivo a usa, de modo
  que hoje ela não protege nada — protege no dia em que alguém a reescrever, que
  é exactamente como o defeito voltou da última vez. Não se escreve texto para
  satisfazer uma guarda.
- **O caminho inverso não é conferido:** um documento que nomeie uma suíte que
  o CI já não roda passa. A perda é menor (manda rodar algo a mais) e conferi-lo
  exigiria distinguir menção de instrução.
- Os `100% / 47,8% / 0%` de 01/09 que o plano narra duas vezes ficam intactos,
  com a data e o aviso de que a economia foi reescalada. A régua compara contra
  o triplo ATUAL justamente para não mandar reescrever história.
- A reconciliação com `arte_orfa.py` e os cinco sprites de `scenes/proto/`
  continua a ser o **§2.9**, e não se tocou nela.

## Um efeito colateral medido

Acrescentar quatro linhas de comentário ao `GameState.gd` mudou **41 linhas** do
`BR_Port_Numeros_Fase_1.md`: a tabela publica o número de linha de cada
constante, e o CI compara-a byte a byte. Não é defeito — é o acoplamento a
funcionar —, mas quem mexer num comentário daquele arquivo tem de regerar a
tabela, e é bom saber disso antes de ver o diff.
