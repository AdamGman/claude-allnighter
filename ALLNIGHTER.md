# claude-allnighter

A starter for running Claude Code autonomously (including with
`--dangerously-skip-permissions` or Auto Mode) without letting the agent
destroy your machine, steal your files, or publish half-built code to the
internet.

## What it is

When you run `claude-allnighter.bat` inside a project folder, it drops:

- `CLAUDE.md` -- opinionated rules for how Claude should think, plan, verify,
  and stay in scope.
- `.claude/settings.json` -- a hardened permissions allow/deny list. The
  deny-list blocks ~244 destructive patterns across Windows cmd, PowerShell,
  LOLBINs, registry persistence, Defender bypass, credential reads, and more.
  The allow-list pre-approves common dev commands plus winget/choco/scoop so
  the agent can install tools unattended.
- `.gitignore` -- sensible defaults so a fresh project is cleanly tracked
  (installer artifacts, Claude session state, build outputs, secrets,
  editor and OS junk).

That's it. No plugins. No hooks. No external dependencies beyond PowerShell
(ships with Windows). One file in, three files out. Double-click to run.

## Why

Claude Code is powerful enough to build real apps unattended overnight, but
by default it can also `rm -rf` your project, read your browser cookies,
publish npm packages, edit your hosts file, or download-and-execute random
PowerShell from the internet. This starter trades some agent flexibility for
a meaningful guarantee: while the agent is working in this folder, it cannot
easily damage your system or exfiltrate your data.

## How to use

1. Copy `claude-allnighter.bat` into the folder you want to start a new
   project in.
2. Double-click it. `CLAUDE.md`, `.claude/settings.json`, this
   `ALLNIGHTER.md`, and `.gitignore` appear. The installer auto-fills
   `{{ProjectName}}` in `CLAUDE.md` with the install folder's name --
   nothing to edit.
3. Open Claude Code in that folder. **If Claude Code was already open
   here, close and reopen it** -- permissions in `.claude/settings.json`
   are read at startup. On the first turn Claude opens with a one-line
   `Claude-Allnighter [status]. What are we building?`-style prompt
   (the exact wording rotates each session), then waits for your task.
4. Give Claude your first task.

### For truly unattended runs

```
claude --dangerously-skip-permissions --max-turns 30 --max-budget-usd 5
```

Bypass mode still respects `permissions.deny`, so the 244 destructive
patterns stay blocked. The `--max-turns` and `--max-budget-usd` flags are
your backstops against a runaway loop.

On Team / Enterprise plans (April 2026+): use Auto Mode instead.

```
claude --permission-mode auto
```

Auto Mode adds an AI classifier on top of the deny-list -- safer middle
ground than bypass. Still respects our deny rules.

## Disclaimer — READ THIS

This is a **personal starter** authored by **AdamGman**. It is not a
commercial product. It has not been audited by any third party. It is not
bulletproof. It is a thoughtful set of guardrails built from Anthropic's
published documentation and a deep-dive audit of Windows-specific attack
surface, and nothing more.

### No warranty

`claude-allnighter` is provided **"AS IS" and "AS AVAILABLE"**, without
warranty of any kind, express or implied, including but not limited to
warranties of merchantability, fitness for a particular purpose, title, and
non-infringement. AdamGman makes no representation or warranty that
the deny-list is exhaustive, that any particular destructive command is
blocked, that Claude Code will respect the permissions in all circumstances,
or that the configuration is appropriate for your specific environment.

### No liability

In no event shall AdamGman be liable for any claim, damages, or
other liability -- whether in an action of contract, tort, negligence, or
otherwise -- arising from, out of, or in connection with `claude-allnighter`
or the use of or other dealings with it. This includes, without limitation:
direct, indirect, incidental, special, exemplary, consequential, or
punitive damages; lost data; lost profits; business interruption; destroyed
files; compromised credentials; unintended code published to public
registries; damaged hardware; service outages; or any other loss, however
caused and on any theory of liability, even if AdamGman has been
advised of the possibility of such damages.

### You assume all risk

By running this installer, you accept that:

- Claude Code is an autonomous agent capable of executing real commands on
  your real machine. Even with the deny-list active, the agent CAN still
  delete, modify, or create files inside the project folder.
- The deny-list works by pattern matching on command strings. A novel
  command, an obfuscated command, a prompt-injection attack, or a bug in
  Claude Code's permission layer could bypass protections that appear to
  be in place.
- Third-party dependencies (npm packages, pip packages, winget installers,
  MCP servers) may themselves be compromised or malicious. The deny-list
  does not inspect the contents of code the agent downloads.
- You are solely responsible for backing up anything you care about
  **before** starting an autonomous session.
- You are solely responsible for reviewing what the agent produces before
  shipping it, merging it, or giving it access to production systems.

### Before you run

1. Read `CLAUDE.md` in its entirety. Those are the behavioral rules the
   agent is told to follow. If you disagree with any of them, edit them
   before your first session.
2. Read `.claude/settings.json`. Those are the mechanical permissions. If
   something you need is blocked, remove that entry and understand what
   you just unblocked.
3. Run on a throwaway project first. Do not point a fresh install at a
   production codebase, your home folder, or anything you cannot afford
   to lose.
4. Keep current backups. Not cloud sync -- actual backups.

### Known limitations

- Does not stop Claude from deleting files INSIDE the project. That is the
  project's responsibility via git commits, off-machine backups, and your
  own discipline.
- Does not protect against a compromised Claude Code binary. If Anthropic's
  executable is malicious, no configuration helps.
- Does not protect against OS-level exploits, kernel-level malware, or
  anything that bypasses the shell layer entirely.
- Does not guarantee the application the agent builds is correct, secure,
  or licensable. Code review remains your job.
- Does not replace your operating system's antivirus, endpoint protection,
  or backup strategy. It is one layer in a defense-in-depth strategy, not
  the whole strategy.

### Project location

`claude-allnighter` fences the agent out of user folders like
`C:\Users\<you>\Documents\`, `\Desktop\`, `\Downloads\`, `\Music\`,
`\Videos\`, `\Pictures\`, `\OneDrive\`, and `\Dropbox\` by default, to
keep tax documents, password databases, personal photos, and the like
out of reach.

**Installing into a user folder is supported, with a scoped exception.**
If you run the installer from inside one of those folders (e.g.,
`C:\Users\you\Documents\my-project\`), the installer detects this and
automatically strips only the deny rule that would block the folder you
installed into. Example: installing under `Documents\` removes
`Read(**/Users/*/Documents/**)` and `Bash(*Users*Documents*)` so your
project files are readable. Every OTHER user-folder deny stays in place
(Desktop, Downloads, OneDrive, etc.), and every credential / cert / tax /
password / browser / AppData / SSH-key / system-path block remains active.

For stronger isolation, keep work in a dedicated development folder
outside any user home subdir -- for example `D:\dev\`, `C:\dev\`, or
similar. No exceptions needed, nothing stripped.

## License

Released under the MIT License. In plain English the MIT terms mean:
**the software is provided "as is", without warranty of any kind, express
or implied. AdamGman is not liable for any claim, damages, or other
liability arising from the use of this software.** You may use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the
software, subject to including the copyright notice and this disclaimer in
all copies or substantial portions.

Copyright (c) 2026 AdamGman.
