#!/bin/zsh
set -euo pipefail
# Usage: ./setup-custom-domain.sh trip.example.com
DOMAIN="${1:?用法: ./setup-custom-domain.sh 你的域名（如 trip.example.com）}"

ROOT="$(cd "$(dirname "$0")" && pwd)"
GH="$ROOT/../.tools/gh_2.101.0_macOS_arm64/bin/gh"
REPO="997523034-maker/aus-trip-2026"

echo "绑定自定义域名: $DOMAIN"

cd "$ROOT"
echo "$DOMAIN" > CNAME
git add CNAME
git commit -m "chore: add custom domain CNAME for GitHub Pages" || true
git -c http.version=HTTP/1.1 push origin main

"$GH" api "repos/$REPO/pages" -X PUT \
  -f cname="$DOMAIN" \
  -f build_type=legacy \
  -f 'source[branch]=main' \
  -f 'source[path]=/' >/dev/null

echo ""
echo "✅ GitHub 已配置。请在 DNS 服务商添加："
echo ""
if [[ "$DOMAIN" == *.*.* ]]; then
  echo "  类型: CNAME"
  echo "  主机: ${DOMAIN%%.*}  （或按面板填子域名前缀）"
  echo "  值:   997523034-maker.github.io"
else
  echo "  类型: A"
  echo "  值:   185.199.108.153"
  echo "        185.199.109.153"
  echo "        185.199.110.153"
  echo "        185.199.111.153"
  echo "  （根域名另加 CNAME www → 997523034-maker.github.io 或 A 同上）"
fi
echo ""
echo "DNS 生效后（通常 5–30 分钟）："
echo "  https://$DOMAIN/"
echo "  https://$DOMAIN/mobile.html"
