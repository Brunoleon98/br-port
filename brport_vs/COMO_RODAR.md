# BR Port VS — Como abrir e rodar no Godot (Windows)

Passo a passo para abrir o loop core do Vertical Slice no seu PC.
Não precisa saber programar nem instalar Git.

---

## 1. Baixar o Godot

1. Ir em **https://godotengine.org/download/windows**
2. Baixar o **"Godot Engine"** — a versão **padrão**.
   ⚠️ **NÃO** baixar a versão **".NET"** — aquela é para C#, e este projeto é GDScript.
3. Precisa ser **Godot 4.6 ou mais novo**. (O projeto é validado no **4.6.3**,
   que é a versão que roda no CI a cada push.)

O download é um `.zip` com **um único `.exe` dentro**. Não tem instalador:
descompacta e dá duplo clique no `.exe`. Pode deixar onde quiser (Desktop, Documentos…).

> **Se o Windows reclamar** — "O Windows protegeu o seu computador":
> clicar em **Mais informações → Executar assim mesmo**.
> É o aviso padrão para executável sem assinatura digital paga. O Godot é seguro.

---

## 2. Baixar o código do jogo

Link direto:

```
https://github.com/Brunoleon98/br-port/archive/refs/heads/main.zip
```

Descompactar. Vai aparecer a pasta:

```
br-port-main\
└── brport_vs\          ← ESTA é a pasta do projeto Godot
    ├── project.godot
    ├── autoload\
    ├── scenes\
    └── scripts\
```

> Se preferir pelo site: github.com/Brunoleon98/br-port → botão verde **Code**
> → **Download ZIP**.

---

## 3. Importar no Godot

1. Abrir o `.exe` do Godot → aparece o **Gerenciador de Projetos**.
2. Clicar em **"Importar"**.
3. Navegar até a pasta **`brport_vs`** e selecionar o arquivo **`project.godot`**.
4. Clicar em **"Importar e Editar"**.

---

## 4. Rodar

Apertar **F5** (ou o botão **▶** no canto superior direito).

### Dois avisos para não assustar

**A primeira abertura demora.** O Godot importa a arte toda (mapa, props,
ícones) antes de conseguir abrir a cena. É uma vez só — depois fica em cache
na pasta `.godot`.

**A janela abre alta e estreita** (720×1280, retrato). É um jogo mobile, então a
janela tem formato de celular mesmo.

---

## 5. Como jogar

| Ação | Como fazer |
|---|---|
| Alocar trabalhador | **Tocar** no trabalhador livre e depois no cartão da doca — ou **arrastar**, para o cartão ou para o píer no mapa |
| Passar o dia | Botão **▶ AVANÇAR DIA** — processa a docagem e fatura |
| Oferta do rival | Quando o Arlindo aparecer: **Igualar** / **Manter preço** / **Recusar** |
| Construir no porto | Botão **Construir** — píer 2 e 3, armazém, pátio e escritório |
| Pagar a dívida | No fim da **semana 4** vem a cobrança da parcela de R$ 8.000 |

Regras rápidas do loop:
- Barco **sem trabalhador** alocado vai embora no fim do turno → você perde a receita e cai reputação.
- Trabalhador fica **ocupado** enquanto opera (barco grande leva 2 turnos).
- Toda semana: entra a renda do píer (+R$240) e saem os custos (salários + manutenção).

---

## 6. Recomeçar do zero

O jogo **salva sozinho** a cada turno — ao reabrir, ele volta de onde parou.

Para começar uma partida nova: **⏸ Pausar → Novo jogo**.

O save fica em `%APPDATA%\Godot\app_userdata\BR Port VS\`
(cole isso na barra do Explorer). Dá para apagar a pasta na mão se precisar.

---

## 7. Se der problema

| Sintoma | O que fazer |
|---|---|
| "Projeto criado em outra versão do Godot" | Confirmar que baixou **Godot 4.6.3** (ou mais novo), não 3.x. O projeto está marcado como 4.6 — abrir numa 4.x anterior mostra esse aviso. |
| Tela preta ao rodar | Conferir em **Projeto → Configurações do Projeto → Application → Run** se a cena principal é `res://scenes/Main.tscn`. |
| Erro de script | Ler o painel **"Saída"** (Output), na parte de baixo do editor — a mensagem inteira costuma dizer exatamente o que faltou. |
| Não consigo arrastar o trabalhador | O trabalhador precisa estar **verde** (livre). Cinza = ocupado. E a doca precisa ter barco sem trabalhador — quando aceita, o píer no mapa acende. |

---

## Testes automáticos (opcional)

Existe um conjunto de testes em `tests/run_tests.gd` que abre a cena real e
confere o loop (oferta do rival, alocação de trabalhador, upgrade, 40 partidas
completas). Não é necessário para jogar — serve para pegar regressão quando o
código mudar. Para rodar pela linha de comando:

```
Godot_v4.6.3-stable_win64.exe --headless --path . --script res://tests/run_tests.gd
```

Termina com `TODOS OS TESTES PASSARAM` (código de saída 0) ou lista o que falhou.

> **Num clone novo, importe a arte antes.** Sem a pasta `.godot` o Godot não
> resolve as texturas e a suíte falha com uma pilha de
> `referenced non-existent resource` que não tem nada a ver com o teste:
>
> ```
> Godot --headless --path . --import
> ```
>
> É preciso uma vez por clone. Em Linux sem monitor isto funciona igual — o
> `--import` não precisa de tela, só a captura precisa (ver abaixo).

---

## Onde mexer no visual

A interface **não é mais construída por código**. Ela mora em dois lugares:

| Onde | O que é |
|---|---|
| `ui/tema_brport.tres` | **Todo o estilo** — cores, cantos, fontes, botões, e os estilos de doca e trabalhador. Mudar aqui muda o jogo inteiro. |
| `scenes/*.tscn` | A árvore de nós de cada tela. Abre no editor e dá para arrastar. |

A paleta é a do protótipo HTML validado (navy `#1c3454` sobre creme `#f0f6ff`).
Os scripts só alimentam os nós com texto e trocam qual estilo do tema está
valendo — nenhum deles pinta cor na mão.

**Isso é o que torna o Bloco 4 barato:** trocar retângulo por sprite é editar
cena e tema, não reescrever script.

Para ver a tela sem abrir o editor:

```
Godot_v4.6.3-stable_win64.exe --path . --resolution 720x1280 --script res://tools/capturar_tela.gd -- 10 tela.png
```

O `10` é quantos turnos jogar antes da foto (0 = tela inicial). No Linux sem
monitor, prefixe com `xvfb-run -a` e acrescente `--rendering-driver opengl3`.

---

## Onde mexer no balanceamento

Todos os números do jogo estão em **`autoload/GameState.gd`**, no topo do arquivo,
marcados com o comentário `# TUNING:`. Dá para mudar valor de barco, custo de
salário, valor da parcela etc. sem tocar em nenhuma lógica.

Para **medir** o efeito de uma mudança em vez de chutar, existe um simulador que
roda centenas de partidas com três perfis de jogador (quem joga perfeito, quem
joga mediano e quem joga mal) e imprime a taxa de vitória de cada um:

```
Godot_v4.6.3-stable_win64.exe --headless --path . --script res://tools/simular_balanceamento.gd -- 800
```

O jeito de usar é: rodar, anotar os números, mudar **uma** constante `# TUNING:`,
rodar de novo com a mesma semente e comparar. Detalhes e a leitura dos resultados
de hoje estão em `../docs/BLOCO3_MARCO_INTERMEDIARIO.md`.

---

*BR Port · Bloco 2 (loop core com placeholder) · arte final vem no Bloco 4*
