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

function M.readtext(node)
  local startrow, startcolumn, startbyte_count = node:start()
  startcolumn = startcolumn + 1
  local endrow, endcolumn, endbyte_count = node:end_()
  local currentBuffer = vim.api.nvim_get_current_buf()
  local currentLine = vim.api.nvim_buf_get_lines(currentBuffer, startrow, endrow+1, false)[1]
  local nodeText = string.sub(currentLine, startcolumn, endcolumn)
  local replaced, count = nodeText:gsub(":", "")
  return replaced 
end

function M.readChildren(node)
  for child in node:iter_children() do
    if child:type() ~= "comment" and child:type() == "block_mapping_pair" then
      -- print(M.readtext(child:named_child(0)))
    end
    M.readChildren(child)
  end
end

function M.arraySize(pathArray)
  -- print("arraySize: array contents: " .. vim.inspect(pathArray))
  local i = 0
  for _, element in pairs(pathArray) do
    i = i + 1
  end
  return i
end

function M.subArray(pathArray, start, endsize)
  -- print("subArray: array contents: " .. vim.inspect(pathArray))
  local i = 1
  local newArray = {}
  local newSize = 0
  for _, element in pairs(pathArray) do
    -- print("i = " .. i)
    -- print("start = " .. start)
    -- print("endsize = " .. endsize)
    if i >= start and i <= endsize then
      newSize = newSize + 1
      -- print("newSize = " .. newSize)
      newArray[newSize] = element
      -- print("newArray[i] = " .. newArray[newSize])
    end
    i = i + 1
  end
  -- print("newArray: array contents: " .. vim.inspect(newArray))
  return newArray
end

function M.deepestNode(pathArray, node)
  if M.arraySize(pathArray) == 0 then
    return node
  end

  for child in node:iter_children() do
    for innerChild in child:iter_children() do
      for innerInnerChild in innerChild:iter_children() do
        if innerInnerChild:type() ~= "comment" and innerInnerChild:type() == "block_mapping_pair" then
          local text = M.readtext(innerInnerChild:named_child(0))
          -- print("Array 1" .. pathArray[1])
          if text == pathArray[1] then
            local size = M.arraySize(pathArray)
            local subArray = M.subArray(pathArray, 2, size)
            -- print(text)
            return M.deepestNode(subArray, innerInnerChild)
          end
        end
      end
    end
  end
end

function M.jumptopath(path)
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()
  local parent = node
  local lastParent = parent
  while parent ~= nil and parent:type() ~= "document" do
    local parentText = M.readtext(parent)
    local type = parent:type()
    if type == "block_mapping_pair" then
      -- print(parentText)
    end
    lastParent = parent
    parent = parent:parent()
  end

  if lastParent:parent() ~= nil then
    lastParent = lastParent:parent()
  end

  M.readChildren(lastParent)

  local pathArray = {}
  local i = 0
  for subpath in string.gmatch(path, "[^%.]+") do
    i = i + 1
    pathArray[i] = subpath
  end
  deepest = M.deepestNode(pathArray, lastParent)
  ts_utils.goto_node(deepest, false, false)
end

return M
