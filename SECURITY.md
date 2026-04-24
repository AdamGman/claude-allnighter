# Security Policy

## Reporting a vulnerability

If you find a way for the deny-list patterns in `.claude/settings.json` to be bypassed (i.e., a destructive command that should be blocked but actually executes), please open a **private security advisory**:

https://github.com/AdamGman/claude-allnighter/security/advisories/new

Don't open a public issue for bypass cases — public issues make the vulnerability immediately exploitable for everyone running the tool.

## What counts as a vulnerability

- Any destructive command (`rm -rf`, `format`, registry write, persistence install, credential read, `.exe` from `Downloads`, etc.) that the deny-list claims to block but actually executes via the `Bash`, `PowerShell`, or `Monitor` tool on Windows
- Any allow-list pattern that approves a destructive command we'd intend to block
- Any way to read user files outside the project folder despite the project-scope fence in `CLAUDE.md`
- Any way to bypass the no-AI-attribution override on commits

## What's NOT in scope

- Bugs in Claude Code itself (report to Anthropic)
- Feature requests or general improvements (open a regular issue)
- Issues with third-party MCP servers or libraries the agent installs
- Compromised-dependency attacks — the deny-list pattern-matches command strings, it does not inspect the contents of code the agent downloads
- Bypasses requiring physical access to the machine

## Response time

Personal alpha project, one maintainer. Best effort, no SLA. I look at private advisories when I see them. Bypasses that could `rm -rf` someone's project or exfiltrate credentials get attention first.
