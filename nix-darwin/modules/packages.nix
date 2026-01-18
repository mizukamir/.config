{ pkgs, ... }:
let
  codelldb-wrapper = pkgs.writeShellScriptBin "codelldb" ''
    exec "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb" "$@"
  '';
in
{
  home.packages = with pkgs; [
    ripgrep
    gh
    lazygit
    bottom
    gdu
    nodejs_24
    wezterm
    neovim
    fd 
    visidata
    mise
    rustup
    gitleaks
    pre-commit
    zellij

    # gui
    obsidian

    # sketchbar font
    sketchybar-app-font

    # Debug
    codelldb-wrapper
  ];
}
