local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Same colors as ../ghostty/config. The cursor and selection match Ghostty's
-- defaults when it has no theme: foreground-colored, with inverted text.
config.colors = {
	background = "#1D1E27",
	foreground = "#FDFDFD",
	cursor_bg = "#FDFDFD",
	cursor_fg = "#1D1E27",
	cursor_border = "#FDFDFD",
	selection_bg = "#FDFDFD",
	selection_fg = "#1D1E27",
	ansi = { "#282A2B", "#F3977F", "#5ADECD", "#F272A2", "#886F97", "#C574DD", "#79E6F3", "#FDFDFD" },
	brights = { "#415844", "#FF4971", "#18E3C8", "#FF8037", "#556FFF", "#B0D143", "#3FDCEE", "#BEBEC1" },
}
-- No config.font: WezTerm's built-in JetBrains Mono with Nerd Font icons,
-- the same font Ghostty uses by default.
config.font_size = 14.0
-- Cursor and padding match ../ghostty/config, in the same points.
config.default_cursor_style = "SteadyBar"
config.window_padding = { left = "10pt", right = "10pt", top = "8pt", bottom = "8pt" }
config.hide_tab_bar_if_only_one_tab = true
-- Both Option keys send Alt, and 100,000 lines of history, like ../ghostty/config.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.scrollback_lines = 100000
config.window_decorations = "RESIZE"

-- Let these Cmd keys reach Herdr and Neovim (see ../herdr/config.toml). The
-- kitty keyboard protocol is what carries the Cmd modifier through to them.
config.enable_kitty_keyboard = true
config.keys = {}
for _, key in ipairs({ { "t", "CMD" }, { "w", "CMD" }, { "k", "CMD" }, { "e", "CMD" }, { "g", "CMD|SHIFT" }, { "d", "CMD" }, { "d", "CMD|SHIFT" } }) do
	table.insert(config.keys, { key = key[1], mods = key[2], action = wezterm.action.DisableDefaultAssignment })
end

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

return config
