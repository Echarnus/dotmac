# Brewfile — everything Homebrew is responsible for on this machine.
#
# Homebrew installs the *host-level* tools: the shell, the window manager, the
# terminal, the GUI apps. Per-project language toolchains (.NET, node, python,
# java, …) are deliberately NOT here — those come from Nix/devenv per repo, so
# two projects can pin different versions without fighting over a global install.
#
#   brew bundle install --file ~/dotfiles/Brewfile
#
# Re-dump after installing something new:
#   brew bundle dump --file ~/dotfiles/Brewfile --force --describe

tap "arl/arl"
tap "hashicorp/tap"
tap "nikitabobko/tap"

# ---------------------------------------------------------------- shell & prompt
brew "zsh-autosuggestions"     # fish-like inline suggestions
brew "zsh-syntax-highlighting" # command colouring as you type
brew "zoxide"                  # smarter `cd` that learns your habits
brew "fzf"                     # fuzzy finder (drives `gfz` branch picker)
brew "fastfetch"               # login banner; maintained successor to neofetch
brew "stow"                    # symlink manager used to deploy this repo

# ------------------------------------------------------------------ terminal ui
brew "arl/arl/gitmux"          # git status segment for the tmux pane border

# ------------------------------------------------------------------- dev tooling
brew "neovim"
brew "ripgrep"
brew "gh"                      # GitHub CLI
brew "direnv"                  # per-directory env; loads devenv shells on cd
brew "hashicorp/tap/terraform"
brew "mas"                     # Mac App Store CLI
brew "displayplacer"           # scriptable display arrangement

# Cloud CLIs are deliberately NOT here. `az` and `scw` are per-project concerns:
# each scope pins its own version and keeps its own credentials via a scoped
# AZURE_CONFIG_DIR / SCW_CONFIG_PATH, so two clients can never share auth state.
# They come from devenv instead — see ~/Projects/<scope>/devenv.nix:
#   packages = [ pkgs.azure-cli pkgs.scaleway-cli ];

# ------------------------------------------------------------------ window mgmt
cask "nikitabobko/tap/aerospace" # tiling window manager
cask "linearmouse"               # per-device mouse/scroll tuning
cask "caffeine"                  # keep the Mac awake

# ---------------------------------------------------------------------- terminal
cask "iterm2"
cask "font-jetbrains-mono-nerd-font" # required — status bar/prompt use Nerd Font glyphs

# --------------------------------------------------------------------- dev apps
cask "visual-studio-code"
cask "docker-desktop"
cask "dbeaver-community"
cask "sqlcl"
cask "git-credential-manager"
cask "claude"
cask "claude-code"

# ---------------------------------------------------------------------- browsers
cask "vivaldi"        # default browser
cask "google-chrome"

# --------------------------------------------------------------- communication
# signal + whatsapp are floated by aerospace (on-window-detected rules already
# existed in .aerospace.toml before the apps themselves were ever installed).
cask "signal"
cask "whatsapp"
cask "discord"
cask "microsoft-teams"

# ------------------------------------------------------------------------ proton
cask "proton-drive"
cask "proton-mail-bridge"
cask "proton-pass"
cask "protonvpn"

# ------------------------------------------------------------------------- other
cask "figma"
cask "libreoffice"
# Second brain. The vaults themselves live in iCloud and are not installed by
# brew — register them with bootstrap/obsidian-vaults.sh after first launch.
cask "obsidian"
cask "spotify"
cask "steam"
cask "nvidia-geforce-now"

# ------------------------------------------------------------------ mac app store
# `brew bundle install` shells out to mas, and mas 7 needs sudo to install into
# /Applications — so this section prompts for a password and cannot run unattended.
mas "Xcode",   id: 497799835

# iWork. These are the current *universal* App Store listings; the old Mac-only IDs
# (Pages 409201541, Numbers 409203825, Keynote 409183694) are retired and now return
# "No apps found in the App Store for ADAM ID".
mas "Pages",   id: 361309726
mas "Numbers", id: 361304891
mas "Keynote", id: 361285480
