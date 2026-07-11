#!/data/data/com.termux/files/usr/bin/bash
# prepare_cursor_mobox.sh
# Створює робочий каталог для Cursor, призначеного для Mobox/Termux.

set -euo pipefail

CURSOR_URL="https://downloader.cursor.sh/windows/nsis/x64"
PROJECT_REPO_URL=""
INSTALL_DIR="$HOME/cursor-mobox"

# Якщо доступний доступ до спільного сховища, розміщуємо у папці, яка буде диском D: у Mobox
if [[ -d "$HOME/storage/shared" ]]; then
  INSTALL_DIR="$HOME/storage/shared/Cursor"
fi

print_usage() {
  cat <<EOF
Usage: $0 [--url URL] [--repo URL] [--dir PATH] [--help]

Options:
  --url URL       URL для завантаження Cursor Windows (.exe) (за замовчуванням: $CURSOR_URL)
  --repo URL      Git репозиторій з ВАШИМ кодом (проєктом), який ви хочете редагувати в Cursor
  --dir PATH      Каталог для розміщення Cursor (за замовчуванням: ${INSTALL_DIR})
  --help          Показати цю довідку
EOF
}

require_termux() {
  if [[ -z "${PREFIX:-}" || ! -d "/data/data/com.termux" ]]; then
    echo "Помилка: цей скрипт працює лише в Termux." >&2
    exit 1
  fi
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Помилка: потрібна команда '$1'. Встановіть її через pkg install $1." >&2
    exit 1
  fi
}

clone_project_repo() {
  local url="$1"
  local dir="$2"

  echo "Клонуємо ваш проєкт з: $url у $dir/project"
  rm -rf "$dir/project"
  git clone "$url" "$dir/project"
}

download_file() {
  local url="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  echo "Завантаження Cursor: $url"
  curl -fsSL -o "$dest" "$url"
  echo "Збережено у: $dest"
}

create_launchers() {
  local dir="$1"

  # 1. Створюємо run_cursor.bat для запуску всередині Mobox (Wine)
  cat > "$dir/run_cursor.bat" <<'EOF'
@echo off
setlocal
cd /d "%~dp0"

:: Electron-додатки (наприклад, Cursor) у Wine потребують запуску без пісочниці (--no-sandbox)
:: та інші специфічні параметри сумісності.

if exist "Cursor.exe" (
  echo Запуск Cursor.exe з сумісними прапорцями...
  start "" "Cursor.exe" --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage %*
) else if exist "App\Cursor.exe" (
  echo Запуск App\Cursor.exe...
  start "" "App\Cursor.exe" --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage %*
) else (
  echo Cursor.exe не знайдено.
  echo Будь ласка, переконайтеся, що ви завантажили та розпакували Cursor у цю папку.
  pause
)
EOF

  # 2. Створюємо run-cursor-in-mobox.sh для зручного виклику з терміналу Termux
  cat > "$dir/run-cursor-in-mobox.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Інструкція для користувача про запуск Cursor у середовищі Mobox.
cd "$(dirname "$0")"

echo "========================================================="
echo "Для запуску Cursor у середовищі Mobox (Wine):"
echo "1. Відкрийте додаток Termux-X11 та запустіть контейнер Mobox."
echo "2. У провіднику Wine (або робочому столі Mobox) перейдіть на диск D:"
echo "3. Знайдіть папку Cursor і запустіть файл run_cursor.bat."
echo "========================================================="
echo ""
echo "Ця папка містить файл run_cursor.bat, який запускає Cursor"
echo "з прапорцем '--no-sandbox', що є критичним для роботи під Wine."
echo ""
if [[ -d "./project" ]]; then
  echo "Ваш клонований проєкт знаходиться за шляхом: D:\\Cursor\\project"
fi
EOF
  chmod +x "$dir/run-cursor-in-mobox.sh"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --url)
        shift
        CURSOR_URL="$1"
        ;;
      --repo)
        shift
        PROJECT_REPO_URL="$1"
        ;;
      --dir)
        shift
        INSTALL_DIR="$1"
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      *)
        echo "Невідома опція: $1" >&2
        print_usage
        exit 1
        ;;
    esac
    shift
  done

  require_termux
  require_tool curl
  require_tool git
  require_tool bash
  require_tool mkdir

  mkdir -p "$INSTALL_DIR"

  local archive="$INSTALL_DIR/CursorSetup.exe"
  download_file "$CURSOR_URL" "$archive"

  if command -v 7z >/dev/null 2>&1; then
    echo "Знайдено 7z. Автоматично розпаковуємо Cursor..."
    7z x "$archive" -o"$INSTALL_DIR" -y || echo "Увага: розпакування завершилося з деякими попередженнями."
  elif command -v 7za >/dev/null 2>&1; then
    echo "Знайдено 7za. Автоматично розпаковуємо Cursor..."
    7za x "$archive" -o"$INSTALL_DIR" -y || echo "Увага: розпакування завершилося з деякими попередженнями."
  else
    echo "Попередження: 7z/7za не знайдено. Встановіть його через 'pkg install p7zip' для авто-розпакування."
    echo "Вам потрібно буде розпакувати CursorSetup.exe самостійно в каталозі: $INSTALL_DIR"
  fi

  create_launchers "$INSTALL_DIR"

  if [[ -n "$PROJECT_REPO_URL" ]]; then
    clone_project_repo "$PROJECT_REPO_URL" "$INSTALL_DIR"
  fi

  cat > "$INSTALL_DIR/README.md" <<'EOF'
# Cursor on Mobox

Цей каталог призначений для Cursor, який запускається у Mobox/Termux.

Кроки:
1. Запустіть контейнер Mobox через Termux / Termux-X11.
2. Відкрийте провідник (Wine Explorer) або робочий стіл у Mobox.
3. Перейдіть на диск `D:\Cursor` (якщо папка в спільному сховищі) або диск `Z:` / `Y:` (залежно від налаштувань дисків у Mobox).
4. Запустіть `run_cursor.bat`.

Зверніть увагу:
- Скрипт автоматично додає прапорці `--no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage`, без яких Chromium-додатки не працюють під Wine.
EOF

  echo "========================================================="
  echo "Готово! Cursor підготовлено в: $INSTALL_DIR"
  echo "Для детальної інструкції запустіть:"
  echo "  bash $INSTALL_DIR/run-cursor-in-mobox.sh"
  echo "========================================================="
}

main "$@"
