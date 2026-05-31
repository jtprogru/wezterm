local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Theme: авто-переключение dark/light по системной теме macOS
local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Gruvbox dark, hard (base16)"
  end
  return "Gruvbox light, hard (base16)"
end
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

-- Font
-- Прошлые шрифты и их настройки — в README.md.
-- weight = DemiBold: Regular/Medium у Iosevka дают заметно тонкую кириллицу относительно латиницы.
config.font = wezterm.font({ family = "Iosevka Nerd Font Mono", weight = "DemiBold" })
config.font_size = 19
-- Аналог font-thicken: Normal load target + HorizontalLcd рендер.
-- Light, вопреки названию, отключает часть хинтинга и делает штрихи тоньше — не использовать.
config.freetype_load_target = "Normal"
config.freetype_render_target = "HorizontalLcd"

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- macOS window style: нативный заголовок с proxy-иконкой
config.window_decorations = "TITLE | RESIZE"

-- macos-option-as-alt = left:
-- левый Option = Alt (zellij и прочие получают корректные Alt-комбинации),
-- правый Option = composition (Option+символ продолжает работать для спецсимволов).
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Keybindings
config.keys = {
  -- Alt+стрелки → корректные CSI, чтобы zellij не ловил ESC f / ESC b как Alt+f.
  { key = "RightArrow", mods = "ALT", action = act.SendString("\x1b[1;3C") },
  { key = "LeftArrow", mods = "ALT", action = act.SendString("\x1b[1;3D") },
  { key = "UpArrow", mods = "ALT", action = act.SendString("\x1b[1;3A") },
  { key = "DownArrow", mods = "ALT", action = act.SendString("\x1b[1;3B") },

  -- Навигация по табам как в iTerm2
  { key = "LeftArrow", mods = "CMD", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CMD", action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "RightArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },

  -- Shift+Enter → ESC + CR: перенос строки в Claude Code и других TUI
  -- через Zellij. Plain Enter в Zellij перехвачен для autolock,
  -- Shift+Enter под тот биндинг не подпадает.
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
}

-- Copy on select: завершение выделения копирует в системный буфер.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection"),
  },
}

-- Quality of life
config.hide_mouse_cursor_when_typing = true
config.window_close_confirmation = "NeverPrompt"
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.scrollback_lines = 10000000

-- Авто-перечитывать конфиг и подхватывать смену темы системы
config.automatically_reload_config = true

-- Window appearance
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Tab bar: крупные, заметные табы с понятным названием запущенной команды.
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 24

-- Шрифт самой полосы табов крупнее обычного, чтобы заголовки читались издалека.
config.window_frame = {
  font = wezterm.font({ family = "Iosevka Nerd Font Mono", weight = "Bold" }),
  font_size = 16,
}

-- Подсветка активного таба сильнее фоновых, плюс акцентная подложка.
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = "#d4500e",
      fg_color = "#1d2021",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c3836",
      fg_color = "#a89984",
    },
    inactive_tab_hover = {
      bg_color = "#504945",
      fg_color = "#ebdbb2",
      italic = false,
    },
    new_tab = {
      bg_color = "#3c3836",
      fg_color = "#a89984",
    },
    new_tab_hover = {
      bg_color = "#504945",
      fg_color = "#ebdbb2",
    },
  },
}

-- В заголовке таба показываем индекс, реально выполняющийся процесс и cwd.
-- Если активна программа (vim/nvim/ssh/git/…) — она важнее, чем shell.
local PROCESS_ICONS = {
  ["nvim"] = wezterm.nerdfonts.custom_vim,
  ["vim"] = wezterm.nerdfonts.dev_vim,
  ["zsh"] = wezterm.nerdfonts.dev_terminal,
  ["bash"] = wezterm.nerdfonts.dev_terminal,
  ["fish"] = wezterm.nerdfonts.dev_terminal,
  ["ssh"] = wezterm.nerdfonts.mdi_server_network,
  ["git"] = wezterm.nerdfonts.dev_git,
  ["lazygit"] = wezterm.nerdfonts.dev_git,
  ["docker"] = wezterm.nerdfonts.linux_docker,
  ["kubectl"] = wezterm.nerdfonts.linux_docker,
  ["k9s"] = wezterm.nerdfonts.linux_docker,
  ["go"] = wezterm.nerdfonts.dev_go,
  ["python"] = wezterm.nerdfonts.dev_python,
  ["python3"] = wezterm.nerdfonts.dev_python,
  ["node"] = wezterm.nerdfonts.dev_nodejs_small,
  ["cargo"] = wezterm.nerdfonts.dev_rust,
  ["rustc"] = wezterm.nerdfonts.dev_rust,
  ["make"] = wezterm.nerdfonts.seti_makefile,
  ["htop"] = wezterm.nerdfonts.mdi_chart_areaspline,
  ["btop"] = wezterm.nerdfonts.mdi_chart_areaspline,
  ["zellij"] = wezterm.nerdfonts.cod_split_horizontal,
  ["tmux"] = wezterm.nerdfonts.cod_split_horizontal,
}

local function basename(path)
  if not path or path == "" then
    return ""
  end
  return path:gsub("^.*[/\\]", ""):gsub("%.exe$", "")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
  local pane = tab.active_pane
  local proc = basename(pane.foreground_process_name)
  local title = pane.title or ""

  -- Если title переопределён через OSC 0/1/2 — уважаем его.
  local user_set = title ~= "" and title ~= proc and not title:match("^%- ")
  local label = user_set and title or (proc ~= "" and proc or "shell")

  local icon = PROCESS_ICONS[proc] or wezterm.nerdfonts.fa_terminal
  local index = tab.tab_index + 1

  -- cwd как подсказка справа, обрезанная до последнего сегмента.
  local cwd = ""
  if pane.current_working_dir then
    local p = pane.current_working_dir.file_path or ""
    p = p:gsub("/$", "")
    local seg = p:match("([^/]+)$")
    if seg and seg ~= "" then
      cwd = " " .. seg
    end
  end

  local text = string.format(" %d %s %s%s ", index, icon, label, cwd)

  -- Ужмём, если не влезает.
  if #text > max_width then
    text = wezterm.truncate_right(text, max_width - 1) .. "…"
  end

  if tab.is_active then
    return {
      { Attribute = { Intensity = "Bold" } },
      { Text = text },
    }
  end
  return text
end)

return config
