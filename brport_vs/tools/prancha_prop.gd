extends SceneTree

# ============================================================
# BR Port VS — a PRANCHA de um prop: a versão do jogo ao lado da candidata
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# É a ferramenta de quem ITERA um prop — a IA incluída —, e nasceu do veredito
# do Bruno sobre as três folhas de contato (23/09): «deixar mais útil para a IA
# alterar e fazer os testes que precisa para que os props saiam melhores», com
# referências profissionais. A folha de contato responde "o catálogo inteiro dá
# para olhar?"; a prancha responde "ESTA mudança neste prop melhorou?", e são
# perguntas diferentes (`docs/decisoes/068`).
#
# O que ela mostra, sempre com a versão A (o PNG que está no disco) à esquerda
# e a B (a candidata) à direita, na MESMA janela — a união dos dois desenhos —,
# para que uma diferença de posição se veja em vez de ser alinhada fora:
#
#   1. NO JOGO — a foto do jogo a correr, congelado no momento em que o prop
#      aparece, com a textura trocada no nó que o mostra. É o "aceite é na foto
#      de runtime" do `art_lab/README.md`: os vizinhos, a luz do mapa e o que
#      tapa o quê só existem aqui.
#   2. 1:1 SOBRE O CHÃO — o chão que o mapa pinta debaixo da âncora, como na
#      folha de contato, e ao lado a DIFERENÇA: onde A e B deixam de ser iguais.
#   3. AMPLIADO — os pixels da textura, sem filtro, para o detalhe que a 1:1
#      não se julga (o cachorro tem 10 px).
#   4. SILHUETA · VALOR — a forma chapada a preto e o prop em cinzento sobre o
#      chão em cinzento. São os dois testes que toda referência de prancha de
#      prop repete: a forma lê antes da cor, e o valor separa-se do fundo antes
#      do matiz ajudar.
#   5. ESCALA — o prop entre o trabalhador e o camião, os três pousados na mesma
#      linha de chão, a 1:1. É a nota dos camiões («cuidado com a proporção»):
#      carros e pessoas vão entrar no mapa, e a régua deles já está nele.
#   6. NÚMEROS — o tamanho a 1:1, os pixels opacos, o contraste de Weber da
#      mediana do prop contra cada chão, a folga até à borda do quadro e a
#      distância A↔B da régua 16x16 do `comparar_props.py`. São DESCRITORES, e
#      nenhum decide nada sozinho: a folha de produção do `art_lab` diz-o com
#      todas as letras («métricas nunca substituem essa decisão»).
#
# O log repete as linhas de contexto e de números: quem itera sem abrir a
# imagem lê-as lá.
#
# ⚠️ A E B LEEM-SE DO ARQUIVO, NUNCA DO `load()`. O `load()` devolve o `.ctex`
# de `.godot/imported/`, que é de quando o projeto foi importado: com o prop
# regerado na mesma sessão, a versão A seria a de ONTEM a chamar-se "no disco"
# (`CLAUDE.md`, «teste que lê arte gerada lê o arquivo»). E os dois lados
# entram na foto do jogo pelo MESMO caminho — `ImageTexture` no nó —, senão uma
# diferença de importador passaria por diferença de desenho.
#
# ⚠️ E SEM CANDIDATA, B É A. Não é enfeite: é o controle que a régua pede
# («o mesmo arquivo dos dois lados tem de dar zero EXATO»). Com os dois lados
# iguais a ferramenta EXIGE Δ = 0 e as duas fotos do jogo iguais ao byte, e
# reprova se não der — é a prova de que a comparação não tem ruído próprio.
#
# ⚠️ E O PROP PRECISA DE UM SÍTIO NO JOGO. A partida é semeada e passa por três
# estágios do porto — em ruínas, com duas estruturas e completo —, e a prancha
# fotografa o PRIMEIRO momento em que o prop aparece. Medido em 27/09, 45 dos 59
# aparecem sozinhos em 16 turnos. Os outros (cascos e camiões que o sorteio não
# trouxe) entram NO LUGAR DE UM IRMÃO: um prop da mesma família do jogo, visto
# a aparecer, com o desenho do tamanho mais parecido — e a prancha DIZ que foi
# forçado, porque um contexto inventado que se apresentasse como visto seria a
# folha a mentir sobre o que mediu. O órfão da `SEM_ANCORA` fica sem foto, com
# a razão escrita.
#
# Uso (Linux, sem monitor — precisa de xvfb; o `--fixed-fps 60` torna a foto
# do jogo reprodutível, como na bateria):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --fixed-fps 60 --script res://tools/prancha_prop.gd \
#     -- <saida.png> <prop> [<candidata.png>]
#
# O caminho de iterar um prop do Blender, sem tocar no que o jogo usa:
#   python3 tools/gerar_props_iso.py /tmp/cand <prop>
#   ... prancha_prop.gd -- /tmp/prancha.png <prop> /tmp/cand/<prop>.png
# ============================================================

const SEMENTE := 20260902          # a mesma da bateria de capturas
const FRAMES_POR_TURNO := 40       # o camião e o barco assentam neste tempo
const FRAMES_ATE_ASSENTAR := 8
const FRAMES_DA_TROCA := 3

# Quantas estruturas cada estágio compra e quantos turnos joga nele. Os três
# estágios são os três portos que a bateria já fotografa (inicio, meio,
# completo), e o último é mais longo porque é o único que recebe os navios
# grandes e os camiões deles.
const ESTAGIOS := [
	{"nome": "em ruínas", "comprar": 0, "turnos": 4},
	{"nome": "meio", "comprar": 2, "turnos": 4},
	{"nome": "completo", "comprar": 99, "turnos": 8},
]

# A régua da linha de escala. É uma afirmação sobre QUEM serve de régua, e não
# um número: se um dos dois sair do catálogo, a prancha reprova em vez de
# desenhar a linha sem ele.
const REGUAS := ["trabalhador.png", "caminhao_pescado.png"]

# ⚠️ O ZOOM É EM PIXELS DA TEXTURA, e é por isso que os fatores do JOGO são
# 1,5x, 3x e 4,5x. Desde a alavanca B um prop tem 768 px para 512 de coordenada
# (`docs/decisoes/029`), e num telefone de 1080 é a textura que chega ao ecrã
# pixel a pixel. Ampliar a imagem já reduzida a 512 inventaria pixels que o
# jogador não tem; ampliar a textura por um inteiro mostra os que ele tem.
const AMPLIACAO_MAX := 8        # 12x do jogo: o cachorro tem 10 px
const TEXTURA_POR_TELA := 1.5

# As alturas mínimas e máximas das linhas. A mínima é para o chão LER como chão
# à volta de um prop de 9 px; a máxima do recorte do jogo é para um casco com
# vizinhança não comer a prancha.
const ALT_MIN_LINHA := 60.0
const CTX_ALT_MAX := 300.0
const CTX_ZOOM_MAX := 4
const SV_ALT_MAX := 160.0
const ESC_ALT_MAX := 170.0

const FUNDO := Color(0.09, 0.16, 0.24)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)
const TINTA_AVISO := Color(0.95, 0.75, 0.30)
const SILHUETA := Color(0.06, 0.08, 0.10)
const FUNDO_SILHUETA := Color(0.93, 0.94, 0.95)
const MARCA_DIFERENCA := Color(1.0, 0.25, 0.85)

const MARGEM := 10
const ROTULO := 16
const CABECALHO := 40
const LARG := 720.0
const ALT := 1280.0
const COLUNA := (LARG - 3.0 * MARGEM) / 2.0
const DESENHO_MIN := 19

# Um pixel conta como "mudou" acima disto — o ruído do denoiser do Cycles é de
# ±2/255 (`CLAUDE.md`, «prop não é artefato byte-reprodutível»), e contar esse
# ruído como diferença pintaria a prancha inteira de magenta.
const LIMIAR_PIXEL := 3.0 / 255.0

var GS
var _cat: RefCounted
var _main: Control
var _saida := "user://prancha.png"
var _prop := ""
var _cand_caminho := ""
var _a: Image
var _b: Image
var _iguais := false
var _uniao := Rect2i()
var _chaos: Array = []
var _irmaos: Array = []          # [[png, custo], ...] por preferência

# A máquina de estados. `_fase` diz o que o `_process` está a fazer; a troca
# de textura para as três fotos do jogo é uma sub-fase com o seu contador.
var _fase := "armar"
var _frames := 0
var _estagio := 0
var _turnos := 0
var _contexto := {}              # o melhor contexto fotografado até aqui
var _troca := {}                 # a troca em curso
var _foto: Image = null
var _artes: Array = []
var _tentados := {}              # "png@turno" já tentados, para não girar
var _recusas := 0                # trocas que não chegaram à foto do jogo
var _numeros := {}


func _process(_delta: float) -> bool:
	match _fase:
		"armar":
			if not _armar():
				return true
			_fase = "jogar"
			return false
		"jogar":
			return _jogar()
		"trocar":
			return _trocar()
		"montar":
			if not _montar():
				return true
			_fase = "fotografar"
			_frames = 0
			return false
		"fotografar":
			return _fotografar()
	return false


# ── ARMAR: ler os argumentos, as duas imagens, e pôr a partida de pé ────────

func _armar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		print("FALHOU — uso: -- <saida.png> <prop> [<candidata.png>]")
		quit(1)
		return false
	_saida = args[0]
	_prop = String(args[1]).get_basename().get_file() + ".png"
	GS = root.get_node("GameState")
	_cat = load("res://tools/catalogo_props.gd").new(GS)

	var nomes: Array = _cat.catalogo()
	if not nomes.has(_prop):
		print("FALHOU — '%s' não é um prop de mapa. São: %s"
			% [_prop.get_basename(), ", ".join(nomes.map(func(n): return n.get_basename()))])
		quit(1)
		return false
	for r in REGUAS:
		if not nomes.has(r):
			print("FALHOU — a régua '%s' saiu do catálogo; a linha de escala " % r
				+ "ficaria sem ela. Escolha outra em REGUAS.")
			quit(1)
			return false

	var caminho_a := ProjectSettings.globalize_path("%s/%s" % [_cat.PASTA, _prop])
	_a = _ler(caminho_a)
	_cand_caminho = args[2] if args.size() >= 3 else caminho_a
	_b = _ler(_cand_caminho)
	if _a == null or _b == null:
		print("FALHOU — não consegui ler %s" % (caminho_a if _a == null else _cand_caminho))
		quit(1)
		return false
	_iguais = _cand_caminho == caminho_a \
		or ProjectSettings.globalize_path(_cand_caminho) == caminho_a

	# ⚠️ A CANDIDATA CUMPRE O CONTRATO DO QUADRO, ou não há comparação. O mesmo
	# lado nos dois (768) é o que põe o desenho no mesmo sítio do mapa — um
	# render a 512 sairia 1,5x fora e pareceria um defeito do desenho. E os
	# quatro cantos transparentes são a guarda barata contra o fundo pintado
	# que dois lotes de fora já trouxeram (`conferir_lote_de_arte.py`).
	if _a.get_size() != _b.get_size():
		print("FALHOU — a candidata tem %s e o prop do jogo %s. O quadro é o "
			% [_b.get_size(), _a.get_size()]
			+ "contrato que põe o desenho no sítio: renderize-a no mesmo.")
		quit(1)
		return false
	for canto in [Vector2i.ZERO, Vector2i(_b.get_width() - 1, 0),
			Vector2i(0, _b.get_height() - 1), _b.get_size() - Vector2i.ONE]:
		if _b.get_pixelv(canto).a > 0.0:
			print("FALHOU — a candidata tem o canto %s opaco: o fundo veio " % canto
				+ "pintado. Um prop é desenho sobre transparência.")
			quit(1)
			return false

	var ua := _a.get_used_rect()
	var ub := _b.get_used_rect()
	if ua.size == Vector2i.ZERO or ub.size == Vector2i.ZERO:
		print("FALHOU — %s está vazio." % ("A" if ua.size == Vector2i.ZERO else "B"))
		quit(1)
		return false
	_uniao = ua.merge(ub)

	var r := {"ancoras": {}, "vistas": []}
	_cat.da_cena("res://scenes/Main.tscn", Vector2.ZERO, "./MapaWrap", r)
	var chaos: Dictionary = _cat.chaos([_prop], r)
	_chaos = chaos.get(_prop, [])
	_irmaos = _irmaos_de(r)

	# A PARTIDA: a mesma receita do `capturar_tela.gd` — espaço 1 com os outros
	# vazios, semente ANTES do `new_game()`, nomes dados para a tela de nomes
	# não tapar o mapa, e a oferta do rival resolvida antes de qualquer compra.
	for n in range(2, GS.ESPACOS + 1):
		GS.apagar_espaco(n)
	GS._rng.seed = SEMENTE
	GS.comecar_no_espaco(1)
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(_main)
	return true


## Lê um PNG do disco como RGBA8. `null` se não der.
func _ler(caminho: String) -> Image:
	var img := Image.load_from_file(caminho)
	if img == null or img.is_empty():
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


## Os irmãos que podem emprestar o LUGAR ao prop, por ordem de preferência: os
## da mesma família do jogo (o mesmo nó troca entre eles) e com o mesmo PAPEL
## nela — o eixo do camião, a classe do casco —, o de desenho mais parecido
## primeiro.
##
## ⚠️ O PAPEL É FILTRO, NÃO PREFERÊNCIA. A primeira versão escolhia só pelo
## tamanho do desenho, e medido nos 59 pôs o `caminhao_conteiner_mx` no lugar
## do `caminhao_armazenagem`, que anda no outro eixo: o camião saía
## atravessado na rua e a prancha chamava-lhe contexto. Sem irmão do mesmo
## papel à vista, não há foto — e a prancha reprova, que é melhor do que
## mostrar um estado que o jogo não monta.
func _irmaos_de(r: Dictionary) -> Array:
	var familias: Dictionary = _cat.familias(r["ancoras"])
	var papeis: Dictionary = _cat.papeis()
	var meu := _a.get_used_rect().size
	var out: Array = []
	for slot in familias:
		var nomes: Array = []
		for t in familias[slot]:
			nomes.append((t as Texture2D).resource_path.get_file())
		if not nomes.has(_prop):
			continue
		for t in familias[slot]:
			var n: String = (t as Texture2D).resource_path.get_file()
			if n == _prop or papeis.get(n, "") != papeis.get(_prop, ""):
				continue
			var s := PropIso.imagem(t).get_used_rect().size
			out.append([n, absi(s.x - meu.x) + absi(s.y - meu.y)])
	out.sort_custom(func(x, y): return x[1] < y[1])
	return out


# ── JOGAR: os três estágios do porto, a olhar para o prop a cada turno ──────

func _jogar() -> bool:
	_frames += 1
	if _frames < FRAMES_POR_TURNO:
		return false
	_frames = 0
	# Um painel que o dia abriu (o boletim, uma fala) põe o escurecer por cima
	# do mapa inteiro: fechado ANTES de olhar, que a troca ainda espera frames
	# até à foto. A primeira versão fotografou o camião através dele.
	_fechar_paineis()

	# O próprio prop, à vista: é o contexto verdadeiro, e acaba a procura.
	# ⚠️ CADA TENTATIVA UMA VEZ POR TURNO. Uma troca que não chega à foto (o
	# prop tapado por outro nó) volta aqui com o mesmo nó à vista, e sem esta
	# conta a prancha tentaria o mesmo frame para sempre sem avançar o dia.
	var no := _no_que_mostra(_prop)
	if no != null and not _tentados.has("%s@%d" % [_prop, GS.turn]):
		_comecar_troca(no, _prop)
		return false
	# Um irmão à vista, melhor do que o que já se fotografou: fotografa-se já,
	# que o momento passa, e a partida continua à espera do prop verdadeiro.
	for i in range(_irmaos.size()):
		if _contexto.has("irmao_ordem") and i >= int(_contexto["irmao_ordem"]):
			break
		var outro := _no_que_mostra(String(_irmaos[i][0]))
		if outro != null and not _tentados.has("%s@%d" % [_irmaos[i][0], GS.turn]):
			_comecar_troca(outro, String(_irmaos[i][0]), i)
			return false

	var est: Dictionary = ESTAGIOS[_estagio]
	if _turnos < int(est["turnos"]):
		_avancar()
		_turnos += 1
		return false
	_estagio += 1
	_turnos = 0
	if _estagio >= ESTAGIOS.size():
		_fase = "montar"
		return false
	_comprar(int(ESTAGIOS[_estagio]["comprar"]))
	return false


## O nó VISÍVEL que está a mostrar este PNG agora, ou `null`. Visível quer dizer
## na árvore, com o `modulate` de pé e o desenho dentro da tela — um camião a
## desvanecer no fim do ciclo não é um sítio onde o prop se veja.
func _no_que_mostra(png: String) -> CanvasItem:
	var pilha: Array = [_main]
	while not pilha.is_empty():
		var n: Node = pilha.pop_back()
		for c in n.get_children():
			pilha.append(c)
		if not (n is TextureRect or n is Sprite2D):
			continue
		var tex: Texture2D = n.get("texture")
		if tex == null or tex.resource_path.get_file() != png \
				or not tex.resource_path.begins_with(_cat.PASTA + "/"):
			continue
		var ci := n as CanvasItem
		if not ci.is_visible_in_tree() or ci.modulate.a < 0.9 or ci.self_modulate.a < 0.9:
			continue
		var r := _rect_na_tela(ci, tex.get_size(), PropIso.imagem(tex).get_used_rect())
		if not Rect2(Vector2.ZERO, Vector2(LARG, ALT)).has_point(r.get_center()):
			continue
		return ci
	return null


## Onde o recorte `usado` (em pixel da textura) cai na TELA, para um nó que
## desenha uma textura de lado `lado`. Serve ao `TextureRect` esticado a 512 e
## ao `Sprite2D` da fauna, centrado e com escala — a transformação do nó diz o
## resto, e é por isso que não se soma `offset` de pai em pai aqui (a armadilha
## do `MapaWrap` no `CLAUDE.md`).
func _rect_na_tela(ci: CanvasItem, lado: Vector2, usado: Rect2i) -> Rect2:
	var k := Vector2.ONE
	var origem := Vector2.ZERO
	if ci is TextureRect:
		k = (ci as TextureRect).size / lado
	elif ci is Sprite2D:
		var s := ci as Sprite2D
		origem = s.offset - (lado / 2.0 if s.centered else Vector2.ZERO)
	var t := ci.get_global_transform_with_canvas()
	var cantos := [Vector2(usado.position), Vector2(usado.position.x + usado.size.x, usado.position.y),
		Vector2(usado.position.x, usado.position.y + usado.size.y), Vector2(usado.end)]
	var r := Rect2(t * (origem + (cantos[0] as Vector2) * k), Vector2.ZERO)
	for c in cantos:
		r = r.expand(t * (origem + (c as Vector2) * k))
	return r


func _comprar(ate: int) -> void:
	var ids: Array = GS.ESTRUTURAS.keys()
	var tabela: Dictionary = GS.ESTRUTURAS
	ids.sort_custom(func(x, y): return int(tabela[x]["ordem"]) < int(tabela[y]["ordem"]))
	for eid in ids.slice(0, ate):
		if GS.tem_estrutura(eid):
			continue
		# O caixa vem da tabela de preços, como no `capturar_tela.gd`.
		GS.cash += int(tabela[eid]["custo"])
		if not GS.comprar_estrutura(eid):
			push_error("prancha: nao consegui comprar %s (%s)"
				% [eid, GS.impedimento_estrutura(eid)])


## Um dia, pelo botão do jogador. Os painéis que abram fecham-se todos: a
## prancha quer o MAPA, e um painel por cima taparia exatamente o prop. A oferta
## do rival responde-se como na bateria, e os trabalhadores alocam-se para o
## porto OPERAR — é com ele a operar que os camiões saem para a rua.
func _avancar() -> void:
	_fechar_paineis()
	if GS.phase == "rival_offer":
		GS.negotiate_rival("metade")
		_fechar_paineis()
	if GS.phase != "playing":
		return
	for w in GS.workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) > 0 or GS.worker_dock_index(wid) >= 0:
			continue
		for i in range(GS.docks.size()):
			var doca = GS.docks[i]
			if doca["boat"] == null or doca["worker_id"] != null:
				continue
			if GS.assign_worker(wid, i):
				break
	_main._on_advance_pressed()


func _fechar_paineis() -> void:
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return
	for painel in overlay.get_children():
		overlay.remove_child(painel)
		painel.queue_free()


# ── TROCAR: congelar o jogo e tirar as três fotos (A, B e sem o prop) ────────
#
# ⚠️ CONGELA-SE O `Main` INTEIRO, e não só o nó: o camião anda por tween e o
# `Main` troca-lhe a textura a cada trecho da rota. Com o `process_mode`
# desligado, os tweens presos aos nós param e ninguém reescreve a textura
# entre a foto A e a B — que é o que faz das duas uma comparação.
#
# ⚠️ E A TERCEIRA FOTO É A PROVA, não enfeite. "Esconder a peça muda a foto?"
# é a pergunta que a `049` escolheu para as folhas de contato, e aqui ela diz
# que o prop chegou mesmo à foto do jogo — um nó atrás de outro, ou fora da
# janela do `MapaWrap`, daria zero.

func _comecar_troca(no: CanvasItem, mostra: String, irmao_ordem: int = -1) -> void:
	_main.process_mode = Node.PROCESS_MODE_DISABLED
	_tentados["%s@%d" % [mostra, GS.turn]] = true
	_troca = {
		"no": no, "mostra": mostra, "irmao_ordem": irmao_ordem,
		"textura": no.get("texture"), "passo": 0, "fotos": [],
	}
	no.set("texture", ImageTexture.create_from_image(_a))
	_frames = 0
	_fase = "trocar"


func _trocar() -> bool:
	_frames += 1
	if _frames < FRAMES_DA_TROCA:
		return false
	_frames = 0
	var no: CanvasItem = _troca["no"]
	(_troca["fotos"] as Array).append(root.get_texture().get_image())
	_troca["passo"] = int(_troca["passo"]) + 1
	match int(_troca["passo"]):
		1:
			no.set("texture", ImageTexture.create_from_image(_b))
			return false
		2:
			no.hide()
			return false
	no.show()
	var lado := Vector2(_a.get_size())
	var janela := _rect_na_tela(no, lado, _uniao)
	no.set("texture", _troca["textura"])
	_main.process_mode = Node.PROCESS_MODE_INHERIT

	var fotos: Array = _troca["fotos"]
	var visto_a := PropIso.desenho_na_foto(fotos[0], fotos[2], janela)
	var visto_b := PropIso.desenho_na_foto(fotos[1], fotos[2], janela)
	var natural := int(_troca["irmao_ordem"]) < 0
	if visto_a >= DESENHO_MIN and visto_b >= DESENHO_MIN:
		_contexto = {
			"a": fotos[0], "b": fotos[1], "janela": janela,
			"natural": natural, "mostra": _troca["mostra"],
			"irmao_ordem": _troca["irmao_ordem"],
			"no": String(_main.get_path_to(no)),
			"estagio": String(ESTAGIOS[_estagio]["nome"]), "turno": int(GS.turn),
			"visto": mini(visto_a, visto_b),
		}
		if natural:
			_fase = "montar"
			return false
	else:
		_recusas += 1
		print("Aviso: o nó %s mostrava o prop e esconder a troca mudou só %d px "
			% [_main.get_path_to(no), mini(visto_a, visto_b)]
			+ "— tapado ou fora do mapa; continuo a procurar.")
	_fase = "jogar"
	return false


# ── MONTAR: a prancha ─────────────────────────────────────────────────────────

func _montar() -> bool:
	if _main != null:
		root.remove_child(_main)
		_main.queue_free()
		_main = null

	# ⚠️ PROP COM LUGAR NO JOGO E SEM FOTO DO JOGO REPROVA. A primeira versão
	# escrevia "não apareceu em 16 turnos" e seguia verde — e uma prova do
	# contexto partida (a foto sem o prop igual à foto com ele, por exemplo)
	# poria as 58 pranchas a dizê-lo sem uma queixa. Medido em 27/09, os 58
	# props fora da `SEM_ANCORA` têm todos foto (vistos ou no lugar de um
	# irmão), logo a ausência é defeito e não sorteio. É a conta dos dois lados
	# da folha de contato: o órfão declarado não pode ter foto, e quem não é
	# órfão tem de a ter.
	var orfao: bool = _cat.SEM_ANCORA.has(_prop)
	if _contexto.is_empty() != orfao:
		print(("FALHOU — %s não teve foto do jogo em %d turnos" % [_prop, _turnos_jogados()]
			+ " (%d tentativas recusadas) e não está em SEM_ANCORA." % _recusas)
			if not orfao else
			"FALHOU — %s está em SEM_ANCORA e apareceu no jogo: tire-o da lista." % _prop)
		quit(1)
		return false

	var ta := _dados(_a)
	var tb := _dados(_b)
	var diff := _diferenca(_a, _b)
	var d16 := _distancia16(_a, _b)
	_numeros = {"a": ta, "b": tb, "d16": d16, "mudou": int(diff["mudou"])}

	# ⚠️ OS DOIS LADOS IGUAIS DÃO ZERO EXATO, OU A RÉGUA TEM RUÍDO. É o
	# controle do cabeçalho, feito aqui e não num teste à parte: se a mesma
	# imagem dos dois lados der uma distância, um pixel mudado, ou duas fotos
	# do jogo diferentes, nada do que a prancha diz sobre um par diferente vale.
	if _iguais:
		var fotos_iguais := _contexto.is_empty() \
			or (_contexto["a"] as Image).get_data() == (_contexto["b"] as Image).get_data()
		if d16 != 0.0 or int(diff["mudou"]) != 0 or not fotos_iguais:
			print("FALHOU — A e B são o mesmo arquivo e a régua deu Δ16=%.4f, "
				% d16 + "%d px mudados, fotos do jogo iguais: %s. "
				% [int(diff["mudou"]), fotos_iguais]
				+ "A régua tem ruído próprio; nada do que ela diz vale.")
			quit(1)
			return false

	var camada := CanvasLayer.new()
	camada.layer = 100
	root.add_child(camada)
	var fundo := ColorRect.new()
	fundo.color = FUNDO
	fundo.size = Vector2(LARG, ALT)
	camada.add_child(fundo)

	var y := 4.0
	_texto(camada, "PRANCHA — %s" % _prop.get_basename(), Vector2(MARGEM, y), 15, TINTA)
	y += 20.0
	var b_diz := "B = A (sem candidata)" if _iguais else "B = %s" % _cand_caminho.get_file()
	_texto(camada, "A = art/props/%s (o disco)  ·  %s" % [_prop, b_diz],
		Vector2(MARGEM, y), 11, TINTA_FRACA)
	y = CABECALHO

	# As alturas saem do que a prancha CARREGA, e a ampliação é a maior que
	# cabe no que sobra — a folha que transborda corta em silêncio, e esta
	# reprova em vez de cortar (`folha_frota`, `folha_props`).
	var u := Vector2(_uniao.size) / TEXTURA_POR_TELA          # a janela a 1:1
	var alt_ctx := _altura_contexto()
	var alt_1 := maxf(u.y, ALT_MIN_LINHA)
	var alt_sv := u.y * _zoom_sv(u)
	var esc := _escala_medidas()
	var alt_num := 7.0 * 14.0
	var fixo := CABECALHO + alt_ctx + alt_1 + alt_sv + float(esc["alt"]) + alt_num \
		+ 6.0 * (ROTULO + 2.0) + 4.0 * 6.0 + MARGEM
	if u.x > (LARG - 4.0 * MARGEM) / 3.0:
		print("FALHOU — %s tem %.0f px a 1:1 e a linha do chão dá %.0f por painel."
			% [_prop, u.x, (LARG - 4.0 * MARGEM) / 3.0])
		quit(1)
		return false
	# A AMPLIAÇÃO FICA COM O QUE SOBRA, e é a maior que cabe: é o painel onde
	# o detalhe se julga, e um prop de 9 px merece a página que um casco de
	# 140 não deixa.
	var m := 0
	for f in range(AMPLIACAO_MAX, 0, -1):
		var tam := Vector2(_uniao.size) * float(f)
		if tam.x <= COLUNA and fixo + tam.y <= ALT:
			m = f
			break
	if m == 0:
		print("FALHOU — %s não cabe na prancha nem com a ampliação a 1,5x " % _prop
			+ "(pede %.0f px de altura, a tela tem %.0f)." % [fixo + _uniao.size.y, ALT])
		quit(1)
		return false

	# 1. NO JOGO
	y = _secao(camada, y, _titulo_contexto())
	y = _linha_contexto(camada, y, alt_ctx)
	# 2. 1:1 SOBRE O CHÃO, e a diferença
	y = _secao(camada, y, "1:1 sobre o chão que o mapa pinta debaixo da âncora · "
		+ "e, à direita, onde B deixa de ser A (%d px)" % int(diff["mudou"]))
	y = _linha_chao(camada, y, u, alt_1, diff["imagem"])
	# 3. AMPLIADO
	y = _secao(camada, y, "Ampliado %s do jogo — %d px de textura por pixel, sem filtro"
		% [_fator(float(m) * TEXTURA_POR_TELA), m])
	y = _linha_ampliada(camada, y, m)
	# 4. SILHUETA · VALOR
	y = _secao(camada, y, "Silhueta chapada · valor em cinzento sobre o chão em cinzento (%s)"
		% _fator(_zoom_sv(u)))
	y = _linha_sv(camada, y, u)
	# 5. ESCALA
	y = _secao(camada, y, "Escala %s — trabalhador · prop · camião, com o pé na mesma linha"
		% _fator(float(esc["fator"])))
	y = _linha_escala(camada, y, esc)
	# 6. NÚMEROS
	y = _secao(camada, y, "Números — descritores, não veredito")
	_linha_numeros(camada, y, ta, tb, d16, int(diff["mudou"]))
	return true


func _titulo_contexto() -> String:
	if _contexto.is_empty():
		var porque: String = _cat.SEM_ANCORA.get(_prop, "não apareceu em %d turnos"
			% _turnos_jogados())
		return "No jogo — sem foto: %s" % porque
	var como := "visto a aparecer" if bool(_contexto["natural"]) \
		else "FORÇADO no lugar de %s" % String(_contexto["mostra"]).get_basename()
	return "No jogo — porto %s, dia %d, %s · recorte %s" % [_contexto["estagio"],
		int(_contexto["turno"]), como, _fator(float(_zoom_contexto(_janela_contexto())))]


func _turnos_jogados() -> int:
	var n := 0
	for e in ESTAGIOS:
		n += int(e["turnos"])
	return n


func _altura_contexto() -> float:
	if _contexto.is_empty():
		return 40.0
	var j: Rect2 = _janela_contexto()
	return j.size.y * float(_zoom_contexto(j))


## A janela do recorte do jogo: o desenho dos dois lados, com vizinhança à
## volta — metade do próprio tamanho e nunca menos de 40 px, que é o que um
## prédio da vila ocupa. Sem vizinhos não há contexto, só outra foto isolada.
func _janela_contexto() -> Rect2:
	var j: Rect2 = _contexto["janela"]
	var folga := Vector2(maxf(40.0, j.size.x * 0.5), maxf(40.0, j.size.y * 0.5))
	var r := j.grow_individual(folga.x, folga.y, folga.x, folga.y)
	r = r.intersection(Rect2(Vector2.ZERO, Vector2(LARG, ALT)))
	# A janela nunca passa da coluna: um casco grande com vizinhança pede mais
	# largura do que a prancha tem, e aí a folga encolhe à volta do prop.
	if r.size.x > COLUNA:
		r = Rect2(Vector2(j.get_center().x - COLUNA / 2.0, r.position.y),
			Vector2(COLUNA, r.size.y))
	if r.size.y > CTX_ALT_MAX:
		r = Rect2(Vector2(r.position.x, j.get_center().y - CTX_ALT_MAX / 2.0),
			Vector2(r.size.x, CTX_ALT_MAX))
	r.position = r.position.clamp(Vector2.ZERO, Vector2(LARG, ALT) - r.size)
	return Rect2(r.position.floor(), r.size.floor())


func _zoom_contexto(j: Rect2) -> int:
	return clampi(int(minf(COLUNA / j.size.x, CTX_ALT_MAX / j.size.y)), 1, CTX_ZOOM_MAX)


func _zoom_sv(u: Vector2) -> float:
	# Duas peças por coluna (silhueta e valor): a maior ampliação que cabe.
	# Os fatores são múltiplos de 1,5 — um número inteiro de pixels de textura
	# por pixel, que é o que deixa desenhar sem filtro — e o 1:1 no fim.
	for f in [9.0, 6.0, 4.5, 3.0, 1.5, 1.0]:
		if u.x * f <= COLUNA / 2.0 - 4.0 and u.y * f <= SV_ALT_MAX:
			return f
	return 1.0


## As três peças da linha de escala, e a maior ampliação em que cabem.
##
## ⚠️ ALINHAM PELO PÉ DO DESENHO, e não pelo centro do quadro. O centro do
## quadro é a origem do mundo e seria o chão de todos — se todos pousassem no
## chão. O trabalhador não pousa: ele partilha a âncora do píer e é desenhado à
## altura do TABUADO, e alinhado pelo centro flutuava um palmo acima do camião
## (medido na primeira prancha). É a convenção das pranchas de escala: todos no
## mesmo chão desenhado, que é o que a pergunta "quem é maior?" pede.
func _escala_medidas() -> Dictionary:
	var pecas: Array = []
	for r in REGUAS:
		var t: Texture2D = load("%s/%s" % [_cat.PASTA, r])
		pecas.append(PropIso.imagem(t))
	var alto := 0.0
	for p in pecas + [_a, _b]:
		alto = maxf(alto, float((p as Image).get_used_rect().size.y) / TEXTURA_POR_TELA)
	var largura := float(maxi(_a.get_used_rect().size.x, _b.get_used_rect().size.x))
	for p in pecas:
		largura += float((p as Image).get_used_rect().size.x)
	largura /= TEXTURA_POR_TELA
	var fator := 1.0
	for f in [3.0, 1.5]:
		if largura * f + 4.0 * 12.0 <= COLUNA and alto * f <= ESC_ALT_MAX:
			fator = f
			break
	return {"reguas": pecas, "alto": alto, "fator": fator, "alt": alto * fator + 18.0}


func _fator(f: float) -> String:
	return ("%.1fx" % f).replace(".0x", "x").replace(".", ",")


func _secao(camada: CanvasLayer, y: float, texto: String) -> float:
	_texto(camada, texto, Vector2(MARGEM, y + 2.0), 11, TINTA_FRACA)
	return y + ROTULO + 2.0


func _texto(camada: CanvasLayer, texto: String, onde: Vector2, fonte: int,
		cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = onde
	l.add_theme_color_override("font_color", cor)
	l.add_theme_font_size_override("font_size", fonte)
	camada.add_child(l)
	return l


## Uma imagem na prancha. `prova` marca as que têm de chegar à foto — a guarda
## das folhas de contato, que esconde a peça e exige que a foto mude.
func _imagem(camada: CanvasLayer, img: Image, onde: Vector2, tam: Vector2,
		sem_filtro: bool, prova: String = "") -> TextureRect:
	var t := TextureRect.new()
	t.texture = ImageTexture.create_from_image(img)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if sem_filtro \
		else CanvasItem.TEXTURE_FILTER_LINEAR
	t.position = onde
	t.size = tam
	camada.add_child(t)
	if prova != "":
		_artes.append([t, prova])
	return t


func _faixas(camada: CanvasLayer, canto: Vector2, tam: Vector2, tons: Array,
		cinza: bool = false) -> void:
	if tons.is_empty():
		var l := TextureRect.new()
		l.texture = _cat.listrado()
		l.stretch_mode = TextureRect.STRETCH_TILE
		l.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		l.position = canto
		l.size = tam
		camada.add_child(l)
		return
	for i in range(tons.size()):
		var c: Color = tons[i]
		if cinza:
			var v := c.get_luminance()
			c = Color(v, v, v)
		var f := ColorRect.new()
		f.color = c
		f.position = canto + Vector2(tam.x * float(i) / float(tons.size()), 0.0)
		f.size = Vector2(tam.x / float(tons.size()), tam.y)
		camada.add_child(f)


func _recorte(img: Image) -> Image:
	return img.get_region(_uniao)


func _linha_contexto(camada: CanvasLayer, y: float, alt: float) -> float:
	if _contexto.is_empty():
		_faixas(camada, Vector2(MARGEM, y), Vector2(LARG - 2.0 * MARGEM, alt - 6.0), [])
		return y + alt
	var j := _janela_contexto()
	var z := _zoom_contexto(j)
	var tam := j.size * float(z)
	for lado in [0, 1]:
		var foto: Image = _contexto["a" if lado == 0 else "b"]
		var x := MARGEM + float(lado) * (COLUNA + MARGEM) + (COLUNA - tam.x) / 2.0
		_imagem(camada, foto.get_region(Rect2i(j)), Vector2(x, y), tam, z > 1,
			"contexto %s" % ["A", "B"][lado])
	return y + alt


func _linha_chao(camada: CanvasLayer, y: float, u: Vector2, alt: float,
		diff: Image) -> float:
	var larg := (LARG - 4.0 * MARGEM) / 3.0
	var tam_piso := Vector2(larg, alt)
	var dy := (alt - u.y) / 2.0
	for lado in [0, 1]:
		var x := MARGEM + float(lado) * (larg + MARGEM)
		_faixas(camada, Vector2(x, y), tam_piso, _chaos)
		# 1:1 COM O FILTRO DO JOGO: a textura de 768 desenhada a 512, como o
		# `TextureRect` do mapa a desenha.
		_imagem(camada, _recorte(_a if lado == 0 else _b),
			Vector2(x + (larg - u.x) / 2.0, y + dy), u, false, "1:1 %s" % ["A", "B"][lado])
	var xd := MARGEM + 2.0 * (larg + MARGEM)
	var fd := ColorRect.new()
	fd.color = Color(0.0, 0.0, 0.0)
	fd.position = Vector2(xd, y)
	fd.size = tam_piso
	camada.add_child(fd)
	# A diferença não passa pela prova de "chegou à foto": com A = B ela é
	# vazia DE PROPÓSITO, e exigir-lhe desenho reprovaria o controle.
	_imagem(camada, _recorte(diff), Vector2(xd + (larg - u.x) / 2.0, y + dy), u, true)
	return y + alt + 6.0


func _linha_ampliada(camada: CanvasLayer, y: float, m: int) -> float:
	var tam := Vector2(_uniao.size) * float(m)
	for lado in [0, 1]:
		var x := MARGEM + float(lado) * (COLUNA + MARGEM)
		_faixas(camada, Vector2(x, y), Vector2(COLUNA, tam.y), _chaos)
		_imagem(camada, _recorte(_a if lado == 0 else _b),
			Vector2(x + (COLUNA - tam.x) / 2.0, y), tam, true,
			"ampliado %s" % ["A", "B"][lado])
	return y + tam.y + 6.0


func _linha_sv(camada: CanvasLayer, y: float, u: Vector2) -> float:
	var f := _zoom_sv(u)
	var tam := u * f
	var meia := COLUNA / 2.0
	for lado in [0, 1]:
		var img := _a if lado == 0 else _b
		var x := MARGEM + float(lado) * (COLUNA + MARGEM)
		var fs := ColorRect.new()
		fs.color = FUNDO_SILHUETA
		fs.position = Vector2(x, y)
		fs.size = Vector2(meia - 4.0, tam.y)
		camada.add_child(fs)
		_imagem(camada, _recorte(_silhueta(img)),
			Vector2(x + (meia - 4.0 - tam.x) / 2.0, y), tam, f > 1.0,
			"silhueta %s" % ["A", "B"][lado])
		_faixas(camada, Vector2(x + meia, y), Vector2(meia, tam.y), _chaos, true)
		_imagem(camada, _recorte(_valor(img)),
			Vector2(x + meia + (meia - tam.x) / 2.0, y), tam, f > 1.0,
			"valor %s" % ["A", "B"][lado])
	return y + tam.y + 6.0


## O prop entre as duas réguas, os três com o pé na mesma linha.
func _linha_escala(camada: CanvasLayer, y: float, esc: Dictionary) -> float:
	var f: float = esc["fator"]
	var alt: float = esc["alt"]
	var chao_y := y + 6.0 + float(esc["alto"]) * f
	for lado in [0, 1]:
		var x0 := MARGEM + float(lado) * (COLUNA + MARGEM)
		_faixas(camada, Vector2(x0, y), Vector2(COLUNA, alt - 6.0), _chaos)
		var pecas: Array = [esc["reguas"][0], _a if lado == 0 else _b, esc["reguas"][1]]
		var largura := 0.0
		for p in pecas:
			largura += float((p as Image).get_used_rect().size.x) / TEXTURA_POR_TELA * f + 12.0
		var x := x0 + (COLUNA - largura) / 2.0 + 6.0
		for i in range(pecas.size()):
			var p: Image = pecas[i]
			var ur := p.get_used_rect()
			var tam := Vector2(ur.size) / TEXTURA_POR_TELA * f
			_imagem(camada, p.get_region(ur), Vector2(x, chao_y - tam.y), tam, f > 1.0,
				"escala %s" % ["A", "B"][lado] if i == 1 else "")
			x += tam.x + 12.0
		var linha := ColorRect.new()
		linha.color = Color(TINTA, 0.35)
		linha.position = Vector2(x0 + 4.0, chao_y)
		linha.size = Vector2(COLUNA - 8.0, 1.0)
		camada.add_child(linha)
	return y + alt


func _linha_numeros(camada: CanvasLayer, y: float, ta: Dictionary, tb: Dictionary,
		d16: float, mudou: int) -> void:
	var linhas := [
		["desenho a 1:1", "%s", "tam"],
		["pixels opacos (de tela)", "%s", "opacos"],
		["folga até à borda do quadro", "%s", "folga"],
		["luminância mediana do prop", "%s", "lum"],
		["Weber contra cada chão", "%s", "weber"],
	]
	for l in linhas:
		var va := String(ta[l[2]])
		var vb := String(tb[l[2]])
		_texto(camada, "%s:" % l[0], Vector2(MARGEM, y), 10, TINTA_FRACA)
		_texto(camada, va, Vector2(MARGEM + 190.0, y), 10, TINTA)
		_texto(camada, vb, Vector2(MARGEM + 190.0 + 250.0, y), 10,
			TINTA if va == vb else TINTA_AVISO)
		y += 14.0
	_texto(camada, ("A↔B, régua 16x16 do comparar_props.py (maior célula): %.4f  ·  "
		% d16).replace(".", ",") + "%d px de textura mudaram" % mudou, Vector2(MARGEM, y), 10,
		TINTA if d16 < 0.02 else TINTA_AVISO)
	y += 14.0
	_texto(camada, "calibração da régua: 0,000 = mesma imagem · 0,022 = um pixel "
		+ "de deslocamento a 512 · 0,42 = outro prop", Vector2(MARGEM, y), 10, TINTA_FRACA)


# ── AS CONTAS ────────────────────────────────────────────────────────────────

## Os descritores de um lado, já como TEXTO, que é o que a prancha e o log
## escrevem — e as duas saídas têm de dizer o mesmo.
func _dados(img: Image) -> Dictionary:
	var ur := img.get_used_rect()
	var lums: Array = []
	for y in range(ur.position.y, ur.end.y):
		for x in range(ur.position.x, ur.end.x):
			var c := img.get_pixel(x, y)
			if c.a >= 0.5:
				lums.append(c.get_luminance())
	lums.sort()
	var med: float = lums[lums.size() / 2] if not lums.is_empty() else 0.0
	var tela := Vector2(ur.size) / TEXTURA_POR_TELA
	var folga := mini(mini(ur.position.x, ur.position.y),
		mini(img.get_width() - ur.end.x, img.get_height() - ur.end.y))
	var webers: Array = []
	for c in _chaos:
		var lc := (c as Color).get_luminance()
		webers.append(("%.2f" % (absf(med - lc) / maxf(lc, 1.0 / 255.0))).replace(".", ","))
	return {
		"tam": "%d x %d px" % [roundi(tela.x), roundi(tela.y)],
		"opacos": "%d" % roundi(float(lums.size()) / (TEXTURA_POR_TELA * TEXTURA_POR_TELA)),
		"folga": "%d px de textura" % folga,
		"lum": "%d/255" % roundi(med * 255.0),
		"weber": " · ".join(webers) if not webers.is_empty() else "sem chão (recurso)",
	}


func _silhueta(img: Image) -> Image:
	var out := Image.create_empty(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	var ur := img.get_used_rect()
	for y in range(ur.position.y, ur.end.y):
		for x in range(ur.position.x, ur.end.x):
			if img.get_pixel(x, y).a >= 0.5:
				out.set_pixel(x, y, SILHUETA)
	return out


func _valor(img: Image) -> Image:
	var out := Image.create_empty(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	var ur := img.get_used_rect()
	for y in range(ur.position.y, ur.end.y):
		for x in range(ur.position.x, ur.end.x):
			var c := img.get_pixel(x, y)
			var v := c.get_luminance()
			out.set_pixel(x, y, Color(v, v, v, c.a))
	return out


## Onde B deixa de ser A: o B em cinzento apagado, e a magenta cada pixel cuja
## diferença passa do ruído do denoiser. É a pergunta "o que é que mudou?", que
## a olho, entre dois PNG quase iguais, não se responde.
func _diferenca(a: Image, b: Image) -> Dictionary:
	var out := Image.create_empty(a.get_width(), a.get_height(), false, Image.FORMAT_RGBA8)
	var ur := _uniao
	var n := 0
	for y in range(ur.position.y, ur.end.y):
		for x in range(ur.position.x, ur.end.x):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			var d := maxf(maxf(absf(ca.r * ca.a - cb.r * cb.a), absf(ca.g * ca.a - cb.g * cb.a)),
				maxf(absf(ca.b * ca.a - cb.b * cb.a), absf(ca.a - cb.a)))
			if d > LIMIAR_PIXEL:
				out.set_pixel(x, y, MARCA_DIFERENCA)
				n += 1
			elif cb.a > 0.0:
				var v := cb.get_luminance() * 0.45
				out.set_pixel(x, y, Color(v, v, v, cb.a))
	return {"imagem": out, "mudou": n}


## A régua do `tools/comparar_props.py`, com a MESMA conta: o quadro inteiro
## pré-multiplicado pelo alfa, reduzido a 16x16 por MÉDIA (nunca por
## `resize`, que numa redução de 48x não faz média — `docs/decisoes/047`), e a
## maior diferença de célula e de canal. Duas réguas com a mesma promessa
## conferem-se no mesmo par, e esta conferiu-se contra a de Python em 27/09.
func _distancia16(a: Image, b: Image) -> float:
	var ra := _reduzir16(a)
	var rb := _reduzir16(b)
	var maior := 0.0
	for i in range(ra.size()):
		maior = maxf(maior, absf(ra[i] - rb[i]))
	return maior


func _reduzir16(img: Image) -> PackedFloat32Array:
	var lado := 16
	var cw := img.get_width() / lado
	var ch := img.get_height() / lado
	var out := PackedFloat32Array()
	out.resize(lado * lado * 4)
	var ur := img.get_used_rect()
	for y in range(ur.position.y, mini(ur.end.y, ch * lado)):
		for x in range(ur.position.x, mini(ur.end.x, cw * lado)):
			var c := img.get_pixel(x, y)
			var i := ((y / ch) * lado + (x / cw)) * 4
			out[i] += c.r * c.a
			out[i + 1] += c.g * c.a
			out[i + 2] += c.b * c.a
			out[i + 3] += c.a
	var area := float(cw * ch)
	for i in range(out.size()):
		out[i] /= area
	return out


# ── FOTOGRAFAR: a prancha, e a prova de que cada peça chegou a ela ──────────

func _fotografar() -> bool:
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false
	if _foto == null:
		_foto = root.get_texture().get_image()
		for par in _artes:
			(par[0] as CanvasItem).hide()
		_frames = 0
		return false
	var sem := root.get_texture().get_image()
	var ausentes := 0
	for par in _artes:
		var arte := par[0] as TextureRect
		var n := PropIso.desenho_na_foto(_foto, sem, Rect2(arte.position, arte.size))
		if n < DESENHO_MIN:
			print("FALHOU  '%s' não chegou à prancha: %d px mudam ao escondê-la"
				% [par[1], n])
			ausentes += 1
	if ausentes > 0:
		quit(1)
		return true
	if _foto.save_png(_saida) != OK:
		print("FALHOU ao salvar em %s" % _saida)
		quit(1)
		return true

	var ta: Dictionary = _numeros["a"]
	var tb: Dictionary = _numeros["b"]
	if _contexto.is_empty():
		print("Contexto: sem foto do jogo — %s" % _titulo_contexto().trim_prefix("No jogo — sem foto: "))
	else:
		print("Contexto: %s · nó %s · %d px do prop na foto do jogo"
			% [_titulo_contexto().trim_prefix("No jogo — "), _contexto["no"],
			   int(_contexto["visto"])])
	for k in ["tam", "opacos", "folga", "lum", "weber"]:
		print("  %-7s A: %-22s B: %s" % [k, ta[k], tb[k]])
	print("  Δ16 A↔B: %.4f · %d px de textura mudaram" % [float(_numeros["d16"]),
		int(_numeros["mudou"])])
	print("Folha salva em %s (%dx%d) — prancha de %s, %d peças provadas"
		% [_saida, _foto.get_width(), _foto.get_height(), _prop.get_basename(), _artes.size()])
	quit(0)
	return true
