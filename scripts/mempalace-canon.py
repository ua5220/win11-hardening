#!/usr/bin/env python3
"""Канон репо → wing win11_hardening у mempalace: дзеркало ~/.mempalace/sources/win11_hardening + mine + sync.

Палац здебільшого містить уривки транскриптів — копії файлів на дату сесії, які старіють.
Тут лежить ПОТОЧНА версія джерел правди: MemPalace 3.12 при повторному mine спершу пише нові
шухляди, потім прибирає старі, незмінні файли перевикористовують вектори. Тека першого рівня
дзеркала = кімната. Файли з CONFIG["split"] (CHANGELOG) розбиваються по `## `-розділах: closet
бачить лише перші 5 000 символів файлу, а дата в імені стає `content_date` розділу. Після mine
`mempalace sync --apply` у межах дзеркала прибирає шухляди джерел, яких у дзеркалі вже немає.
Шаблон спільний для репо користувача (еталон — avto-advokat).

Запуск: SessionEnd-хук (`--wait`) або post-commit (без прапорця — перезапуск себе відокремлено
з `--wait`). `--dry-run` — показати розкладку без запису. Немає mempalace — тихо виходить.
"""

import os
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath

CONFIG = {'wing': 'win11_hardening',
 'files': [('.claude/CLAUDE.md', 'general'),
           ('README.md', 'general'),
           ('policies/*.txt', 'policies'),
           ('policies/*.inf', 'policies'),
           ('settings/*.ps1', 'settings')],
 'split': [('CHANGELOG.md', 'general')],
 'skills': {}}

REPO = Path(__file__).resolve().parents[1]
HOME = Path.home() / ".mempalace"
WING = CONFIG["wing"]
MIRROR = HOME / "sources" / WING
PID_FILE = HOME / "hook_state" / f"canon-{WING}.pid"
LOG_FILE = HOME / "hook_state" / f"canon-{WING}.log"
SKIP_DIRS = {".git", "node_modules", "vendor", "coverage", "coverage-js", ".cache", ".phpunit.cache", ".superpowers", ".worktrees"}
ENV = dict(os.environ, PYTHONUTF8="1", MEMPALACE_WING=WING)


def mirror_rel(rel: Path) -> Path:
    """Без прихованих тек (`.claude` → `claude`): miner пропускає dot-теки."""
    return Path(*[part.lstrip(".") or part for part in rel.parts])


def split_sections(src: Path, room: str) -> dict[Path, bytes]:
    """`## <заголовок>` → окремий файл `<room>/<stem>/<slug>.md`; slug з дати заголовка, якщо вона є."""
    text = src.read_text(encoding="utf-8")
    parts = re.split(r"(?m)^(?=## )", text)
    out: dict[Path, bytes] = {}
    head = parts[0].strip()
    if head:
        out[Path(room) / src.stem / "_intro.md"] = (head + "\n").encode()
    seen: dict[str, int] = {}
    for part in parts[1:]:
        title = part.splitlines()[0][3:].strip()
        date = re.search(r"\d{4}-\d{2}-\d{2}", title)
        slug = re.sub(r"[^\w.-]+", "-", title).strip("-").lower()[:60] or "section"
        slug = f"{date.group(0)}-{slug}" if date and not slug.startswith(date.group(0)) else slug
        seen[slug] = seen.get(slug, 0) + 1
        name = slug if seen[slug] == 1 else f"{slug}-{seen[slug]}"
        out[Path(room) / src.stem / f"{name}.md"] = f"# {src.stem} — {title}\n\n{part.strip()}\n".encode()
    return out


def plan() -> dict[Path, bytes]:
    out: dict[Path, bytes] = {}
    files = []
    for root, dirs, names in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        files += [Path(root) / n for n in names]
    for src in files:
        rel = PurePosixPath(src.relative_to(REPO).as_posix())
        split = next((room for pattern, room in CONFIG.get("split", []) if rel.full_match(pattern)), None)
        if split:
            out.update(split_sections(src, split))
            continue
        for pattern, room in CONFIG["files"]:
            if rel.full_match(pattern):  # `*` — у межах сегмента, `**` — будь-яка глибина (Python ≥3.13)
                out[Path(room) / mirror_rel(Path(rel))] = src.read_bytes()
                break
    for room, skills in CONFIG.get("skills", {}).items():
        for skill in skills:
            base = REPO / ".claude" / "skills" / skill
            for src in base.glob(CONFIG.get("skill_files", "**/*.md")) if base.is_dir() else []:
                out[Path(room) / "skills" / skill / src.relative_to(base)] = src.read_bytes()
    return out


def config_yaml() -> str:
    rooms = {room for _, room in CONFIG["files"]} | {room for _, room in CONFIG.get("split", [])} | set(CONFIG.get("skills", {}))
    lines = [f"wing: {WING}", "rooms:"]
    for room in sorted(rooms):
        lines += [f"  - name: {room}", f"    description: канон репо ({room})", f"    keywords: [{room}]"]
    return "\n".join(lines) + "\n"


def sync_mirror(target: dict[Path, bytes]) -> int:
    changed = 0
    MIRROR.mkdir(parents=True, exist_ok=True)
    cfg = MIRROR / "mempalace.yaml"
    text = config_yaml()
    if not cfg.is_file() or cfg.read_text(encoding="utf-8") != text:
        cfg.write_text(text, encoding="utf-8")
    for rel, data in target.items():
        dst = MIRROR / rel
        if dst.is_file() and dst.read_bytes() == data:
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(data)
        changed += 1
    keep = {MIRROR / rel for rel in target} | {cfg}
    for path in sorted(MIRROR.rglob("*"), reverse=True):
        if path.is_file() and path not in keep:
            path.unlink()
            changed += 1
        elif path.is_dir() and not any(path.iterdir()):
            path.rmdir()
    return changed


def build_room_index(target: dict[Path, bytes]) -> None:
    """TF-IDF-словники кімнат для маршрутизатора пошуку (`.claude/hooks/mempal_rooms.py`)."""
    try:
        sys.dont_write_bytecode = True  # без __pycache__ у репо
        sys.path.insert(0, str(REPO / ".claude" / "hooks"))
        import mempal_rooms

        docs: dict[str, list[str]] = {}
        for rel, data in target.items():
            docs.setdefault(rel.parts[0], []).append(data.decode("utf-8", "ignore"))
        index = mempal_rooms.build_index(WING, docs)
        print(f"mempalace-canon[{WING}]: індекс кімнат — {len(index)} кімнат")
    except Exception as exc:  # індекс — не критичний: без нього маршрутизатор просто не ставить room
        print(f"mempalace-canon[{WING}]: індекс кімнат не збудовано: {exc}")


def running() -> bool:
    try:
        pid = int(PID_FILE.read_text(encoding="utf-8").strip())
    except (OSError, ValueError):
        return False
    if pid == os.getpid():
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
    mine_cmd = [sys.executable, "-m", "mempalace", "mine", str(MIRROR), "--wing", WING, "--agent", "repo-canon"]
    sync_cmd = [sys.executable, "-m", "mempalace", "sync", str(MIRROR), "--wing", WING]
    if mode == "dry":
        subprocess.run([*mine_cmd, "--dry-run"], env=ENV, check=False)
        subprocess.run([*sync_cmd, "--dry-run"], env=ENV, check=False)
        return
    if running():
        print("mempalace-canon: попередній прохід ще працює — наступний запуск наздожене")
        return
    if mode == "detach":  # post-commit: той самий скрипт з --wait, відокремлено — коміт не чекає
        flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
        proc = subprocess.Popen(
            [sys.executable, __file__, "--wait"], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, env=ENV, cwd=str(HOME), creationflags=flags, close_fds=True,
        )
        PID_FILE.write_text(str(proc.pid), encoding="utf-8")
        return
    PID_FILE.write_text(str(os.getpid()), encoding="utf-8")
    with open(LOG_FILE, "ab") as log:
        done = subprocess.run(mine_cmd, stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=ENV, cwd=str(HOME), check=False)
        if done.returncode == 0:  # прибирати лише після успішного mine
            subprocess.run([*sync_cmd, "--apply"], stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=ENV, cwd=str(HOME), check=False)


def main() -> int:
    mode = "dry" if "--dry-run" in sys.argv else "wait" if "--wait" in sys.argv else "detach"
    if not (HOME / "palace").is_dir():
        return 0
    try:
        import mempalace  # noqa: F401
    except ImportError:
        return 0
    if mode != "detach":
        target = plan()
        changed = sync_mirror(target)
        print(f"mempalace-canon[{WING}]: {len(target)} файлів у дзеркалі, змінено {changed}")
        build_room_index(target)
    mine(mode)  # завжди: незмінні файли mine пропускає, пропущений раніше прохід наздоганяється
    return 0


if __name__ == "__main__":
    sys.exit(main())
