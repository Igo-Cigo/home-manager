{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "igor";
  home.homeDirectory = "/home/igor";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.waybar-mpris
    pkgs.vlc
    pkgs.nwg-look
    pkgs.pokeget-rs

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment =
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/igor/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Ghostty
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Propo";
      theme = "detuned";
      confirm-close-surface = false;
      resize-overlay = "never";
    };
  };

  # Waybar
  programs.waybar.enable = true;
  home.file = {
    ".config/waybar/config.jsonc".source = ~/.dots/waybar/config.jsonc;
    ".config/waybar/style.css".source = ~/.dots/waybar/style.css;
  };

  # Hyprland
  #wayland.windowManager.hyprland.enable = true;
  home.file = {
    ".config/hypr/hyprland.conf".source = ~/.dots/hypr/hyprland.conf;
    # ".config/hypr/hyprpaper.conf".source = ~/.dots/hypr/hyprpaper.conf;
  };

  # swww
  services.swww.enable = true;

  # Wofi
  programs.wofi.enable = true;
  home.file = {
    ".config/wofi/style.css".source = ~/.dots/wofi/style.css;
    ".config/wofi/wifimenu".source = ~/.dots/wofi/wifimenu;
    ".config/wofi/powermenu".source = ~/.dots/wofi/powermenu;
  };

  # zsh
  home.file = {
    ".p10k.zsh".source = ~/.dots/zsh/.p10k.zsh;
  };
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      path = ".zsh_history";
      save = 10000; # Has to be the same size as the 'size' variable
      saveNoDups = true;
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreAllDups = true;
      findNoDups = true;
    };
    shellAliases = {
      "editnixconf" = "sudo nano /etc/nixos/configuration.nix";
      "editnixhome" = "nano ~/.config/nixpkgs/home.nix";
      "ls" = "ls --color";
    };
    # Manage plugins
    initContent = ''
      # eval "$(fnm env --use-on-cd)"
      # Initialize powerlevel10k
      if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Initialize zinit
      ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"
      if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname "$ZINIT_HOME")"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      fi
      source "''${ZINIT_HOME}/zinit.zsh"

      # Add in Powerlevel10k
      zinit ice depth=1; zinit light romkatv/powerlevel10k

      # Add in zsh plugins
      zinit light zsh-users/zsh-syntax-highlighting
      zinit light zsh-users/zsh-completions
      zinit light zsh-users/zsh-autosuggestions
      zinit light Aloxaf/fzf-tab

      # Add in snippets
      zinit ice wait lucid; zinit snippet OMZP::sudo
      zinit ice wait lucid; zinit snippet OMZP::command-not-found

      # Load completions
      autoload -U compinit && compinit

      zinit cdreplay -q

      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

      # Keybinds
      # bindkey '^f' autosuggest-accept
      bindkey -e
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
    '';
  };
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  # fastfetch
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "~/.config/fastfetch/victini.txt";
        padding = {
          top = 2;
          left = 2;
        };
      };
      display = {
        separator = " ";
        key = {
          width = 20;
        };
        percent = {
          type = 1;
        };
      };
      modules = [
        "break" "break" "break" "break" "break"
        {
          type = "title";
          color = { host = "italic_light_magenta"; };
        }
        {
          type = "separator";
          string = "═";
          length = 20;
        }
        {
          type = "os";
          format = "{3}";
        }
        {
          type = "shell";
          format = "{6}";
        }
        {
          type = "wm";
          format = "{2}";
        }
        "terminal"
        "memory"
        {
          type = "colors";
          symbol = "square";
        }
      ];
    };
  };
  home.file = {
    ".config/fastfetch/victini.txt".source = ~/.dots/fastfetch/victini.txt;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
