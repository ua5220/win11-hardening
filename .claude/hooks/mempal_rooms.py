"""Маршрутизатор кімнат mempalace: TF-IDF-словники кімнат, навчені на каноні репо.

Індекс будує `scripts/mempalace-canon.py` (build_index) у `~/.mempalace/sources/_index/<wing>.json`;
хук `mempal-search-router.py` (route) підставляє `room` у mempalace_search, коли впевнений.
Стемінг грубий навмисно: перші STEM символів кириличного слова («деплой», «деплою» → «депло»),
латинські ідентифікатори (`deploy.sh`, `generateblocks`) — цілком. Без залежностей.
"""

import json
import math
import re
from collections import Counter
from pathlib import Path

INDEX_DIR = Path.home() / ".mempalace" / "sources" / "_index"
STEM = 5
TOP_TERMS = 3000
NEVER_TARGET = {"general", "diary"}  # загальні кімнати: фільтр на них = майже «без фільтра», а помилка відсікає відповідь
TOKEN_RE = re.compile(r"[a-zа-яіїєґ0-9][a-zа-яіїєґ0-9_.\-]{2,}", re.IGNORECASE)
STOP = {
    "the", "and", "for", "with", "this", "that", "from", "are", "not", "you", "use", "when", "only", "into", "after",
    "якщо", "лише", "тільки", "також", "через", "після", "перед", "щоб", "його", "вона", "воно", "вони", "цей", "цього",
    "який", "яка", "яке", "які", "для", "або", "але", "без", "під", "над", "між", "так", "ще", "вже", "бо", "що", "як",
    "коли", "де", "там", "тут", "усі", "всі", "кожен", "можна", "треба", "потрібно", "немає", "буде", "було", "були",
}


def terms(text: str) -> list[str]:
    out = []
    for raw in TOKEN_RE.findall(text.lower()):
        tok = raw.strip(".-_")
        if len(tok) < 3 or tok in STOP or tok.isdigit():
            continue
        out.append(tok[:STEM] if re.match(r"[а-яіїєґ]", tok) else tok)
    return out


def build_index(wing: str, docs: dict[str, list[str]]) -> dict:
    """docs: room → тексти. Повертає і записує {room: {term: weight}} з top TOP_TERMS термінів кімнати."""
    tf = {room: Counter(t for text in texts for t in terms(text)) for room, texts in docs.items()}
    df = Counter(t for counts in tf.values() for t in counts)
    rooms = len(tf) or 1
    index = {}
    for room, counts in tf.items():
        total = sum(counts.values()) or 1
        weights = {
            t: (1 + math.log(c)) * math.log((rooms + 1) / (df[t] + 0.5)) * (1 + math.log(1 + 1000 * c / total)) / 3
            for t, c in counts.items()
            if df[t] < rooms or rooms == 1
        }
        best = sorted(weights.items(), key=lambda kv: -kv[1])[:TOP_TERMS]
        index[room] = {t: round(w, 3) for t, w in best if w > 0}
    INDEX_DIR.mkdir(parents=True, exist_ok=True)
    (INDEX_DIR / f"{wing}.json").write_text(json.dumps(index, ensure_ascii=False), encoding="utf-8")
    return index


def load(wing: str) -> dict:
    try:
        return json.loads((INDEX_DIR / f"{wing}.json").read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def route(query: str, wing: str, min_score: float = 2.0, min_ratio: float = 1.4) -> tuple[str | None, list]:
    """(кімната або None, рейтинг [(room, score)]). None — коли не впевнений: тоді пошук без room."""
    index = load(wing)
    q = set(terms(query))
    ranked = sorted(((room, sum(w.get(t, 0.0) for t in q)) for room, w in index.items()), key=lambda kv: -kv[1])
    ranked = [(r, round(s, 2)) for r, s in ranked if s > 0]
    if not ranked or ranked[0][0] in NEVER_TARGET:
        return None, ranked[:3]  # лідер — загальна кімната: тема не специфічна, фільтр не ставимо
    top, second = ranked[0][1], ranked[1][1] if len(ranked) > 1 else 0.0
    confident = top >= min_score and (second == 0 or top / second >= min_ratio)
    return (ranked[0][0] if confident else None), ranked[:3]
