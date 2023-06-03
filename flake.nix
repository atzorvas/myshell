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
            mkdir -p "$out/config/.zshrc.d"
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
            echo "zshrc copied"
            substituteAll $src/config/.zshrc.d/colors $out/config/.zshrc.d/colors
            substituteAll $src/config/.zshrc.d/completion $out/config/.zshrc.d/completion
            substituteAll $src/config/.zshrc.d/default $out/config/.zshrc.d/default
            substituteAll $src/config/.zshrc.d/fzf $out/config/.zshrc.d/fzf
            substituteAll $src/config/.zshrc.d/lang-java $out/config/.zshrc.d/lang-java
            substituteAll $src/config/.zshrc.d/lang-python $out/config/.zshrc.d/lang-python
            substituteAll $src/config/.zshrc.d/lang-ruby $out/config/.zshrc.d/lang-ruby
            substituteAll $src/config/.zshrc.d/list-mode $out/config/.zshrc.d/list-mode
            substituteAll $src/config/.zshrc.d/vim-mode $out/config/.zshrc.d/vim-mode
            echo "rest zshrc copied"
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
