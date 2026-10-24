# Regras gerais — valem em toda sessão

> **Carregam sempre**, como o núcleo do `CLAUDE.md`: não dependem do arquivo
> aberto. São as lições de como uma régua mente e um defeito injetado deixa
> de provar, de como uma edição apaga um arquivo, e de como o git e o
> briefing enganam no arranque. Vieram do `CLAUDE.md` em 10/10, palavra por
> palavra (`docs/decisoes/091`). Lição nova que valha seja qual for o arquivo
> entra aqui; a de um tema, na regra dele.

## Da medição e do defeito injetado (item 7 do fecho)

O item 7 do fecho, no núcleo, é a regra; o que segue é como ela já
falhou de maneiras que valem para qualquer régua. As que só valem para
uma suíte ou uma guarda do Godot estão em `testes-e-guardas.md`.

   ⚠️ **E UM VALOR IMPOSSÍVEL É O MESMO ALARME QUE O ZERO, e mais barato de
   ver.** A irmã da regra do zero em tudo, do outro lado: ali a régua não
   consegue devolver outra coisa; aqui ela devolve uma coisa que não pode
   existir. Em 19/09 a régua da faixa de mensagem relatou **−194** mensagens
   "nunca apresentadas" — uma contagem negativa —, e o sinal apontava para a
   causa: a sonda pendurava-se num funil que tinha deixado de ser único.
   **SONDA PRESA A UM PONTO DE PASSAGEM MORRE QUANDO O PONTO DEIXA DE
   PASSAR TUDO**, e não se queixa; quem mexe no funil vai ver quem estava
   pendurado nele.
   ⚠️ **E `has()` NÃO CONTA DUPLICATAS, no relatório cujo assunto É a
   duplicata.** Na mesma régua, já corrigida, a contagem discordava dela
   própria — 49 pela subtração contra 42 pelo `has()`, porque um texto escrito
   duas vezes e apresentado uma contava por duas vistas. Onde o caso
   interessante é a repetição, a conta é de MULTICONJUNTO. E foi a discordância
   entre os dois métodos que a apanhou: **uma régua que responde à mesma
   pergunta por dois caminhos denuncia-se sozinha.**
   ⚠️ **PERCURSO RESPONDE PELO QUE SE VÊ; ARQUIVO RESPONDE PELO QUE EXISTE.**
   Uma régua que caminha pelo jogo só mede o que o caminho ALCANÇA, e isso não
   se nota porque ela publica um total grande. Medido em 21/09: dos sítios que
   pintam cor à mão, o percurso de 19 estados do `medir_contraste_ui.gd` não
   chega a três — o dia já vivido do calendário (ele abre no dia 1), a estrutura
   já construída (abre com o porto em ruínas) e a doca sob oferta do rival. O
   `COR_PASSADO` que o briefing entregou como CASO DE TESTE nunca esteve nos 214
   textos, e os 5,42:1 dele eram conta à mão. Antes de tratar um inventário em
   runtime como inventário, pergunte que estados ele NÃO monta.
   ⚠️ **E A RÉGUA PRECISA DO MESMO DEFEITO INJETADO QUE O VALIDADOR — e precisa
   mais.** Um validador que nunca reprovou dá um verde de graça; uma régua muda
   dá um NÚMERO, e o número vira a conclusão da sessão. Em 14/09 a medição do
   raster da água devolveu "0,00% dos pixels mudam" — e uma régua que estivesse
   a comparar o arquivo consigo mesmo teria dito exatamente o mesmo. O que
   separa as duas coisas são duas corridas de dois segundos: **o mesmo arquivo
   dos dois lados tem de dar zero EXATO** (deu: Δ máx 0,00, o que prova que ela
   não tem ruído próprio), **e um par que se sabe diferente tem de dar muito**
   (o mapa do pátio deu 5,89% da janela e Δ máx 145). Só depois disso "zero"
   quer dizer zero.
   ⚠️ **E TEMPO COMPARA-SE EMPARELHADO, uma volta de cada.** O mesmo comando de
   geração deu 18,71 s de manhã e 22–23 s à tarde neste contêiner: **20% de
   deriva da máquina**, que é mais do que muita diferença que este projeto mede.
   Duas corridas soltas em horas diferentes comparam a carga, não o código.
   ⚠️ **E RECEITA DERIVADA QUE NÃO CASA NADA DÁ UM VERDE DE GRAÇA.** É a regra
   da amostra vazia com a roupa de um bloco de shell, e mordeu na sessão que a
   escreveu: o `/fechar-sessao` passou a derivar do `testes.yml` os comandos que
   regeram os mapas, o `grep` casou **zero** deles — no workflow eles estão
   partidos por continuações `\` —, nada correu, o `git diff` saiu vazio e isso
   leu-se como sucesso. **Conte o que a derivação achou antes de acreditar no
   silêncio dela** (`docs/decisoes/032`).
   ⚠️ **E NÚMERO PARTIDO POR UMA QUEBRA DE LINHA ESCAPA A TODO `grep` DE
   LINHA.** A prosa deste repositório quebra aos ~79 caracteres, então qualquer
   facto de vários tokens pode ficar a cavalo de duas linhas. Em 18/09 o sétimo
   sítio a repetir as taxas do balanceamento estava escrito `100,0% / 80,2%` +
   `/ 37,3%` — e sobreviveu a uma revisão externa E a uma varredura à mão,
   ambas feitas com `grep -n`. Régua que procura FACTO lê o arquivo inteiro com
   `\s*` a atravessar a quebra; e normalize a grafia, que `100,0%` contra
   `100%` abriu um segundo endereço sem a guarda ver.
   ⚠️ **E CONTAGEM QUE INSTRUI CONFERE-SE; CONTAGEM QUE NARRA FICA.** A regra
   irmã — *"contagem em prosa de lista que cresce tira-se"* — diz o que fazer;
   esta diz onde NÃO fazer. O `grep` por "as cinco suítes" dá dezenas de
   acertos e quase todos são história verdadeira (*"nenhuma das cinco suítes
   lia aquela linha"* descreve o dia em que eram cinco). Corrigi-los é
   reescrever o registo para ficar verde. Antes de trocar um número, pergunte
   se ele manda fazer alguma coisa.
   **E confira que o defeito injetado pegou.** Dois já não pegaram: um usou uma
   variável de ambiente que a sessão já trazia definida, e outro quebrou o
   GDScript de tal jeito que o passo anterior falhou calado e reaproveitou o
   arquivo da corrida antiga. Nos dois casos o validador "passou" sem nunca ter
   visto defeito nenhum — que é pior do que não o ter testado, porque agora há
   confiança.
   **E confira o `$?` do comando certo.** Em 02/09 um defeito injetado reprovou
   como devia e o `$?` deu 0: a corrida acabava em `| tail -3`, e o que se
   estava a medir era o `tail`. Redirecione para arquivo e leia o código de
   saída antes de olhar a saída — num cano, o `$?` é do último elo.
   **E confira que o defeito chegou a quem o havia de ver.** Em 03/09 baixou-se
   o `RUA_RECUO` para reproduzir o pátio estreito e o teste passou: o
   `gerar_mapa_iso.py` escreve as âncoras AO LADO do SVG, e o SVG tinha ido
   para `/tmp`. O teste leu a tabela antiga e nunca soube do defeito. Antes de
   concluir "o validador não pega", confira que o arquivo que ele lê mudou.
   **E confira que a base está LIMPA antes de injetar o defeito seguinte.** No
   mesmo dia, o `git checkout` que devolvia o arquivo entre um defeito e outro
   restaurou a versão anterior ao trabalho inteiro — e os três testes seguintes
   relataram, contentes, a mesma falha herdada. Nenhum deles provou nada. Entre
   um defeito e o próximo, rode o validador uma vez e exija que ele PASSE; e
   guarde o original com `cp`, nunca com `git`, que não sabe o que ainda não foi
   commitado.
   ⚠️ **E A SAÍDA DAS FERRAMENTAS DESTE PROJETO É UM CONTRATO — a mensagem
   nova pode colidir com uma sentinela.** Aqui quem decide aprovação é uma
   STRING na saída e não o código de saída, e de propósito: a linha final de
   cada suíte, `(Tela|Folha) salva em` no `capturar_evidencia.sh`, `=== Leitura
   ===` e `possível travamento` no CI, `FORA` no `projetar_parcelas.py`. Em
   12/09 uma linha NOVA que anunciava uma exclusão legítima dizia "FORA DO
   PORTÃO" e reprovou o projetor inteiro — código 1 a dizer que o modelo não
   calibra, quando ele calibrava. É a regra acima do outro lado: ali a busca
   achava o que não devia num ARQUIVO, aqui numa MENSAGEM que se acabou de
   escrever. Antes de imprimir texto novo numa ferramenta, procure que strings
   alguém procura na saída dela.
   ⚠️ **E UM MARCADOR NOVO PODE CONTER UM VELHO POR DENTRO.** Em 21/09 a régua
   do sinal de áudio ia chamar-se `MEDIDA DE AUDIO OK` — e essa string CONTÉM
   `AUDIO OK`, que é exactamente o que o passo do `teste_audio.gd` procura no
   `testes.yml`. Duas ferramentas diferentes a satisfazer o mesmo `grep`: o
   passo do encanamento passaria a ficar verde com a régua do sinal, e ninguém
   veria. Ela chama-se `SINAL OK`. **Marcador novo confere-se por SUBSTRING
   contra os que já existem**, não por ser um nome diferente.

## Ao corrigir um, varra os irmãos (da seção «Arte»)

  ⚠️ **E AO CORRIGIR UM, VARRA OS IRMÃOS — a lição escrita não anda sozinha
  até eles.** Em 07/09 o pau-de-carga dos cargueiros foi girado para o costado
  porque no plano do mastro ele lia como uma CRUZ, e a armadilha ficou escrita
  ao lado da correção; o pesqueiro, que tem o mesmo mastro com o mesmo pau,
  ficou com a cruz por mais uma sessão inteira, porque ninguém voltou a abrir o
  prop. Correção de leitura fecha-se com um `grep` pela FORMA que a causou, não
  pela peça onde ela apareceu.

## Edição, código e relatório (do «Estilo de código»)

- **`.get(chave, omissão)` num dicionário de configuração transforma erro de
  digitação em número plausível.** Em 02/09 o `Registro` lia
  `ESTRUTURAS[id].get("preco", 0)` — a chave é `custo` — e o relatório dizia,
  sem erro nenhum, que o jogador construía de graça. A mesma linha errada
  estava em dois arquivos. Num dicionário cujas chaves são conhecidas, acesso
  DIRETO: um `id` inexistente tem de rebentar em vez de mentir. E **zero é o
  pior valor de omissão que há, porque se lê como medida** — no mesmo dia, um
  contador por turno que era zerado e nunca incrementado fez o relatório
  afirmar "0 barcos servidos" num porto que atendeu 184.
- **⚠️ FORMATAR PARA O OLHO PODE APAGAR O NÚMERO, e "0." lê-se como zero.**
  Irmã da regra acima — ali o zero de omissão passava por medida; aqui é o
  número de verdade que se perde a caminho do papel. O `gerar_tabela_numeros.py`
  fixava `"%.2f"` e depois fazia `rstrip("0")`: correto para os 0,50 e 0,28 que
  o jogo tinha, e destruidor para o primeiro valor abaixo de 0,005 — o
  `JUROS_POR_TURNO` (0,0025) foi para a tabela como **`0.`**, sem erro nenhum,
  numa ferramenta cujo lema é recusar-se a adivinhar. **Precisão fixa num
  formatador é uma aposta sobre valores que ainda não existem.** As casas saem
  do valor; e a guarda que isto pedia é barata — **releia o que formatou e
  exija que volte ao que era**, senão a tabela perde o número sem uma palavra.
- **⚠️ `open(..., "w")` TRUNCA ANTES DE O CONTEÚDO EXISTIR, e isso vale para
  todo arquivo gerado.** O `main()` do `gerar_mapa_iso.py` tem o comentário
  certo ao lado do SVG — gerar ANTES de abrir, "que trunca de imediato, e um
  erro deixaria o mapa vazio" —, e a tabela de âncoras ao lado NÃO tinha a mesma
  proteção: um `NameError` dentro de `tabela_ancoras()`, chamada de dentro do
  `json.dump()`, deixou o `.json` com **zero bytes** e o commit anterior por
  cima. É a regra "ao corrigir um, VARRA OS IRMÃOS" aplicada a dois `open()` no
  mesmo arquivo.
  ⚠️ **E VALE PARA O SCRIPT DESCARTÁVEL QUE EDITA UM ARQUIVO DO PROJETO.** Em
  14/09 um `io.open(p, "w", newline=...)` com o argumento mal escapado rebentou
  **depois** de truncar, e um arquivo versionado de 253 linhas ficou com ZERO
  bytes — salvo pelo `git checkout` só por já estar commitado. Edição em massa
  monta o texto todo, escreve num temporário e faz `os.replace`; nunca abre o
  original para escrita.
  ⚠️ **E O `os.replace` PERDE O MODO DO ARQUIVO** — é o preço do remédio acima,
  e cobrou-o na mesma tarde: o `capturar_evidencia.sh` reescrito assim ficou
  644, e a bateria morreu com código **126 em 0 s**, que não se parece nada com
  um erro de captura. Ao trocar um arquivo por um temporário, copie o modo
  (`os.chmod(tmp, os.stat(p).st_mode)`) antes do `replace`.
  ⚠️ **E O HEREDOC SEM ASPAS EXECUTA AS CRASES DO TEXTO.** Em 24/09 um
  `python3 - <<EOF` que escrevia um comentário com `` `franzida` `` apagou a
  palavra do arquivo — o shell correu-a como comando, e o único rasto foi um
  `franzida: command not found` no meio da saída. Neste repositório, onde todo
  comentário cita código entre crases, edição por heredoc é `<<'EOF'`; o que
  vier do shell entra por argumento ou por arquivo.
  ⚠️ **E TROCAR O QUE ESTÁ ENTRE DOIS MARCADORES APAGA TUDO O QUE MORA ENTRE
  ELES.** Em 27/09 um `s[:s.index(A)] + novo + s[s.index(B):]` ia substituir
  uma função e levava mais SETE, porque o marcador B vinha quatrocentas linhas
  abaixo do que se supunha. O que salvou foi o script conferir cada troca
  ANTES de escrever (`assert s.count(a) == 1`, e uma falhou): nada foi para o
  disco. Edição por intervalo confere a ORDEM dos dois marcadores e conta,
  depois, as `func` que o arquivo tem (`068`).
- **⚠️ QUEM LÊ UM RESULTADO DE UMA LISTA QUE CRESCE LÊ POR IDENTIDADE, NUNCA
  POR ÍNDICE.** A conclusão do simulador tirava o "jogar mal" de
  `resultados[size - 1]`, o que era o Descuidado enquanto os perfis eram três;
  com o Antecipado no fim (12/09) passou a ser ele, e a Leitura publicou 80%
  onde a tabela, duas linhas acima, media 37,3% — com os dois vereditos que
  dependem do número a dispararem ao contrário do que ela mede. Não dá erro
  nenhum, e o índice continua válido. **Índice é posição; papel é identidade**,
  e num `Array` de resultados só a segunda sobrevive à lista crescer ou a ser
  reordenada. Recuse identidade ausente E duplicada: escolher o primeiro de dois
  homónimos é decidir por posição outra vez. E a identidade não se inventa —
  aqui é o NOME, porque o despejo JSON e o `projetar_parcelas.py` já o usavam
  (`docs/decisoes/030`).
  ⚠️ **E VEREDITO NUM RELATÓRIO É POLÍTICA, e não cai quando a decisão que o
  sustentava é substituída.** No mesmo arquivo, *"o ERRO NÃO CUSTA, é este o
  sintoma de 'fácil demais'"* acima de 50% sobreviveu quinze dias à `005`, que
  substituiu a fantasia de sobrevivência por *"a decisão errada custa TEMPO e
  OPORTUNIDADE, não a partida"* — e nenhum limiar novo foi escrito para o lugar
  do velho. É a irmã de "número em pixel escrito à mão envelhece calado", com um
  JULGAMENTO em vez de um número, e é pior: o número errado lê-se como número,
  o veredito errado lê-se como conclusão. Limiar sem decisão viva a segurá-lo
  sai, e no lugar fica a descrição factual.
  ⚠️ **E CONCLUSÃO QUE VIVE DENTRO DE QUEM A PRODUZ NÃO SE PROVA.** A razão de
  nenhuma das seis suítes poder ter apanhado aquilo: a frase morava num
  `SceneTree` que roda 4 perfis × 600 partidas antes de chegar a ela, e isso não
  se alimenta com fixture. Separá-la num arquivo de aritmética pura custou umas
  linhas e é o que torna o bloco T7 possível — e ela devolve LINHAS em vez de
  imprimir, porque o que se tem de provar é o TEXTO final: neste projeto a
  formatação já engoliu um número sozinha (o `0.` do `JUROS_POR_TURNO`).

## Git e briefing no arranque (de «O que cabe numa sessão»)

⚠️ **E BURACO PREVISTO NUM BRIEFING PERGUNTA-SE DE QUE FONTE FOI LIDO.** O
briefing de 15/09 avisava que a folha de props ia ficar com cinco famílias sem
âncora — as construções em ruína, os nove cascos, o píer vazio —, e estava
errado: ele lera a TABELA de âncoras, onde eles de facto não estão, e a CENA
responde por 50 dos 51 props, porque prop alternativo partilha o NÓ que o jogo
troca. Meia sessão estava desenhada à volta de um remendo que não fazia falta.
Um briefing é a previsão de quem já fechou a conversa: antes de herdar o buraco
que ele anuncia, **pergunte a que fonte ele o perguntou, e pergunte à outra**.

⚠️ **E `git diff --stat` NOMEIA O ARQUIVO, NUNCA O QUE MUDOU DENTRO DELE.**
Este projeto descreve diffs arquivo a arquivo — em decisão, em briefing e em
corpo de PR —, e a lista de nomes convida a inventar o motivo de cada um. Em
22/09 escrevi que o `Main.gd` era «follow-through» da leva de cor do cartão da
doca: eram **duas referências em COMENTÁRIO**, de `_estilo()` para `refresh()`,
porque aquela função se dissolveu. O `--stat` tinha-me dado o nome e eu supus o
resto. **Antes de escrever o que um arquivo mudou, abra o diff DELE** — e vale
o dobro quando o texto vai para um registo público, que é onde a suposição
passa a parecer facto.

⚠️ **E `git fetch origin A B` NÃO ATUALIZA O `A` SE O `B` NÃO EXISTIR.** Ele
aborta com `fatal: couldn't find remote ref B` e **código 128**, e nenhum dos
dois refs se mexe — reproduzido em 21/09. O natural, ao abrir sessão, é
perguntar pela `main` e pela branch designada na mesma linha; se a branch já
foi apagada depois do PR fundir, a `main` local fica na fotografia de quando o
contêiner subiu. Medido nesse dia: `origin/main` ficou no PR **#51** enquanto o
GitHub estava no **#62** — 40 commits —, e daí saem duas leituras erradas que
custam caro: `git diff origin/main..HEAD` varre a sessão inteira dos outros, e
`git checkout -B <branch> origin/main` **apaga tudo o que foi fundido nesses
40 commits**. Peça um ref de cada vez, e confirme o HEAD real com o GitHub
antes de reapontar seja o que for.
⚠️ **E ELE FALHA ALTO — quem o cala é o cano.** O `fatal` sai no `stderr` e o
código é 128, mas `git fetch ... | tail -2` devolve **0**, que é o do `tail`.
É a regra do "`$?` do comando certo" a morder na primeira linha da sessão, que
é o pior sítio: tudo o que vem depois herda uma `main` velha.

⚠️ **E PR FUNDIDO NÃO QUER DIZER BRANCH FUNDIDA.** A branch designada deste
projeto reaproveita o nome entre sessões, e a receita de a reiniciar da `main`
depois de um PR fundir é `git checkout -B <nome> origin/main` — que DESCARTA o
que a branch tiver a mais. Em 11/09 isso apanhou um commit fechado e empurrado
DEPOIS de o PR ter sido fundido: ele só sobreviveu por estar no remoto. Antes de
reapontar, pergunte o que fica de fora — `git log --oneline origin/main..HEAD` —
e recupere pelo remoto (`git reset --hard origin/<nome>`) em vez de assumir que
a main tem tudo.

⚠️ **E NÚMERO DE DECISÃO E NOME DE BRIEFING SÃO ESPAÇOS PARTILHADOS ENTRE
AGENTES.** Em 16/10 a `111` e o briefing `15b` saíram repetidos, cada agente a
olhar só para a sua base. O livre conta-se em todos os ramos empurrados
(`tools/conferir_colaboracao.py`), e quem funde em segundo renumera só as
linhas que escreveu (`tools/renumerar_decisao.py`) — nunca por `sed` na
árvore, que apaga as citações do outro (`119`).
⚠️ **E O PRÉ-PR É UMA FOTOGRAFIA: corre outra vez logo antes do push.** Em
17/10 ele saiu limpo às 18:36:24, o Codex empurrou a `125` dele às 18:36:31,
e esta conversa empurrou a sua `125` meia hora depois sem o repetir; quem
renumerou foi ela, para `126` e `127`.

## Ambiente (de «Como rodar»)

**A autorização do Bruno continua valendo dentro do recorte aprovado, inclusive
ao retomar noutra conversa.** Antes de perguntar, leia o pedido, os aceites e
os limites registrados na decisão e na continuidade da entrega.

- Ler o repositório, consultar refs/PRs/CI, preparar a branch, editar, importar,
  rodar testes/capturas isolados, documentar e fazer commits locais são passos
  da tarefa autorizada; não pedem outra confirmação a cada comando.
- Depois de autorizado abrir, publicar ou atualizar um PR, isso cobre fetch,
  push normal para a branch da entrega, criação/atualização desse PR e consulta
  ao CI. Correções e registros da mesma entrega não pedem autorização de novo.
  Outra entrega não herda essa autorização de publicação.
- Aceite concreto de arte não se pergunta outra vez para a mesma versão e
  composição. Consulte o registro; mudança no que foi aceito pede novo aceite.
- Continuam os limites expressos do Bruno: sem merge pelo Codex, force, push
  para main/Claude, descarte de trabalho/dados ou ampliação de escopo. Silêncio,
  seleção predefinida e simples retomada não concedem autorização nova.

**Autorização de tarefa e aprovação técnica da plataforma são diferentes.**
Estas instruções não liberam o sandbox nem garantem permissões técnicas entre
sessões. Prefira conectores e permissões disponíveis. Para Git,
downloads necessários ao Godot e sockets da captura virtual, peça à ferramenta
somente o acesso indispensável, preservando proxy/TLS; não peça ao Bruno para
reaprovar o objetivo já autorizado nem contorne uma recusa da plataforma.

**Bruno também acompanha pelo celular, onde pedidos técnicos podem não
aparecer.** Se a plataforma exigir aprovação, explique no chat a ação exata e
a razão. Se a chamada ficar pendente, informe o bloqueio prontamente e siga
com o que independe dela; não espere em silêncio nem trate a espera
como consentimento. Registre o que foi executado e o que ficou bloqueado.
Trabalho em fundo descreve-se pelo que prova e quanto falta (`137`).

**Literais multilinha no Windows precisam do conteúdo LF do Git.** Medido em
`086`: CRLF no checkout de `Narrativa.gd` impedia o separador `\n\n—\n\n`
de dividir o caderno, causando cinco falhas de design. A mesma base com LF
passou. Conferir o blob e normalizar as quebras locais antes de testar; não
reescrever a peça nem relaxar a guarda para esconder uma diferença do checkout.
Desde 10/10 o `.gitattributes` (`* text=auto eol=lf`) faz isso em todo checkout
novo; uma cópia Windows anterior a ele refaz-se, com tudo commitado, por
`git rm -r --cached -q . && git reset --hard`.

**A pesquisa de referências passa pela BUSCA, não pelas páginas.** O proxy
destas sessões bloqueia Wikipédia, wikis de jogos, Steam, Game Developer,
80.lv, GDC Vault e Game UI Database (medido em 25/09); a busca web funciona e
devolve um resumo com a página. Referência lida por resumo cita-se como pista
de padrão, dizendo que a página não foi lida (`docs/decisoes/063`).
