#!/usr/bin/env bash
# اجرای X4G داخل Codespace
# - پورت 8000 (فورward شده به URL عمومی app.github.dev)
# - دیتا در ./data (بین ری‌استارت‌های Codespace می‌ماند)
# - رمز ادمین تصادفی ساخته و در data/admin_password.txt ذخیره و چاپ می‌شود
set -e
cd "$(dirname "$0")"

export PORT=8000
export DATA_DIR="$(pwd)/data"
mkdir -p "$DATA_DIR"

if [ ! -s "$DATA_DIR/admin_password.txt" ]; then
  openssl rand -hex 8 > "$DATA_DIR/admin_password.txt" 2>/dev/null || (date +%s%N | sha256sum | head -c 16 > "$DATA_DIR/admin_password.txt")
fi
export ADMIN_PASSWORD="$(cat "$DATA_DIR/admin_password.txt")"

URL_HOST=""
# سعی می‌کنیم دامنهٔ عمومی Codespace را از environment بخوانیم
if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
  URL_HOST="${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

echo "================================================"
echo " 🚀 X4G starting on port $PORT"
if [ -n "$URL_HOST" ]; then
  echo " 🌐 Public URL: https://${URL_HOST}/dashboard"
  echo "    (پورت 8000 باید Public باشد — devcontainer خودش تنظیم می‌کند)"
fi
echo " 🔑 Admin password: $ADMIN_PASSWORD"
echo "    (ذخیره در $DATA_DIR/admin_password.txt)"
echo "================================================"

exec python main.py
