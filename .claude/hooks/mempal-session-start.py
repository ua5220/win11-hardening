#!/usr/bin/env python3
"""MemPalace SessionStart (wing win11_hardening): лише ідентичність проєкту (L0), без L1 wake-up.

L1 бере найсвіжіші шухляди wing-а, а це переважно уривки розмов (`*.jsonl`): сирі виклики
інструментів і застарілі на момент наступної сесії факти. Знання з палацу — пошуком
(`mempalace_search`), коли воно потрібне.
"""

import json
import os
import sys

IDENTITY = os.path.expanduser("~/.mempalace/identity_win11_hardening.txt")

try:
    with open(IDENTITY, encoding="utf-8") as fh:
        ctx = fh.read().strip()
except OSError as e:
    ctx = f"mempalace identity unavailable: {e}"

out = {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ctx}}
sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))
