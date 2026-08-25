# BR Port — Estado do Projeto

> Resumo de onde o projeto está. Serve para retomar o trabalho numa conversa
> nova sem precisar reexplicar tudo.
>
> **Última atualização:** 25/08/2026 (medição de balanceamento + kit do Bloco 3)

---

## Onde estamos no roadmap

**Fase 4 — Produção do Vertical Slice**, dentro dela o **Bloco 2 (loop core com
placeholder)**, que está **entregue e jogável**.

As Fases 1–3 já foram concluídas antes: o protótipo HTML de diagnóstico foi
jogado e aprovado (Playtest V3 ✅ GO) e o **GDD 7 está congelado** como fonte da
verdade (`docs/design/BR_Port_GDD_V7.jsx`).

Próximo passo previsto no plano de produção: **Bloco 3 — marco intermediário**
(jogar bastante, entregar para 1 pessoa de confiança testar sem instrução, e
decidir se o loop está pronto para receber arte final).

O Bloco 3 **já está começado**: a parte medível foi feita (ver a seção de
balanceamento abaixo) e o roteiro do playtest está pronto em
`docs/BLOCO3_MARCO_INTERMEDIARIO.md`. Falta a parte humana — jogar e observar
alguém jogando — e registrar a decisão.

---

## O que existe hoje

| Onde | O que é |
|---|---|
| `brport_vs/` | Projeto Godot 4.2+ (GDScript) — o jogo |
| `brport_vs/autoload/GameState.gd` | Toda a lógica e os números do jogo |
| `brport_vs/tests/run_tests.gd` | 19 asserções de regressão |
| `brport_vs/tools/simular_balanceamento.gd` | Simulador — roda N partidas com 3 perfis de jogador e mede a dificuldade |
| `brport_vs/COMO_RODAR.md` | Passo a passo para abrir no Godot (Windows) |
| `docs/BLOCO3_MARCO_INTERMEDIARIO.md` | Medição do balanceamento + roteiro do playtest + onde registrar a decisão |
| `docs/design/` | GDD 7, Roadmap, Plano de Produção, guias, Validation Guide |
| `index.html` (raiz) | O protótipo HTML original, já validado |

### Sistemas que funcionam
- Turno diário com botão "Avançar dia" (sem relógio real)
- Drag-and-drop de trabalhadores para as docas
- Economia: caixa, receita por barco, renda do píer, custos semanais
- Reputação Comercial (0–100, 5 faixas qualitativas)
- Contra-oferta do Arlindo (3 presets + mood face do cliente)
- Parcela única de R$ 8.000 ao Sr. Ribeiro, vencendo na semana 4
- Upgrade único (ampliar píer: +1 doca, +1 trabalhador)
- Autosave local a cada turno

### O que é placeholder de propósito
**Toda a arte** — a interface é montada por código com retângulos coloridos.
Isso é intencional: arte final é o **Bloco 4**. Áudio, Diário do Porto, cena
narrativa de fim de Fase 1 e a lista "VS — OUT" do GDD também ficam para depois.

---

## Pendência conhecida: balanceamento

**Correção de rumo:** a leitura anterior ("provavelmente fácil demais, ~63% de
vitória") estava errada. Aqueles 63% vinham da suíte de testes, que joga
**perfeito** — e com 40 partidas a margem de erro é de ±15 pontos.

Medido direito, com 3.000 partidas por perfil de jogador:

| Perfil | Vitórias | Caixa no vencimento (mediana) |
|---|---|---|
| Joga perfeito | 58,5% | R$ 8.188 (parcela: R$ 8.000) |
| Joga mediano | 7,2% | R$ 6.634 |
| Joga mal | 0,1% | R$ 4.689 |

Ou seja: **não está fácil — está no fio da navalha.** Quem joga certo ganha por
2% de folga, decidida pelo sorteio dos barcos; quem joga como um estreante não
ganha nunca. Além disso, ninguém quebra por caixa (o píer sozinho paga os
custos) e a reputação não afeta nada mecanicamente — igualar a oferta do Arlindo
é sempre a jogada certa, então aquela tela ainda não é uma decisão.

A análise completa, as tabelas de sensibilidade (o que acontece mudando a
parcela ou a chegada de barcos) e o roteiro do playtest estão em
**`docs/BLOCO3_MARCO_INTERMEDIARIO.md`**.

**Nenhum número do jogo foi alterado** — essa decisão é do Bloco 3, depois de
jogar e observar alguém jogando. Se for ajustar: todas as constantes estão no
topo de `brport_vs/autoload/GameState.gd`, marcadas com `# TUNING:`, e dá para
medir o efeito de cada mudança com o simulador antes de fechar.

Uma ressalva registrada: os valores de barco hoje (R$240–760) estão
**acima** do que o GDD define para a Fase 1 (R$80–300). Foi necessário para a
parcela de R$8.000 caber em 4 semanas sem mexer no valor dela — e, pela medição
acima, mesmo assim ela **quase não cabe**. Vale reabrir a pergunta ao contrário:
talvez o número a mexer seja a parcela, não o valor do barco.

---

## Histórico de correções relevantes

O primeiro playtest humano (25/08) encontrou dois bugs sérios, ambos corrigidos:

1. **Jogo travava** depois de aceitar a oferta do rival — o botão "Avançar dia"
   ficava desabilitado para sempre. Era ordem de emissão de sinais; hoje toda
   troca de fase passa por um ponto único que avisa a interface.
2. **O mesmo trabalhador podia ser alocado em várias docas** ao mesmo tempo,
   multiplicando receita de graça. Hoje é bloqueado, e tocar na doca libera o
   trabalhador (para desfazer arrasto errado).

Lição registrada: a verificação automatizada agora **instancia a cena real** e
checa o estado dos botões. A versão anterior só chamava a lógica direto, e por
isso não pegou nenhum dos dois.

Segunda lição, do dia 25/08: **um harness que joga perfeito não mede
dificuldade.** A taxa de vitória de ~63% que constava aqui vinha da suíte de
testes jogando sem errar uma vez sequer — o que descrevia o teto do jogo, não a
experiência de quem pega no controle pela primeira vez. Medir dificuldade exige
simular também o jogador que erra, e com amostra grande o bastante para a
margem de erro não engolir a conclusão. Daí o
`tools/simular_balanceamento.gd`.

---

## Como retomar numa conversa nova

Comece a conversa apontando este arquivo. Algo como:

> "Continuando o BR Port — leia `docs/ESTADO_DO_PROJETO.md`. Quero trabalhar em X."

Para rodar os testes antes e depois de mexer no código:

```
Godot_v4.x_win64.exe --headless --path brport_vs --script res://tests/run_tests.gd
```

Espera-se `TODOS OS TESTES PASSARAM` e código de saída 0.

E para medir o efeito de qualquer mudança de balanceamento (800 partidas por
perfil de jogador, ~10 segundos):

```
Godot_v4.x_win64.exe --headless --path brport_vs --script res://tools/simular_balanceamento.gd -- 800
```
