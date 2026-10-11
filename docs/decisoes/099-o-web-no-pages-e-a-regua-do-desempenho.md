# 099 — O build Web vai ao Pages pela main verde, e o desempenho mede-se por chamada

**11/10/2026.** Base `f6a2cf5` (o PR #122, o M10, fundido); 099 livre
conferida na main pelo GitHub, sem PR aberto do Codex. É o **M11** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), destravado pela resposta do Bruno ao
**D6** (registada na `098`): sim, o CI publica o `brport-web` da `main` no
GitHub Pages, no lugar do protótipo HTML da raiz.

O M11 tinha quatro partes. Três são de máquina e estão aqui; a quarta — o
FPS e o aquecimento no telefone — é do Bruno, com o link que esta entrega põe
no ar.

## 1. O Pages publica a main que passou

No `testes.yml`, o job do export monta o site depois do Web e ANTES do APK:
o `brport-web` à raiz e o protótipo em `/prototipo/` — ele não se apaga, é o
`index.html` da raiz, um arquivo só que puxa as fontes do Google. Sobe pelo
`upload-pages-artifact`, só em push na `main`. O job novo `publicar-pages`
depende das suítes **e** do export: um jogo que reprova num teste não vai para
o link que se manda a quem nunca o viu, e o site que já está no ar fica até a
main voltar a verde. Pull request não publica. Permissões só nesse job
(`pages: write`, `id-token: write`); `concurrency` sem cancelar, para dois
pushes seguidos publicarem por ordem.

⚠️ **Precisa de uma configuração que só o Bruno muda:** Settings → Pages →
Build and deployment → Source = **«GitHub Actions»**. Com a fonte antiga o
job reprova na main, e o vermelho é o aviso.

**Prova, aqui no contêiner** — o export Web corre com os templates, e bastam
os `web_*` do `.tpz` (85 MB dos 815):

- servido por `python3 -m http.server`, que não manda cabeçalho nenhum (como o
  Pages, que não deixa pôr COOP/COEP), o build abre no Chromium sem cabeça
  (Playwright, WebGL por SwiftShader) com `crossOriginIsolated` a falso e sem
  `SharedArrayBuffer`, e o motor diz `single-threaded`: é o
  `variant/thread_support=false` do preset. Chega ao menu e, com um toque em
  «Nova partida», ao caderno por cima do mapa;
- as 347 texturas importam-se sem perda (`compress/mode=0`) e nenhuma é
  VRAM comprimida, logo o `vram_texture_compression/for_mobile=false` do
  preset Web não custa nada no navegador do telefone;
- o YAML lê-se, e o `conferir_guardas_ci.py` dá `GUARDAS OK` (os passos novos
  não correm `--script`).

**O que não se prova aqui:** o próprio deploy. Ele corre no primeiro push na
`main` depois de fundido, e só com a fonte trocada.

## 2. A régua do desempenho: `tools/medir_desempenho.gd`

Conta, com o jogo aberto, as chamadas de desenho, os objetos e as
primitivas por quadro, os nós e os tweens vivos, e cronometra o `_process`
de cada script pela CHAMADA DIRETA — com o cabeçalho de N9: sob `xvfb-run` o
`TIME_PROCESS` inclui o desenho por software (86 ms), e em `--headless` o
laço dorme até 6,9 ms com e sem o `Main`. Corre em `xvfb-run`, como a da
VRAM (`049`), e espera `DESEMPENHO MEDIDO`.

**Dois estados**, porque o dia 1 é o porto mais vazio do jogo: a abertura (o
mapa do dia 1, com os nomes dados) e o meio da partida, que é o save de
exemplo da versão corrente (`tests/saves/v14.json`, dia 30). Cada um PROVA
que mede o mapa: com um painel no `Overlay` do `Main`, recusa.

**Calibra-se antes de medir**, como a da VRAM: doze sprites de textura
própria têm de aparecer como doze chamadas a mais (deram 12,0; com a mesma
textura dão 1,0 — o lote junta-os), e uma sonda cujo `_process` espera
200 µs tem de ser lida de volta (200,6–204,9).

| Medido em 11/10, neste contêiner | Abertura (dia 1) | Meio (v14, dia 30) |
|---|---|---|
| Chamadas de desenho por quadro | 273 (271–276) | 469 (467–473) |
| Objetos · primitivas | 607 · 7.385 | 846 · 8.653 |
| Nós · tweens vivos | 225 · 20 | 225 · 20 |
| Script por quadro | 0,014 ms | 0,014 ms |

O script é o `Fauna.gd` ×9 (0,013 ms), o `Main.gd` (0,0008) e o `Audio.gd`
(0,0001): 0,08% de um quadro de 60 FPS. **O que cresce com o porto é o
desenho**, de 273 para 469 chamadas — é esse o número a pôr ao lado do FPS
do telefone. Os nós não mudam: a cena tem as três docas montadas desde o
início, e o porto troca texturas, não nós. Não há limiar: um veredito sem
decisão viva a segurá-lo é política (`gerais.md`). Os 411 / 263 / 0,033 ms
da revisão de 09/10 eram de outro estado, que ela não nomeou, e não se
comparam com estes — é por isso que a régua escreve o estado.

**Seis defeitos, todos recusados com código 1 e sem o marcador**, cada um
aplicado com contagem e desfeito por cópia com o hash conferido, e a base
verde depois:

| # | Defeito | Quem recusou |
|---|---|---|
| 1 | correr em `--headless` | a calibração do desenho (0,0 chamadas) |
| 2 | dividir pelo total de chamadas das rodadas | a sonda (lida a 40,1 µs) |
| 3 | chamar outro método no laço | a sonda (0,1 µs) |
| 4 | a varredura pergunta `is_physics_processing()` | «não achou o `_process` do `Main`» |
| 5 | sem os nomes, o caderno abre | o estado (`TelaNomes.tscn` no `Overlay`) |
| 6 | os sprites de calibração com a mesma textura | a calibração do desenho (1,0) |

**O que a calibração do desenho não vê:** um erro na constante do monitor
dentro da medida, que não partilha código com ela. Ela prova que o contexto
CONTA chamadas, não que a linha que as lê pede a certa.

⚠️ **E O F19 APANHOU A PRIMEIRA VERSÃO.** O laço lia o `_process` por string
(`call`, `has_method`), num receptor que é qualquer nó, e a declaração do F19
(`093`) não o sabe dizer: como «não é membro» reprova, porque o `Main` o
define; como receptor de um alvo, mentiria. A saída é a chamada DIRETA num
destipado, que grita se o nome faltar — o que o F19 protege —, e o filtro
pelo `is_processing()`, que o motor só liga sozinho a quem define o
`_process`. Está no comentário da função.

## 3. As partidas do A7 têm pasta: `playtest/`

Um `.jsonl` por partida real, colado do «Copiar registro da partida» (Pausa
ou tela inicial → Ajustes), com o nome `AAAA-MM-DD_quem_N.jsonl` — `bruno`,
`pessoa-a`… e nunca o nome de quem jogou. O registro já é anónimo pela
`006` (o R5 do `teste_registro` tranca-o); o nome do arquivo é o único sítio
onde a regra depende de quem o escreve, e o `playtest/README.md` di-lo. Lê-se
com `ler_registros.py --pasta playtest`, que com a pasta vazia sai com
código 1.

## O que fica de fora

- **O FPS e o aquecimento no telefone** — do Bruno, pelo link do Pages.
- **A régua no CI.** É sob demanda, como a da VRAM: o runner não é o
  telefone, e sem limiar o número só se lê. Se um dia se quiser o desenho
  por PR, ele é determinístico e cabe na bateria do `captura.yml`.
- **Um `html/custom_html_shell` ou PWA** para o Pages: o padrão do Godot
  abre e chega à partida.
- **A fila parou:** o M9 espera o D1b e o M12 o A8. Volta a frente 5, pelo
  tutorial curto que o Bruno escolheu em 11/10.
