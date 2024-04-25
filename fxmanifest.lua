fx_version 'cerulean'
game 'gta5'

description 'qbx_hud'
repository 'https://github.com/Qbox-project/qbx_hud'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

ui_page 'html/index.html'
files {
    'locales/*.json',
    'config/client.lua',
    '@pma-voice/shared.lua',
	'html/*'
}

dependencies {
    'ox_lib',
    'qbx_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'