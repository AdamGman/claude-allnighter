# claude-allnighter — Changelog

All notable changes to `claude-allnighter.bat`. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), adherent to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Versioning rules for this project:**

Pre-1.0 alpha. Flat counter — `0.20`, `0.21`, `0.22`, ... Each release
just increments. No PATCH/MINOR distinction until `1.0`.

When you edit the `.bat`, bump `VERSION=` at the top AND add an entry
here under `## [Unreleased]`. Release the entry to the next free integer
in the `0.X` sequence when you're ready to tag.

---

## [Unreleased]

Nothing yet.

---

## [0.20] — 2026-04-22

Initial public release.

### What ships

- **Single self-extracting Windows `.bat` installer.** Double-click to drop four files into your project: `CLAUDE.md`, `.claude/settings.json`, `ALLNIGHTER.md`, `.gitignore`.
- **Hardened permissions** — 116 allow entries (wildcard-by-default for Bash, MCP, file ops, web, built-in tools) and 342 deny entries covering POSIX/Windows/PowerShell/Monitor destructive commands, LOLBINs, registry persistence, Defender bypass, browser/credential reads, user-folder snooping, `.exe` execution from danger paths, suspicious binary names. Read patterns ship in both relative form (`Read(**/Users/*/Documents/**)`) and POSIX-normalized form (`Read(//c/Users/*/Documents/**)`) for reliable matching against absolute Windows paths (per Anthropic's path-normalization spec).
- **Behavioral discipline in `CLAUDE.md`** — four coding principles (think before coding, simplicity first, surgical changes, goal-driven execution), project-scope fence, archive-over-delete, winget-first installs, long-session handoff discipline, override-required no-AI-attribution rule.
- **Smart install behaviors** — auto-fills `{{ProjectName}}` with the install folder name; detects when installed under a user folder (`Documents`, `Desktop`, etc.) and strips only the matching deny rule.
- **Dynamic session-start ack** — Claude opens each session with a varied one-line greeting.
- **MIT licensed.**
