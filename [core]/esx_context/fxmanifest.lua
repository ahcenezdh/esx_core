fx_version 'cerulean'

game 'gta5'
author 'ESX-Framework & Brayden'
description 'Offical ESX Legacy Context Menu'
lua54 'yes'
version '1.9.4'

ui_page 'web/index.html'

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'main.lua',
}

files {
    'web/**'
}

dependencies {
    'es_extended'
}
