#!/usr/bin/env python3
"""PostToolUse на mempalace_search: «детектор відлуння» (wing win11_hardening).

Більшість шухляд — уривки транскриптів (`*.jsonl`), тобто копії стану на дату сесії. Хук дописує
до видачі тип і вік кожного результату; якщо в репо є `inc/site-data.php` з константами
`*_PHONE`/`*_EMAIL` — ще й позначає контакти, що з ними розходяться. Пам'ять — свідчення, не
поточний стан. Помилка скрипта = мовчанка.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

PHONE_RE = re.compile(r"(?<!\d)(?:\+?38[\s\-()]*)?0[\s\-()]*\d{2}[\s\-()]*\d{3}[\s\-()]*\d{2}[\s\-()]*\d{2}(?!\d)")
STALE_DAYS = 14


def canon() -> tuple[set[str], set[str]]:
    root = Path(os.environ.get("CLAUDE_PROJECT_DIR", Path(__file__).resolve().parents[2]))
    site_data = root / "inc" / "site-data.php"
    if not site_data.is_file():
        return set(), set()
    text = site_data.read_text(encoding="utf-8")
    phones = {re.sub(r"\D", "", m) for m in re.findall(r"const\s+\w*PHONE\w*\s*=\s*'([^']+)'", text)}
    emails = {m.lower() for m in re.findall(r"const\s+\w*EMAIL\w*\s*=\s*'([^']+)'", text)}
    return {p for p in phones if p}, emails


def find_results(obj: object) -> list[dict] | None:
    if isinstance(obj, dict):
        if isinstance(obj.get("results"), list):
            return obj["results"]
        for value in obj.values():
            found = find_results(value)
            if found is not None:
                return found
    elif isinstance(obj, list):
        for value in obj:
            found = find_results(value)
            if found is not None:
                return found
    elif isinstance(obj, str) and '"results"' in obj:
        try:
            return find_results(json.loads(obj))
        except ValueError:
            return None
    return None


def age_days(stamp: str) -> int | None:
    try:
        dt = datetime.fromisoformat(stamp.replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        return None
    if dt.tzinfo is None:
        dt = dt.astimezone()  # легасі naive = локальний час (MemPalace 3.12)
    return (datetime.now(timezone.utc) - dt).days


def kind(hit: dict) -> str:
    if "\\.mempalace\\sources\\" in str(hit.get("source_path", "")).replace("/", "\\"):
        return "канон репо"
    src = str(hit.get("source_file", ""))
    if src.endswith(".jsonl"):
        return "транскрипт"
    if str(hit.get("room", "")) == "diary":
        return "щоденник"
    return "курована"


def flags(text: str, phones: set[str], emails: set[str]) -> list[str]:
    out = []
    if phones:
        for raw in {m.group(0) for m in PHONE_RE.finditer(text)}:
            digits = re.sub(r"\D", "", raw)
            digits = "38" + digits if digits.startswith("0") else digits
            if digits not in phones:
                out.append(f"телефон {raw.strip()} не з site-data.php")
    for email in emails:
        domain = email.split("@")[-1]
        for found in {m.lower() for m in re.findall(rf"[\w.+-]+@{re.escape(domain)}", text, re.IGNORECASE)}:
            if found not in emails:
                out.append(f"email {found} не з site-data.php")
    return out


def main() -> None:
    payload = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    results = find_results(payload.get("tool_response"))
    if not results:
        return
    phones, emails = canon()
    lines, echoes = [], 0
    for i, hit in enumerate(results, 1):
        k = kind(hit)
        echoes += k == "транскрипт"
        age = age_days(str(hit.get("filed_at") or hit.get("created_at") or ""))
        age_s = f"{age} дн." if age is not None else "вік ?"
        mark = " ⚠ старе" if age is not None and age > STALE_DAYS and k != "канон репо" else ""
        bad = flags(str(hit.get("text", "")), phones, emails)
        lines.append(f"#{i} {k}, {age_s}{mark}" + ((" ⚠ " + "; ".join(bad)) if bad else ""))
    head = f"Детектор відлуння: {echoes}/{len(results)} результатів — уривки транскриптів (копії стану на дату сесії)."
    tail = "Факт із пам'яті ≠ поточний стан: перед дією звір із репо або живим станом; розбіжність — вір живому."
    out = {"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": "\n".join([head, *lines, tail])}}
    sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
