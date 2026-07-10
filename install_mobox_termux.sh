#!/data/data/com.termux/files/usr/bin/bash
# install_mobox_termux.sh
# Завантажує компоненти Mobox для Termux та запускає офіційний інсталятор.

set -euo pipefail

TERMUX_APK_URL="https://f-droid.org/repo/com.termux_118.apk"
TERMUX_X11_APK_URL="https://raw.githubusercontent.com/olegos2/mobox/main/components/termux-x11.apk"
INPUT_BRIDGE_APK_URL="https://raw.githubusercontent.com/olegos2/mobox/main/components/inputbridge.apk"
MOBOX_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/olegos2/mobox/main/install"

DOWNLOAD_DIR="$HOME/mobox-install"
APKS_DIR="$DOWNLOAD_DIR/apks"
INSTALL_SCRIPT="$DOWNLOAD_DIR/mobox-install.sh"

print_usage() {
  cat <<EOF
Usage: $0 [--dir PATH] [--skip-apks] [--no-open] [--help]

Options:
  --dir PATH      Каталог для збереження завантажених файлів (за замовчуванням: ${DOWNLOAD_DIR})
  --skip-apks     Не завантажувати APK для Termux-X11 та Input Bridge
  --no-open       Не відкривати APK після завантаження
  --help          Показати цю довідку
EOF
}

require_termux() {
  if [[ -z "${PREFIX:-}" || ! -d "/data/data/com.termux" ]]; then
    echo "Помилка: цей скрипт працює тільки в Termux." >&2
    exit 1
  fi
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Помилка: потрібна команда '$1'. Встановіть її через pkg install $1." >&2
    exit 1
  fi
}

wait_storage() {
  if [[ ! -d "$HOME/storage/shared" ]]; then
    if command -v termux-setup-storage >/dev/null 2>&1; then
      echo "Запит дозволу на доступ до сховища..."
      termux-setup-storage
    fi
    while [[ ! -d "$HOME/storage/shared" ]]; do
      echo "Очікування дозволу на доступ до сховища..." >&2
      sleep 2
    done
  fi
}

download_file() {
  local url="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  echo "Завантаження: $url"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$dest" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$dest" "$url"
  else
    echo "Помилка: не знайдено curl або wget." >&2
    exit 1
  fi

  echo "Збережено: $dest"
}

open_file() {
  local path="$1"
  if command -v termux-open >/dev/null 2>&1; then
    echo "Відкриваю: $path"
    termux-open "$path"
  else
    echo "termux-open не знайдено. Файл залишено у: $path" >&2
  fi
}

main() {
  local install_dir="$DOWNLOAD_DIR"
  local skip_apks=false
  local open_after=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dir)
        shift
        install_dir="$1"
        ;;
      --skip-apks)
        skip_apks=true
        ;;
      --no-open)
        open_after=false
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

  DOWNLOAD_DIR="$install_dir"
  APKS_DIR="$DOWNLOAD_DIR/apks"
  INSTALL_SCRIPT="$DOWNLOAD_DIR/mobox-install.sh"

  require_termux
  require_tool bash
  require_tool mkdir
  require_tool rm
  require_tool cat
  require_tool printf
  require_tool command
  require_tool test
  require_tool sleep
  require_tool pwd
  require_tool basename
  require_tool dirname
  require_tool dirname
  require_tool readlink || true

  mkdir -p "$APKS_DIR"
  wait_storage

  if [[ "$skip_apks" == false ]]; then
    download_file "$TERMUX_X11_APK_URL" "$APKS_DIR/termux-x11.apk"
    download_file "$INPUT_BRIDGE_APK_URL" "$APKS_DIR/inputbridge.apk"
    if [[ "$open_after" == true ]]; then
      open_file "$APKS_DIR/termux-x11.apk"
      open_file "$APKS_DIR/inputbridge.apk"
      echo "Встановіть APK-файли вручну у вашому Android-пакетному менеджері." >&2
    fi
  else
    echo "Пропуск завантаження APK-файлів Termux-X11 та Input Bridge." >&2
  fi

  download_file "$MOBOX_INSTALL_SCRIPT_URL" "$INSTALL_SCRIPT"
  chmod +x "$INSTALL_SCRIPT"

  if [[ "$open_after" == true ]]; then
    echo "Запуск офіційного інсталятора Mobox..."
    bash "$INSTALL_SCRIPT"
  else
    echo "Інсталятор завантажено у: $INSTALL_SCRIPT" >&2
    echo "Запустіть: bash '$INSTALL_SCRIPT'" >&2
  fi
}

main "$@"
