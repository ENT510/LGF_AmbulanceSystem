local Shared = {}
local Config = require "modules.client.cl-config"

function Shared.notify(title, message, type, source)
    local context = lib.context
    if context == "client" then
        if Config.ProviderNotification == "ox_lib" then
            lib.notify({
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = 'top-left',
            })
        end
        if Config.ProviderNotification == "lgf_duipack" then
            TriggerEvent("LGF_DuiPack:sendDuiNotify", {
                Title = title,
                Message = message,
                Type = type,
                Duration = 5
            })
        end
    else
        if Config.ProviderNotification == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', source, {
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = 'top-left',
            })
        end
        if Config.ProviderNotification == "lgf_duipack" then
            TriggerClientEvent("LGF_DuiPack:sendDuiNotify", source, {
                Title = title,
                Message = message,
                Type = type,
                Duration = 5
            })
        end
    end
end


return Shared
