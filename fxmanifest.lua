fx_version 'cerulean'
game 'gta5'

description 'qbx_hud'
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
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

ui_page "html/index.html"
files {
	"html/index.html",
    "html/style.css",
    "html/script.js",
    "config/client.lua",
    "config/server.lua",
}

dependencies {
    'ox_lib',
    'qbx_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'