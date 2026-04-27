-- init.lua
--
-- Bootstrap only. The real config lives in README.md (literate source) and is
-- tangled to lua/config.lua. To regenerate from a shell:
--   nvim --headless -l tangle.lua
-- Inside Neovim, run :Tangle.

local ok, err = pcall(require, "config")

if not ok then
  -- First run (or lua/config.lua deleted): tangle README.md, then retry.
  local tangler = vim.fn.stdpath("config") .. "/tangle.lua"
  if vim.loop.fs_stat(tangler) then
    dofile(tangler)
    ok, err = pcall(require, "config")
  end
end

if not ok then
  vim.notify("config load failed: " .. tostring(err), vim.log.levels.ERROR)
end
