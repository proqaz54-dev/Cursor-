#!/data/data/com.termux/files/usr/bin/bash
# prepare_cursor_mobox.sh
# Створює робочий каталог для модифікованої версії Cursor, призначеної для Mobox/Termux.

set -euo pipefail

CURSOR_REPO_URL=""
INSTALL_DIR="$HOME/cursor-mobox"

print_usage() {
  cat <<EOF
Usage: $0 [--repo URL] [--dir PATH] [--help]

Options:
  --repo URL      Git репозиторій з вихідним кодом Cursor
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

clone_cursor_repo() {
  local url="$1"
  local dir="$2"

  echo "Клонуємо Cursor з: $url"
  rm -rf "$dir"
  git clone "$url" "$dir"
}

create_launcher() {
  local dir="$1"
  cat > "$dir/run-cursor-in-mobox.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Запускає Cursor у середовищі Mobox.
# Змініть цю команду, щоб відобразити конкретний запуск вашого Cursor-проєкту.

export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/glibc/lib:$LD_LIBRARY_PATH"

cd "$(dirname "$0")"

echo "Запуск Cursor у Mobox..."
# TODO: замініть ./cursor на реальну команду запуску вашого проєкту
exec ./cursor "$@"
EOF
  chmod +x "$dir/run-cursor-in-mobox.sh"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        shift
        CURSOR_REPO_URL="$1"
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
  require_tool git
  require_tool bash

  mkdir -p "$INSTALL_DIR"

  if [[ -n "$CURSOR_REPO_URL" ]]; then
    clone_cursor_repo "$CURSOR_REPO_URL" "$INSTALL_DIR"
  else
    echo "Увага: URL репозиторію Cursor не вказано. Створюю порожній каталог для майбутнього коду." >&2
  fi

  create_launcher "$INSTALL_DIR"

  cat > "$INSTALL_DIR/README.md" <<'EOF'
# Cursor on Mobox

Цей каталог призначений для адаптованої версії Cursor, яка запускається у Mobox/Termux.

Кроки:
1. Помістіть сюди ваш вихідний код Cursor або клон репозиторію Cursor.
2. Відкрийте і змініть `run-cursor-in-mobox.sh`, щоб команда запуску відповідала вашому проєкту.
3. Запустіть:
   `./run-cursor-in-mobox.sh`

У середовищі Mobox можуть знадобитися:
- `LD_LIBRARY_PATH` з glibc Termux
- `PATH` з термукс-бінарниками
- запуск через `termux-open` або прямий запуск бінарника
EOF

  echo "Готово. Розміщено Cursor у: $INSTALL_DIR"
  echo "Запустіть: $INSTALL_DIR/run-cursor-in-mobox.sh"
  echo "Редагуйте цей файл, щоб він відповідав вашій версії Cursor у Mobox." >&2
}

main "$@"
