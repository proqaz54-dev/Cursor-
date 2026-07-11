#!/data/data/com.termux/files/usr/bin/bash
# termux_auto_bootstrap.sh
# Завантажує скрипти Mobox/Cursor з GitHub у Termux і запускає інсталятор.

set -euo pipefail

REPO_OWNER="proqaz54-dev"
REPO_NAME="Cursor-"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
TARGET_DIR="${HOME}/.local/bin"
SCRIPTS=(
  "install_mobox_termux.sh"
  "prepare_cursor_mobox.sh"
  "prepare_cursor_winlator.sh"
  "prepare_cursor_linux_native.sh"
)

require_termux() {
  if [[ -z "${PREFIX:-}" || ! -d "/data/data/com.termux" ]]; then
    echo "Помилка: цей скрипт працює лише в Termux." >&2
    exit 1
  fi
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Помилка: потрібна команда '$1'." >&2
    exit 1
  fi
}

download_script() {
  local name="$1"
  local target="$TARGET_DIR/$name"
  echo "Завантаження $name..."
  mkdir -p "$TARGET_DIR"
  curl -fsSL -o "$target" "$RAW_BASE/$name"
  chmod +x "$target"
  echo "Збережено у $target"
}

main() {
  require_termux
  require_tool curl
  require_tool chmod
  require_tool mkdir

  echo "Завантаження скриптів налаштування Cursor для Android..."
  for script in "${SCRIPTS[@]}"; do
    download_script "$script"
  done

  echo ""
  echo "========================================================="
  echo " Завантаження завершено!"
  echo " Доступні інструменти:"
  echo "========================================================="
  echo " 1) Встановлення Mobox (Wine):"
  echo "    bash $TARGET_DIR/install_mobox_termux.sh"
  echo ""
  echo " 2) Підготовка Cursor для Mobox (Windows x64):"
  echo "    bash $TARGET_DIR/prepare_cursor_mobox.sh"
  echo ""
  echo " 3) Підготовка Cursor для Winlator (Windows x64):"
  echo "    bash $TARGET_DIR/prepare_cursor_winlator.sh"
  echo ""
  echo " 4) Нативний запуск Cursor (Linux ARM64 - НАЙШВИДШИЙ ВАРІАНТ):"
  echo "    bash $TARGET_DIR/prepare_cursor_linux_native.sh"
  echo "========================================================="
  echo ""

  # Якщо аргументи порожні, запитуємо користувача, який режим він хоче запустити
  if [[ $# -eq 0 ]]; then
    echo "Оберіть дію:"
    echo "1. Запустити Mobox-інсталятор (install_mobox_termux.sh)"
    echo "2. Налаштувати нативний Cursor Linux ARM64 (РЕКОМЕНДОВАНО)"
    echo "3. Налаштувати Cursor під Mobox"
    echo "4. Налаштувати Cursor під Winlator"
    echo "5. Вийти"
    read -p "Введіть номер (1-5): " choice
    case "$choice" in
      1) bash "$TARGET_DIR/install_mobox_termux.sh" ;;
      2) bash "$TARGET_DIR/prepare_cursor_linux_native.sh" ;;
      3) bash "$TARGET_DIR/prepare_cursor_mobox.sh" ;;
      4) bash "$TARGET_DIR/prepare_cursor_winlator.sh" ;;
      *) echo "Вихід." ;;
    esac
  else
    echo "Запуск Mobox-інсталятора з переданими параметрами..."
    bash "$TARGET_DIR/install_mobox_termux.sh" "$@"
  fi
}

main "$@"
