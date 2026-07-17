
from __future__ import annotations
import ast, json, re, sys
import xml.etree.ElementTree as ET
from pathlib import Path
import nbformat, yaml

ROOT = Path(".")
REQUIRED = [
    "README.md", "LICENSE", "LICENSE_REVIEW.md",
    "THIRD_PARTY_NOTICES.md", "PUBLIC_RELEASE_STATUS.md",
    "OWNERSHIP_REVIEW.md",
]
SECRET_PATTERNS = {
    "OpenAI key": re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9_-]{16,}"),
    "GitHub token": re.compile(
        r"\b(?:ghp_|gho_|ghu_|ghs_|ghr_|github_pat_)[A-Za-z0-9_]{16,}"
    ),
    "Google API key": re.compile(r"\bAIza[0-9A-Za-z_-]{20,}"),
    "AWS access key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "Private key": re.compile(
        r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"
    ),
}
TEXT_SUFFIXES = {
    ".py",".pyi",".toml",".cfg",".ini",".txt",".md",".yml",".yaml",
    ".json",".sh",".bash",".xml",".js",".jsx",".ts",".tsx",".java",
    ".kt",".kts",".c",".h",".cpp",".hpp",".rs",".ml",".mli",
    ".gradle",".properties",
}
SKIP_PARTS = {
    ".git",".venv","venv","node_modules","build","dist",".gradle",
    "target","_build","__pycache__",".pytest_cache",".ruff_cache",
    ".mypy_cache",
}

def files():
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        yield path

failures = []
for name in REQUIRED:
    if not (ROOT / name).is_file():
        failures.append(f"Missing required release document: {name}")

for path in files():
    rel = path.as_posix()
    if path.stat().st_size > 95_000_000:
        failures.append(f"File exceeds 95 MB: {rel}")

    suffix = path.suffix.lower()
    if suffix == ".ipynb":
        try:
            nb = nbformat.read(path, as_version=4)
        except Exception as exc:
            failures.append(f"Malformed notebook {rel}: {exc}")
            continue
        for i, cell in enumerate(nb.cells):
            if cell.cell_type == "code":
                if cell.get("outputs"):
                    failures.append(f"Notebook output remains: {rel}, cell {i}")
                if cell.get("execution_count") is not None:
                    failures.append(f"Execution count remains: {rel}, cell {i}")
    elif suffix == ".py":
        try:
            ast.parse(path.read_text(encoding="utf-8", errors="replace"))
        except Exception as exc:
            failures.append(f"Python syntax error in {rel}: {exc}")
    elif suffix == ".json":
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:
            failures.append(f"Invalid JSON {rel}: {exc}")
    elif suffix in {".yml", ".yaml"}:
        try:
            yaml.safe_load(path.read_text(encoding="utf-8"))
        except Exception as exc:
            failures.append(f"Invalid YAML {rel}: {exc}")
    elif suffix == ".xml":
        try:
            ET.parse(path)
        except Exception as exc:
            failures.append(f"Invalid XML {rel}: {exc}")

    if suffix in TEXT_SUFFIXES and path.stat().st_size <= 5_000_000:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for kind, pattern in SECRET_PATTERNS.items():
            if pattern.search(text):
                failures.append(f"{kind} pattern in {rel}")

if failures:
    print("\n".join(failures))
    raise SystemExit(1)

print("Portable structural, security, syntax, and notebook checks passed.")
