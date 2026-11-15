# Memory packs (for clients without local file access)

Some clients — ChatGPT on the web, Claude.ai, mobile apps, cloud agents — cannot read files on your computer. For those, generate a **memory pack**: a single Markdown snapshot of the most useful notes, then attach or paste it into the conversation (or add it to a Project).

## Build a pack

From the installed skill folder (or this repository):

```bash
node scripts/memory-pack.mjs --vault "D:\Obsidian\MyVault" --out MEMORY_PACK.md
```

Options:

| Flag | Default | Meaning |
| --- | --- | --- |
| `--vault <path>` | `$OBSIDIAN_VAULT` | Obsidian vault root |
| `--out <file>` | `MEMORY_PACK.md` | Output file |
| `--max-chars <n>` | `40000` | Soft size budget for the whole pack |
| `--days <n>` | `90` | A note counts as "recent" within this many days |
| `--include-archive` | off | Include notes from archive / snapshot folders |

The script is plain Node.js (18+), zero dependencies. It never writes into the vault.

## What the pack contains

1. **Profile & preferences** — notes whose path or tags mention profile / about / preferences.
2. **Goals & priorities** — notes mentioning goals, plans, priorities.
3. **Active projects** — notes mentioning projects / work.
4. **Recent notes** — updated within `--days`, newest first.
5. **Full index** — every scanned note as `path — title (date)`.

Each section carries short excerpts within the size budget, so a chat-only model still gets the gist.

## Use a pack

- **ChatGPT web / mobile:** start a Project, add `MEMORY_PACK.md` as a project file (or attach it to the chat), and tell the model to use it as memory.
- **Claude.ai:** attach `MEMORY_PACK.md` to the conversation or add it to a Project.
- **Codex/ChatGPT desktop "Work" surfaces:** attach the file when local skills are unavailable.
- **Any chat client:** paste the pack into the first message or custom instructions if attachments are not supported.

Refresh the pack after big changes. Keep it local: it contains private note excerpts. Add `MEMORY_PACK*.md` to `.gitignore` if you run the script inside a git repository.

## Privacy

The pack is plain text, stored where you choose. Treat it like your notes themselves: do not upload it to public services, and do not commit it to a repository.
