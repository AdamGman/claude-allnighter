<div align="center">

# claude-allnighter

### Autonomous Claude Code, safe for Windows.

[![Version](https://img.shields.io/badge/version-0.20-blue)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2B-0078D4)](https://www.microsoft.com/windows)
[![Status](https://img.shields.io/badge/status-alpha-orange)]()
[![Deny rules](https://img.shields.io/badge/deny%20rules-342-red)](#whats-blocked)
[![Last commit](https://img.shields.io/github/last-commit/AdamGman/claude-allnighter)](https://github.com/AdamGman/claude-allnighter/commits/main)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

Turn [Claude Code](https://docs.claude.com/claude-code) into a no-frills autonomous app builder on Windows. **Zero Yes/No prompts. Zero BS code.**

One self-extracting `.bat` drops two things into your project:

- **Hardened permissions.** Deny-list is the only safety boundary; allow-list is wildcard-by-default. Claude runs any command that isn't destructive, without stopping to ask — and without reading your browser cookies, publishing rogue npm packages, editing your hosts file, deleting your project, or running random `.exe` files from `Downloads`.
- **A disciplined `CLAUDE.md`.** Four coding principles (think before coding, minimum code that solves the problem, surgical changes only, verifiable success checks before starting) so Claude doesn't ship bloated abstractions, silent side-quests, or half-finished refactors.

Drop in the folder, open Claude, ship the app.

[Install](#install) · [Why](#why) · [What's blocked](#whats-blocked) · [Signs it's working](#signs-its-working) · [Tradeoffs](#tradeoffs) · [Star history](#star-history) · [Disclaimer](#disclaimer)

</div>

---

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/AdamGman/claude-allnighter?style=social)](https://github.com/AdamGman/claude-allnighter/stargazers) &nbsp; [![GitHub forks](https://img.shields.io/github/forks/AdamGman/claude-allnighter?style=social)](https://github.com/AdamGman/claude-allnighter/network/members)

</div>

---

## Install

In your project folder, open `cmd`:

```cmd
curl -O https://raw.githubusercontent.com/AdamGman/claude-allnighter/main/claude-allnighter.bat
claude-allnighter.bat
```

Or download `claude-allnighter.bat` from the [latest release](https://github.com/AdamGman/claude-allnighter/releases/latest) and double-click it inside your project folder.

> **Heads up — SmartScreen / AV.** The `.bat` is unsigned. Windows SmartScreen and most antivirus tools will flag it on first run as "unrecognized publisher." Review the file in any text editor before executing (it's a self-extracting batch + inline PowerShell — fully readable, ~40 KB), then click **More info → Run anyway** if you trust what you see. The whole point of this tool is "don't blindly trust unsigned scripts," so checking ours before running fits the brief.

### Review what gets installed, before running anything

The `.bat` is self-extracting — it drops four files into your project folder. **The exact file contents are visible at the repo root so you can read them first**, no extraction or running required:

- **[`CLAUDE.md`](CLAUDE.md)** — behavioral rules Claude operates under (the four coding principles, project-scope fence, archive-over-delete safety, long-session HANDOFF discipline, no-AI-attribution commit rule).
- **[`.claude/settings.json`](.claude/settings.json)** — the full 116 allow + 342 deny permissions list. Every pattern visible.
- **[`ALLNIGHTER.md`](ALLNIGHTER.md)** — the explainer and disclaimer that ships into the user's project.
- `.gitignore` — sensible defaults (visible inside the bat between `REM @@BEGIN .gitignore@@` and `REM @@END .gitignore@@`).

If anything in those files looks wrong for your situation, edit them after install OR open an issue.

You'll see:

```
=========================================================
  claude-allnighter v0.20
  Autonomous Claude Code, safe for Windows
=========================================================

[install] Installing into: D:\dev\my-project

[ok]   CLAUDE.md
[ok]   .claude\settings.json
[ok]   ALLNIGHTER.md
[ok]   .gitignore

[done]
```

Four files extracted:

| File | Purpose |
|---|---|
| `CLAUDE.md` | Behavioral rules organized as four principles (think before coding / simplicity first / surgical changes / goal-driven execution), plus project-scope fence, archive-over-delete, winget-first installs, long-session handoff discipline |
| `.claude/settings.json` | Hardened allow/deny list (116 allow + 342 deny entries) |
| `ALLNIGHTER.md` | Explainer + disclaimer for the user |
| `.gitignore` | Sensible defaults: installer `*.template`, `.claude/archive/`, build outputs, secrets, editor/OS junk |

The installer auto-fills `{{ProjectName}}` in `CLAUDE.md` with the install folder's name. Nothing to edit by hand. Re-running the installer never clobbers — existing files are written as `<name>.template` instead.

Open Claude Code in that folder. **If Claude Code was already open in this folder, close and reopen it** — `.claude/settings.json` is read at startup, not mid-session, so an already-open session won't pick up the new permissions until you restart it. On the first turn, Claude opens with a one-line `Claude-Allnighter [status]. What are we building?`-style prompt (the exact wording rotates each session — status picked from `active`/`loaded`/`ready`/`armed`/`set`/`online`/`running`/`up`, CTA picked from a pool of "What are we building?"-style questions) and then waits for your task. No probes, no upfront ceremony.

---

## Why

Claude Code is powerful enough to build real apps unattended overnight. By default, it has two problems.

**Security.** It can:

- `rm -rf` your project
- Read your browser cookies, password databases, SSH keys, AWS credentials
- Publish unfinished code to npm
- Edit your `hosts` file or registry
- Download and execute random PowerShell from the internet
- Persist itself via scheduled tasks or `Startup\` folder
- Disable Defender real-time monitoring

**Code quality.** It tends to:

- Overcomplicate with abstractions for code that has one caller
- Start silent side-quests "while we're in the area"
- Leave half-finished refactors
- Write 200 lines where 50 would do
- Claim a bug is fixed without a test that proves it
- Remove or change code it doesn't understand as a side effect of orthogonal edits

`claude-allnighter` solves both: hardened permissions stop system damage and data exfil; a disciplined `CLAUDE.md` keeps Claude writing minimum, surgical, verifiable code.

**How the four principles map to what they prevent:**

| Our principle | What it prevents |
|---|---|
| **Think before coding** | Claude picking an interpretation silently and shipping something you didn't want |
| **Simplicity first** | Overcomplicated abstractions, unrequested features, 200 lines where 50 would do |
| **Surgical changes** | Silent side-refactors, edits to files you didn't mention, style drift |
| **Goal-driven execution** | Bugs "fixed" without a reproducing test, weak success criteria, infinite loops |

---

## How it compares

| | Docker sandbox | Linux shell hooks | **claude-allnighter** |
|---|---|---|---|
| First-run setup | Install Docker Desktop | Install Bash, jq, etc. | **Double-click** |
| Platform | Cross-platform | Linux / macOS / WSL | **Windows-native** |
| External dependencies | Docker | Bash + supporting tools | **None** (PowerShell ships with Windows 10+) |
| Deny patterns | Process isolation (no list) | ~40 | **342** |
| Windows-specific patterns (PowerShell LOLBINs, registry, Defender) | No | No | **Yes** |
| Reads your AppData / browser / SSH | Containerized | Depends on hooks | **Blocked** |
| `.exe` from Downloads / Temp / Desktop | Containerized | Depends on hooks | **Blocked** |

---

## What's blocked

<details>
<summary><b>342 deny patterns — click to expand</b></summary>

**Tool-specific matching.** Claude Code permissions match per-tool. `Bash(...)` patterns only block the Bash tool; `PowerShell(...)` patterns only block the PowerShell tool; `Monitor(...)` patterns only block the Monitor tool. So destructive-command denies are mirrored across all three tools — if you add a new deny, add the `Bash(...)`, `PowerShell(...)`, and `Monitor(...)` variants where the command could plausibly be invoked.

| Category | Examples |
|---|---|
| **POSIX destructive** | `rm -rf` (all flag variants), `find -delete`, `find -exec rm` |
| **Windows cmd destructive** | `rd /s`, `del /s`, `format`, `diskpart`, `bcdedit`, `wmic`, `fsutil`, `cipher /w`, `robocopy /mir` |
| **PowerShell destructive (via Bash)** | `Remove-Item -Recurse`, `Format-Volume`, `Clear-Disk`, `-EncodedCommand`, `Set-ExecutionPolicy`, `DownloadString`, `Invoke-Expression`, etc. |
| **PowerShell destructive (via PS tool directly)** | **Mirrors of the above with `PowerShell(...)` prefix** — `Remove-Item -Recurse/-Force`, `Format-Volume`, `Clear-Disk`, `Remove-Partition`, `Restart-Computer`, `Set-MpPreference -DisableRealtimeMonitoring`, `Add-MpPreference -ExclusionPath`, `DownloadString`, `DownloadFile`, `Invoke-Expression`, `Net.WebClient`, `iwr \| iex`, `Start-Process -FilePath *.exe`, `New-Service`, `Register-ScheduledTask`, `New-LocalUser`, `Add-LocalGroupMember Administrators`, `Set-ItemProperty HKLM`, `drivers\etc\hosts`, `diskpart`, `bcdedit`, `wmic`, `fsutil`, `takeown`, `icacls /reset`, `certutil -urlcache`, `bitsadmin`, `mshta http`, `regsvr32 /i:http`, `cmd /c rd/del/format` bypass, `.exe` from Downloads/Desktop/Temp, suspicious exe names |
| **Monitor destructive (watcher tool)** | Top-tier mirrors — `rm -rf`, `Remove-Item -Recurse`, `Format-Volume`, `DownloadString`, `Invoke-Expression`, `iwr \| iex`, `shutdown`, `format`, `diskpart`, `bcdedit` |
| **LOLBIN download-and-exec** | `certutil -urlcache`, `bitsadmin`, `mshta http`, `regsvr32 /i:http`, `iwr \| iex`, `DownloadString`, `DownloadFile` |
| **Registry / persistence** | `reg add HKLM`, `schtasks /create`, `sc create / config / delete`, `net user /add`, `**\Startup\*` |
| **Defender bypass** | `Set-MpPreference -DisableRealtimeMonitoring`, `Add-MpPreference -ExclusionPath`, `Dism /Disable-Feature` |
| **System state** | `shutdown`, `wsl --unregister`, `setx PATH`, `mklink /D C:\`, `**\drivers\etc\hosts*` |
| **Git destructive** | `git push --force`, `git reset --hard`, `git clean -fdx`, `git branch -D`, `git restore .` |
| **Package publishing** | `npm publish`, `pnpm publish`, `yarn publish`, `cargo publish` |
| **`.exe` from danger paths** | `/Downloads/*.exe`, `/Desktop/*.exe`, `/Temp/*.exe`, `AppData/Local/Temp/*.exe`, suspicious names (`*payload*.exe`, `*keylog*.exe`, `*ransom*.exe`) |
| **Sensitive reads** | `.env`, `*.key`, `*.pem`, `*.pfx`, `*.kdbx`, `id_rsa*`, `.ssh/**`, `.aws/**`, `.azure/**`, `.kube/config`, `.docker/config.json`, browser profiles, registry hives |
| **Personal files** | `*tax*.pdf`, `*1099*.pdf`, `*W-2*.pdf`, `*passport*.pdf`, `*.kdbx`, `*.wallet`, `*.ovpn` |
| **User-folder snooping** | `**/Users/*/Documents/**`, `Desktop`, `Downloads`, `Music`, `Videos`, `Pictures`, `OneDrive`, `Dropbox`, `Google Drive`, `iCloudDrive` |

</details>

<details>
<summary><b>Allow list — wildcard-by-default for autonomous mode</b></summary>

The allow list is intentionally broad. The deny-list (342 patterns above) is the only safety boundary that matters; the allow-list is wildcarded so autonomous sessions never stall on permission prompts. Anything the deny-list doesn't catch is approved without asking.

> **Note on Windows path matching:** Claude Code normalizes Windows paths to POSIX form before deny-pattern matching (`C:\Users\AdamG\Documents\file` becomes `/c/Users/AdamG/Documents/file`). The deny-list ships both the relative form (`Read(**/Users/*/Documents/**)`) and the POSIX-normalized form (`Read(//c/Users/*/Documents/**)`) for every Windows-targeted Read pattern. Anthropic has open issues ([#30736](https://github.com/anthropics/claude-code/issues/30736), [#34741](https://github.com/anthropics/claude-code/issues/34741)) about glob matching on Windows; until those land, deny-pattern firing on absolute Windows paths may be inconsistent. Both forms are present so coverage tightens automatically when the upstream fix ships.

- **All bash commands** — `Bash(*)`. Anything not destructive (per the deny-list) runs without prompt.
- **PowerShell** — `PowerShell(*)` (separate tool from Bash on Windows, same deny-list applies).
- **All MCP tools** — `mcp__*` plus per-server entries for `mcp__playwright`, `mcp__chrome-devtools`, `mcp__context7`, `mcp__next-ai-drawio`.
- **Built-in Claude Code tools** — `Monitor` (dev-server waits, background process polling), `NotebookEdit` (Jupyter cells), `Skill(*)`, `ExitPlanMode`, `Agent(*)`.
- **File ops** — `Read(**)`, `Edit(**)`, `Write(**)`, `Grep(**)`, `Glob(**)`.
- **Web** — `WebFetch`, `WebSearch`.

Documented categories (redundant with the `Bash(*)` wildcard but kept for reference and self-documentation):

- **Git (non-destructive)** — `status`, `diff`, `log`, `show`, `add`, `commit`, `branch`, `checkout`, `stash`, `restore`, `fetch`, `pull`, `merge`, `rebase`, `init`, `config --get`
- **Node / JS** — `npm`/`pnpm`/`yarn`/`bun` install/run/test, `npx`, `bunx`, `pnpm dlx`, `tsc`, `eslint`, `prettier`, `biome`
- **Python** — `python`, `python3`, `ruff`, `black`, `mypy`, `pytest`
- **Rust** — `cargo build`, `cargo check`, `cargo test`, `cargo run`
- **Go** — `go build`, `go test`, `go run`
- **Other runtimes** — `node`, `deno`
- **Windows package managers** — `winget`/`choco`/`scoop` install/upgrade/list/search
- **Ollama** — `serve`, `pull`, `run`, `list`, `ps`, `stop`, `rm`, `show`
- **Localhost API testing** — `curl` to `localhost`, `127.0.0.1`, `localhost:11434` (Ollama)
- **Filesystem (safe)** — `ls`, `pwd`, `cat`, `head`, `tail`, `which`, `where`, `mkdir`, `touch`, `cp`, `mv`

</details>

---

## Project location

By default, the agent is fenced out of these folders so personal files (tax docs, passwords, photos) stay out of reach:

```
Documents · Desktop · Downloads · Music · Videos · Pictures
OneDrive · Dropbox · Google Drive · iCloudDrive
```

**Installing inside one of those is supported**, with a scoped exception. The installer detects the install path and strips ONLY the deny rule that would block the matched folder. Everything else (credentials, browser profiles, SSH/AWS keys, AppData, system paths, the OTHER user folders) stays blocked. A cyan `[exception]` line in the install output reports what was stripped.

For maximum isolation, keep work in a dedicated dev folder outside any user home subdir — `D:\dev\`, `C:\dev\`, etc. No exceptions needed, nothing stripped.

---

## Signs it's working

When `claude-allnighter` is doing its job, you'll notice:

- First session opens with one line like `Claude-Allnighter loaded. What's the project?` and then waits — no verification theater, no file listing, no probes.
- Claude asks clarifying questions before starting, not after the mistake is in the diff.
- Bug fixes ship with a test that reproduces the bug. No "I think that's fixed" hand-waving.
- Diffs touch only what you asked about. No surprise refactors of files you didn't mention.
- Overnight sessions end with working code or a clear `HANDOFF.md`, not a half-finished experiment.
- Zero permission prompts interrupting flow. Destructive attempts get silently blocked by the deny-list, not bounced to you.

---

## Tradeoffs

- Biases toward letting the agent run freely with a hard safety floor. If your workflow is to check in on every architectural decision, wildcard-by-default allow-list isn't it.
- Deny-list is pattern-matching, not formal verification. A novel command structure could slip through. Use on projects, not on production infrastructure you can't afford to lose.
- Coding principles bias toward caution over speed. For obvious one-liner fixes (typo, version bump, rename), trust judgment over rigor — the four principles are for non-trivial work.

---

## Star history

[![Star History Chart](https://api.star-history.com/svg?repos=AdamGman/claude-allnighter&type=Date)](https://star-history.com/#AdamGman/claude-allnighter&Date)

---

## Disclaimer

Provided **as is**, without warranty of any kind. The deny-list works by pattern matching on command strings — a novel command, an obfuscated command, or a prompt-injection attack could bypass protections that appear active. Third-party dependencies (npm, pip, winget) may themselves be malicious; the deny-list does not inspect the contents of code the agent downloads.

Read the full disclaimer in [`ALLNIGHTER.md`](claude-allnighter.bat) (extracted by the installer; embedded in the `.bat`).

**You are responsible for backing up anything you care about before starting an unattended session.**

---

## License

MIT. Copyright (c) 2026 AdamGman.
