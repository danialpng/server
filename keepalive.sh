#!/usr/bin/env bash
# جلوگیری از خاموش شدن Codespace به‌خاطر بیکاری (best-effort).
# هر ۵ دقیقه یک درخواست API احرازهویت‌شده می‌فرستد تا نشست فعال بماند.
# نکته: برای اطمینان کامل، در تنظیمات گیت‌هاب
# Settings → Codespaces → Default idle timeout را روی 240 minutes بگذارید.
while true; do
  gh api user > /dev/null 2>&1 || true
  sleep 300
done
