# Harness 规则文件适配

模板以 `AGENTS.md` 为唯一源。落地时确认用户当前使用的 harness，生成对应规则文件（内容与 AGENTS.md 保持一致）。不确定用户在用哪个 harness 就先问，不要猜。

| Harness | 规则文件 | 说明 |
|---------|---------|------|
| TRAE | `AGENTS.md` | 自动读取，无需额外文件 |
| Claude Code | `CLAUDE.md` | 复制一份；Claude Code 也原生支持 `AGENTS.md`，二选一即可 |
| Cursor | `.cursor/rules/main.mdc` | 见下方 mdc 格式；旧版 `.cursorrules` 已过时，仅兼容 |
| Windsurf | `.windsurfrules` | 复制一份 |
| Cline | `.clinerules` | 复制一份 |
| 其他 | `AGENTS.md` | 无自动读取，手动引用 |

## Cursor .mdc 格式

`.mdc` 文件在正文前加 frontmatter，AGENTS.md 全文紧随其后：

```mdc
---
description: 项目全局规则（与 AGENTS.md 保持同步）
alwaysApply: true
---
（AGENTS.md 全文粘贴在此处）
```

## 同步约定

- 规则修改一律先改 `AGENTS.md`，再同步到其他规则文件——多源并存时以 AGENTS.md 为准，避免漂移
- 用户切换 harness 时，以 AGENTS.md 为源重新生成对应规则文件，不重写内容
