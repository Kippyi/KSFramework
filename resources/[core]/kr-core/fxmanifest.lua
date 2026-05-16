fx_version 'cerulean'
game 'gta5'

author 'KSFramework'
description 'KR Core - Economy, Banking, Jobs, Character Management'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/init.lua',
    'server/jobs.lua',
    'server/banking.lua'
}

client_scripts {
    'client/init.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependencies {
    'ox_lib',
    'mysql-async'
}
