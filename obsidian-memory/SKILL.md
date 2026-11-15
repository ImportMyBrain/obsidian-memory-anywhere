---
name: obsidian-memory
description: "Recall-first memory from a local Obsidian vault. Load this skill before answering ANY user message (new chats, follow-ups, simple questions) to search the user's Obsidian notes for relevant memories and integrate them into the answer. Works with any Agent Skills client: Claude Code, ChatGPT/Codex, Cursor, GitHub Copilot, Gemini CLI, DeepSeek Harness. 中文触发：回答任何消息前，先查 Obsidian 记忆再回答。"
license: MIT
compatibility: "Any Agent Skills-compatible client. Best with local file search/read tools (Claude Code, Codex CLI, Cursor, GitHub Copilot, Gemini CLI, DSH). Chat-only clients can use an attached MEMORY_PACK.md instead."
metadata:
  version: "1.0.0"
  homepage: "https://github.com/ImportMyBrain/obsidian-memory-anywhere"
---

# Obsidian Memory — recall first, answer second

A portable workflow: before answering, look up the relevant notes in the user's local Obsidian vault, judge what is current, and weave the result into the answer. Never invent memories.

## 0. Configure (one minute, once)

Replace this placeholder with the user's real vault path:

- `VAULT`: `__VAULT_PATH__` — absolute path to the Obsidian vault root, e.g. `D:\Obsidian\MyVault` or `~/Obsidian/MyVault`
- `PROFILE_DIR`: *(optional)* vault-relative folder with the user's profile / preference notes, e.g. `Profile`
- `ARCHIVE_DIR`: *(optional)* vault-relative folder with archived conversations, e.g. `Chats`
- `MEMORY_PACK`: *(optional)* path to a generated memory pack, e.g. `MEMORY_PACK.md`

If `VAULT` is still the placeholder `__VAULT_PATH__`, the skill is not configured: ask the user for the vault path once, then search. Do not guess the path.

## 1. Every turn: choose the memory access mode

Decide how you can reach memory **before** answering. Do this every turn, including one-word follow-ups.

| Mode | When | What to do |
| --- | --- | --- |
| **A. Vault access** | You have file-read / search tools or a shell | Search the vault directly → Section 2 |
| **B. Memory pack** | No filesystem, but a `MEMORY_PACK.md` is attached or pasted | Use the pack → Section 4 |
| **C. Neither** | No vault access and no pack | Say so in one line, ask for a path or a pack, then answer normally |

Never skip this check and never fabricate a memory that is not in the vault or the pack.

## 2. Mode A — search the vault

1. **Extract 2–6 keywords** from the message: people, projects, courses, goals, dates, proper nouns. Add synonyms: abbreviations, full names, translations.
2. **Read the entry notes first** when present: `00 首页.md`, `Home.md`, `README.md`, `index.md`, or an `MOC` note in the vault root or the profile folder. They reveal the structure and current priorities.
3. **Search once with a regex** like `keyword1|keyword2|keyword3`:
   - Claude Code: `Grep` / `Glob` / `Read`
   - Codex CLI, Cursor, GitHub Copilot, Gemini CLI: a shell (`rg`, `grep`, `find`) or the client's own search/read tools
   - DSH: `grep` / `glob` / `read`
   Search only `*.md` files; skip `.obsidian/`, `.trash/`, `_source/`, attachments and binary files.
4. **Read the top 3–5 matches.** Check frontmatter `updated` / `created`, then the body status. For long notes, read the outline (headings) first.
5. **Classify each note**: direct (use it) / background (shapes tone, depth and priorities) / historical snapshot (supplement only) / irrelevant (skip, don't force it).
6. **Resolve conflicts by recency**: the note with the newer `updated` wins. If it is still ambiguous, say "I found two versions — using the newer one".
7. **Control cost**: at most 1–2 searches and 5 reads. For a follow-up on the same topic, reuse the previous results unless the message introduces a new entity.

## 3. Integrate into the answer

- Weave memory into the answer naturally; do not dump a list of notes.
- Let memory shape conclusions, priorities, tone and examples.
- Cite source and date, for example "according to your Nov 10 note on X...". Keep "what the note says" separate from "what I infer".
- Respect the user's stored preferences: language, directness, teaching order, formatting.
- Sensitive information (finances, IDs, accounts, health, family) only when directly relevant; do not volunteer it.
- **No relevant memory found**: say "I couldn't find relevant notes in your Obsidian vault" in one line, then answer normally. Never invent a memory.

## 4. Mode B — use a memory pack

A memory pack is a generated Markdown snapshot of the vault for clients without local file access (ChatGPT web, Claude.ai, mobile apps, etc.). See `references/memory-pack.md` for how to build and refresh one.

- Read the attached or pasted pack; treat it as a read-only snapshot of the user's notes.
- Locate the relevant section (profile, goals, projects, recent notes) and cite the note heading it came from.
- If the pack does not contain the answer, say so; do not extrapolate beyond the pack.
- If the pack looks stale, ask the user to regenerate it (it starts with a generation date).

## 5. Write back only when there is new information

- New fact, progress or preference change: update the matching note under `PROFILE_DIR` (keep its structure, bump the frontmatter `updated`) and add `[[links]]` to related notes.
- New project or goal: create a note in the right folder and link it from the entry or overview note.
- Never overwrite historical snapshots. Never store passwords, tokens or API keys. If nothing is new, do not touch the vault.

## 6. Privacy and safety

- Read-only by default; this workflow sends nothing anywhere.
- Do not read `.obsidian/`, system folders, attachments or binaries.
- Keep private notes out of group chats, shared sessions and third-party tools.
- Use this skill only for the vault owner's own sessions.

## 7. Make it run every turn (recommended)

Skills are usually loaded on demand. To run this workflow before every answer, add the one-line rule from `references/always-on.md` to the client's always-on instruction file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, ChatGPT/Claude custom instructions, etc.).
