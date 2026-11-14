#!/usr/bin/env python3
"""PreToolUse на mempalace_search (wing win11_hardening): рецепт пошуку — механізмом, а не нагадуванням.

Правка входу (updatedInput замінює весь вхід, тому копіюємо всі поля):
- candidate_strategy → "union", якщо не задано (MiniLM англомовний, BM25 ловить українські слова, шляхи, ID);
- max_distance прибирається (рахується за сирою відстанню й відсікає довгі канонічні шматки);
- room "*" → без фільтра (свідомий другий крок, коли потрібна історія з транскриптів);
- room не задано → маршрутизатор `mempal_rooms.route` (TF-IDF-словники кімнат канону) ставить кімнату,
  лише коли впевнений і лідер — не загальна кімната (general/diary). Пороги — із заміру 2026-11-15
  (23 запити: без room 16/23 у топ-3, з маршрутизатором 19/23, з правильною кімнатою 23/23).
Помилка = мовчанка (пошук іде без змін).
"""

import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репо (import mempal_rooms)
sys.path.insert(0, str(Path(__file__).resolve().parent))

WING = "win11_hardening"
MIN_SCORE, MIN_RATIO = 0.5, 1.0


def main() -> None:
    import mempal_rooms

    payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    original = payload.get("tool_input") or {}
    new = dict(original)
    notes = []
    if not new.get("candidate_strategy"):
        new["candidate_strategy"] = "union"
        notes.append('candidate_strategy="union"')
    if "max_distance" in new:
        new.pop("max_distance")
        notes.append("max_distance прибрано")
    if str(new.get("room", "")).strip() == "*":
        new.pop("room")
        notes.append('room "*" → без фільтра')
    elif not new.get("room"):
        wing = str(new.get("wing") or WING)
        room, ranked = mempal_rooms.route(str(new.get("query", "")), wing, MIN_SCORE, MIN_RATIO)
        if room:
            new["room"] = room
            alt = ", ".join(f"{r} {s}" for r, s in ranked[1:3])
            notes.append(f'room="{room}" (маршрутизатор; далі: {alt or "—"}; без фільтра — room "*")')
    if new == original:
        return
    out = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": "mempalace search recipe",
            "updatedInput": new,
            "additionalContext": "Маршрутизатор пошуку: " + "; ".join(notes) + ".",
        }
    }
    sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
