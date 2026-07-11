# VERDICT — ATOM-131 (qroky command on PATH, kit v0.4.1)

**ACCEPT** — blind mutational verify (L-tier, targeted, INFO-037), round 1.
Verifier: independent, executor's claims treated as hypotheses. Date: 11.07.2026.

## What was independently reproduced / proven

1. **Harness rerun (my machine, my run):** `distribution/dry-run.sh` → **24/24 PASS**
   (claim confirmed). Head untouched: `git diff v0.4..HEAD -- runtime/claude/telegram/`
   is empty.
2. **Mutations (3/3 killed, temp copies, full harness rerun each):**
   - **M1** — `_launcher_wire()` neutered (launcher never installed) → scenario 22
     FAILS wholesale (`a=0/0/0 relay=127…`) AND scenario 12 FAILS
     (`launcher=0 pathblocks=0/0 home_files=4/4`). 22/24.
   - **M2** — provenance guard removed (`grep INFO-044` → `true`, uninstall deletes
     any file at the launcher path) → scenario 22 FAILS exactly on d1
     «foreign launcher survives» (`d1=…/0/0/…`). 23/24.
   - **M3** — PATH dup-check broken (marker never found, block always appended) →
     scenario 12 FAILS exactly on «PATH block ровно 1 после re-run»
     (`pathblocks=1/2`). 23/24.
   No mutant survived; every kill landed on the assertion the mandate named.
3. **Shell-profile safety (code read whole + byte-proof on a copy):**
   - Install: marker searched across all 5 profiles (.zshrc/.zprofile/.bashrc/
     .bash_profile/.profile) before writing; written only when `~/.local/bin`
     genuinely absent from PATH; best-effort (read-only ~ logged, install continues).
   - Uninstall awk excision uses exact-line match (`$0==s`/`$0==e`): proved on a
     fixture profile with foreign lines before/after and marker-LOOKALIKE lines
     («# >>> qroky command similar but not equal >>>», trailing-junk end marker) —
     everything outside the exact block is **byte-identical** after excision.
   - Empty-var paths: `set -euo pipefail` in install.sh (unset HOME aborts);
     empty SHELL → ~/.profile fallback; profile writes are inside best-effort
     guards — no write lands in a wrong place silently.
   - Launcher deleted ONLY with INFO-044 provenance (grep), foreign file stays
     with an honest line (proven live by M2 kill + scenario 22 d1 on real code).
4. **Curl-mode is real, not a stub:** dry-run.sh:1929-1931 copies qroky.sh as the
   «downloaded» file; scenario 22(a) runs `bash <(cat "$DOWNLOADED") install` from
   a neutral empty cwd ($0=/dev/fd/N). Fixture origin `fake-kit-origin` is a real
   git repo with tag, carrying FULL distribution/ (install.sh, dist-manifest,
   verify.sh, lang/) + qroky.sh at root — so the vendored-installer uninstall
   (22 d2, kit copy gone) is contentful, and M2 proved that path discriminative.
   I re-executed this 4× (baseline + 3 mutants).
5. **Launcher:** exactly 12 lines inside the heredoc, no logic beyond resolve+exec,
   two `exec bash` paths (kit copy, then vendored `$WD/framework/qroky.sh` via the
   machine trace `~/.qroky/workdir`), zero `rm` anywhere in it; failure line prints
   the curl one-liner.
6. **Texts:** curl one-liner is the single entry in README ×3 (line ~17-18); manual
   clone demoted to the air-gapped/curl-less alternative ×3; finale
   `L_FINALE_QROKY_COMMAND` ×3 locales names `~/.local/bin/qroky` + the profile
   file (when the PATH line was written) + «qroky uninstall»; NEW-terminal honesty
   line present ×3; uninstall reinstall-hint = curl one-liner ×3
   (`L_UNINSTALL_REINSTALL_HINT`). Greps for «bash framework/», «cd ~/work»: clean.
7. **SKILL.md (vendored):** diff v0.4..HEAD = Amended-строка INFO-044 in I3 +
   Provenance table row + one in-place text fix (`bash install.sh --uninstall` →
   `qroky uninstall` inside the same I3 exception — consistent with the directive).
   GATE-028 line and grep-provenance intact. Author copy untouched.
8. **Backfill (DoD 6):** `cmd_apply_update` wires the launcher every time
   (idempotent, refreshes content) and announces only when `had_launcher=0` —
   second update is silent by construction; scenario 22(c) proves the backfill +
   single announce live.
9. **CHANGELOG v0.4.1:** matches the verified facts, user-benefit language,
   air-gapped alternative named.

## Findings (none blocking)

- **F1 (minor, real):** residual PATH-dependent commands in user-facing texts:
  `bash install.sh --enable-telegram / --enable-heartbeat / --enable-backup`
  (README ×3: en 4 hits, ro 4, ru 4; lang/*.sh: 10-12 hits each — interview skip
  hints, enable-later hints). The `qroky` launcher dispatches only
  install/update/details/uninstall, so a curl-mode user (kit hidden at
  ~/.qroky/kit) cannot run these hints from anywhere — the exact defect class
  INFO-044 fixes. RESULT's DoD-4 claim «README ×3 … всюду qroky» is overstated
  for these secondary flows. Core journey (entry/finale/update/uninstall) is
  fully path-free. Recommend next touch: `qroky telegram|heartbeat|backup`
  subcommands or reworded hints.
- **F2 (nano, cosmetic):** uninstall's awk removes only the marker block; the one
  blank line the installer printed BEFORE the block survives, so install/uninstall
  cycles accumulate blank lines in the profile. Foreign content byte-preserved.
- **F3 (note):** harness asserts the backfill announce but not the SILENCE of a
  second consecutive update (DoD-6 tail verified in code only).
- **F4 (note, harness):** dry-run.sh line 66 hard-depends on the atom workspace
  dir existing (`cd … && pwd`); with it absent, `ATOM_WORKSPACE` resolves empty
  and transcripts spray at `/`. Irrelevant for in-repo runs; worth a guard.

## Расход

~22k of ~25k envelope (harness rerun + 3 full mutant reruns in parallel + code
read + byte-proofs). No network, no real GitHub, fake-origin only, no writes
outside scratchpad except this VERDICT.md.
