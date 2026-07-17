
from __future__ import annotations
import os, shutil, subprocess, tempfile
from pathlib import Path

ROOT = Path(".")
projects = sorted(
    path for path in (ROOT / "projects").iterdir()
    if path.is_dir()
)
failures = []
compiled = 0

for project in projects:
    project = project.resolve()
    sources = [
        path for path in project.rglob("*.java")
        if "tests" not in {part.lower() for part in path.parts}
        and "test" not in {part.lower() for part in path.parts}
    ]
    if not sources:
        continue

    out = Path(tempfile.mkdtemp(prefix=f"javac-{project.name}-"))
    command = [
        "javac",
        "-encoding",
        "UTF-8",
        "-d",
        str(out.resolve()),
    ]

    uses_javafx = any(
        "javafx." in path.read_text(encoding="utf-8", errors="ignore")
        for path in sources
    )
    if uses_javafx:
        module_candidates = [
            Path(os.environ.get("JAVA_HOME", "")) / "lib",
            Path("/usr/share/openjfx/lib"),
        ]
        module_path = next(
            (path for path in module_candidates if path.is_dir()),
            None,
        )
        if module_path:
            command += [
                "--module-path", str(module_path),
                "--add-modules", "javafx.controls,javafx.fxml",
            ]

    command += [str(path.resolve()) for path in sources]
    result = subprocess.run(
        command, cwd=project, capture_output=True, text=True
    )
    shutil.rmtree(out, ignore_errors=True)

    if result.returncode != 0:
        failures.append(
            f"=== {project.relative_to(ROOT)} ===\n"
            f"{result.stdout}\n{result.stderr}"
        )
    else:
        compiled += 1

if failures:
    raise SystemExit("\n\n".join(failures))

print(f"Compiled {compiled} Java project(s) without student test sources.")
