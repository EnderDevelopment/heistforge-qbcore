fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'EnderDevelopment'
description 'Secure in-game QBCore heist creator'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/schema.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/app.js',
    'html/style.css'
}

server_export 'GetHeist'
server_export 'GetHeists'
