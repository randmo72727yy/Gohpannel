#!/bin/bash
# استفاده:
#   ./genlink.sh <domain-railway-شما> <UUID> [WS_PATH] [نام دلخواه]
#
# مثال:
#   ./genlink.sh myapp-production.up.railway.app b7e2c1a4-... /vless-ws "My VLESS"

set -euo pipefail

DOMAIN="${1:?دامنه Railway را وارد کنید (مثلا myapp.up.railway.app)}"
UUID="${2:?UUID را وارد کنید}"
WS_PATH="${3:-/vless-ws}"
NAME="${4:-VLESS-Railway}"

# چون Railway خودش روی 443 با TLS معتبر ترمینیت می‌کند، همیشه:
#   port = 443, security = tls, type = ws
ENCODED_NAME=$(echo -n "$NAME" | sed 's/ /%20/g')

LINK="vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=${WS_PATH}&sni=${DOMAIN}#${ENCODED_NAME}"

echo "$LINK"
