local aerial = require('aerial')
local M = {}

function M.whereami()
  local location=aerial.get_location(true)
  local path=""
  local lastKnownWord=""

  for unused, tables in pairs(location) do
    -- print(vim.inspect(tables))
    for key, value in pairs(tables) do
      if key == "name" then
        if path.len(path) == 0 then
          path = value
        else
          path = path .. "." .. value
        end
        lastKnownWord = value
      end
    end
  end

  local currentCursorWord = vim.fn.expand('<cword>')

  if currentCursorWord ~= lastKnownWord then
    path = path .. "." .. currentCursorWord
  end
  print(path)
end

return M
