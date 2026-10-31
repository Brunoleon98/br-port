# BR Port — a háptica (`149`); a próxima conversa é o casco que rola (A3)

**31/10/2026.** Branch `claude/hopeful-ride-f61g1m`, que arranca da cabeça
do PR #160 (a `148`, branch `claude/sharp-lamport-kf55gf`, `0e39079`), aberto
e acompanhado noutra conversa — como a `148` arrancou da `144`. O PR desta
conversa é o #PR_DESTA, contra a `main`: até o #160 fundir, ele leva também
os cinco commits da `148`.

**Decisão `149` — a T1, o terceiro item do tema animação e toque.** Medido
antes: nenhuma vibração no jogo, nenhuma permissão `VIBRATE`, e no Linux o
`vibrate_handheld()` não faz nada nem se queixa. **A vibração segue a porta
do assentar, e vale para os três momentos: quem a pede é o toque, depois de
o `GameState` aceitar** — o cartão ao largo (atracar, 20 ms), a virada armada
pelo «Avançar dia» (obra pronta, 40 ms), o «Pagar» e o «Quitar agora»
(parcela paga, 40 ms). A virada simples e a segunda chance não vibram; o
movimento reduzido não a cala. «Vibração» nos Ajustes, ao lado do som,
ligada por omissão, fora do save. `permissions/vibrate=true` no preset
Android, e o CI procura-a no manifesto do APK. O D54, o F5 e o F24 provam-no,
com 20 defeitos no catálogo; a linha nova entra no D33, no RB5, no T29 e no
T30.

⚠️ O motor do contraste mede o nó invisível: a linha escondida passou o D33,
e quem a contou foi o RB5 (`.claude/rules/testes-e-guardas.md`, antes de «O
que as suítes executam e não conferem»).

⚠️ O botão desligado premido pelo `pressed.emit()` não é um toque; a
conferência que só ele provava saiu do «Pagar» (`.claude/rules/testes-e-guardas.md`,
logo a seguir, e a `149`).

⚠️ O rótulo declarado tem de ser único sem o dado entre parênteses
(`.claude/rules/testes-e-guardas.md`, «O defeito injetado fica no catálogo»).

⚠️ A permissão Android lê-se no preset e no manifesto do APK, e no Linux o
`vibrate_handheld()` é silencioso (`.claude/rules/plataforma.md`, «Chaves e
export do Godot»).

⚠️ A «Vibração» desligada fica no tom claro do `hover` depois do toque — um
dos irmãos por varrer do rodapé (`.claude/rules/interface.md`, «NO TELEFONE O
"PASSAR POR CIMA" FICA DEPOIS DO TOQUE»).

**Pendente:** o veredito do Bruno no telefone (o APK é o `brport-apk` do CI
do PR desta conversa); o merge do #160 e depois o deste, que são dele.
Escolha desta conversa que ele pode reverter: a segunda chance não vibra.

**A próxima conversa, pela ordem do Bruno:** o casco que rola (A3), com o
desenho na `144`. A guarda nova e os defeitos dela são F6 (Opus); o resto é
receita.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 144 (o desenho dos quatro itens do tema animação e toque), 148
(o A1) e 149 (a T1, a háptica). Confira a main remota, os PRs abertos e o CI
do último merge, e rode python3 tools/conferir_colaboracao.py com o trabalho
commitado (ele lê o HEAD). O PR #160 (a 148) e o #PR_DESTA (a 149, branch
claude/hopeful-ride-f61g1m, que arranca da cabeça do #160) são do Bruno para
fundir: se algum ainda estiver aberto, confira o CI dele, e a branch nova
arranca da main depois deles — se não tiverem fundido, da cabeça do #PR_DESTA,
como a 149 arrancou da 148. Se o Bruno trouxer o veredito da háptica no
telefone, trate-o primeiro (a 149, «O gate»).

O item desta conversa, na ordem que o Bruno escolheu (A1′ → A1 → T1 → A3):
o A3, o casco que rola 1,5°. O barco atracado (Dock._iniciar_balanco(), uma
rotação em paralelo com o subir, 1,7 s, pivô no centro do quadro) e os três
ao largo (Main._animar_ancorados(), pelo MovimentoDeFundo). Atenção, da 144:
desde o A1′ o nó Barco também espelha (flip_h) e tem uma segunda imagem
(BarcoVira); o deslize e a partida põem a rotação a 0, e a BarcoVira roda
com o Barco ou fica a direito. O desenho, a prova e os mutantes estão na 144
(«A3 — o casco que rola 1,5°»).

1. Meça antes: a sonda lê a rotação do Barco e dos ancorados ao longo dos
   quadros (hoje 0), e o custo (medir_desempenho.gd: chamadas, nós, tweens).
2. Implemente com a guarda nova (dentro de ±1,5°, em fase com o subir; com o
   movimento reduzido, 0; o deslize e a partida a 0), o defeito injetado de
   cada pergunta no catálogo (secção nova, ao lado da 149), e a bateria a
   mudar UMA vez, em toda foto com barco.
3. O gate é o vídeo: mostre o casco a rolar, atracado e ao largo, e pergunte
   o veredito sozinho, logo a seguir (a skill /arte, §8).

Depois vêm a esteira, a fumaça e o fundeadouro (a ordem entre os três
pergunta-se). As duas melhorias que a 148 encontrou e o Bruno não pediu
estão escritas lá. A luz, o som e o resto abrem-se quando ele os pedir
(143). Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da
próxima conversa em bloco copiável.
```
