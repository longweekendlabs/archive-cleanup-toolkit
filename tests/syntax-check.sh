#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile "$repo_root/bin/extract-archives-cleanup"
bash -n "$repo_root/bin/find-leftover-archives"

"$repo_root/bin/extract-archives-cleanup" --help >/dev/null
"$repo_root/bin/extract-archives-cleanup" --version >/dev/null
"$repo_root/bin/find-leftover-archives" --help >/dev/null

printf 'Syntax and CLI checks passed.\n'
