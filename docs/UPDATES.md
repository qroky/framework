# How updates work — and how to refuse them

This page is for the owner of a Qroky instance. It explains exactly when your
instance checks for updates, what it does and does not do without you, how to
update by hand, how to roll back, and how to turn the whole thing off. The
short version: **nothing is ever applied without your explicit yes**, and the
right to say «don't touch my instance» is a supported configuration, not a
workaround.

## The mechanics, end to end

1. **The check rides the morning digest.** If you said yes to the morning
   digest (question 7 at install), a scheduled job runs on weekday mornings
   (09:07, macOS launchd) and, as part of writing your digest, runs a
   **read-only** check: `install.sh --check-update`.
2. **Release tags only.** The check fetches this repository's release tags
   (`v0.4.2`, `v0.4.1`, …) — never the moving `main` branch. Whatever is
   committed between releases cannot reach your machine.
3. **You see a 3-line digest, not a surprise.** If a newer release exists,
   your digest shows the version and the first three lines of its changelog,
   and a marker file is written (`.qroky/update-available`). Nothing else
   happens. Want the full picture first? `qroky details` prints the complete
   release notes.
4. **Applying always waits for your explicit «да».** `qroky update` shows
   what is about to happen, asks for confirmation in your language
   («да» / «da» / «yes»), and does nothing on any other answer.
5. **The update is recorded as a mini-atom in YOUR journal.** Every applied
   update writes a decision record into your own workspace —
   `decisions/UPDATE-YYYY-MM-DD-vX.Y.Z.md` — naming the old tag, the new tag,
   the fact that you confirmed, and the fate of your local edits. Your
   instance keeps its own audit trail of every change it made to itself.

## What happens to your local edits

If you have edited files inside the vendored `framework/` folder, the
updater does not pretend you didn't:

- Before asking for confirmation, it **shows you the exact list** of locally
  changed files (conflicts are shown, never silently resolved).
- If you confirm, your edits are safely stashed, the release is applied, and
  the updater tries to re-apply your edits on top.
- If they re-apply cleanly, the decision record says so. If they cannot be
  re-applied automatically, **they are not lost**: they stay in the stash, and
  the updater prints the exact command to inspect them
  (`git -C <your workspace>/framework stash list`).

Your instance's core is never silently modified — not by updates, and not by
local drift: every state is recoverable through git history, and your own
`decisions/` folder is the journal of every change your instance made to
itself.

## Updating by hand (no digest needed)

The morning digest is a convenience, not a dependency. At any moment:

```bash
qroky details    # full release notes for the pending update
qroky update     # check, show, confirm, apply — one command from any folder
```

On a machine without the `qroky` launcher (or air-gapped), the same commands
exist as installer flags, run from the kit's `distribution/` folder or from
your instance's vendored copy at `<your workspace>/framework/distribution/`:

```bash
bash install.sh --check-update           # read-only: is a new release out?
bash install.sh --show-update-details    # the full release notes
bash install.sh --apply-update           # apply, after your explicit yes
```

## Rolling back to any release

Your instance's `framework/` folder is a real git checkout pinned to a tag,
so every published release remains reachable:

```bash
git -C <your workspace>/framework tag -l 'v*'      # list all releases
git -C <your workspace>/framework checkout v0.4.1  # roll back to any one
```

Honest note: a by-hand rollback changes the working copy immediately, but the
installer's own state record (`install-state.json`) still names the tag it
last applied — it re-synchronizes on your next `qroky update`. Either way,
nothing is lost: every state is a git ref, and the road back is
`git checkout <tag>`.

## Turning the check off entirely

«Не трогайте мой инстанс» — «don't touch my instance» — is your right, stated
plainly:

- **Never enable it:** answer no at question 7 of the install. The digest
  ships installed-but-off; no job is scheduled, and nothing on your machine
  ever checks for updates.
- **Turn it off later:** remove the scheduled job —

  ```bash
  launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/md.qroky.heartbeat.<your folder name>.plist
  rm ~/Library/LaunchAgents/md.qroky.heartbeat.<your folder name>.plist
  ```

  (the plist file's exact name sits in `<your workspace>/.qroky/launchd/`).
- **Turn it back on later:** one command, `qroky enable-heartbeat`.

With the job off, no update check runs — ever. And even with it on, the check
is read-only: it can tell you about a release, and it can do nothing else.
An instance that never says «да» simply stays on its tag, forever, and keeps
working — updates are an offer, not an obligation.
