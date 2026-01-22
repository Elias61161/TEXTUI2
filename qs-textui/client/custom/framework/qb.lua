if Config.Framework ~= 'qb' then
    return
end

QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobData)
    PlayerData.job = jobData
end)

CreateThread(function()
    PlayerData = GetPlayerData()
end)

function TriggerServerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

function GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function GetPlayers()
    return QBCore.Functions.GetPlayers()
end

function GetPlayerIdentifier()
    return GetPlayerData().citizenid
end

function GetJobName()
    return PlayerData?.job?.name or 'unemployed'
end

function GetJobGrade()
    return PlayerData?.job?.grade?.level or 0
end
