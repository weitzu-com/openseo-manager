---
name: openseo-manager
description: Set up, update, verify, and repair the OpenSEO plugin (MCP + SEO skills) in Claude Code. Use when the user asks to install, connect, update, refresh, check, or fix OpenSEO, or to turn its automatic updates on or off. Never runs paid SEO research.
---

# OpenSEO Manager

Keep OpenSEO working in this agent with the fewest moving parts. OpenSEO works only when three things are all true:

1. **Installed**: the official `openseo@openseo` plugin is installed and current.
2. **Signed in**: its MCP server (`https://app.openseo.so/mcp`, or a self-hosted endpoint) is authenticated.
3. **Usable here**: this session can call the tools *and* discover the skills.

Check and report each one separately. If one is true, that proves nothing about the others.

## Rules

- Never run paid research (keyword, SERP, audit, backlink, AI-visibility runs) while managing setup. Only use the free reads: `whoami`, `list_projects`. `create_project` is free too, but only run it if the user gives you a domain.
- Change only OpenSEO. Keep other plugins, connectors, and MCP servers as they are.
- Never ask for API keys or OAuth codes in chat, and never write them into a repository. Sign-in happens in the user's browser or the client's secret settings.
- Don't create duplicates. If you find OpenSEO skills copied by hand into `~/.claude/skills/` or `.claude/skills/` alongside the plugin, or an old custom OpenSEO connector alongside the plugin's server, report it. Remove it only after the user agrees.
- Before you replace a file the user has edited, ask them.
- Check `claude plugin --help` before you run plugin commands, because flags change between versions.

## Workflow

### 1. Inspect

Run `scripts/openseo-status.sh` (relative to this skill folder). It prints the Claude Code version, the OpenSEO marketplace and plugin version, its install path and scope, the MCP endpoint, the skill list, any duplicate skill copies, and whether auto-update is enabled. It reads only and changes nothing.

### 2. Install (only if missing)

```bash
claude plugin marketplace add every-app/open-seo
claude plugin install openseo@openseo --scope user
```

In the Claude desktop app or Cowork, plugins can also be added through **Customize → Plugins → Add marketplace → `https://github.com/every-app/open-seo`**. Self-hosted OpenSEO uses its own MCP endpoint instead of the plugin.

### 3. Update

Run `scripts/openseo-update.sh`. It refreshes the `openseo` marketplace, updates `openseo@openseo` in its existing scope, and prints a diff of the skill files between the old and new versions. It is idempotent, so running it when the plugin is already current does nothing.

### 4. Sign in

If the MCP server shows as needing authentication, tell the user to approve it. They can run `/mcp` in a terminal `claude` session or use the app's connector settings, then approve in the browser. Don't loop retrying tools that aren't available.

### 5. Reload and verify

- Plugin updates take effect in a **new session** (a restart may be needed). Tell the user this. Don't claim the new version is live in the current session.
- When the tools are loaded, call `whoami` and then `list_projects`. Report success only after both return.
- Check that the skills are discoverable: the `openseo:*` skills should show up in the skill list or `/` menu.
- If `list_projects` is empty, ask for the user's website and offer to run `create_project`.

### 6. Automatic updates

- Enable: `scripts/install-autoupdate.sh` (macOS uses launchd; Linux uses cron). It runs daily, plus once at login.
- Disable: `scripts/uninstall-autoupdate.sh`.
- Log: `~/.claude/openseo-manager/update.log`.

Auto-update only refreshes the plugin files. Sessions that are already running keep the old version until they restart.

## Handoff

Keep the final reply short. Say what is now true for installed, signed in, and usable here. Say whether the skill files actually changed. Give at most one action for the user, such as starting a new session or approving sign-in. Suggest `/openseo:seo-audit` as a good next step, but don't run it.
