if Config.Framework ~= 'esx' then
    return
end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    PlayerData = playerData
    Debug('player loaded', json.encode(playerData))
end)

CreateThread(function()
    PlayerData = GetPlayerData()
    Debug('init playerData')
end)

RegisterNetEvent('esx:setJob', function(jobData)
    PlayerData.job = jobData
end)

function TriggerServerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

function GetPlayerData()
    return ESX.GetPlayerData()
end

function GetPlayers()
    return ESX.Game.GetPlayers()
end

function GetPlayerIdentifier()
    return GetPlayerData().identifier
end

function GetJobName()
    return PlayerData?.job?.name or 'unemployed'
end

function GetJobGrade()
    return PlayerData?.job?.grade or 0
end
