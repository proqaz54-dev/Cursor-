#!/bin/bash
# prepare_cursor_winlator.sh
# Підготовлює каталог для запуску модифікованого Cursor у Winlator.

set -euo pipefail

CURSOR_URL=""
WORKDIR="$HOME/cursor-winlator"

print_usage() {
  cat <<EOF
Usage: $0 [--url URL] [--dir PATH]

Options:
  --url URL   URL на архів або EXE Cursor для Windows
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
if exist "Cursor.exe" (
  start "Cursor" "Cursor.exe"
) else (
  echo Cursor.exe not found.
  echo Put your modified Cursor build in this folder.
pause
)
EOF

  cat > "$dir/README.txt" <<'EOF'
Cursor for Winlator
===================
1. Помістіть сюди ваш Windows-бінарник Cursor або архів з ним.
2. Якщо це архів .zip/.7z, розпакуйте його в цю папку.
3. Запустіть run_cursor.bat у Winlator.
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
    local archive="$WORKDIR/cursor_download"
    download_file "$CURSOR_URL" "$archive"
    echo "Файл скачано. Розпакуйте його вручну в $WORKDIR"
  else
    echo "URL не вказано. Підготовлено лише шаблон для Winlator."
  fi

  echo "Готово: $WORKDIR"
}

main "$@"
