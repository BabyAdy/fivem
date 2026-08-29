fx_version 'cerulean'
game 'gta5'

author 'Purple Havoc'
description 'Custom HUD — identity block, money/bank/PP with live +/- animations, staff shield, speedometer'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/vehicle.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/logo.png',
}

dependencies {
    'qb-core',
    'custom_auth',
}
