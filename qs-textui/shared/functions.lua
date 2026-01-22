-- Utility Functions for TextUI
-- Provides logging, table operations, and helper functions

-- Debug logging function (only prints if Config.Debug is enabled)
function Debug(...)
  if not Config.Debug then
    return
  end
  
  local message = "^2[TEXT UI DEBUG]^0 "
  local args = {...}
  
  for _, value in pairs(args) do
    if type(value) == "table" then
      message = message .. json.encode(value) .. "\t"
    else
      message = message .. tostring(value) .. "\t"
    end
  end
  
  print(message)
end

-- Warning logging function
function Warning(...)
  local message = "^3[TEXT UI WARNING]^0 "
  local args = {...}
  
  for _, value in pairs(args) do
    message = message .. tostring(value) .. "\t"
  end
  
  print(message)
end

-- Info logging function
function Info(...)
  local message = "^[5TEXT UI INFO]^0 "
  local args = {...}
  
  for _, value in pairs(args) do
    message = message .. tostring(value) .. "\t"
  end
  
  print(message)
end

-- Error logging function
function Error(...)
  local message = "^1[TEXT UI ERROR]^0 "
  local args = {...}
  
  for _, value in pairs(args) do
    message = message .. tostring(value) .. "\t"
  end
  
  print(message)
end

-- Loop error - continuously prints an error message
function LoopError(...)
  local errorMessage = table.unpack({...})
  
  CreateThread(function()
    while true do
      print("^1[ERROR]^7", errorMessage)
      Wait(2000)
    end
  end)
end

-- Table utility: Check if a value exists in a table
function table.includes(tbl, value)
  if not tbl then
    return false
  end
  
  for _, item in pairs(tbl) do
    if item == value then
      return true
    end
  end
  
  return false
end

-- Table utility: Deep clone a table (recursive)
function table.deepclone(tbl)
  local cloned = table.clone(tbl)
  
  for key, value in pairs(cloned) do
    if type(value) == "table" then
      cloned[key] = table.deepclone(value)
    end
  end
  
  return cloned
end

-- Table utility: Find an element in a table
-- Can use a function predicate or direct value comparison
function table.find(tbl, searchValue)
  if not tbl then
    return false, false
  end
  
  for key, value in pairs(tbl) do
    if type(searchValue) == "function" then
      -- Use predicate function
      if searchValue(value, key) then
        return value, key
      end
    else
      -- Direct value comparison
      if value == searchValue then
        return value, key
      end
    end
  end
  
  return false, false
end

-- String utility: Split a string by delimiter
function string.split(str, delimiter)
  delimiter = delimiter or ":"
  local result = {}
  local pattern = string.format("([^%s]+)", delimiter)
  
  str:gsub(pattern, function(match)
    result[#result + 1] = match
  end)
  
  return result
end

-- Table utility: Filter a table based on a predicate function
function table.filter(tbl, predicate)
  local filtered = {}
  
  for key, value in pairs(tbl) do
    if predicate(value, key, tbl) then
      table.insert(filtered, value)
    end
  end
  
  return filtered
end

-- Table utility: Map a table to a new table using a transformer function
function table.map(tbl, transformer)
  local mapped = {}
  
  for key, value in pairs(tbl) do
    table.insert(mapped, transformer(value, key, tbl))
  end
  
  return mapped
end

-- Table utility: Create a slice of a table
function table.slice(tbl, startIndex, endIndex, step)
  local sliced = {}
  startIndex = startIndex or 1
  endIndex = endIndex or #tbl
  step = step or 1
  
  for i = startIndex, endIndex, step do
    sliced[#sliced + 1] = tbl[i]
  end
  
  return sliced
end

-- Dependency checker: Checks if required resources are started
-- Takes a table of resource names mapped to values
-- Returns the value of the first started resource found, or false if none are started
function DependencyCheck(resourceMap)
  for resourceName, value in pairs(resourceMap) do
    local state = GetResourceState(resourceName)
    if state:find("started") ~= nil then
      return value
    end
  end
  
  return false
end