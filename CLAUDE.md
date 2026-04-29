# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Neovim configuration written as a **literate config** in Markdown. The single source of truth is `README.md`; `lua/config.lua` is generated.

## File roles (important — do not get this wrong)

- `README.md` — **edit this**. Literate Markdown document containing the entire config in ` ```lua ` fenced blocks. Tangled in document order.
- `tangle.lua` — pure-Lua extractor. Reads `README.md`, concatenates every ` ```lua ` block, writes `lua/config.lua`.
- `lua/config.lua` — **generated, do not edit**. Tangled output of `README.md`. The whole `lua/` directory is gitignored.
- `init.lua` — bootstrap only. Tries `require("config")`; if that fails (first run, missing `lua/config.lua`), runs `tangle.lua` automatically and retries.
- `nvim-pack-lock.json` — `vim.pack` lockfile, **committed**.

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

Just run `nvim`. `init.lua` notices `lua/config.lua` is missing, runs `tangle.lua`, then `require("config")` succeeds and `vim.pack` installs the rest of the plugins on demand. You may need to reopen Neovim once or twice while installs finish.

## Architecture

- **Plugin manager**: Neovim 0.12's built-in `vim.pack` (no `lazy.nvim`). The `# PACK` section reimplements the lazy.nvim features actually used in this config — parallel install, dependency ordering, `event`/`cmd`/`ft`/`keys` lazy-loading, `priority`, `build` hooks, and `config = true|fn|opts` dispatch — on top of `vim.pack.add` + `:packadd`. Plugin spec shape mirrors lazy.nvim, so per-plugin call sites are unchanged.
- **Plugin registration**: plugins are not declared in a flat spec — they are registered throughout `README.md` next to their own configuration via a helper `plug({...})` defined in the *Pack Helper Function* section. `plug` appends to a local `plugins` table and wraps `config` so a failing plugin setup is reported via `vim.notify` instead of breaking init. `require_main` resolves the require name from the repo (e.g. `catgoose/nvim-colorizer.lua` → `require("colorizer")`) by trying sensible variants.
- **Section ordering matters**: `README.md` is tangled top-to-bottom into one `lua/config.lua`. Setup variables (leader keys, `o`/`g`/`cmd` aliases, `plug()`, `P()`/`B()`) are defined at the top and used by every later section. The `# PACK` block must run after every `plug()` call, so it lives near the end. Add new plugins inside an existing topical section (e.g. `# GIT`, `# LSP`, `# AI`) rather than at the bottom.
- **Markdown UX**: `render-markdown.nvim` handles concealing/styling for markdown buffers; `obsidian.nvim` handles workspaces/journal/frontmatter; `otter.nvim` gives embedded LSP inside fenced code blocks. The `# EDIT CODE BLOCK` section provides a small native `edit_code_block` function (`<localleader>cg`) that opens the fenced block under the cursor in a floating scratch buffer with the inner filetype set, splicing edits back on `:w` — replaces the unmaintained `nvim-FeMaco.lua` and uses `vim.treesitter` directly with no plugin dependency.
- **Keymaps**: plugin-specific maps live with the plugin in `README.md`. Global non-plugin maps live in the `# KEYMAPS` section. The `map()` wrapper consults `lazy_keys_index` (populated by the `# PACK` lazy-key trigger registrar) to avoid clobbering keys that a deferred plugin will eventually claim when first triggered.
- **Leaders**: `<leader>` is `<Space>`, `<localleader>` is `<Space><Space>`. Set in `# SETUP VARIABLES AND FUNCTIONS / Leader keys` and must stay first.
- **Globals exposed**: `P(v)` pretty-prints a Lua value via `vim.inspect`; `B(v)` opens a scratch buffer with the inspected value. Use these for debugging.

## Philosophy

Simon's priorities, in order: **stability > speed > simplicity**. When in doubt, prefer the boring, proven choice.

- **Vim-native first**: prefer built-in Neovim features and APIs over plugin equivalents. Only reach for a plugin when the built-in genuinely cannot do the job. Don't fight vim's model — motions, operators, text objects, and the buffer/window/tab hierarchy should all work as expected.
- **Stability over features**: avoid plugins that are unstable, frequently-breaking, or require constant workarounds. Pinned versions and conservative upgrades are fine.
- **Speed**: startup time matters. Plugins should be lazy-loaded where possible (`event`, `cmd`, `ft`, `keys`). Don't add plugins that block the main loop or slow `BufReadPost`.
- **Simplicity**: fewer plugins doing more is better than many plugins each doing one tiny thing. Prefer removing code over adding it. Don't configure things that don't need configuring — if the default is fine, leave it alone. `opts = {}` and `enabled = true` are noise; remove them.
- **No deviations from vim conventions**: keymaps should follow vim's mental model (`[`/`]` for prev/next, `g` prefix for extended motions, `z` for fold/view, operator+motion composition). Don't remap standard keys (`H`, `L`, `K`, `gw`, etc.) without a strong reason.

## Comments

Write comments in config code when the *why* is non-obvious — a hidden constraint, a workaround, a subtle interaction between plugins. Don't describe what the code does if the code is self-evident.

Use these tags in comments:
- `-- NOTE:` for important context or non-obvious behaviour the reader should know
- `-- FIX:` for known issues, bugs, or workarounds that should eventually be resolved
- `-- HACK:` for pragmatic compromises that work but feel wrong
- `-- TODO:` for things that should be done but aren't yet

Example:
```lua
-- NOTE: capabilities must be set before vim.lsp.enable() is called
-- FIX: lua_ls incorrectly flags vim.* globals without this diagnostics override
vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
```

## Conventions

- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:` …) — see recent `git log` and the `gitcommit` snippets in the `# SNIPPETS` section.
- When adding a plugin, register it with `plug({ ... })`, not by mutating `plugins` directly. If `config = true`, `config = {}`, or `config = nil` with `opts`, the helper auto-resolves `require(<main>).setup(opts)` (trying `.nvim` / `.lua` / `nvim-` / `vim-` strippings, plus a lowercased variant).
- After editing `README.md`, always re-tangle (`:Tangle` or `nvim --headless -l tangle.lua`) before testing — running Neovim reads `lua/config.lua`, not the markdown.
- Fenced lua blocks must use exactly ` ```lua ` (lowercase, no extra whitespace) and close with bare ` ``` `. The tangler matches lines verbatim.

## Working efficiently in this repo

- **Opus 4.7 supervises, Sonnet 4.6 workers do the work.** The main thread plans, decides, and reviews; non-trivial reads, searches, edits, and rewrites get delegated to an Agent (`subagent_type: general-purpose` with `model: "sonnet"`, or `Explore` for searches). Ask for a short report back, not a transcript.
- **Why:** `README.md` is large (~3000 lines). Reading and grepping it in the supervisor thread burns context fast; offloading to a Sonnet worker keeps the main session lean.
- **Keep token usage low.** Read targeted line ranges, not whole files. Locate sections by their `# SECTION` headers via `grep` / `Explore` before opening. Don't re-read a section that hasn't changed.
- When delegating, give the worker the section header and approximate line (e.g. "the `# PACK` block, around `README.md:3091`") so it doesn't waste turns re-searching.
- Small surgical edits where you already know the exact `old_string` are fine in the supervisor thread — don't spawn a worker just to call `Edit`.
