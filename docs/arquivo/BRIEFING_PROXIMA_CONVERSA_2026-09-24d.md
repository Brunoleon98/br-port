# BR Port — prompt para a próxima conversa (o trabalhador e as caras sem foto)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para desenhar a forma do trabalhador e ler cada veredito
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). Os
tiros da bateria, as provas no jogo e o rasto de prosa descem para **Sonnet**
depois de cada veredito.

**Situação:** os três que falam estão no jogo no kit afinado, cada um com a
sua cabeça, em Standard a −0,35 EV — decisão **`056`**, sobre a `055`. A
contente da Dona Cida sorri de boca fechada e com os olhos; o Sr. Ribeiro
(retangular e alto) e o Arlindo (de ângulos) passaram ao kit afinado, e o
kit de caixas dos retratos de fala saiu do `brp_porto.py`. O código é
`blender/brp_retratos.py` (`Rosto`, `CIDA`/`RIBEIRO`/`ARLINDO`, `KIT`), e
o caminho de cada um, volta a volta, está em `art_lab/retratos/`.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/elegant-carson-ttlss4`, à frente da `main`
  (`5276efa`, o #80 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, a `056` e os
  retratos novos só existem nela.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz — a ordem é do Bruno

- **O trabalhador do rodapé no kit afinado.** É o último retrato no kit de
  antes (`trabalhador_retrato` em `brp_porto.py`) e em AgX, e no boletim fica
  ao lado da Dona Cida. ⚠️ **É de CORPO INTEIRO de propósito** (identifica uma
  unidade pelo capacete e pelo colete, e é mostrado a ~70 px): o kit afinado
  é de bustos, e a pergunta de como ele passa — busto, corpo inteiro com as
  peças novas, só a cor — é do Bruno. Pergunte antes de produzir (a regra de
  23/09: a técnica de um asset é escolha dele).
- **Os tiros das caras sem foto na bateria**: a preocupada e a contente da
  Dona Cida (o boletim ruim e o ótimo), a formal do Sr. Ribeiro («a dívida») e
  a pressão do Arlindo («a última tentativa»), com o catálogo de capturas ao
  nível do TEMPO (`051`). Hoje a contente só foi vista numa cópia, com a
  ferramenta de cena a aceitar o resumo da semana em JSON — a da `main` não o
  faz.

⚠️ **Pergunte com opções, e pergunte O QUÊ.** Nesta frente o Bruno marcou
várias vezes TODAS as categorias de «ajustar» sem dizer o quê; o que
funcionou foi a segunda pergunta, com a lista do que se vê na foto (e o campo
de texto para o detalhe). Leia a resposta inteira — ele escreve o essencial no
«Outro» («ainda aparece linha azul no pescoço»).

## 3. O que ficou pendente do Bruno

- **O trabalhador** (§2): se passa, e como.
- **AgX ou Standard nos PROPS** (plano de arte §7.1): a troca global continua
  por decidir. Contorno por casco invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

Estão na `056`, no fim do §7.5 do plano de arte, nos comentários de
`blender/brp_retratos.py` e nos README de `art_lab/retratos/ribeiro/` e
`arlindo/`. As que mais servem ao passo seguinte:

- ⚠️ **Cada personagem é enquadrado pela SUA cabeça** (60% do quadro): à
  escala da Dona Cida a cara do Ribeiro saía 8,5% menor.
- ⚠️ **Numa câmera de cima, o que está atrás SOBE e o que avança DESCE**: o
  cabelo de um careca só se vê se passar acima do crânio na IMAGEM, e uma
  pala maior desce sobre as sobrancelhas.
- ⚠️ **Um tom contrário a alternar lê como pente ou lâminas**: o fio
  desenha-se pela sombra entre placas do mesmo tom.
- ⚠️ **Quando tirar a peça suspeita não tira a queixa, a peça é outra**: o
  «colar azul» do Arlindo era o tampo do tronco, não o pé de gola.
- ⚠️ **«0 pixels entre corridas» não se garante, nem na mesma máquina**: a
  prova de «não mudou» é o `tools/comparar_props.py` (`CLAUDE.md`).
- ⚠️ **Heredoc sem aspas executa as crases dos comentários** e apaga palavras
  sem erro: edite com `<<'EOF'` (`CLAUDE.md`).
- **A prova no jogo:** uma cópia por `git archive`, só os PNG trocados,
  `--import`, os tiros com os argumentos do `capturar_evidencia.sh`, e a
  comparação em **RGB**. O fecho corre a bateria inteira nas duas árvores.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11; o download do
  wheel (373 MB) cortou-se a meio uma vez — baixe-o com `pip download`
  primeiro. As pranchas pedem `pillow` no Python do sistema.

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `056`, o R1–R9 nem as levas de cor. A próxima
  livre é a **`057`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O veredito do Bruno e o que se fez com ele. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O PR só se
abre a pedido.
