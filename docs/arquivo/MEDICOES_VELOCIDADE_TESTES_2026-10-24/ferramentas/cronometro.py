#!/usr/bin/env python3
"""Corre um comando e carimba cada linha da saída com o tempo desde o início.
Uso: cronometro.py LOG -- cmd args..."""
import subprocess, sys, time, os
log = sys.argv[1]; cmd = sys.argv[sys.argv.index("--")+1:]
t0 = time.monotonic()
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=os.environ)
with open(log, "w") as f:
    for linha in p.stdout:
        f.write("%8.3f %s" % (time.monotonic()-t0, linha.decode("utf-8","replace")))
rc = p.wait()
tot = time.monotonic()-t0
with open(log, "a") as f:
    f.write("%8.3f [fim rc=%d]\n" % (tot, rc))
print("%s %.2f s rc=%d" % (os.path.basename(log), tot, rc))
