# ساخت کانفیگ VLESS (v2ray) روی VPS با GitHub Actions + Tailscale

این ریپو یک GitHub Workflow دارد که:

1. رانر گیت‌هاب را از طریق **Tailscale** به شبکهٔ خصوصی شما وصل می‌کند
2. با SSH (فقط از داخل شبکهٔ تیل‌اسکیل — پورت SSH سرور لازم نیست روی اینترنت باز باشد) به VPS وصل می‌شود
3. **Xray-core** را نصب/به‌روز می‌کند و کانفیگ **VLESS + TCP + Reality** می‌سازد
4. لینک آمادهٔ `vless://` را در **Summary** و **Artifacts** جاب می‌گذارد تا در v2rayNG و مشابه آن ایمپورت کنید

```
GitHub Runner ──Tailscale──> VPS (Xray/VLESS-Reality:443)
     └─ SSH فقط از داخل تیل‌اسکیل، بدون باز بودن SSH روی اینترنت
```

---

## پیش‌نیازها

- یک VPS (اوبونتو ۲۰.۰۴ به بعد / دبیان) با دسترسی root
- اکانت Tailscale (پلن رایگان کافی است)
- یک ریپوی GitHub **خصوصی** (لینک ساخته‌شده شامل UUID است؛ نباید عمومی شود)

## مرحله ۱ — نصب Tailscale روی VPS

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
tailscale ip -4     # مثلاً 100.101.102.103 — این را برای سیکرت VPS_HOST لازم دارید
```

اگر از ACL تگ‌دار استفاده می‌کنید، سرور را تگ بزنید:

```bash
tailscale up --advertise-tags=tag:vps
```

## مرحله ۲ — ساخت OAuth Client در Tailscale

در [کنسول ادمین](https://login.tailscale.com/admin/settings/oauth) → **OAuth clients** → Generate:

- **Scopes:** «Auth Keys» با دسترسی **Write** (در بعضی نسخه‌های UI با نام «Keys»)
- **Tags:** `tag:ci` (حتماً به OAuth کلاینت بدهید وگرنه اتصال ورک‌فلو fail می‌شود)

`Client ID` و `Client Secret` را کپی کنید (Secret فقط یک‌بار نمایش داده می‌شود).

اگر ACL سفارشی دارید، در تب **Access Controls** این را اضافه/تطبیق دهید:

```json
{
  "tagOwners": {
    "tag:ci":  ["autogroup:admin"],
    "tag:vps": ["autogroup:admin"]
  },
  "acls": [
    { "action": "accept", "src": ["tag:ci"], "dst": ["tag:vps:22"] }
  ]
}
```

اگر ACL دستکاری نکرده‌اید (پیش‌فرض allow-all است) همین مرحه کافی است.

## مرحله ۳ — ساخت کلید SSH

روی کامپیوتر خودتان (یا هرجا که راحت‌ترید):

```bash
ssh-keygen -t ed25519 -f vps-deploy-key -N ""
ssh-copy-id -i vps-deploy-key.pub root@SERVER_PUBLIC_IP   # فقط همین یک‌بار از طریق IP عمومی
```

## مرحله ۴ — سیکرت‌های گیت‌هاب

در ریپو: **Settings → Secrets and variables → Actions → New repository secret**

| نام سیکرت | الزامی؟ | مقدار |
|---|---|---|
| `TS_OAUTH_CLIENT_ID` | ✅ | مثلاً `k1234567890abcdef.tailnet-name.ts.net` |
| `TS_OAUTH_CLIENT_SECRET` | ✅ | Client Secret مرحله ۲ |
| `VPS_HOST` | ✅ | آی‌پی Tailscale سرور (`100.x.x.x` — خروجی `tailscale ip -4`) |
| `VPS_SSH_KEY` | ✅ | محتوای کامل فایل `vps-deploy-key` (کلید **خصوصی**) |
| `VPS_USER` | اختیاری | پیش‌فرض `root` |
| `VPS_SSH_PORT` | اختیاری | پیش‌فرض `22` |
| `XRAY_PORT` | اختیاری | پورت کانفیگ VLESS؛ پیش‌فرض `443` |
| `XRAY_UUID` | اختیاری | UUID ثابت (اگر خالی باشد خودکار ساخته و روی سرور ذخیره می‌شود) |
| `REALITY_DEST` | اختیاری | سایت پشت‌صحنهٔ Reality؛ پیش‌فرض `www.microsoft.com:443` |
| `NODE_NAME` | اختیاری | اسم کانفیگ؛ پیش‌فرض `xray-reality` (بدون فاصله) |

## مرحله ۵ — اجرا

تب **Actions** → ورک‌فلو **Deploy Xray (VLESS + Reality) over Tailscale** → **Run workflow** → Run.

- خروجی (دو لینک `vless://`) در تب **Summary** همان جاب و فایل `vless-link.txt` در **Artifacts** است
- لینک اول: با IP عمومی — از هر جایی و بدون نیاز به Tailscale کار می‌کند
- لینک دوم (`-tailscale`): با آی‌پی `100.x` — فقط برای دستگاه‌هایی که Tailscale روشن دارند
- تیک **regenerate** فقط وقتی بزنید که بخواهید UUID و کلیدهای قبلی را باطل کنید

## ایمپورت در کلاینت

لینک را کپی کنید و در برنامه ایمپورت کنید (Clipboard import):

- **اندروید:** v2rayNG ، Hiddify ، Nekobox
- **iOS/macOS:** Streisand ، V2Box ، Shadowrocket
- **ویندوز:** Nekoray ، Hiddify ، v2rayN

---

## چرا Tailscale؟ و سخت‌سازی فایروال

چون کل مدیریت از طریق تیل‌اسکیل انجام می‌شود، می‌توانید روی سرور SSH عمومی را ببندید و فقط این‌ها را باز بگذارید:

```bash
ufw allow 443/tcp        # یا XRAY_PORT شما
ufw allow 41641/udp      # پورت WireGuard تیل‌اسکیل (در صورت استفاده از مستقیم)
# بعد از تست موفق اتصال Tailscale:
ufw deny 22/tcp
```

> ⚠️ قبل از بستن پورت ۲۲ یک بار اتصال تیل‌اسکیل را تست کنید وگرنه دسترسی روت از دست می‌رود (راه نجات: کنسول وب VPS provider).

## رفع اشکال

- **«VPS در دسترس نیست» در جاب:** تگ `tag:ci` را به OAuth کلاینت نداده‌اید، `tagOwners` را تنظیم نکرده‌اید، یا سرور `tailscale down` است (`tailscale status` را روی سرور ببینید).
- **خطای SSH (Permission denied):** سیکرت `VPS_SSH_KEY` باید کلید *خصوصی* کامل با خطوط `BEGIN/END` باشد و پابلیک آن با `ssh-copy-id` روی سرور باشد.
- **پورت ۴۴۳ اشغال است:** (مثلاً nginx/آپاچی دارید) سیکرت `XRAY_PORT` را مثلاً `8443` بگذارید.
- **کلاینت وصل نمی‌شود:** `REALITY_DEST` باید سایت TLS 1.3 باشد. گزینه‌های جایگزین: `yahoo.com:443` ، `www.samsung.com:443` ، `docker.com:443`. بعد از تغییر، ورک‌فلو را دوباره اجرا کنید.
- **لاگ سرور:** `journalctl -u xray -e` و `systemctl status xray`.
- **تغییر پورت/نام/UUID بدون regenerate:** کافی است ورک‌فلو را دوباره اجرا کنید؛ UUID و کلیدها حفظ می‌شوند و فقط لینک‌ها با تنظیمات جدید ساخته می‌شوند.

## نکات امنیتی

- ریپو را **خصوصی** نگه دارید؛ لینک `vless://` معادل رمز عبور شماست.
- اگر لینک لو رفت: ورک‌فلو را با تیک **regenerate** اجرا کنید — همهٔ کلاینت‌ها باید لینک جدید را ایمپورت کنند.
- کلید خصوصی Reality فقط روی سرور در `/usr/local/etc/xray/.reality` می‌ماند و هرگز در لاگ‌های گیت‌هاب چاپ نمی‌شود.
- Tailscale در ایران گاهی (به‌خصوص DERP/رله‌ها) محدود یا کند می‌شود؛ برای مصرف روزمره لینک IP عمومی بهتر است و Tailscale فقط برای مدیریت سرور.
