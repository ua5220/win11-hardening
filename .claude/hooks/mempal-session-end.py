#!/usr/bin/env python3
"""MemPalace SessionEnd (wing win11_hardening): фінальний flush сесії, потім оновлення канону репо.

Бюджет SessionEnd у Claude Code — ~1,5 с, тож обгортка лише запускає себе відокремленим
процесом (`--child`) і виходить. Дочірній процес послідовно (без конкуренції за lock палацу)
виконує `mempalace hook run --hook session-end` і `scripts/mempalace-canon.py --wait`.
Без цього хука сесії <15 повідомлень без компакції не зберігались, а маркери
`hook_state/*_last_save` накопичувались (MemPalace 3.12). Помилка = мовчанка.
"""

import os
import subprocess
import sys
from pathlib import Path

WING = "win11_hardening"
env = dict(os.environ, MEMPALACE_WING=WING, PYTHONUTF8="1")
data = sys.stdin.buffer.read()

if "--child" in sys.argv:
    subprocess.run(
        [sys.executable, "-m", "mempalace", "hook", "run", "--hook", "session-end", "--harness", "claude-code"],
        input=data, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env, cwd=os.path.expanduser("~"), check=False,
    )
    canon = Path(__file__).resolve().parents[2] / "scripts" / "mempalace-canon.py"
    if canon.is_file():
        subprocess.run([sys.executable, str(canon), "--wait"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env, check=False)
    sys.exit(0)

base = subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.CREATE_NO_WINDOW
for flags in (base | subprocess.CREATE_BREAKAWAY_FROM_JOB, base):
    try:
        proc = subprocess.Popen(
            [sys.executable, __file__, "--child"],
            stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            env=env, cwd=os.path.expanduser("~"), creationflags=flags, close_fds=True,
        )
        assert proc.stdin is not None
        proc.stdin.write(data)
        proc.stdin.close()
        break
    except OSError:
        continue
sys.exit(0)
