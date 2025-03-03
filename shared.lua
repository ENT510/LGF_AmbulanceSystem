local Shared = {}
local Config = require "modules.client.cl-config"

function Shared.notify(title, message, type, source)
    local context = lib.context
    if context == "client" then
        lib.notify({
            title = title,
            description = message,
            type = type,
            duration = 5000,
            position = 'top-left',
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = message,
            type = type,
            duration = 5000,
            position = 'top-left',
        })
    end
end

return Shared
