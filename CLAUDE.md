# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Neovim configuration written as a **literate config** in Markdown. The single source of truth is `README.md`; `lua/config.lua` is generated.

## File roles (important — do not get this wrong)

- `README.md` — **edit this**. Literate Markdown document containing the entire config in ` ```lua ` fenced blocks. Tangled in document order.
- `tangle.lua` — pure-Lua extractor. Reads `README.md`, concatenates every ` ```lua ` block, writes `lua/config.lua`.
- `lua/config.lua` — **generated, do not edit**. Tangled output of `README.md`. Gitignored (`.gitignore`).
- `init.lua` — bootstrap only. Tries `require("config")`; if that fails (first run, missing `lua/config.lua`), runs `tangle.lua` automatically and retries.
- `lazy-lock.json` — gitignored.

If asked to change config behavior, edit `README.md` and re-tangle. Do not edit `lua/config.lua` directly — it will be overwritten.

## Tangle (regenerate `lua/config.lua`)

Headless one-shot:

```sh
nvim --headless -l tangle.lua
```

(`-l` runs a Lua script with no user init — fast, no plugin dependency.)

Inside Neovim, after editing `README.md`, run `:Tangle` (defined in the EXCOMMANDS section). Restart Neovim afterwards to load the regenerated config.

The extractor is a simple state machine: it appends every line between a line equal to ` ```lua ` and the next line equal to ` ``` `. Indented fences are not recognized. There is no front-matter directive — the source is hard-coded as `README.md` next to `tangle.lua`.

## First-time bootstrap

Just run `nvim`. `init.lua` notices `lua/config.lua` is missing, runs `tangle.lua`, then `require("config")` succeeds and Lazy installs the rest of the plugins. You may need to reopen Neovim once or twice while Lazy finishes.

## Architecture

- **Plugin manager**: `lazy.nvim`. Plugins are not declared in a flat spec — they are registered throughout `README.md` next to their own configuration via a helper `plug({...})` defined in the *Lazy Helper Function* section. `plug` appends to a local `plugins` table and wraps `config` so a failing plugin setup is reported via `vim.notify` instead of breaking init. `require('lazy').setup(plugins, {})` is called at the end (`# LAZY` section).
- **Section ordering matters**: `README.md` is tangled top-to-bottom into one `lua/config.lua`. Setup variables (leader keys, `o`/`g`/`cmd` aliases, `plug()`, `P()`/`B()`) are defined at the top and used by every later section. Add new plugins inside an existing topical section (e.g. `# GIT`, `# LSP`, `# AI`) rather than at the bottom.
- **Markdown UX**: `render-markdown.nvim` handles concealing/styling for markdown buffers; `obsidian.nvim` handles workspaces/journal/frontmatter; `otter.nvim` gives embedded LSP inside fenced code blocks; `nvim-FeMaco.lua` edits a code block in a floating buffer (`<localleader>cg`).
- **Keymaps**: plugin-specific maps live with the plugin in `README.md`. Global non-plugin maps live in the `# KEYMAPS` section, which uses a local `map()` wrapper that defers to `lazy.core.handler` to avoid clobbering plugin-defined keys.
- **Leaders**: `<leader>` is `<Space>`, `<localleader>` is `<Space><Space>`. Set in `# SETUP VARIABLES AND FUNCTIONS / Leader keys` and must stay first.
- **Globals exposed**: `P(v)` pretty-prints a Lua value via `vim.inspect`; `B(v)` opens a scratch buffer with the inspected value. Use these for debugging.

## Conventions

- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:` …) — see recent `git log` and the `gitcommit` snippets in the `# SNIPPETS` section.
- When adding a plugin, register it with `plug({ ... })`, not by mutating `plugins` directly. If `config = true` or `config = {}`, the helper auto-resolves `require(<main>).setup(opts)` and strips a trailing `.nvim`.
- After editing `README.md`, always re-tangle (`:Tangle` or `nvim --headless -l tangle.lua`) before testing — running Neovim reads `lua/config.lua`, not the markdown.
- Fenced lua blocks must use exactly ` ```lua ` (lowercase, no extra whitespace) and close with bare ` ``` `. The tangler matches lines verbatim.
