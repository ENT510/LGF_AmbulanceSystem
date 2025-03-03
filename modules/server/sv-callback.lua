local Server = {}
local Legacy = exports.LEGACYCORE:GetCoreData()

function Server.updateDeathStatus(target, isDead)
    local identifier = GetPlayerIdentifierByType(target, "license")
    local slot = Legacy.DATA:GetPlayerCharSlot(target)
    local result = MySQL.update.await(
        'UPDATE `users` SET `is_dead` = ? WHERE `identifier` = ? AND `charIdentifier` = ?',
        { isDead and 1 or 0, identifier, slot }
    )
    return result
end

lib.callback.register("LGF_AmbulanceSystem.Update.UpdateStatusDeath", function(source, target, state, reviveTarget)
    reviveTarget = reviveTarget or false
    local entity = GetPlayerPed(target)
    local id = target or source
    Entity(entity).state:set('isPlayerDead', state, true)
    TriggerClientEvent("LGF_AmbulanceSystem.Update.UpdateDeathStatus", -1, id, state)
    Server.updateDeathStatus(id, state)
    if reviveTarget then
        TriggerClientEvent("LGF_AmbulanceSystem.Init.RevivePlayerTarget", id, id)
    end
    return true
end)

function Server.getDeathStatus(target, slot, useDb)
    if useDb then
        local identifier = GetPlayerIdentifierByType(target, "license")
        local isDead = MySQL.scalar.await(
            'SELECT `is_dead` FROM `users` WHERE `identifier` = ? AND charIdentifier = ? LIMIT 1', {
                identifier,
                slot
            })

        return isDead == 1 and true or false
    else
        local entity = GetPlayerPed(target)
        local isDead = Entity(entity).state.isPlayerDead
        return isDead or false
    end
end

RegisterNetEvent('LegacyCore:PlayerLoaded')
AddEventHandler('LegacyCore:PlayerLoaded', function(slot, data, newPlayer)
    local status = Server.getDeathStatus(data.source, slot, true)
    local entity = GetPlayerPed(data.source)
    if status then
        TriggerClientEvent("LGF_AmbulanceSystem.Init.SetDeathOnLoaded", -1, data.source, true)
        Entity(entity).state.isPlayerDead = true
    else
        TriggerClientEvent("LGF_AmbulanceSystem.Update.UpdateDeathStatus", -1, data.source, false)
        Entity(entity).state.isPlayerDead = false
    end
end)

exports("isPlayerDead", function(target, fetchDb)
    local slot = Legacy.DATA:GetPlayerCharSlot(target)
    return Server.getDeathStatus(target, slot, fetchDb)
end)
