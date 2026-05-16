fx_version 'cerulean'
game 'gta5'

author 'KSFramework'
description 'KR Inventory - Item Management System'
version '1.1.0'

shared_scripts {
    '@kr-lib/shared/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/init.lua'
}

client_scripts {
    'client/init.lua'
}

dependencies {
    'kr-lib',
    'kr-core',
    'mysql-async'
}
