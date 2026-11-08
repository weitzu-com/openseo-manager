# OpenSEO Manager

A Claude Code skill (packaged as a plugin) that sets up, updates, checks, and auto-updates the official [OpenSEO](https://openseo.so) plugin.

一个 Claude Code 技能（以插件形式发布）：一键安装、更新、校验并自动更新官方 OpenSEO 插件（MCP + SEO 技能）。

> Community project. Not affiliated with OpenSEO. It does not copy or redistribute OpenSEO's skills; it manages the official `openseo@openseo` plugin from [every-app/open-seo](https://github.com/every-app/open-seo).

## Why (first principles) / 设计原则

OpenSEO is only useful when three separate things are all true:

| State | Proof |
|---|---|
| **Installed**: the plugin is present and current | `installed_plugins.json` version matches the marketplace |
| **Signed in**: the MCP server is authenticated | the OAuth approval in your browser |
| **Usable here**: this session sees the tools and skills | `whoami` + `list_projects` succeed, and the `openseo:*` skills are listed |

Every step checks one of these, and every report keeps the three separate. Updates touch only OpenSEO and stay in its existing scope. They never use credits and never ask for secrets in chat.

## Install / 安装

```bash
claude plugin marketplace add weitzu-com/openseo-manager
claude plugin install openseo-manager@openseo-manager --scope user
```

Or as a plain personal skill / 或作为个人技能：

```bash
git clone https://github.com/weitzu-com/openseo-manager /tmp/openseo-manager && cp -R /tmp/openseo-manager/skills/openseo-manager ~/.claude/skills/
```

Then, in a new session, ask: "Set up OpenSEO" / "Update OpenSEO" / "Turn on OpenSEO auto-update", or invoke `/openseo-manager:openseo-manager`.

## Scripts / 脚本

All scripts live in `skills/openseo-manager/scripts/`:

| Script | Purpose |
|---|---|
| `openseo-status.sh` | Read-only report: version, scope, MCP endpoint, skills, duplicates, auto-update |
| `openseo-update.sh` | Refresh the marketplace, update the plugin in its scope, diff the skill files |
| `install-autoupdate.sh` | Run the daily update (macOS uses launchd, daily and at login; Linux uses cron). Set the hour with `OPENSEO_UPDATE_HOUR=9` |
| `uninstall-autoupdate.sh` | Turn auto-update off |

Log: `~/.claude/openseo-manager/update.log`. Updated plugins load in the **next** Claude session.

自动更新只更新插件文件；已打开的会话需新开会话才会加载新版本。

## License

MIT
