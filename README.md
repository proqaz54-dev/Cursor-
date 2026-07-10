# Cursor-

Цей репозиторій містить інструменти для встановлення `Mobox` у Termux та підготовки модифікованої версії `Cursor` для середовища Mobox.

## Файли

- `install_mobox_termux.sh` — завантажує потрібні компоненти Mobox/Termux та запускає офіційний інсталятор.
- `prepare_cursor_mobox.sh` — створює робочий каталог для адаптації `Cursor` під Mobox.
- `termux_auto_bootstrap.sh` — автоматично завантажує обидва скрипти з GitHub у Termux і запускає Mobox-інсталятор.

## Як використовувати в Termux

1. Встановіть GitHub-репозиторій у Termux через:
   `curl -fsSL https://raw.githubusercontent.com/proqaz54-dev/Cursor-/main/termux_auto_bootstrap.sh -o ~/termux_auto_bootstrap.sh && bash ~/termux_auto_bootstrap.sh`

2. Якщо хочете лише підготувати каталог для Cursor:
   `bash ~/.local/bin/prepare_cursor_mobox.sh --repo <URL_репозиторію_Cursor>`

3. Відредагуйте `~/cursor-mobox/run-cursor-in-mobox.sh` для реального запуску вашого Cursor-проєкту.

4. Запустіть:
   `bash ~/cursor-mobox/run-cursor-in-mobox.sh`

## Примітки

- `install_mobox_termux.sh` використовує офіційний інсталятор з репозиторію [olegos2/mobox](https://github.com/olegos2/mobox).
- Якщо у вас вже встановлено `Termux-X11` та `Input Bridge`, можете запустити: `bash ~/.local/bin/install_mobox_termux.sh --skip-apks`.
- Для роботи `run-cursor-in-mobox.sh` потрібен вихідний код Cursor або компільований бінарник у цільовому каталозі.
