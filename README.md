# dotfiles

My Mac setup, managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).
One repo, one command, and a fresh Mac ends up configured the same way every time.

It's built around running coding agents (Claude Code, Codex, Pi, Kimi) side by side in [Herdr](https://herdr.dev), with Neovim and lazygit for reading and reviewing what they write.

Started from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) and reshaped around my own workflow.
The Herdr, Ghostty, and Neovim pieces take ideas from the [Datalumina Herdr guide](https://learn.datalumina.com/docs/herdr).

## What you get

- System settings: dark mode, key repeat, Dock, Finder, trackpad
- Homebrew apps and CLI tools, declared in `configuration.nix`
- Nix user packages: ripgrep, fd, fzf, jq, lazygit, Neovim
- Shell: zsh with autosuggestions, syntax highlighting, aliases, a starship prompt, and the guide's [folder tools](https://learn.datalumina.com/docs/herdr/folders): zoxide (`z`, `zi`), fzf keys (Ctrl+R, Ctrl+T, Alt+C), and `eza` and `bat` in place of `ls` and `cat`
- lazygit: the [guide's config](https://learn.datalumina.com/docs/herdr/lazygit), with `delta` diffs, branch colors per agent, and Esc to quit
- Terminals: WezTerm and Ghostty, kept at the same look and behavior
- Editor: Neovim on [LazyVim](https://www.lazyvim.org), set up as a VS Code-style file viewer
- Herdr: agent multiplexer with a lazygit popup and agent state integrations
- Agent configs: Claude, Codex, and opencode share one `home/AGENTS.md`; Pi gets its own theme, extensions, and settings

Everything uses Dave's colors from the [Datalumina guide](https://learn.datalumina.com/docs/herdr/ghostty): a `#1D1E27` background with a bright custom palette in WezTerm, Ghostty, and Pi, Atom One Dark on that background in Neovim, and the guide's status colors in Herdr.

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: in `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";`.

## Fresh-machine setup

```sh
git clone https://github.com/Rudransh-1508/dotfiles.git
cd dotfiles
```

Read "Make it yours" below first, especially the Homebrew cleanup warning.
Then:

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`. `home.nix` points at config files through that path, so it has to exist before the first build.
3. Checks the `user` in `flake.nix` against your macOS username, and offers to fix it if they differ.
4. Runs the first `darwin-rebuild switch`.

### Validate without applying

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

Most files under `home/` are linked straight into place, so edits to them take effect without a rebuild.
You only need `./rebuild.sh` for package lists, system defaults, and new links.

## Make it yours

- **Username**: run `./bootstrap.sh` (it offers to set it) or change the single `user = "rudranshrathore"` line in `flake.nix`.
  Everything else is threaded from that one variable.
- **Host label** `"mac"`, in three places that must match: `flake.nix`, `rebuild.sh`, and `bootstrap.sh`.
- **Git identity** is deliberately not set by this config. Set it with `git config --global`, or add a `programs.git` block to `home.nix`.

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
Every switch uninstalls any Homebrew formula, cask, or tap that isn't declared in `brews`, `casks`, or `taps`.
Read those lists before your first switch and add anything you want to keep.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, installed for Claude, Codex, and opencode. Edit or delete it if you don't want my instructions.
- The `cc` and `co` aliases run `claude --dangerously-skip-permissions` and `codex --full-auto`. Know what they do before using them.

## Repo tour

- `flake.nix` - entry point. Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system config: macOS defaults and Homebrew.
- `home.nix` - user config: shell, packages, prompt, and the links into `home/`.
- `rebuild.sh` - re-applies the config.
- `home/` - the real config files, linked into place with `mkOutOfStoreSymlink`:
  - `.config/wezterm/wezterm.lua` - WezTerm, with dimmed unfocused windows
  - `.config/ghostty/config` - Ghostty, mirroring the WezTerm look
  - `.config/herdr/config.toml` - Herdr keys, theme, and the lazygit popup
  - `.config/nvim/` - LazyVim config
  - `.claude/settings.json` - Claude Code settings, including the Herdr state hook
  - `.pi/agent/` - Pi themes, extensions, and settings
  - `AGENTS.md` - shared agent instructions
  - `.agents/skills/herdr/` - the Herdr skill for every agent

## Terminals

WezTerm and Ghostty share the same theme, the built-in JetBrains Mono at 14pt, a steady bar cursor, the guide's padding, a solid background, and no titlebar.
Both Option keys work as Alt, and each keeps 100,000 lines of scrollback.
The one difference: only WezTerm dims unfocused windows, because Ghostty has no option for it.
When you change one, change the other.

## Herdr

[Herdr](https://herdr.dev) runs each agent in its own pane and shows in a sidebar which ones are working, blocked, or done.

- Keys follow the [Datalumina guide](https://learn.datalumina.com/docs/herdr/keyboard): Cmd+T new tab, Cmd+W close tab, Cmd+K go to any workspace, tab, or agent, Ctrl+Left/Right for tabs, Ctrl+Up/Down for workspaces, Alt+Up/Down to cycle panes. Cmd+D splits a new pane to the right and Cmd+Shift+D below; these two are not in the guide.
- Cmd+Shift+G (or `Ctrl+B` then `d`) opens lazygit as a popup in the focused pane's folder. `q` closes it.
- `Ctrl+B` stays as the prefix fallback; `Ctrl+B` then `?` lists every binding.
- WezTerm and Ghostty both unbind those Cmd keys so they reach Herdr.
- macOS takes the Ctrl arrows for Mission Control. `home.nix` turns those shortcuts off on every rebuild; log out and back in if they still switch Spaces.
- The sidebar shows a colored dot per agent and two lines per entry. Blue means blocked or done (look at me), violet means working.
- The [auto-title plugin](https://github.com/kryptamine/herdr-auto-title) names each tab after its folder, branch, or the agent's current task, so the sidebar reads like a task list. Install it once per machine, pinned to a release (it needs Go, which `configuration.nix` installs):

```sh
herdr plugin install kryptamine/herdr-auto-title --ref v0.19.0
herdr plugin action invoke herdr.auto-title.restart
```

- The Herdr skill (`home/.agents/skills/herdr/SKILL.md`, linked for Claude, Codex, Pi, and Kimi) lets one agent split a pane, start another agent there, send it work, and read the result. It only activates when you mention Herdr, for example: "Use Herdr to start a codex agent named coder in a split next to you, give it docs/plan.md, and review its diff when it's done." It's printed by `herdr --skill`, so regenerate it after updating Herdr.
- Agent integrations make agents report their own state and let Herdr restore sessions after a restart. Install them once per machine:

```sh
herdr integration install claude
herdr integration install codex
herdr integration install pi
herdr integration install kimi
```

## Neovim

Neovim runs [LazyVim](https://www.lazyvim.org) with a file tree on the left, single click to preview, and double click to keep a file open.
The first launch clones its plugins from GitHub, so it needs network access once.

## Pi

[Pi](https://pi.dev) is optional and not installed by this config. Install it from its owner:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Home Manager links `~/.pi/agent/themes`, `~/.pi/agent/extensions`, `models.json`, and `settings.json` from this repo, and leaves Pi's credentials, sessions, and caches alone.

- `themes/dave.json` is the active theme, built from the terminal palette and Pi's [theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json). `tokyo-night.json` and `rose-pine-moon.json` are kept as alternatives.
- `extensions/calm` adds `/calm`, a quieter presentation mode that hides tool call shells and collapsed thinking. It's MIT licensed; see its `LICENSE`.
- `extensions/terminal-status-title.js` shows a spinner in the terminal title while Pi works.
- `settings.json` pins two third-party packages, `pi-web-access@0.14.0` and `@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6`. They run with your full user permissions, so trust them like any other code.

## License

MIT No Attribution. See `LICENSE`.
