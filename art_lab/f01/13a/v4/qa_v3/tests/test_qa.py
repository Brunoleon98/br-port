"""Defeitos artificiais precisam ser detectados antes de confiar no QA."""
import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest
from PIL import Image, ImageDraw

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from qa_assets import png_problems, changed_outside, stable_layout, release_problems, sha


class Guardas(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def png(self, mode="RGBA", blank=False, clipped=False):
        im = Image.new(mode, (20, 20), (0, 0, 0, 0) if mode == "RGBA" else (255, 255, 255))
        if not blank:
            ImageDraw.Draw(im).rectangle((0 if clipped else 4, 4, 15, 15), fill="green")
        p = self.root / "a.png"
        im.save(p)
        return p

    def good_dossier(self):
        p = self.root / "evidence.txt";p.write_text("Captura e decisão fictícias para teste da guarda")
        return {"candidate_sha256": "a" * 64,
                "gates": {g: {"status": "pass", "candidate_sha256": "a" * 64,
                    "evidence": [{"path": p.name, "sha256": sha(p)}]}
                    for g in ("reference", "visual", "integration", "mobile", "human")}}

    def test_alpha_valid(self):
        self.assertEqual(png_problems(self.png()), [])

    def test_opaque_rejected(self):
        self.assertTrue(png_problems(self.png(mode="RGB")))

    def test_empty_rejected(self):
        self.assertTrue(png_problems(self.png(blank=True)))

    def test_border_rejected(self):
        self.assertTrue(png_problems(self.png(clipped=True)))

    def test_edit_outside_mask(self):
        a = Image.new("RGB", (10, 10));b = a.copy();b.putpixel((8, 8), (255, 0, 0))
        mask = Image.new("L", (10, 10));ImageDraw.Draw(mask).rectangle((0, 0, 3, 3), fill=255)
        self.assertEqual(changed_outside(a, b, mask), 1)

    def test_edit_inside_mask(self):
        a = Image.new("RGB", (10, 10));b = a.copy();b.putpixel((2, 2), (255, 0, 0))
        mask = Image.new("L", (10, 10));ImageDraw.Draw(mask).rectangle((0, 0, 3, 3), fill=255)
        self.assertEqual(changed_outside(a, b, mask), 0)

    def test_wrong_image_size(self):
        with self.assertRaises(ValueError):
            changed_outside(Image.new("RGB", (10, 10)), Image.new("RGB", (9, 10)), Image.new("L", (10, 10)))

    def test_shape_rng_cannot_move_proposed_layout(self):
        self.assertEqual(stable_layout(0), stable_layout(1000))

    def test_metadata_ready(self):
        self.assertEqual(release_problems(self.good_dossier(), self.root), [])

    def test_human_pending_cannot_release(self):
        d = self.good_dossier();d["gates"]["human"]["status"] = "pending"
        self.assertTrue(release_problems(d, self.root))

    def test_old_candidate_approval_rejected(self):
        d = self.good_dossier();d["gates"]["visual"]["candidate_sha256"] = "b" * 64
        self.assertTrue(release_problems(d, self.root))

    def test_missing_evidence_rejected(self):
        d = self.good_dossier();(self.root / "evidence.txt").unlink()
        self.assertTrue(release_problems(d, self.root))

    def test_modified_evidence_rejected(self):
        d = self.good_dossier();(self.root / "evidence.txt").write_text("alterado")
        self.assertTrue(release_problems(d, self.root))

    def test_path_escape_rejected(self):
        d = self.good_dossier();d["gates"]["human"]["evidence"][0]["path"] = "../other.txt"
        self.assertTrue(release_problems(d, self.root))


if __name__ == "__main__":
    unittest.main(verbosity=2)
