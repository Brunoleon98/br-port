#!/usr/bin/env python3
"""Auditoria isolada de assets. Não escreve no checkout e não aprova beleza.

Python 3.10+ e Pillow. Resultado 2 significa problemas no asset auditado;
resultado 0 não dispensa critérios humanos e evidência de runtime.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import random
import re
import sys
from PIL import Image, ImageChops

sys.dont_write_bytecode = True


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def png_problems(path):
    problems = []
    with Image.open(path) as im:
        if im.format != "PNG" or im.mode != "RGBA":
            return ["PNG precisa de RGBA real"]
        alpha = im.getchannel("A")
        bbox = alpha.getbbox()
        if bbox is None:
            return ["asset vazio"]
        if alpha.getextrema()[0] == 255:
            problems.append("sem transparência")
        edges = [alpha.crop((0, 0, im.width, 1)),
                 alpha.crop((0, im.height - 1, im.width, im.height)),
                 alpha.crop((0, 0, 1, im.height)),
                 alpha.crop((im.width - 1, 0, im.width, im.height))]
        if any(e.getextrema()[1] > 8 for e in edges):
            problems.append("conteúdo toca o limite do canvas")
    return problems


def changed_outside(before, after, mask):
    if before.size != after.size or before.size != mask.size:
        raise ValueError("dimensões de imagem/máscara diferentes")
    delta = ImageChops.difference(before.convert("RGB"), after.convert("RGB"))
    allowed = mask.convert("L")
    return sum(any(p) and m < 128
               for p, m in zip(delta.get_flattened_data(), allowed.get_flattened_data()))


def keyed_rng(asset_id, channel):
    key = hashlib.sha256(f"BRP-QA-V3|{asset_id}|{channel}".encode()).digest()
    return random.Random(int.from_bytes(key[:16], "big"))


def stable_layout(draw_cost=0):
    """Demonstração: identidade/posição/forma independentes, fora do jogo."""
    anchors = []
    for zone, ys in {1: (2.5, 5.0, 6.6), 2: (10.2, 12.0)}.items():
        mx1 = -5.45 if zone == 1 else -1.45
        for i, y in enumerate(ys):
            aid = f"f01_13a_{zone}_{i}"
            x = mx1 - .48 - keyed_rng(aid, "position").uniform(0, .26)
            shape = keyed_rng(aid, "shape")
            for _ in range(draw_cost):
                shape.random()
            anchors.append([aid, x, y])
    return anchors


def release_problems(dossier, evidence_root=None):
    """Contrato externo de qualidade, sem reinterpretar manifest legado."""
    problems = []
    digest = dossier.get("candidate_sha256")
    if not isinstance(digest, str) or not re.fullmatch(r"[0-9a-f]{64}", digest):
        problems.append("candidato sem SHA-256 válido")
    for gate in ("reference", "visual", "integration", "mobile", "human"):
        item = dossier.get("gates", {}).get(gate, {})
        if item.get("status") != "pass":
            problems.append(f"{gate}: não aprovado")
        evidence = item.get("evidence")
        if not isinstance(evidence, list) or not evidence:
            problems.append(f"{gate}: sem evidência")
        else:
            for entry in evidence:
                if not isinstance(entry, dict) or not entry.get("path") or not entry.get("sha256"):
                    problems.append(f"{gate}: evidência sem caminho e hash")
                    continue
                if evidence_root is None:
                    problems.append(f"{gate}: conteúdo da evidência não verificado")
                    continue
                root = Path(evidence_root).resolve()
                f = (root / entry["path"]).resolve()
                if not f.is_relative_to(root) or not f.is_file() or sha(f) != entry["sha256"]:
                    problems.append(f"{gate}: evidência ausente, alterada ou fora do pacote")
        if item.get("candidate_sha256") != digest:
            problems.append(f"{gate}: evidência de outra revisão")
    return problems


def audit_repo(repo):
    source = Path(repo) / "tools/gerar_mapa_iso.py"
    spec = importlib.util.spec_from_file_location("brp_readonly", source)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    original = m.arbusto_baixo_f1

    def positions(lobes=None, extra=0):
        output = []
        def capture(x, y, rng):
            output.append([round(x, 9), y])
            if lobes is None:
                result = original(x, y, rng)
            else:
                for _ in range(lobes):
                    m._lobo(0, 0, 1, 1, rng)
                result = ""
            for _ in range(extra):
                rng.random()
            return result
        m.arbusto_baixo_f1 = capture
        try:
            for zone in (1, 2):
                lo, hi, edge = m.DEGRAUS[zone]
                m.vegetacao_do_solo(zone, m.FUNDO_TERRA, lo,
                                   edge - m.VILA_RECUO_2, hi)
        finally:
            m.arbusto_baixo_f1 = original
        return output

    current = positions()
    mutation = positions(extra=100)
    six = positions(lobes=6)
    seven = positions(lobes=7)
    # A exportação isolada parte direto da semente; o mapa consome primeiro
    # um sorteio de posição. A saída pode coincidir por acidente, pois
    # choice() também consome bits do RNG. Testar, nunca inferir divergência.
    map_rng = random.Random(m.SEMENTE_CHAO + 1301)
    map_rng.uniform(0, .26)
    map_svg = original(0, 0, map_rng)
    export_svg = original(0, 0, random.Random(m.SEMENTE_CHAO + 1301))
    repeated = original(0, 0, random.Random(m.SEMENTE_CHAO + 1301))
    manifest = json.loads((Path(repo) / "brport_vs/data/assets/BRP_PRODUCTION_MANIFEST.json").read_text())
    return {
        "source_sha256": sha(source),
        "anchors_current": current,
        "anchors_mutation": mutation,
        "placement_unchanged": current == mutation,
        "v2_six_lobe_replay": six,
        "seven_lobe_replay_matches_current": current == seven,
        "historical_replay_note": "V2 reconstruída do código mostrado na conversa; não é um arquivo V2 autenticado.",
        "exact_specimen_matches_first_instance": map_svg == export_svg,
        "shape_repeatable": repeated == export_svg,
        "legacy_production_with_open_gates": [x["asset_id"] for x in manifest["assets"]
            if x["status"] == "production" and x.get("open_gates")],
        "isolated_layout_proposal_pass": stable_layout(0) == stable_layout(1000),
    }


def audit(contract_path, repo=None):
    path = Path(contract_path).resolve()
    c = json.loads(path.read_text())
    root = path.parent.parent
    rows = []
    def add(name, status, detail):
        rows.append({"test": name, "status": status, "detail": detail})
    for name, item in c["files"].items():
        p = root / item["path"]
        valid = p.is_file() and sha(p) == item["sha256"]
        add("hash_" + name, "PASS" if valid else "FAIL", item["path"])
    candidate = root / c["files"]["candidate"]["path"]
    if not candidate.is_file():
        raise FileNotFoundError(candidate)
    errors = png_problems(candidate)
    add("png_alpha_canvas", "FAIL" if errors else "PASS", errors)
    for label, filename in (("before", "before_map"), ("after", "after_map")):
        with Image.open(root / c["files"][filename]["path"]) as im:
            size = im.size
            add("map_dimensions_" + label, "PASS" if size == (720, 720) else "FAIL", list(size))
    before = Image.open(root / c["files"]["before_map"]["path"]).convert("RGB")
    after = Image.open(root / c["files"]["after_map"]["path"]).convert("RGB")
    if before.size == after.size:
        delta = ImageChops.difference(before, after)
        add("map_delta", "INFO", {"pixels": sum(any(p) for p in delta.get_flattened_data()), "bbox": delta.getbbox()})
    mask = c.get("allowed_change_mask")
    if mask:
        n = changed_outside(before, after, Image.open(root / mask))
        add("protected_regions", "PASS" if n == 0 else "FAIL", {"outside_pixels": n})
    else:
        add("protected_regions", "PENDING", "Sem máscara independente de portas, docas e rotas; bbox de diferença não substitui essa prova.")
    add("scale_metadata", "INFO", c["scale"])
    problems = release_problems(c, root)
    add("quality_release", "PENDING" if problems else "PASS", problems)
    technical = None
    if repo:
        actual = sha(Path(repo) / "tools/gerar_mapa_iso.py")
        if actual != c["audited_generator_sha256"]:
            add("pinned_source", "FAIL", "Gerador mudou. Refaça a auditoria; não use o adaptador de V3 em fonte diferente.")
        else:
            add("pinned_source", "PASS", actual)
            technical = audit_repo(repo)
            for key in ("placement_unchanged", "exact_specimen_matches_first_instance", "shape_repeatable"):
                add(key, "PASS" if technical[key] else "FAIL", technical[key])
            add("stable_rng_prototype", "PASS" if technical["isolated_layout_proposal_pass"] else "FAIL",
                "Teste da proposta isolada, sem aplicação ao código do jogo.")
            add("legacy_status_semantics", "REVIEW", technical["legacy_production_with_open_gates"])
    else:
        add("repo_adapter", "PENDING", "Passe --repo para repetir a sonda do gerador local fixado.")
    return {"asset_id": c["asset_id"], "candidate_sha256": c["candidate_sha256"],
            "tests": rows, "repo_details": technical,
            "ready_for_release": not problems and not any(r["status"] in ("FAIL", "PENDING", "REVIEW") for r in rows)}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--contract", default=str(Path(__file__).parent / "contracts/13a.qa.json"))
    ap.add_argument("--repo")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    result = audit(args.contract, args.repo)
    dest = Path(args.out)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    print("QA_RESULT_WRITTEN", dest)
    counts = {s: sum(t["status"] == s for t in result["tests"])
              for s in ("PASS", "FAIL", "PENDING", "REVIEW", "INFO")}
    print(json.dumps(counts), "ready_for_release=", result["ready_for_release"])
    return 0 if result["ready_for_release"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
