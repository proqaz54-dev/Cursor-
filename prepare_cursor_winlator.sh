#!/bin/bash
# prepare_cursor_winlator.sh
# Підготовлює каталог для запуску модифікованого Cursor у Winlator.

set -euo pipefail

CURSOR_URL="https://downloader.cursor.sh/windows/nsis/x64"
WORKDIR="$HOME/cursor-winlator"

print_usage() {
  cat <<EOF
Usage: $0 [--url URL] [--dir PATH]

Options:
  --url URL   URL на архів або EXE Cursor для Windows (за замовчуванням: $CURSOR_URL)
  --dir PATH  Каталог для підготовки (за замовчуванням: $WORKDIR)
EOF
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Помилка: потрібна команда '$1'." >&2
    exit 1
  fi
}

download_file() {
  local url="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  echo "Завантажую: $url"
  curl -L -o "$dest" "$url"
}

prepare_winlator_layout() {
  local dir="$1"
  mkdir -p "$dir"

  cat > "$dir/run_cursor.bat" <<'EOF'
@echo off
setlocal
cd /d "%~dp0"

:: Electron-додатки (наприклад, Cursor/VS Code) у Wine потребують відключення пісочниці (--no-sandbox)
:: та інші специфічні параметри для запуску без збоїв.

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

  cat > "$dir/README.txt" <<'EOF'
Cursor for Winlator
===================
1. Цей каталог підготовлено для запуску Cursor під Winlator.
2. Скрипт автоматично завантажив інсталятор і спробував його розпакувати.
3. Якщо автоматичне розпакування не відбулося, розпакуйте 'CursorSetup.exe' за допомогою 7-Zip (або в самому Winlator за допомогою архіватора).
4. Запускайте 'run_cursor.bat' у Winlator для запуску з підтримкою сумісних параметрів (без пісочниці).
EOF
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --url)
        shift
        CURSOR_URL="$1"
        ;;
      --dir)
        shift
        WORKDIR="$1"
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

  require_tool curl
  require_tool mkdir
  require_tool chmod

  prepare_winlator_layout "$WORKDIR"

  if [[ -n "$CURSOR_URL" ]]; then
    local archive="$WORKDIR/CursorSetup.exe"
    download_file "$CURSOR_URL" "$archive"

    if command -v 7z >/dev/null 2>&1; then
      echo "Знайдено 7z. Починаємо автоматичне розпакування..."
      7z x "$archive" -o"$WORKDIR" -y || echo "Увага: розпакування завершилося з деякими попередженнями, але файли могли успішно видобутися."
    elif command -v 7za >/dev/null 2>&1; then
      echo "Знайдено 7za. Починаємо автоматичне розпакування..."
      7za x "$archive" -o"$WORKDIR" -y || echo "Увага: розпакування завершилося з деякими попередженнями."
    else
      echo "Файл завантажено у $archive."
      echo "Встановіть p7zip (pkg install p7zip), щоб скрипт автоматично розпакував його наступного разу."
      echo "Або розпакуйте його вручну безпосередньо у $WORKDIR."
    fi
  else
    echo "URL не вказано. Підготовлено лише шаблон для Winlator."
  fi

  echo "Готово. Матеріали збережено у: $WORKDIR"
}

main "$@"
