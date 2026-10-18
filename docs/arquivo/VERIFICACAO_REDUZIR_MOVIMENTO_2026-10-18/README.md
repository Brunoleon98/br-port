# Reduzir movimento — reprodução e limites

Recorte RB6 escolhido pelo Bruno, decisão `129`, branch
`codex/reduzir-movimento`, [PR #143](https://github.com/Brunoleon98/br-port/pull/143).
Base `56b3983`, após o merge do #142. Sem merge automático e sem aceite
físico ou visual inferido do CI.

## Comportamento

Ajustes no início e na pausa oferecem a mesma preferência. O botão Voltar e
o Voltar do aparelho devolvem à origem, sem empilhar cópias do painel.
`apresentacao.cfg` pertence ao aparelho, fora dos espaços da partida, e
passa pelo ArmazemLocal. Booleano ausente/inválido mantém movimento padrão;
falha ao gravar é anunciada, com a escolha válida somente na sessão.

O inventário da decisão 129 distingue fundo, transição e operação. Água,
vegetação, boias, luzes e balanço ficam numa pose fixa; fauna mantém pose,
toque e som. Tráfego sem serviço fica oculto; visitas ao berço e ciclos dos
operadores continuam. Pulsos viram realces fixos. Caixa chega diretamente
ao valor final; o ganho permanece legível pelo mesmo tempo, com descarte
independente. A folha reduzida conclui os callbacks da navegação.

Não muda GameState, SAVE_VERSION, serviços, dia, economia, RNG, missão,
meta ou dados da partida. Não usa time_scale. A mata usa somente a API
pública existente, sem editar o WIP visual do Claude nem sua arte/testes.

## Provas reproduzíveis

Godot na versão de `.godot-version`, importado por
`tools/importar_para_ci.py`. As seis suítes e seus marcadores são os de
`.github/workflows/testes.yml`. O T29 vive em
`brport_vs/tests/casos_reduzir_movimento.gd`, com bandeira final. Confere
portas reais dos Ajustes, retorno/duplicação, aplicação imediata e em nós
novos, valores inválidos, falha de escrita, alturas lógicas de tela, realce,
operação, resultado e callbacks. Fotografia de todos os campos da partida,
RNG, bytes/mtime dos arquivos e registro, com destino de save ausente,
denuncia até regravar os mesmos bytes. Somente a preferência pode mudar.

`tools/testar_preferencia_movimento.py --godot "$G"` inicia processos
distintos para escrever/reler true e false, recusa string no lugar de bool
e prova leitura ausente sem criar arquivo. Usa perfil temporário e a
sentinela, agora com seis arquivos, preservando os anteriores.
Uma aplicação mínima, sem `--script`, importa cópias dos dois scripts reais
e inicia processos distintos pelo singleton da UI, no caminho do jogador;
também preserva true/false após reiniciar. Não abre a partida do usuário.

Ferramentas comuns derivam a apresentação padrão; não herdam a escolha de
outra captura. A sonda de persistência usa explicitamente o leitor, e a
captura RB6 aplica o modo solicitado. Não se relaxaram guardas antigas
para aceitar uma bancada montada com outra apresentação.

Os defeitos ficam no catálogo oficial, ids `movimento-*`; as 97 entradas
anteriores continuam. A exploração identifica a guarda de cada defeito;
o job **Defeitos já provados** do HEAD do PR executa o catálogo integrado.
Código de saída sozinho não é evidência: exigir `MUTANTES OK` e os
marcadores das seis suítes, sem SCRIPT ERROR/push_error.

## Comparação temporal e capturas

`capturar_movimento.gd` entra na bateria oficial, com modos normal,
reduzido, Ajustes pelo início/pausa e resultado de serviço. Os pares usam
semente 42, 60 FPS fixos, quadros 30 e 150, intervalo de dois segundos,
janela 720×1280 e recorte do mapa `[0, 62, 720, 782]`. Cada par registra
esses parâmetros, turno, caixa e RNG em JSON. Não avança a partida.

`tools/comparar_movimento.py` exige parâmetros/estado iguais, imagem contra
ela mesma com zero exato, movimento no controle normal e zero pixels
alterados no fundo reduzido. Compara RGB, preservando o recorte real do mapa.
A calibração sintética confirmou zero para a mesma imagem e um para um
pixel alterado; introduzir movimento no par reduzido reprovou a régua.
Isso mede mudança visual, sem afirmar desempenho.

O CI de Captura publica os pares, manifestos, comparação e telas em
**brport-rb6**, separado do artefato completo. Este ambiente não tem xvfb;
as capturas desenhadas são produzidas pelo CI, baixadas pelo conector e
inspecionadas antes de encerrar. O artefato pequeno evita repetir o download
grande do #142. As imagens e os logs locais ficam preservados em
`.evidencias/reduzir-movimento/`; resultados do HEAD constam no PR.

## Colaboração e pendências

Bruno confirmou que o Claude está ativo no visual. WIP `67b2641`, branch
`ccr-d445dbad-nogxh2`: não se editaram MataNoMapa, seus testes, arte nem
geradores. O pré-PR também consulta esse ramo; seu WIP deixou sem alvo os
defeitos `mata-copia-desalinhada` e `mata-contorno-cego`. As provas antigas
permanecem nesta entrega; a frente visual deve adequá-las ao que modificar.

#140/#141/#142 já mesclados; Meu porto agora e diagnóstico não foram
reimplementados. A `127` não recebeu aceite; estradas/detalhes esperam.
Telefone, leitura por pessoa nova, A4 e caderno dependem do Bruno. A `107`
continua local/separada; Safe save failed histórico sem causa isolada.
Nenhuma frente nova foi escolhida por esta entrega.
