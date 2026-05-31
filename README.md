# wezterm

Личный конфиг [WezTerm](https://wezfurlong.org/wezterm/) под macOS. Зеркалит поведение моего ghostty-конфига: те же шрифт, цвета, поведение Option, табы и keybindings — чтобы переключение между терминалами было незаметным.

## Файлы

- `wezterm.lua` — основной конфиг. Один файл, без сторонних плагинов.

## Зависимости

- macOS (часть настроек завязана на `macos_*` и `cmd`-биндинги).
- [Iosevka Nerd Font Mono](https://github.com/ryanoasis/nerd-fonts/releases) — используется и для основного шрифта терминала, и для полосы табов. Без Nerd-варианта пропадут иконки процессов в заголовках табов.
- Темы `Gruvbox dark, hard (base16)` и `Gruvbox light, hard (base16)` — идут в комплекте с WezTerm, отдельной установки не требуют.

## Что внутри

### Тема

Автопереключение dark/light по системной теме macOS через `wezterm.gui.get_appearance()`. `automatically_reload_config = true` гарантирует, что смена темы системой подхватится без рестарта.

### Шрифт

- `Iosevka Nerd Font Mono`, размер 19.
- `freetype_load_target = 'Light'` + `freetype_render_target = 'HorizontalLcd'` — аналог ghostty-шной `font-thicken`: чуть «жирнее» рендер на Retina без перехода на bold-начертание.

### Курсор

Мигающий блок (`BlinkingBlock`), интервал моргания 500 мс, без easing (`Constant`) — чтобы не «дышал», а просто моргал.

### Окно

- `window_decorations = 'TITLE | RESIZE'` — нативный заголовок macOS с proxy-иконкой текущего cwd в title bar.
- `window_padding` 8/8/6/6, `window_background_opacity = 0.95`, `macos_window_background_blur = 20` — лёгкая прозрачность с blur поверх рабочего стола.
- `scrollback_lines = 10_000_000` — большой буфер прокрутки.

### Табы

Использую `use_fancy_tab_bar = true`. Полоса табов оформлена отдельно от основного шрифта: `Iosevka Nerd Font Mono Bold`, размер 16 — заметно крупнее тела, удобно читать издалека.

- `tab_max_width = 24` — компактные табы, чтобы помещалось много.
- Цвета (Gruvbox-палитра): активный таб `#d65d0e` (neutral orange) на тёмном тексте `#1d2021`; неактивные `#3c3836`/`#a89984`; hover — светлее.
- Кастомный `format-tab-title` показывает: `<index> <иконка> <процесс или OSC-title> <последний сегмент cwd>`. Если приложение выставило заголовок через `OSC 0/1/2`, он имеет приоритет над именем процесса.
- Иконки nerdfonts для частых программ: nvim/vim, ssh, git/lazygit, docker/kubectl/k9s, go/python/node/cargo, make, htop/btop, zellij/tmux, zsh/bash/fish. Остальные — generic terminal.
- Длинные заголовки урезаются через `wezterm.truncate_right` и хвост `…`.

### macOS Option

```
send_composed_key_when_left_alt_is_pressed  = false  -- левый Option = Alt
send_composed_key_when_right_alt_is_pressed = true   -- правый Option = композиция спецсимволов
```

Левый Option работает как Alt — нужно для zellij и других TUI, которые ждут Alt-комбинации. Правый Option сохраняет macOS-композицию (`Option+`, `Option+e`, и т.п.).

### Keybindings

| Сочетание | Действие |
| --- | --- |
| `Alt+←/→/↑/↓` | Шлют корректные CSI (`ESC [1;3D/C/A/B`). Без явного бинда zellij ловил бы macOS-композицию (`ESC f` / `ESC b`) и трактовал её как `Alt+f` → `ToggleFloatingPanes`. |
| `Cmd+←` / `Cmd+→` | Предыдущий / следующий таб (как в iTerm2). |
| `Cmd+Shift+←` / `Cmd+Shift+→` | Подвинуть текущий таб влево / вправо. |

### Мышь

`copy-on-select`: завершение левого выделения → `CompleteSelection('ClipboardAndPrimarySelection')`, то есть копируется и в системный буфер, и в primary. `hide_mouse_cursor_when_typing = true`. Закрытие окна без подтверждения (`window_close_confirmation = 'NeverPrompt'`).

## История шрифтов

Раньше пробовал, но отказался:

- `JetBrains Mono Nerd Font` 18 — слишком «округлый», утомлял глаза на длинных сессиях.
- `MonaspiceNe Nerd Font` 18 — нравились лигатуры, но мелкие детали на Retina размывались.
- `FiraCode Nerd Font` 18 — хороший дефолт, но Iosevka заметно компактнее по ширине, при этом не теряет читаемости. На 16:9 27" это даёт +2–3 колонки на пейн.

Текущий выбор — `Iosevka Nerd Font Mono 19` с FreeType-«утолщением». Из всех протестированных у Iosevka самый предсказуемый рендер при изменении DPI (внешний 4K + встроенный Retina одновременно).

## Соответствие ghostty-конфигу

| ghostty | wezterm |
| --- | --- |
| `theme = dark:Gruvbox Dark,light:Gruvbox Light` | `wezterm.gui.get_appearance()` + `color_scheme` |
| `font-family`, `font-size` | `font`, `font_size` |
| `font-thicken`, `font-thicken-strength` | `freetype_load_target = 'Light'` + `HorizontalLcd` |
| `cursor-style = block`, `cursor-style-blink = true` | `default_cursor_style = 'BlinkingBlock'`, `cursor_blink_rate` |
| `macos-titlebar-style = native`, `macos-titlebar-proxy-icon = visible` | `window_decorations = 'TITLE \| RESIZE'` |
| `macos-option-as-alt = left` | `send_composed_key_when_left_alt_is_pressed = false` |
| `keybind = alt+<dir>=text:\x1b[1;3<X>` | `act.SendString('\x1b[1;3<X>')` |
| `keybind = cmd+left/right = previous/next_tab` | `act.ActivateTabRelative(±1)` |
| `keybind = cmd+shift+left/right = move_tab:±1` | `act.MoveTabRelative(±1)` |
| `copy-on-select` | `mouse_bindings` → `CompleteSelection('ClipboardAndPrimarySelection')` |
| `mouse-hide-while-typing` | `hide_mouse_cursor_when_typing` |
| `confirm-close-surface = false` | `window_close_confirmation = 'NeverPrompt'` |
| `window-padding-x/y` | `window_padding` |
| `scrollback-limit` | `scrollback_lines` |
| `background-opacity` | `window_background_opacity` |
| `background-blur-radius` | `macos_window_background_blur` |
| `window-save-state = always` | нет встроенного аналога; решается плагином `resurrect.wezterm`, пока не подключён |
| `shell-integration = detect`, `... = no-cursor` | не нужно — WezTerm подхватывает OSC-последовательности из shell автоматически |
