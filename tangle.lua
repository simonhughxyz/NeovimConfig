-- tangle.lua
--
-- Extracts every ```lua fenced block from README.md and writes the
-- concatenation to lua/config.lua. README.md is the canonical literate
-- source for this config.
--
-- Headless invocation (no user config loaded):
--   nvim --headless -l tangle.lua
--
-- Also exposed as :Tangle inside Neovim (see EXCOMMANDS section).

local function script_dir()
  local info = debug.getinfo(1, "S").source
  if info:sub(1, 1) == "@" then
    info = info:sub(2)
  end
  return info:match("(.*/)") or "./"
end

local function tangle()
  local dir = script_dir()
  local source = dir .. "README.md"
  local target = dir .. "lua/config.lua"

  local src = assert(io.open(source, "r"), "cannot open " .. source)
  local out = {}
  local inside = false
  for line in src:lines() do
    if not inside then
      if line == "```lua" then
        inside = true
      end
    else
      if line == "```" then
        inside = false
      else
        out[#out + 1] = line
      end
    end
  end
  src:close()

  assert(not inside, "unterminated ```lua fence in " .. source)

  vim.fn.mkdir(dir .. "lua", "p")

  local dst = assert(io.open(target, "w"), "cannot open " .. target)
  dst:write("-- AUTO-GENERATED from README.md by tangle.lua. Do not edit.\n\n")
  dst:write(table.concat(out, "\n"))
  dst:write("\n")
  dst:close()

  return #out, target
end

local n, target = tangle()
io.write(string.format("tangled %d lines -> %s\n", n, target))
