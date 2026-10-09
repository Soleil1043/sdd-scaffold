# sdd-scaffold

**SDD（Spec-Driven Development）项目脚手架技能** — 在当前目录把一个想法初始化为规格先行的结构化项目，面向中小项目，强调 human in the loop。

适用于 ZCode 及兼容 SKILL.md 规范的编码 Agent；模板与流程来自 [vibecoding-scaffold](https://github.com/) 五阶段工作流（已打包在本技能 `assets/template/` 下）。

## 标准开发流程

**需求分析 → 方案设计 → 构建 → 测试 → 上线**

- **竞品调研先行** — 需求分析前先检索 GitHub / 互联网上的同类竞品，结论写入需求规格说明书「竞品参考」
- **前两阶段纯对话式** — 需求分析与方案设计通过自然语言多轮对话推进，不弹选项卡片；需求分析是最值得投入时间的阶段，宁可多问，不可含糊
- **阶段门禁由用户主动宣布** — 必须用户明确回答"需求分析阶段结束，进入方案设计"（方案设计同理）才推进，AI 不替用户判断阶段结束
- **后续阶段走 SDD** — 任务拆解 → 构建 → 测试 → 上线，按门禁推进、文件即状态

## 它解决什么问题

直接对 Agent 说"帮我做个项目"，通常会得到一次性的代码倾倒：没有需求边界、没有决策记录、改需求时无从追溯。sdd-scaffold 把 SDD 范式固化成技能流程：**先调研、再对话分析、后落地，规格先行、门禁推进、文件即状态**。

## 特性

- **Human in the loop 全程贯穿** — 未访谈不动手；需求规格说明书 / 设计说明书 / tasks 每份产出必须用户确认才进入下一步；非空目录写入前先确认
- **七步编排** — 环境检查 → 竞品调研 → 需求分析（对话式）→ 落地脚手架与需求规格说明书 → 方案设计（对话式，技术栈在此确定）→ 任务拆解 → 交接构建/测试/上线
- **设计变动先算账** — 任何架构/设计变动，AI 必须先在对话中分析优势与代价，用户主动确认后才执行（「设计变更 Prompt」）
- **需求可追溯** — 功能（Fxx）/ 异常（Exx）/ 接口 / 任务四层互相引用编号，Phase 3 有覆盖检查门禁
- **决策留痕** — 技术栈与关键取舍写入 `decisions.md`（ADR 格式，只追加不删除）
- **跨平台脚本** — `scripts/init.sh`（bash / Git Bash）与 `init.ps1`（PowerShell 5.1+ / 7.x），幂等且绝不覆盖已有文件
- **多 harness 规则适配** — 按 `references/harness-rules.md` 生成 TRAE / Claude Code / Cursor（.mdc）/ Windsurf / Cline 的规则文件，以 AGENTS.md 为单一源
- **会话可恢复** — 所有状态落盘在 `.agent/` 目录，新会话用「上下文恢复 Prompt」从断点继续；检测到已有 `.agent/` 时自动转恢复模式而非重建

## 安装

**ZCode（自动发现）：**

```bash
# 用户级（所有项目可用）
git clone https://github.com/Soleil1043/sdd-scaffold.git ~/.agents/skills/sdd-scaffold

# 或项目级（仅当前项目可用，优先级更高）
git clone https://github.com/Soleil1043/sdd-scaffold.git <project>/.zcode/skills/sdd-scaffold
```

**其他 harness：** 支持 SKILL.md 技能规范的（如 Claude Code），将本仓库克隆到对应技能目录即可；没有技能系统的 harness，可将 `SKILL.md` 内容作为项目规则文件的一部分参考使用。

## 使用

新开会话，在目标目录输入：

```
/sdd-scaffold 帮我做一个记账 CLI 工具
```

或自然语言触发（"新建项目""搭个脚手架""帮我把这个想法做成项目"）。Agent 会先调研竞品，再以对话式完成需求分析与方案设计——两个阶段的结束都由你主动宣布；随后落地文件并按 SDD 门禁推进构建、测试、上线。

## 产出结构

```
your-project/
├── AGENTS.md              ← 项目规则（技术栈、工作流约束、Git 规范）
├── README.md              ← 现场生成，非模板复制品
├── .cursor/rules/main.mdc ← 按 harness 生成的规则文件
└── .agent/
    ├── 需求规格说明书.md   ← Phase 1：需求分析产物（竞品参考 + Fxx 功能 + Exx 异常 + 变更记录）
    ├── 设计说明书.md       ← Phase 2：方案设计产物（选型含代价 + 表结构 + API + 决策）
    ├── tasks.md           ← Phase 3：任务清单（依赖 + 验收 + 覆盖标注）
    ├── progress.md        ← Phase 4：逐任务构建日志
    ├── decisions.md       ← 全程：决策记录（D0XX）
    └── prompts.md         ← 各阶段 / 需求变更 / 设计变更 / 回退 / 上下文恢复提示词
```

构建阶段（Phase 4）由生成的 `AGENTS.md` 工作流接管：一次一任务、完成即记录、逐任务 commit、每任务等验证；需求变更走「需求变更 Prompt」先改需求规格说明书再同步下游，架构变动走「设计变更 Prompt」先分析优势与代价、经用户确认后才动。

## 设计说明

- 模板以**资产快照**形式打包在 `assets/template/`，通过初始化脚本确定性复制，保证每次产出一致；`SKILL.md` 只做编排（约 100 行），细节规则在被复制进项目后才按阶段加载
- 适用范围：单人或小团队、MVP 功能 3-8 条的中小项目；更大项目建议先拆模块逐个搭建

## License

[MIT](LICENSE)
