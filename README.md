# Cursor on Android / Cursor на Android 🚀

Офіційний скрипт для швидкого встановлення та автоматичного налаштування ПК-версії **Cursor** на Android через Termux.

---

## 🇺🇦 Інструкція встановлення (Українська)

Ви можете обрати один із двох способів встановлення: швидкий в один рядок або покроковий.

### Спосіб 1: Швидке встановлення в одну команду (Рекомендовано)
Скопіюйте та вставте цю команду в Termux. Вона сама завантажить скрипт, дасть права на запуск та запустить встановлення:

```bash
wget -qO ~/install_cursor_android.sh https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh && chmod +x ~/install_cursor_android.sh && bash ~/install_cursor_android.sh
```

---

### Спосіб 2: Покрокове встановлення (Крок за кроком)

**Крок 1. Завантажте скрипт на свій телефон через `wget`:**
```bash
wget https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh -O ~/install_cursor_android.sh
```

**Крок 2. Надайте дозволи на запуск завантаженого скрипту (chmod):**
```bash
chmod +x ~/install_cursor_android.sh
```

**Крок 3. Запустіть сам скрипт інсталяції в Termux:**
```bash
./install_cursor_android.sh
```

---

### Як запустити Cursor після встановлення:
1. Запустіть додаток **Termux-X11** на телефоні.
2. У Termux запустіть X-сервер у фоновому режимі:
   ```bash
   termux-x11 :1 &
   ```
3. Запустіть Cursor командою:
   ```bash
   ./run_cursor.sh
   ```
4. Поверніться в додаток **Termux-X11** — повноцінний настільний Cursor готовий до використання з нативною швидкістю процесора!

---

## 🇬🇧 Installation Guide (English)

You can choose either the quick one-liner installation or the detailed step-by-step method.

### Option 1: Quick One-Line Installation (Recommended)
Copy and paste this command into Termux to download, set permissions, and run the installation script automatically:

```bash
wget -qO ~/install_cursor_android.sh https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh && chmod +x ~/install_cursor_android.sh && bash ~/install_cursor_android.sh
```

---

### Option 2: Step-by-Step Installation

**Step 1. Download the script using `wget`:**
```bash
wget https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/install_cursor_android.sh -O ~/install_cursor_android.sh
```

**Step 2. Grant executable permissions to the downloaded script (chmod):**
```bash
chmod +x ~/install_cursor_android.sh
```

**Step 3. Run the installer script in Termux:**
```bash
./install_cursor_android.sh
```

---

### How to Run Cursor:
1. Open the **Termux-X11** app on your phone.
2. Start the X-server in Termux:
   ```bash
   termux-x11 :1 &
   ```
3. Launch Cursor:
   ```bash
   ./run_cursor.sh
   ```
4. Return to the **Termux-X11** app – now code with native ARM64 desktop Cursor!
