fx_version 'cerulean'
game 'gta5'

description 'QBX_Hud'
repository 'https://github.com/Qbox-project/qbx_hud'
version '1.0.0'

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

lua54 'yes'
use_experimental_fxv2_oal 'yes'
