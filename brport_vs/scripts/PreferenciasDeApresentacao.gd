class_name PreferenciasDeApresentacao
extends RefCounted

# Preferência do aparelho, não da partida (`129`). A leitura não cria arquivo;
# só o toque nos Ajustes grava. Ferramentas passam pelo mesmo ArmazemLocal.
signal mudou(reduzido: bool)
signal texto_mudou(tamanho: String)

const ARQUIVO := "apresentacao.cfg"
const PADRAO := "padrao"
const MAIOR := "maior"
const FATOR_MAIOR := 1.25
static var _compartilhada: PreferenciasDeApresentacao
var reduzir_movimento := false
var tamanho_do_texto := PADRAO
var caminho: String


static func atual() -> PreferenciasDeApresentacao:
	if _compartilhada == null:
		# As réguas antigas medem a apresentação padrão, independentemente do
		# arquivo deixado por outra ferramenta. Captura RB6 aplica sua escolha
		# explicitamente; a sonda de reinício usa o mesmo leitor por new().
		_compartilhada = PreferenciasDeApresentacao.new(not ArmazemLocal.sob_ferramenta())
	return _compartilhada


func _init(carregar: bool = true) -> void:
	caminho = ArmazemLocal.caminho(ARQUIVO)
	if not carregar:
		return
	var cfg := ConfigFile.new()
	if cfg.load(caminho) == OK:
		var valor: Variant = cfg.get_value("apresentacao", "reduzir_movimento", false)
		# Não converter string/número: um arquivo inválido mantém a apresentação
		# anterior ao RB6, da mesma forma que uma instalação sem preferência.
		if typeof(valor) == TYPE_BOOL:
			reduzir_movimento = valor
		var texto: Variant = cfg.get_value("apresentacao", "tamanho_do_texto", PADRAO)
		if typeof(texto) == TYPE_STRING and texto in [PADRAO, MAIOR]:
			tamanho_do_texto = texto


func definir_reduzir_movimento(valor: bool) -> Error:
	# A escolha vale na sessão mesmo se o disco recusar. A UI informa que não
	# conseguiu lembrá-la; nunca confirma persistência só por ter tentado.
	reduzir_movimento = valor
	var cfg := ConfigFile.new()
	# Carrega antes de escrever para conservar texto, movimento e chaves que
	# uma versão futura conheça. O setter antigo criava um arquivo de uma chave.
	cfg.load(caminho)
	cfg.set_value("apresentacao", "reduzir_movimento", valor)
	var erro := cfg.save(caminho)
	mudou.emit(valor)
	return erro


func definir_tamanho_do_texto(valor: String) -> Error:
	if valor not in [PADRAO, MAIOR]:
		return ERR_INVALID_PARAMETER
	tamanho_do_texto = valor
	var cfg := ConfigFile.new()
	cfg.load(caminho)
	cfg.set_value("apresentacao", "tamanho_do_texto", valor)
	var erro := cfg.save(caminho)
	texto_mudou.emit(valor)
	return erro


func fator_do_texto() -> float:
	return FATOR_MAIOR if tamanho_do_texto == MAIOR else 1.0
