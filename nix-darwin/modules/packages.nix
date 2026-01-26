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
    fd
    bat
    eza
    dust
    typos
    jq
    ast-grep
    fzf
    lazygit
    bottom
    gdu
    nodejs_24
    wezterm
    neovim
    visidata
    mise
    rustup
    gitleaks
    pre-commit
    zellij

    # Filer for terminal
    yazi
    zoxide
    resvg
    popler
    ffmpeg

    # gui
    obsidian

    # sketchbar font
    sketchybar-app-font

    # Debug
    codelldb-wrapper
  ];
}
