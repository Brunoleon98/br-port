# Fundo da inicial — verificação de 22/10/2026

Base `0cd4ca3646fb86b0c8fdda555f2199f51138bc9a`, #146 mesclado por Bruno.
Branch local `codex/fundo-inicial-v3`; sem publicação solicitada ou novo PR.
O verde da base não aprova esta implementação.

## Aceite e identidade

A foto antiga de runtime não estava montada neste ambiente. Recriada com
Godot 4.6.3 em cópia isolada da base, trocando só a textura do nó Fundo na
ferramenta de captura. Bruno respondeu: “Aprovo esta v3 para a tela inicial”.
Navio inteiro acima do cartão, faixa de água e título legível; quatro botões
nas posições originais. Nenhuma regeneração de arte.

Fonte original RGB opaca 941×1672, inferior aos 1080 px do briefing antigo.
`art_lab/tela_inicial/v3/fundo.png` e a cópia de produção
`brport_vs/art/tela_inicial/fundo_inicial.png` têm SHA256
`c8dd35c73b11a13da9d3f773ba916cce10b9307c8d7d1addb79faf9571e7ec6f`.
O conferidor genérico volta a acusar xadrez/sem alfa: classificação inadequada
para este fundo opaco, já registrada na v3. Inspeção visual sem xadrez.

`FUNDO_INICIAL` é exclusivo da inicial; `FUNDO` e o consumidor do celular
permanecem no degradê. Nenhuma posição, save, preferência, mapa ou logo mudou.

## Guardas e execução

D48 em `tests/casos_fundo_inicial.gd`, chamado pelo teste de design com
bandeira final. Lê a textura no nó Fundo da inicial montada e no nó
PapelDeParede de um celular real. A identidade da imagem é independente
da constante sob teste; não mede gosto ou composição automaticamente.

A exploração dos dois defeitos novos passou com base verde antes/depois:

| Defeito | Reprovação observada no teste de design |
|---|---|
| `inicio-fundo-provisorio` | D48: inicial desenha a fonte v3 aceita |
| `inicio-fundo-vaza-celular` | D48: celular conserva o degrade |

**MUTANTES OK:** 132 ids e os 132 pares suíte/rótulo confirmados na
reinjeção real, bases verdes antes/depois nas cinco suítes consumidoras.
As 130 entradas anteriores permanecem idênticas. O validador de assets
também passou, completando as seis suítes com seus marcadores finais, sem
SCRIPT ERROR. Os 1.649 arquivos selados voltaram aos mesmos bytes.

Quatro capturas finais reais 720×1280 foram geradas e inspecionadas:
inicial com e sem partida, Configurações e celular. A inicial com partida
é idêntica ao PNG da prévia aceita. Navio acima do cartão, água livre e
título legível nos dois estados; Continuar inativo sem partida. O celular
conserva o degradê. Logs com marcador, sem SCRIPT ERROR ou GDScript backtrace.
Sentinela final intacta: seis arquivos byte a byte.

A chamada inicial para as provas finais foi interrompida sem gerar logs;
na retomada, o ambiente já não tinha a cópia temporária nem o servidor
gráfico. Eles foram recriados, sem repetir o catálogo concluído.

## Ambiente e acervo

Sem xvfb-run instalado; Xorg com driver dummy já disponível forneceu tela
virtual. Capturas reais com OpenGL3, semente da ferramenta e FPS 60.
Perfil de ferramentas isolado em /tmp; sentinela plantada nesse perfil
antes de executar Godot, sem abrir os dados reais do jogador.

Acervo local `.evidencias/fundo-inicial-v3/2026-10-22/`: foto apresentada,
exploração, catálogo completo, suítes e capturas finais. Não contém o acervo
antigo de início/Configurações nem RB5, que não veio montado; não se afirma
ter recuperado os arquivos ou refs de backup de outra sessão.
Preservar todos os acervos disponíveis e as candidatas originais.

## CI pós-merge do #146

Consultas separadas do trabalho local: runs Testes `39717302846` e Captura
`39717302825`, ambos sobre `0cd4ca3`. Captura concluiu success; Godot
headless e export APK/Web passaram. O job Publicar no Pages `119625011673`
concluiu success e seu log informa `https://brunoleon98.github.io/br-port/`.
Logs oficiais confirmam os seis marcadores, DOCS OK, sentinelas intactas,
COBERTURA OK e BUILD EXPORTADO CONFERIDO para a base. Testes e Captura pós-merge concluíram success na consulta final. O job de
mutantes também concluiu success; seu log confirma MUTANTES OK para os
130 defeitos da base e sentinela intacta.
A publicação refere-se ao #146, ainda com o degradê na inicial.
