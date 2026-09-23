# BR Port — pacote isolado de QA de assets V3

Conteúdo: plano revisado, relatório da candidata 13A, contrato de evidências fixado por SHA-256, script de auditoria, testes negativos e imagens usadas na verificação. É uma entrega paralela ao projeto de código; não substitui a execução em Godot nem altera o repositório.

## Executar

Requer Python 3.10+ e Pillow 12+. Na raiz deste pacote:

```bash
python3 -m unittest discover -s tests -v
python3 qa_assets.py --repo /caminho/para/br-port --out results/nova_auditoria.json
```

O segundo comando retorna **2** com o contrato de 13A atual porque a candidata tem falhas e gates abertos. Sem `--repo`, o teste do gerador fica pendente. O adaptador de leitura requer exatamente o SHA-256 do gerador registrado no contrato; quando mudar, gere outro contrato/revisão e reavalie as imagens. `results/13a_auditoria.json` é a execução auditada em 23/09/2026.

## Arquivos

- `PLANO_PRODUCAO_ASSETS_BR_PORT_V3.md`: critérios, catálogo, roteiro F1–F5 e matriz Q01–Q15.
- `RELATORIO_AUDITORIA_ASSETS_V3.md`: achados e próxima iteração do 13A.
- `contracts/13a.qa.json`: revisão, caminhos e hashes, escala e gates.
- `qa_assets.py`: verificações objetivas; a proposta de RNG separado é só uma simulação externa.
- `tests/test_qa.py`: casos negativos para transparência, tamanho, máscara, evidências alteradas, revisão trocada e RNG.
- `evidence/`: candidato, mapas rasterizados e recorte de referência. `comparacao_anterior.jpg` é apenas registro histórico: as escalas dos itens isolados não constituem comparação justa.
- `results/`: saída reproduzível e snapshot do checkout lido, sem arquivo de jogo.

Os gates com evidência checam existência, hash e revisão. O verificador não pode determinar se uma aprovação humana escrita é autêntica ou se o design é bonito. Uma máscara para áreas protegidas deve vir de geometria de gameplay independente da imagem comparada; deixá-la vazia mantém o teste pendente. O bitmap isolado de 13A não é textura usada pela cena.
