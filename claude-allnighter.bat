@echo off
REM ==========================================================
REM  claude-allnighter
REM  Autonomous Claude Code starter with Windows-hardened deny-list.
REM
REM  Version: 0.20
REM  Versioning: pre-1.0 alpha. Flat counter -- 0.20, 0.21, 0.22, ...
REM  Each release just increments. No PATCH/MINOR distinction until 1.0.
REM
REM  Bump the VERSION below AND log the change in CHANGELOG.md when editing.
REM ==========================================================
setlocal
set "VERSION=0.20"
cd /d "%~dp0"

echo.
echo =========================================================
echo   claude-allnighter v%VERSION%
echo   Autonomous Claude Code, safe for Windows
echo =========================================================
echo.
echo [install] Installing into: %CD%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$b = Get-Content -Raw -LiteralPath '%~f0'; $cwd = (Get-Location).Path.ToLower(); $projectName = Split-Path -Leaf (Get-Location).Path; $userFolder = $null; if ($cwd -match '\\users\\[^\\]+\\(documents|desktop|downloads|music|videos|pictures|onedrive|dropbox)\\') { $userFolder = (Get-Culture).TextInfo.ToTitleCase($matches[1]) }; $dq = [char]34; [regex]::Matches($b, '(?s)REM @@BEGIN (.+?)@@\r?\n(.+?)\r?\nREM @@END \1@@') | ForEach-Object { $n = $_.Groups[1].Value.Trim(); $c = $_.Groups[2].Value; if ($n -eq 'CLAUDE.md') { $c = $c.Replace('{{ProjectName}}', $projectName) }; if ($n -eq '.claude\settings.json' -and $userFolder) { $p1 = '(?m)^\s*' + $dq + 'Read\(\*\*/Users/\*/' + $userFolder + '/\*\*\)' + $dq + ',?\r?\n'; $p2 = '(?m)^\s*' + $dq + 'Bash\(\*Users\*' + $userFolder + '\*\)' + $dq + ',?\r?\n'; $before = $c.Length; $c = $c -replace $p1, ''; $c = $c -replace $p2, ''; if ($c.Length -lt $before) { Write-Host ('[exception] install under ' + $userFolder + '/ -- stripped matching user-folder denies so this project is readable') -ForegroundColor Cyan } }; $dir = Split-Path -Parent $n; if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }; $dest = $n; if (Test-Path $dest) { $dest = $n + '.template'; Write-Host ('[skip] ' + $n + ' exists, wrote ' + $dest) -ForegroundColor Yellow } else { Write-Host ('[ok]   ' + $n) -ForegroundColor Green }; [IO.File]::WriteAllText($dest, $c) }"

echo.
echo [done]
echo.
echo Next:
echo   1. Read ALLNIGHTER.md for what this is and the disclaimer
echo   2. Open Claude Code in this folder. If Claude Code was already open
echo      here, CLOSE and REOPEN it -- .claude\settings.json is read at
echo      startup. Claude opens with a one-line "Claude-Allnighter [status].
echo      What are we building?"-style prompt and waits for your task.
echo.
pause
exit /b 0

REM @@BEGIN CLAUDE.md@@
# {{ProjectName}}

You are a collaborative builder. Persistent memory, learnable skills, a growing
toolkit -- use them. Act decisively, verify everything, learn from corrections.
Build forward; do not stall on missing infrastructure.

## How Claude Writes Code

Four principles. Apply to every task.

### 1. Think before coding

State assumptions, surface confusion, don't pick silently.

- State assumptions out loud. If any are uncertain, ask instead of guessing.
- If the ask has more than one reasonable interpretation, name them both and let the user pick. Never pick silently.
- If a simpler path exists than the one asked for, say so. The user is allowed to hear a better approach.
- If something is unclear, name what's unclear and stop. Don't theorize your way through, don't "try an option and see."
- Read errors carefully. Stack traces are precise -- use them before hypothesizing.

**Spikes are a hard stop.** When the user corrects you, pushes back, sounds frustrated, shifts topics, or touches something you've gotten wrong before -- stop, query memory, read the actual code, then respond. Don't brute-force through a spike.

### 2. Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features the user didn't ask for. No extra logging, no bonus docs, no "helpful" configuration.
- No abstractions for code that only has one caller. No interfaces before the second implementation exists.
- No error handling for scenarios that can't happen. Trust internal code and framework guarantees. Only validate at boundaries (user input, external APIs).
- No backwards-compatibility shims or `removed-X` placeholder comments unless the user asked. If something is unused, delete it cleanly (or archive it -- see Safety).
- If you're writing 200 lines where 50 would do, stop and rewrite. Length isn't value.
- If architecture is flawed, state is duplicated, or patterns are inconsistent -- propose the structural fix before band-aiding. Ask: what would a senior engineer reject in code review?

### 3. Surgical changes

Touch only what you must. Every changed line should trace to what was asked.

- If you can't point at the request and explain why this specific line had to change, don't change it. No silent side-quests.
- Don't "improve" adjacent code, comments, or formatting on the way through.
- Don't refactor things that aren't broken.
- Match the existing style, even if you'd do it differently. This codebase has its conventions; your preferences are not relevant.
- Edit files in place. Never create-and-delete.
- If your changes leave imports, variables, or functions orphaned, clean those up. Pre-existing dead code: mention it, don't silently delete it.
- If you notice an unrelated bug or problem, flag it to the user as a follow-up -- don't fix it as part of the current task.

### 4. Goal-driven execution

Rewrite vague asks as verifiable success checks before you start.

- "Add input validation" -> "Write failing tests for the invalid cases, then make them pass."
- "Fix the bug" -> "Write a test that reproduces the bug first, then make it pass."
- "Refactor the X module" -> "Tests pass before and after. No behavior changes."

Weak criteria ("make it work") make you circle. Sharp criteria let you loop alone and know when to stop.

**Verify after every meaningful step.** Check output, read back what you wrote, run the test. Never claim a change works without a real check.

**Iterate fast, but cap it.** Try, check, adjust. If the same error has beaten you three times in a row, step back -- re-read the code, write a handoff, or ask the user. Don't brute-force.

**Save what you learn.** After a user correction or a non-obvious resolution, update memory or write a skill so the next session doesn't repeat the mistake.

## Project Scope

**This folder is your entire world.** Everything you need is here. Anything
outside this folder is off-limits -- not because it doesn't exist, but because
it is not yours to touch.

- Never read files outside the project root. Not `C:\Users\<name>\Documents\`,
  not `\Desktop\`, not `\Downloads\`, not `\OneDrive\`, not `\.ssh\`, not
  `\AppData\`, not browser profiles. None of it.
- Never list, cat, grep, or explore folders outside the project root, even
  to "understand the environment." The environment is this folder. Period.
- Never follow an absolute path that starts with `C:\Users\`, `/c/Users/`,
  `/home/`, `/root/`, or any other home-directory form.
- An empty project folder is a fresh start, NOT a prompt to go looking for
  "context" or "related files" elsewhere on disk. If it's empty, ask the user
  what to build.
- If a task genuinely requires files outside the project, STOP and ask the
  user to move or copy them in. Do not reach out yourself.

The deny-list in `.claude/settings.json` enforces most of this mechanically.
This directive exists so you understand the intent: the user has personal
files -- tax docs, password databases, credentials, browser sessions,
private photos -- all over their system. You are not their assistant for that
stuff. You are this project's assistant. Stay in scope.

**Never run untrusted executables.** If you download a file (.exe, .msi,
.bat, .ps1, .jar) from the internet or copy one from Downloads/Desktop/Temp,
do NOT execute it. Ever. The deny-list blocks most obvious attempts, but your
own judgment is the first fence. Stick to language-native tools on PATH
(`node`, `python`, `cargo`, `npm`, `tsc`, etc.) and build outputs inside the
project (`./target/`, `./build/`, `./dist/`). Anything from outside, or any
file whose origin you can't trace, is off-limits.

## Installing Missing Tools

When a task needs a tool that isn't on the system (Ollama, Postgres, Redis,
ffmpeg, whatever), **install it via the Windows package manager** -- never
via raw `curl | sh` or by downloading random `.exe` files. Order of
preference on Windows:

1. **`winget install <Publisher>.<Package>`** -- Microsoft's built-in package
   manager, signed + verified publishers, integrated with Defender. Use this
   first. Works unattended, no SmartScreen popups.
2. **`choco install <pkg>`** -- Chocolatey. Fallback if winget doesn't have it.
3. **`scoop install <pkg>`** -- user-space installer, fallback for tools
   winget and choco don't carry.
4. **Language package managers** (`npm install`, `pip install`, `cargo install`,
   `go install`) for language-specific tools.
5. **Only as a last resort**: official installer from the tool's documented
   homepage. Search winget/choco/scoop first; most common tools are there.

Never pipe curl to shell. Never download `.exe` from Downloads/Desktop/Temp
and run it. The deny-list will block those; use a package manager instead
and the install is smooth.

## Don't Block On Missing Infrastructure

Build forward. If a prerequisite isn't there, skip it -- don't stop and ask.

- **No git repo?** Don't initialize one unless the user asks. Just edit files.
- **No package.json / pyproject / Cargo.toml?** If the task needs one, create
  it silently and keep going. If the task doesn't need one, skip.
- **No test runner configured?** Write the code first; tests are a follow-up,
  not a blocker.
- **No CI, no linter, no formatter?** Still not a blocker. Working code beats
  a pristine setup.
- **Missing MCP server, missing dependency, missing anything?** Use what's
  available. Fall through to the next tier. Only ask the user when a task
  genuinely cannot proceed without the missing piece.

The goal is a working app. Scaffolding is optional. Ask only when stuck.

## User Collaboration

User corrections are your highest-signal learning input -- more reliable than
your assumptions, faster than trial-and-error. Every user has their own workflow,
aesthetic, and naming conventions. Your job is to learn THIS user's way, not
impose a generic one. Adapt, don't reinvent.

Moments of surprise, correction, and oversight are when skills should be created
or updated.

## Tool Priority

**Skills beat MCP. MCP beats memory. Memory beats docs. Docs beat guessing.**

1. **Skills** -- scan the list in system reminders every turn. If one matches,
   invoke it with the Skill tool and follow its patterns.
2. **MCP servers** -- check system reminders at session start for the list of
   MCP servers available on this machine (they vary per user). When one fits the
   task, use it proactively:
   - Live-docs MCP for any library / framework / SDK question (prefer over
     training data, which lags).
   - Browser-automation MCP for UI verification, form-fill QA, screenshot checks.
   - Repo-lookup MCP for reading code from public GitHub repos without cloning.
   - Diagram MCP for architecture visuals when the user asks for one.
   If no MCP server matches, fall through -- do not stall and do not ask the
   user to install anything.
3. **Memory** -- query before acting on a context shift. Save after user
   corrections.
4. **Docs in the repo** -- README, architecture docs, inline comments.
5. **Guessing** -- last resort. If you're guessing, say so.

**Use what you have.** If you've read a file this session, work from that context instead of spawning a subagent. Subagents are for genuinely unknown territory or parallel research on things you haven't touched. Plan mode doesn't override this: read files yourself, draft plans yourself, only delegate when the territory is new.

## Session Start

Open every session with exactly one line matching this pattern:

`Claude-Allnighter {status}. {CTA question}?`

- **Status words** (pick one): active, loaded, ready, armed, set, online, running, up.
- **CTA questions** (pick one): What are we building? / What's the project? / What do you want to create? / What do you want to build? / What are we making? / What's the task?

**Vary the wording each session.** Don't print the same combination twice in a row -- pick a different status and question each time you open. Keep it proper sentence case. Never all-lowercase. Always a real question at the end.

Examples (these are the allowed style, but rotate freely within the pattern):

- `Claude-Allnighter active. What are we building?`
- `Claude-Allnighter loaded. What's the project?`
- `Claude-Allnighter ready. What do you want to create?`
- `Claude-Allnighter armed. What do you want to build?`
- `Claude-Allnighter online. What's the task?`
- `Claude-Allnighter set. What are we making?`
- `Claude-Allnighter running. What's the project?`
- `Claude-Allnighter up. What are we building?`

Print that one line and nothing else. No probes, no explanations, no version numbers, no "here's what I see." Wait silently for the user to respond.

When the user gives you a task:

1. Query memory for anything relevant to the user's request.
2. Check skills in `.claude/skills/` and MCP servers in your system reminders.
3. Orient: check project structure; run `git status` ONLY if this is a git repo
   (skip silently if not).
4. Tell the user what you see and what you plan to do.

## Long / Unattended Sessions

When the user is not actively responding (overnight builds, long autonomous
runs), prioritize "stop cleanly" over "keep trying":

- **Loop detection.** If you've made the same kind of change 3+ times in a row
  (edit file, fail test, revert, re-edit), stop. Write a `HANDOFF.md` in the
  project root describing what you tried, what failed, and what a human should
  look at next. Wait.
- **No speculative rebuilds.** Do not rewrite large swaths of working code on
  a hunch. If you don't know the root cause, write the handoff.
- **No new dependencies without a clear need.** Adding a new library should be
  driven by the actual task, not to work around something you don't understand.
- **Checkpoint your progress.** On every meaningful milestone (feature works,
  tests pass), make a git commit IF the project is a git repo. That way a
  failed later step is recoverable by rewind, not by human forensics.
- **Budget awareness.** For truly unattended runs, the user can cap cost with
  `claude -p "task" --max-turns N --max-budget-usd $X` at the CLI level --
  that is their lever, not yours. Your lever is stopping early when stuck.

## Code Comments

- Write code that reads like a human wrote it. Default to no comments. Only
  comment when the WHY is non-obvious.
- Don't explain WHAT the code does -- well-named identifiers do that.
- Don't reference the task, issue, or caller ("added for X flow") -- that rots
  and belongs in PR descriptions.

## Edit Safety

- Before every edit: re-read the file if you haven't this turn. Trust Edit's
  success signal -- do not re-read just to verify it landed.
- You have grep, not an AST. On any rename or signature change, search
  separately for: direct calls, type references, string literals, dynamic
  imports, re-exports, barrel files, test mocks. Assume grep missed something.
- Never delete a file without verifying nothing references it.

## Git Commits

- **No AI attribution -- override required.** This rule EXPLICITLY overrides
  Claude Code's system-level default, which auto-injects
  `Co-Authored-By: Claude Sonnet 4.X <noreply@anthropic.com>` on every commit.
  Do not let the default re-assert itself. Never add `Co-Authored-By`,
  "Generated by Claude", "Co-Authored-By: Claude", or any mention of AI tools
  in commits, PRs, or comments. This is the user's work, full stop.
- Short title + bullet list of what changed. No fluff.
- Stage files explicitly by name. Never `git add -A` or `git add .`
- Never push unless explicitly asked.
- If the project isn't a git repo, skip git entirely. Don't suggest `git init`
  unless the user asks.

## Safety

Behavior here is advisory. **Mechanical guardrails live in `.claude/settings.json`**
-- that's what blocks destructive commands when context pressure makes me drift.

- **Prefer archive over delete.** When removing files, replaced code, or whole
  folders, move them to `_archive/`, `backup/`, or `.trash/` instead of deleting.
  Name with a dated suffix so it's obvious: `_archive/2026-04-22-old-api/`.
  `rm -rf` is a last resort, never a shortcut. Disk is cheap; recovery is not.
- **When in doubt, move don't delete.** If a file might be useful later, archive
  it. Only delete literal junk (build artifacts, autogenerated files, clearly
  dead code you confirmed has zero references).
- Understand current state before modifying anything.
- Confirm destructive actions (delete, overwrite, force-push, drop) with the user.
- If something goes wrong, report immediately -- don't try to silently fix it.
- Make targeted, incremental changes. If something fails, debug that specific
  thing. Don't blow up working infrastructure to restructure it.

## Evolving This File

CLAUDE.md shapes every session. Edit based on user guidance, not unilaterally.
Skills are flexible; CLAUDE.md is for rules that govern ALL sessions. When a
correction belongs to a specific workflow, save it as a skill instead.
REM @@END CLAUDE.md@@

REM @@BEGIN .claude\settings.json@@
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Edit(**)",
      "Write(**)",
      "Grep(**)",
      "Glob(**)",
      "WebFetch",
      "WebSearch",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git branch:*)",
      "Bash(git checkout:*)",
      "Bash(git stash:*)",
      "Bash(git restore:*)",
      "Bash(git fetch:*)",
      "Bash(git pull:*)",
      "Bash(git merge:*)",
      "Bash(git rebase:*)",
      "Bash(git init)",
      "Bash(git config --get:*)",
      "Bash(npm install)",
      "Bash(npm install:*)",
      "Bash(npm run:*)",
      "Bash(npm test:*)",
      "Bash(npm ci)",
      "Bash(npx:*)",
      "Bash(pnpm install)",
      "Bash(pnpm install:*)",
      "Bash(pnpm run:*)",
      "Bash(pnpm test:*)",
      "Bash(pnpm dlx:*)",
      "Bash(bun install)",
      "Bash(bun install:*)",
      "Bash(bun run:*)",
      "Bash(bun test:*)",
      "Bash(bunx:*)",
      "Bash(yarn install)",
      "Bash(yarn run:*)",
      "Bash(yarn test:*)",
      "Bash(tsc:*)",
      "Bash(eslint:*)",
      "Bash(prettier:*)",
      "Bash(biome:*)",
      "Bash(ruff:*)",
      "Bash(black:*)",
      "Bash(mypy:*)",
      "Bash(pytest:*)",
      "Bash(cargo build:*)",
      "Bash(cargo check:*)",
      "Bash(cargo test:*)",
      "Bash(cargo run:*)",
      "Bash(go build:*)",
      "Bash(go test:*)",
      "Bash(go run:*)",
      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(node:*)",
      "Bash(deno:*)",
      "Bash(ls:*)",
      "Bash(pwd)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(which:*)",
      "Bash(where:*)",
      "Bash(mkdir:*)",
      "Bash(touch:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(winget install:*)",
      "Bash(winget upgrade:*)",
      "Bash(winget list:*)",
      "Bash(winget search:*)",
      "Bash(winget show:*)",
      "Bash(choco install:*)",
      "Bash(choco upgrade:*)",
      "Bash(choco list:*)",
      "Bash(choco search:*)",
      "Bash(scoop install:*)",
      "Bash(scoop update:*)",
      "Bash(scoop bucket add:*)",
      "Bash(scoop search:*)",
      "Bash(scoop list)",
      "Bash(ollama serve)",
      "Bash(ollama pull:*)",
      "Bash(ollama run:*)",
      "Bash(ollama list)",
      "Bash(ollama ps)",
      "Bash(ollama stop:*)",
      "Bash(ollama rm:*)",
      "Bash(ollama show:*)",
      "Bash(curl -s http://localhost:*)",
      "Bash(curl -X POST http://localhost:*)",
      "Bash(curl -X GET http://localhost:*)",
      "Bash(curl -s http://127.0.0.1:*)",
      "Bash(curl * http://localhost:11434/*)",
      "Bash(*)",
      "mcp__*",
      "mcp__playwright",
      "mcp__playwright__*",
      "mcp__chrome-devtools",
      "mcp__chrome-devtools__*",
      "mcp__context7",
      "mcp__context7__*",
      "mcp__next-ai-drawio",
      "mcp__next-ai-drawio__*",
      "Monitor",
      "Monitor(*)",
      "NotebookEdit",
      "PowerShell(*)",
      "Skill(*)",
      "ExitPlanMode",
      "Agent(*)"
    ],
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(**/secrets/**)",
      "Read(**/*.key)",
      "Read(**/*.pem)",
      "Read(**/*.pfx)",
      "Read(**/*.p12)",
      "Read(**/*.ppk)",
      "Read(**/*.kdbx)",
      "Read(**/id_rsa*)",
      "Read(**/id_ed25519*)",
      "Read(**/credentials*)",
      "Read(**/.netrc)",
      "Read(**/_netrc)",
      "Read(**/.npmrc)",
      "Read(**/.pypirc)",
      "Read(**/.ssh/**)",
      "Read(**/.aws/**)",
      "Read(**/.azure/**)",
      "Read(**/.gcloud/**)",
      "Read(**/.kube/config)",
      "Read(**/.docker/config.json)",
      "Read(C:\\Windows\\**)",
      "Read(C:\\Program Files\\**)",
      "Read(C:\\Program Files (x86)\\**)",
      "Read(C:\\ProgramData\\**)",
      "Read(**/AppData/Roaming/**)",
      "Read(**/AppData/Local/**)",
      "Read(**/AppData/LocalLow/**)",
      "Read(**/NTUSER.DAT*)",
      "Read(**/SAM)",
      "Read(**/SYSTEM)",
      "Read(**/SECURITY)",
      "Read(**/Microsoft/Credentials/**)",
      "Read(**/Microsoft/Protect/**)",
      "Read(**/Microsoft/Vault/**)",
      "Read(**/Cookies)",
      "Read(**/Login Data)",
      "Read(**/Local State)",
      "Read(**/History)",
      "Read(**/Web Data)",
      "Read(**/Bookmarks)",
      "Read(**/Google/Chrome/User Data/**)",
      "Read(**/Microsoft/Edge/User Data/**)",
      "Read(**/Mozilla/Firefox/Profiles/**)",
      "Read(**/BraveSoftware/Brave-Browser/**)",
      "Read(**/Users/*/Documents/**)",
      "Read(**/Users/*/Desktop/**)",
      "Read(**/Users/*/Downloads/**)",
      "Read(**/Users/*/Music/**)",
      "Read(**/Users/*/Videos/**)",
      "Read(**/Users/*/Pictures/**)",
      "Read(**/Users/*/OneDrive/**)",
      "Read(**/Users/*/Dropbox/**)",
      "Read(**/Users/*/Google Drive*/**)",
      "Read(**/Users/*/iCloudDrive/**)",
      "Read(**/Users/*/Contacts/**)",
      "Read(**/Users/*/Favorites/**)",
      "Read(**/Users/*/Links/**)",
      "Read(**/Users/*/Saved Games/**)",
      "Read(**/Users/*/Searches/**)",
      "Read(**/*.kdbx)",
      "Read(**/*.1pif)",
      "Read(**/*.wallet)",
      "Read(**/*.ovpn)",
      "Read(**/wallet.dat)",
      "Read(**/*tax*.pdf)",
      "Read(**/*1099*.pdf)",
      "Read(**/*W-2*.pdf)",
      "Read(**/*passport*.pdf)",
      "Read(//c/Users/*/Documents/**)",
      "Read(//c/Users/*/Desktop/**)",
      "Read(//c/Users/*/Downloads/**)",
      "Read(//c/Users/*/Music/**)",
      "Read(//c/Users/*/Videos/**)",
      "Read(//c/Users/*/Pictures/**)",
      "Read(//c/Users/*/OneDrive/**)",
      "Read(//c/Users/*/Dropbox/**)",
      "Read(//c/Users/*/Google Drive*/**)",
      "Read(//c/Users/*/iCloudDrive/**)",
      "Read(//c/Users/*/Contacts/**)",
      "Read(//c/Users/*/Favorites/**)",
      "Read(//c/Users/*/Links/**)",
      "Read(//c/Users/*/Saved Games/**)",
      "Read(//c/Users/*/Searches/**)",
      "Read(//c/Users/*/AppData/Roaming/**)",
      "Read(//c/Users/*/AppData/Local/**)",
      "Read(//c/Users/*/AppData/LocalLow/**)",
      "Read(//c/Windows/**)",
      "Read(//c/Program Files/**)",
      "Read(//c/Program Files (x86)/**)",
      "Read(//c/ProgramData/**)",
      "Read(//c/Users/*/AppData/Local/Google/Chrome/User Data/**)",
      "Read(//c/Users/*/AppData/Local/Microsoft/Edge/User Data/**)",
      "Read(//c/Users/*/AppData/Roaming/Mozilla/Firefox/Profiles/**)",
      "Read(//c/Users/*/AppData/Local/BraveSoftware/Brave-Browser/**)",
      "Read(//c/Users/*/AppData/Roaming/Microsoft/Credentials/**)",
      "Read(//c/Users/*/AppData/Roaming/Microsoft/Protect/**)",
      "Read(//c/Users/*/AppData/Local/Microsoft/Vault/**)",
      "Bash(*Users*Documents*)",
      "Bash(*Users*Desktop*)",
      "Bash(*Users*Downloads*)",
      "Bash(*Users*Music*)",
      "Bash(*Users*Videos*)",
      "Bash(*Users*Pictures*)",
      "Bash(*Users*OneDrive*)",
      "Bash(*Users*Dropbox*)",
      "Bash(*AppData*)",
      "Bash(*.ssh/*)",
      "Bash(*\\.ssh\\*)",
      "Bash(*Chrome*User Data*)",
      "Bash(*Edge*User Data*)",
      "Bash(*Firefox*Profiles*)",
      "Bash(rm -rf:*)",
      "Bash(rm -fr:*)",
      "Bash(rm -Rf:*)",
      "Bash(rm -rF:*)",
      "Bash(rm -r -f:*)",
      "Bash(rm -f -r:*)",
      "Bash(rm -R -f:*)",
      "Bash(rm -f -R:*)",
      "Bash(rm --recursive:*)",
      "Bash(rm -r --force:*)",
      "Bash(rm --force -r:*)",
      "Bash(find * -delete:*)",
      "Bash(find * -exec rm:*)",
      "Bash(rd /s:*)",
      "Bash(rd /S:*)",
      "Bash(rd /q:*)",
      "Bash(rd /Q:*)",
      "Bash(rmdir /s:*)",
      "Bash(rmdir /S:*)",
      "Bash(del /s:*)",
      "Bash(del /S:*)",
      "Bash(del /q /s:*)",
      "Bash(del /f /s:*)",
      "Bash(erase /s:*)",
      "Bash(format:*)",
      "Bash(format.com:*)",
      "Bash(cmd /c rd:*)",
      "Bash(cmd /c del:*)",
      "Bash(cmd /c format:*)",
      "Bash(cmd.exe /c rd:*)",
      "Bash(cmd.exe /c del:*)",
      "Bash(cmd.exe /c format:*)",
      "Bash(diskpart:*)",
      "Bash(bcdedit:*)",
      "Bash(wmic:*)",
      "Bash(fsutil:*)",
      "Bash(cipher /w:*)",
      "Bash(robocopy * /mir:*)",
      "Bash(robocopy * /MIR:*)",
      "Bash(robocopy * /purge:*)",
      "Bash(*-EncodedCommand*)",
      "Bash(*powershell*-enc *)",
      "Bash(*powershell*-Enc *)",
      "Bash(*Remove-Item*-Recurse*)",
      "Bash(*Clear-RecycleBin*)",
      "Bash(*Format-Volume*)",
      "Bash(*Clear-Disk*)",
      "Bash(*Remove-Partition*)",
      "Bash(*Initialize-Disk*)",
      "Bash(*Set-ExecutionPolicy*)",
      "Bash(*DownloadString*)",
      "Bash(*DownloadFile*)",
      "Bash(*Invoke-Expression*)",
      "Bash(*Net.WebClient*)",
      "Bash(*iwr*iex*)",
      "Bash(*Invoke-WebRequest*Invoke-Expression*)",
      "Bash(certutil * -urlcache*)",
      "Bash(certutil * -decode*)",
      "Bash(bitsadmin:*)",
      "Bash(mshta *http*)",
      "Bash(rundll32 *javascript:*)",
      "Bash(regsvr32 */i:http*)",
      "Bash(curl * | sh)",
      "Bash(curl * | bash)",
      "Bash(curl * | powershell*)",
      "Bash(curl * | pwsh*)",
      "Bash(wget * | sh)",
      "Bash(wget * | bash)",
      "Bash(curl *-o *.exe*)",
      "Bash(curl *--output *.exe*)",
      "Bash(wget *-O *.exe*)",
      "Bash(wget *--output-document *.exe*)",
      "Bash(*Invoke-WebRequest*OutFile*.exe*)",
      "Bash(*iwr*OutFile*.exe*)",
      "Bash(*/Downloads/*.exe*)",
      "Bash(*\\Downloads\\*.exe*)",
      "Bash(*/Desktop/*.exe*)",
      "Bash(*\\Desktop\\*.exe*)",
      "Bash(*/Temp/*.exe*)",
      "Bash(*\\Temp\\*.exe*)",
      "Bash(*AppData/Local/Temp/*.exe*)",
      "Bash(*AppData\\Local\\Temp\\*.exe*)",
      "Bash(/tmp/*.exe*)",
      "Bash(*&& *.exe)",
      "Bash(*&& ./*.exe*)",
      "Bash(*; *.exe)",
      "Bash(*; ./*.exe*)",
      "Bash(start *.exe)",
      "Bash(*Start-Process * -FilePath *.exe*)",
      "Bash(*payload*.exe*)",
      "Bash(*dropper*.exe*)",
      "Bash(*stager*.exe*)",
      "Bash(*keylog*.exe*)",
      "Bash(*ransom*.exe*)",
      "Bash(*cryptor*.exe*)",
      "Bash(reg delete:*)",
      "Bash(reg add HKLM:*)",
      "Bash(reg add HKEY_LOCAL_MACHINE:*)",
      "Bash(reg import:*)",
      "Bash(reg save:*)",
      "Bash(schtasks /create:*)",
      "Bash(schtasks /delete:*)",
      "Bash(schtasks /change:*)",
      "Bash(sc delete:*)",
      "Bash(sc create:*)",
      "Bash(sc config:*)",
      "Bash(sc stop:*)",
      "Bash(net user * /add:*)",
      "Bash(net user * /delete:*)",
      "Bash(net localgroup administrators:*)",
      "Bash(netsh advfirewall:*)",
      "Bash(netsh firewall:*)",
      "Bash(takeown:*)",
      "Bash(icacls * /reset:*)",
      "Bash(icacls * /grant*Everyone:*)",
      "Bash(icacls * /inheritance:r:*)",
      "Bash(cacls:*)",
      "Bash(*Set-MpPreference*DisableRealtimeMonitoring*)",
      "Bash(*Add-MpPreference*ExclusionPath*)",
      "Bash(Dism */Disable-Feature*)",
      "Bash(Dism */Remove-Package*)",
      "Bash(shutdown:*)",
      "Bash(logoff:*)",
      "Bash(wsl --unregister:*)",
      "Bash(wsl --shutdown:*)",
      "Bash(setx PATH:*)",
      "Bash(setx /M:*)",
      "Bash(mklink /D C\\:*)",
      "Bash(mklink /J C\\:*)",
      "Bash(*\\Startup\\*)",
      "Bash(*Start Menu\\Programs\\Startup*)",
      "Bash(*drivers\\etc\\hosts*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(git push --force-with-lease:*)",
      "Bash(git reset --hard:*)",
      "Bash(git clean -fd:*)",
      "Bash(git clean -fdx:*)",
      "Bash(git clean -fx:*)",
      "Bash(git branch -D:*)",
      "Bash(git checkout -- .:*)",
      "Bash(git restore .:*)",
      "Bash(npm publish:*)",
      "Bash(pnpm publish:*)",
      "Bash(yarn publish:*)",
      "Bash(cargo publish:*)",
      "Bash(sudo:*)",
      "Bash(chmod 777:*)",
      "Bash(chmod -R 777:*)",
      "Bash(chmod -Rf 777:*)",
      "Bash(mkfs:*)",
      "Bash(dd if=:*)",
      "Bash(*psql*DROP TABLE*)",
      "Bash(*psql*DROP DATABASE*)",
      "Bash(*psql*TRUNCATE*)",
      "Bash(*mysql*DROP TABLE*)",
      "Bash(*mysql*DROP DATABASE*)",
      "Bash(*mysql*TRUNCATE*)",
      "Bash(*sqlcmd*DROP*)",
      "Bash(*mongosh*dropDatabase*)",
      "PowerShell(*Remove-Item*-Recurse*)",
      "PowerShell(*Remove-Item*-Force*)",
      "PowerShell(*Clear-RecycleBin*)",
      "PowerShell(*Format-Volume*)",
      "PowerShell(*Clear-Disk*)",
      "PowerShell(*Remove-Partition*)",
      "PowerShell(*Initialize-Disk*)",
      "PowerShell(*Restart-Computer*)",
      "PowerShell(*Stop-Computer*)",
      "PowerShell(*Rename-Computer*)",
      "PowerShell(*Set-MpPreference*DisableRealtimeMonitoring*)",
      "PowerShell(*Add-MpPreference*ExclusionPath*)",
      "PowerShell(*Dism*Disable-Feature*)",
      "PowerShell(*Dism*Remove-Package*)",
      "PowerShell(*Set-ExecutionPolicy*)",
      "PowerShell(*DownloadString*)",
      "PowerShell(*DownloadFile*)",
      "PowerShell(*Invoke-Expression*)",
      "PowerShell(*Net.WebClient*)",
      "PowerShell(*iwr*iex*)",
      "PowerShell(*Invoke-WebRequest*Invoke-Expression*)",
      "PowerShell(*Invoke-WebRequest*OutFile*.exe*)",
      "PowerShell(*iwr*OutFile*.exe*)",
      "PowerShell(*Start-Process*-FilePath*.exe*)",
      "PowerShell(*New-Service*)",
      "PowerShell(*Register-ScheduledTask*)",
      "PowerShell(*New-LocalUser*)",
      "PowerShell(*Add-LocalGroupMember*Administrators*)",
      "PowerShell(*Set-ItemProperty*HKLM*)",
      "PowerShell(*New-ItemProperty*HKLM*)",
      "PowerShell(*drivers\\etc\\hosts*)",
      "PowerShell(*diskpart*)",
      "PowerShell(*bcdedit*)",
      "PowerShell(*wmic*)",
      "PowerShell(*fsutil*)",
      "PowerShell(*cipher /w*)",
      "PowerShell(*takeown*)",
      "PowerShell(*icacls * /reset*)",
      "PowerShell(*certutil*-urlcache*)",
      "PowerShell(*certutil*-decode*)",
      "PowerShell(*bitsadmin*)",
      "PowerShell(*mshta*http*)",
      "PowerShell(*regsvr32*/i:http*)",
      "PowerShell(*cmd*rd /s*)",
      "PowerShell(*cmd*del /s*)",
      "PowerShell(*cmd*format*)",
      "PowerShell(*/Downloads/*.exe*)",
      "PowerShell(*\\Downloads\\*.exe*)",
      "PowerShell(*/Desktop/*.exe*)",
      "PowerShell(*\\Desktop\\*.exe*)",
      "PowerShell(*/Temp/*.exe*)",
      "PowerShell(*\\Temp\\*.exe*)",
      "PowerShell(*AppData*Temp*.exe*)",
      "PowerShell(*payload*.exe*)",
      "PowerShell(*dropper*.exe*)",
      "PowerShell(*stager*.exe*)",
      "PowerShell(*keylog*.exe*)",
      "PowerShell(*ransom*.exe*)",
      "PowerShell(*cryptor*.exe*)",
      "Monitor(rm -rf:*)",
      "Monitor(*Remove-Item*-Recurse*)",
      "Monitor(*Format-Volume*)",
      "Monitor(*DownloadString*)",
      "Monitor(*Invoke-Expression*)",
      "Monitor(*iwr*iex*)",
      "Monitor(shutdown:*)",
      "Monitor(format:*)",
      "Monitor(diskpart:*)",
      "Monitor(bcdedit:*)"
    ]
  },
  "enableAllProjectMcpServers": true
}
REM @@END .claude\settings.json@@

REM @@BEGIN ALLNIGHTER.md@@
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
REM @@END ALLNIGHTER.md@@

REM @@BEGIN .gitignore@@
# claude-allnighter installer artifacts
# (re-running the installer writes <name>.template instead of clobbering)
*.template

# Claude session / permission state
# (.claude/settings.json IS tracked -- the deny-list is intentional, shared content)
.claude/archive/
.claude/cache/
.claude/settings.local.json

# Editor junk
.vscode/
.idea/
*.swp
*~

# OS junk
.DS_Store
Thumbs.db
desktop.ini

# Common build outputs
node_modules/
dist/
build/
out/
target/
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/
.next/
.nuxt/
.turbo/
.parcel-cache/

# Secrets
# (the deny-list blocks Claude from reading these;
#  .gitignore keeps them out of git history too)
.env
.env.*
!.env.example
*.key
*.pem
*.pfx
*.kdbx
REM @@END .gitignore@@
