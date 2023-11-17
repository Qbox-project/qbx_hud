fx_version 'cerulean'
game 'gta5'

description 'HUD for Qbox'
repository 'https://github.com/Qbox-project/qbx_hud'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/*',
    'html/index.html',
    'html/styles.css',
    'html/responsive.css',
    'html/app.js',
    'config/*.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
