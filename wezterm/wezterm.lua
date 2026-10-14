local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- Platform detection (macOS + Linux).
local target = wezterm.target_triple
local is_linux = target:find 'linux' ~= nil

local home = os.getenv 'HOME' or wezterm.home_dir

-- Work around a GNOME Wayland HiDPI buffer-scale crash on this machine.
-- Wayland only exists on Linux; guarding keeps this a no-op on macOS.
if is_linux then
  config.enable_wayland = false
end

-- Launch the terminal boot menu when it's installed, otherwise fall back to
-- the default login shell so a machine without the menu still opens cleanly.
local function file_exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

local boot_menu = home .. '/.local/bin/terminal-boot-menu'
if file_exists(boot_menu) then
  config.default_prog = { boot_menu }
end
config.term = 'wezterm'

-- Honor kitty keyboard protocol requests, which report real press/release
-- events instead of bare characters. Terminal emulators (retroemu) need this:
-- without release events a held direction stalls for the OS key-repeat delay.
-- Defaults to false. If the Esc key ever misbehaves, delete this line — older
-- WezTerm builds have a known bug with it.
config.enable_kitty_keyboard = true

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

-- On macOS the left/right Option key still composes accented characters; only
-- the specific Option combos bound below are intercepted. No-op on Linux.
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

local function close_after_tmux_command(window, pane, tmux_keys)
  -- Detaching usually ends the pane's process (ssh is exec'd), so the pane
  -- closes itself. Only close it if it is still around; otherwise
  -- CloseCurrentPane would hit whichever pane became active and can take the
  -- whole window with it.
  local pane_id = pane:pane_id()
  pane:send_text(tmux_keys)
  wezterm.time.call_after(0.2, function()
    local ok, still_open = pcall(wezterm.mux.get_pane, pane_id)
    if ok and still_open then
      window:perform_action(act.CloseCurrentPane { confirm = false }, still_open)
    end
  end)
end

local function send_tmux_command(pane, tmux_keys)
  pane:send_text(tmux_keys)
end

-- Cmd+W ends the current tmux session (detach / kill / cancel) rather than
-- closing the tab, matching the personal config. Alt+W still closes a pane.
local pause_prompt = act.InputSelector {
  title = 'Pause',
  description = 'End Session?',
  alphabet = '123',
  choices = {
    { id = 'pause', label = '1 - Yes' },
    { id = 'kill', label = '2 - Yes - Kill Session' },
    { id = 'cancel', label = '3 - No' },
  },
  action = wezterm.action_callback(function(window, pane, id)
    if id == 'pause' then
      close_after_tmux_command(window, pane, '\x02d')
    elseif id == 'kill' then
      send_tmux_command(pane, '\x02:kill-session\r')
    end
  end),
}

-- Always ask before closing a pane, even when it's only running a shell.
-- WezTerm's own y/n prompt covers just the pane being closed.
config.skip_close_confirmation_for_processes_named = {}

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
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentPane { confirm = true } },
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

  -- macOS Command/Option muscle memory (ported from the personal modules/keys.lua).
  { key = 'Enter', mods = 'SUPER', action = act.ToggleFullScreen },
  { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
  { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
  { key = 'm', mods = 'SUPER', action = act.Hide },
  {
    key = 'a',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      local dims = pane:get_dimensions()
      local text = pane:get_text_from_region(0, dims.scrollback_top, 0, dims.scrollback_top + dims.scrollback_rows)
      window:copy_to_clipboard(text:match '^%s*(.-)%s*$')
    end),
  },
  { key = 'DownArrow', mods = 'SUPER', action = act.ScrollToBottom },
  { key = 'LeftArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Down' },
  -- Option word/char editing (readline-style) at the shell prompt.
  { key = 'LeftArrow', mods = 'OPT', action = act.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1bf' },
  { key = 'Backspace', mods = 'OPT', action = act.SendString '\x1b\x7f' },

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
