{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    neovim
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    # Shell tools from the Datalumina guide: https://learn.datalumina.com/docs/herdr/folders
    BAT_THEME = "TwoDark";
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
    FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --cycle";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept

      # fzf keys: Ctrl+R history, Ctrl+T file, Alt+C folder. zoxide: z and zi.
      if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null; then
        source <(fzf --zsh)
      fi
      command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      ls = "eza";
      ll = "eza -la";
      tree = "eza --tree";
      cat = "bat";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file."Library/Application Support/lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/lazygit/config.yml";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Herdr skill, printed by `herdr --skill` so it matches the installed Herdr.
  # Codex, Pi, and Kimi read ~/.agents/skills; Claude reads ~/.claude/skills.
  # Regenerate after a Herdr update: herdr --skill > home/.agents/skills/herdr/SKILL.md
  home.file.".agents/skills/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/herdr";
  home.file.".claude/skills/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/herdr";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Give Ctrl+arrows to Herdr: turn off the Mission Control, Application
  # windows, and Move left/right a space shortcuts. -dict-add keeps every other
  # shortcut as it is.
  home.activation.freeCtrlArrows = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for id in 32 33 79 80 81 82; do
      run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
        -dict-add "$id" "<dict><key>enabled</key><false/></dict>"
    done
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
