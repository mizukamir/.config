{ config, ... }:

{
  xdg.configFile."sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/sketchybar";
}
