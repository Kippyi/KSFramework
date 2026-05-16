fx_version 'cerulean'
game 'gta5'

author 'KSFramework'
description 'KR-Lib - Custom utility library for KSFramework'
version '1.0.0'

shared_scripts {
    'shared/main.lua'
}

client_scripts {
    'client/notifications.lua',
    'client/progress.lua',
    'client/keybinds.lua',
    'client/textui.lua',
    'client/menu.lua'
}

server_scripts {
    'server/utils.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}
