#!/data/data/com.termux/files/usr/bin/bash
# install_cursor_android.sh
# Автоматичний інсталятор для запуску Cursor (ПК версії) на Android.
# Скрипт встановлює спеціальний контейнер Ubuntu через proot-distro,
# завантажує нативний Linux ARM64 Cursor, розпаковує його та налаштовує запуск через Termux-X11.

set -euo pipefail

CURSOR_URL="https://downloader.cursor.sh/linux/appImage/arm64"
INSTALL_DIR="$HOME/cursor-android"
DISTRO="ubuntu"

# Кольори для красивого виводу
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
  exit 1
}

require_termux() {
  if [[ -z "${PREFIX:-}" || ! -d "/data/data/com.termux" ]]; then
    error "Цей скрипт призначений тільки для запуску всередині Termux на Android!"
  fi
}

install_packages() {
  log "Оновлення списку пакетів Termux..."
  pkg update -y || warn "Оновлення пакетів завершилося з попередженням. Продовжуємо..."

  log "Встановлення необхідних утиліт (curl, proot-distro, tar, x11-utils)..."
  pkg install -y curl proot-distro tar x11-utils || error "Не вдалося встановити системні пакети Termux."
}

setup_ubuntu_environment() {
  log "Налаштування спеціального Linux контейнера ($DISTRO)..."

  if ! proot-distro list | grep -q "Installed.*$DISTRO"; then
    log "Встановлення Ubuntu..."
    proot-distro install "$DISTRO"
  else
    log "Ubuntu вже встановлено в proot-distro."
  fi

  log "Встановлення графічних бібліотек та системних залежностей для Cursor всередині Ubuntu..."
  local setup_script="/tmp/setup_cursor_deps.sh"

  proot-distro login "$DISTRO" --shared-tmp -- bash -c "cat > $setup_script" <<'EOF'
#!/bin/bash
set -e
echo "Оновлення пакетів репозиторію Ubuntu..."
apt-get update -y

echo "Встановлення залежностей для GUI додатків (Electron, Chromium, GTK3)..."
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
  wget \
  dbus-x11

echo "Залежності всередині Ubuntu успішно встановлено!"
EOF

  proot-distro login "$DISTRO" --shared-tmp -- bash "$setup_script"
}

download_and_extract_cursor() {
  mkdir -p "$INSTALL_DIR"
  cd "$INSTALL_DIR"

  local appimage_file="cursor-arm64.AppImage"

  log "Завантаження оригінального нативного Linux ARM64 AppImage Cursor..."
  curl -L -o "$appimage_file" "$CURSOR_URL"
  chmod +x "$appimage_file"

  log "Розпакування AppImage (це необхідно, оскільки FUSE не підтримується на Android без Root)..."
  rm -rf squashfs-root

  # Оскільки AppImage є glibc-бінарником, ми повинні виконувати розпакування всередині контейнера Ubuntu (proot-distro),
  # де присутні необхідні бібліотеки glibc. Шлях $INSTALL_DIR (під домашньою директорією Termux) повністю доступний у proot.
  proot-distro login "$DISTRO" --shared-tmp -- bash -c "cd '$INSTALL_DIR' && ./'$appimage_file' --appimage-extract" || error "Помилка при розпакуванні AppImage Cursor."

  # Видаляємо громіздкий початковий файл AppImage для економії місця
  rm -f "$appimage_file"
  log "Cursor успішно завантажено та розпаковано!"
}

create_launchers() {
  local launcher_path="$HOME/run_cursor.sh"

  log "Створення пускового скрипта $launcher_path..."

  cat > "$launcher_path" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# Скрипт для запуску Cursor у Termux через Termux-X11 та proot-distro Ubuntu.

# Встановлюємо DISPLAY для виводу графіки у Termux-X11
export DISPLAY=:1

# Запуск Cursor всередині proot-distro Ubuntu з відключеною пісочницею (обов'язково для proot/Wine)
proot-distro login $DISTRO --shared-tmp -- bash -c "export DISPLAY=:1; $INSTALL_DIR/squashfs-root/AppRun --no-sandbox --disable-gpu-sandbox --disable-dev-shm-usage"
EOF

  chmod +x "$launcher_path"
}

print_final_instructions() {
  echo -e "\n${GREEN}========================================================================${NC}"
  echo -e " ${GREEN}Cursor успішно встановлено на ваш Android!${NC}"
  echo -e "${GREEN}========================================================================${NC}"
  echo -e "\nДля запуску Cursor виконайте наступні прості кроки:"
  echo -e "1. Встановіть та запустіть додаток ${YELLOW}Termux-X11${NC} на вашому телефоні."
  echo -e "2. У Termux запустіть графічний X-сервер командою:"
  echo -e "   ${BLUE}termux-x11 :1 &${NC}"
  echo -e "3. Запустіть Cursor однією командою:"
  echo -e "   ${BLUE}./run_cursor.sh${NC}"
  echo -e "4. Відкрийте додаток Termux-X11 — ви побачите запущений повноцінний Cursor!"
  echo -e "\nДля розробки ви можете відкривати будь-яку папку у вашому контейнері."
  echo -e "${GREEN}========================================================================${NC}\n"
}

main() {
  require_termux
  install_packages
  setup_ubuntu_environment
  download_and_extract_cursor
  create_launchers
  print_final_instructions
}

main "$@"
