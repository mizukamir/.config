{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = {}
        
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
      
      config.automatically_reload_config = true
      config.window_background_opacity = 0.85
      config.default_prog = { "${pkgs.zellij}/bin/zellij" }
 
      -- 装飾系設定
      config.enable_tab_bar = false
      config.window_decorations = "RESIZE"
      
      config.send_composed_key_when_left_alt_is_pressed = true
      config.send_composed_key_when_right_alt_is_pressed = true

      config.keys = {
        { key = 'h', mods = 'CMD', action = act.SendKey { key = 'h', mods = 'ALT' } },
        { key = 'j', mods = 'CMD', action = act.SendKey { key = 'j', mods = 'ALT' } },
        { key = 'k', mods = 'CMD', action = act.SendKey { key = 'k', mods = 'ALT' } },
        { key = 'l', mods = 'CMD', action = act.SendKey { key = 'l', mods = 'ALT' } },
        { key = 'n', mods = 'CMD', action = act.SendKey { key = 'n', mods = 'ALT' } },
        { key = 't', mods = 'CMD', action = act.SendKey { key = 't', mods = 'ALT' } },
      } 
      return config
    '';
  };
}
