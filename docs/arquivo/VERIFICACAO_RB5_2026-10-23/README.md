# Verificação local do RB5 — 23/10/2026

Bruno aprovou três colunas com +25% na bancada da decisão `134`. A decisão
`135` registra a integração: Padrão e Maior nos Ajustes do início e da pausa,
leitura e foco preservados, preferências de texto e movimento independentes.
No fechamento local ainda não havia push ou PR desta entrega. O envio posterior
autorizado por Bruno está em [PUBLICACAO.md](PUBLICACAO.md); o recibo abaixo
continua retratando as provas locais anteriores ao PR.

## Fonte e identidade

Base: main `ed2c770b105fecb4c9750e5e0fca64735fae97e1`. Branch local:
`codex/rb5-texto-global`, com a proposta `bf9be01` preservada na branch da
bancada. O recibo sela a fonte das fotos e o catálogo; as provas se referem
à integração local, não ao CI ou ao Pages da main.

O Web local combina o PCK exportado desta fonte com o runtime oficial
Godot 4.6.3 do pacote da main. A identidade foi gerada antes do export:
`bf9be019739110d24e94398dde7b18bf0e6a1da1`, árvore modificada. Isso identifica
a exportação da fonte de trabalho, não um commit publicado nem uma junção
de PR. APK e CI remoto desta integração não foram executados.

## Resultados

- Seis suítes com seus marcadores finais, sem SCRIPT ERROR.
- 84 percursos de captura no Maior, com 86 PNGs reais 720×1280 (duas imagens
  temporais adicionais para o movimento): todo o percurso de interface da bateria,
  inclusive Meu Porto, diagnóstico, ajuda, celular e os estados de decisão.
  Cobertura por painel/tempo/retrato confirmada pelo conferidor.
- Padrão: inicial, HUD e celular idênticos ao byte às capturas da main.
- 158 mutantes e todos os 158 pares suíte/rótulo confirmados; bases verdes
  antes e depois, arquivos selados restaurados aos mesmos bytes.
  Os 132 IDs anteriores permanecem: 128 entradas idênticas e quatro contextos
  de gravação de movimento adaptados para conservar a preferência de texto.
- Sentinelas dos seis arquivos do jogador intactas nas suítes, capturas e
  mutantes. Todos os perfis foram isolados.
- Chromium 393×852 com toque: as quatro combinações Padrão/Maior × movimento
  completo/reduzido foram gravadas, recarregadas e vistas selecionadas nos
  controles. Um cais nomeado foi iniciado pelo jogo; save e registro
  conservaram bytes e timestamp durante os Ajustes e reinícios. O áudio
  permaneceu ausente, sem criação indevida. Nenhum armazenamento do navegador
  do jogador foi apagado.

O console Web emite um aviso `can_process` ao abrir a nova partida. O mesmo
aviso, na mesma etapa, foi reproduzido com o pacote oficial da main. Não houve
SCRIPT ERROR ou backtrace GDScript na prova final. A GUI nativa prova arrasto e toque sobre os cartões. No Web, um arrasto por
toque também moveu a barra do porto e preservou save e registro, depois de
resolver a proposta pendente no perfil de teste. As imagens antes/depois
foram inspecionadas. Não substitui o teste físico no telefone.

O resumo mecânico está em [recibo.json](recibo.json). Ele omite caminhos de
perfis locais. Logs, 86 PNGs e passagens de desenvolvimento ficam no acervo
privado `.evidencias/rb5-integracao/2026-10-22/`, sem promessa de montagem em
outra sessão. Passagens anteriores, inclusive falhas, não foram promovidas
como prova da fonte final.

## Fotos representativas

| Foto | O que conferir |
|---|---|
| [Porto](inicio.png) | Três colunas, indicação de rolagem e ações fixas |
| [Ajustes](ajustes.png) | Seleção de texto, exemplo e retorno |
| [Construir](construir_inicio.png) | Preços, impedimentos e ação legível |
| [Celular](menu.png) | Aparelho, papel de parede e apps em duas colunas |
| [Meu Porto](retomada_fase2.png) | Consulta com leitura e botões visíveis |
| [Web](ajustes-web.png) | Maior em um viewport móvel do Chromium |
| [Porto antes](02-porto-antes-web.png) / [depois](03-porto-depois-web.png) | Arrasto por toque com a barra deslocada e a partida preservada |

## Preservação e continuação

GameState, save/SAVE_VERSION, mapa/Mata, Main.tscn, project.godot e o fundo v3
continuam nos mesmos bytes da main. A v3 mantém SHA256
`c8dd35c73b11a13da9d3f773ba916cce10b9307c8d7d1addb79faf9571e7ec6f`.
A bancada, branches, backup refs e acervos anteriores foram preservados.

Publicação desta entrega e teste no telefone continuam pendentes. A consulta
remota confirmou main `ed2c770`, 274 refs (127 heads e 147 refs de PR) e
nenhum PR aberto. O fetch normal
ficou indisponível neste ambiente; todas as 127 referências locais foram
comparadas com o conector GitHub e coincidem. Não foi usado force, push para
main/Claude ou merge pelo Codex.
