# dotmac

Personal macOS dotfiles for a single machine, deployed with GNU Stow. Repo lives at
`~/dotfiles`, remote is `github.com/Echarnus/dotmac`.

Read `README.md` for what each package does and how a fresh machine is set up. This file
covers how to *work* in the repo.

## Nix first

**Reach for Nix before anything else.** When a change could be expressed declaratively in
Nix or imperatively in a shell script / `brew install`, choose Nix — even when the shell
version is shorter today. Declarative, idempotent and versioned beats a script that has to
be run in the right order on a machine you're rebuilding under time pressure.

Order of preference:

1. **nix-darwin** — system-level macOS config: `defaults`, services, fonts, and Homebrew
   itself (`homebrew.brews` / `casks` / `masApps`). This is the destination for everything
   currently in `bootstrap/` and `Brewfile`.
2. **home-manager** — user-level config, when system scope isn't warranted. Notably
   `targets.darwin.defaults` for user defaults without taking over the machine.
3. **devenv** (per project, under `~/Projects/<Scope>/`) — language toolchains. Never
   global, so two clients can pin different versions.
4. **Homebrew / shell script** — last resort, and only for the documented exceptions below.

The `README.md` table (host tools = Homebrew) describes where the repo *is*, not where it
is going. `bootstrap/*.sh` is interim scaffolding; migrating it to nix-darwin is a wanted
change, not a risky one. If you touch that area, prefer moving it toward Nix over
extending the shell scripts.

### Documented exceptions — don't "fix" these

These are outside Nix for concrete reasons. Each one has cost someone an afternoon already:

| Thing | Why it can't be Nix |
|---|---|
| Docker Desktop | Needs system-level install; no working Nix path on macOS |
| SQLcl | nixpkgs marks it `x86_64-linux`-only and unfree — cannot build on Apple Silicon |
| Terraform | Unfree since the 1.6 BUSL relicence; devenv reports it only as an opaque `failed to get drvPath`. Use `pkgs.opentofu` if you want it scoped |
| .NET SDK in `~/.dotnet` | Code signing. C# Dev Kit's Microsoft-signed server can't `dlopen` Nix's ad-hoc-signed `libhostfxr.dylib`. See `bootstrap/README.md` |
| GUI apps (casks) | Signed/notarised `.app` bundles; Homebrew casks are the pragmatic route |

If you believe an exception is now solvable, say so and show the evidence — don't silently
rewrite it.

## Git

- **Push straight to `main`.** No feature branches, no pull requests, no draft PRs. This is
  a single-user config repo; the ceremony buys nothing. Commit and `git push origin main`.
- **Commit subject is `<area>: <what>`**, lowercase after the colon, imperative-ish.
  Match the existing log:
  ```
  bootstrap: add macOS defaults and editor .NET SDK setup
  nix-toolchain: add --powerline banner mode and --extra segments
  Brewfile: add Pages, Numbers and Keynote
  ```
  Add a body only when the *why* isn't obvious from the subject — a non-obvious constraint,
  or a decision someone would otherwise undo.
- **Never add `Co-Authored-By` or "Generated with" trailers.** No AI attribution in commit
  messages or any other git content.
- Don't commit `.DS_Store`, `.claude/worktrees/`, or anything under `.direnv/` / `.devenv/`.

## Layout rules

Each top-level directory is a **stow package** whose internal layout mirrors `$HOME`.
`stow vscode` symlinks `vscode/.config/Code/User/` to `~/.config/Code/User/`. If you add a
file, put it at the path it should occupy under `$HOME`.

Three directories are **not** stowed, and the difference matters:

| Directory | How it runs | Consequence |
|---|---|---|
| `scripts/` | `.zshrc` sources `scripts/*.sh` **on every shell start** | Only shell *functions* belong here. A script that *does* something on load would run on every new terminal |
| `bin/` | Invoked by absolute path (tmux config) | Executables, must stay executable |
| `bootstrap/` | Run once by hand on a fresh machine | Must be idempotent and safe to re-run |

Never put a one-shot setup script in `scripts/`. That is the mistake this table exists to
prevent.

## Conventions

- **Shell startup is fail-soft.** Every optional tool in `.zshrc` is guarded with
  `command -v`, so a missing binary never breaks the shell. Keep it that way.
- **`Brewfile` is hand-curated with comments explaining *why* each group exists.** Don't
  replace it with a raw `brew bundle dump` — that discards the reasoning. To add one
  package, add one line in the right section.
- **`vscode/.config/Code/User/extensions.txt` is curated, not a dump.** `code --list-extensions`
  emits everything ever installed (~59 entries); the tracked list is the ~22 that are
  actually wanted. Add entries deliberately.
- **Extension *enablement* is not tracked.** It lives in `state.vscdb`, a binary SQLite
  file. A globally disabled extension looks exactly like a broken one — if a language
  feature is silently dead, check **Extensions → `@disabled`** before debugging further.
- **Absolute paths in tracked config.** `dotnetAcquisitionExtension.existingDotnetPath` in
  the VS Code settings snapshot hardcodes `/Users/kennethdeclercq/...` because the setting
  does not expand `~`. If the home directory ever changes, that needs a manual fix.
- **Scope beats convenience.** Credentials and cloud CLIs are per-project, never global —
  `AZURE_CONFIG_DIR`, `SCW_CONFIG_PATH`, `GCM_NAMESPACE` are set in each scope's `.envrc`.
  Never run `git config --global` or `gcm configure`.

## Verifying

There are no tests. The ladder, highest rung available:

```bash
bash -n bootstrap/*.sh scripts/*.sh        # syntax
./bootstrap/<script>.sh                    # they're idempotent — actually run them
stow -n -v <package>                       # dry-run the symlinking
```

For anything touching a config file another tool parses (VS Code settings, `.tmux.conf`,
`devenv.nix`), validate it rather than eyeballing — a broken `settings.json` fails silently
and VS Code just ignores the file. State plainly what you verified and what you didn't.
