# Bootstrap

One-shot setup scripts for a fresh machine. **Not stowed and not sourced** — unlike
`scripts/`, which `.zshrc` loads on every shell start, everything here is run by hand
exactly once (and is safe to re-run later).

| Script | What it does |
|---|---|
| `macos-defaults.sh` | macOS system preferences via `defaults write` |
| `vscode-dotnet-sdk.sh` | Installs Microsoft's signed .NET SDK into `~/.dotnet` for VS Code's C# extensions |
| `obsidian-vaults.sh` | Points a fresh Obsidian install at the iCloud note vaults |

```bash
~/dotfiles/bootstrap/macos-defaults.sh
~/dotfiles/bootstrap/vscode-dotnet-sdk.sh
~/dotfiles/bootstrap/obsidian-vaults.sh
```

---

## `macos-defaults.sh`

Currently one setting: **F1–F12 as real function keys** (`com.apple.keyboard.fnState`),
so the media controls move onto `fn`+F-key. Without it every F-key an editor cares about
— F2 rename, F5 run, F12 go-to-definition — needs `fn` held down.

macOS reads this at login, so **log out and back in** afterwards. Flipping it by hand in
*System Settings → Keyboard → Keyboard Shortcuts → Function Keys* applies immediately if
you don't want to wait.

---

## `obsidian-vaults.sh`

The vaults live in iCloud Drive at
`~/Library/Mobile Documents/com~apple~CloudDocs/Notes/` — `ClercqIt` (the second brain),
`Personal` and `Cooking`. Each already carries its own `.obsidian/` folder, so themes,
plugins and hotkeys sync down with the notes.

What does **not** sync is Obsidian's list of known vaults. That is machine-local state in
`~/Library/Application Support/obsidian/obsidian.json`, so a fresh install opens the empty
vault picker and expects you to find the `com~apple~CloudDocs` path by hand, once per vault.
This script seeds that file instead — any directory under `Notes/` containing a `.obsidian`
folder is registered, so a future fourth vault needs no change here.

Two things worth knowing:

- **Quit Obsidian first.** It rewrites `obsidian.json` wholesale on exit, so edits made
  underneath a running instance vanish when you quit it. The script refuses to run rather
  than fail silently.
- **It is a script, not home-manager config**, because `obsidian.json` is mutable state —
  Obsidian stores window geometry and the last-open vault there. It can be seeded, but it
  can never be a symlink into a read-only store.

---

## `vscode-dotnet-sdk.sh`

This is the one exception to *"no language toolchains installed globally"*, and it is
worth understanding before assuming it is a mistake.

C# Dev Kit's server binary is Microsoft-signed and runs under the macOS hardened runtime.
It **cannot** load `libhostfxr.dylib` from a Nix-provided .NET SDK, because Nix signs its
libraries ad-hoc with no Team Identifier:

```
code signature ... not valid for use in process: mapping process and mapped file
(non-platform) have different Team IDs
.NET server exited with 130
```

The failure is invisible in the editor. Dev Kit logs that it is opening the solution — to
a server that died a fraction of a second earlier — and Roslyn quietly falls back to
treating every `.cs` file as a standalone program under a synthetic `Canonical.csproj`.
The symptom is **Go to Definition working inside a file but not across projects**, which
looks like a broken solution file rather than a code-signing problem.

So the SDK here exists only to satisfy the editor. It is deliberately **not** added to
`PATH`:

- Terminal and CI builds keep using the per-repo devenv/Nix SDK — build behaviour is unchanged,
  and two projects can still pin different .NET versions.
- Only VS Code's C# extensions are redirected, through
  `dotnetAcquisitionExtension.existingDotnetPath` in `vscode/.config/Code/User/settings.json`.

That setting needs a **real absolute path** — `~` is not expanded — so if a rebuilt machine
has a different home directory than the committed snapshot, correct the two paths there.

Diagnosing a regression: the logs that actually say what happened live at

```
~/Library/Application Support/Code/logs/<session>/window*/exthost/ms-dotnettools.csdevkit/C# Dev Kit.log
~/Library/Application Support/Code/logs/<session>/window*/exthost/ms-dotnettools.csharp/C#.log
```

---

## A caveat on VS Code extensions

`vscode/.config/Code/User/extensions.txt` records which extensions to **install**. It does
not record whether they are **enabled** — that state lives in
`~/Library/Application Support/Code/User/globalStorage/state.vscdb`, which is a binary
SQLite file and is not tracked here.

Worth knowing, because a globally disabled extension looks exactly like a broken one: the
Angular Language Service being disabled presents as "F12 does nothing in templates", with
no error anywhere. If a language feature is silently dead, check
**Extensions → `@disabled`** before debugging anything else.
