# Always-on instructions (make the skill run every turn)

Skills are usually loaded on demand. To run **tiered recall** before every answer, add the rule below to the client's always-on instruction file. Load the skill once per session, then reuse it.

## The rule (English)

```markdown
## Obsidian memory first (every turn · tiered v2)
Load the `obsidian-memory` skill once per session, then reuse it. Before answering any message: (0) read `.memory/MEMORY_DIGEST.md` first — reuse it if already read this session; (1) if not enough, search the index with `memory-search.mjs` and read only the top 3–5 summaries; (2) if needed, read an excerpt (first 60–80 lines or ±20 lines around a keyword); (3) only then read a full note (max 1–2, ≤8 KB each). Do not grep the whole vault, do not re-read the digest every turn, and do not repeat the same search for a follow-up. Cold archives are excluded unless the user asks about past conversations. If nothing relevant is found, say so in one line and answer normally; never invent memories.
```

## 中文版

```markdown
## Obsidian 记忆优先（每轮强制 · 分级检索 v2）
会话只加载一次 `obsidian-memory` skill，之后复用。每轮回答前：先读 `.memory/MEMORY_DIGEST.md` 小抄（本会话读过就复用）；不够再跑 `memory-search.mjs` 查索引，只看 top 3–5 条摘要；仍不够读候选笔记片段（前 60–80 行或关键词 ±20 行）；最后才读整篇（最多 1–2 篇，每篇 ≤8 KB）。不要全库 grep，不要每轮重复读小抄，同一话题追问不要重复搜索。冷归档默认不参与，只有用户问“之前聊过”才查。没查到就用一句话说明并正常回答，不要编造记忆。
```

## Where to put it

| Client | File |
| --- | --- |
| Claude Code | `CLAUDE.md` in the project, or `~/.claude/CLAUDE.md` globally |
| Codex CLI / ChatGPT desktop | `AGENTS.md` in the repo, or `~/.codex/AGENTS.md` globally |
| Cursor | `AGENTS.md` in the repo, or a `.cursor/rules/*.mdc` rule with `alwaysApply: true` |
| GitHub Copilot | `.github/copilot-instructions.md`, or user-level custom instructions |
| Gemini CLI | `GEMINI.md` |
| DSH | `AGENTS.md` in the workspace, or the global instruction file |
| Claude.ai / ChatGPT web | Personal preferences / custom instructions, or Project instructions |

## Manual invocation

- Claude Code: `/obsidian-memory`
- Codex CLI: `$obsidian-memory` (or open `/skills`)
- Cursor: `/obsidian-memory` or `@obsidian-memory`
- ChatGPT desktop: `@` and pick the skill
- Others: type the skill name with the client's invocation syntax

Always-on instructions affect every conversation in that scope. Prefer workspace-level files over global ones if the same machine also runs group-chat bots or unrelated agents.

## Rebuild the digest

If the digest is missing or stale (older than ~24h), run once:

```bash
node <skill base>/scripts/memory-build.mjs --vault "<VAULT>" --archive "Chats"
```
