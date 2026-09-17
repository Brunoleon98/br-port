# 030 — A Leitura do simulador escolhe por identidade, e perdeu o veredito que não tinha decisão

**17/09/2026 · R1 da §7.1 do plano v3 · achado pela revisão externa de 17/09**

## O defeito, e o que ele custava

`_imprimir_diagnostico` lia os dois perfis da conclusão pela POSIÇÃO na lista:
o primeiro índice para o Ótimo e o último para o "jogar mal". Enquanto os
perfis eram três, o último era o Descuidado. Com o **Antecipado** acrescentado
no fim em 12/09 (`docs/decisoes/019`), passou a ser ele — o clone do Mediano que
quita a parcela adiantado.

Medido em 600 partidas, semente 20260825 do CI, com a tabela e a Leitura lado a
lado na mesma saída:

| | A tabela mede | A Leitura publicava |
|---|---:|---:|
| "Jogar mal" | Descuidado **37,3%** | **80%** (a taxa do Antecipado) |
| Vão | **62,7 pontos** | **20 pontos** |

**Não era erro de enfeite: invertia a conclusão.** Os dois vereditos que
dependem desses números dispararam ao contrário do que a tabela media — `80 >
50` acionou *"o ERRO NÃO CUSTA, é este o sintoma de 'fácil demais'"*, e `20 <
25` acionou *"a decisão do jogador pesa pouco no resultado"*, por cima de uma
tabela que mostra 62,7 pontos de vão.

**E havia um segundo defeito, latente.** O denominador (`n`) era montado dos
contadores do Ótimo e servia as DUAS taxas. Hoje não se vê, porque todos os
perfis correm as mesmas `partidas`; é da família do `.get(chave, 0)` que já fez
o relatório afirmar que o jogador construía de graça, à espera da primeira
rodada com amostras diferentes.

## O que se decidiu

**A identidade é o NOME, e não uma chave nova.** É o contrato que o projeto já
usa em dois sítios — o despejo JSON indexa `perfis[nome]` e o
`projetar_parcelas.py` consulta `medicao["perfis"]["Mediano"]`. Um contrato que
já existe em dois lugares não precisa de um terceiro.

"Descuidado" NÃO quer dizer "a menor taxa desta rodada". O papel é declarado, e
identidade ausente ou DUPLICADA é recusa explícita — escolher o primeiro de dois
homónimos seria voltar a decidir por posição com outra roupa.

**Cada taxa com o denominador do próprio perfil**, derivado do registro dele
(`vitorias + quebrou_antes + chegou_sem_dinheiro`, que particionam as partidas).
Amostra vazia não vira 0%: vira recusa, porque zero lê-se como medida.

**A diferença é em pontos percentuais, e a palavra está escrita na linha.**

## E o veredito saiu, que é a parte que não é conserto

*"O ERRO NÃO CUSTA, é este o sintoma de 'fácil demais'"* acima de 50%, e *"errar
custa caro"* abaixo de 15%, são limiares da fantasia de sobrevivência que a
`docs/decisoes/005` substituiu em 02/09. Aquela decisão diz o contrário com
todas as letras: num jogo tranquilo *"a decisão errada custa TEMPO e
OPORTUNIDADE, não a partida"*. **Nenhum limiar novo foi escrito para o lugar do
velho** — e inventar um aqui seria pôr política de balanceamento dentro de um
relatório, que é o que esta fila de correções está proibida de fazer.

O mesmo vale para *"vão estreito = a decisão do jogador pesa pouco"* abaixo de
25 pontos, que é o outro lado da mesma frase.

O que ficou no lugar dos dois é a descrição factual das taxas e do vão, mais uma
linha a apontar para o que a `009` diz que discrimina de verdade: a **margem em
regime** (R$674.019 contra R$103.290), e não a taxa de vitória.

Os ramos do TETO ficam. O Ótimo a 100% é alvo registrado, e a `005` diz por
escrito que perder tem de continuar possível.

## A prova, e o que ela custou a montar

A conclusão saiu de `simular_balanceamento.gd` para
`tools/leitura_do_simulador.gd` por uma razão só: **não havia como prová-la**.
Um veredito dentro de um `SceneTree` que roda 4 perfis × 600 partidas não se
alimenta com fixture. Fora dele é aritmética sobre um Array, e o bloco **T7** do
`run_tests.gd` — suíte que o CI já roda — dá-lhe sete fixtures sintéticas.

Os cinco mutantes do briefing, injetados **separadamente**, com controle
positivo verde entre cada um:

| Mutante | Asserções que reprovaram | Onde caiu |
|---|---:|---|
| acesso pelo último índice | 12 | A (pega o Antecipado) e A+extra |
| `argmin` no lugar da identidade | 12 | **só** A+extra e as recusas |
| troca só do rótulo impresso | 2 | a asserção de TEXTO |
| diferença relativa | 2 | **só** a fixture B |
| denominador do Ótimo reutilizado | 3 | **só** a fixture B |

⚠️ **Duas medições que contrariaram o desenho, e as duas na mesma direção.**

O `argmin` **passou a fixture do briefing inteira** — nela o Descuidado é mesmo
o mínimo, e as duas versões não divergem. Foi preciso um quinto perfil sintético
a 1/10 para ele ser ao mesmo tempo o último da lista e o mínimo observado.

E a diferença RELATIVA **também dá 70** quando o Ótimo está a 100%: `100 − 30 =
70` e `(100 − 30)/100 = 70%`. O estado que discrimina as duas contas é o Ótimo
FORA do teto — que é justamente o que o jogo não faz hoje. Daí a fixture B, com
o Ótimo a 16/20: 50 pontos contra 62,5% de diferença relativa, e ela é também a
que dá amostras de tamanhos diferentes (20 e 10), sem as quais o denominador
reaproveitado passaria despercebido.

## O que fica de fora, e é para dizer

O jogo **não mudou**: nenhum `# TUNING:`, nenhuma política de perfil, nenhuma
semente. O despejo JSON saiu **byte a byte idêntico** ao de antes, e o portão de
calibração do `projetar_parcelas.py` continua verde. O que mudou foram catorze
linhas de texto na conclusão.

A recusa por identidade encerra o simulador com código **1**, o que reprova os
dois workflows sob `set -euo pipefail` sem sentinela nova na saída — provado com
o perfil renomeado e com `-- 0`. A linha `=== Leitura ===` continua a sair mesmo
na recusa, porque é isso que o CI pergunta com ela: se a corrida CHEGOU ali.
