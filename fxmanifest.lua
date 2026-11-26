fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kio_thermite'
author 'KIO Labs'
description 'Thermite minigame: place the charges, light the fuse, control the burn. Standalone. Start() returns true (open), false (failed) or nil (backed out).'
version '1.1.0'
repository 'https://github.com/KioLabs/kio_thermite'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'index.html'
files {
    'index.html',
}
