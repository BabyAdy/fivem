fx_version 'cerulean'
game 'gta5'

author 'Purple Havoc'
description 'Custom NUI chat: proximity local chat + premium / admin / helper channels'
version '2.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

dependencies {
    'qb-core',
    'custom_auth',
}
