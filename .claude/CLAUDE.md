# CLAUDE.md

@../AGENTS.md

## Claude-specific notes

- **Don't use worktrees in this repo.** `AGENTS.md` says push straight to `main`; a worktree
  plus a branch is pure overhead for a single-user config repo. `.claude/worktrees/` is
  scratch space and is gitignored — never commit anything under it.
- **No PR step.** Finishing a change here means: commit, `git push origin main`, done. Don't
  offer to open a pull request.
- The `~/dotfiles` checkout is the live one — its files are symlinked into `$HOME`, so an
  edit takes effect immediately for stowed packages. Treat it as the user's working machine,
  not a sandbox: prefer editing, verifying, then committing over speculative changes.
