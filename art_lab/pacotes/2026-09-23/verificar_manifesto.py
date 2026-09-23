"""Verify every payload entry without extracting the audit archive."""
from pathlib import Path
from zipfile import ZipFile
import sys,json,hashlib
p=Path(sys.argv[1] if len(sys.argv)>1 else 'BR_PORT_AUDITORIA_ARTE_2026-09-23.zip')
with ZipFile(p) as z:
 m=json.loads(z.read('manifest_sha256.json'))
 expected={i['arquivo_zip'] for i in m['files']}|{'manifest_sha256.json'}
 actual=set(z.namelist())
 assert actual==expected,{'missing':sorted(expected-actual),'unexpected':sorted(actual-expected)}
 for item in m['files']:
  b=z.read(item['arquivo_zip'])
  assert len(b)==item['bytes'],item['arquivo_zip']
  assert hashlib.sha256(b).hexdigest()==item['sha256'],item['arquivo_zip']
print(f"PASS: {len(m['files'])} arquivos conferidos por tamanho e SHA-256")
