#!/usr/bin/env bash
# بعد از ساخت Codespace اجرا می‌شود: نصب وابستگی‌ها + آماده‌سازی دیتا
set -e
pip install --quiet -r requirements.txt
mkdir -p data
echo "✅ X4G dependencies installed. برای اجرا: bash start.sh"
