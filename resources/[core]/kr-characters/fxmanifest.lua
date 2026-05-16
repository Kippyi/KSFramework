fx_version 'cerulean'
game 'gta5'

author 'KSFramework'
description 'KR Characters - Housing, Properties, Blips'
version '1.1.0'

shared_scripts {
    '@kr-lib/shared/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/housing.lua'
}

client_scripts {
    'client/housing.lua',
    'client/properties_blips.lua'
}

dependencies {
    'kr-lib',
    'kr-core',
    'mysql-async'
}
