// Exercita o MESMO backend do jogo num Web mínimo, sem pôr ganchos de teste
// no produto. Chrome do runner; Playwright só controla os gestos e a permissão.
const { chromium } = require('playwright');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const http = require('node:http');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');

async function main() {
  const pasta = fs.mkdtempSync(path.join(os.tmpdir(), 'brport-copia-web-'));
  const projeto = path.join(pasta, 'projeto');
  const saida = path.join(pasta, 'web');
  fs.mkdirSync(projeto); fs.mkdirSync(saida);
  fs.copyFileSync(path.join(__dirname, '../brport_vs/scripts/CopiaDoDiagnostico.gd'),
    path.join(projeto, 'Copia.gd'));
  fs.writeFileSync(path.join(projeto, 'project.godot'), `config_version=5
[application]
config/name="Prova da cópia Web"
run/main_scene="res://Main.tscn"
[display]
window/size/viewport_width=400
window/size/viewport_height=200
[rendering]
renderer/rendering_method="gl_compatibility"
`);
  fs.writeFileSync(path.join(projeto, 'export_presets.cfg'), `[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
[preset.0.options]
variant/thread_support=false
`);
  fs.writeFileSync(path.join(projeto, 'Main.tscn'), `[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://Main.gd" id="1"]
[node name="Main" type="Node"]
script = ExtResource("1")
`);
  fs.writeFileSync(path.join(projeto, 'Main.gd'), `extends Node
func _ready() -> void:
	var copia = load("res://Copia.gd").new()
	add_child(copia)
	copia.concluida.connect(func(ok: bool):
		JavaScriptBridge.eval("window.resultados.push(" + JSON.stringify(ok) + ")"))
	var botao := Button.new()
	botao.position = Vector2(20, 20)
	botao.size = Vector2(300, 80)
	botao.text = "Copiar diagnóstico"
	botao.pressed.connect(func(): copia.copiar("BR Port\\nDiagnóstico de bancada"))
	add_child(botao)
	JavaScriptBridge.eval("window.pronto = true")
`);
  const godot = process.argv[2];
  for (const args of [['--headless', '--path', projeto, '--import'],
    ['--headless', '--path', projeto, '--export-release', 'Web', path.join(saida, 'index.html')]]) {
    const r = spawnSync(godot, args, { encoding: 'utf8', timeout: 120000 });
    assert.equal(r.status, 0, r.stdout + r.stderr);
    assert(!/SCRIPT ERROR|SHADER ERROR/.test(r.stdout + r.stderr), r.stdout + r.stderr);
  }
  const servidor = http.createServer((req, res) => {
    const nome = path.basename(new URL(req.url, 'http://localhost').pathname) || 'index.html';
    const arquivo = path.join(saida, nome);
    if (!fs.existsSync(arquivo)) { res.writeHead(404); res.end(); return; }
    const tipos = { '.wasm': 'application/wasm', '.js': 'text/javascript', '.html': 'text/html' };
    res.setHeader('Content-Type', tipos[path.extname(arquivo)] || 'application/octet-stream');
    fs.createReadStream(arquivo).pipe(res);
  });
  await new Promise(resolve => servidor.listen(0, '127.0.0.1', resolve));
  const browser = await chromium.launch({ channel: 'chrome', headless: true,
    args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  try {
    for (const modo of ['sucesso', 'recusa', 'ausente', 'pendente']) {
      const contexto = await browser.newContext({ permissions: ['clipboard-read', 'clipboard-write'] });
      const page = await contexto.newPage();
      const erros = [];
      page.on('pageerror', e => erros.push(String(e)));
      page.on('console', m => { if (/SCRIPT ERROR|SHADER ERROR/.test(m.text())) erros.push(m.text()); });
      await page.addInitScript(({ modo }) => {
        window.resultados = []; window.modo = modo;
        const original = navigator.clipboard.writeText.bind(navigator.clipboard);
        navigator.clipboard.writeText = texto => {
          if (window.modo === 'recusa') return Promise.reject(new DOMException('Recusado', 'NotAllowedError'));
          if (window.modo === 'pendente') return new Promise(resolve => { window.atrasada = resolve; });
          return original(texto);
        };
        if (modo === 'ausente') Object.defineProperty(navigator, 'clipboard', { value: undefined });
      }, { modo });
      await page.goto(`http://127.0.0.1:${servidor.address().port}/`);
      await page.waitForFunction(() => window.pronto === true, null, { timeout: 60000 });
      await page.waitForTimeout(200);
      assert.deepEqual(await page.evaluate(() => window.resultados), [], 'abrir não copia');
      await page.mouse.click(150, 60);
      await page.waitForFunction(() => window.resultados.length === 1);
      assert.deepEqual(await page.evaluate(() => window.resultados), [modo === 'sucesso']);
      if (modo === 'sucesso') assert.equal(await page.evaluate(() => navigator.clipboard.readText()),
        'BR Port\nDiagnóstico de bancada');
      if (modo === 'pendente') {
        await page.evaluate(() => { window.modo = 'sucesso'; });
        await page.mouse.click(150, 60);
        await page.waitForFunction(() => window.resultados.length === 2);
        await page.evaluate(() => window.atrasada());
        await page.waitForTimeout(100);
        assert.deepEqual(await page.evaluate(() => window.resultados), [false, true], 'resposta atrasada não confirma outra tentativa');
      }
      assert.deepEqual(erros, []);
      console.log('PASS COPIA WEB: ' + modo);
      await contexto.close();
    }
    console.log('COPIA WEB PROVADA');
  } finally {
    await browser.close();
    await new Promise(resolve => servidor.close(resolve));
    fs.rmSync(pasta, { recursive: true, force: true });
  }
}
main().catch(e => { console.error(e); process.exit(1); });
