# 🧠 obsidian-memory-anywhere

<a id="chinese"></a>

**简体中文** | [English](#english)

> 一个 Skill，让大部分 AI 在回答前先翻你的 Obsidian。

基于 [Agent Skills 开放标准](https://agentskills.io/specification)：同一份 `SKILL.md`，可以装进 Claude Code、ChatGPT / Codex、Claude.ai、Cursor、GitHub Copilot、Gemini CLI、DeepSeek Harness，以及任何支持该标准的客户端。纯 Markdown，零依赖，不联网。

---

## 为什么需要它

和 AI 聊得越久，越容易遇到这三个问题：

- 上个月聊过的项目细节，今天它完全不记得；
- 你明明在 Obsidian 里记了目标、偏好、项目进度，它却像第一次见你；
- 每次都要重新贴背景，贴完还是模板化回答。

这个 Skill 把「先查记忆，再回答」变成固定流程：**每次回答前，先检索你的 Obsidian 库，判断哪些记忆还有效，整合进答案，然后才开口。**

## ✨ 它做了什么

| 步骤 | 说明 |
| --- | --- |
| 1. 抽关键词 | 从问题里识别项目、课程、人物、目标、时间、专有名词，做同义扩展 |
| 2. 判断能力 | 当前 AI 能读本地文件 → 直接查库；不能 → 用你上传的 `MEMORY_PACK.md` 快照 |
| 3. 检索库 | 用客户端自带的搜索 / 读取工具，只读 `*.md`，跳过 `.obsidian/`、附件、系统目录 |
| 4. 判断记忆 | 直接相关 / 背景相关 / 历史快照 / 无关；冲突时以较新的笔记为准 |
| 5. 整合回答 | 记忆影响结论、优先级、语气和例子；引用来源与日期，区分事实和推断 |
| 6. 必要时写回 | 只有出现新事实才更新主笔记并加 `[[双链]]`，没新信息不动库 |
| 7. 查不到时 | 一句话说明「没查到相关记录」，然后正常回答；绝不编造记忆 |

## 📦 兼容性

| 客户端 | 安装位置 | 说明 |
| --- | --- | --- |
| **Claude Code** | `~/.claude/skills/` 或项目 `.claude/skills/` | 自动按描述加载；也可 `/obsidian-memory` |
| **Claude.ai**（网页 / 桌面 App） | 设置 → Capabilities → Skills，上传 skill 文件夹的 zip（保留 `obsidian-memory/` 为顶层目录） | 自动按需加载；需开启 Code execution |
| **ChatGPT 桌面 App / Codex CLI / IDE 扩展** | `~/.agents/skills/`（Codex 用户级技能目录） | `$obsidian-memory`、`/skills` 或 `@` 选择 |
| **ChatGPT 网页 / 移动端** | 无本地文件权限 → 使用 `MEMORY_PACK.md` | 放进 Project 或作为附件上传 |
| **Cursor** | `~/.agents/skills/` 或 `~/.cursor/skills/` | 自动 / `/obsidian-memory`；也读 Claude、Codex 目录 |
| **GitHub Copilot**（App / CLI / IDE） | `~/.agents/skills/` 或 `~/.copilot/skills/`；项目可用 `.github/skills/` | 自动按需加载 |
| **Gemini CLI** | `~/.agents/skills/` 或 `~/.gemini/skills/` | 自动按需加载 |
| **DeepSeek Harness（DSH）** | `~/.dsh/skills/` | 另有 DSH 专用轻量版：[obsidian-memory-skill](https://github.com/ImportMyBrain/obsidian-memory-skill) |
| **其他 Agent Skills 客户端** | 遵循该客户端的 skills 目录约定 | 格式通用，机制一致 |

> 完整的支持列表见 [agentskills.io/clients](https://agentskills.io/clients)。各客户端的目录约定可能随版本变化，安装前可先看对应文档。

## 🚀 安装

### 方式一：一键脚本（推荐）

Windows：

```powershell
git clone https://github.com/ImportMyBrain/obsidian-memory-anywhere.git
cd obsidian-memory-anywhere
.\install.ps1 -Vault "D:\Obsidian\MyVault"
```

macOS / Linux：

```bash
git clone https://github.com/ImportMyBrain/obsidian-memory-anywhere.git
cd obsidian-memory-anywhere
./install.sh --vault "$HOME/Obsidian/MyVault"
```

脚本会：

- 把 skill 复制到 `~/.agents/skills/obsidian-memory/`（Codex / Cursor / Copilot / Gemini 等共用）和 `~/.claude/skills/obsidian-memory/`（Claude Code）；
- 如果传了 `--vault` / `-Vault`，把安装副本里的 `__VAULT_PATH__` 换成你的库路径；
- 已存在同名 skill 时先备份再覆盖（`-Force` / `--force`）。

项目级安装（写进仓库、团队共享）：

```powershell
.\install.ps1 -Project -ProjectPath "D:\my-repo"
```

```bash
./install.sh --project /path/to/repo
```

### 方式二：手动安装

把本仓库的 `obsidian-memory/` 整个文件夹复制到对应客户端的 skills 目录（见上方表格），然后编辑其中的 `SKILL.md` 第 0 节，把 `__VAULT_PATH__` 换成你的 Obsidian 库路径。

### 方式三：下载 zip

从 [Releases](https://github.com/ImportMyBrain/obsidian-memory-anywhere/releases) 下载 zip，解压后按需复制到对应目录。

## ⚙️ 配置（1 分钟）

打开 `obsidian-memory/SKILL.md` 第 0 节：

```markdown
- `VAULT`: `D:\Obsidian\MyVault`   # 你的库根目录（必填）
- `PROFILE_DIR`: `Profile`         # 个人档案 / 偏好目录（可选，相对 VAULT）
- `ARCHIVE_DIR`: `Chats`           # 历史归档目录（可选）
- `MEMORY_PACK`: `MEMORY_PACK.md`  # 给无文件权限的 AI 用的快照（可选）
```

`PROFILE_DIR` 里建议放一份「关于我 / 我的偏好」的笔记，检索时先读它，回答会更贴合你。

## 🔁 让它每轮自动生效（推荐）

Skill 默认按需加载。想让它**每次回答前都自动跑**，在客户端的常驻指令文件里加一行：

```markdown
## Obsidian memory first (every turn)
Before answering any message, load the `obsidian-memory` skill and search the local Obsidian vault for relevant notes, then integrate those memories into the answer. Do this for new chats, follow-ups, simple questions and short messages too.
```

各客户端的文件对应关系（`AGENTS.md` / `CLAUDE.md` / `GEMINI.md` / `.cursor/rules` / `.github/copilot-instructions.md` / 自定义指令）见 [always-on.md](obsidian-memory/references/always-on.md)。

## 💬 给没有本地文件权限的 AI 用（ChatGPT 网页 / Claude.ai / 手机）

这些客户端读不到你电脑上的文件，用 **Memory Pack**：

```bash
node obsidian-memory/scripts/memory-pack.mjs --vault "D:\Obsidian\MyVault" --out MEMORY_PACK.md
```

生成的 `MEMORY_PACK.md` 是一个 40KB 左右的记忆快照（个人档案 / 目标 / 当前项目 / 最近笔记 / 全量索引）。把它：

- 放进 ChatGPT 的 Project 文件，或直接作为附件发给对话；
- 在 Claude.ai 里附加到对话或 Project；
- 作为系统提示词的一部分粘贴（如果客户端不支持附件）。

详细说明见 [memory-pack.md](obsidian-memory/references/memory-pack.md)。

## 🗂️ 目录结构

```
obsidian-memory/                 # 可安装的 skill 本体
├── SKILL.md                     # 主流程（含能力分级：查库 / 用 pack / 无记忆）
├── references/
│   ├── always-on.md             # 各客户端「每轮强制」配置
│   └── memory-pack.md           # Memory Pack 用法
├── scripts/
│   └── memory-pack.mjs          # 导出记忆快照（Node 18+，零依赖）
└── agents/
    └── openai.yaml              # ChatGPT / Codex 的界面元数据（可选）
install.ps1 / install.sh         # Windows / macOS+Linux 安装脚本
README.md                        # 中英双语说明（中文在前）
LICENSE                          # MIT
```

## 🔒 隐私

- 纯本地：skill 只读你的 Markdown，不发网络请求，不上传任何内容。
- 不读 `.obsidian/`、系统目录和附件二进制；不把隐私内容带进群聊或第三方会话。
- `MEMORY_PACK.md` 是明文快照，包含笔记摘录：只保存到本地、不要提交进仓库（仓库的 `.gitignore` 已忽略 `MEMORY_PACK*.md`）。
- 本仓库全部示例为通用文本，不含任何真实笔记内容或路径。

## 📄 License

[MIT](LICENSE)

## 🔗 相关项目

- [mubu-memory](https://github.com/ImportMyBrain/mubu-memory) —— 同样的思路，笔记在幕布（Mubu）的版本。

---

如果这个 skill 帮你省下了每次重新解释自己的时间，欢迎点个 ⭐。

---

<a id="english"></a>

# 🌐 English

[简体中文](#chinese) | **English**

> One skill. Most AI clients. Your Obsidian, recalled before the answer.

Built on the [Agent Skills open standard](https://agentskills.io/specification): the same `SKILL.md` installs into Claude Code, ChatGPT / Codex, Claude.ai, Cursor, GitHub Copilot, Gemini CLI, DeepSeek Harness, and any other client that supports the standard. Plain Markdown, no dependencies, no network access.

## Why

Chats drift. The assistant forgets last month's project details, even though you wrote everything down in Obsidian. You end up re-explaining your context in every conversation — and still get generic answers.

`obsidian-memory` makes "recall first, answer second" a fixed workflow: **before every answer, search the vault, judge what's current, weave it into the answer.**

## What it does

| Step | Detail |
| --- | --- |
| 1. Extract keywords | People, projects, courses, goals, dates, proper nouns — plus synonyms |
| 2. Detect capability | Local file access → search the vault; no file access → use an attached `MEMORY_PACK.md` |
| 3. Search | Use the client's own search/read tools; only `*.md`, skip `.obsidian/`, attachments, system folders |
| 4. Judge memories | Direct / background / historical snapshot / irrelevant; newer notes win conflicts |
| 5. Integrate | Memory shapes conclusions, priorities, tone and examples; cite source and date |
| 6. Write back | Only when there is genuinely new information; add `[[links]]` |
| 7. No match | Say so in one line and answer normally; never fabricate memories |

## Compatibility

| Client | Install location |
| --- | --- |
| Claude Code | `~/.claude/skills/` or project `.claude/skills/` |
| Claude.ai | Settings → Capabilities → Skills → upload the skill folder as a zip (keep `obsidian-memory/` as the zip's top-level folder; Code execution must be enabled) |
| ChatGPT desktop / Codex CLI / IDE extension | `~/.agents/skills/` (Codex user-level skills) |
| ChatGPT web / mobile | No local file access → attach `MEMORY_PACK.md` to a Project or chat |
| Cursor | `~/.agents/skills/` or `~/.cursor/skills/` |
| GitHub Copilot (App / CLI / IDE) | `~/.agents/skills/` or `~/.copilot/skills/`; project: `.github/skills/` |
| Gemini CLI | `~/.agents/skills/` or `~/.gemini/skills/` |
| DeepSeek Harness (DSH) | `~/.dsh/skills/` (there is also a DSH-only variant: [obsidian-memory-skill](https://github.com/ImportMyBrain/obsidian-memory-skill)) |
| Any Agent Skills client | Follow its skills directory convention |

See the full client list at [agentskills.io/clients](https://agentskills.io/clients). Directory conventions can change; check each client's docs before installing.

## Install

```powershell
# Windows
git clone https://github.com/ImportMyBrain/obsidian-memory-anywhere.git
cd obsidian-memory-anywhere
.\install.ps1 -Vault "D:\Obsidian\MyVault"
```

```bash
# macOS / Linux
git clone https://github.com/ImportMyBrain/obsidian-memory-anywhere.git
cd obsidian-memory-anywhere
./install.sh --vault "$HOME/Obsidian/MyVault"
```

The installer copies the skill to `~/.agents/skills/obsidian-memory/` (shared by Codex, Cursor, Copilot, Gemini, …) and `~/.claude/skills/obsidian-memory/` (Claude Code), and fills `__VAULT_PATH__` when `--vault` is provided.

## Configure

Edit section 0 of `obsidian-memory/SKILL.md`:

```markdown
- `VAULT`: `D:\Obsidian\MyVault`   # required
- `PROFILE_DIR`: `Profile`         # optional, relative to VAULT
- `ARCHIVE_DIR`: `Chats`           # optional
- `MEMORY_PACK`: `MEMORY_PACK.md`  # optional, for chat-only clients
```

## Run it every turn

Add the rule from [always-on.md](obsidian-memory/references/always-on.md) to your client's always-on instruction file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, custom instructions, …).

## Chat-only clients

For ChatGPT web, Claude.ai and mobile apps, generate a memory pack and attach it to a Project or chat:

```bash
node obsidian-memory/scripts/memory-pack.mjs --vault "D:\Obsidian\MyVault" --out MEMORY_PACK.md
```

The pack (~40 KB) contains profile, goals, active projects, recent notes and a full index. See [memory-pack.md](obsidian-memory/references/memory-pack.md).

## Privacy

- Local only: reads Markdown, no network calls, no uploads.
- Skips `.obsidian/`, system folders and binary attachments.
- `MEMORY_PACK.md` is plain text with note excerpts — keep it local and out of commits (the repo `.gitignore` ignores `MEMORY_PACK*.md`).
- All examples in this repository are generic — no real notes or personal paths.

## License

[MIT](LICENSE)

## Related

- [mubu-memory](https://github.com/ImportMyBrain/mubu-memory) — the same idea for Mubu (幕布) notes.
