#!/data/data/com.termux/files/usr/bin/bash
# termux_auto_bootstrap.sh
# Завантажує скрипти Mobox/Cursor з GitHub у Termux і запускає інсталятор.

set -euo pipefail

REPO_OWNER="proqaz54-dev"
REPO_NAME="Cursor-"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
TARGET_DIR="${HOME}/.local/bin"
SCRIPTS=("install_mobox_termux.sh" "prepare_cursor_mobox.sh")

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
  echo "Завантаження $name"
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

  for script in "${SCRIPTS[@]}"; do
    download_script "$script"
  done

  echo "Встановлення завершено."
  echo "Запуск Mobox-інсталятора..."
  bash "$TARGET_DIR/install_mobox_termux.sh" "$@"
}

main "$@"
