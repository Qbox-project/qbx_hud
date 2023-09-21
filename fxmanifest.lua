fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'qbx-hud'
author 'Qbus & Qbox Contributors'
version '1.0.0'
repository 'https://github.com/Qbox-project/qbx-hud'
description 'HUD for Qbox'

shared_scripts {
    '@qbx-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    '@ox_lib/init.lua',
    '@qbx-core/import.lua',
}

modules {
    'qbx-core:core',
    'qbx-core:playerdata',
}

server_script 'server.lua'
client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/*',
    'html/index.html',
    'html/styles.css',
    'html/responsive.css',
    'html/app.js',
}
