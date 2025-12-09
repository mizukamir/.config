local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.window_background_opacity = 0.85

if wezterm.target_triple == "x86_64-apple-darwin" then
	config.default_prog = { "/usr/local/bin/fish", "-l" }
end

return config
