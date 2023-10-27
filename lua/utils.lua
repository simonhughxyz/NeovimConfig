-- utils.lua

local M = {}

M.number_ordinal = function(n)
    local last_digit = n % 10
    if last_digit == 1 and n ~= 11
        then return 'st'
    elseif last_digit == 2 and n ~= 12
        then return 'nd'
    elseif last_digit == 3 and n ~= 13
        then return 'rd'
    else
        return 'th'
    end
end

M.datef = function(datestr, date)
  local date = date or os.date("*t", os.time())
  local datestr = string.gsub(datestr, "%%o", M.number_ordinal(date.day))
  return os.date(datestr, os.time(date))
end

return M
