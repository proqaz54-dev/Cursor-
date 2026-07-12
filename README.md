# Cursor on Android / Cursor на Android 🚀

Офіційний скрипт для швидкого встановлення та автоматичного налаштування ПК-версії **Cursor** на Android через Termux.

---

## 🇺🇦 Швидкий старт (Українська)

Скопіюйте та вставте цю команду в Termux, щоб повністю автоматично встановити спеціальний контейнер Ubuntu Linux та Cursor для вашого телефону:

```bash
curl -fsSL https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh -o ~/install_cursor_android.sh && chmod +x ~/install_cursor_android.sh && bash ~/install_cursor_android.sh
```

### Як запустити після встановлення:
1. Запустіть додаток **Termux-X11** на телефоні.
2. У Termux запустіть X-сервер:
   ```bash
   termux-x11 :1 &
   ```
3. Запустіть Cursor командою:
   ```bash
   ./run_cursor.sh
   ```
4. Поверніться в додаток **Termux-X11** — і користуйтеся нативним, швидким Cursor прямо на вашому Android!

---

## 🇬🇧 Quick Start (English)

Copy and paste this single command into Termux to automatically install the customized Ubuntu Linux container and native ARM64 Cursor for your Android phone:

```bash
curl -fsSL https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh -o ~/install_cursor_android.sh && chmod +x ~/install_cursor_android.sh && bash ~/install_cursor_android.sh
```

### How to Run:
1. Open the **Termux-X11** app.
2. In Termux, start the X-server:
   ```bash
   termux-x11 :1 &
   ```
3. Launch Cursor:
   ```bash
   ./run_cursor.sh
   ```
4. Open the **Termux-X11** app to code with native ARM64 desktop Cursor!
