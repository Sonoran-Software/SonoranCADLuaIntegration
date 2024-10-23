fx_version 'cerulean'
games {'gta5'}

author 'Sonoran CAD'
description 'Sonoran CAD FiveM Integration'
version '2.9.33'

server_scripts {
    'core/http.js'
    ,'core/unzipper/unzip.js'
    ,'core/image.js'
    ,'core/logging.lua'
    ,'core/shared_functions.lua'
    ,'core/configuration.lua'
    ,'core/server.lua'
    ,'core/commands.lua'
    ,'core/httpd.lua'
    ,'core/unittracking.lua'
    ,'core/updater.lua'
    ,'core/apicheck.lua'
    ,'submodules/**/*_config.lua'
    ,'core/plugin_loader.lua'
    ,'submodules/**/sv_*.lua'
    ,'submodules/**/sv_*.js'
    ,'core/screenshot.lua'
               }
client_scripts {
    'core/logging.lua'
    ,'core/headshots.lua'
    ,'core/shared_functions.lua'
    ,'core/client.lua'
    ,'core/lighting.lua'
    ,'submodules/**/*_config.lua'
    ,'submodules/**/cl_*.lua'
    ,'submodules/**/cl_*.js'
}

ui_page 'core/client_nui/index.html'

files {
    'stream/**/*.ytyp',
    'core/client_nui/index.html',
    'core/client_nui/js/*.js',
    'core/client_nui/sounds/*.mp3',
    'core/client_nui/img/logo.gif'
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
