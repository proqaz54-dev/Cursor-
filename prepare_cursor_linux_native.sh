#!/data/data/com.termux/files/usr/bin/bash
# prepare_cursor_linux_native.sh
# Встановлює та налаштовує нативний запуск Cursor (Linux ARM64) у Termux через proot-distro та Termux-X11.

set -euo pipefail

CURSOR_URL="https://downloader.cursor.sh/linux/appImage/arm64"
INSTALL_DIR="$HOME/cursor-native"
DISTRO="ubuntu"

print_usage() {
  cat <<EOF
Usage: $0 [--url URL] [--dir PATH] [--distro NAME] [--help]

Options:
  --url URL       URL для завантаження Linux ARM64 AppImage (за замовчуванням: $CURSOR_URL)
  --dir PATH      Каталог для завантаження та розпакування (за замовчуванням: $INSTALL_DIR)
  --distro NAME   Назва proot-distro дистрибутива (за замовчуванням: $DISTRO)
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
    echo "Встановлюємо потрібний інструмент: $1..." >&2
    pkg install -y "$1"
  fi
}

setup_proot_and_dependencies() {
  echo "Налаштування proot-distro..."
  require_tool proot-distro

  # Перевіряємо чи встановлено дистрибутив
  if ! proot-distro list | grep -q "Installed.*$DISTRO"; then
    echo "Встановлюємо $DISTRO через proot-distro..."
    proot-distro install "$DISTRO"
  else
    echo "Дистрибутив $DISTRO вже встановлено."
  fi

  # Створюємо скрипт для встановлення залежностей всередині proot-distro
  echo "Створення скрипту інсталяції залежностей всередині $DISTRO..."

  local script_path="/tmp/install_deps.sh"
  proot-distro login "$DISTRO" --shared-tmp -- bash -c "cat > $script_path" <<'EOF'
#!/bin/bash
set -e
echo "Оновлення пакетів у контейнері..."
apt-get update -y
echo "Встановлення залежностей для Electron та GUI додатків..."
apt-get install -y --no-install-recommends \
  libasound2 \
  libgbm1 \
  libnss3 \
  libxshmfence1 \
  libglu1-mesa \
  libx11-xcb1 \
  libxcb-dri3-0 \
  libxtst6 \
  libxss1 \
  libgtk-3-0 \
  ca-certificates \
  fonts-dejavu \
  git \
  curl \
  wget
echo "Залежності успішно встановлено!"
EOF

  proot-distro login "$DISTRO" --shared-tmp -- bash "$script_path"
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
        INSTALL_DIR="$WORKDIR"
        ;;
      --distro)
        shift
        DISTRO="$1"
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
  require_tool mkdir
  require_tool tar

  setup_proot_and_dependencies

  mkdir -p "$INSTALL_DIR"
  local appimage_path="$INSTALL_DIR/cursor-arm64.AppImage"

  echo "Завантаження Cursor Linux ARM64 AppImage..."
  curl -L -o "$appimage_path" "$CURSOR_URL"
  chmod +x "$appimage_path"

  echo "Розпакування AppImage (оскільки FUSE не працює в proot без root)..."
  cd "$INSTALL_DIR"

  # Оскільки ми на ARM64, запускаємо AppImage з ключем --appimage-extract для видобування вмісту
  # Це створить каталог squashfs-root
  rm -rf squashfs-root
  ./cursor-arm64.AppImage --appimage-extract

  # Створюємо зручний скрипт запуску для Termux
  cat > "$INSTALL_DIR/run-native.sh" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# Запускає нативний Cursor всередині proot-distro з підтримкою Termux-X11

export DISPLAY=:1
# Запуск proot-distro з прокиданнямDISPLAY та запуском Cursor
proot-distro login $DISTRO --shared-tmp -- bash -c "export DISPLAY=:1; $INSTALL_DIR/squashfs-root/AppRun --no-sandbox --disable-gpu-sandbox"
EOF
  chmod +x "$INSTALL_DIR/run-native.sh"

  cat > "$INSTALL_DIR/README.md" <<EOF
# Нативний Cursor (Linux ARM64) на Android

Ви успішно завантажили та розпакували нативну версію Cursor для архітектури ARM64.
Це забезпечує максимальну продуктивність і швидкість роботи (без емуляції Windows)!

### Як запустити:

1. Встановіть та запустіть **Termux-X11** (X-сервер для Android).
2. Запустіть Termux-X11 у Termux за допомогою команди:
   \`termux-x11 :1 &\`
3. Запустіть Cursor командою:
   \`bash $INSTALL_DIR/run-native.sh\`
4. Відкрийте додаток Termux-X11 на телефоні — ви побачите запущений інтерфейс Cursor!

### Особливості:
- Cursor працює всередині контейнера $DISTRO.
- Використовується прапорець \`--no-sandbox\`, оскільки proot не підтримує пісочницю у віртуалізованому середовищі.
EOF

  echo "========================================================="
  echo "Успішно! Нативний Cursor ARM64 підготовлено у:"
  echo "  $INSTALL_DIR"
  echo ""
  echo "Для детальної інструкції та запуску зверніться до:"
  echo "  cat $INSTALL_DIR/README.md"
  echo "  bash $INSTALL_DIR/run-native.sh"
  echo "========================================================="
}

main "$@"
