#!/usr/bin/env bash
# Лінт CI, shell-скриптів і секретів: actionlint + zizmor (.github), shellcheck (усі *.sh у git),
# gitleaks (уся історія git; виключення — .gitleaks.toml, перевірені історичні знахідки — .gitleaksignore).
# Падає (код 1) на будь-якій знахідці.
#
# Інструменти (версії однакові локально й у CI):
#   Windows: winget install koalaman.shellcheck --version 0.11.0
#            winget install rhysd.actionlint --version 1.7.12
#            uv tool install zizmor==1.32.0
#            winget install Gitleaks.Gitleaks --version 8.30.1
#   CI:      pipx install shellcheck-py==0.11.0.1; pipx install actionlint-py==1.7.12.25; pipx install zizmor==1.32.0;
#            gitleaks 8.30.1 — архів релізу з перевіркою sha256 (див. workflow); checkout з fetch-depth: 0
# zizmor з GH_TOKEN робить і онлайн-аудити (impostor commits, відомі вразливі actions); без токена — офлайн.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

need() {
	command -v "$1" >/dev/null 2>&1 && return 0
	echo "lint-ci: не знайдено $1 — встановлення див. у шапці scripts/lint-ci.sh" >&2
	exit 1
}

fail=0
if [ -d .github/workflows ]; then
	need actionlint
	need zizmor
	actionlint || fail=1
	zizmor --quiet .github || fail=1
fi

mapfile -t shfiles < <(git ls-files -- '*.sh' '*.bash')
if [ "${#shfiles[@]}" -gt 0 ]; then
	need shellcheck
	shellcheck -x -S warning "${shfiles[@]}" || fail=1
fi

need gitleaks
gitleaks git --redact --no-banner --log-level warn . || fail=1

[ "$fail" -eq 0 ] && echo "lint-ci: workflows, ${#shfiles[@]} shell-скриптів, історія git — 0 зауважень"
exit "$fail"
