local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
local home = os.getenv 'HOME'

-- Work around a GNOME Wayland HiDPI buffer-scale crash on this machine.
config.enable_wayland = false

config.default_prog = { home .. '/.local/bin/terminal-boot-menu' }
config.term = 'wezterm'

config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Symbols Nerd Font Mono',
  'Migu 2m Nerd Font',
}
config.font_size = 12.5
config.line_height = 1.08
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.color_scheme = 'Tokyo Night Storm'
config.window_background_opacity = 0.82
config.text_background_opacity = 0.92
config.inactive_pane_hsb = {
  saturation = 0.86,
  brightness = 0.62,
}

config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 18,
  right = 18,
  top = 14,
  bottom = 12,
}
config.initial_cols = 104
config.initial_rows = 30
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_frame = {
  font = wezterm.font { family = 'Migu 2m Nerd Font', weight = 'Bold' },
  font_size = 11.0,
  active_titlebar_bg = '#16161e',
  inactive_titlebar_bg = '#101014',
}

config.colors = {
  tab_bar = {
    background = '#11111a',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#11111a',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#1f2335',
      fg_color = '#a9b1d6',
    },
    inactive_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#c0caf5',
    },
    new_tab = {
      bg_color = '#11111a',
      fg_color = '#7dcfff',
    },
  },
}

config.keys = {
  -- Mac-style muscle memory on this keyboard: Alt is the Command-like key.
  { key = 't', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'ALT', action = act.CloseCurrentPane { confirm = true } },
  { key = 'd', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'ALT|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'ALT|SHIFT', action = act.TogglePaneZoomState },
  { key = 'f', mods = 'ALT', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'k', mods = 'ALT', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'LeftArrow', mods = 'ALT|CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT|CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT|CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT|CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = '[', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(1) },

  -- Super fallback: the Windows key can still behave like Command.
  { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab { confirm = true } },
  { key = 'd', mods = 'SUPER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'SUPER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'SUPER|SHIFT', action = act.TogglePaneZoomState },
  { key = 'f', mods = 'SUPER', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'k', mods = 'SUPER', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'LeftArrow', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize { 'Left', 4 } },
  { key = 'RightArrow', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize { 'Right', 4 } },
  { key = 'UpArrow', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize { 'Up', 2 } },
  { key = 'DownArrow', mods = 'SUPER|SHIFT', action = act.AdjustPaneSize { 'Down', 2 } },
  { key = '[', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },

  -- Same actions without Super for keyboards/window managers that intercept it.
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
}

return config
