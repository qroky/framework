# Qroky on Windows (via WSL2) and Linux

Qroky runs on Windows through **WSL2** — a real Linux running inside Windows.
You install WSL2 once, then use the *exact same* one-line installer as macOS,
answer the same questions, and get the same working instance — including the
scheduled parts (the morning digest and the Telegram bot). This page is the
WSL2 walkthrough plus the honest list of what differs from macOS.

Native Windows / PowerShell is **not** supported in this version — Qroky is a
bash-and-git tool, and WSL2 is the supported way to run it on Windows.

---

## Set up WSL2 in three steps

**1. Install WSL2.** Open PowerShell (or Windows Terminal) *as Administrator*
and run:

```powershell
wsl --install
```

This installs WSL2 and Ubuntu by default, then asks you to reboot. After the
reboot, Ubuntu opens and asks you to pick a username and password for your
Linux home — that is your Linux account, separate from Windows.

**2. Turn on systemd.** The morning digest and the Telegram jobs are scheduled
with **systemd user timers** (the same role macOS gives to launchd). WSL2 can
run systemd, but it is off by default. Turn it on once: inside the Ubuntu
terminal, open `/etc/wsl.conf` (create it if missing) and add:

```ini
[boot]
systemd=true
```

for example with:

```bash
sudo tee -a /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

Then, from **Windows** (PowerShell), restart WSL so the setting takes effect:

```powershell
wsl --shutdown
```

Reopen the Ubuntu terminal. You can confirm systemd is running with
`systemctl --user` — it should respond rather than error.

> **If you skip this step:** Qroky still installs and works, but it falls back
> to **cron** for scheduling, and cron on WSL2/Ubuntu does not start on its own
> — you would have to run `sudo service cron start` after each boot. Turning on
> systemd is the smoother path, which is why it is step 2. If no scheduler is
> available at all, the installer tells you plainly and never pretends the
> scheduled parts are running.

**3. Install git and Claude Code inside WSL.** Everything Qroky needs lives
*inside* the Linux side, not on Windows. Install git:

```bash
sudo apt-get update && sudo apt-get install -y git
```

Then install Claude Code inside WSL by following Anthropic's official
instructions, and sign in. (Claude Code is the reference runtime Qroky drives.)

---

## Then: the same one line as everyone else

From your Ubuntu (WSL2) terminal, run the exact installer macOS users run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
```

Answer the same eight questions. That is it — there is no Windows-specific
installer and no Windows-specific flags.

---

## Using Qroky day to day

If you are on Windows, read this: Qroky's engine runs inside Ubuntu (WSL2),
but you do **not** have to live in a Linux terminal to use it. There are three
ways to work with it, and the first two feel like ordinary Windows.

- **VS Code — the main way.** Install VS Code on Windows plus its **WSL**
  extension, then open your workspace once with `code .` from the Ubuntu
  terminal. From then on it is a normal Windows window connected to the Linux
  side: you edit files, start Claude Code, and talk to Qroky from there, while
  the Linux terminal stays under the hood.
- **Telegram — from your phone or any device.** Once you connect the bot during
  setup, the morning digest, the gate decisions (approve or decline as buttons),
  and "what's in progress" all arrive in Telegram. You can steer Qroky and
  approve its decisions from your phone while it works on your PC — no terminal,
  no computer required.
- **The Ubuntu terminal directly**, if that is what you prefer.

The only things that happen strictly inside Ubuntu are the one-time install
above and the Claude Code sessions themselves — and even those you normally
open through the Windows VS Code window, not a bare terminal. Keep your
workspace on the Linux side (`~/...`), not on the Windows `C:` drive — see the
next section.

---

## What is different from macOS

- **Where your files live.** Your workspace is a normal folder inside the Linux
  home, e.g. `\\wsl$\Ubuntu\home\<you>\...` when viewed from Windows Explorer,
  or just `~/...` inside the terminal. Keep your Qroky workspace on the Linux
  side (under `~`), not on the Windows `C:` drive — the Windows drive is slow
  from inside WSL and does not preserve Linux file permissions.
- **What schedules the jobs.** macOS uses launchd; WSL2/Linux uses systemd user
  timers (or cron as a fallback). The digest still fires on weekday mornings and
  the Telegram digest still fires daily — the mechanism underneath is the only
  difference, and Qroky picks it for you automatically.
- **The `qroky` command and PATH.** The installer drops a `qroky` launcher in
  `~/.local/bin` and, if that folder is not already on your `PATH`, adds a line
  to your shell profile (`~/.bashrc` on Ubuntu's default bash). Open a fresh
  terminal after installing so the command is found.
- **Opening the workspace in VS Code.** Install the *WSL* extension in VS Code
  on Windows, then from the WSL terminal run `code .` inside your workspace —
  VS Code opens connected to WSL, editing the Linux-side files directly.

---

## Honest boundaries

- The Linux/WSL2 scheduler path is exercised by the kit's own test harness on
  real Linux (autodetection and the cron backend) and by simulation for the
  systemd backend where a live systemd bus was not available. As of this
  version it has **not yet** been through a full living install by a Windows
  user end to end — if you are that first user and something in the first 15
  minutes does not match this page, that is exactly the report the project
  wants (see the feedback channel in the README).
- WSL1 is not supported; use WSL2 (the default with `wsl --install`).
- Qroky does not install WSL for you — step 1 above is a Windows action you run
  once yourself.
