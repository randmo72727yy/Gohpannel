#!/bin/sh
set -e

# حالت تولید کلید REALITY (فقط یک‌بار لازم است اجرا شود)
# اجرا با: railway run در سرویس، یا با ست کردن Start Command موقت روی: /entrypoint.sh keygen
if [ "$1" = "keygen" ]; then
  echo "===================================================="
  echo " REALITY KEYPAIR - این خروجی را کپی کن و نگه دار"
  echo "===================================================="
  xray x25519
  echo "===================================================="
  echo " PrivateKey  -> بگذار در متغیر REALITY_PRIVATE_KEY"
  echo " Password    -> این همان Public Key است، برای ساخت لینک کلاینت (pbk) لازم است"
  echo "===================================================="
  # نگه داشتن کانتینر روشن تا لاگ را بخوانی، بعد دستی متوقفش کن
  sleep 3600
  exit 0
fi

: "${LISTEN_PORT:?LISTEN_PORT تنظیم نشده - همان پورتی که در Railway TCP Proxy به آن اشاره کردی}"
: "${UUID:?UUID تنظیم نشده}"
: "${REALITY_PRIVATE_KEY:?REALITY_PRIVATE_KEY تنظیم نشده - با حالت keygen بسازش}"
: "${REALITY_DEST:?REALITY_DEST تنظیم نشده - مثال: www.microsoft.com:443}"
: "${REALITY_SERVER_NAME:?REALITY_SERVER_NAME تنظیم نشده - مثال: www.microsoft.com}"

export LISTEN_PORT UUID REALITY_PRIVATE_KEY REALITY_DEST REALITY_SERVER_NAME
export REALITY_SHORT_ID="${REALITY_SHORT_ID:-}"

envsubst < /etc/xray/config.template.json > /etc/xray/config.json

echo "Xray در حال اجرا روی 0.0.0.0:${LISTEN_PORT} (VLESS + TCP + REALITY)"
exec xray run -c /etc/xray/config.json
