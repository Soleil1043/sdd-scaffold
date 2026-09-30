---
name: sdd-scaffold
description: 在当前目录按 SDD（Spec-Driven Development）范式初始化一个新项目——先访谈用户（项目名称、要解决的问题、目标用户、MVP 范围），再确认技术栈选型，然后落地 .agent/ 规格文件、AGENTS.md 和 git 仓库，并按 spec → plan → tasks 的阶段门禁推进。Use whenever the user wants to start, init, or scaffold a new project, or says 新建项目/起个项目/搭脚手架/项目初始化/SDD/spec-driven/vibecoding/做个工具或应用 — even if they just describe an idea without saying "scaffold".
---

# SDD 项目脚手架（面向中小项目）

把当前目录初始化为一个按 SDD 范式推进的项目：规格先行、门禁推进、文件即状态。模板与流程来自 vibecoding-scaffold（已打包在本技能 `assets/template/` 下）。跨 harness 可用：初始化脚本支持 bash 与 PowerShell，各 harness 的规则文件适配见 `references/harness-rules.md`。适用范围：单人或小团队、MVP 功能 3-8 条的中小项目；更大的项目建议先拆模块，逐个搭建。

## 核心原则（human in the loop）

1. **未访谈不动手** — 没拿到用户对需求和技术栈的回答之前，不创建任何文件
2. **每道门禁等确认** — spec、plan、tasks 每份产出都要用户明确确认后才进入下一步，用户没说"确认/可以/通过"就继续等
3. **不编造需求** — 用户没说的就追问；用户说"你定"的，给出建议并作为假设写进 spec
4. **非空目录先确认** — 写入前必须让用户知道将创建哪些内容，绝不覆盖已有文件

## 流程总览

Step 0 环境检查 → Step 1 需求访谈 → Step 2 技术栈选型 → Step 3 落地脚手架（Phase 0）→ Step 4 起草 spec（Phase 1）→ Step 5 技术方案（Phase 2）→ Step 6 任务拆解（Phase 3）→ Step 7 收尾

本文件只负责编排；每个阶段的细节规则在模板文件里，执行到哪一步就读对应的文件。

## Step 0：环境检查

1. `ls` 查看当前目录，分三种情况：
   - **空目录** → 继续 Step 1
   - **有文件但无 `.agent/`** → 列出将要创建的清单（AGENTS.md、README.md、.agent/×6、git 仓库），等用户确认后再继续；已有同名文件要说明如何处理（默认跳过并提示）
   - **已有 `.agent/` 目录** → 不重新搭建，转恢复模式：读取 `.agent/` 全部 .md，报告项目目标 / 已完成任务 / 下一个待办 / 未解决问题，等用户指示（参考 prompts.md 的「上下文恢复 Prompt」）
2. `git rev-parse --is-inside-work-tree` 判断是否已是 git 仓库，Step 3 会用到

## Step 1：需求访谈

一轮问完以下 6 个问题，等用户全部回答后再继续（不要自问自答）：

1. 项目叫什么名字？（用户没想好时，按下方「起名规程」处理）
2. 一句话：它解决什么问题？
3. 给谁用？（目标用户、使用场景）
4. MVP 要包含哪些功能？（引导到 3-8 条，中小项目的合理范围）
5. 明确不做什么？（把功能边界外的想法记下来，填 spec 的非目标）
6. 有硬性约束吗？（必须用的语言/框架、部署环境、性能要求）

**起名规程**（用户没想好名字时）：基于问题描述给 3-5 个候选，每个附一句理由和目录/包名安全的英文标识符形态（如 `expense-tracker`），必要时附中文展示名；用户仍不选就先定一个工作名，标注为假设写入 spec「假设与依赖」，spec 确认前都可改名。触发语里还没有问题描述时，先问完问题 2 再给候选。

用户含糊时最多追问一轮。用户说"你定"的名称、功能取舍，给出建议并标注为假设，后续写入 spec 的「假设与依赖」。

## Step 2：技术栈选型

根据 Step 1 的需求给出 3-4 个候选组合，每个附一句适用理由。用当前 harness 的结构化提问工具提供选项（如 ZCode 的 AskUserQuestion，保留 Other 自定义）；没有此类工具就直接在对话里列出编号选项让用户回复。常见组合：

- Python 后端 API：FastAPI + SQLAlchemy + MySQL/PostgreSQL + pytest — 数据与接口为主的项目
- Node 全栈 Web：Next.js + Prisma + PostgreSQL — 前后端一体的 Web 应用
- 纯前端工具：React/Vue + Vite + 本地存储或轻后端 — 工具型界面
- CLI / 脚本：Python + uv + typer — 命令行工具

用户指定其他栈完全尊重，模板不锁技术栈。选型结果记住，Step 3 落地时写入 decisions.md。

## Step 3：落地脚手架（Phase 0）

技能加载时会给出本技能的 base directory（下称 `<skill>`）。

1. 运行初始化脚本（脚本基于自身位置定位模板，幂等，绝不覆盖已有文件；按当前环境可用的 shell 二选一）：

   ```bash
   bash <skill>/scripts/init.sh          # bash / Git Bash / Linux / macOS
   pwsh <skill>/scripts/init.ps1         # PowerShell（powershell.exe 5.1 亦可）
   ```

   输出会列出创建了哪些文件、跳过了哪些；有跳过项就向用户报告并等指示。
2. 适配 harness 规则文件：先读 `references/harness-rules.md`，确认当前 harness 并生成对应规则文件；不确定用户在用哪个 harness 就先问。
3. 定制 `AGENTS.md`：`[PROJECT_NAME]` → 项目名；技术栈占位符 → Step 2 选型（逐行替换，不留占位符）；代码约定按栈调整（CLI/前端项目删掉不适用的条目，如 RESTful 约定）
4. 新建 `README.md`（不要复制模板 README，那是脚手架自己的说明书）：项目名、一句话描述、技术栈、状态标注"文档将在 Phase 5 完善"
5. `.agent/decisions.md` 追加 D001：技术栈选型（背景、选项对比、最终选择、理由），格式照该文件模板
6. git 仓库已由脚本初始化；全部定制完成后 `git add AGENTS.md README.md .agent/ <harness规则文件> && git commit -m "chore: init project rules"`

## Step 4：起草 spec（Phase 1）

1. 基于 Step 1 访谈答案填写 `.agent/spec.md` 全部 8 节，状态保持 🔄 待确认：
   - 每条功能（Fxx）有可验证的验收标准
   - 「边界与异常」给核心功能标注异常场景（Exx）和期望行为
   - 访谈中的假设写入「假设与依赖」
2. 向用户展示 spec 摘要（问题陈述、功能列表、非目标），等确认
3. 用户要求修改 → 改完再次等确认；确认后状态改 ✅，变更记录补 v1.0 一行

## Step 5：技术方案（Phase 2）

读 `.agent/prompts.md`，按其 Phase 2 提示词执行。要点：每个选型附一句理由；重大取舍追加 `decisions.md`；API/接口表标注对应 Fxx 并覆盖全部需求。门禁：用户确认 plan.md 后才进 Step 6。

## Step 6：任务拆解（Phase 3）

读 `.agent/prompts.md`，按其 Phase 3 提示词执行。要点：每个任务标注覆盖的 Fxx/Exx；拆完自查 tasks.md 末尾的「覆盖检查」三项并打勾。门禁：用户确认 tasks.md 后才进 Step 7。

## Step 7：收尾

1. 报告：已创建的文件、各文件状态、下一步怎么走
2. 问用户：是否现在开始实现 T001？
   - 开始 → 由 AGENTS.md 的工作流约束接管（一次一任务、完成记录到 progress.md、逐任务 commit、每任务等用户验证）
   - 不开始 → 停在这里；后续会话用 prompts.md 的「上下文恢复 Prompt」继续

## 搭建之后：变更与回退

- 构建中要改需求 → 走 prompts.md 的「需求变更 Prompt」：先改 spec、记录变更，再同步 plan/tasks，最后才动代码
- 某个任务做坏了 → 走「回退 Prompt」：git reset、任务打回 [ ]、progress.md 记录原因
