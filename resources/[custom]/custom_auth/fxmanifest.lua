fx_version 'cerulean'
game 'gta5'

author 'Purple Havoc'
description 'Custom Authentication System for QBCore (RPG, single character per account)'
version '2.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sha256.lua',
    'server/main.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

dependencies {
    'qb-core',
    'oxmysql',
}
