# Referências visuais — o alvo de arte do BR Port

Esta pasta guarda as imagens que definem **para onde a arte do jogo vai**.
Elas não são especificação de produção: são concept art. A diferença importa e
está registrada em `docs/design/BR_Port_Plano_Arte_Blender.md`.

---

## ⚠️ Os arquivos ainda não estão aqui

As cinco imagens chegaram por anexo numa conversa. **Anexo de chat não vira
arquivo no disco do contêiner** — o assistente vê a imagem, mas não tem um
caminho para copiar. Elas precisam entrar pelo Git, e o lugar é esta pasta.

Para pôr as imagens no projeto, arraste os arquivos para cá com estes nomes e
faça commit:

| Arquivo | O que a imagem mostra |
|---|---|
| `alvo_01_fase1_uma_doca.png` | Dia 18, 1 doca. Vila pequena, escritório, guindaste único, pesqueiro + cargueiro |
| `alvo_02_fase1_duas_docas.png` | Dia 19, 2 docas. Cidade com comércio (PADARIA, MERCADO), empilhadeiras, mais carga |
| `alvo_03_fase2_tres_docas.png` | Dia 18, 3 docas. Pórtico "PORTO MIRIM · BEM-VINDO!", pátio de contêineres, iate |
| `alvo_04_fase3_quatro_docas.png` | Dia 48, 4 docas. Silos, pórticos de contêiner azuis, ARMAZÉM ESPECIAL, navio de cruzeiro |
| `alvo_05_fase4_cinco_docas.png` | Dia 105, 5 docas. ADMINISTRAÇÃO com heliponto, ESTALEIRO com dique seco, OFICINAS, vagões |

Enquanto elas não chegam, a leitura abaixo é o que o projeto tem — e ela foi
escrita olhando as cinco, não de memória de estilo.

---

## O que as cinco imagens dizem juntas

**Elas são um ARCO DE CRESCIMENTO, não cinco variações.** Vila → cidade →
porto industrial → complexo portuário. É exatamente a progressão por Fase que
o GDD descreve, e valida a decisão de `--nivel-vila=N` no gerador do mapa —
só que num alcance muito maior do que o implementado.

O que cresce, na ordem em que cresce:

1. **Docas**, de 1 a 5, e o rótulo de tamanho junto (`2x1 CÉLULAS` → `3x2`).
2. **A cidade atrás**, de casa térrea a sobrado com comércio a prédio.
3. **A densidade do pátio**: carga solta → contêineres empilhados → pátio
   organizado em fileiras com empilhadeiras e caminhões circulando.
4. **O tipo de navio**: pesqueiro → cargueiro → porta-contêineres → cruzeiro.
5. **Os equipamentos**: guindaste de lança → pórtico → pórtico de contêiner
   sobre trilhos.
6. **Os prédios de apoio**, que só aparecem tarde: oficina, estaleiro,
   administração com heliponto, silos.

---

## Leitura de estilo

### Cenário

- **Projeção isométrica** com a mesma leitura 2:1 que o projeto já usa. A
  câmera é mais **AFASTADA** que a nossa: vê-se um distrito inteiro, não três
  berços. Isto é uma decisão de enquadramento tão importante quanto qualquer
  outra — ver §4 do plano.
- **Contorno escuro suave** na silhueta de cada volume. O projeto testou
  Freestyle e rejeitou (fechava o vazado da treliça); a referência mostra que
  a ideia estava certa e a implementação é que não servia.
- **Oclusão de ambiente em toda fresta** — sob beirais, entre contêineres,
  na junta do píer com a água. É o que dá o ar "assentado".
- **Luz quente de sol baixo** com sombra longa e azulada, e um fio de luz
  quente na quina superior de cada volume.
- **Densidade**: em qualquer recorte de 200×200px há 6 a 12 objetos. No nosso
  mapa há 1 a 3. É a diferença mais visível de todas.

### Paleta (amostrada das imagens)

| Elemento | Referência | O projeto hoje |
|---|---|---|
| Água rasa | turquesa `#3fb6cf`–`#57c6dc` | `#4a96b4` — mais cinza |
| Água funda | `#1b7fa8` | `#1d4f68` — bem mais escuro |
| Areia | `#e8d9a8` | não existe faixa de areia |
| Telha | `#c2502e` a `#e07a3c` | `#c85420` — está certo |
| Parede | creme `#f2e6cf`, e cada casa de uma cor | `#eef2f5` — frio e uniforme |
| Vegetação | `#3e8f3a` com `#6fbf4e` no realce | `#2d7a3a` — sem realce |
| Asfalto | `#6b6f76` com faixa amarela viva | `#6f7b85` — está certo |

**O ajuste mais barato e mais visível é a água e a areia.** A referência é
tropical e quente; o nosso mapa é de mar frio. São constantes no dicionário
`C` de `tools/gerar_mapa_iso.py`.

### Personagens

Trabalhadores em proporção **chibi** (≈3 cabeças), com **rosto desenhado**,
colete laranja, capacete, e braços separados do corpo. O nosso é um empilhado
de cinco caixas sem rosto. Rosto a esta escala é textura, não geometria — ver
o plano.

### Interface

A UI da referência é **muito mais encorpada** que a nossa, e nada disso é
Blender — é tema do Godot e ícone:

- Painéis com **gradiente vertical** sutil, borda clara de 2px, e **sombra
  projetada** por baixo.
- **Trilho esquerdo** de botões-pílula com ícone colorido e **contador
  vermelho** no canto.
- **Barra inferior** de 6 botões, cada um com **cor própria** (laranja, azul,
  laranja, verde, âmbar, roxo), gradiente e rótulo em caixa alta.
- **HUD superior** com pílulas de recurso, cada uma com ícone próprio, e o
  relógio/dia à direita.
- Rótulos de doca em **branco com contorno grosso**, com uma pílula escura
  por baixo dizendo o tamanho — curiosamente, é o que este projeto acabou de
  tirar do mapa. A diferença: lá o rótulo tem uma pílula de dado por baixo e
  fica sobre água vazia; aqui ficava sobre o barco.

---

## Como usar esta pasta

Referência serve para **decidir**, não para copiar. Antes de encomendar ou
gerar qualquer arte nova, a pergunta é: *qual das seis linhas de crescimento
acima esta peça serve, e em que Fase?* Peça que não responde a isso é peça
que vai ficar sem uso — já aconteceu duas vezes neste projeto
(`docs/arquivo/BLOCO4_PACOTE_SPRITES.md`).
