#!/usr/bin/env python3
"""Канон репо → wing win11_hardening у mempalace: дзеркало ~/.mempalace/sources/win11_hardening + mine.

Палац здебільшого містить уривки транскриптів — копії файлів на дату сесії, які старіють.
Тут лежить ПОТОЧНА версія джерел правди: MemPalace 3.12 при повторному mine спершу пише нові
шухляди, потім прибирає старі, незмінні файли перевикористовують вектори. Тека першого рівня
дзеркала = кімната. Шаблон спільний для репо користувача (еталон — avto-advokat).

Запуск: SessionEnd-хук (`--wait`, у відокремленому процесі) або post-commit (без прапорця —
mine відокремлено). `--dry-run` — показати розкладку без запису. Немає mempalace — тихо виходить.
"""

import filecmp
import os
import subprocess
import sys
from pathlib import Path, PurePosixPath

CONFIG = {'wing': 'win11_hardening',
 'files': [('.claude/CLAUDE.md', 'general'),
           ('README.md', 'general'),
           ('CHANGELOG.md', 'general'),
           ('policies/*.txt', 'policies'),
           ('policies/*.inf', 'policies'),
           ('settings/*.ps1', 'settings')],
 'skills': {}}

REPO = Path(__file__).resolve().parents[1]
HOME = Path.home() / ".mempalace"
WING = CONFIG["wing"]
MIRROR = HOME / "sources" / WING
PID_FILE = HOME / "hook_state" / f"canon-{WING}.pid"
LOG_FILE = HOME / "hook_state" / f"canon-{WING}.log"
SKIP_DIRS = {".git", "node_modules", "vendor", "coverage", "coverage-js", ".cache", ".phpunit.cache", ".superpowers", ".worktrees"}


def mirror_rel(rel: Path) -> Path:
    """Без прихованих тек (`.claude` → `claude`): miner пропускає dot-теки."""
    return Path(*[part.lstrip(".") or part for part in rel.parts])


def plan() -> dict[Path, Path]:
    out: dict[Path, Path] = {}
    files = []
    for root, dirs, names in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        files += [Path(root) / n for n in names]
    for src in files:
        rel = PurePosixPath(src.relative_to(REPO).as_posix())
        for pattern, room in CONFIG["files"]:
            if rel.full_match(pattern):  # `*` — у межах сегмента, `**` — будь-яка глибина (Python ≥3.13)
                out[Path(room) / mirror_rel(Path(rel))] = src
                break
    for room, skills in CONFIG.get("skills", {}).items():
        for skill in skills:
            base = REPO / ".claude" / "skills" / skill
            for src in base.glob(CONFIG.get("skill_files", "**/*.md")) if base.is_dir() else []:
                out[Path(room) / "skills" / skill / src.relative_to(base)] = src
    return out


def config_yaml() -> str:
    rooms = sorted({room for _, room in CONFIG["files"]} | set(CONFIG.get("skills", {})))
    lines = [f"wing: {WING}", "rooms:"]
    for room in rooms:
        lines += [f"  - name: {room}", f"    description: канон репо ({room})", f"    keywords: [{room}]"]
    return "\n".join(lines) + "\n"


def sync_mirror(target: dict[Path, Path]) -> int:
    changed = 0
    MIRROR.mkdir(parents=True, exist_ok=True)
    cfg = MIRROR / "mempalace.yaml"
    text = config_yaml()
    if not cfg.is_file() or cfg.read_text(encoding="utf-8") != text:
        cfg.write_text(text, encoding="utf-8")
    for rel, src in target.items():
        dst = MIRROR / rel
        if dst.is_file() and filecmp.cmp(src, dst, shallow=False):
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(src.read_bytes())
        changed += 1
    keep = {MIRROR / rel for rel in target} | {cfg}
    for path in sorted(MIRROR.rglob("*"), reverse=True):
        if path.is_file() and path not in keep:
            path.unlink()
            changed += 1
        elif path.is_dir() and not any(path.iterdir()):
            path.rmdir()
    return changed


def running() -> bool:
    try:
        pid = int(PID_FILE.read_text(encoding="utf-8").strip())
    except (OSError, ValueError):
        return False
    if os.name == "nt":
        out = subprocess.run(["tasklist", "/FI", f"PID eq {pid}", "/NH"], capture_output=True, text=True, check=False).stdout
        return str(pid) in out and "python" in out.lower()
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def mine(mode: str) -> None:
    cmd = [sys.executable, "-m", "mempalace", "mine", str(MIRROR), "--wing", WING, "--agent", "repo-canon"]
    env = dict(os.environ, PYTHONUTF8="1", MEMPALACE_WING=WING)
    if mode == "dry":
        subprocess.run([*cmd, "--dry-run"], env=env, check=False)
        return
    if running():
        print("mempalace-canon: попередній mine ще працює — наступний запуск наздожене")
        return
    log = open(LOG_FILE, "ab")  # noqa: SIM115 — живе в дочірньому процесі
    if mode == "wait":
        PID_FILE.write_text(str(os.getpid()), encoding="utf-8")
        subprocess.run(cmd, stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=env, cwd=str(HOME), check=False)
        return
    flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
    proc = subprocess.Popen(cmd, stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=env, cwd=str(HOME), creationflags=flags, close_fds=True)
    PID_FILE.write_text(str(proc.pid), encoding="utf-8")


def main() -> int:
    mode = "dry" if "--dry-run" in sys.argv else "wait" if "--wait" in sys.argv else "detach"
    if not (HOME / "palace").is_dir():
        return 0
    try:
        import mempalace  # noqa: F401
    except ImportError:
        return 0
    target = plan()
    changed = sync_mirror(target)
    print(f"mempalace-canon[{WING}]: {len(target)} файлів у дзеркалі, змінено {changed}")
    mine(mode)  # завжди: незмінні файли mine пропускає, пропущений раніше прохід наздоганяється
    return 0


if __name__ == "__main__":
    sys.exit(main())
