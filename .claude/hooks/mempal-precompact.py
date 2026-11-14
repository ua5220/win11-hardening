#!/usr/bin/env python3
# MemPalace PreCompact Hook — save context before compaction
import os
import subprocess
import sys

os.environ["MEMPALACE_WING"] = "win11_hardening"
os.environ["PYTHONUTF8"] = "1"

data = sys.stdin.buffer.read()
try:
	result = subprocess.run(
		[sys.executable, "-m", "mempalace", "hook", "run", "--hook", "precompact", "--harness", "claude-code"],
		input=data,
		capture_output=True,
		env=os.environ,
		timeout=30,
	)
	if result.returncode != 0:
		# Діагностика у stderr Claude Code; хук залишається fail-safe (CLAUDE.md → mempalace).
		sys.stderr.buffer.write(result.stderr[-2000:])
	sys.stdout.buffer.write(result.stdout)
except subprocess.TimeoutExpired:
	print("mempalace precompact hook timed out after 30s", file=sys.stderr)
except OSError as e:
	print(f"mempalace precompact hook failed: {e}", file=sys.stderr)
