# dotmac

Personal macOS dotfiles — the full setup for a fresh MacBook, deployed with [GNU Stow](https://www.gnu.org/software/stow/).

The guiding split:

| Layer | Owner | Why |
|---|---|---|
| Host tools (shell, terminal, window manager, GUI apps) | **Homebrew** (`Brewfile`) | One machine-wide version is fine |
| Per-project toolchains (.NET, node, python, java, …) | **Nix / devenv** per repo | Two projects can pin different versions without conflict |
| Config files | **This repo** + `stow` | Symlinked into `$HOME`, so `git pull` updates them live |

Nothing language-specific is installed globally. A repo declares its own toolchain in `devenv.nix`, direnv loads it on `cd`, and the tmux status bar reports whatever Nix actually put on `PATH`.

---

## 📦 What's Included

Each top-level directory is a **stow package** — its internal layout mirrors `$HOME`.

| Package | Deploys to | Contents |
|---|---|---|
| `aerospace` | `~/.aerospace.toml` | Tiling window manager config |
| `tmux` | `~/.tmux.conf`, `~/.tmux-*.sh`, `~/.gitmux.conf` | Terminal multiplexer + status bar |
| `zsh` | `~/.zshrc`, `~/.zprofile` | Shell config |
| `nvim` | `~/.config/nvim/` | LazyVim setup |
| `vscode` | `~/.config/Code/User/` | Settings, keybindings, extension list |
| `direnv` | `~/.config/direnv/` | direnv global config + nix-direnv hook |
| `scripts` | *(sourced in place)* | Shell functions auto-loaded by `.zshrc` |
| `bin` | *(referenced by path)* | Helper executables |

`scripts/` and `bin/` are **not** stowed — `.zshrc` sources `~/dotfiles/scripts/*.sh` directly, and `bin/nix-toolchain` is invoked by absolute path from the tmux config.

### 🚀 AeroSpace
Tiling window manager with vim-like keybindings.
- Workspaces 1–3 pinned to the built-in display, 4–9 to external monitors (`CU34V5C`, `ASUS VG32VQ1B`)
- Chat and Proton apps (Signal, WhatsApp, Proton*) are forced to **floating** layout

### 💻 Tmux
- `.tmux.conf` — settings and keybindings
- `.gitmux.conf` — git status styling for the pane border
- `.tmux-status-bar-left.sh` — toolchain versions (see below)
- `.tmux-status-bar-right.sh` — git status via gitmux
- `.tmux-battery.sh` — battery indicator in the bottom bar

### 🐚 Zsh
Oh My Zsh with the Agnoster theme, deliberately stripped down: directory and git segments are hidden in the prompt because tmux already shows them.
- Plugins: `git`, `zsh-autosuggestions`, `dotnet`, `docker`, `docker-compose`
- Aliases: `ls`, `clr`, `py`, `gfz` (fzf branch picker)
- Integrations: fzf, zoxide, direnv, syntax highlighting, bun, Scaleway and Angular completions
- Startup is **fail-soft** — every optional tool is guarded by `command -v`, so a missing binary never breaks the shell

### 📝 Neovim
LazyVim-based, Tokyo Night, Neo-tree pinned right (width 35), full LSP + completion. See `nvim/.config/nvim/QUICKSTART.md`.

### 🧰 Scripts
- `gdev` (`scripts/azure-devops.sh`) — create a git branch from an Azure DevOps work item assigned to you
- `gmerge` (`scripts/gmerge.sh`) — checkout a branch, pull, return, and merge

### 🤖 Claude Code Skills & Agents
Kept in a **separate private repo** — [`Echarnus/Claude`](https://github.com/Echarnus/Claude) — since some skills contain company-internal logic. Not stored here; dotmac only references them.

```bash
# requires access to the private repo (GitHub auth: `gh auth login`)
git clone https://github.com/Echarnus/Claude.git ~/Developer/Claude
mkdir -p ~/.claude/skills ~/.claude/agents
for d in ~/Developer/Claude/skills/*/; do
  [ -f "$d/SKILL.md" ] && ln -sfn "$d" ~/.claude/skills/"$(basename "$d")"
done
for f in ~/Developer/Claude/agents/*.md; do
  ln -sfn "$f" ~/.claude/agents/"$(basename "$f")"
done
```

Claude Code auto-discovers `~/.claude/skills` and `~/.claude/agents` on start. For the **Claude Desktop** app, skills are added via *Customize → Skills* (upload a zip).

---

## ❄️ Nix, devenv & direnv

Per-project toolchains come from [devenv](https://devenv.sh) (backed by [Determinate Nix](https://determinate.systems)), loaded automatically by direnv.

```bash
# 1. Determinate Nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. devenv + nix-direnv into the default profile
nix profile install nixpkgs#devenv nixpkgs#nix-direnv
```

`direnv/.config/direnv/` (stowed) wires it up:
- `direnvrc` sources the `nix-direnv` hook, which caches built environments so re-entering a directory is instant instead of re-evaluating
- `direnv.toml` sets `hide_env_diff = true`, suppressing the `export +AWK +CC +CXX …` wall on every `cd`; the `direnv: loading …` line still shows

Per project:

```bash
cd ~/Developer/some-project
devenv init      # writes devenv.nix
direnv allow     # approve the directory once
```

Add a language to `devenv.nix` and it appears on `PATH` — **and in the tmux status bar** — with no further wiring.

---

## 🔧 Installation

### Fresh machine

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone
git clone https://github.com/Echarnus/dotmac.git ~/dotfiles
cd ~/dotfiles

# 3. Everything Homebrew owns — CLI tools, GUI apps, the Nerd Font
brew bundle install --file ~/dotfiles/Brewfile

# 4. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Nix + devenv (see section above)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
nix profile install nixpkgs#devenv nixpkgs#nix-direnv

# 6. Symlink the configs
cd ~/dotfiles
stow aerospace tmux zsh nvim vscode direnv

# 7. VS Code extensions
cat ~/.config/Code/User/extensions.txt | xargs -L 1 code --install-extension
```

> **Note on step 4:** Oh My Zsh's installer replaces `~/.zshrc`. Run it *before* `stow zsh`, or re-run `stow --restow zsh` afterwards.

### Terminal font

Set the terminal font to **JetBrainsMono Nerd Font** (installed by the Brewfile) for both *Font* and *Non-ASCII Font*. Without it the status bar glyphs render as boxes.

### Apply

```bash
source ~/.zshrc                    # zsh
tmux source-file ~/.tmux.conf      # tmux (or Ctrl+b then r)
aerospace start                    # window manager
```

---

## 🔄 Updating

```bash
cd ~/dotfiles && git pull
```

Symlinked configs are live immediately; reload the relevant tool as above. AeroSpace needs a restart.

After installing a new Homebrew package, re-dump the Brewfile so the next machine gets it:

```bash
brew bundle dump --file ~/dotfiles/Brewfile --force --describe
```

---

## ✨ The tmux status bar

Two bars, four scripts.

### Pane border (top)

**Left — toolchain versions, read from the loaded Nix environment.**

`.tmux-status-bar-left.sh` delegates to `bin/nix-toolchain`, which resolves versions from the `/nix/store` paths behind the profile's `bin/` symlinks:

```
❄  ❖ .NET 10  ⬢ node 24  ❯ pwsh 7.6  ☕ jdk 21
```

This reports **what Nix actually put on `PATH`** — not what a `.csproj`, `global.json`, `Directory.Build.props` or `package.json` claims. It's also a pure filesystem walk with no subprocesses, which matters because tmux re-runs it every 2 seconds.

The `❄` prefix marks the versions as Nix-sourced. Nothing is printed outside a Nix environment.

Recognised tools, in display order: `.NET`, `node`, `bun`, `deno`, `python3`, `ruby`, `go`, `rust`, `java`, `pwsh`, `terraform`, `psql`. Anything the profile doesn't provide is skipped.

**Right —** git status via gitmux (`.tmux-status-bar-right.sh`).

### Bottom bar
Session name, window list, battery, hostname (only when not on the primary MacBook), date and time.

### Customising

- **Add a tool to the version bar** → append a row to the `tools=()` table in `bin/nix-toolchain`, in the form `binary|label|icon|tmux-colour|version-components`. Run `bin/nix-toolchain` directly (no `--tmux`) to check the output.
- **Change colours or layout** → `set -g status-*` and `pane-border-format` in `tmux/.tmux.conf`.

---

## 📄 License

Personal configuration repository. Use anything you find useful.
