Config = {}

Config.priceForRevive = 4000

Config.respawnCoords = vec4(296.6872, -573.5970, 43.1397, 151.9501)
Config.ProviderNotification = "ox_lib"
Config.animations = {
    ["death_car"] = {
        dict = "veh@low@front_ps@idle_duck",
        clip = "sit"
    },
    ["death_normal"] = {
        dict = "dead",
        clip = "dead_a"
    },
    ["get_up"] = {
        dict = "get_up@directional@movement@from_knees@action",
        clip = "getup_r_0"
    }
}




return Config
