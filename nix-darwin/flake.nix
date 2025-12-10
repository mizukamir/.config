{
  description = "Example nix-darwin system flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-firefox-darwin, home-manager }:
  let
    settings = builtins.fromJSON (builtins.readFile (builtins.getEnv "PWD" + "/mysettings.json"));
      user = settings.user;
      host = settings.host;
      
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [ vim
          git
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

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
          nixpkgs.overlays = [ nixpkgs-firefox-darwin.overlay ];
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
  };
}
