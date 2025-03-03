Client                            = {}
local Config                      = require "modules.client.cl-config"
local Utils                       = require "modules.client.cl-utils"
local Cam                         = require "modules.client.cl-cam"
local Shared                      = require "shared"
LocalPlayer.state.deathScreenBusy = false
Players                           = {}
local Legacy                      = exports.LEGACYCORE:GetCoreData()



RegisterNetEvent("LGF_AmbulanceSystem.Update.UpdateDeathStatus", function(target, status)
    Players[target] = Players[target] or {}
    Players[target].isPlayerDead = status
end)

RegisterNetEvent("LGF_AmbulanceSystem.Init.RevivePlayerTarget", function(targetId)
    if not targetId then return end
    Client.respawnPlayer(targetId)
end)


RegisterNetEvent("LGF_AmbulanceSystem.Init.SetDeathOnLoaded", function(target, status)
    Players[target] = Players[target] or {}
    Players[target].isPlayerDead = status
    local playerId = GetPlayerFromServerId(target)
    local playerPed = GetPlayerPed(playerId)
    lib.requestAnimDict(Config.animations["death_normal"].dict)
    TaskPlayAnim(playerPed, Config.animations["death_normal"].dict, Config.animations["death_normal"].clip, 50.0, 8.0, -1,
        1, 1.0, false, false, false)
    Wait(600)
    SetEntityHealth(playerPed, 0)
    Cam.StartCamera(playerPed, 0.0, 0.0, true, 0.0)
    Wait(300)
    Utils.doScreenFade("in", 200)
    Client.openDeathScreen({ Display = true, DeathSeconds = 60 })
    local deathTime = GetGameTimer()
    while Players[target].isPlayerDead do
        local elapsedSeconds = math.floor((GetGameTimer() - deathTime) / 1000)
        if elapsedSeconds >= 60 then
            Client.respawnPlayer(target)
        end
        Wait(500)
    end
end)

function Client.openDeathScreen(data)
    LocalPlayer.state.deathScreenBusy = data.Display
    local deathSeconds = data.DeathSeconds
    SendNUIMessage({
        action = "openDeathScreen",
        data = { Display = data.Display, DeathSeconds = deathSeconds or 60 }
    })
    CreateThread(function()
        while Players[cache.serverId].isPlayerDead do
            Wait(1)
            if IsControlJustReleased(0, 38) then
                local hasMoney = exports.LGF_Inventory:getMoneyCount("money") >= Config.priceForRevive

                if hasMoney then
                    local success, source = lib.callback.await("LGF_AmbulanceSystem.Revive.RemoveMoney", false,
                        cache.serverId, Config.priceForRevive)
                    if success then
                        Client.respawnPlayer(source)
                    end
                else
                    Shared.notify("No Money", "You dont have Enough money for pay", "error")
                end
            end
        end
    end)
end

function Client.changeDeathStatus(target, newStatus)
    if type(newStatus) ~= "boolean" then return end
    if type(target) == "string" then target = tonumber(target) end
    if not target or not newStatus then return end
    local success, newState = lib.callback.await("LGF_AmbulanceSystem.Update.UpdateStatusDeath", false, target, newStatus)
    return success, newState
end

function Client.stopPlayerDeath(target, coordsData)
    local playerId = GetPlayerFromServerId(target)
    local playerPed = GetPlayerPed(playerId)

    local coords = coordsData ~= nil and coordsData or GetEntityCoords(playerPed)

    Client.openDeathScreen({ Display = false, DeathSeconds = 0 })
    Wait(500)

    if coordsData ~= nil then
        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false)
    end


    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), false, false)

    TaskPlayAnim(playerPed, Config.animations["get_up"].dict, Config.animations["get_up"].clip, 8.0, -8.0, -1, 0, 0, 0, 0,
        0)
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetEntityInvincible(playerPed, false)
    SetEveryoneIgnorePlayer(target, false)
    ClearPedTasks(playerPed)
    Utils.doScreenFade("in", 700)
    Players[target].isPlayerDead = false
    Client.changeDeathStatus(target, false)
end

function Client.respawnPlayer(target, coords)
    if target == cache.serverId then
        local playerId = GetPlayerFromServerId(target)
        local playerPed = GetPlayerPed(playerId)
        local coordsData = coords
        Utils.doScreenFade("out", 1000)
        Cam.DestroyCamera()
        Client.stopPlayerDeath(target, coordsData)
        Wait(2000)
        FreezeEntityPosition(playerPed, false)
        ClearPedTasks(playerPed)
    end
end

function Client.initPlayerDeath(target)
    local playerId = GetPlayerFromServerId(target)
    Players[target] = Players[target] or {}
    local reviveSeconds = 60

    if Players[target].isPlayerDead then return end
    Players[target].isPlayerDead = true
    Client.changeDeathStatus(target, true)
    Utils.doScreenFade("out", 200)

    local playerPed = GetPlayerPed(playerId)
    lib.requestAnimDict(Config.animations["death_normal"].dict)
    TaskPlayAnim(playerPed, Config.animations["death_normal"].dict, Config.animations["death_normal"].clip, 50.0, 8.0, -1,
        1, 1.0, false, false, false)
    Wait(600)
    SetEntityHealth(playerPed, 0)
    Cam.StartCamera(playerPed, 0.0, 0.0, true, 0.0)
    Wait(300)
    Utils.doScreenFade("in", 200)
    Client.openDeathScreen({ Display = true, DeathSeconds = reviveSeconds })

    local deathTime = GetGameTimer()
    while Players[target].isPlayerDead do
        local elapsedSeconds = math.floor((GetGameTimer() - deathTime) / 1000)
        if elapsedSeconds >= reviveSeconds then
            Client.respawnPlayer(target, Config.respawnCoords)
        end

        Wait(500)
    end
end

RegisterCommand("killme", function()
    local sr = GetPlayerServerId(PlayerId())
    Client.initPlayerDeath(sr)
end, false)

function Client.conditionTarget(entity)
    local hasItem, itemCount = exports.LGF_Inventory:hasItem("bandage", 1)
    return IsPedAPlayer(entity)
        and IsEntityDead(entity) or
        IsPedDeadOrDying(entity, true) and hasItem and Legacy.DATA:GetPlayerMetadata("JobName") == "ambulance"
end

exports.ox_target:addGlobalPlayer({
    {
        icon = 'fa-solid fa-male',
        label = 'Revive Ped',
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            print(Legacy.DATA:GetPlayerMetadata("JobName") == "ambulance")
            return Client.conditionTarget(entity)
        end,
        onSelect = function(data)
            local targetId = NetworkGetPlayerIndexFromPed(data.entity)
            local id = GetPlayerServerId(targetId)
            local dict = lib.requestAnimDict("mini@cpr@char_a@cpr_str")
            TaskPlayAnim(cache.ped, dict, "cpr_pumpchest", 1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
            Wait(5000)
            local success = lib.callback.await("LGF_AmbulanceSystem.Update.UpdateStatusDeath", false, id, false, true)
            if success then
                ClearPedTasks(cache.ped)
            end
        end
    }
})

RegisterCommand("reviveme", function()
    Client.respawnPlayer(GetPlayerServerId(PlayerId()))
end, false)

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local victim = data[1]
    local victimDied = data[4]
    if not IsPedAPlayer(victim) then return end
    local playerPed = PlayerPedId()
    if victim == playerPed then
        if victimDied and GetEntityHealth(victim) == 0 then
            local victimServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim))
            Client.initPlayerDeath(victimServerId)
        end
    end
end)

exports("isPlayerDead", function(target)
    target = target or cache.serverId
    return Players[target].isPlayerDead
end)
