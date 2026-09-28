# 073 — A frota no jogo: o convés de embarcações e nenhuma bandeira

**28/09/2026 · frente 4 do A5, família frota** — fecha a `072`. As duas ordens
do Bruno ao fechá-la eram **a baleeira num lugar mais realista** e **a bandeira
do Brasil fora de todos os navios**, os de pesca aceites incluídos. A sexta
candidata foi **aceite**, e os nove cascos estão no jogo.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| Onde vai a baleeira (perguntado ANTES de desenhar, com prévia em ASCII de cada opção) | **Convés de embarcações** — a recomendada, contra a queda livre na popa e «as duas, para comparar» |
| 6.ª candidata | **Aceito** |

A baleeira levou seis posições na `072`, todas escolhidas a olho e recusadas
uma a uma. Aqui a posição foi pergunta antes do render, e a primeira candidata
foi aceite.

## O que mudou no gerador

- **A superestrutura dos cargueiros tem dois níveis** (`superestrutura()` e
  `conves_de_embarcacoes()` em `gerar_props_iso.py`): em baixo um convés de
  acomodação largo (`NIVEL_BAIXO` 0,20); em cima a ponte, mais estreita, com
  `CONVES_BAL` 0,18 de cada bordo. O teto do nível de baixo é o **convés de
  embarcações**. A caixa envolvente não mudou: o topo, o comprimento e a boca
  são os de antes, e a chaminé, o radar e o `topo_sup` ficam onde estavam.
- **A baleeira** fica nesse convés, pelo bordo que se vê e a ré, com a borda
  0,03 para fora do nível de baixo, que é onde uma baleeira de turco fica
  estivada. Leva **dois turcos inclinados** (os montantes de pé foram a «cara»
  da `072`).
- **A parede ao lado dela é cega.** A fita de vidro da ponte subiu para o alto
  do nível de cima (`FITA_ALT` 0,12). As janelas desse nível ficam só à
  frente da baleeira, e as do nível de baixo por baixo da borda do convés. As
  asas do passadiço ficam à altura do pé da fita.
- **A bandeira saiu dos nove navios**, e com ela o `pavilhao()`, o parâmetro
  `bandeira` do `marcas_de_casco()`, as três cores da paleta e o mastro de
  sinais dos cargueiros.

## Como se mediu

- `tools/conferir_casco.py`: os seis cargueiros dão **«tudo dentro»**. Nos de
  pesca só aparece o que sai de propósito (pneus, motor de popa, portas de
  arrasto, o pau da traineira), e a bandeira já não consta.
- **D29**, antes → depois: traineira 50% → 46%, arrasteiro 53% → 55%, granel de
  longo curso 50% → 53%; os outros cinco a 53% nos dois lados (teto 62%). Os de
  pesca só perderam a bandeira. Ela voava para ré e alargava o desenho, e a
  régua lê a linha de fundo em proporção dele.
- `.pck` **+2.608 bytes** (13.505.736 → 13.508.344, +0,02% do `.pck`).
- As seis suítes verdes; a bateria de capturas e a folha da frota
  refotografadas.

## O que ficou por dizer

**A 1:1, os turcos leem como duas marcas escuras nas pontas da baleeira**, e
não claramente como turcos. Disse-o na entrega, e o Bruno aceitou assim.

**A baleeira nasceu dentro do casco na primeira foto, sem erro nenhum.** A
altura do convés vivia em `zc`, e o laço das marcas de calado, mais abaixo na
mesma função, reusava o nome e deixava-o em 0,46. Quem o apanhou foi a foto
(zero pixels laranja), e não o `conferir_casco.py`: dentro do casco não é
«fora». O comentário vive em `marcas_de_carga()`.
