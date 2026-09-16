#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
GH="$ROOT/../.tools/gh_2.101.0_macOS_arm64/bin/gh"
REPO_NAME="aus-trip-2026"

if [[ ! -x "$GH" ]]; then
  echo "gh CLI not found at $GH"
  exit 1
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "GitHub 未登录，正在打开浏览器授权..."
  printf '1\n1\nY\n' | "$GH" auth login -h github.com -p https -w
fi

cd "$ROOT"
if ! git remote get-url origin >/dev/null 2>&1; then
  "$GH" repo create "$REPO_NAME" --private --source=. --remote=origin --push
else
  git push -u origin main
fi

"$GH" api "repos/{owner}/$REPO_NAME/pages" \
  -X POST \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/ >/dev/null 2>&1 || true

USER="$("$GH" api user -q .login)"
echo ""
echo "Web:    https://${USER}.github.io/${REPO_NAME}/"
echo "Mobile: https://${USER}.github.io/${REPO_NAME}/mobile.html"
echo "Repo:   https://github.com/${USER}/${REPO_NAME}"
