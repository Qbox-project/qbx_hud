fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'qbx_hud'
author 'Qbus & Qbox Contributors'
version '1.0.0'
repository 'https://github.com/Qbox-project/qbx_hud'
description 'HUD for Qbox'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    '@ox_lib/init.lua',
    '@qbx_core/import.lua',
}

modules {
    'qbx_core:playerdata',
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
