{
  description = "atzorvas' ZSH (myshell) Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pwnvim.url = "github:zmre/pwnvim";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      dependencies = with pkgs;
        [
          bat
          btop
          coreutils
          cowsay # this is here to help with testing
          curl
          direnv
          exa
          exif
          fd
          file
          fzf
          fzy
          git
          gnused
          less
          mdcat # colorize markdown
          pstree
          inputs.pwnvim.packages.${system}.pwnvim
          ripgrep
          starship
          zoxide
          zsh
          zsh-completions
          zsh-autocomplete
          zsh-autosuggestions
          zsh-syntax-highlighting
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ueberzug];

      packages.myshell = with pkgs;
        stdenv.mkDerivation rec {
          version = "1.0.0";
          name = "myshell";
          inherit system;
          src = self;
          buildInputs = [zsh] ++ dependencies;
          nativeBuildInputs = [makeWrapper];
          phases = ["installPhase"];

          installPhase = ''
            mkdir -p "$out/bin"
            mkdir -p "$out/config"
            cp -r $src/config/.zshrc.d $out/config/
            echo "Folders created"
            export zsh_autosuggestions="${pkgs.zsh-autosuggestions}"
            export zsh_autocomplete="${pkgs.zsh-autocomplete}"
            export zsh_syntax_highlighting="${pkgs.zsh-syntax-highlighting}"
            export fzf="${pkgs.fzf}"
            export starship="${pkgs.starship}"
            export zoxide="${pkgs.zoxide}"
            export direnv="${pkgs.direnv}"
            export zsh_completions="${pkgs.zsh-completions}"
            export starshipconfig="${./config/starship.toml}"
            substituteAll $src/config/zshrc $out/config/.zshrc
            makeWrapper "${zsh}/bin/zsh" "$out/bin/myshell" --set SHELL_SESSIONS_DISABLE 1 --set ZDOTDIR "$out/config" --set myshell 1 --prefix PATH : "$out/bin:"${
              pkgs.lib.makeBinPath dependencies
            }
          '';
        };
      apps.myshell = flake-utils.lib.mkApp {
        drv = packages.myshell;
        name = "myshell";
        exePath = "/bin/myshell";
      };
      packages.default = packages.myshell;
      apps.default = apps.myshell;
    });
}
