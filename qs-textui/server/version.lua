-- Version Checker
-- Automatically checks for updates from GitHub and notifies about new versions

-- Get current resource version and name
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
local resourceName = GetCurrentResourceName()

-- Convert version string to comparable number
-- Example: "1.2.3" -> 123
local function versionToNumber(versionString)
  local parts = versionString:split(".")
  local result = ""
  
  for i = 1, #parts do
    result = result .. parts[i]
  end
  
  return tonumber(result)
end

-- Compare versions and return difference with descriptions
local function compareVersions(remoteVersion, descriptions)
  local currentVersionNum = versionToNumber(currentVersion)
  local remoteVersionNum = versionToNumber(remoteVersion)
  local difference = remoteVersionNum - currentVersionNum
  
  return difference, descriptions
end

-- Only check version if it's defined in the manifest
if currentVersion then
  -- Construct GitHub API URL

  
  -- Perform HTTP request to check for updates
  PerformHttpRequest(versionUrl, function(statusCode, responseBody, headers)
    -- Handle API unavailable
    if statusCode == 404 then
      return
    end
    
    -- Handle successful response
    if statusCode == 200 then
      local versionData = json.decode(responseBody)
      local remoteVersion = versionData.version
      local descriptions = versionData.descriptions
      
      local versionDiff, changeLog = compareVersions(remoteVersion, descriptions)
      
      if versionDiff == 0 then
        -- Using latest version
        print("^2You are using the latest version of " .. resourceName .. "!^0")
        
      elseif versionDiff > 0 then
        -- Update available
        print("^3New version available for " .. resourceName .. "!^0")
        
        -- Print changelog
        for _, description in pairs(changeLog) do
          print("^3- " .. description .. "^0")
        end
        
        print("^3You have version " .. currentVersion .. 
              ", upgrade to version " .. remoteVersion .. "!^0")
              
      else
        -- Using newer version than available
        print("^1You are using a newer version of " .. resourceName .. 
              " than the one available on GitHub.^0")
      end
    end
  end, "GET", "", {}, {})
  
else
  -- Version not defined in manifest
  print("Unable to obtain the version of " .. resourceName .. 
        ". Make sure it is defined in your fxmanifest.lua.")
end