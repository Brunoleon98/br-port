# Bancada RB5 — tamanho do texto, 19/10/2026

Base: main `fc052032ea796060eea803d46f413ccdb0b14bf1`, depois dos PRs
#143 (RB6) e #144 (vegetação). Branch `codex/bancada-texto-ajustavel`.
Recorte autorizado na `131`: medir Padrão/+25%/+50% antes de escolher o Maior.
**Não é a preferência global implementada nem um leiaute aprovado.**

## Reproduzir

Godot da `.godot-version` (4.6.3 nesta bancada). Importar primeiro, em perfil
descartável, como todas as ferramentas do projeto. Para medir sem imagem:

```sh
python3 tools/rodar_bancada_texto.py --godot /caminho/para/godot \
  --saida /tmp/bancada-texto
```

Para fotos, repetir com `--capturar` em ambiente gráfico permitido, ou com
`xvfb-run -a` quando disponível. Não esperar imagem de `--headless`.
`--cenarios` e `--fatores` permitem repetir apenas um caso.
O executor tem teto de 180 s por processo, exige marcador real, manifesto
e PNG quando solicitado; verifica estado antes/depois, reaplicação da escala,
retorno à base e sentinela dos seis arquivos do jogador.

No ambiente desta sessão não havia Xvfb e o sandbox proibia sockets locais.
A primeira solicitação foi interrompida sem execução. Após Bruno pedir
continuar, a autorização da plataforma permitiu Xorg virtual com driver dummy,
sem escuta TCP; duas baterias gráficas terminaram, encerrando o servidor
pelo seu PID. Não houve rejeição automática nem alteração de política do projeto.

## Mesmo estado e parâmetros

- Janela lógica 720×1280, FPS fixo 60, semente 42; turno 1, caixa R$400.000.
- Reduzir movimento ligado antes de montar os nós, só em memória.
- Os três espaços de ferramenta são derivados novamente; o jogador não é lido.
- O artigo é o mais longo do conteúdo real: Glossário. Há foto no início e fim.
- A doca usa texto de extremos das tabelas e formatadores reais, como o D18.
  É uma fixture de apresentação: o primeiro cartão mostra DOCA 3, não uma
  partida jogada até esse estado. As demais colunas conservam o contexto.
- Ajustes/artigo ampliam o painel; HUD/doca ampliam a interface da Main.
  Não foram alterados mapa, viewport, enquadramento ou projeção.
- A linha de candidatos dos Ajustes é amostra da bancada, sem callbacks de
  interação. A aplicação escolhe o fator pela linha de comando, sem persistir.

Duas baterias de 18 processos produziram **21 PNGs iguais, par a par, por bytes**,
18 manifestos e o resumo idênticos. Os manifestos também coincidiram com os
18 processos headless. Reaplicar não acumula escala e o retorno a 1 restaura
a fonte base. Estado, RNG, arquivos e registro conservaram a fotografia
anterior à ampliação. As duas sentinelas gráficas ficaram intactas.

## O que as medidas e as imagens mostram

| Caso | Fator | Largura das docas | Largura da fila | Invasão da mensagem pela fila | Textos fora da janela |
|---|---:|---:|---:|---:|---:|
| HUD | 1 | 692 | 692 | 0 | 0 |
| HUD | 1,25 | 692 | 696 | 11 | 0 |
| HUD | 1,5 | 727 | 771 | 27 | 1 |
| Doca longa | 1 | 692 | 692 | 0 | 0 |
| Doca longa | 1,25 | 736 | 696 | 11 | 0 |
| Doca longa | 1,5 | 797 | 771 | 27 | 2 |

**+25% já exige acomodação.** A barra de docas longa termina em x=750,
além dos 720 da janela, mesmo sem um glyph detectado fora dela. A faixa
de mensagem cobre parte de “aguarda mais 1 dia” da fila na imagem.

**+50% aumenta a pressão.** `R$8.440` ultrapassa a janela em 54 unidades;
`píer em ruínas` também sai em 19,1875 no caso longo. O cartão de meta
atinge 90 de altura e invade em 7 a faixa Construir.

Nos dois Ajustes, os 18 textos de cada fator não apresentam excesso medido;
os controles e Voltar ficam visíveis nas imagens. No Glossário, a altura
do conteúdo passa de 1.022 para 1.377 e 1.747; a área de leitura mede 638,
638 e 634. As fotos do fim mostram a última entrada e o botão Assuntos.

**Nenhum candidato está aprovado como ampliação global pronta.** O achado
não escolhe conforto no telefone. Não houve teste de toque/Voltar do aparelho.

## Limites e guardas

A régua usa os caracteres desenhados de Label e a extensão natural da fonte
para Button. Não reconstrói alinhamento/margens dos botões nem cobre todos
os papéis de texto do jogo. Rolagem não é isenção para prometer acesso:
o relatório conserva o excesso e informa o ScrollContainer. Sobreposição
de contentores não afirma que todos os seus glyphs colidem.

Um Label pode caber na própria caixa enquanto o contentor alarga e cobre
o vizinho. Por isso o manifesto guarda retângulos e mínimos originais/atuais;
um zero em `excesso_local` não aprova o leiaute. As fotos são parte da prova.

O bloco próprio `tests/casos_bancada_texto.gd`, chamado pelo teste de design
com bandeira final, calibra a régua: par que cabe/transborda na mesma caixa,
par dentro/fora da janela, override 19 → 24/29, reaplicação e retorno à base.
Quatro defeitos da régua entram no catálogo oficial `tools/mutantes.toml`;
os 120 anteriores são preservados, inclusive os 17 `movimento-*`.
O catálogo integrado terminou com `MUTANTES OK`: conjunto exato dos 124 ids,
cada suíte/rótulo declarado presente nas reprovações reais e bases verdes
antes/depois. Os 120 anteriores estão idênticos por conteúdo de cada entrada.
`mutantes-relatorio.json` e `mutantes.log` registram a execução completa.

As seis suítes concluíram: `TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`,
`FUMACA OK`, `REGISTRO OK` e `ASSET OK`, sem SCRIPT ERROR ou push_error.
As cinco bases finais do catálogo e o asset_validator posterior completam
essa verificação, com logs em `suites/`. A sentinela confirmou seis arquivos
intactos; o recibo consolidado é `verificacoes-finais.json`.
As cópias publicadas `sentinela-antes.log` e
`sentinela-mutantes-antes.log` omitem somente o caminho local do perfil
temporário, após bloqueio desse metadado pela revisão automática de publicação.
Os originais permanecem no acervo local; contagens e resultados são preservados.

Testes `39180551837`, Captura `39180551839` e Balanceamento `39254893265`
estão concluídos/success na main fc05203. Não validam esta bancada;
o CI próprio deve ser conferido no PR, separadamente das provas locais.

O teto do job de mutantes passa de 60 para 90 minutos: a main já consumiu
58min18s no job oficial `117832180799`, com 120 defeitos; esta bancada
acrescenta quatro. Não se alteraram os comandos nem o cálculo dos tetos por suíte.

## Arquivos e revisão humana

PNGs, manifestos e logs da mesma execução acompanham este README. Os segundos
quadros do artigo têm cópia do log real da própria execução. As folhas
comparativas e o comparador HTML locais derivam desses PNGs, sem modificar
os originais; não são outra renderização do jogo.

Bruno ainda precisa comparar no telefone e escolher o tamanho/acomodação.
Só depois cabe autorizar cobertura funcional global e memória por aparelho,
sem uma preferência apagar a outra. O RB6 conserva telefone/aceite visual
pendentes; a vegetação tem o aceite próprio da `130` e Claude segue no visual.
