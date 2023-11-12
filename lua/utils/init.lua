-- utils.lua

local M = {}

P = function(v)
  print(vim.inspect(v))
  return v
end

M.number_ordinal = function(n)
  local last_digit = n % 10
  if last_digit == 1 and n ~= 11
  then
    return 'st'
  elseif last_digit == 2 and n ~= 12
  then
    return 'nd'
  elseif last_digit == 3 and n ~= 13
  then
    return 'rd'
  else
    return 'th'
  end
end

M.datef = function(datestr, date)
  local date = date or os.date("*t", os.time())
  local datestr = string.gsub(datestr, "%%o", M.number_ordinal(date.day))
  return os.date(datestr, os.time(date))
end

local urand = assert(io.open('/dev/urandom', 'rb'))

M.crypto_seed = function()
  local b = 4
  local m = 256
  local r = urand
  local n, s = 0, r:read(b)

  for i = 1, s:len() do
    n = m * n + s:byte(i)
  end

  return n
end

-- M.get_secure_rand = function(opts)
--   local opts = opts and opts or {}
--
--   local handle = io.popen('openssl rand -hex 20')
--   local output = handle:read('*a')
--   local rand = output:gsub('[\n\r]', ' ')
--   handle:close()
--   return rand
-- end

return M
