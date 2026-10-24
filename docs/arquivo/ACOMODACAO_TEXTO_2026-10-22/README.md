# RB5 — propostas de acomodação, 22/10/2026

Continuação autorizada da `131`, decisão `134`. Base `ed2c770`, main do
#147, com Testes `39864014466` e Captura `39864014530` concluídos/success.
Os 132 ids/pares pós-merge foram auditados no relatório oficial, com bases
verdes e sentinela intacta. A branch de fechamento anterior foi preservada.

**Proposta para escolher tamanho e acomodação. Não é a opção global pronta.**
Comparador em [comparar.html](comparar.html). Os PNGs são capturas reais do
Godot, sem retoque; começo e fim da rolagem são arquivos independentes.

## Alternativas

- **Colunas:** mantém três docas e três barcos lado a lado. Valor com
  conteúdo ganha linha própria; nomes e descrições quebram dentro do cartão.
- **Lista:** conserva os mesmos cartões, um abaixo do outro, com maior
  largura de leitura. Precisa percorrer uma área vertical maior.

Construir, Menu e Avançar dia ficam fixos fora da rolagem. Pausar conserva
seu lugar na faixa superior, cujas margens internas foram reduzidas.
O modo Padrão usa a cena original, sem acomodação aplicada.

| Proposta | Aumento | Rolagem no HUD inicial | Rolagem com doca longa |
|---|---:|---:|---:|
| Colunas | +25% | 96 | 183 |
| Colunas | +50% | 188 | 260 |
| Lista | +25% | 623 | 623 |
| Lista | +50% | 744 | 744 |

Valores em unidades lógicas. A janela de leitura tem 380 de altura em
+25% e 369 em +50%; as ações fixas crescem com a fonte/estilo real.
Todos os conteúdos dos casos montados podem aparecer percorrendo a área,
mas não ficam simultaneamente à vista. Mensagem e cobrança também rolam;
esta é uma escolha de desenho a avaliar, não uma consequência já aceita.

**Sugestão para avaliação: Colunas/+25%.** Exige menos rolagem e mantém a
comparação entre barcos lado a lado. A régua não escolhe conforto de leitura
no telefone; +50% continua como candidata.

## Reprodução e controles

```sh
python3 tools/rodar_acomodacao_texto.py --godot /caminho/godot \
  --saida /tmp/rb5-acomodacao
# Acrescentar --capturar numa tela virtual; ferramentas em sequência.
```

Godot 4.6.3, 720×1280, FPS fixo 60, semente 42. Mesma montagem da bancada
original: turno 1, caixa R$400.000, movimento reduzido ligado em memória.
A doca longa é fixture de apresentação derivada das tabelas/formatadores,
não uma partida jogada até esse estado; o primeiro cartão mostra DOCA 3.
Não altera o save para fingir esse porto nem grava apresentacao.cfg.

Seis casos originais (HUD/doca × Padrão/+25%/+50%) e oito acomodados
(duas propostas × dois casos × dois aumentos). São 22 capturas: seis
originais e começo/fim de cada proposta. Os oito manifestos finais foram
repetidos em headless e coincidiram integralmente com os gráficos.

A comparação usa o mesmo texto/fonte por multiconjunto: nenhum texto
original foi perdido nem reduzido; só a indicação de rolagem foi acrescentada.
Nos oito pares, o raster do mapa, entre y=62 e y=722, ficou idêntico em
pixels RGB, inclusive nas fotos do fim. Os quatro controles fixos têm
retângulos dentro da janela e alvos mínimos de 44 unidades. Estado, RNG,
arquivos e registro foram fotografados antes da acomodação e da ampliação:
continuaram iguais. Reaplicar o fator não acumula escala; restaurar fontes
retorna à base. Sentinelas dos seis arquivos do jogador intactas.

O controle original com aumento sozinho conserva suas falhas conhecidas:
fila sobre mensagem e cortes em +50%. O caso Padrão é o controle sem essas
falhas. As primeiras propostas gastavam altura com linha de valor vazia e
folga excessiva nos botões; os arquivos finais retiram esse desperdício.
O primeiro raster de +50% também mostrou Pausar fora da janela; a proposta
passa a medir controles sem texto e acomoda as margens da faixa superior.
Os PNGs finais e recortes de inspeção confirmam a presença desses controles.

`conferencia.json` registra as comparações e `sha256.json` os arquivos da
execução. Logs/manifestos originais permanecem em
`.evidencias/rb5-acomodacao/2026-10-22/`. Só as cópias versionadas dos logs
trocam o diretório absoluto de saída por `<saida>` e o nome de perfil
temporário por `<perfil>`; resultados não mudam.

As seis suítes locais passaram com seus marcadores finais, sem SCRIPT ERROR
ou push_error; sentinela final dos seis arquivos intacta. `DOCS OK` dentro
dos tetos existentes. Os 1.649 arquivos existentes de produção, suíte e
catálogo foram conferidos byte a byte contra a main; só foram acrescentadas
ferramentas excluídas do export. Nenhum alvo/guarda da suíte foi alterado e
nenhum defeito anterior foi removido. O catálogo não foi reinjetado localmente
nesta etapa de propostas; o verde oficial da base é separado destas provas.

## Limites

A régua de glyphs da `131` continua com seus limites; o retângulo de uma
ação não prova gesto, conforto ou contraste em todos os estados do jogo.
Esta etapa fotografa a rolagem pelo valor da barra. Não mede arrastar com
o dedo sobre cartões acionáveis nem prova que o gesto deixa de atracar ou
liberar um barco. Isso precisa ser exercitado antes da integração funcional.
Não houve aceite ou teste físico no telefone.

Não cobre ainda todas as telas da §3 do recorte, atualização dinâmica do
leiaute, mudança de modo sem remontar, foco, posição de leitura e persistência
independente do RB6. A bancada é estática; não deve ser publicada como jogo.
Não muda Main.tscn, cartões de produção, tema, MataNoMapa, arte ou catálogo.
Não acrescenta guarda à suíte nem enfraquece as provas existentes.

Depois do aceite concreto de tamanho/acomodação, a etapa funcional terá de
tratar interação, cobertura global e convivência no disco conforme o recorte
de 19/10. A autorização desta etapa não foi tomada como aceite daquelas.
