{
  description = "Example nix-darwin system flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};


    settings = builtins.fromJSON (builtins.readFile (builtins.getEnv "PWD" + "/../nix/mysettings.json"));
      user = settings.user;
      host = settings.host;

    configuration = { pkgs, ... }: {
      environment.systemPackages = with pkgs;
        [ vim
          git
        ];

      # Install and activation Tailscale
      services.tailscale.enable = true;

      # JankyBorders
      services.jankyborders = {
        enable = true;
        style="round";
        width=5.0;
        hidpi=true;
        active_color="0xff0080ff";
        inactive_color="0xffa9a9a9";
      };

      # SketchyBar
      services.sketchybar = {
        enable = true;
      };

      # Automatically launch settings for Aerospace
      launchd.user.agents.aerospace = {
        command = "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "${user}";
      homebrew = {
        enable = true;

        taps = [
          "nikitabobko/tap" # For Aerospace
        ];

        casks = [
          "orbstack"
          "aerospace"
          "font-hack-nerd-font"
          "sf-symbols"
          "alt-tab"
          "firefox"
          "google-chrome"
          "raycast"
          "nani"
          "spotify"
        ];

        onActivation = {
          cleanup = "zap";
          autoUpdate= true;
        };
      };

    # Hide Dock settings
      system.defaults.dock = {
      autohide = true;
      autohide-delay = 1000.0;
      autohide-time-modifier = 0.0;
      tilesize = 16;
      static-only = true;
      show-recents = false;
    };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;

      nixpkgs.config.allowUnfree = true;

      users.users.${user}.home = "/Users/${user}";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake
    darwinConfigurations."${host}" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        {
          # nixpkgs.overlays = [ nixpkgs-firefox-darwin.overlay ];
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # home.nix に 変数を渡すための設定
          home-manager.extraSpecialArgs = {
            inherit user;
            gitName = settings.gitName;
            gitEmail = settings.gitEmail;
          };

          # ユーザーごとの設定読み込み
          home-manager.users."${user}" = import ./home.nix;
        }
      ];
    };
    formatter.${system} = pkgs.nixfmt-rfc-style;
  };
}
