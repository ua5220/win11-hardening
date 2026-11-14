#!/usr/bin/env python3
"""UserPromptSubmit: нагадування про mempalace_search (wing win11_hardening) лише для змістовних запитів.

Короткі відповіді («так», «далі») — без нагадування: вони продовжують поточну задачу.
Помилка скрипта = мовчанка.
"""

import json
import sys

MIN_CHARS = 40
REFS = ''
TEXT = (
    "Нагадування (mempalace): якщо це нова нетривіальна задача — виклич "
    'mcp__mempalace__mempalace_search ПЕРЕД тим, як почати діяти: wing "win11_hardening", '
    'candidate_strategy "union" (ембедер англомовний — BM25 ловить українські слова, імена, шляхи, ID), '
    "без max_distance (поріг за сирою відстанню відсікає довгі канонічні документи); для точності — фільтр room." + REFS + " "
    "Уривок транскрипту — свідчення, не факт."
)


def main() -> None:
    payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    if len(str(payload.get("prompt", "")).strip()) < MIN_CHARS:
        return
    out = {"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": TEXT}}
    sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
