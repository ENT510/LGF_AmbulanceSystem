fx_version 'adamant'
game 'gta5'
author 'ENT510'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua',
}

client_scripts {
    'modules/client/cl-config.lua',
    'modules/client/cl-utils.lua',
    'modules/client/cl-cam.lua',
    'modules/client/cl-main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/server/sv-config.lua',
    'modules/server/sv-callback.lua',
}


files {
    'web/build/index.html',
    'web/build/**/*',
  }
  
  
  ui_page 'web/build/index.html'
  
