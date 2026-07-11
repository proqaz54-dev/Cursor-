# Cursor on Android / Cursor на Android 🚀

Цей репозиторій містить інструменти та скрипти для встановлення та запуску настільної (ПК) версії популярного AI-редактора коду **Cursor** на пристроях Android.

---

## 🇺🇦 Українська версія

Ми пропонуємо три основні способи запуску Cursor на Android. Кожен спосіб має свої переваги та недоліки:

### 1. Нативний Linux ARM64 (Рекомендовано - найшвидший варіант)
*Запускає офіційну версію Cursor для Linux ARM64 всередині контейнера proot-distro (Ubuntu) за допомогою Termux-X11.*
- **Плюси:** Максимальна швидкість роботи без емуляції, повноцінна апаратна підтримка архітектури процесора, висока стабільність.
- **Мінуси:** Потребує налаштування X-сервера (Termux-X11).

### 2. Через Winlator (Windows-емуляція)
*Запускає Windows-версію Cursor за допомогою емулятора Winlator.*
- **Плюси:** Зручний інтерфейс управління, легке налаштування сенсорного введення та віртуального геймпада/миші.
- **Мінуси:** Емуляція x64 на ARM64 забирає ресурси процесора.

### 3. Через Mobox (Швидка Windows-емуляція)
*Запускає Windows-версію Cursor всередині високоефективного Wine-контейнера Mobox у Termux.*
- **Плюси:** Вища продуктивність емуляції порівняно з Winlator завдяки оптимізованому Box64.
- **Мінуси:** Складніше налаштування керування та миші.

---

## 🚀 Як використовувати (Швидкий старт у Termux)

Встановіть GitHub-репозиторій та завантажте всі необхідні скрипти однією командою в Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/termux_auto_bootstrap.sh -o ~/termux_auto_bootstrap.sh && bash ~/termux_auto_bootstrap.sh
```

Ця команда завантажить чотири основні інструменти у `~/.local/bin/`:
- `prepare_cursor_linux_native.sh` — Налаштування нативного Linux ARM64 Cursor.
- `prepare_cursor_mobox.sh` — Підготовка Cursor для Mobox.
- `prepare_cursor_winlator.sh` — Підготовка Cursor для Winlator.
- `install_mobox_termux.sh` — Офіційний інсталятор Mobox.

---

## 🛠️ Детальні кроки для кожного методу

### Метод 1: Нативний запуск Linux ARM64 (Рекомендовано)
1. Запустіть скрипт налаштування:
   ```bash
   bash ~/.local/bin/prepare_cursor_linux_native.sh
   ```
2. Скрипт автоматично встановить `proot-distro` з `Ubuntu`, завантажить офіційний **Linux ARM64 AppImage** від Cursor, розпакує його (щоб обійти обмеження FUSE в Android) та встановить всі потрібні графічні залежності.
3. Запустіть додаток **Termux-X11** на телефоні.
4. У Termux запустіть X-сервер та стартуйте Cursor:
   ```bash
   termux-x11 :1 &
   bash ~/cursor-native/run-native.sh
   ```
5. Перейдіть у додаток Termux-X11 на екрані вашого пристрою – Cursor готовий до роботи з повною швидкістю процесора!

### Метод 2: Запуск у Winlator (Windows x64)
1. Запустіть підготовку каталогу:
   ```bash
   bash ~/.local/bin/prepare_cursor_winlator.sh
   ```
2. Скрипт автоматично скачає Windows-версію Cursor (`CursorSetup.exe`) і розпакує її (якщо встановлено `p7zip`).
3. Відкрийте Winlator на Android, перейдіть до папки `cursor-winlator` на вашому пристрої (зазвичай у завантаженнях або спільній пам'яті).
4. Запустіть **`run_cursor.bat`** (файл автоматично додає сумісні прапорці `--no-sandbox --disable-gpu-sandbox`, без яких Cursor не запуститься у Wine).

### Метод 3: Запуск у Mobox (Windows x64)
1. Запустіть підготовку:
   ```bash
   bash ~/.local/bin/prepare_cursor_mobox.sh
   ```
2. Скрипт скачає інсталятор і підготує папку `Cursor` у спільному сховищі (вона відображатиметься як диск `D:\` у Mobox).
3. Запустіть інсталятор Mobox, якщо він ще не встановлений:
   ```bash
   bash ~/.local/bin/install_mobox_termux.sh
   ```
4. У середовищі Mobox відкрийте Wine Explorer, перейдіть до `D:\Cursor` та запустіть **`run_cursor.bat`** для безпроблемного запуску без пісочниці.

---

## 📌 Важливі примітки
- **Пісочниця (Sandbox):** Усі Electron-додатки (включаючи Cursor) за замовчуванням запускаються у захищеній пісочниці. Оскільки Wine та Proot не підтримують пісочницю Chromium повністю, скрипти автоматично використовують прапорець `--no-sandbox`.
- **Проєкти:** Ви можете завантажувати власні проєкти у підготовлені папки та відкривати їх у Cursor для повноцінної розробки безпосередньо з телефону чи планшета!

---

## 🇬🇧 English Version

Tools for installing and running the desktop version of **Cursor IDE** on Android via Termux-X11 (Native ARM64), Winlator, or Mobox.

### Installation
Run this quick bootstrap script in Termux:
```bash
curl -fsSL https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/termux_auto_bootstrap.sh -o ~/termux_auto_bootstrap.sh && bash ~/termux_auto_bootstrap.sh
```

### Modes of Operation:
1. **Native Linux ARM64 (Recommended):** Uses `prepare_cursor_linux_native.sh` to extract the official Linux ARM64 AppImage and run it inside a `proot-distro` Ubuntu environment via **Termux-X11**. Provides full hardware CPU performance.
2. **Winlator (Wine):** Uses `prepare_cursor_winlator.sh` to get Windows x64 Cursor and runs it via `run_cursor.bat` inside the Winlator emulator.
3. **Mobox (Wine):** Uses `prepare_cursor_mobox.sh` to place Windows x64 Cursor into the shared disk `D:\Cursor` and launch it with required `--no-sandbox` flags in Mobox.
