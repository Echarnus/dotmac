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
brew "azure-cli"
brew "hashicorp/tap/terraform"
brew "scw"                     # Scaleway CLI
brew "mas"                     # Mac App Store CLI
brew "displayplacer"           # scriptable display arrangement

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
cask "spotify"
cask "steam"
cask "nvidia-geforce-now"

# ------------------------------------------------------------------ mac app store
mas "Xcode", id: 497799835
