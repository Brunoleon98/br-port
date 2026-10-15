from pathlib import Path
import json, math, sys, copy

def quantis(v):
    v=sorted(v)
    return {'n':len(v),'p10':v[int(len(v)*.1)],'p50':v[len(v)//2], 'p90':v[int(len(v)*.9)]} if v else {'n':0,'p10':None,'p50':None,'p90':None}

def conferir(d):
    assert [g['perfil'] for g in d['resultados']] == ['Ótimo','Mediano','Descuidado','Antecipado']
    assert d['fase_2']['semanas'] is None and d['fase_2']['parcelas'] == []
    for g in d['resultados']:
        linhas = g['partidas']; r = g['resumo']
        assert len(linhas) == d['partidas_por_perfil']
        assert not any(x['travou'] for x in linhas)
        e = [x for x in linhas if x['entrada'] is not None]
        m = [x for x in e if x['dias_ate_meta'] is not None]
        assert r['partidas'] == len(linhas) and r['entraram'] == len(e)
        assert r['metas'] == len(m)
        assert r['perdas_fase_1'] == len(linhas)-len(e)
        assert r['quebras_antes_meta'] == sum(x['quebrou'] and x['dias_ate_meta'] is None for x in e)
        assert r['quebras_apos_meta'] == sum(x['quebrou'] and x['dias_ate_meta'] is not None for x in e)
        assert r['censuradas'] == sum(not x['quebrou'] and x['dias_ate_meta'] is None for x in e)
        assert r['entraram'] == r['metas']+r['quebras_antes_meta']+r['censuradas']
        assert r['dias_ate_meta'] == quantis([x['dias_ate_meta'] for x in m])
        for k in ['caixa_entrada','caixa_meta','menor_caixa','caixa_final','margem_operacional','dias_abaixo_piso','suspensoes','recuperacoes']:
            assert r[k] == quantis([x[k] for x in e if x[k] is not None]), (g['perfil'],k)
        for x in e:
            assert x['entrada'] == 85
            assert 0 <= x['fechos_observados'] <= d['janela_dias']
            assert x['dia_final']-x['entrada'] == x['fechos_observados']
            assert x['quebrou'] or x['fechos_observados'] == d['janela_dias']
            assert x['margem_operacional'] == x['caixa_final']-x['caixa_entrada']+x['investimento']
            assert x['menor_caixa'] <= min(x['caixa_entrada'],x['caixa_final'])
            if x['dias_ate_meta'] is not None:
                assert x['dia_meta']-x['entrada'] == x['dias_ate_meta'] > 0
                assert x['primeiro_cargueiro'] and x['fechos_ate_cargueiro'] <= x['dias_ate_meta']
                assert all(x['conclusoes_de_obras'][k] <= x['dias_ate_meta'] for k in d['fase_2']['meta']['infra'])
                assert x['dias_de_reputacao'] == d['fase_2']['meta']['dias']
            else:
                assert x['dia_meta'] is None and x['caixa_meta'] is None
            if x['quebrou']:
                assert x['caixa_final'] < 0
    return True

if __name__ == '__main__':
    p=Path(sys.argv[1]); d=json.loads(p.read_text(encoding='utf-8'))
    assert conferir(d)
    # Controles da régua: dados idênticos passam, um valor de resumo e um
    # dia observado adulterados precisam falhar, separadamente.
    for mutante in ['resumo','dia']:
        n=copy.deepcopy(d)
        if mutante == 'resumo': n['resultados'][0]['resumo']['metas'] += 1
        else: n['resultados'][0]['partidas'][0]['dia_meta'] += 1
        try: conferir(n)
        except AssertionError: pass
        else: raise AssertionError('controle não pegou: '+mutante)
    print('MEDICAO CONFERIDA:',p.name,'; dois controles reprovados')
