--[[
    QS-TEXTUI
    Full compatibility with:
    - lunar_bridge
    - esx_textui
    - okokTextUI
    - cd_drawtextui
    - jg-textui
    - ox_lib (drawTextUI)
    - qb-core (DrawText)
]]

Config = Config or {}
Config.Debug = false
Config.Colors = {
    insideBackground = "radial-gradient(50% 50% at 50% 50%, #006299 0%, #00a3ff 100%)",
    insideBorder = "4px solid #0190e1",
    insideBoxShadow = "0px 0px 22px 0px rgba(0, 163, 255, 0.8)",
    backgroundAnimateColor = "rgba(0, 163, 255, 1)"
}

-- =====================================================
-- STATE
-- =====================================================

local points = {}
local pointCallbacks = {}
local activePoint = nil
local selectedIndex = 1
local isNuiFocused = false
local currentTextUI = nil

-- =====================================================
-- UTILITY
-- =====================================================

local function Debug(...)
    if Config.Debug then
        print("[qs-textui]", ...)
    end
end

local function GenerateId()
    return 'point_' .. math.random(100000, 999999) .. '_' .. GetGameTimer()
end

local function GetPlayerJob()
    -- QBCore
    local QBCore = exports['qb-core']:GetCoreObject()
    if QBCore then
        local pd = QBCore.Functions.GetPlayerData()
        if pd and pd.job then
            return pd.job.name
        end
    end
    
    -- ESX
    if ESX then
        local pd = ESX.GetPlayerData()
        if pd and pd.job then
            return pd.job.name
        end
    end
    
    return nil
end

local function GetPlayerGang()
    local QBCore = exports['qb-core']:GetCoreObject()
    if QBCore then
        local pd = QBCore.Functions.GetPlayerData()
        if pd and pd.gang then
            return pd.gang.name
        end
    end
    return nil
end

-- =====================================================
-- CHECK REQUIREMENTS
-- =====================================================

local function CheckRequirements(option)
    if not option then return false end
    
    -- Job check
    if option.job then
        local job = GetPlayerJob()
        if type(option.job) == "table" then
            local has = false
            for _, j in ipairs(option.job) do
                if j == job then has = true break end
            end
            if not has then return false end
        elseif option.job ~= job then
            return false
        end
    end
    
    -- Gang check
    if option.gang then
        local gang = GetPlayerGang()
        if type(option.gang) == "table" then
            local has = false
            for _, g in ipairs(option.gang) do
                if g == gang then has = true break end
            end
            if not has then return false end
        elseif option.gang ~= gang then
            return false
        end
    end
    
    -- canInteract
    if option.canInteract then
        local ok, result = pcall(option.canInteract)
        if ok and not result then return false end
    end
    
    return true
end

-- =====================================================
-- SIMPLE TEXT UI (2D, fixed position)
-- =====================================================

local function ShowTextUI(text, options)
    options = options or {}
    
    local key = nil
    
    -- Parse key from text if format is "[E] Text"
    if text then
        local k, t = string.match(text, "%[(%w+)%]%s*(.*)")
        if k then
            key = k
            text = t
        end
    end
    
    key = options.key or key
    
    currentTextUI = { text = text, key = key }
    
    SendNUIMessage({
        action = "showSimpleText",
        text = text,
        key = key
    })
end

local function HideTextUI()
    if currentTextUI then
        SendNUIMessage({ action = "hideSimpleText" })
        currentTextUI = nil
    end
end

-- =====================================================
-- POINT SYSTEM (3D markers with options)
-- =====================================================

local function AddPoint(data)
    if not data or not data.coords then
        print("^1[qs-textui]^7 Error: addPoint requires coords")
        return nil
    end
    
    local id = data.id or GenerateId()
    
    -- Separate callbacks
    local callbacks = {}
    local optionsClean = {}
    
    if data.options then
        for i, opt in ipairs(data.options) do
            callbacks[i] = {
                onSelect = opt.onSelect,
                canInteract = opt.canInteract
            }
            optionsClean[i] = {
                label = opt.label or opt.text or "Option",
                icon = opt.icon,
                key = opt.key or "E",
                job = opt.job,
                gang = opt.gang
            }
        end
    end
    
    pointCallbacks[id] = callbacks
    
    points[id] = {
        id = id,
        coords = vector3(data.coords.x, data.coords.y, data.coords.z),
        distance = data.distance or 2.0,
        displayDistance = data.displayDistance or data.renderDistance or 10.0,
        options = optionsClean,
        resource = GetInvokingResource() or GetCurrentResourceName()
    }
    
    Debug("Point added:", id)
    return id
end

local function RemovePoint(id)
    if points[id] then
        points[id] = nil
        pointCallbacks[id] = nil
        
        if activePoint == id then
            activePoint = nil
            selectedIndex = 1
            SendNUIMessage({ action = "hide" })
        end
        Debug("Point removed:", id)
    end
end

local function RemovePointsByResource(res)
    local toRemove = {}
    for id, p in pairs(points) do
        if p.resource == res then
            table.insert(toRemove, id)
        end
    end
    for _, id in ipairs(toRemove) do
        RemovePoint(id)
    end
end

-- =====================================================
-- EXPORTS - MAIN
-- =====================================================

exports("addPoint", AddPoint)
exports("removePoint", RemovePoint)
exports("showTextUI", ShowTextUI)
exports("hideTextUI", HideTextUI)

-- =====================================================
-- EXPORTS - COMPATIBILITY (esx_textui style)
-- =====================================================

exports("TextUI", function(text, type)
    ShowTextUI(text, { style = type })
end)

exports("HideUI", HideTextUI)

-- =====================================================
-- EXPORTS - COMPATIBILITY (okokTextUI style)
-- =====================================================

exports("Open", function(text, type, position)
    ShowTextUI(text, { style = type, position = position })
end)

exports("Close", HideTextUI)

-- =====================================================
-- EXPORTS - COMPATIBILITY (cd_drawtextui style)
-- =====================================================

exports("ShowText", function(key, text)
    ShowTextUI(text, { key = key })
end)

exports("HideText", HideTextUI)

-- =====================================================
-- EXPORTS - COMPATIBILITY (jg-textui style)
-- =====================================================

exports("DrawText", function(text, position)
    ShowTextUI(text, { position = position })
end)

exports("HideDrawText", HideTextUI)

-- =====================================================
-- EXPORTS - COMPATIBILITY (ox_lib style)
-- =====================================================

exports("showText", ShowTextUI)
exports("hideText", HideTextUI)

-- Additional aliases
exports("Show", ShowTextUI)
exports("Hide", HideTextUI)
exports("displayTextUI", ShowTextUI)

-- =====================================================
-- NUI CALLBACKS
-- =====================================================

RegisterNUICallback("getConfig", function(data, cb)
    cb({ colors = Config.Colors })
end)

RegisterNUICallback("selectOption", function(data, cb)
    local id = data.id
    local idx = data.index
    
    if id and idx and pointCallbacks[id] and pointCallbacks[id][idx] then
        local callback = pointCallbacks[id][idx].onSelect
        if callback then
            callback()
        end
    end
    cb("ok")
end)

RegisterNUICallback("scroll", function(data, cb)
    if data.index then
        selectedIndex = data.index
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
    cb("ok")
end)

-- =====================================================
-- MAIN LOOP
-- =====================================================

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        
        local closest = nil
        local closestDist = 999999
        local closestScreen = nil
        
        for id, point in pairs(points) do
            local dist = #(pCoords - point.coords)
            
            if dist <= point.displayDistance then
                sleep = 0
                
                if dist < closestDist then
                    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(point.coords.x, point.coords.y, point.coords.z)
                    if onScreen then
                        closest = point
                        closestDist = dist
                        closestScreen = { x = sx, y = sy }
                    end
                end
            end
        end
        
        if closest and not IsPauseMenuActive() and not IsScreenFadedOut() then
            local inRange = closestDist <= closest.distance
            
            if inRange then
                -- Get valid options
                local valid = {}
                for i, opt in ipairs(closest.options) do
                    local cbs = pointCallbacks[closest.id] and pointCallbacks[closest.id][i]
                    local check = {
                        job = opt.job,
                        gang = opt.gang,
                        canInteract = cbs and cbs.canInteract
                    }
                    
                    if CheckRequirements(check) then
                        table.insert(valid, {
                            index = i,
                            label = opt.label,
                            icon = opt.icon,
                            key = opt.key or "E"
                        })
                    end
                end
                
                if #valid > 0 then
                    if selectedIndex > #valid then selectedIndex = 1 end
                    
                    activePoint = closest.id
                    
                    SendNUIMessage({
                        action = "showOptions",
                        id = closest.id,
                        x = closestScreen.x,
                        y = closestScreen.y,
                        options = valid,
                        selectedIndex = selectedIndex
                    })
                else
                    if activePoint then
                        activePoint = nil
                        selectedIndex = 1
                        SendNUIMessage({ action = "hide" })
                    end
                end
            else
                -- Show marker
                if activePoint then
                    activePoint = nil
                    selectedIndex = 1
                end
                
                SendNUIMessage({
                    action = "showMarker",
                    id = closest.id,
                    x = closestScreen.x,
                    y = closestScreen.y
                })
            end
        else
            if activePoint then
                activePoint = nil
                selectedIndex = 1
                SendNUIMessage({ action = "hide" })
            end
            
            -- Also hide marker if nothing nearby
            SendNUIMessage({ action = "hide" })
        end
        
        Wait(sleep)
    end
end)

-- =====================================================
-- KEY PRESS
-- =====================================================

CreateThread(function()
    while true do
        local sleep = 100
        
        if activePoint and pointCallbacks[activePoint] then
            sleep = 0
            
            if IsControlJustReleased(0, 38) then -- E
                local point = points[activePoint]
                if point then
                    local valid = {}
                    for i, opt in ipairs(point.options) do
                        local cbs = pointCallbacks[activePoint][i]
                        if CheckRequirements({ job = opt.job, gang = opt.gang, canInteract = cbs and cbs.canInteract }) then
                            table.insert(valid, { idx = i })
                        end
                    end
                    
                    if valid[selectedIndex] then
                        local realIdx = valid[selectedIndex].idx
                        local cb = pointCallbacks[activePoint][realIdx]
                        if cb and cb.onSelect then
                            cb.onSelect()
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- =====================================================
-- SCROLL (Mouse wheel)
-- =====================================================

CreateThread(function()
    while true do
        local sleep = 100
        
        if activePoint then
            local point = points[activePoint]
            if point then
                local count = 0
                for i, opt in ipairs(point.options) do
                    local cbs = pointCallbacks[activePoint][i]
                    if CheckRequirements({ job = opt.job, gang = opt.gang, canInteract = cbs and cbs.canInteract }) then
                        count = count + 1
                    end
                end
                
                if count > 1 then
                    sleep = 0
                    
                    local changed = false
                    
                    if IsControlJustPressed(0, 241) then -- Scroll up
                        selectedIndex = selectedIndex - 1
                        if selectedIndex < 1 then selectedIndex = count end
                        changed = true
                    end
                    
                    if IsControlJustPressed(0, 242) then -- Scroll down
                        selectedIndex = selectedIndex + 1
                        if selectedIndex > count then selectedIndex = 1 end
                        changed = true
                    end
                    
                    if changed then
                        SendNUIMessage({
                            action = "updateSelection",
                            selectedIndex = selectedIndex
                        })
                        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- =====================================================
-- NUI FOCUS HIDE
-- =====================================================

CreateThread(function()
    while true do
        if IsNuiFocused() then
            if not isNuiFocused then
                isNuiFocused = true
                SendNUIMessage({ action = "setVisible", visible = false })
            end
        else
            if isNuiFocused then
                isNuiFocused = false
                SendNUIMessage({ action = "setVisible", visible = true })
            end
        end
        Wait(200)
    end
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler("onResourceStop", function(res)
    RemovePointsByResource(res)
    if res == GetCurrentResourceName() then
        SendNUIMessage({ action = "hideAll" })
    end
end)

-- =====================================================
-- EVENTS (for compatibility)
-- =====================================================

RegisterNetEvent("qs-textui:client:ShowTextUI", function(text, options)
    ShowTextUI(text, options)
end)

RegisterNetEvent("qs-textui:client:HideTextUI", function()
    HideTextUI()
end)

-- esx_textui events
RegisterNetEvent("esx_textui:TextUI", function(text, type)
    ShowTextUI(text, { style = type })
end)

RegisterNetEvent("esx_textui:HideUI", function()
    HideTextUI()
end)

-- =====================================================
-- DEBUG COMMANDS
-- =====================================================

RegisterCommand("testqs", function()
    local coords = GetEntityCoords(PlayerPedId())
    
    AddPoint({
        coords = coords,
        distance = 2.0,
        displayDistance = 10.0,
        options = {
            {
                label = "Open Bank",
                icon = "bank",
                onSelect = function()
                    print("Opening bank...")
                end
            },
            {
                label = "Check Balance",
                icon = "money",
                onSelect = function()
                    print("Checking balance...")
                end
            },
            {
                label = "Talk to Clerk",
                icon = "user",
                onSelect = function()
                    print("Talking...")
                end
            }
        }
    })
    
    print("^2[qs-textui]^7 Test point created!")
end, false)

RegisterCommand("testtext", function()
    ShowTextUI("Press to interact", { key = "E" })
    
    SetTimeout(5000, function()
        HideTextUI()
    end)
end, false)

RegisterCommand("hideqs", function()
    for id in pairs(points) do
        RemovePoint(id)
    end
    HideTextUI()
    print("^2[qs-textui]^7 All cleared!")
end, false)