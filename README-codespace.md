# اجرای X4G در GitHub Codespaces

این نسخه از X4G برای اجرای مستقیم روی **GitHub Codespaces** آماده شده — بدون نیاز به Railway یا VPS.

## نحوهٔ اجرا (۳ قدم)

1. **ساخت Codespace:** در همین ریپو روی دکمهٔ سبز `Code` → تب `Codespaces` → `Create codespace on main` کلیک کنید. بعد از ساخت، وابستگی‌ها خودکار نصب می‌شوند و پورت 8000 به‌صورت **Public** فوروارد می‌شود.
2. **اجرای سرور:** در ترمینال Codespace بنویسید:
   ```bash
   bash start.sh
   ```
   رمز ادمین تصادفی همان‌جا چاپ می‌شود (در `data/admin_password.txt` هم ذخیره است).
3. **دریافت کانفیگ:** پنل روی تب `Ports` با آدرس `https://<name>-8000.app.github.dev` باز می‌شود. وارد `/dashboard` شوید، لینک VLESS را کپی کنید و در v2rayNG / NekoBox / Streisand ایمپورت کنید.

لینک‌های ساخته‌شده به‌صورت خودکار همان دامنهٔ Codespace را با پورت 443 و TLS استفاده می‌کنند — یعنی مستقیم قابل اتصال‌اند (ترابرد VLESS-WS روی فورواردر Codespace که WebSocket را پشتیبانی می‌کند).

## ⏳ عمر Codespace

- Codespace بعد از **بیکاری** خاموش می‌شود (پیش‌فرض ۳۰ دقیقه). در
  `Settings → Codespaces → Default idle timeout` آن را روی **240 minutes** بگذارید.
- اسکریپت `keepalive.sh` را در یک ترمینال جدا اجرا کنید تا نشست فعال بماند (best-effort):
  ```bash
  bash keepalive.sh
  ```
- بعد از خاموشی، Codespace را دوباره Run کنید و `bash start.sh` را بزنید — کانفیگ‌ها و رمز در `./data` می‌مانند.
- سهمیهٔ رایگان: ۱۲۰ core-hour در ماه (با ۲ هسته ≈ ۶۰ ساعت).

## 🔒 امنیت

- ریپو را **Private** نگه دارید؛ آدرس Codespace تصادفی و غیرقابل حدس است ولی رمز پیش‌فرض را عوض کنید.
- رمز ادمین: در پنل `/dashboard` → تغییر رمز، یا فایل `data/admin_password.txt`.
- هرکس لینک را داشته باشد می‌تواند از ترافیک شما استفاده کند — لینک‌ها را مثل رمز عبور نگه دارید.
