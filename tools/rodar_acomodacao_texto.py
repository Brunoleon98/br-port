#!/usr/bin/env python3
"""Compara propostas locais do RB5 com os mesmos nós, estado e letras da bancada.

Não exporta nem instala preferência global. Controles são fotografados também
no fim da rolagem. O relatório conserva falhas de encaixe em vez de as ocultar.
"""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile
from rodar_bancada_texto import RAIZ, rodar


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--godot', default=shutil.which('godot'))
    ap.add_argument('--saida', type=Path, required=True)
    ap.add_argument('--capturar', action='store_true')
    ap.add_argument('--propostas', nargs='+', choices=['original', 'colunas', 'lista'], default=['original', 'colunas', 'lista'])
    ap.add_argument('--fatores', nargs='+', choices=['1', '1.25', '1.5'], default=['1', '1.25', '1.5'])
    ap.add_argument('--cenarios', nargs='+', choices=['hud', 'doca'], default=['hud', 'doca'])
    args = ap.parse_args()
    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    perfil = Path(tempfile.mkdtemp(prefix='perfil-', dir=saida))
    env = os.environ.copy()
    env.update(XDG_DATA_HOME=str(perfil), XDG_CACHE_HOME=str(perfil/'cache'), APPDATA=str(perfil))
    sentinela = ['python3', 'tools/sentinela_do_jogador.py']
    rodar(sentinela+['plantar', 'brport_vs'], env, saida/'sentinela-antes.log')
    resultados = []
    for proposta in args.propostas:
        for cenario in args.cenarios:
            for fator in args.fatores:
                if proposta != 'original' and fator == '1':
                    continue  # Padrão fica idêntico à main; não é redesenhado.
                nome = f'{proposta}-{cenario}-{fator}'
                base = saida/nome
                script = 'bancada_texto' if proposta == 'original' else 'acomodacao_texto_bancada'
                cmd = [args.godot, '--path', 'brport_vs', '--resolution', '720x1280', '--audio-driver', 'Dummy', '--fixed-fps', '60']
                cmd += ['--rendering-driver', 'opengl3'] if args.capturar else ['--headless']
                cmd += ['--script', f'res://tools/{script}.gd', '--', cenario, fator, str(base)]
                cmd += ['capturar' if args.capturar else 'medir', proposta]
                log = rodar(cmd, env, Path(str(base)+'.log'))
                if 'BANCADA TEXTO MEDIDA ' not in log:
                    raise SystemExit(f'Sem conclusão: {nome}')
                dados = json.loads(Path(str(base)+'.json').read_text())
                if not dados['mesmo_estado_apos_ampliar'] or dados['fontes'] != dados['fontes_reaplicadas']:
                    raise SystemExit(f'Estado ou reaplicação divergente: {nome}')
                if any(a['base'] != b['aplicado'] for a,b in zip(dados['fontes'], dados['fontes_restauradas'], strict=True)):
                    raise SystemExit(f'Base não restaurada: {nome}')
                if args.capturar:
                    esperadas = ['.png'] + (['_fim.png'] if proposta != 'original' else [])
                    for sufixo in esperadas:
                        p = Path(str(base)+sufixo)
                        if not p.is_file() or not p.stat().st_size:
                            raise SystemExit(f'Foto ausente: {p.name}')
                textos = dados['medicao']['textos']
                resultados.append({'caso': nome, 'textos': len(textos),
                    'excesso_local': [t for t in textos if t['excesso_local'] > 1],
                    'excesso_janela_sem_rolagem': [t for t in textos if t['excesso_janela'] > 1 and not t['em_rolagem']],
                    'areas': dados['medicao']['areas']})
                print(f'Medido {nome}', flush=True)
    fim = rodar(sentinela+['conferir', 'brport_vs'], env, saida/'sentinela-depois.log')
    if 'SENTINELA INTACTA' not in fim:
        raise SystemExit('Sentinela não confirmada')
    (saida/'resumo.json').write_text(json.dumps(resultados, ensure_ascii=False, indent=2)+'\n')
    print(f'ACOMODACAO MEDIDA — {len(resultados)} casos; estado e sentinela preservados')


if __name__ == '__main__':
    main()
