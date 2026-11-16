---
name: obsidian-memory
description: "Recall-first, token-efficient memory from a local Obsidian vault. Load this skill before answering ANY user message to run a tiered recall: read the generated digest first, then search the compact index, then read note excerpts, and only then full notes. Works with any Agent Skills client: Claude Code, ChatGPT/Codex, Cursor, GitHub Copilot, Gemini CLI, DeepSeek Harness. 中文触发：回答任何消息前，先看小抄→查索引→读片段→才读全文，分级检索省 token。"
license: MIT
compatibility: "Any Agent Skills-compatible client. Best with local file search/read tools and a shell for the index scripts (Claude Code, Codex CLI, Cursor, GitHub Copilot, Gemini CLI, DSH). Chat-only clients can use an attached memory pack (or the digest) instead."
metadata:
  version: "2.0.0"
  homepage: "https://github.com/ImportMyBrain/obsidian-memory-anywhere"
---

# Obsidian Memory — tiered recall (v2)

A portable, token-efficient workflow: before answering, recall relevant notes in tiers — digest → index → excerpt → full note — and integrate them into the answer. Never invent memories.

## 0. Configure (one minute, once)

- `VAULT`: `__VAULT_PATH__` — absolute path to the Obsidian vault root, e.g. `D:\Obsidian\MyVault` or `~/Obsidian/MyVault`
- `MEMORY_DIR`: `<VAULT>/.memory` — generated digest / index directory (default)
- `ARCHIVE_DIRS`: *(optional)* vault-relative folders treated as cold storage, e.g. `Chats`, `Archive`
- `MEMORY_PACK`: *(optional)* path to a generated memory pack, for chat-only clients

If `VAULT` is missing, empty, or still the template placeholder: ask the user for the vault path once, then configure. Do not guess the path.

## 1. Every turn: choose the access mode

| Mode | When | What to do |
| --- | --- | --- |
| **A. Vault access** | You have file-read/search tools (and ideally a shell) | Run the tiered recall → Section 2 |
| **B. Memory pack / digest** | No filesystem, but a `MEMORY_PACK.md` or `MEMORY_DIGEST.md` is attached/pasted | Use it → Section 4 |
| **C. Neither** | No vault access and no pack | Say so in one line, ask for a path or pack, then answer normally |

Never skip this check and never fabricate a memory that is not in the vault or the pack.

## 2. Mode A — tiered recall (Level 0 → 3)

**Level 0 · digest first (always)**
- Read `MEMORY_DIR/MEMORY_DIGEST.md` (~2–3 KB: entry notes, profile/preferences, goals, active projects, recent updates).
- If already read in this session and not rebuilt since: reuse it, do not re-read.
- If missing / older than 24h / you wrote back to the vault this turn: rebuild it once (Section 3), then read.

**Level 1 · search the index**
- Run: `node "<skill base>/scripts/memory-search.mjs" --vault "<VAULT>" --query "keyword1 keyword2" --top 5`
- 2–6 keywords. Read only the returned top 3–5 rows (title / path / updated / summary).
- Add `--include-cold` only when the user asks about past conversations ("we discussed this before") — cold archives are excluded by default.

**Level 2 · read an excerpt**
- Read the first 60–80 lines of a candidate note (frontmatter + intro).
- Need a specific detail: `grep` inside that note for the keyword, then read ±20 lines around the hit.
- Do not read long notes (>10 KB) in full at this level.

**Level 3 · read the full note (rare)**
- Only when the user asks for detail, or digest + index + excerpt are insufficient.
- At most 1–2 notes per turn, ≤8 KB each. Do not read cold archives in full unless explicitly asked.

- For a follow-up on the same topic: reuse previous results; search again only for a new entity/topic.
- No match: say "I couldn't find relevant notes in your Obsidian vault" in one line, then answer normally.

## 3. Build / rebuild the digest and index

When missing, older than 24h, or after a write-back:

```bash
node "<skill base>/scripts/memory-build.mjs" --vault "<VAULT>" --archive "Chats" --archive "Archive"
```

Outputs into `<VAULT>/.memory/`:

- `MEMORY_DIGEST.md` — Level 0 cheat sheet (~2–3 KB)
- `MEMORY_INDEX.md` — Level 1 human-readable index (one line per note)
- `index.json` — Level 1 machine index for `memory-search.mjs`

Build once at session start if stale; do not rebuild every turn.

## 4. Mode B — memory pack / digest

- A memory pack is a generated snapshot for clients without local file access (ChatGPT web, Claude.ai, mobile). See `references/memory-pack.md`.
- The digest is the smaller "cheat sheet" — if the client can only accept one file, attach the digest first; the pack is for deeper context.
- Treat the attached file as a read-only snapshot; cite note titles. If it lacks the answer, say so; ask the user to regenerate if stale.

## 5. Token budget

- Digest ≤3 KB; search output ≤2 KB; excerpt ≤1.5 KB/note; full notes ≤2 and only when needed.
- Keep total recalled context around ≤8 KB per turn unless the user explicitly asks for a deep dive.
- Never grep the whole vault first, never read the whole index file, never re-read the digest/skill every turn.

## 6. Integrate into the answer

- Weave memory into the answer naturally; do not dump a list of notes.
- Let memory shape conclusions, priorities, tone and examples.
- Cite source and date; keep "what the note says" separate from "what I infer".
- Respect stored preferences (language, directness, teaching order, formatting).
- Sensitive information only when directly relevant; do not volunteer it.

## 7. Write back only when there is new information

- New fact / progress / preference change: update the matching note (keep its structure, bump the frontmatter `updated`) and add `[[links]]`.
- New project or goal: create a note and link it from the entry / overview.
- Never overwrite historical snapshots. Never store passwords, tokens or API keys.
- After writing back, rebuild the digest/index once (Section 3).

## 8. Privacy and safety

- Read-only by default; this workflow sends nothing anywhere.
- Do not read `.obsidian/`, system folders, attachments or binaries.
- Keep private notes out of group chats, shared sessions and third-party tools.
- Use this skill only for the vault owner's own sessions.

## 9. Make it run every turn (recommended)

Skills are usually loaded on demand. To run tiered recall before every answer, add the rule from `references/always-on.md` to the client's always-on instruction file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, custom instructions, etc.). Load the skill once per session; reuse it afterward.
